#!/usr/bin/env node

/**
 * Script to backfill vector embeddings for existing products
 * This enables semantic similarity search using pgvector
 * 
 * Usage: npm run embed:backfill
 */

require('dotenv').config();
const { Product } = require('../src/models');
const DeepSeek = require('../src/services/deepseekService');
const logger = require('../src/utils/logger');

// Configuration
const BATCH_SIZE = 25; // Process products in batches to avoid rate limits
const DELAY_BETWEEN_BATCHES = 1000; // 1 second delay between batches
const MAX_VECTOR_DIMENSION = 384; // Deepseek embedding dimension for text

/**
 * Main function to backfill embeddings
 */
async function backfillEmbeddings() {
  try {
    // Check if pgvector extension is installed
    const [result] = await Product.sequelize.query(`
      SELECT EXISTS (
        SELECT FROM pg_extension WHERE extname = 'vector'
      );
    `);
    
    if (!result[0].exists) {
      logger.error('pgvector extension is not installed in the database');
      logger.error('Please run: CREATE EXTENSION vector;');
      process.exit(1);
    }
    
    // Check if name_vec column exists in products table
    const [columnResult] = await Product.sequelize.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'name_vec'
      );
    `);
    
    if (!columnResult[0].exists) {
      logger.info('Adding name_vec column to products table...');
      await Product.sequelize.query(`
        ALTER TABLE products ADD COLUMN name_vec vector(${MAX_VECTOR_DIMENSION});
      `);
      logger.info('Column added successfully');
    }
    
    // Find all products that don't have vector embeddings yet
    const products = await Product.findAll({
      where: {
        deleted_at: null
      },
      attributes: ['id', 'name']
    });
    
    if (products.length === 0) {
      logger.info('No products found to process');
      process.exit(0);
    }
    
    logger.info(`Found ${products.length} products to process`);
    
    // Process products in batches
    for (let i = 0; i < products.length; i += BATCH_SIZE) {
      const batch = products.slice(i, Math.min(i + BATCH_SIZE, products.length));
      
      logger.info(`Processing batch ${Math.floor(i / BATCH_SIZE) + 1}/${Math.ceil(products.length / BATCH_SIZE)}`);
      
      // Extract names for batch processing
      const names = batch.map(product => product.name);
      
      try {
        // Get embeddings for all names in the batch
        const response = await DeepSeek.client.embeddings.create({
          model: 'deepseek-embedding',
          input: names
        });
        
        // Process response and update database
        for (let j = 0; j < batch.length; j++) {
          const product = batch[j];
          const embedding = response.data[j].embedding;
          
          // Update product with embedding
          await Product.sequelize.query(`
            UPDATE products
            SET name_vec = $1::vector
            WHERE id = $2
          `, {
            bind: [embedding, product.id]
          });
          
          logger.debug(`Updated embedding for product ${product.id}: ${product.name}`);
        }
        
        logger.info(`Processed ${Math.min((i + BATCH_SIZE), products.length)}/${products.length} products`);
        
        // Add delay between batches to avoid rate limits
        if (i + BATCH_SIZE < products.length) {
          await new Promise(resolve => setTimeout(resolve, DELAY_BETWEEN_BATCHES));
        }
      } catch (error) {
        logger.error(`Error processing batch starting at index ${i}:`, error);
        logger.info('Will continue with next batch...');
      }
    }
    
    logger.info('Embedding backfill completed successfully');
    process.exit(0);
  } catch (error) {
    logger.error('Unhandled error in backfill process:', error);
    process.exit(1);
  }
}

// Run the backfill process
if (require.main === module) {
  logger.info('Starting embedding backfill process');
  backfillEmbeddings();
}
