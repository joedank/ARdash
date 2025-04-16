'use strict';

const projectService = require('../services/projectService');
const { ValidationError } = require('../utils/errors');
const multer = require('multer');
const logger = require('../utils/logger');
const { success, error } = require('../utils/response.util');

// Configure multer for photo uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  }
});

// Export middleware directly
const photoUpload = upload.single('photo');

/**
 * Get all projects with optional filters
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const getAll = async (req, res, next) => {
  try {
    const filters = {
      type: req.query.type,
      status: req.query.status,
      includeConverted: req.query.includeConverted === 'true'
    };

    logger.info(`Getting projects with filters: ${JSON.stringify(filters)}`);

    const projects = await projectService.getAllProjects(filters);
    return res.json(success(projects, 'Projects retrieved successfully'));
  } catch (err) {
    logger.error('Error getting all projects:', err);
    next(err);
  }
};

/**
 * Create a new project
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const post = async (req, res, next) => {
  try {
    const project = await projectService.createProject(req.body);
    return res.json(success(project, 'Project created successfully'));
  } catch (err) {
    logger.error('Error creating project:', err);
    next(err);
  }
};

/**
 * Get today's projects
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const getTodayProjects = async (req, res, next) => {
  try {
    const projects = await projectService.getTodayProjects();
    return res.json(success(projects, 'Today\'s projects retrieved successfully'));
  } catch (err) {
    logger.error('Error getting today\'s projects:', err);
    next(err);
  }
};

/**
 * Get a specific project with details
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const get = async (req, res, next) => {
  try {
    const project = await projectService.getProjectWithDetails(req.params.id);
    return res.json(success(project, 'Project retrieved successfully'));
  } catch (err) {
    logger.error(`Error getting project ${req.params.id}:`, err);
    next(err);
  }
};

/**
 * Update a project
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const update = async (req, res, next) => {
  try {
    const project = await projectService.updateProject(req.params.id, req.body);
    return res.json(success(project, 'Project updated successfully'));
  } catch (err) {
    logger.error(`Error updating project ${req.params.id}:`, err);
    next(err);
  }
};

/**
 * Check project dependencies before deletion
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const checkProjectDependencies = async (req, res, next) => {
  try {
    const dependencies = await projectService.getProjectDependencies(req.params.id);
    return res.json(success(dependencies, 'Project dependencies retrieved successfully'));
  } catch (err) {
    logger.error(`Error checking project dependencies ${req.params.id}:`, err);
    next(err);
  }
};

/**
 * Delete a project
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const deleteProject = async (req, res, next) => {
  try {
    const { deleteReferences } = req.query; // Get deletion type from query

    if (deleteReferences === 'true') {
      await projectService.deleteProjectWithReferences(req.params.id);
    } else {
      await projectService.deleteProject(req.params.id); // Existing method
    }

    return res.json(success(null, 'Project deleted successfully'));
  } catch (err) {
    logger.error(`Error deleting project ${req.params.id}:`, err);
    next(err);
  }
};

/**
 * Update project status
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const updateStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    if (!status) {
      throw new ValidationError('Status is required');
    }

    const project = await projectService.updateProjectStatus(req.params.id, status);
    return res.json(success(project, `Project status updated to ${status} successfully`));
  } catch (err) {
    logger.error(`Error updating project status for ${req.params.id}:`, err);
    next(err);
  }
};

/**
 * Add inspection to project
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const addInspection = async (req, res, next) => {
  try {
    const inspection = await projectService.addInspection(req.params.id, req.body);
    return res.json(success(inspection, 'Inspection added to project successfully'));
  } catch (err) {
    logger.error(`Error adding inspection to project ${req.params.id}:`, err);
    next(err);
  }
};

/**
 * Add photo to project
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const addPhoto = async (req, res, next) => {
  try {
    if (!req.file) {
      throw new ValidationError('Photo file is required');
    }

    const photo = await projectService.addProjectPhoto(
      req.params.id,
      req.file,
      req.body
    );

    return res.json(success(photo, 'Photo added to project successfully'));
  } catch (err) {
    logger.error(`Error adding photo to project ${req.params.id}:`, err);
    next(err);
  }
};

/**
 * Delete a photo from a project
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const deletePhoto = async (req, res, next) => {
  try {
    const { id: projectId, photoId } = req.params;

    if (!projectId || !photoId) {
      throw new ValidationError('Project ID and Photo ID are required');
    }

    await projectService.deleteProjectPhoto(projectId, photoId);
    const updatedProject = await projectService.getProjectWithDetails(projectId);

    return res.json(success(updatedProject, 'Photo deleted successfully'));
  } catch (err) {
    logger.error(`Error deleting photo ${req.params.photoId} from project ${req.params.id}:`, err);
    next(err);
  }
};


/**
 * Convert project to estimate
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const convertToEstimate = async (req, res, next) => {
  try {
    const result = await projectService.convertToEstimate(req.params.id);
    return res.json(success(result, 'Project converted to estimate successfully'));
  } catch (err) {
    logger.error(`Error converting project ${req.params.id} to estimate:`, err);
    next(err);
  }
};

/**
 * Convert assessment to active job
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const convertToJob = async (req, res, next) => {
  try {
    const { estimate_id } = req.body;

    if (!estimate_id) {
      throw new ValidationError('Estimate ID is required for conversion');
    }

    // First, update the project to link to the estimate if it's not already linked
    const project = await projectService.getProjectWithDetails(req.params.id);
    if (!project.estimate_id) {
      await projectService.updateProject(req.params.id, { estimate_id });
    }

    // Then convert the project to a job
    const jobProject = await projectService.convertAssessmentToJob(req.params.id, estimate_id);

    return res.json(success(jobProject, 'Assessment converted to job successfully'));
  } catch (err) {
    logger.error(`Error converting assessment ${req.params.id} to job:`, err);
    next(err);
  }
};

/**
 * Update additional work notes for a project
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const updateAdditionalWork = async (req, res, next) => {
  try {
    const { additional_work } = req.body;

    if (additional_work === undefined) {
      throw new ValidationError('Additional work notes are required');
    }

    const project = await projectService.updateAdditionalWork(req.params.id, additional_work);

    return res.json(success(project, 'Additional work notes updated successfully'));
  } catch (err) {
    logger.error(`Error updating additional work for project ${req.params.id}:`, err);
    next(err);
  }
};

/**
 * Get the current active job
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const getCurrentActiveJob = async (req, res, next) => {
  try {
    // This endpoint doesn't use any URL parameters, so no UUID validation needed
    const activeJob = await projectService.getCurrentActiveJob();
    return res.json(success(activeJob, 'Current active job retrieved successfully'));
  } catch (err) {
    logger.error('Error getting current active job:', err);
    next(err);
  }
};

/**
 * Get upcoming projects
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const getUpcomingProjects = async (req, res, next) => {
  try {
    // This endpoint only uses query parameters, not URL parameters, so no UUID validation needed
    const limit = req.query.limit ? parseInt(req.query.limit, 10) : 5;
    const projects = await projectService.getUpcomingProjects(limit);
    return res.json(success(projects, 'Upcoming projects retrieved successfully'));
  } catch (err) {
    logger.error('Error getting upcoming projects:', err);
    next(err);
  }
};

/**
 * Get assessment projects
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const getAssessmentProjects = async (req, res, next) => {
  try {
    // This endpoint only uses query parameters, not URL parameters, so no UUID validation needed
    const limit = req.query.limit ? parseInt(req.query.limit, 10) : 10;
    const projects = await projectService.getAssessmentProjects(limit);
    return res.json(success(projects, 'Assessment projects retrieved successfully'));
  } catch (err) {
    logger.error('Error getting assessment projects:', err);
    next(err);
  }
};

/**
 * Get recently completed projects
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const getRecentlyCompletedProjects = async (req, res, next) => {
  try {
    // This endpoint only uses query parameters, not URL parameters, so no UUID validation needed
    const limit = req.query.limit ? parseInt(req.query.limit, 10) : 5;
    const projects = await projectService.getRecentlyCompletedProjects(limit);
    return res.json(success(projects, 'Recently completed projects retrieved successfully'));
  } catch (err) {
    logger.error('Error getting recently completed projects:', err);
    next(err);
  }
};

/**
 * Get rejected assessment projects
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const getRejectedProjects = async (req, res, next) => {
  try {
    // This endpoint only uses query parameters, not URL parameters, so no UUID validation needed
    const limit = req.query.limit ? parseInt(req.query.limit, 10) : 5;
    const projects = await projectService.getRejectedProjects(limit);
    return res.json(success(projects, 'Rejected assessment projects retrieved successfully'));
  } catch (err) {
    logger.error('Error getting rejected assessment projects:', err);
    next(err);
  }
};

/**
 * Update upcoming projects to in_progress when their scheduled date arrives
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const updateUpcomingProjects = async (req, res, next) => {
  try {
    const result = await projectService.updateUpcomingProjects();
    return res.json(success(result, 'Upcoming projects updated successfully'));
  } catch (err) {
    logger.error('Error updating upcoming projects:', err);
    next(err);
  }
};

/**
 * Reject an assessment project
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const rejectAssessment = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { rejectionReason } = req.body;

    const project = await projectService.rejectAssessment(id, rejectionReason);
    return res.json(success(project, 'Assessment project rejected successfully'));
  } catch (err) {
    logger.error(`Error rejecting assessment ${req.params.id}:`, err);
    next(err);
  }
};

module.exports = {
  photoUpload,
  getAll,
  post,
  getTodayProjects,
  get,
  update,
  delete: deleteProject,
  updateStatus,
  addInspection,
  addPhoto,
  deletePhoto,
  convertToEstimate,
  convertToJob,
  updateAdditionalWork,
  checkProjectDependencies,
  getCurrentActiveJob,
  getUpcomingProjects,
  getAssessmentProjects,
  getRecentlyCompletedProjects,
  getRejectedProjects,
  updateUpcomingProjects,
  rejectAssessment
};