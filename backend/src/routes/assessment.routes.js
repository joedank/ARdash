'use strict';

const express = require('express');
const router = express.Router();
const assessmentController = require('../controllers/assessmentController');
const authMiddleware = require('../middleware/auth.middleware');
const uuidValidator = require('../middleware/uuidValidator');

// Apply authentication middleware to all routes
router.use(authMiddleware.authenticate);

/**
 * @route GET /api/assessment/for-estimate/:estimateId
 * @description Get assessment data for an estimate
 * @access Private
 */
router.get(
  '/for-estimate/:estimateId',
  uuidValidator.validateUuid('estimateId'),
  assessmentController.getAssessmentForEstimate
);

module.exports = router;
