const { Product } = require('../models');
const logger = require('../utils/logger');
const { success, error } = require('../utils/response.util');

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
    
    return res.status(200).json(success(products, 'Products retrieved successfully'));
  } catch (err) {
    logger.error('Error listing products:', err);
    return res.status(500).json(error('Failed to list products', { message: err.message }));
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
      return res.status(400).json(error('Product name is required'));
    }
    
    const product = await Product.create(productData);
    
    return res.status(201).json(success(product, 'Product created successfully'));
  } catch (err) {
    logger.error('Error creating product:', err);
    return res.status(500).json(error('Failed to create product', { message: err.message }));
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
      return res.status(404).json(error('Product not found'));
    }
    
    return res.status(200).json(success(product, 'Product retrieved successfully'));
  } catch (err) {
    logger.error(`Error getting product by ID: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to get product', { message: err.message }));
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
      return res.status(404).json(error('Product not found'));
    }
    
    await product.update(productData);
    
    return res.status(200).json(success(product, 'Product updated successfully'));
  } catch (err) {
    logger.error(`Error updating product: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to update product', { message: err.message }));
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
      return res.status(404).json(error('Product not found'));
    }
    
    await product.destroy();
    
    return res.status(200).json(success(null, 'Product deleted successfully'));
  } catch (err) {
    logger.error(`Error deleting product: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to delete product', { message: err.message }));
  }
};

module.exports = {
  listProducts,
  createProduct,
  getProduct,
  updateProduct,
  deleteProduct
};
