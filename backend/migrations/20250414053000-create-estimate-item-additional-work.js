'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      // Check if table already exists
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

      // Check if index already exists
      const indexExists = async (tableName, indexName) => {
        try {
          const query = `
            SELECT indexname
            FROM pg_indexes
            WHERE tablename = '${tableName}'
            AND indexname = '${indexName}'
          `;
          const result = await queryInterface.sequelize.query(query, {
            type: queryInterface.sequelize.QueryTypes.SELECT
          });
          return result.length > 0;
        } catch (error) {
          console.error(`Error checking index ${indexName} on ${tableName}:`, error);
          return false;
        }
      };

      // Create table if it doesn't exist
      if (!(await tableExists('estimate_item_additional_work'))) {
        console.log('Creating estimate_item_additional_work table...');
        await queryInterface.createTable('estimate_item_additional_work', {
          id: {
            type: Sequelize.UUID,
            defaultValue: Sequelize.UUIDV4,
            primaryKey: true
          },
          estimate_item_id: {
            type: Sequelize.UUID,
            allowNull: false,
            references: {
              model: 'estimate_items',
              key: 'id'
            },
            onUpdate: 'CASCADE',
            onDelete: 'CASCADE'
          },
          description: {
            type: Sequelize.TEXT,
            allowNull: false
          },
          created_at: {
            type: Sequelize.DATE,
            allowNull: false,
            defaultValue: Sequelize.fn('NOW')
          },
          updated_at: {
            type: Sequelize.DATE,
            allowNull: false,
            defaultValue: Sequelize.fn('NOW')
          }
        });
        console.log('estimate_item_additional_work table created successfully');
      } else {
        console.log('estimate_item_additional_work table already exists, skipping creation');
      }

      // Add index if it doesn't exist
      const indexName = 'estimate_item_additional_work_estimate_item_id_idx';
      if (await tableExists('estimate_item_additional_work') && !(await indexExists('estimate_item_additional_work', indexName))) {
        console.log('Adding index on estimate_item_id...');
        await queryInterface.addIndex('estimate_item_additional_work', ['estimate_item_id'], {
          name: indexName
        });
        console.log('Index added successfully');
      } else {
        console.log('Index already exists or table does not exist, skipping index creation');
      }
    } catch (error) {
      console.error('Error in migration:', error);
      throw error;
    }
  },

  down: async (queryInterface, Sequelize) => {
    try {
      // Check if table exists before dropping
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

      if (await tableExists('estimate_item_additional_work')) {
        console.log('Dropping estimate_item_additional_work table...');
        await queryInterface.dropTable('estimate_item_additional_work');
        console.log('Table dropped successfully');
      } else {
        console.log('estimate_item_additional_work table does not exist, nothing to drop');
      }
    } catch (error) {
      console.error('Error in down migration:', error);
      throw error;
    }
  }
};
