'use strict';

/**
 * Migration to clean up empty settings rows
 * This removes any rows with empty string or NULL values from the settings table
 */
module.exports = {
  /**
   * Run the migration
   * @param {Object} queryInterface - Sequelize QueryInterface
   * @param {Object} Sequelize - Sequelize constructor
   * @returns {Promise} - Promise resolved when migration is complete
   */
  async up(queryInterface, Sequelize) {
    try {
      // Delete empty settings
      await queryInterface.sequelize.query(
        'DELETE FROM settings WHERE value = \'\' OR value IS NULL;'
      );
      
      console.log('Successfully cleaned up empty settings rows');
      return Promise.resolve();
    } catch (error) {
      console.error('Error cleaning up empty settings rows:', error);
      return Promise.reject(error);
    }
  },

  /**
   * Reverse the migration - no action needed as we can't restore deleted rows
   * @returns {Promise} - Promise resolved immediately
   */
  async down(queryInterface, Sequelize) {
    console.log('This migration cannot be reversed (deleted empty settings)');
    return Promise.resolve();
  }
};
