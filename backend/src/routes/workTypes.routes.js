'use strict';

const express = require('express');
const router = express.Router();
const controller = require('../controllers/workTypesController');
const { validate, schemas } = require('../controllers/workTypesController');
const { authenticate } = require('../middleware/auth.middleware');
const { isEstimatorManagerOrAdmin } = require('../middleware/role.middleware');
const { validateUuid } = require('../middleware/uuidValidator');
const rateLimit = require('express-rate-limit');

// Rate limiter for similarity search
const similarityLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 60, // 60 requests per minute
  message: 'Too many similarity requests, please try again later',
  standardHeaders: true,
  legacyHeaders: false
});

/**
 * @route   GET /api/work-types/similar
 * @desc    Find similar work types by name
 * @access  Private
 * @note    This route doesn't use the UUID validator as it doesn't use path parameters
 */
router.get('/similar', authenticate, similarityLimiter, controller.findSimilarWorkTypes);

/**
 * @route   POST /api/work-types/import
 * @desc    Import work types
 * @access  Private
 * @note    This route doesn't use the UUID validator as it doesn't use path parameters
 */
router.post('/import', authenticate, controller.importWorkTypes);

/**
 * @route   GET /api/work-types/tags/frequency
 * @desc    Get tags grouped by frequency
 * @access  Private
 * @note    This route doesn't use the UUID validator as it doesn't use path parameters
 */
router.get('/tags/frequency', authenticate, controller.getTagsByFrequency);

/**
 * @route   GET /api/work-types
 * @desc    Get all work types with optional filtering
 * @access  Private
 * @note    This route doesn't use the UUID validator as it doesn't use path parameters
 */
router.get('/', authenticate, controller.getAllWorkTypes);

/**
 * @route   GET /api/work-types/:id
 * @desc    Get a work type by ID
 * @access  Private
 */
router.get('/:id', authenticate, validateUuid('id'), controller.getWorkTypeById);

/**
 * @route   POST /api/work-types
 * @desc    Create a new work type
 * @access  Private
 * @note    This route doesn't use the UUID validator as it doesn't use path parameters
 */
router.post('/', authenticate, controller.createWorkType);

/**
 * @route   PUT /api/work-types/:id
 * @desc    Update a work type
 * @access  Private
 */
router.put('/:id', authenticate, validateUuid('id'), controller.updateWorkType);

/**
 * @route   DELETE /api/work-types/:id
 * @desc    Delete a work type
 * @access  Private
 */
router.delete('/:id', authenticate, validateUuid('id'), controller.deleteWorkType);

/**
 * @route   PATCH /api/work-types/:id/costs
 * @desc    Update costs for a work type
 * @access  Private (Admin or Estimator Manager)
 */
router.patch('/:id/costs', authenticate, isEstimatorManagerOrAdmin, validateUuid('id'), validate(schemas.updateCosts), controller.updateCosts);

/**
 * @route   GET /api/work-types/:id/costs/history
 * @desc    Get cost history for a work type
 * @access  Private
 */
router.get('/:id/costs/history', authenticate, validateUuid('id'), controller.getCostHistory);

/**
 * @route   POST /api/work-types/:id/materials
 * @desc    Add materials to a work type
 * @access  Private (Admin or Estimator Manager)
 */
router.post('/:id/materials', authenticate, isEstimatorManagerOrAdmin, validateUuid('id'), validate(schemas.addMaterials), controller.addMaterials);

/**
 * @route   DELETE /api/work-types/:id/materials/:materialId
 * @desc    Remove a material from a work type
 * @access  Private (Admin or Estimator Manager)
 */
router.delete('/:id/materials/:materialId', authenticate, isEstimatorManagerOrAdmin, validateUuid('id'), validateUuid('materialId'), controller.removeMaterial);

/**
 * @route   POST /api/work-types/:id/tags
 * @desc    Add tags to a work type
 * @access  Private (Admin or Estimator Manager)
 */
router.post('/:id/tags', authenticate, isEstimatorManagerOrAdmin, validateUuid('id'), validate(schemas.addTags), controller.addTags);

/**
 * @route   DELETE /api/work-types/:id/tags/:tag
 * @desc    Remove a tag from a work type
 * @access  Private (Admin or Estimator Manager)
 */
router.delete('/:id/tags/:tag', authenticate, isEstimatorManagerOrAdmin, validateUuid('id'), controller.removeTag);

module.exports = router;
