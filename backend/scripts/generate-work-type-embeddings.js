'use strict';

/**
 * Script to generate embeddings for existing work types
 * Run with: node scripts/generate-work-type-embeddings.js
 */

require('dotenv').config();
const { sequelize, WorkType } = require('../src/models');
const deepseekService = require('../src/services/deepseekService');
const logger = require('../src/utils/logger');

// Set this to true to actually update the database
const UPDATE_DATABASE = true;

async function generateEmbeddings() {
  try {
    logger.info('Starting work type embedding generation');
    
    // Check if vector similarity is enabled
    if (process.env.ENABLE_VECTOR_SIMILARITY !== 'true') {
      logger.error('Vector similarity is not enabled. Set ENABLE_VECTOR_SIMILARITY=true in .env');
      process.exit(1);
    }
    
    // Get all work types without embeddings
    const workTypes = await WorkType.findAll({
      where: {
        name_vec: null
      }
    });
    
    logger.info(`Found ${workTypes.length} work types without embeddings`);
    
    // Process each work type
    for (const workType of workTypes) {
      try {
        logger.info(`Generating embedding for "${workType.name}"`);
        
        // Generate embedding
        const embedding = await deepseekService.generateEmbedding(workType.name);
        
        if (!embedding || !Array.isArray(embedding)) {
          logger.warn(`Failed to generate embedding for "${workType.name}"`);
          continue;
        }
        
        logger.info(`Generated embedding with ${embedding.length} dimensions`);
        
        // Update the work type with the embedding
        if (UPDATE_DATABASE) {
          // Use raw SQL to update the vector column
          await sequelize.query(
            `UPDATE work_types SET name_vec = $1::vector WHERE id = $2`,
            {
              bind: [JSON.stringify(embedding), workType.id],
              type: sequelize.QueryTypes.UPDATE
            }
          );
          
          logger.info(`Updated work type "${workType.name}" with embedding`);
        } else {
          logger.info(`[DRY RUN] Would update work type "${workType.name}" with embedding`);
        }
      } catch (error) {
        logger.error(`Error processing work type "${workType.name}":`, error);
      }
    }
    
    logger.info('Embedding generation complete');
  } catch (error) {
    logger.error('Error generating embeddings:', error);
  } finally {
    // Close the database connection
    await sequelize.close();
  }
}

// Run the script
generateEmbeddings();
