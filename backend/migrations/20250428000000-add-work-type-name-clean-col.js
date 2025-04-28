'use strict';

/**
 * Migration to add a generated name_clean column to work_types table
 * This column will store the work type name with generic tokens removed
 * We also create a GIN index on this column for faster trigram similarity searches
 */

// Generic tokens to filter out
const GENERIC_TOKENS = [
  'install', 'installation', 'replace', 'replacement',
  'repair', 'repairs', 'service', 'services'
].join('|');

module.exports = {
  async up(queryInterface, Sequelize) {
    // Use transaction to ensure both operations succeed or fail together
    const transaction = await queryInterface.sequelize.transaction();
    
    try {
      // Add the generated column that removes generic tokens
      await queryInterface.sequelize.query(`
        ALTER TABLE work_types 
        ADD COLUMN name_clean text GENERATED ALWAYS AS (
          regexp_replace(
            lower(name), 
            '\\m(${GENERIC_TOKENS})\\M', 
            '', 
            'gi'
          )
        ) STORED;
      `, { transaction });
      
      // Create a GIN index for fast trigram searches
      await queryInterface.sequelize.query(`
        CREATE INDEX work_types_name_clean_gin 
        ON work_types 
        USING gin (name_clean gin_trgm_ops);
      `, { transaction });
      
      await transaction.commit();
      
      console.log('Successfully added name_clean column and index to work_types table');
    } catch (error) {
      await transaction.rollback();
      console.error('Error adding name_clean column and index:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    // Use transaction to ensure both operations succeed or fail together
    const transaction = await queryInterface.sequelize.transaction();
    
    try {
      // Drop the index first
      await queryInterface.sequelize.query(`
        DROP INDEX IF EXISTS work_types_name_clean_gin;
      `, { transaction });
      
      // Drop the column
      await queryInterface.sequelize.query(`
        ALTER TABLE work_types DROP COLUMN IF EXISTS name_clean;
      `, { transaction });
      
      await transaction.commit();
      
      console.log('Successfully dropped name_clean column and index from work_types table');
    } catch (error) {
      await transaction.rollback();
      console.error('Error dropping name_clean column and index:', error);
      throw error;
    }
  }
};
