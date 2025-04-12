'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    const tableInfo = await queryInterface.describeTable('invoices');
    if (!tableInfo.discount_amount) {
      await queryInterface.addColumn('invoices', 'discount_amount', {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: false,
        defaultValue: 0.00
      });
    }
  },

  async down (queryInterface, Sequelize) {
    const tableInfo = await queryInterface.describeTable('invoices');
    if (tableInfo.discount_amount) {
      await queryInterface.removeColumn('invoices', 'discount_amount');
    }
  }
};
