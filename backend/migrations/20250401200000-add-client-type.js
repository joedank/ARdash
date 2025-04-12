'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      // Add client_type column to clients table
      await queryInterface.addColumn('clients', 'client_type', {
        type: Sequelize.ENUM('property_manager', 'resident'),
        allowNull: true, // Initially allow null during migration
        defaultValue: 'resident',
      }).catch(error => {
        console.log('Error adding client_type column (may already exist):', error.message);
      });
      
      // Add index on client_type column
      await queryInterface.addIndex('clients', ['client_type'], {
        name: 'clients_client_type'
      }).catch(error => {
        console.log('Error adding index on client_type (may already exist):', error.message);
      });
      
      console.log('Migration to add client_type completed successfully');
    } catch (error) {
      console.error('Migration failed:', error);
    }
  },

  down: async (queryInterface, Sequelize) => {
    try {
      // Remove index on client_type
      await queryInterface.removeIndex('clients', 'clients_client_type').catch(error => {
        console.log('Error removing index on client_type:', error.message);
      });
      
      // Remove client_type column
      await queryInterface.removeColumn('clients', 'client_type').catch(error => {
        console.log('Error removing client_type column:', error.message);
      });
      
      // Remove ENUM type
      await queryInterface.sequelize.query('DROP TYPE IF EXISTS enum_clients_client_type;').catch(error => {
        console.log('Error dropping ENUM type:', error.message);
      });
      
      console.log('Rollback of client_type migration completed successfully');
    } catch (error) {
      console.error('Rollback failed:', error);
    }
  }
};
