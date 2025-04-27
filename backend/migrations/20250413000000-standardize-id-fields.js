'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Helper function to check if column exists
      const columnExists = async (tableName, columnName) => {
        try {
          const tableInfo = await queryInterface.describeTable(tableName);
          return !!tableInfo[columnName];
        } catch (error) {
          return false;
        }
      };

      // Step 1: Add new standardized client_id column to invoices table if it doesn't exist
      if (!(await columnExists('invoices', 'client_id_new'))) {
        console.log('Adding client_id_new column to invoices table...');
        await queryInterface.addColumn('invoices', 'client_id_new', {
          type: Sequelize.UUID,
          allowNull: true,
          references: {
            model: 'clients',
            key: 'id'
          }
        });
      } else {
        console.log('client_id_new column already exists in invoices table, skipping...');
      }

      // Step 2: Copy data from client_fk_id to the new client_id_new column if client_fk_id exists
      if (await columnExists('invoices', 'client_fk_id')) {
        console.log('Copying data from client_fk_id to client_id_new in invoices...');
        await queryInterface.sequelize.query(`
          UPDATE invoices
          SET client_id_new = client_fk_id
          WHERE client_fk_id IS NOT NULL
        `);
      } else {
        console.log('client_fk_id column does not exist in invoices, skipping data copy...');
      }

      // Step 3: Add new standardized client_id column to estimates table if it doesn't exist
      if (!(await columnExists('estimates', 'client_id_new'))) {
        console.log('Adding client_id_new column to estimates table...');
        await queryInterface.addColumn('estimates', 'client_id_new', {
          type: Sequelize.UUID,
          allowNull: true,
          references: {
            model: 'clients',
            key: 'id'
          }
        });
      } else {
        console.log('client_id_new column already exists in estimates table, skipping...');
      }

      // Step 4: Copy data from client_fk_id to the new client_id_new column if client_fk_id exists
      if (await columnExists('estimates', 'client_fk_id')) {
        console.log('Copying data from client_fk_id to client_id_new in estimates...');
        await queryInterface.sequelize.query(`
          UPDATE estimates
          SET client_id_new = client_fk_id
          WHERE client_fk_id IS NOT NULL
        `);
      } else {
        console.log('client_fk_id column does not exist in estimates, skipping data copy...');
      }

      // Step 5: Drop foreign key constraints on client_fk_id columns if they exist
      // Helper function to check if constraint exists
      const constraintExists = async (tableName, constraintName) => {
        try {
          const query = `
            SELECT constraint_name
            FROM information_schema.table_constraints
            WHERE table_name = '${tableName}'
            AND constraint_name = '${constraintName}'
          `;
          const result = await queryInterface.sequelize.query(query, {
            type: queryInterface.sequelize.QueryTypes.SELECT
          });
          return result.length > 0;
        } catch (error) {
          console.error(`Error checking constraint ${constraintName} on ${tableName}:`, error);
          return false;
        }
      };

      if (await constraintExists('invoices', 'invoices_client_fk_id_fkey')) {
        console.log('Removing constraint invoices_client_fk_id_fkey...');
        await queryInterface.removeConstraint('invoices', 'invoices_client_fk_id_fkey');
      } else {
        console.log('Constraint invoices_client_fk_id_fkey does not exist, skipping...');
      }

      if (await constraintExists('estimates', 'estimates_client_fk_id_fkey')) {
        console.log('Removing constraint estimates_client_fk_id_fkey...');
        await queryInterface.removeConstraint('estimates', 'estimates_client_fk_id_fkey');
      } else {
        console.log('Constraint estimates_client_fk_id_fkey does not exist, skipping...');
      }

      // Step 6: Rename client_id_new to client_id in invoices table
      if (await columnExists('invoices', 'client_fk_id')) {
        console.log('Removing client_fk_id column from invoices...');
        await queryInterface.removeColumn('invoices', 'client_fk_id');
      } else {
        console.log('client_fk_id column does not exist in invoices, skipping removal...');
      }

      if (await columnExists('invoices', 'client_id_new') && !(await columnExists('invoices', 'client_id'))) {
        console.log('Renaming client_id_new to client_id in invoices...');
        await queryInterface.renameColumn('invoices', 'client_id_new', 'client_id');
      } else if (await columnExists('invoices', 'client_id_new') && await columnExists('invoices', 'client_id')) {
        console.log('Both client_id_new and client_id exist in invoices, removing client_id_new...');
        await queryInterface.removeColumn('invoices', 'client_id_new');
      } else {
        console.log('Cannot rename client_id_new to client_id in invoices, columns not in expected state...');
      }

      // Step 7: Rename client_id_new to client_id in estimates table
      if (await columnExists('estimates', 'client_fk_id')) {
        console.log('Removing client_fk_id column from estimates...');
        await queryInterface.removeColumn('estimates', 'client_fk_id');
      } else {
        console.log('client_fk_id column does not exist in estimates, skipping removal...');
      }

      if (await columnExists('estimates', 'client_id_new') && !(await columnExists('estimates', 'client_id'))) {
        console.log('Renaming client_id_new to client_id in estimates...');
        await queryInterface.renameColumn('estimates', 'client_id_new', 'client_id');
      } else if (await columnExists('estimates', 'client_id_new') && await columnExists('estimates', 'client_id')) {
        console.log('Both client_id_new and client_id exist in estimates, removing client_id_new...');
        await queryInterface.removeColumn('estimates', 'client_id_new');
      } else {
        console.log('Cannot rename client_id_new to client_id in estimates, columns not in expected state...');
      }

      // Step 8: Add index on the new client_id column in invoices if it doesn't exist
      try {
        console.log('Adding index on client_id in invoices...');
        await queryInterface.addIndex('invoices', ['client_id'], {
          name: 'invoices_client_id_idx',
          ifNotExists: true
        });
      } catch (error) {
        console.log('Error adding index on client_id in invoices, may already exist:', error.message);
      }

      // Step 9: Add index on the new client_id column in estimates if it doesn't exist
      try {
        console.log('Adding index on client_id in estimates...');
        await queryInterface.addIndex('estimates', ['client_id'], {
          name: 'estimates_client_id_idx',
          ifNotExists: true
        });
      } catch (error) {
        console.log('Error adding index on client_id in estimates, may already exist:', error.message);
      }

      console.log('Successfully standardized client ID field names in invoices and estimates tables');
    } catch (error) {
      console.error('Error standardizing client ID field names:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    console.log('This migration has been made idempotent and should not need to be reverted.');
    console.log('If you need to revert, please do so manually with careful consideration of the current database state.');
    return Promise.resolve();
  }
};