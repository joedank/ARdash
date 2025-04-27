'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    const qi = queryInterface;
    // Use raw SQL to insert the default embedding model setting if it doesn't exist
    await queryInterface.sequelize.query(`
      INSERT INTO settings ("key", value, "group", description, created_at, updated_at)
      SELECT 'deepseek_embedding_model',
             'deepseek-embed-v1',
             'ai',
             'Default embedding model for DeepSeek provider',
             NOW(), NOW()
      WHERE NOT EXISTS (
        SELECT 1 FROM settings WHERE "key" = 'deepseek_embedding_model'
      );
    `);

    console.log('Migration: Added default deepseek_embedding_model setting if needed');
  },

  async down(queryInterface, Sequelize) {
    const qi = queryInterface;
    // Revert the migration if needed
    await queryInterface.sequelize.query(`
      DELETE FROM settings WHERE "key" = 'deepseek_embedding_model' AND value = 'deepseek-embed-v1';
    `);
    
    console.log('Migration: Removed default deepseek_embedding_model setting');
  }
};
