'use strict';

const { Queue } = require('bullmq');
const Redis = require('ioredis');
const logger = require('../utils/logger');

// Initialize Redis connection
const connection = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');

// Create embedding queue
const embedQueue = new Queue('embedding', { 
  connection,
  defaultJobOptions: {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 1000
    }
  }
});

/**
 * Helper to wait for job completion
 * @param {string} jobId - The job ID to wait for
 * @param {number} timeout - Timeout in milliseconds
 * @returns {Promise<any>} - The job result
 */
embedQueue.waitUntilFinished = async (jobId, timeout = 30000) => {
  return new Promise((resolve, reject) => {
    // Set timeout
    const timeoutId = setTimeout(() => {
      reject(new Error(`Embedding job ${jobId} timed out after ${timeout}ms`));
    }, timeout);

    // Create job completion listener
    const checkComplete = async () => {
      const job = await embedQueue.getJob(jobId);
      
      if (!job) {
        clearTimeout(timeoutId);
        return reject(new Error(`Job ${jobId} not found`));
      }

      const state = await job.getState();
      
      if (state === 'completed') {
        clearTimeout(timeoutId);
        const result = await job.returnvalue;
        return resolve(result);
      } else if (['failed', 'error'].includes(state)) {
        clearTimeout(timeoutId);
        return reject(new Error(`Job ${jobId} failed with state: ${state}`));
      }

      // Check again after a short delay
      setTimeout(checkComplete, 500);
    };

    // Start checking
    checkComplete();
  });
};

// Log queue events
embedQueue.on('error', (error) => {
  logger.error(`Embedding queue error: ${error.message}`, { error });
});

embedQueue.on('failed', (job, error) => {
  logger.error(`Embedding job ${job.id} failed: ${error.message}`, {
    jobId: job.id,
    error
  });
});

module.exports = embedQueue;