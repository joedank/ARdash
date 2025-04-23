'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Step 1: Check if pg_trgm extension exists, if not try to create it
    try {
      await queryInterface.sequelize.query('CREATE EXTENSION IF NOT EXISTS pg_trgm;');
      console.log('pg_trgm extension is now available');
    } catch (error) {
      console.warn('Warning: Failed to create pg_trgm extension. Similarity matching will use fallback method.');
      console.warn('Error details:', error.message);
    }

    // Step 2: Check if pgvector extension exists, if not try to create it
    let vectorExtensionAvailable = false;
    try {
      await queryInterface.sequelize.query('CREATE EXTENSION IF NOT EXISTS vector;');
      console.log('pgvector extension is now available');
      vectorExtensionAvailable = true;
    } catch (error) {
      console.warn('Warning: Failed to create pgvector extension. Vector similarity will be skipped.');
      console.warn('Error details:', error.message);
    }

    // Step 3: Add name_vec column if pgvector is available
    if (vectorExtensionAvailable) {
      try {
        // Check if name_vec column already exists
        const tableInfo = await queryInterface.sequelize.query(
          `SELECT column_name 
           FROM information_schema.columns 
           WHERE table_name = 'products' AND column_name = 'name_vec'`,
          { type: Sequelize.QueryTypes.SELECT }
        );

        if (tableInfo.length === 0) {
          // Column does not exist, so create it
          await queryInterface.sequelize.query('ALTER TABLE products ADD COLUMN name_vec vector(384);');
          console.log('Added name_vec vector column to products table');
        } else {
          console.log('name_vec column already exists in products table');
        }
      } catch (error) {
        console.error('Error adding vector column to products table:', error.message);
      }
    }

    // Step 4: Create a GIN index on name column using pg_trgm to speed up similarity searches
    try {
      await queryInterface.sequelize.query(`
        CREATE INDEX IF NOT EXISTS idx_products_name_gin ON products USING GIN (name gin_trgm_ops);
      `);
      console.log('Created GIN index for trigram similarity on products.name');
    } catch (error) {
      console.warn('Warning: Failed to create GIN index. Similarity searches may be slower.');
      console.warn('Error details:', error.message);
    }
  },

  down: async (queryInterface, Sequelize) => {
    // Remove the vector column if it exists
    try {
      await queryInterface.sequelize.query(`
        ALTER TABLE products DROP COLUMN IF EXISTS name_vec;
      `);
      console.log('Removed name_vec column from products table');
    } catch (error) {
      console.error('Error removing name_vec column:', error.message);
    }

    // Remove the GIN index
    try {
      await queryInterface.sequelize.query(`
        DROP INDEX IF EXISTS idx_products_name_gin;
      `);
      console.log('Removed GIN index for trigram similarity on products.name');
    } catch (error) {
      console.error('Error removing GIN index:', error.message);
    }

    // Note: We don't remove the extensions as they might be used by other parts of the application
    // and removing extensions requires superuser privileges in PostgreSQL.
  }
};