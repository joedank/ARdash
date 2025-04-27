'use strict';

const { Worker } = require('bullmq');
const Redis = require('ioredis');
const logger = require('../utils/logger');
const embeddingProvider = require('../services/embeddingProvider');

// Initialize Redis connection with BullMQ required settings
const connection = new Redis(process.env.REDIS_URL || 'redis://localhost:6379', {
  maxRetriesPerRequest: null
});

// Create worker
const worker = new Worker('embedding', async job => {
  const { text } = job.data;

  logger.info(`Processing embedding job ${job.id} for text: ${text.substring(0, 50)}...`);

  try {
    // Make sure the embedding provider is initialized
    await embeddingProvider.reinitialize();
    
    // Generate embedding using the provider
    const vector = await embeddingProvider.embed(text);
    
    if (!vector) {
      throw new Error('Embedding provider returned null vector');
    }

    logger.info(`Successfully created embedding for job ${job.id} with ${vector.length} dimensions`);
    
    // Return the result
    return { vector };
  } catch (error) {
    logger.error(`Error generating embedding for job ${job.id}: ${error.message}`, { error });
    // Mark job as failed with a clear error message so BullMQ doesn't retry indefinitely
    job.moveToFailed(new Error(`Embedding failed: ${error.message}`), true);
    // Return failure object instead of throwing
    return { success: false, error: error.message };
  }
}, { 
  connection,
  concurrency: 2, // Process up to 2 jobs simultaneously
  lockDuration: 120000 // 2 minutes lock
});

// Log worker events
worker.on('error', err => {
  logger.error(`Embedding worker error: ${err.message}`, { error: err });
});

worker.on('completed', job => {
  logger.info(`Embedding job ${job.id} completed successfully`);
});

// Handle termination gracefully
process.on('SIGTERM', async () => {
  logger.info('Embedding worker received SIGTERM, closing...');
  await worker.close();
  process.exit(0);
});

logger.info('Embedding worker started');
