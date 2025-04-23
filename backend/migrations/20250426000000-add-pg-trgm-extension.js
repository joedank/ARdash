'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Add pg_trgm extension for similarity search
      await queryInterface.sequelize.query(`
        CREATE EXTENSION IF NOT EXISTS pg_trgm;
      `);
      
      console.log('Successfully added pg_trgm extension');
    } catch (error) {
      console.error('Failed to add pg_trgm extension:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    try {
      // Drop pg_trgm extension
      await queryInterface.sequelize.query(`
        DROP EXTENSION IF EXISTS pg_trgm;
      `);
      
      console.log('Successfully dropped pg_trgm extension');
    } catch (error) {
      console.error('Error dropping pg_trgm extension:', error);
      throw error;
    }
  }
};
