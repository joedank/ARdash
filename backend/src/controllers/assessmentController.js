'use strict';

const { Project, ProjectInspection } = require('../models');
const logger = require('../utils/logger');

/**
 * Controller for handling assessment-related operations
 */
const assessmentController = {
  /**
   * Get assessment data for an estimate
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getAssessmentForProject(req, res, next) {
    try {
      const { projectId } = req.params;
      
      logger.info(`Fetching assessment data for project ${projectId}`);
      
      // Get the project directly
      const project = await Project.findOne({
        where: { id: projectId }
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
  }
};

module.exports = assessmentController;
