'use strict';

const materialsService = require('../services/materials.service');
const logger = require('../utils/logger');
const { ValidationError } = require('../utils/errors');

/**
 * Controller for materials
 */
const materialsController = {
  /**
   * Find products by name using trigram similarity
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  findByName: async (req, res, next) => {
    try {
      const name = req.query.name || req.query.q;
      const threshold = req.query.threshold ? parseFloat(req.query.threshold) : 0.3;
      const type = req.query.type || 'material';
      
      if (!name) {
        throw new ValidationError('Name parameter is required (use either "name" or "q")');
      }
      
      const products = await materialsService.findByName(name, threshold, type);
      
      return res.json({
        success: true,
        data: products
      });
    } catch (error) {
      logger.error(`Error in findByName for "${req.query.name || req.query.q}":`, error);
      next(error);
    }
  },
  
  /**
   * Find product by SKU
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  findBySku: async (req, res, next) => {
    try {
      const { sku } = req.params;
      
      if (!sku) {
        throw new ValidationError('SKU parameter is required');
      }
      
      const product = await materialsService.findBySku(sku);
      
      return res.json({
        success: true,
        data: product
      });
    } catch (error) {
      logger.error(`Error in findBySku for SKU "${req.params.sku}":`, error);
      next(error);
    }
  },
  
  /**
   * Create a new product
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  createProduct: async (req, res, next) => {
    try {
      const product = await materialsService.createProduct(req.body);
      
      return res.status(201).json({
        success: true,
        data: product,
        message: 'Product created successfully'
      });
    } catch (error) {
      logger.error('Error in createProduct:', error);
      next(error);
    }
  },
  
  /**
   * Get frequently used materials
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  getFrequentlyUsedMaterials: async (req, res, next) => {
    try {
      const limit = req.query.limit ? parseInt(req.query.limit, 10) : 20;
      
      const materials = await materialsService.getFrequentlyUsedMaterials(limit);
      
      return res.json({
        success: true,
        data: materials
      });
    } catch (error) {
      logger.error('Error in getFrequentlyUsedMaterials:', error);
      next(error);
    }
  },
  
  /**
   * Resolve product ID by SKU or name
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  resolveProductId: async (req, res, next) => {
    try {
      const { identifier } = req.params;
      const type = req.query.type || 'material';
      
      if (!identifier) {
        throw new ValidationError('Product identifier is required');
      }
      
      const productId = await materialsService.resolveProductId(identifier, type);
      
      return res.json({
        success: true,
        data: { id: productId }
      });
    } catch (error) {
      logger.error(`Error in resolveProductId for "${req.params.identifier}":`, error);
      next(error);
    }
  }
};

module.exports = materialsController;
