'use strict';

// Import the ViewManager utility
const ViewManager = require('../src/utils/ViewManager');
const viewDefinitions = require('../src/config/viewDefinitions');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Using a transaction to ensure all operations succeed or fail together
    return queryInterface.sequelize.transaction(async (transaction) => {
      try {
        console.log('Starting migration to modify payment_terms column...');
        
        // Initialize the ViewManager
        const viewManager = new ViewManager(queryInterface);
        
        // Explicitly drop the view, modify the column, and recreate the view
        await viewManager.queryInterface.sequelize.query(
          `DROP VIEW IF EXISTS client_view;`,
          { transaction }
        );
        
        // Now safely modify the column without view dependencies
        await viewManager.queryInterface.sequelize.query(
          `ALTER TABLE "clients" ALTER COLUMN "payment_terms" TYPE VARCHAR(255);`,
          { transaction }
        );
        
        // Recreate the view using the stored definition
        await viewManager.queryInterface.sequelize.query(
          viewDefinitions.client_view,
          { transaction }
        );
        
        console.log('Migration completed successfully');
        return Promise.resolve();
      } catch (error) {
        console.error('Migration failed:', error);
        return Promise.reject(error);
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    // If needed to revert, use the same approach
    return queryInterface.sequelize.transaction(async (transaction) => {
      const viewManager = new ViewManager(queryInterface);
      
      // Revert to original type (assuming it was TEXT)
      await viewManager.safelyAlterColumnType(
        'clients',
        'payment_terms',
        'TEXT',
        transaction
      );
      
      return Promise.resolve();
    });
  }
};
