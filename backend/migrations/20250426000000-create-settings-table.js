'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    const qi = queryInterface;

    try {
      // Check if settings table exists
      const tableExists = await queryInterface.sequelize.query(`
        SELECT EXISTS (
          SELECT FROM information_schema.tables 
          WHERE table_name = 'settings'
        );
      `, { type: Sequelize.QueryTypes.SELECT });
      
      if (!tableExists[0].exists) {
        // Create settings table if it doesn't exist
        await queryInterface.createTable('settings', {
          id: {
            type: Sequelize.INTEGER,
            primaryKey: true,
            autoIncrement: true
          },
          key: {
            type: Sequelize.STRING(255),
            allowNull: false,
            unique: true
          },
          value: {
            type: Sequelize.TEXT,
            allowNull: true
          },
          group: {
            type: Sequelize.STRING(255),
            allowNull: false,
            defaultValue: 'general'
          },
          description: {
            type: Sequelize.TEXT,
            allowNull: true
          },
          created_at: {
            type: Sequelize.DATE,
            defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
          },
          updated_at: {
            type: Sequelize.DATE,
            defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
          }
        });
      } else {
        // Fix NULL timestamps if they exist
        await queryInterface.sequelize.query(`
          UPDATE settings
          SET created_at = NOW(), updated_at = NOW()
          WHERE created_at IS NULL OR updated_at IS NULL;
        `);
      }

      // Drop the index if it exists first
      await queryInterface.sequelize.query(
        'DROP INDEX IF EXISTS idx_settings_group;'
      );
      
      // Create indexes
      await queryInterface.addIndex('settings', ['group'], {
        name: 'idx_settings_group',
        ifNotExists: true
      });

      // Only insert if the specific keys don't exist yet
      const keys = ['deepseek_embedding_model', 'embedding_provider', 'enable_vector_similarity'];
      for (const key of keys) {
        const exists = await queryInterface.sequelize.query(`
          SELECT EXISTS (SELECT 1 FROM settings WHERE key = '${key}')
        `, { type: Sequelize.QueryTypes.SELECT });
        
        if (!exists[0].exists) {
          // Different insert statements for each key
          if (key === 'deepseek_embedding_model') {
            await queryInterface.sequelize.query(`
              INSERT INTO settings (key, value, "group", description, created_at, updated_at)
              VALUES ('deepseek_embedding_model', 'deepseek-embedding', 'ai', 'Default embedding model for DeepSeek', NOW(), NOW());
            `);
          } else if (key === 'embedding_provider') {
            await queryInterface.sequelize.query(`
              INSERT INTO settings (key, value, "group", description, created_at, updated_at)
              VALUES ('embedding_provider', 'deepseek', 'ai', 'Default embedding provider', NOW(), NOW());
            `);
          } else if (key === 'enable_vector_similarity') {
            await queryInterface.sequelize.query(`
              INSERT INTO settings (key, value, "group", description, created_at, updated_at)
              VALUES ('enable_vector_similarity', 'true', 'ai', 'Enable vector similarity search', NOW(), NOW());
            `);
          }
        }
      }
    } catch (error) {
      console.error('Error in settings table migration:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    const qi = queryInterface;
    // We don't want to drop the settings table in down migration
    // as it could contain important user settings
    // Instead, we'll just remove the specific settings we added
    await queryInterface.sequelize.query(`
      DELETE FROM settings
      WHERE key IN ('deepseek_embedding_model', 'embedding_provider', 'enable_vector_similarity')
    `);
  }
};
