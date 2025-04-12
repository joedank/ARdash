'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    await queryInterface.addColumn('estimates', 'address_id', {
      type: Sequelize.UUID,
      allowNull: true,
      references: {
        model: 'client_addresses', // Name of the target table
        key: 'id',
      },
      onUpdate: 'CASCADE',
      onDelete: 'SET NULL', // Or 'RESTRICT' or 'CASCADE' depending on desired behavior
      comment: 'Foreign key to client_addresses table for the selected address'
    });

    // Optionally, add an index for performance
    await queryInterface.addIndex('estimates', ['address_id']);
  },

  async down (queryInterface, Sequelize) {
    // Remove the index first
    await queryInterface.removeIndex('estimates', ['address_id']);
    // Then remove the column
    await queryInterface.removeColumn('estimates', 'address_id');
  }
};
