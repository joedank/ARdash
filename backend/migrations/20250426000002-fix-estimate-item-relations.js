'use strict';

/**
 * This migration fixes issues with estimate_item_additional_work relations
 * by checking if they exist before trying to create them.
 */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      console.log('Starting fix for estimate_item_additional_work relations...');
      
      // Check if the relation already exists
      const relationExists = async (relationName) => {
        try {
          const query = `
            SELECT constraint_name
            FROM information_schema.table_constraints
            WHERE constraint_name = '${relationName}'
          `;
          const result = await queryInterface.sequelize.query(query, {
            type: queryInterface.sequelize.QueryTypes.SELECT
          });
          return result.length > 0;
        } catch (error) {
          console.error(`Error checking relation ${relationName}:`, error);
          return false;
        }
      };
      
      // Check if the table exists
      const tableExists = async (tableName) => {
        try {
          const query = `
            SELECT table_name
            FROM information_schema.tables
            WHERE table_name = '${tableName}'
          `;
          const result = await queryInterface.sequelize.query(query, {
            type: queryInterface.sequelize.QueryTypes.SELECT
          });
          return result.length > 0;
        } catch (error) {
          console.error(`Error checking table ${tableName}:`, error);
          return false;
        }
      };
      
      // Check if the column exists
      const columnExists = async (tableName, columnName) => {
        try {
          const query = `
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = '${tableName}'
            AND column_name = '${columnName}'
          `;
          const result = await queryInterface.sequelize.query(query, {
            type: queryInterface.sequelize.QueryTypes.SELECT
          });
          return result.length > 0;
        } catch (error) {
          console.error(`Error checking column ${columnName} in table ${tableName}:`, error);
          return false;
        }
      };
      
      // Check if estimate_item_additional_work table exists
      if (await tableExists('estimate_item_additional_work')) {
        console.log('estimate_item_additional_work table exists');
        
        // Check if estimate_item_id column exists
        if (await columnExists('estimate_item_additional_work', 'estimate_item_id')) {
          console.log('estimate_item_id column exists in estimate_item_additional_work table');
          
          // Check if the relation already exists
          if (await relationExists('estimate_item_additional_work_estimate_item_id')) {
            console.log('Relation estimate_item_additional_work_estimate_item_id already exists, skipping...');
          } else {
            console.log('Adding foreign key constraint for estimate_item_id...');
            await queryInterface.addConstraint('estimate_item_additional_work', {
              fields: ['estimate_item_id'],
              type: 'foreign key',
              name: 'estimate_item_additional_work_estimate_item_id',
              references: {
                table: 'estimate_items',
                field: 'id'
              },
              onDelete: 'CASCADE',
              onUpdate: 'CASCADE'
            });
          }
        } else {
          console.log('estimate_item_id column does not exist in estimate_item_additional_work table, skipping...');
        }
      } else {
        console.log('estimate_item_additional_work table does not exist, skipping...');
      }
      
      console.log('Successfully fixed estimate_item_additional_work relations');
    } catch (error) {
      console.error('Error fixing estimate_item_additional_work relations:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    console.log('This migration ensures database consistency and should not be reverted.');
    return Promise.resolve();
  }
};
