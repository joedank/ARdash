'use strict';

const express = require('express');
const router = express.Router();
const controller = require('../controllers/projects.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { validateUuid, validateMultipleUuids } = require('../middleware/uuidValidator');

/**
 * @route   GET /api/projects
 * @desc    Get all projects with optional filters
 * @access  Private
 */
router.get('/', authenticate, controller.getAll);

/**
 * @route   POST /api/projects
 * @desc    Create a new project
 * @access  Private
 */
router.post('/', authenticate, controller.post);

/**
 * @route   GET /api/projects/today
 * @desc    Get today's projects
 * @access  Private
 */
router.get('/today', authenticate, controller.getTodayProjects);

/**
 * @route   GET /api/projects/:id
 * @desc    Get project details
 * @access  Private
 */
router.get('/:id', authenticate, validateUuid('id'), controller.get);

/**
 * @route   PUT /api/projects/:id
 * @desc    Update project
 * @access  Private
 */
router.put('/:id', authenticate, validateUuid('id'), controller.update);

/**
 * @route   GET /api/projects/:id/dependencies
 * @desc    Check project dependencies before deletion
 * @access  Private
 */
router.get('/:id/dependencies', authenticate, validateUuid('id'), controller.checkProjectDependencies);

/**
 * @route   DELETE /api/projects/:id
 * @desc    Delete project
 * @access  Private
 */
router.delete('/:id', authenticate, validateUuid('id'), controller.delete);

/**
 * @route   PUT /api/projects/:id/status
 * @desc    Update project status
 * @access  Private
 */
router.put('/:id/status', authenticate, validateUuid('id'), controller.updateStatus);

/**
 * @route   POST /api/projects/:id/inspections
 * @desc    Add inspection to project
 * @access  Private
 */
router.post('/:id/inspections', authenticate, validateUuid('id'), controller.addInspection);

/**
 * @route   POST /api/projects/:id/photos
 * @desc    Add photo to project
 * @access  Private
 */
router.post('/:id/photos', authenticate, validateUuid('id'), controller.photoUpload, controller.addPhoto);

/**
 * @route   DELETE /api/projects/:id/photos/:photoId
 * @desc    Delete a photo from a project
 * @access  Private
 */
router.delete(
  '/:id/photos/:photoId', 
  authenticate, 
  validateMultipleUuids(['id', 'photoId']), 
  controller.deletePhoto
);

/**
 * @route   POST /api/projects/:id/convert
 * @desc    Convert project to estimate
 * @access  Private
 */
router.post('/:id/convert', authenticate, validateUuid('id'), controller.convertToEstimate);

/**
 * @route   POST /api/projects/:id/convert-to-job
 * @desc    Convert assessment to active job
 * @access  Private
 */
router.post('/:id/convert-to-job', authenticate, validateUuid('id'), controller.convertToJob);

/**
 * @route   PUT /api/projects/:id/additional-work
 * @desc    Update additional work notes for a project
 * @access  Private
 */
router.put('/:id/additional-work', authenticate, validateUuid('id'), controller.updateAdditionalWork);

module.exports = router;