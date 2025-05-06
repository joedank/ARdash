'use strict';

/**
 * Migration to fix the Gemini API key and configuration
 * 
 * This migration addresses issues with the Gemini embedding integration:
 * 1. The API key format and handling was incorrect (using OpenAI/DeepSeek format instead of Google format)
 * 2. The API key was not being passed in the correct header format
 * 
 * The code fixes for this issue were already made in embeddingProvider.js
 * This migration just updates the API key if needed.
 */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Check the current api key format
      const [results] = await queryInterface.sequelize.query(
        `SELECT value FROM settings WHERE "key" = 'embedding_api_key'`
      );
      
      const currentKey = results?.[0]?.value || '';
      
      // Check if the key looks like a DeepSeek/OpenAI key (starts with 'sk-')
      if (currentKey.startsWith('sk-')) {
        console.log('Current API key has the format of an OpenAI/DeepSeek key (sk-), which is incompatible with Gemini');
        console.log('You will need to manually update the key to a valid Google API key (typically AIza...) in the settings UI');
        
        // Update with a placeholder or environment variable if available
        const geminiKey = process.env.GEMINI_API_KEY || 'REPLACE_WITH_VALID_GEMINI_API_KEY';
        
        if (geminiKey !== 'REPLACE_WITH_VALID_GEMINI_API_KEY') {
          await queryInterface.sequelize.query(`
            UPDATE settings 
            SET value = '${geminiKey}' 
            WHERE "key" = 'embedding_api_key' AND "group" = 'ai_provider';
          `);
          console.log('Updated API key with environment variable value');
        } else {
          console.log('No GEMINI_API_KEY environment variable found, please update the key manually');
        }
      } else {
        console.log('API key format does not appear to be a DeepSeek/OpenAI key, no update needed');
      }
      
      // Ensure all other embedding settings are correct
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
        
        -- Enable vector similarity if it was disabled
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
