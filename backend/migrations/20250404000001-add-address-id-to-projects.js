'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Add address_id column to projects table
    await queryInterface.addColumn('projects', 'address_id', {
      type: Sequelize.UUID,
      allowNull: true,
      references: {
        model: 'client_addresses',
        key: 'id'
      },
      after: 'client_id'
    });

    // Add index for address_id
    await queryInterface.addIndex('projects', ['address_id']);
  },

  down: async (queryInterface, Sequelize) => {
    // Remove index first
    await queryInterface.removeIndex('projects', ['address_id']);
    
    // Then remove the column
    await queryInterface.removeColumn('projects', 'address_id');
  }
};