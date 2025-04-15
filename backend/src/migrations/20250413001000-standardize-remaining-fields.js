'use strict';

/**
 * Migration to standardize field names across remaining entities
 * Ensures consistent naming convention (snake_case) for database fields
 * Updated with column existence checks to prevent errors
 */
module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Transaction to ensure atomicity
    const transaction = await queryInterface.sequelize.transaction();
    
    try {
      // Helper function to safely rename columns
      const safeRenameColumn = async (tableName, oldName, newName) => {
        const tableInfo = await queryInterface.describeTable(tableName);
        if (tableInfo[oldName] && !tableInfo[newName]) {
          await queryInterface.renameColumn(tableName, oldName, newName, { transaction });
          console.log(`Renamed ${tableName}.${oldName} to ${newName}`);
        } else {
          console.log(`Skipping ${tableName}.${oldName} rename - column doesn't exist or target already exists`);
        }
      };
      
      // Standardize invoice fields
      await safeRenameColumn('invoices', 'clientId', 'client_id');
      await safeRenameColumn('invoices', 'addressId', 'address_id');
      
      // Standardize estimate fields
      await safeRenameColumn('estimates', 'clientId', 'client_id');
      await safeRenameColumn('estimates', 'addressId', 'address_id');
      
      // Standardize invoice_items fields
      await safeRenameColumn('invoice_items', 'invoiceId', 'invoice_id');
      
      // Standardize estimate_items fields
      await safeRenameColumn('estimate_items', 'estimateId', 'estimate_id');
      await safeRenameColumn('estimate_items', 'productId', 'product_id');
      
      // Standardize project_photos fields (if not already standardized)
      await safeRenameColumn('project_photos', 'projectId', 'project_id');
      await safeRenameColumn('project_photos', 'inspectionId', 'inspection_id');
      
      // Standardize payments fields
      await safeRenameColumn('payments', 'invoiceId', 'invoice_id');
      
      // Commit transaction
      await transaction.commit();
      console.log('Field standardization migration completed successfully');
      return Promise.resolve();
    } catch (error) {
      // Rollback transaction on error
      await transaction.rollback();
      console.error('Migration failed:', error);
      return Promise.reject(error);
    }
  },

  down: async (queryInterface, Sequelize) => {
    console.log('This migration cannot be safely reversed automatically. Manual restoration would be needed if required.');
    return Promise.resolve();
  }
};
