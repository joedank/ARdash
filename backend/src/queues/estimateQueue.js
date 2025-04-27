'use strict';

const { Queue } = require('bullmq');
const Redis = require('ioredis');
const logger = require('../utils/logger');

// Initialize Redis connection
const connection = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');

// Create estimate generation queue
const estimateQueue = new Queue('estimate-generation', { 
  connection,
  defaultJobOptions: {
    attempts: 2,
    backoff: {
      type: 'exponential',
      delay: 1000
    },
    removeOnComplete: 100, // Keep last 100 completed jobs
    removeOnFail: 200 // Keep last 200 failed jobs for troubleshooting
  }
});

// Log queue events
estimateQueue.on('error', (error) => {
  logger.error(`Estimate queue error: ${error.message}`, { error });
});

estimateQueue.on('failed', (job, error) => {
  logger.error(`Estimate job ${job.id} failed: ${error.message}`, {
    jobId: job.id,
    error
  });
});

estimateQueue.on('completed', (job) => {
  logger.info(`Estimate job ${job.id} completed successfully`);
});

module.exports = estimateQueue;
