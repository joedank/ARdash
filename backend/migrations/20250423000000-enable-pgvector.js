'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Add pgvector extension for vector similarity search
      await queryInterface.sequelize.query(`
        CREATE EXTENSION IF NOT EXISTS vector;
      `);
      
      console.log('Successfully enabled pgvector extension');
    } catch (error) {
      console.error('Failed to enable pgvector extension:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    // We don't want to drop the extension in down migrations
    // as it might be used by other tables/features
    console.log('Skipping pgvector extension removal in down migration');
  }
};
