'use strict';

const workTypeService = require('../services/workTypeService');
const logger = require('../utils/logger');
const { ValidationError } = require('../utils/errors');
const Joi = require('joi');

// Validation schemas
const schemas = {
  updateCosts: Joi.object({
    unit_cost_material: Joi.number().min(0).allow(null),
    unit_cost_labor: Joi.number().min(0).allow(null),
    productivity_unit_per_hr: Joi.number().min(0).allow(null),
    region: Joi.string().max(50)
  }).min(1), // At least one field must be provided

  addMaterials: Joi.array().items(
    Joi.object({
      product_id: Joi.string().uuid().required(),
      qty_per_unit: Joi.number().min(0).required(),
      unit: Joi.string().max(20).required()
    })
  ).min(1).required(),

  addTags: Joi.array().items(Joi.string().max(50)).min(1).required()
};

// Validation middleware
const validate = (schema) => (req, res, next) => {
  const { error } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: error.details[0].message
    });
  }
  next();
};

/**
 * Controller for work types
 */
const workTypesController = {
  /**
   * Get all work types
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  getAllWorkTypes: async (req, res, next) => {
    try {
      // Extract filter parameters from query
      const filters = {
        parentBucket: req.query.parent_bucket,
        measurementType: req.query.measurement_type,
        includeMaterials: req.query.include_materials === 'true' || req.query.include_materials === '1'
      };

      const workTypes = await workTypeService.getAllWorkTypes(filters);

      return res.json({
        success: true,
        data: workTypes
      });
    } catch (error) {
      logger.error('Error in getAllWorkTypes:', error);
      next(error);
    }
  },

  /**
   * Get work type by ID
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  getWorkTypeById: async (req, res, next) => {
    try {
      const includeMaterials = req.query.include_materials === 'true' || req.query.include_materials === '1';
      const includeTags = req.query.include_tags === 'true' || req.query.include_tags === '1';
      const includeCostHistory = req.query.include_cost_history === 'true' || req.query.include_cost_history === '1';

      const workType = await workTypeService.getWorkTypeById(
        req.params.id,
        includeMaterials,
        includeTags,
        includeCostHistory
      );

      return res.json({
        success: true,
        data: workType
      });
    } catch (error) {
      logger.error(`Error in getWorkTypeById for ID ${req.params.id}:`, error);
      next(error);
    }
  },

  /**
   * Create a new work type
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  createWorkType: async (req, res, next) => {
    try {
      const workType = await workTypeService.createWorkType(req.body);

      return res.status(201).json({
        success: true,
        data: workType,
        message: 'Work type created successfully'
      });
    } catch (error) {
      logger.error('Error in createWorkType:', error);
      next(error);
    }
  },

  /**
   * Update a work type
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  updateWorkType: async (req, res, next) => {
    try {
      const workType = await workTypeService.updateWorkType(req.params.id, req.body);

      return res.json({
        success: true,
        data: workType,
        message: 'Work type updated successfully'
      });
    } catch (error) {
      logger.error(`Error in updateWorkType for ID ${req.params.id}:`, error);
      next(error);
    }
  },

  /**
   * Delete a work type
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  deleteWorkType: async (req, res, next) => {
    try {
      await workTypeService.deleteWorkType(req.params.id);

      return res.json({
        success: true,
        message: 'Work type deleted successfully'
      });
    } catch (error) {
      logger.error(`Error in deleteWorkType for ID ${req.params.id}:`, error);
      next(error);
    }
  },

  /**
   * Find similar work types
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  findSimilarWorkTypes: async (req, res, next) => {
    try {
      // Accept both 'name' and 'q' parameters for search compatibility
      const name = req.query.name || req.query.q;
      const threshold = req.query.threshold || 0.3;

      if (!name) {
        return res.status(400).json({
          success: false,
          message: 'Name parameter is required (use either "name" or "q")'
        });
      }

      // Add rate limiting here if needed in future
      // For now, just log the request
      logger.info(`Similarity search for "${name}" with threshold ${threshold}`);

      const similarWorkTypes = await workTypeService.findSimilarWorkTypes(name, threshold);

      return res.json({
        success: true,
        data: similarWorkTypes
      });
    } catch (error) {
      logger.error(`Error in findSimilarWorkTypes for name "${req.query.name || req.query.q}":`, error);
      next(error);
    }
  },

  /**
   * Import work types from CSV data
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  importWorkTypes: async (req, res, next) => {
    try {
      if (!req.body || !Array.isArray(req.body)) {
        return res.status(400).json({
          success: false,
          message: 'Request body must be an array of work types'
        });
      }

      const results = await workTypeService.importWorkTypes(req.body);

      return res.json({
        success: true,
        data: results,
        message: `Successfully imported ${results.created} work types, ${results.failed} failed`
      });
    } catch (error) {
      logger.error('Error in importWorkTypes:', error);
      next(error);
    }
  },

  /**
   * Update costs for a work type
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  updateCosts: async (req, res, next) => {
    try {
      // Validate request body
      if (!req.body) {
        throw new ValidationError('Request body is required');
      }

      const { unit_cost_material, unit_cost_labor, productivity_unit_per_hr, region } = req.body;

      // At least one cost field is required
      if (unit_cost_material === undefined && unit_cost_labor === undefined && productivity_unit_per_hr === undefined) {
        throw new ValidationError('At least one cost field is required');
      }

      // Get user ID from authentication middleware
      const userId = req.user ? req.user.id : null;

      const result = await workTypeService.updateCosts(
        req.params.id,
        {
          unit_cost_material,
          unit_cost_labor,
          productivity_unit_per_hr
        },
        userId,
        region || 'default'
      );

      return res.json({
        success: true,
        data: {
          workType: result.workType,
          costHistory: result.costHistory
        },
        message: 'Work type costs updated successfully'
      });
    } catch (error) {
      logger.error(`Error in updateCosts for ID ${req.params.id}:`, error);
      next(error);
    }
  },

  /**
   * Get cost history for a work type
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  getCostHistory: async (req, res, next) => {
    try {
      const region = req.query.region;
      const limit = req.query.limit ? parseInt(req.query.limit, 10) : 10;

      const costHistory = await workTypeService.getCostHistory(req.params.id, region, limit);

      return res.json({
        success: true,
        data: costHistory
      });
    } catch (error) {
      logger.error(`Error in getCostHistory for ID ${req.params.id}:`, error);
      next(error);
    }
  },

  /**
   * Add materials to a work type
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  addMaterials: async (req, res, next) => {
    try {
      if (!req.body || !Array.isArray(req.body)) {
        throw new ValidationError('Request body must be an array of materials');
      }

      const materials = await workTypeService.addMaterials(req.params.id, req.body);

      return res.json({
        success: true,
        data: materials,
        message: `Successfully added ${materials.length} materials to work type`
      });
    } catch (error) {
      logger.error(`Error in addMaterials for ID ${req.params.id}:`, error);
      next(error);
    }
  },

  /**
   * Remove a material from a work type
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  removeMaterial: async (req, res, next) => {
    try {
      await workTypeService.removeMaterial(req.params.id, req.params.materialId);

      return res.json({
        success: true,
        message: 'Material removed successfully'
      });
    } catch (error) {
      logger.error(`Error in removeMaterial for work type ${req.params.id} and material ${req.params.materialId}:`, error);
      next(error);
    }
  },

  /**
   * Add tags to a work type
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  addTags: async (req, res, next) => {
    try {
      if (!req.body || !Array.isArray(req.body)) {
        throw new ValidationError('Request body must be an array of tags');
      }

      const tags = await workTypeService.addTags(req.params.id, req.body);

      return res.json({
        success: true,
        data: tags,
        message: `Successfully added ${tags.length} tags to work type`
      });
    } catch (error) {
      logger.error(`Error in addTags for ID ${req.params.id}:`, error);
      next(error);
    }
  },

  /**
   * Remove a tag from a work type
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  removeTag: async (req, res, next) => {
    try {
      await workTypeService.removeTag(req.params.id, req.params.tag);

      return res.json({
        success: true,
        message: 'Tag removed successfully'
      });
    } catch (error) {
      logger.error(`Error in removeTag for work type ${req.params.id} and tag ${req.params.tag}:`, error);
      next(error);
    }
  },

  /**
   * Get tags by frequency
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  getTagsByFrequency: async (req, res, next) => {
    try {
      const minCount = req.query.min_count ? parseInt(req.query.min_count, 10) : 1;

      const tags = await workTypeService.getTagsByFrequency(minCount);

      return res.json({
        success: true,
        data: tags
      });
    } catch (error) {
      logger.error('Error in getTagsByFrequency:', error);
      next(error);
    }
  }
};

module.exports = {
  ...workTypesController,
  validate,
  schemas
};
