'use strict';

/**
 * Script to backfill cost history for existing work types
 * 
 * This script creates cost history records for all work types that have cost data
 * but no corresponding history records.
 * 
 * Usage: node scripts/backfill-cost-history.js
 */

const { v4: uuidv4 } = require('uuid');
const { Pool } = require('pg');

// Default admin user ID for history records
const ADMIN_USER_ID = '00000000-0000-0000-0000-000000000000';

// Create a PostgreSQL connection pool
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'management_db',
  password: 'postgres',
  port: 5432,
});

/**
 * Backfill cost history for work types
 */
async function backfillCostHistory() {
  console.log('Starting cost history backfill...');
  
  const client = await pool.connect();
  
  try {
    // Start a transaction
    await client.query('BEGIN');
    
    // Get all work types with cost data
    const workTypesResult = await client.query(`
      SELECT id, unit_cost_material, unit_cost_labor, updated_at
      FROM work_types
      WHERE unit_cost_material IS NOT NULL OR unit_cost_labor IS NOT NULL
    `);
    
    const workTypes = workTypesResult.rows;
    console.log(`Found ${workTypes.length} work types with cost data`);
    
    // Create history records for each work type
    const historyRecords = [];
    
    for (const workType of workTypes) {
      // Check if history already exists
      const existingHistoryResult = await client.query(
        'SELECT id FROM work_type_cost_history WHERE work_type_id = $1 LIMIT 1',
        [workType.id]
      );
      
      if (existingHistoryResult.rows.length === 0) {
        historyRecords.push({
          id: uuidv4(),
          work_type_id: workType.id,
          region: 'default',
          unit_cost_material: workType.unit_cost_material,
          unit_cost_labor: workType.unit_cost_labor,
          captured_at: workType.updated_at || new Date(),
          updated_by: ADMIN_USER_ID
        });
      }
    }
    
    if (historyRecords.length > 0) {
      // Bulk create history records
      for (const record of historyRecords) {
        await client.query(`
          INSERT INTO work_type_cost_history (
            id, work_type_id, region, unit_cost_material, unit_cost_labor, 
            captured_at, updated_by, created_at, updated_at
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
        `, [
          record.id,
          record.work_type_id,
          record.region,
          record.unit_cost_material,
          record.unit_cost_labor,
          record.captured_at,
          record.updated_by
        ]);
      }
      console.log(`Created ${historyRecords.length} cost history records`);
    } else {
      console.log('No new cost history records needed');
    }
    
    // Commit the transaction
    await client.query('COMMIT');
    console.log('Cost history backfill completed successfully');
    
    return {
      totalWorkTypes: workTypes.length,
      historyRecordsCreated: historyRecords.length
    };
  } catch (error) {
    // Rollback the transaction on error
    await client.query('ROLLBACK');
    console.error('Error backfilling cost history:', error);
    throw error;
  } finally {
    // Release the client back to the pool
    client.release();
  }
}

// Run the script
backfillCostHistory()
  .then(result => {
    console.log('Backfill results:', result);
    process.exit(0);
  })
  .catch(error => {
    console.error('Backfill failed:', error);
    process.exit(1);
  });
