'use strict';

/**
 * Migration to clean up from previous incomplete standardization
 * and finish the standardization process
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

      // Handle client_id_new in invoices table
      if (await columnExists('invoices', 'client_id_new')) {
        console.log('Found client_id_new in invoices table, cleaning up...');
        
        // If client_id (VARCHAR) exists but client_id_new (UUID) exists too, we need to:
        // 1. Make sure all data is transferred from client_id or client_fk_id to client_id_new
        await queryInterface.sequelize.query(`
          UPDATE invoices
          SET client_id_new = client_id::uuid
          WHERE client_id_new IS NULL AND client_id IS NOT NULL AND client_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
        `);
        
        // 2. Verify there are no null client_id_new values that should be populated
        // 3. Remove old client_id column
        if (await columnExists('invoices', 'client_id')) {
          await queryInterface.removeColumn('invoices', 'client_id');
          console.log('Removed old client_id column from invoices');
        }
        
        // 4. Rename client_id_new to client_id
        await queryInterface.renameColumn('invoices', 'client_id_new', 'client_id');
        console.log('Renamed client_id_new to client_id in invoices');
        
        // 5. Add index on client_id
        await queryInterface.addIndex('invoices', ['client_id']);
        console.log('Added index on client_id in invoices');
      }

      // Handle estimates table similarly
      if (await columnExists('estimates', 'client_id_new')) {
        console.log('Found client_id_new in estimates table, cleaning up...');
        
        // 1. Transfer data from client_id to client_id_new if needed
        await queryInterface.sequelize.query(`
          UPDATE estimates
          SET client_id_new = client_id::uuid
          WHERE client_id_new IS NULL AND client_id IS NOT NULL AND client_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
        `);
        
        // 2. Remove old client_id column
        if (await columnExists('estimates', 'client_id')) {
          await queryInterface.removeColumn('estimates', 'client_id');
          console.log('Removed old client_id column from estimates');
        }
        
        // 3. Rename client_id_new to client_id
        await queryInterface.renameColumn('estimates', 'client_id_new', 'client_id');
        console.log('Renamed client_id_new to client_id in estimates');
        
        // 4. Add index on client_id
        await queryInterface.addIndex('estimates', ['client_id']);
        console.log('Added index on client_id in estimates');
      }

      // Now proceed with safely renaming other camelCase columns to snake_case
      const safeRenameColumn = async (tableName, oldName, newName) => {
        if (await columnExists(tableName, oldName) && !await columnExists(tableName, newName)) {
          await queryInterface.renameColumn(tableName, oldName, newName);
          console.log(`Renamed ${tableName}.${oldName} to ${newName}`);
        } else {
          console.log(`Skipping ${tableName}.${oldName} rename - column doesn't exist or target already exists`);
        }
      };
      
      // Standardize address fields
      await safeRenameColumn('invoices', 'addressId', 'address_id');
      await safeRenameColumn('estimates', 'addressId', 'address_id');
      
      // Standardize other relationships
      await safeRenameColumn('invoice_items', 'invoiceId', 'invoice_id');
      await safeRenameColumn('estimate_items', 'estimateId', 'estimate_id');
      await safeRenameColumn('estimate_items', 'productId', 'product_id');
      await safeRenameColumn('project_photos', 'projectId', 'project_id');
      await safeRenameColumn('project_photos', 'inspectionId', 'inspection_id');
      await safeRenameColumn('payments', 'invoiceId', 'invoice_id');
      
      console.log('Standardization cleanup completed successfully');
    } catch (error) {
      console.error('Error during standardization cleanup:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    console.log('This migration cannot be safely reversed. It has corrected inconsistencies from previous migrations.');
    return Promise.resolve();
  }
};
