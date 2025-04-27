'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    // Step 1: Create the vector extension if it doesn't exist
    await queryInterface.sequelize.query('CREATE EXTENSION IF NOT EXISTS vector;');
    
    // Step 2: Add the embedding column to the products table
    // This defines a 384-dimensional vector (using OpenAI's text-embedding-3-small model dimensions)
    await queryInterface.sequelize.query('ALTER TABLE products ADD COLUMN IF NOT EXISTS embedding vector(384);');
    
    // Step 3: Create an index for faster similarity searches
    await queryInterface.sequelize.query('CREATE INDEX IF NOT EXISTS products_embedding_idx ON products USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);');
    
    console.log('Migration completed successfully: added vector embedding column and index to products table');
  },

  async down(queryInterface, Sequelize) {
    // Step 1: Drop the index if it exists
    await queryInterface.sequelize.query('DROP INDEX IF EXISTS products_embedding_idx;');
    
    // Step 2: Drop the embedding column
    await queryInterface.sequelize.query('ALTER TABLE products DROP COLUMN IF EXISTS embedding;');
    
    console.log('Rollback completed successfully: removed vector embedding column and index from products table');
  }
};
