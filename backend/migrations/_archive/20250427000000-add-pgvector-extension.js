'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Add pgvector extension for vector similarity search
      await queryInterface.sequelize.query(`
        CREATE EXTENSION IF NOT EXISTS vector;
      `);
      
      console.log('Successfully added pgvector extension');
    } catch (error) {
      console.error('Failed to add pgvector extension:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    try {
      // Drop pgvector extension
      await queryInterface.sequelize.query(`
        DROP EXTENSION IF EXISTS vector;
      `);
      
      console.log('Successfully dropped pgvector extension');
    } catch (error) {
      console.error('Error dropping pgvector extension:', error);
      throw error;
    }
  }
};
