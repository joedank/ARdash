'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      // Update the client_id column to allow NULL values
      await queryInterface.changeColumn('invoices', 'client_id', {
        type: Sequelize.STRING,
        allowNull: true,
        comment: 'Legacy client identifier (deprecated)'
      });
      
      console.log('Successfully updated client_id column to allow NULL values');
      return Promise.resolve();
    } catch (error) {
      console.error('Migration failed:', error);
      return Promise.reject(error);
    }
  },

  down: async (queryInterface, Sequelize) => {
    try {
      // Revert: Make client_id NOT NULL again (this assumes all rows have a value)
      // This might fail if there are now NULL values in the column
      await queryInterface.changeColumn('invoices', 'client_id', {
        type: Sequelize.STRING,
        allowNull: false,
        comment: 'Legacy client identifier (deprecated)'
      });
      
      console.log('Successfully reverted client_id column to NOT NULL');
      return Promise.resolve();
    } catch (error) {
      console.error('Rollback migration failed:', error);
      return Promise.reject(error);
    }
  }
};
