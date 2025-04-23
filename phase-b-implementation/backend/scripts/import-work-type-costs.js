'use strict';

/**
 * Script to backfill cost history for existing work types
 * 
 * This script creates cost history records for all work types that have cost data
 * but no corresponding history records.
 * 
 * Usage: node scripts/import-work-type-costs.js
 */

const { v4: uuidv4 } = require('uuid');
const { WorkType, WorkTypeCostHistory, sequelize } = require('../src/models');
const logger = require('../src/utils/logger');

// Default admin user ID for history records
const ADMIN_USER_ID = process.env.ADMIN_USER_ID || '00000000-0000-0000-0000-000000000000';

/**
 * Backfill cost history for work types
 */
async function backfillCostHistory() {
  logger.info('Starting cost history backfill...');
  
  const transaction = await sequelize.transaction();
  
  try {
    // Get all work types with cost data
    const workTypes = await WorkType.findAll({
      where: {
        [sequelize.Op.or]: [
          { unit_cost_material: { [sequelize.Op.not]: null } },
          { unit_cost_labor: { [sequelize.Op.not]: null } }
        ]
      },
      transaction
    });
    
    logger.info(`Found ${workTypes.length} work types with cost data`);
    
    // Create history records for each work type
    const historyRecords = [];
    
    for (const workType of workTypes) {
      // Check if history already exists
      const existingHistory = await WorkTypeCostHistory.findOne({
        where: { work_type_id: workType.id },
        transaction
      });
      
      if (!existingHistory) {
        historyRecords.push({
          id: uuidv4(),
          work_type_id: workType.id,
          region: 'default',
          unit_cost_material: workType.unit_cost_material,
          unit_cost_labor: workType.unit_cost_labor,
          captured_at: workType.updated_at || new Date(),
          updated_by: ADMIN_USER_ID,
          created_at: new Date(),
          updated_at: new Date()
        });
      }
    }
    
    if (historyRecords.length > 0) {
      // Bulk create history records
      await WorkTypeCostHistory.bulkCreate(historyRecords, { transaction });
      logger.info(`Created ${historyRecords.length} cost history records`);
    } else {
      logger.info('No new cost history records needed');
    }
    
    await transaction.commit();
    logger.info('Cost history backfill completed successfully');
    
    return {
      totalWorkTypes: workTypes.length,
      historyRecordsCreated: historyRecords.length
    };
  } catch (error) {
    await transaction.rollback();
    logger.error('Error backfilling cost history:', error);
    throw error;
  }
}

// Run the script if called directly
if (require.main === module) {
  backfillCostHistory()
    .then(result => {
      logger.info('Backfill results:', result);
      process.exit(0);
    })
    .catch(error => {
      logger.error('Backfill failed:', error);
      process.exit(1);
    });
}

module.exports = { backfillCostHistory };
