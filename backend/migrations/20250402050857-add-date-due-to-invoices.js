'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    const tableInfo = await queryInterface.describeTable('invoices');
    if (!tableInfo.date_due) {
      await queryInterface.addColumn('invoices', 'date_due', {
        type: Sequelize.DATEONLY,
        allowNull: false,
        // Add a default value, e.g., 30 days from now, for existing rows
        defaultValue: Sequelize.literal("CURRENT_DATE + INTERVAL '30 day'") 
      });
    }
  },

  async down (queryInterface, Sequelize) {
    const tableInfo = await queryInterface.describeTable('invoices');
    if (tableInfo.date_due) {
      await queryInterface.removeColumn('invoices', 'date_due');
    }
  }
};
