'use strict';

/**
 * Migration to fix the base URL for Gemini embedding API
 * 
 * This migration addresses a critical issue where the embedding_base_url
 * setting still points to DeepSeek's API URL despite the provider being
 * migrated to Google Gemini. This mismatch caused embedding generation to fail.
 */
module.exports = {
  async up(queryInterface) {
    try {
      // Update the base URL for Gemini embeddings
      await queryInterface.sequelize.query(`
        UPDATE settings 
        SET value = 'https://generativelanguage.googleapis.com/v1beta' 
        WHERE "key" = 'embedding_base_url' AND "group" = 'ai_provider';
      `);
      
      console.log('Successfully updated Gemini embedding base URL');
    } catch (error) {
      console.error('Error updating Gemini embedding base URL:', error);
      throw error;
    }
  },

  async down(queryInterface) {
    try {
      // Revert to the old URL if needed (though not recommended)
      await queryInterface.sequelize.query(`
        UPDATE settings 
        SET value = 'https://api.deepseek.com/v1' 
        WHERE "key" = 'embedding_base_url' AND "group" = 'ai_provider';
      `);
    } catch (error) {
      console.error('Error reverting Gemini embedding base URL:', error);
      throw error;
    }
  }
};
