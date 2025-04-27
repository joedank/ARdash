'use strict';

const { Worker } = require('bullmq');
const Redis = require('ioredis');
const logger = require('../utils/logger');
const llmEstimateService = require('../services/llmEstimateService');

// Initialize Redis connection with BullMQ required settings
const connection = new Redis(process.env.REDIS_URL || 'redis://localhost:6379', {
  maxRetriesPerRequest: null
});

// Create worker
const worker = new Worker('estimate-generation', async job => {
  const { input } = job.data;
  
  logger.info(`Processing estimate generation job ${job.id}`);
  
  try {
    // Update job progress to 10%
    await job.updateProgress(10);
    
    // Extract parameters from input
    const { projectId, assessment, mode, aggressiveness } = input;
    
    if (!projectId) {
      throw new Error('Project ID is required for estimate generation');
    }
    
    // Update job progress to 20%
    await job.updateProgress(20);
    
    // Generate the estimate
    const result = await llmEstimateService.generateEstimateFromAssessment({
      projectId,
      assessment,
      mode,
      aggressiveness
    });
    
    // Update job progress to 90%
    await job.updateProgress(90);
    
    // Check if generation was successful
    if (!result.success) {
      throw new Error(result.error || 'Estimate generation failed');
    }
    
    // Update job progress to 100%
    await job.updateProgress(100);
    
    logger.info(`Successfully generated estimate for job ${job.id} with ${result.data.length} items`);
    
    // Return the result
    return {
      success: true,
      data: result.data,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    logger.error(`Error generating estimate for job ${job.id}: ${error.message}`, { error });
    
    // Return error result
    return {
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    };
  }
}, { 
  connection,
  concurrency: 2, // Process up to 2 jobs simultaneously
  lockDuration: 300000 // 5 minutes lock
});

// Log worker events
worker.on('error', err => {
  logger.error(`Estimate worker error: ${err.message}`, { error: err });
});

worker.on('completed', job => {
  logger.info(`Estimate job ${job.id} completed successfully`);
});

worker.on('progress', (job, progress) => {
  logger.debug(`Estimate job ${job.id} progress: ${progress}%`);
});

// Handle termination gracefully
process.on('SIGTERM', async () => {
  logger.info('Estimate worker received SIGTERM, closing...');
  await worker.close();
  process.exit(0);
});

logger.info('Estimate worker started');
