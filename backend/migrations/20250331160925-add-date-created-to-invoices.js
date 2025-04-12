'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const tableInfo = await queryInterface.describeTable('invoices');
    
    if (!tableInfo.date_created) {
      await queryInterface.addColumn('invoices', 'date_created', {
        type: Sequelize.DATEONLY,
        allowNull: false
      });
    }
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.removeColumn('invoices', 'date_created');
  }
};
