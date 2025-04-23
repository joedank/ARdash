'use strict';

const ViewManager = require('../utils/viewManager');
const viewDefinitions = require('../config/viewDefinitions');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    return queryInterface.sequelize.transaction(async (transaction) => {
      try {
        // First, drop the view if it exists
        await queryInterface.sequelize.query(
          'DROP VIEW IF EXISTS client_view;',
          { transaction }
        );
        
        // Then recreate the view using the definition from viewDefinitions
        console.log('Recreating client_view...');
        await queryInterface.sequelize.query(
          viewDefinitions.client_view,
          { transaction }
        );
        
        console.log('Successfully recreated client_view');
        return Promise.resolve();
      } catch (error) {
        console.error('Error in migration:', error);
        throw error;
      }
    });
  },
  
  down: async (queryInterface, Sequelize) => {
    // If needed, we can revert by dropping and recreating again
    return queryInterface.sequelize.transaction(async (transaction) => {
      try {
        await queryInterface.sequelize.query(
          'DROP VIEW IF EXISTS client_view;',
          { transaction }
        );
        
        await queryInterface.sequelize.query(
          viewDefinitions.client_view,
          { transaction }
        );
        
        return Promise.resolve();
      } catch (error) {
        console.error('Error in migration rollback:', error);
        throw error;
      }
    });
  }
};