'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      // Check if the column already exists
      const tableInfo = await queryInterface.describeTable('projects');
      
      if (!tableInfo.work_types) {
        console.log('Adding work_types column to projects table');
        
        // Add the work_types column
        await queryInterface.addColumn('projects', 'work_types', {
          type: Sequelize.JSONB,
          defaultValue: [],
          allowNull: true,
          comment: 'Array of work type UUIDs associated with this assessment'
        });
        
        console.log('Successfully added work_types column to projects table');
      } else {
        console.log('work_types column already exists in projects table');
      }
      
      return Promise.resolve();
    } catch (error) {
      console.error('Migration failed:', error);
      return Promise.reject(error);
    }
  },

  down: async (queryInterface, Sequelize) => {
    try {
      // Check if the column exists before removing it
      const tableInfo = await queryInterface.describeTable('projects');
      
      if (tableInfo.work_types) {
        console.log('Removing work_types column from projects table');
        
        // Remove the work_types column
        await queryInterface.removeColumn('projects', 'work_types');
        
        console.log('Successfully removed work_types column from projects table');
      } else {
        console.log('work_types column does not exist in projects table');
      }
      
      return Promise.resolve();
    } catch (error) {
      console.error('Migration rollback failed:', error);
      return Promise.reject(error);
    }
  }
};
