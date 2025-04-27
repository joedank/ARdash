'use strict';

/**
 * Idempotent migration to rename scope column to condition in projects table
 */
module.exports = {
  async up(queryInterface, Sequelize) {
    const qi = queryInterface;
    try {
      console.log('Starting idempotent scope to condition migration');

      // Check if the table and columns exist
      const tableInfo = await queryInterface.sequelize.query(
        `SELECT column_name
         FROM information_schema.columns
         WHERE table_name = 'projects'`,
        { type: queryInterface.sequelize.QueryTypes.SELECT }
      );

      const columnNames = tableInfo.map(col => col.column_name);

      // If scope doesn't exist or condition already exists, nothing to do
      if (!columnNames.includes('scope') || columnNames.includes('condition')) {
        console.log('Either scope column does not exist or condition column already exists. Skipping this migration.');
        return Promise.resolve();
      }

      // Rename scope to condition
      console.log('Renaming scope column to condition in projects table');
      await queryInterface.renameColumn('projects', 'scope', 'condition');

      console.log('Successfully renamed scope to condition');
      return Promise.resolve();
    } catch (error) {
      console.error('Error during scope to condition migration:', error);
      return Promise.reject(error);
    }
  },

  async down(queryInterface, Sequelize) {
    // This is an idempotent migration, no need for down migration
    return Promise.resolve();
  }
};
