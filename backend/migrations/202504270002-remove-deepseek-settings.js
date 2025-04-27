'use strict';

module.exports = {
  async up(queryInterface) {
    await queryInterface.sequelize.query(`
      DELETE FROM settings WHERE "key" ILIKE 'deepseek_%';
      UPDATE settings SET value='gemini' WHERE "key"='embedding_provider';
    `);
  },

  async down() {
    /* intentional no-op */
  }
};
