'use strict';

const projectService = require('../services/projectService');
const { ValidationError } = require('../utils/errors');
const multer = require('multer');
const logger = require('../utils/logger');

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
      status: req.query.status
    };
    
    const projects = await projectService.getAllProjects(filters);
    return res.json({
      success: true,
      data: projects
    });
  } catch (error) {
    logger.error('Error getting all projects:', error);
    next(error);
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
    return res.json({
      success: true,
      data: project
    });
  } catch (error) {
    logger.error('Error creating project:', error);
    next(error);
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
    return res.json({
      success: true,
      data: projects
    });
  } catch (error) {
    logger.error('Error getting today\'s projects:', error);
    next(error);
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
    return res.json({
      success: true,
      data: project
    });
  } catch (error) {
    logger.error(`Error getting project ${req.params.id}:`, error);
    next(error);
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
    return res.json({
      success: true,
      data: project
    });
  } catch (error) {
    logger.error(`Error updating project ${req.params.id}:`, error);
    next(error);
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
    await projectService.deleteProject(req.params.id);
    return res.json({
      success: true,
      message: 'Project deleted successfully'
    });
  } catch (error) {
    logger.error(`Error deleting project ${req.params.id}:`, error);
    next(error);
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
    return res.json({
      success: true,
      data: project
    });
  } catch (error) {
    logger.error(`Error updating project status for ${req.params.id}:`, error);
    next(error);
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
    return res.json({
      success: true,
      data: inspection
    });
  } catch (error) {
    logger.error(`Error adding inspection to project ${req.params.id}:`, error);
    next(error);
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

    return res.json({
      success: true,
      data: photo
    });
  } catch (error) {
    logger.error(`Error adding photo to project ${req.params.id}:`, error);
    next(error);
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

    return res.json({
      success: true,
      message: 'Photo deleted successfully',
      data: updatedProject
    });
  } catch (error) {
    logger.error(`Error deleting photo ${req.params.photoId} from project ${req.params.id}:`, error);
    next(error);
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
    return res.json({
      success: true,
      data: result
    });
  } catch (error) {
    logger.error(`Error converting project ${req.params.id} to estimate:`, error);
    next(error);
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
    
    return res.json({
      success: true,
      data: jobProject
    });
  } catch (error) {
    logger.error(`Error converting assessment ${req.params.id} to job:`, error);
    next(error);
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
    
    return res.json({
      success: true,
      data: project
    });
  } catch (error) {
    logger.error(`Error updating additional work for project ${req.params.id}:`, error);
    next(error);
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
  deletePhoto, // Added deletePhoto export
  convertToEstimate,
  convertToJob,
  updateAdditionalWork
};