'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('projects', 'additional_work', {
      type: Sequelize.TEXT,
      allowNull: true,
      after: 'scope'
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('projects', 'additional_work');
  }
};