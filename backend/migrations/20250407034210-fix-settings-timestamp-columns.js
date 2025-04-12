'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    // Set a default timestamp for any null created_at values
    await queryInterface.sequelize.query(`
      UPDATE settings 
      SET created_at = CURRENT_TIMESTAMP 
      WHERE created_at IS NULL;
    `);

    // Make the column not nullable
    await queryInterface.sequelize.query(`
      ALTER TABLE settings 
      ALTER COLUMN created_at SET NOT NULL;
    `);
  },

  async down(queryInterface, Sequelize) {
    // Allow null values again
    await queryInterface.sequelize.query(`
      ALTER TABLE settings 
      ALTER COLUMN created_at DROP NOT NULL;
    `);
  }
};
