'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    // Check if columns already exist before adding
    const tableInfo = await queryInterface.describeTable('invoices');

    if (!tableInfo.created_at) {
      await queryInterface.addColumn('invoices', 'created_at', {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      });
    }
    if (!tableInfo.updated_at) {
      await queryInterface.addColumn('invoices', 'updated_at', {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      });
    }
    if (!tableInfo.deleted_at) {
      await queryInterface.addColumn('invoices', 'deleted_at', {
        type: Sequelize.DATE,
        allowNull: true // deleted_at is nullable for soft deletes
      });
    }
  },

  async down (queryInterface, Sequelize) {
    // Check if columns exist before removing
    const tableInfo = await queryInterface.describeTable('invoices');

    if (tableInfo.created_at) {
      await queryInterface.removeColumn('invoices', 'created_at');
    }
    if (tableInfo.updated_at) {
      await queryInterface.removeColumn('invoices', 'updated_at');
    }
    if (tableInfo.deleted_at) {
      await queryInterface.removeColumn('invoices', 'deleted_at');
    }
  }
};
