'use strict';

const { EstimateItemAdditionalWork, EstimateItem } = require('../models');
const { ValidationError, NotFoundError } = require('../utils/errors');
const { validate: uuidValidate } = require('uuid');
const logger = require('../utils/logger');

/**
 * Controller for managing additional work related to estimate items
 */
const EstimateItemAdditionalWorkController = {
  /**
   * Create or update additional work for an estimate item
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async createOrUpdate(req, res, next) {
    try {
      const { estimateItemId } = req.params;
      const { description } = req.body;
      
      // Validate inputs
      if (!uuidValidate(estimateItemId)) {
        throw new ValidationError('Invalid estimate item ID format');
      }
      
      if (!description || typeof description !== 'string' || description.trim() === '') {
        throw new ValidationError('Description is required');
      }
      
      // Check if the estimate item exists
      const estimateItem = await EstimateItem.findByPk(estimateItemId);
      if (!estimateItem) {
        throw new NotFoundError(`Estimate item with ID ${estimateItemId} not found`);
      }
      
      // Find existing additional work or create new
      const [additionalWork, created] = await EstimateItemAdditionalWork.findOrCreate({
        where: { estimate_item_id: estimateItemId },
        defaults: { description }
      });
      
      // If found existing, update it
      if (!created) {
        additionalWork.description = description;
        await additionalWork.save();
      }
      
      // Log successful creation/update
      logger.info(`${created ? 'Created' : 'Updated'} additional work for estimate item ${estimateItemId}: ${additionalWork.id}`);
      
      res.status(created ? 201 : 200).json({
        success: true,
        message: created ? 'Additional work created' : 'Additional work updated',
        data: additionalWork
      });
    } catch (error) {
      next(error);
    }
  },
  
  /**
   * Get additional work for an estimate item
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async get(req, res, next) {
    try {
      const { estimateItemId } = req.params;
      
      // Validate uuid
      if (!uuidValidate(estimateItemId)) {
        throw new ValidationError('Invalid estimate item ID format');
      }
      
      // Find additional work
      const additionalWork = await EstimateItemAdditionalWork.findOne({
        where: { estimate_item_id: estimateItemId }
      });
      
      // Log successful operation
      logger.info(`Fetched additional work for estimate item ${estimateItemId}`);
      
      // Return the additional work (or null if none exists)
      res.json({
        success: true,
        data: additionalWork
      });
    } catch (error) {
      next(error);
    }
  },
  
  /**
   * Delete additional work for an estimate item
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async delete(req, res, next) {
    try {
      const { estimateItemId } = req.params;
      
      // Validate uuid
      if (!uuidValidate(estimateItemId)) {
        throw new ValidationError('Invalid estimate item ID format');
      }
      
      // Delete additional work
      const deleted = await EstimateItemAdditionalWork.destroy({
        where: { estimate_item_id: estimateItemId }
      });
      
      if (deleted === 0) {
        throw new NotFoundError(`No additional work found for estimate item ID ${estimateItemId}`);
      }
      
      // Log the deletion
      logger.info(`Deleted additional work for estimate item ${estimateItemId}`);
      
      res.json({
        success: true,
        message: 'Additional work deleted successfully',
        data: { deleted }
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Get all additional work for a specific estimate
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getByEstimate(req, res, next) {
    try {
      const { estimateId } = req.params;
      
      // Validate uuid
      if (!uuidValidate(estimateId)) {
        throw new ValidationError('Invalid estimate ID format');
      }
      
      // First get all estimate items for this estimate
      const estimateItems = await EstimateItem.findAll({
        where: { estimate_id: estimateId },
        attributes: ['id']
      });
      
      if (!estimateItems || estimateItems.length === 0) {
        return res.json({
          success: true,
          data: []
        });
      }
      
      const estimateItemIds = estimateItems.map(item => item.id);
      
      // Get all additional work for these items
      const additionalWorks = await EstimateItemAdditionalWork.findAll({
        where: {
          estimate_item_id: estimateItemIds
        },
        include: [
          {
            model: EstimateItem,
            as: 'estimateItem',
            attributes: ['id', 'description']
          }
        ]
      });
      
      // Transform into a map with estimate_item_id as key
      const additionalWorkMap = {};
      additionalWorks.forEach(work => {
        additionalWorkMap[work.estimate_item_id] = {
          id: work.id,
          description: work.description,
          createdAt: work.created_at,
          updatedAt: work.updated_at
        };
      });
      
      // Log the successful operation
      logger.info(`Retrieved additional work map for estimate ${estimateId}`);
      
      res.json({
        success: true,
        data: additionalWorkMap
      });
    } catch (error) {
      next(error);
    }
  }
};

module.exports = EstimateItemAdditionalWorkController;
