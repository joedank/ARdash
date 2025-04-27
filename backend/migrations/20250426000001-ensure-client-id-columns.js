'use strict';

/**
 * This migration ensures that invoices and estimates tables have client_id columns
 * with the correct UUID type, without relying on client_fk_id which is deprecated.
 */
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
      
      // Helper function to get column type
      const getColumnType = async (tableName, columnName) => {
        try {
          const tableInfo = await queryInterface.describeTable(tableName);
          return tableInfo[columnName] ? tableInfo[columnName].type : null;
        } catch (error) {
          return null;
        }
      };
      
      console.log('Starting standardization of client_id columns...');
      
      // Handle invoices table
      if (await columnExists('invoices', 'client_id')) {
        // Check if client_id is already UUID type
        const clientIdType = await getColumnType('invoices', 'client_id');
        console.log(`Existing client_id column in invoices has type: ${clientIdType}`);
        
        if (clientIdType && !clientIdType.includes('UUID')) {
          console.log('client_id column in invoices is not UUID type, needs to be updated...');
          
          // Create a temporary column with UUID type
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
            
            // Try to convert existing client_id values to UUID if they match the pattern
            await queryInterface.sequelize.query(`
              UPDATE invoices
              SET client_id_new = client_id::uuid
              WHERE client_id IS NOT NULL 
              AND client_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
            `);
            
            // Remove old column and rename new one
            await queryInterface.removeColumn('invoices', 'client_id');
            await queryInterface.renameColumn('invoices', 'client_id_new', 'client_id');
            console.log('Successfully updated client_id column in invoices to UUID type');
          }
        } else {
          console.log('client_id column in invoices is already UUID type, no changes needed');
        }
      } else {
        // client_id doesn't exist, create it
        console.log('Adding client_id column to invoices table...');
        await queryInterface.addColumn('invoices', 'client_id', {
          type: Sequelize.UUID,
          allowNull: true,
          references: {
            model: 'clients',
            key: 'id'
          }
        });
      }
      
      // Handle estimates table
      if (await columnExists('estimates', 'client_id')) {
        // Check if client_id is already UUID type
        const clientIdType = await getColumnType('estimates', 'client_id');
        console.log(`Existing client_id column in estimates has type: ${clientIdType}`);
        
        if (clientIdType && !clientIdType.includes('UUID')) {
          console.log('client_id column in estimates is not UUID type, needs to be updated...');
          
          // Create a temporary column with UUID type
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
            
            // Try to convert existing client_id values to UUID if they match the pattern
            await queryInterface.sequelize.query(`
              UPDATE estimates
              SET client_id_new = client_id::uuid
              WHERE client_id IS NOT NULL 
              AND client_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
            `);
            
            // Remove old column and rename new one
            await queryInterface.removeColumn('estimates', 'client_id');
            await queryInterface.renameColumn('estimates', 'client_id_new', 'client_id');
            console.log('Successfully updated client_id column in estimates to UUID type');
          }
        } else {
          console.log('client_id column in estimates is already UUID type, no changes needed');
        }
      } else {
        // client_id doesn't exist, create it
        console.log('Adding client_id column to estimates table...');
        await queryInterface.addColumn('estimates', 'client_id', {
          type: Sequelize.UUID,
          allowNull: true,
          references: {
            model: 'clients',
            key: 'id'
          }
        });
      }
      
      // Add indices on client_id columns if they don't exist - using SQL with DROP/CREATE pattern
      try {
        console.log('Adding index on client_id in invoices...');
        await queryInterface.sequelize.query(`
          DROP INDEX IF EXISTS invoices_client_id_idx;
          CREATE INDEX invoices_client_id_idx ON invoices(client_id);
        `);
      } catch (error) {
        console.log('Error adding index on client_id in invoices:', error.message);
      }
      
      try {
        console.log('Adding index on client_id in estimates...');
        await queryInterface.sequelize.query(`
          DROP INDEX IF EXISTS estimates_client_id_idx;
          CREATE INDEX estimates_client_id_idx ON estimates(client_id);
        `);
      } catch (error) {
        console.log('Error adding index on client_id in estimates:', error.message);
      }
      
      console.log('Successfully ensured client_id columns in invoices and estimates tables');
    } catch (error) {
      console.error('Error ensuring client_id columns:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    console.log('This migration ensures database consistency and should not be reverted.');
    return Promise.resolve();
  }
};
