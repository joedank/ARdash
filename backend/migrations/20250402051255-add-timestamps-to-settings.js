'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    const tableInfo = await queryInterface.describeTable('settings');

    if (!tableInfo.created_at) {
      await queryInterface.addColumn('settings', 'created_at', {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      });
    }
    if (!tableInfo.updated_at) {
      await queryInterface.addColumn('settings', 'updated_at', {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      });
    }
  },

  async down (queryInterface, Sequelize) {
    const tableInfo = await queryInterface.describeTable('settings');

    if (tableInfo.created_at) {
      await queryInterface.removeColumn('settings', 'created_at');
    }
    if (tableInfo.updated_at) {
      await queryInterface.removeColumn('settings', 'updated_at');
    }
  }
};
