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
 * @route   GET /api/projects/current-active
 * @desc    Get the current active job
 * @access  Private
 * @note    This route doesn't require UUID validation as it has no parameters
 */
router.get('/current-active', authenticate, controller.getCurrentActiveJob);

/**
 * @route   GET /api/projects/upcoming
 * @desc    Get upcoming projects
 * @access  Private
 * @note    This route doesn't require UUID validation as it only uses query parameters
 */
router.get('/upcoming', authenticate, controller.getUpcomingProjects);

/**
 * @route   GET /api/projects/assessments
 * @desc    Get assessment projects
 * @access  Private
 * @note    This route doesn't require UUID validation as it only uses query parameters
 */
router.get('/assessments', authenticate, controller.getAssessmentProjects);

/**
 * @route   GET /api/projects/recently-completed
 * @desc    Get recently completed projects
 * @access  Private
 * @note    This route doesn't require UUID validation as it only uses query parameters
 */
router.get('/recently-completed', authenticate, controller.getRecentlyCompletedProjects);

/**
 * @route   GET /api/projects/rejected
 * @desc    Get rejected assessment projects
 * @access  Private
 * @note    This route doesn't require UUID validation as it only uses query parameters
 */
router.get('/rejected', authenticate, controller.getRejectedProjects);

/**
 * @route   POST /api/projects/update-upcoming
 * @desc    Update status of upcoming projects when their scheduled date arrives
 * @access  Private
 * @note    This route doesn't require UUID validation as it has no parameters
 */
router.post('/update-upcoming', authenticate, controller.updateUpcomingProjects);

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

/**
 * @route   POST /api/projects/:id/reject
 * @desc    Reject an assessment project
 * @access  Private
 */
router.post('/:id/reject', authenticate, validateUuid('id'), controller.rejectAssessment);

/**
 * @route   PUT /api/projects/:id/work-types
 * @desc    Update work types for a project assessment
 * @access  Private
 */
router.put('/:id/work-types', authenticate, validateUuid('id'), controller.updateWorkTypes);

module.exports = router;