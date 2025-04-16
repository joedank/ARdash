'use strict';

const express = require('express');
const router = express.Router();
const assessmentController = require('../controllers/assessmentController');
const estimatesController = require('../controllers/estimates.controller'); // Add estimates controller
const authMiddleware = require('../middleware/auth.middleware');
const uuidValidator = require('../middleware/uuidValidator');

// Apply authentication middleware to all routes
router.use(authMiddleware.authenticate);

/**
 * @route GET /api/assessment/for-project/:projectId
 * @description Get assessment data for a project (legacy route)
 * @access Private
 */
router.get(
  '/for-project/:projectId',
  uuidValidator.validateUuid('projectId'),
  (req, res, next) => {
    console.log('Legacy route accessed: /api/assessment/for-project/:projectId');
    // Forward to the new endpoint in estimates controller
    return estimatesController.getAssessmentData(req, res, next);
  }
);

module.exports = router;
