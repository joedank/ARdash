'use strict';

/**
 * Script to create a sample work type
 * 
 * This script creates a sample work type with cost data
 * 
 * Usage: node scripts/create-sample-work-type.js
 */

const { v4: uuidv4 } = require('uuid');
const { Pool } = require('pg');

// Create a PostgreSQL connection pool
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'management_db',
  password: 'postgres',
  port: 5432,
});

/**
 * Create a sample work type
 */
async function createSampleWorkType() {
  console.log('Creating sample work type...');
  
  const client = await pool.connect();
  
  try {
    // Start a transaction
    await client.query('BEGIN');
    
    // Create a sample work type
    const workTypeId = uuidv4();
    await client.query(`
      INSERT INTO work_types (
        id, name, parent_bucket, measurement_type, suggested_units,
        unit_cost_material, unit_cost_labor, productivity_unit_per_hr,
        revision, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW())
    `, [
      workTypeId,
      'Install Drywall',
      'Interior-Finish',
      'area',
      'sq ft',
      1.25,
      2.75,
      50,
      1
    ]);
    
    console.log(`Created sample work type with ID: ${workTypeId}`);
    
    // Create a cost history record
    const costHistoryId = uuidv4();
    await client.query(`
      INSERT INTO work_type_cost_history (
        id, work_type_id, region, unit_cost_material, unit_cost_labor,
        captured_at, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, NOW(), NOW(), NOW())
    `, [
      costHistoryId,
      workTypeId,
      'default',
      1.25,
      2.75
    ]);
    
    console.log(`Created cost history record with ID: ${costHistoryId}`);
    
    // Create a tag
    await client.query(`
      INSERT INTO work_type_tags (
        work_type_id, tag, created_at, updated_at
      ) VALUES ($1, $2, NOW(), NOW())
    `, [
      workTypeId,
      'dust-control'
    ]);
    
    console.log('Added tag: dust-control');
    
    // Commit the transaction
    await client.query('COMMIT');
    console.log('Sample work type creation completed successfully');
    
    return {
      workTypeId,
      costHistoryId
    };
  } catch (error) {
    // Rollback the transaction on error
    await client.query('ROLLBACK');
    console.error('Error creating sample work type:', error);
    throw error;
  } finally {
    // Release the client back to the pool
    client.release();
  }
}

// Run the script
createSampleWorkType()
  .then(result => {
    console.log('Creation results:', result);
    process.exit(0);
  })
  .catch(error => {
    console.error('Creation failed:', error);
    process.exit(1);
  });
