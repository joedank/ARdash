'use strict';
module.exports = {
  async up(qi, Sequelize) {
    // add defaults first
    await qi.sequelize.query(`
      ALTER TABLE settings
      ALTER COLUMN created_at SET DEFAULT NOW(),
      ALTER COLUMN updated_at SET DEFAULT NOW();
    `);
    // back-fill legacy rows
    await qi.sequelize.query(`
      UPDATE settings
      SET created_at = NOW(), updated_at = NOW()
      WHERE created_at IS NULL OR updated_at IS NULL;
    `);
  },
  async down() { /* no-op */ }
};
