'use strict';

const { ValidationError } = require('../utils/errors');
const workTypeDetectionService = require('../services/workTypeDetectionService');
const logger = require('../utils/logger');
const { Project, ProjectInspection, Estimate } = require('../models');

/**
 * Detect work types from condition text
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.detectWorkTypes = async (req, res, next) => {
  try {
    const { condition } = req.body;

    if (!condition || typeof condition !== 'string' || condition.trim().length < 15) {
      logger.warn('Invalid or too short condition text for work type detection:', condition);
      return res.status(400).json({
        success: false,
        message: 'Condition text must be at least 15 characters long'
      });
    }

    const workTypes = await workTypeDetectionService.detect(condition);

    return res.status(200).json({
      success: true,
      data: workTypes
    });
  } catch (error) {
    logger.error('Error in detectWorkTypes controller:', error);
    next(error);
  }
};

/**
 * Get assessment data for a project
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.getAssessmentForProject = async (req, res, next) => {
  try {
    const { projectId } = req.params;

    logger.info(`Fetching assessment data for project ${projectId}`);

    // Get the project directly
    const project = await Project.findOne({
      where: { id: projectId }
    });

    if (!project) {
      logger.warn(`No project found with ID ${projectId}`);
      return res.status(200).json({
        success: true,
        message: 'No assessment data found for this project',
        data: null
      });
    }

    // Get the project inspections
    const inspections = await ProjectInspection.findAll({
      where: { project_id: project.id }
    });

    logger.info(`Found ${inspections.length} inspections for project ${project.id}`);

    return res.status(200).json({
      success: true,
      message: 'Assessment data retrieved successfully',
      data: {
        project,
        project_inspections: inspections
      }
    });
  } catch (error) {
    logger.error('Error in getAssessmentForProject:', error);
    next(error);
  }
};

/**
 * Get assessment data for an estimate
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.getAssessmentForEstimate = async (req, res, next) => {
  try {
    const { estimateId } = req.params;

    logger.info(`Fetching assessment data for estimate ${estimateId}`);

    // Get the estimate
    const estimate = await Estimate.findOne({
      where: { id: estimateId }
    });

    if (!estimate || !estimate.project_id) {
      logger.warn(`No estimate found with ID ${estimateId} or estimate has no project_id`);
      return res.status(200).json({
        success: true,
        message: 'No assessment data found for this estimate',
        data: null
      });
    }

    // Get the project
    const project = await Project.findOne({
      where: { id: estimate.project_id }
    });

    if (!project) {
      logger.warn(`No project found for estimate ${estimateId}`);
      return res.status(200).json({
        success: true,
        message: 'No assessment data found for this estimate',
        data: null
      });
    }

    // Get the project inspections
    const inspections = await ProjectInspection.findAll({
      where: { project_id: project.id }
    });

    logger.info(`Found ${inspections.length} inspections for project ${project.id}`);

    return res.status(200).json({
      success: true,
      message: 'Assessment data retrieved successfully',
      data: {
        project,
        project_inspections: inspections
      }
    });
  } catch (error) {
    logger.error('Error in getAssessmentForEstimate:', error);
    next(error);
  }
};
