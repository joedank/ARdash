'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Using a transaction to ensure all operations succeed or fail together
    return queryInterface.sequelize.transaction(async (transaction) => {
      // Define the AI provider settings
      const aiProviderSettings = [
        {
          key: 'language_model_provider',
          value: 'deepseek',
          group: 'ai_provider',
          description: 'Provider for language model tasks',
          created_at: new Date(),
          updated_at: new Date()
        },
        {
          key: 'language_model',
          value: 'deepseek-chat',
          group: 'ai_provider',
          description: 'Model name for language tasks',
          created_at: new Date(),
          updated_at: new Date()
        },
        {
          key: 'language_model_api_key',
          value: process.env.DEEPSEEK_API_KEY || '',
          group: 'ai_provider',
          description: 'API key for language model provider',
          created_at: new Date(),
          updated_at: new Date()
        },
        {
          key: 'language_model_base_url',
          value: process.env.DEEPSEEK_BASE_URL || 'https://api.deepseek.com/v1',
          group: 'ai_provider',
          description: 'Base URL for language model provider',
          created_at: new Date(),
          updated_at: new Date()
        },
        {
          key: 'embedding_provider',
          value: process.env.EMBEDDING_PROVIDER || 'deepseek',
          group: 'ai_provider',
          description: 'Provider for vector embeddings',
          created_at: new Date(),
          updated_at: new Date()
        },
        {
          key: 'embedding_model',
          value: process.env.EMBEDDING_MODEL || 'deepseek-embedding-002',
          group: 'ai_provider',
          description: 'Model name for vector embeddings',
          created_at: new Date(),
          updated_at: new Date()
        },
        {
          key: 'embedding_api_key',
          value: process.env.EMBEDDING_PROVIDER === 'gemini' 
            ? (process.env.GEMINI_API_KEY || '') 
            : (process.env.DEEPSEEK_API_KEY || ''),
          group: 'ai_provider',
          description: 'API key for embedding provider',
          created_at: new Date(),
          updated_at: new Date()
        },
        {
          key: 'embedding_base_url',
          value: process.env.EMBEDDING_PROVIDER === 'gemini' 
            ? (process.env.GEMINI_BASE_URL || 'https://generativelanguage.googleapis.com/v1beta/openai')
            : (process.env.DEEPSEEK_BASE_URL || 'https://api.deepseek.com/v1'),
          group: 'ai_provider',
          description: 'Base URL for embedding provider',
          created_at: new Date(),
          updated_at: new Date()
        },
        {
          key: 'enable_vector_similarity',
          value: process.env.ENABLE_VECTOR_SIMILARITY || 'true',
          group: 'ai_provider',
          description: 'Enable vector-based similarity search',
          created_at: new Date(),
          updated_at: new Date()
        }
      ];

      // Insert settings or update them if they already exist
      for (const setting of aiProviderSettings) {
        const existingSetting = await queryInterface.sequelize.query(
          'SELECT * FROM settings WHERE key = ?',
          {
            replacements: [setting.key],
            type: queryInterface.sequelize.QueryTypes.SELECT,
            transaction
          }
        );

        if (existingSetting && existingSetting.length > 0) {
          // Setting exists, update it
          await queryInterface.sequelize.query(
            'UPDATE settings SET value = ?, "group" = ?, description = ?, updated_at = ? WHERE key = ?',
            {
              replacements: [setting.value, setting.group, setting.description, setting.updated_at, setting.key],
              type: queryInterface.sequelize.QueryTypes.UPDATE,
              transaction
            }
          );
        } else {
          // Setting doesn't exist, insert it
          await queryInterface.sequelize.query(
            'INSERT INTO settings (key, value, "group", description, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
            {
              replacements: [
                setting.key,
                setting.value,
                setting.group,
                setting.description,
                setting.created_at,
                setting.updated_at
              ],
              type: queryInterface.sequelize.QueryTypes.INSERT,
              transaction
            }
          );
        }
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    // Using a transaction to ensure all operations succeed or fail together
    return queryInterface.sequelize.transaction(async (transaction) => {
      // Delete all settings in the ai_provider group
      await queryInterface.sequelize.query(
        'DELETE FROM settings WHERE "group" = ?',
        {
          replacements: ['ai_provider'],
          type: queryInterface.sequelize.QueryTypes.DELETE,
          transaction
        }
      );
    });
  }
};
