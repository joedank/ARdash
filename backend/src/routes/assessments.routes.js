'use strict';

const express = require('express');
const router = express.Router();
const {
  detectWorkTypes,
  getAssessmentForProject,
  getAssessmentForEstimate
} = require('../controllers/assessments.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { validateUuid } = require('../middleware/uuidValidator');
const rateLimit = require('express-rate-limit');

// Create rate limiter for work type detection (30 requests per minute per IP)
const detectWorkTypesLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 30, // 30 requests per minute
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many requests, please try again later.'
  }
});

/**
 * @route   POST /api/assessments/detect-work-types
 * @desc    Detect work types from condition text
 * @access  Private
 */
router.post('/detect-work-types', authenticate, detectWorkTypesLimiter, detectWorkTypes);

/**
 * @route   GET /api/assessments/for-project/:projectId
 * @desc    Get assessment data for a project
 * @access  Private
 */
router.get('/for-project/:projectId', authenticate, validateUuid('projectId'), getAssessmentForProject);

/**
 * @route   GET /api/assessments/for-estimate/:estimateId
 * @desc    Get assessment data for an estimate
 * @access  Private
 */
router.get('/for-estimate/:estimateId', authenticate, validateUuid('estimateId'), getAssessmentForEstimate);

module.exports = router;
