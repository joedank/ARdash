'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    const tableInfo = await queryInterface.describeTable('invoices');
    if (!tableInfo.pdf_path) {
      await queryInterface.addColumn('invoices', 'pdf_path', {
        type: Sequelize.STRING,
        allowNull: true,
        comment: 'Path to the generated PDF file'
      });
    }
  },

  async down (queryInterface, Sequelize) {
    const tableInfo = await queryInterface.describeTable('invoices');
    if (tableInfo.pdf_path) {
      await queryInterface.removeColumn('invoices', 'pdf_path');
    }
  }
};
