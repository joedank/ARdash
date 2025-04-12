const { Product } = require('../models');
const logger = require('../utils/logger');

/**
 * List all products with optional filters
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const listProducts = async (req, res) => {
  try {
    const { type, isActive, search } = req.query;
    
    const where = {};
    
    // Apply filters
    if (type) {
      where.type = type;
    }
    
    if (isActive !== undefined) {
      where.isActive = isActive === 'true';
    }
    
    if (search) {
      const { Op } = require('sequelize');
      where.name = {
        [Op.iLike]: `%${search}%`
      };
    }
    
    const products = await Product.findAll({
      where,
      order: [['name', 'ASC']]
    });
    
    return res.status(200).json({
      success: true,
      data: products
    });
  } catch (error) {
    logger.error('Error listing products:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to list products',
      error: error.message
    });
  }
};

/**
 * Create a new product
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const createProduct = async (req, res) => {
  try {
    const productData = req.body;
    
    // Validate required fields
    if (!productData.name) {
      return res.status(400).json({
        success: false,
        message: 'Product name is required'
      });
    }
    
    const product = await Product.create(productData);
    
    return res.status(201).json({
      success: true,
      message: 'Product created successfully',
      data: product
    });
  } catch (error) {
    logger.error('Error creating product:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to create product',
      error: error.message
    });
  }
};

/**
 * Get product details
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getProduct = async (req, res) => {
  try {
    const { id } = req.params;
    
    const product = await Product.findByPk(id);
    
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    
    return res.status(200).json({
      success: true,
      data: product
    });
  } catch (error) {
    logger.error(`Error getting product by ID: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get product',
      error: error.message
    });
  }
};

/**
 * Update a product
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const productData = req.body;
    
    const product = await Product.findByPk(id);
    
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    
    await product.update(productData);
    
    return res.status(200).json({
      success: true,
      message: 'Product updated successfully',
      data: product
    });
  } catch (error) {
    logger.error(`Error updating product: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to update product',
      error: error.message
    });
  }
};

/**
 * Delete a product
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;
    
    const product = await Product.findByPk(id);
    
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    
    await product.destroy();
    
    return res.status(200).json({
      success: true,
      message: 'Product deleted successfully'
    });
  } catch (error) {
    logger.error(`Error deleting product: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to delete product',
      error: error.message
    });
  }
};

module.exports = {
  listProducts,
  createProduct,
  getProduct,
  updateProduct,
  deleteProduct
};
