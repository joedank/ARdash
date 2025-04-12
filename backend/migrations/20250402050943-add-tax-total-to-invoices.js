'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    const tableInfo = await queryInterface.describeTable('invoices');
    if (!tableInfo.tax_total) {
      await queryInterface.addColumn('invoices', 'tax_total', {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: false,
        defaultValue: 0.00
      });
    }
  },

  async down (queryInterface, Sequelize) {
    const tableInfo = await queryInterface.describeTable('invoices');
    if (tableInfo.tax_total) {
      await queryInterface.removeColumn('invoices', 'tax_total');
    }
  }
};
