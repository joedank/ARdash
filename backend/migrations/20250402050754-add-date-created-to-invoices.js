'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    const tableInfo = await queryInterface.describeTable('invoices');
    if (!tableInfo.date_created) {
      await queryInterface.addColumn('invoices', 'date_created', {
        type: Sequelize.DATEONLY,
        allowNull: false,
        // Add a default value, e.g., the current date, for existing rows
        // Adjust default as needed, maybe use 'created_at' if it exists and is reliable
        defaultValue: Sequelize.literal('CURRENT_DATE') 
      });
    }
  },

  async down (queryInterface, Sequelize) {
    const tableInfo = await queryInterface.describeTable('invoices');
    if (tableInfo.date_created) {
      await queryInterface.removeColumn('invoices', 'date_created');
    }
  }
};
