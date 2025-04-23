'use strict';

const { Product } = require('../models');
const { v4: uuidv4 } = require('uuid');
const logger = require('../utils/logger');
const { ValidationError, NotFoundError } = require('../utils/errors');
const { sequelize } = require('../models');

/**
 * Service for managing materials
 */
class MaterialsService {
  /**
   * Find products by name using trigram similarity
   * @param {string} name - Product name to search
   * @param {number} threshold - Similarity threshold (0-1)
   * @param {string} type - Product type filter
   * @returns {Promise<Array>} Similar products
   */
  async findByName(name, threshold = 0.3, type = 'material') {
    try {
      const query = `
        SELECT id, name, price, tax_rate, unit, type,
               similarity(name, :name) AS score
        FROM products
        WHERE 
          similarity(name, :name) > :threshold
          AND type = :type
          AND deleted_at IS NULL
        ORDER BY score DESC
        LIMIT 10
      `;
      
      const results = await sequelize.query(query, {
        replacements: { name, threshold, type },
        type: sequelize.QueryTypes.SELECT
      });
      
      return results;
    } catch (error) {
      logger.error(`Error finding products similar to "${name}":`, error);
      throw error;
    }
  }
  
  /**
   * Find a product by SKU
   * @param {string} sku - Product SKU
   * @returns {Promise<Object>} Product
   */
  async findBySku(sku) {
    try {
      const product = await Product.findOne({
        where: {
          sku,
          deleted_at: null
        }
      });
      
      return product;
    } catch (error) {
      logger.error(`Error finding product with SKU ${sku}:`, error);
      throw error;
    }
  }
  
  /**
   * Resolve a product ID by SKU or name
   * @param {string} identifier - Product SKU or name
   * @param {string} type - Product type
   * @returns {Promise<string>} Product ID
   */
  async resolveProductId(identifier, type = 'material') {
    try {
      // Try to find by SKU first
      const productBySku = await this.findBySku(identifier);
      
      if (productBySku) {
        return productBySku.id;
      }
      
      // Try to find by name using trigram similarity
      const similarProducts = await this.findByName(identifier, 0.7, type);
      
      if (similarProducts.length > 0) {
        return similarProducts[0].id;
      }
      
      // Not found
      throw new NotFoundError(`Product with identifier "${identifier}" not found`);
    } catch (error) {
      logger.error(`Error resolving product ID for "${identifier}":`, error);
      throw error;
    }
  }
  
  /**
   * Create a new product
   * @param {Object} data - Product data
   * @returns {Promise<Object>} Created product
   */
  async createProduct(data) {
    try {
      // Validate required fields
      if (!data.name) {
        throw new ValidationError('Product name is required');
      }
      
      if (!data.type) {
        throw new ValidationError('Product type is required');
      }
      
      // Set default values
      const productData = {
        id: data.id || uuidv4(),
        name: data.name,
        description: data.description || '',
        price: data.price || 0,
        tax_rate: data.tax_rate || 0,
        type: data.type || 'material',
        unit: data.unit || 'each',
        sku: data.sku || null
      };
      
      // Check for duplicates using trigram similarity
      const similar = await this.findByName(data.name, 0.85, data.type);
      if (similar.length > 0) {
        throw new ValidationError(`A similar product already exists: "${similar[0].name}" (${similar[0].score.toFixed(2)} similarity)`);
      }
      
      const product = await Product.create(productData);
      return product;
    } catch (error) {
      logger.error('Error creating product:', error);
      throw error;
    }
  }
  
  /**
   * Get frequently used materials
   * @param {number} limit - Maximum number of materials to return
   * @returns {Promise<Array>} Frequently used materials
   */
  async getFrequentlyUsedMaterials(limit = 20) {
    try {
      const query = `
        SELECT p.id, p.name, p.price, p.tax_rate, p.unit, p.type, COUNT(wtm.id) as usage_count
        FROM products p
        JOIN work_type_materials wtm ON p.id = wtm.product_id
        WHERE p.type = 'material' AND p.deleted_at IS NULL
        GROUP BY p.id
        ORDER BY usage_count DESC
        LIMIT :limit
      `;
      
      const results = await sequelize.query(query, {
        replacements: { limit },
        type: sequelize.QueryTypes.SELECT
      });
      
      return results;
    } catch (error) {
      logger.error('Error getting frequently used materials:', error);
      throw error;
    }
  }
}

module.exports = new MaterialsService();
