'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Migration is no longer needed since we'll modify the original migration
    return Promise.resolve();
  },

  down: async (queryInterface, Sequelize) => {
    return Promise.resolve();
  }
};