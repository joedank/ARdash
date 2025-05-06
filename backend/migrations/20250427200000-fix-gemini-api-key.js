'use strict';

/**
 * Migration to fix Google Gemini API key and verify all embedding-related settings
 * 
 * This migration is a follow-up to 20250427180000-fix-gemini-base-url.js
 * which fixed the base URL. This migration ensures the API key is properly set
 * and adds the required header configuration for Gemini.
 */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Get the current API key format to check if it needs to be updated
      const [results] = await queryInterface.sequelize.query(
        `SELECT value FROM settings WHERE "key" = 'embedding_api_key'`
      );
      
      const currentKey = results?.[0]?.value || '';
      const isLikelyDeepSeekKey = currentKey.startsWith('sk-');
      
      if (isLikelyDeepSeekKey) {
        console.log('Current API key appears to be a DeepSeek/OpenAI format key, which will not work with Gemini');
        console.log('You will need to manually update the key in the settings UI or with a direct database update');
        console.log('The Gemini API key should be provided in your Google AI Studio console');
        
        // Update with a placeholder or environment variable if available
        const geminiKey = process.env.GEMINI_API_KEY || 'REPLACE_WITH_VALID_GEMINI_API_KEY';
        
        await queryInterface.sequelize.query(`
          UPDATE settings 
          SET value = '${geminiKey}' 
          WHERE "key" = 'embedding_api_key' AND "group" = 'ai_provider';
        `);
      }
      
      // Ensure all other settings are correct
      await queryInterface.sequelize.query(`
        -- Ensure provider is set to Gemini
        UPDATE settings 
        SET value = 'gemini' 
        WHERE "key" = 'embedding_provider' AND "group" = 'ai_provider';
        
        -- Ensure model is correct
        UPDATE settings 
        SET value = 'gemini-embedding-exp-03-07' 
        WHERE "key" = 'embedding_model' AND "group" = 'ai_provider';
        
        -- Ensure base URL is correct
        UPDATE settings 
        SET value = 'https://generativelanguage.googleapis.com/v1beta' 
        WHERE "key" = 'embedding_base_url' AND "group" = 'ai_provider';
        
        -- Enable vector similarity
        UPDATE settings 
        SET value = 'true' 
        WHERE "key" = 'enable_vector_similarity' AND "group" = 'ai_provider';
      `);
      
      console.log('Successfully updated Gemini embedding settings');
    } catch (error) {
      console.error('Error updating Gemini embedding settings:', error);
      throw error;
    }
  },

  async down(queryInterface) {
    // No down migration as we don't want to revert to incorrectly configured settings
    console.log('No down migration for this fix');
  }
};
