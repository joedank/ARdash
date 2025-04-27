'use strict';

// Simplified migration that just drops the view without requiring external modules
// Original imports were:
// const ViewManager = require('../utils/viewManager');
// const viewDefinitions = require('../config/viewDefinitions');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    return queryInterface.sequelize.transaction(async (transaction) => {
      try {
        // Just drop the view if it exists
        console.log('Dropping client_view if it exists...');
        await queryInterface.sequelize.query(
          'DROP VIEW IF EXISTS client_view;',
          { transaction }
        );

        console.log('Successfully dropped client_view');
        return Promise.resolve();
      } catch (error) {
        console.error('Error in migration:', error);
        throw error;
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    // No-op for down migration since we can't recreate the view without the definition
    console.log('Down migration is a no-op for client_view drop');
    return Promise.resolve();
  }
};