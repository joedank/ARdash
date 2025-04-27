'use strict';

const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const estimateQueue = require('../queues/estimateQueue');
const logger = require('../utils/logger');

/**
 * Get status of an estimate generation job
 * @route GET /api/estimate-jobs/:id/status
 * @param {string} id - The job ID
 * @returns {Object} The job status
 */
router.get('/:id/status', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    
    if (!id) {
      return res.status(400).json({
        success: false,
        message: 'Job ID is required'
      });
    }
    
    // Get job from queue
    const job = await estimateQueue.getJob(id);
    
    if (!job) {
      return res.status(404).json({
        success: false,
        message: `Job ${id} not found`
      });
    }
    
    // Get job state
    const state = await job.getState();
    
    // Get job progress
    const progress = job.progress || 0;
    
    // For completed jobs, include the result
    let result = null;
    if (state === 'completed') {
      result = await job.returnvalue;
    }
    
    // For failed jobs, include the reason
    let failReason = null;
    if (state === 'failed') {
      failReason = job.failedReason;
    }
    
    return res.json({
      success: true,
      data: {
        id: job.id,
        state,
        progress,
        result,
        failReason,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    logger.error(`Error getting job status: ${error.message}`, { error });
    return res.status(500).json({
      success: false,
      message: `Failed to get job status: ${error.message}`
    });
  }
});

/**
 * Cancel an estimate generation job
 * @route DELETE /api/estimate-jobs/:id
 * @param {string} id - The job ID
 * @returns {Object} Success status
 */
router.delete('/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    
    if (!id) {
      return res.status(400).json({
        success: false,
        message: 'Job ID is required'
      });
    }
    
    // Get job from queue
    const job = await estimateQueue.getJob(id);
    
    if (!job) {
      return res.status(404).json({
        success: false,
        message: `Job ${id} not found`
      });
    }
    
    // Remove the job
    await job.remove();
    
    return res.json({
      success: true,
      message: `Job ${id} cancelled successfully`
    });
  } catch (error) {
    logger.error(`Error cancelling job: ${error.message}`, { error });
    return res.status(500).json({
      success: false,
      message: `Failed to cancel job: ${error.message}`
    });
  }
});

module.exports = router;
