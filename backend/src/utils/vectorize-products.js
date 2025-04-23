#!/usr/bin/env node

/**
 * Utility script to generate vector embeddings for product names
 * This is used to populate the name_vec column in the products table for vector similarity search
 * 
 * Usage: node vectorize-products.js
 * 
 * Prerequisites:
 * - pgvector extension installed in PostgreSQL
 * - name_vec column added to products table
 * - DeepSeek API key set in environment variables
 */

require('dotenv').config();
const { Product } = require('../models');
const DeepSeek = require('../services/deepseekService');
const logger = require('./logger');

// Maximum batch size for API calls (to avoid rate limits)
const BATCH_SIZE = 20;

// Function to get vector embedding for a single text string
async function getTextEmbedding(text) {
  try {
    const response = await DeepSeek.client.embeddings.create({
      model: 'deepseek-embedding',
      input: text
    });
    
    return response.data[0].embedding;
  } catch (error) {
    logger.error(`Error getting embedding for text: ${text}`, error);
    throw error;
  }
}

// Function to process products in batches
async function processBatch(products) {
  logger.info(`Processing batch of ${products.length} products`);
  
  const texts = products.map(p => p.name);
  let embeddings = [];
  
  try {
    // Get embeddings for all texts in the batch
    const response = await DeepSeek.client.embeddings.create({
      model: 'deepseek-embedding',
      input: texts
    });
    
    embeddings = response.data.map(item => item.embedding);
  } catch (error) {
    logger.error('Error getting batch embeddings, falling back to individual processing', error);
    
    // Fallback to individual processing
    for (const product of products) {
      try {
        const embedding = await getTextEmbedding(product.name);
        await updateProductEmbedding(product, embedding);
      } catch (embeddingError) {
        logger.error(`Skipping product ${product.id} due to embedding error`, embeddingError);
      }
    }
    
    return;
  }
  
  // Update each product with its embedding
  for (let i = 0; i < products.length; i++) {
    await updateProductEmbedding(products[i], embeddings[i]);
  }
  
  logger.info(`Successfully processed batch of ${products.length} products`);
}

// Function to update a single product's embedding
async function updateProductEmbedding(product, embedding) {
  try {
    // Use raw SQL to update because Sequelize doesn't support vector type natively
    await Product.sequelize.query(`
      UPDATE products 
      SET name_vec = $1::vector 
      WHERE id = $2
    `, {
      bind: [embedding, product.id]
    });
    
    logger.debug(`Updated embedding for product ${product.id}: ${product.name}`);
  } catch (error) {
    logger.error(`Error updating embedding for product ${product.id}`, error);
    throw error;
  }
}

// Main function
async function main() {
  logger.info('Starting vector embedding generation for products');
  
  try {
    // Check if vector extension is available
    const [extensionResult] = await Product.sequelize.query(`
      SELECT EXISTS (
        SELECT FROM pg_extension WHERE extname = 'vector'
      );
    `);
    
    if (!extensionResult[0].exists) {
      logger.error('The pgvector extension is not installed in the database. Please install it first.');
      process.exit(1);
    }
    
    // Check if name_vec column exists
    const [columnResult] = await Product.sequelize.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'name_vec'
      );
    `);
    
    if (!columnResult[0].exists) {
      logger.error('The name_vec column does not exist in the products table. Please run the migration first.');
      process.exit(1);
    }
    
    // Get all products that don't have an embedding yet
    const products = await Product.findAll({
      where: {
        deleted_at: null
      },
      attributes: ['id', 'name'],
      order: [['created_at', 'DESC']]
    });
    
    logger.info(`Found ${products.length} products to process`);
    
    // Process in batches
    for (let i = 0; i < products.length; i += BATCH_SIZE) {
      const batch = products.slice(i, i + BATCH_SIZE);
      await processBatch(batch);
      
      // Small delay to avoid rate limits
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
    
    logger.info('Successfully generated vector embeddings for all products');
  } catch (error) {
    logger.error('Error in vector embedding generation process', error);
    process.exit(1);
  }
}

// Run the main function
if (require.main === module) {
  main().catch(error => {
    logger.error('Unhandled error in main process', error);
    process.exit(1);
  });
}

module.exports = {
  getTextEmbedding,
  updateProductEmbedding
};