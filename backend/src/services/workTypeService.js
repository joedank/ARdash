'use strict';

const { WorkType, WorkTypeMaterial, WorkTypeTag, WorkTypeCostHistory, Product } = require('../models');
const { v4: uuidv4 } = require('uuid');
const logger = require('../utils/logger');
const { ValidationError, NotFoundError, AuthorizationError } = require('../utils/errors');
const { sequelize } = require('../models'); // Import sequelize instance

// Simple in-memory cache with TTL
class Cache {
  constructor(ttlMs = 300000) { // Default 5 minutes TTL
    this.cache = new Map();
    this.ttl = ttlMs;
  }

  get(key) {
    if (!this.cache.has(key)) return null;

    const { value, expires } = this.cache.get(key);
    if (Date.now() > expires) {
      this.cache.delete(key);
      return null;
    }

    return value;
  }

  set(key, value) {
    this.cache.set(key, {
      value,
      expires: Date.now() + this.ttl
    });
  }

  clear() {
    this.cache.clear();
  }
}

/**
 * Service for managing work types
 */
class WorkTypeService {
  constructor() {
    // Initialize cache for similar work types with 5-minute TTL
    this.similarWorkTypesCache = new Cache(300000); // 5 minutes
    this.tagFrequencyCache = new Cache(600000); // 10 minutes
  }
  /**
   * Get all work types with optional filtering
   * @param {Object} filters - Optional filter criteria
   * @returns {Promise<Array>} Array of work types
   */
  async getAllWorkTypes(filters = {}) {
    try {
      const where = {};

      // Apply filters if provided
      if (filters.parentBucket) {
        where.parent_bucket = filters.parentBucket;
      }

      if (filters.measurementType) {
        where.measurement_type = filters.measurementType;
      }

      const workTypes = await WorkType.findAll({
        where,
        order: [
          ['parent_bucket', 'ASC'],
          ['name', 'ASC']
        ],
        include: filters.includeMaterials ? [
          {
            model: WorkTypeMaterial,
            as: 'materials',
            include: [
              {
                model: Product,
                as: 'product'
              }
            ]
          },
          {
            model: WorkTypeTag,
            as: 'tags'
          }
        ] : []
      });

      return workTypes;
    } catch (error) {
      logger.error('Error getting work types:', error);
      throw error;
    }
  }

  /**
   * Get a work type by ID with optional inclusion of materials and tags
   * @param {string} id - Work type UUID
   * @param {boolean} includeMaterials - Whether to include materials
   * @param {boolean} includeTags - Whether to include tags
   * @param {boolean} includeCostHistory - Whether to include cost history
   * @returns {Promise<Object>} Work type object
   */
  async getWorkTypeById(id, includeMaterials = false, includeTags = false, includeCostHistory = false) {
    try {
      const include = [];

      if (includeMaterials) {
        include.push({
          model: WorkTypeMaterial,
          as: 'materials',
          include: [
            {
              model: Product,
              as: 'product'
            }
          ]
        });
      }

      if (includeTags) {
        include.push({
          model: WorkTypeTag,
          as: 'tags'
        });
      }

      if (includeCostHistory) {
        include.push({
          model: WorkTypeCostHistory,
          as: 'costHistory',
          order: [['captured_at', 'DESC']]
        });
      }

      const workType = await WorkType.findByPk(id, {
        include
      });

      if (!workType) {
        throw new NotFoundError(`Work type with ID ${id} not found`);
      }

      return workType;
    } catch (error) {
      logger.error(`Error getting work type ${id}:`, error);
      throw error;
    }
  }

  /**
   * Create a new work type
   * @param {Object} data - Work type data
   * @returns {Promise<Object>} Created work type
   */
  async createWorkType(data) {
    // Use a transaction for database consistency
    const transaction = await sequelize.transaction();

    try {
      // Validate required fields
      if (!data.name) {
        throw new ValidationError('Work type name is required');
      }

      if (!data.parent_bucket) {
        throw new ValidationError('Parent bucket is required');
      }

      if (!data.measurement_type) {
        throw new ValidationError('Measurement type is required');
      }

      if (!data.suggested_units) {
        throw new ValidationError('Suggested units are required');
      }

      // Check for duplicates using trigram similarity
      const similar = await this.findSimilarWorkTypes(data.name, 0.85);
      if (similar.length > 0) {
        throw new ValidationError(`A similar work type already exists: "${similar[0].name}" (${similar[0].score.toFixed(2)} similarity)`);
      }

      // Set UUID if not provided
      if (!data.id) {
        data.id = uuidv4();
      }

      // Set initial revision
      if (!data.revision) {
        data.revision = 1;
      }

      // Clean up name to ensure consistent formatting (replace narrow no-break space)
      if (data.name) {
        // Replace unicode narrow-no-break space (U+202F) with standard hyphen
        data.name = data.name.replace(/\u202F/g, '-');
      }

      const workType = await WorkType.create(data, { transaction });

      // If vector embedding is enabled, generate it (to be implemented in Phase B)
      // This is a placeholder for future enhancement
      /*
      if (process.env.ENABLE_VECTOR_EMBEDDINGS === 'true') {
        // Generate embedding and update the record
        const embedding = await generateEmbedding(data.name);
        await workType.update({ name_vec: embedding }, { transaction });
      }
      */

      await transaction.commit();
      return workType;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error creating work type:', error);
      throw error;
    }
  }

  /**
   * Update a work type
   * @param {string} id - Work type UUID
   * @param {Object} data - Updated work type data
   * @returns {Promise<Object>} Updated work type
   */
  async updateWorkType(id, data) {
    const transaction = await sequelize.transaction();

    try {
      const workType = await WorkType.findByPk(id, { transaction });

      if (!workType) {
        throw new NotFoundError(`Work type with ID ${id} not found`);
      }

      // Clean up name to ensure consistent formatting if it's being updated
      if (data.name) {
        // Replace unicode narrow-no-break space (U+202F) with standard hyphen
        data.name = data.name.replace(/\u202F/g, '-');
      }

      // Increment revision number
      data.revision = (workType.revision || 0) + 1;

      await workType.update(data, { transaction });

      await transaction.commit();
      return workType;
    } catch (error) {
      await transaction.rollback();
      logger.error(`Error updating work type ${id}:`, error);
      throw error;
    }
  }

  /**
   * Update costs for a work type
   * @param {string} id - Work type UUID
   * @param {Object} costData - Cost data
   * @param {number} costData.unit_cost_material - Material cost per unit
   * @param {number} costData.unit_cost_labor - Labor cost per unit
   * @param {number} costData.productivity_unit_per_hr - Units that can be completed per hour
   * @param {string} userId - User ID making the update
   * @param {string} region - Region for cost data (default: 'default')
   * @returns {Promise<Object>} Updated work type
   */
  async updateCosts(id, costData, userId, region = 'default') {
    const transaction = await sequelize.transaction({
      // Set a timeout of 30 seconds for the transaction
      timeout: 30000
    });

    try {
      // Validate cost data
      if (costData.unit_cost_material !== undefined && costData.unit_cost_material < 0) {
        throw new ValidationError('Material cost cannot be negative');
      }

      if (costData.unit_cost_labor !== undefined && costData.unit_cost_labor < 0) {
        throw new ValidationError('Labor cost cannot be negative');
      }

      if (costData.productivity_unit_per_hr !== undefined && costData.productivity_unit_per_hr < 0) {
        throw new ValidationError('Productivity cannot be negative');
      }

      const workType = await WorkType.findByPk(id, { transaction });

      if (!workType) {
        throw new NotFoundError(`Work type with ID ${id} not found`);
      }

      // Update the work type costs
      const updateData = {
        revision: (workType.revision || 0) + 1,
        updated_by: userId
      };

      if (costData.unit_cost_material !== undefined) {
        updateData.unit_cost_material = costData.unit_cost_material;
      }

      if (costData.unit_cost_labor !== undefined) {
        updateData.unit_cost_labor = costData.unit_cost_labor;
      }

      if (costData.productivity_unit_per_hr !== undefined) {
        updateData.productivity_unit_per_hr = costData.productivity_unit_per_hr;
      }

      await workType.update(updateData, { transaction });

      // Record in cost history using helper method
      const costHistory = await this._logCostHistory({
        workTypeId: id,
        region,
        unitCostMaterial: costData.unit_cost_material !== undefined ? costData.unit_cost_material : workType.unit_cost_material,
        unitCostLabor: costData.unit_cost_labor !== undefined ? costData.unit_cost_labor : workType.unit_cost_labor,
        userId
      }, transaction);

      await transaction.commit();

      // Return both the updated work type and the new history record
      return {
        workType,
        costHistory
      };
    } catch (error) {
      await transaction.rollback();
      logger.error(`Error updating costs for work type ${id}:`, error);
      throw error;
    }
  }

  /**
   * Add materials to a work type
   * @param {string} workTypeId - Work type UUID
   * @param {Array} materials - Array of material objects
   * @param {string} materials[].product_id - Product ID
   * @param {number} materials[].qty_per_unit - Quantity per unit
   * @param {string} materials[].unit - Unit of measurement
   * @returns {Promise<Array>} Added materials
   */
  async addMaterials(workTypeId, materials) {
    const transaction = await sequelize.transaction({
      timeout: 30000 // 30 seconds timeout
    });

    try {
      const workType = await WorkType.findByPk(workTypeId, { transaction });

      if (!workType) {
        throw new NotFoundError(`Work type with ID ${workTypeId} not found`);
      }

      const results = [];

      for (const material of materials) {
        // Validate product ID
        if (!material.product_id) {
          throw new ValidationError('Product ID is required for each material');
        }

        // Check if product exists
        const product = await Product.findByPk(material.product_id, { transaction });

        if (!product) {
          throw new ValidationError(`Product with ID ${material.product_id} not found`);
        }

        // Check if material already exists for this work type
        const existingMaterial = await WorkTypeMaterial.findOne({
          where: {
            work_type_id: workTypeId,
            product_id: material.product_id
          },
          transaction
        });

        if (existingMaterial) {
          // Update existing material
          await existingMaterial.update({
            qty_per_unit: material.qty_per_unit || existingMaterial.qty_per_unit,
            unit: material.unit || existingMaterial.unit
          }, { transaction });

          results.push(existingMaterial);
        } else {
          // Create new material
          const newMaterial = await WorkTypeMaterial.create({
            id: uuidv4(),
            work_type_id: workTypeId,
            product_id: material.product_id,
            qty_per_unit: material.qty_per_unit || 1,
            unit: material.unit || 'each'
          }, { transaction });

          results.push(newMaterial);
        }
      }

      // Update work type revision
      await workType.update({
        revision: (workType.revision || 0) + 1
      }, { transaction });

      await transaction.commit();
      return results;
    } catch (error) {
      await transaction.rollback();
      logger.error(`Error adding materials to work type ${workTypeId}:`, error);
      throw error;
    }
  }

  /**
   * Remove a material from a work type
   * @param {string} workTypeId - Work type UUID
   * @param {string} materialId - Work type material UUID
   * @returns {Promise<boolean>} Success status
   */
  async removeMaterial(workTypeId, materialId) {
    const transaction = await sequelize.transaction({
      timeout: 30000 // 30 seconds timeout
    });

    try {
      const workType = await WorkType.findByPk(workTypeId, { transaction });

      if (!workType) {
        throw new NotFoundError(`Work type with ID ${workTypeId} not found`);
      }

      const material = await WorkTypeMaterial.findOne({
        where: {
          id: materialId,
          work_type_id: workTypeId
        },
        transaction
      });

      if (!material) {
        throw new NotFoundError(`Material with ID ${materialId} not found for work type ${workTypeId}`);
      }

      await material.destroy({ transaction });

      // Update work type revision
      await workType.update({
        revision: (workType.revision || 0) + 1
      }, { transaction });

      await transaction.commit();
      return true;
    } catch (error) {
      await transaction.rollback();
      logger.error(`Error removing material ${materialId} from work type ${workTypeId}:`, error);
      throw error;
    }
  }

  /**
   * Add tags to a work type
   * @param {string} workTypeId - Work type UUID
   * @param {Array} tags - Array of tag strings
   * @returns {Promise<Array>} Added tags
   */
  async addTags(workTypeId, tags) {
    const transaction = await sequelize.transaction({
      timeout: 30000 // 30 seconds timeout
    });

    try {
      const workType = await WorkType.findByPk(workTypeId, { transaction });

      if (!workType) {
        throw new NotFoundError(`Work type with ID ${workTypeId} not found`);
      }

      const results = [];

      for (const tag of tags) {
        // Skip empty tags
        if (!tag || typeof tag !== 'string' || tag.trim() === '') {
          continue;
        }

        // Normalize tag (lowercase, trim)
        const normalizedTag = tag.trim().toLowerCase();

        // Check if tag already exists for this work type
        const existingTag = await WorkTypeTag.findOne({
          where: {
            work_type_id: workTypeId,
            tag: normalizedTag
          },
          transaction
        });

        if (!existingTag) {
          // Create new tag
          const newTag = await WorkTypeTag.create({
            work_type_id: workTypeId,
            tag: normalizedTag
          }, { transaction });

          results.push(newTag);
        } else {
          results.push(existingTag);
        }
      }

      // Update work type revision
      await workType.update({
        revision: (workType.revision || 0) + 1
      }, { transaction });

      await transaction.commit();
      return results;
    } catch (error) {
      await transaction.rollback();
      logger.error(`Error adding tags to work type ${workTypeId}:`, error);
      throw error;
    }
  }

  /**
   * Remove a tag from a work type
   * @param {string} workTypeId - Work type UUID
   * @param {string} tag - Tag to remove
   * @returns {Promise<boolean>} Success status
   */
  async removeTag(workTypeId, tag) {
    const transaction = await sequelize.transaction({
      timeout: 30000 // 30 seconds timeout
    });

    try {
      const workType = await WorkType.findByPk(workTypeId, { transaction });

      if (!workType) {
        throw new NotFoundError(`Work type with ID ${workTypeId} not found`);
      }

      // Normalize tag (lowercase, trim)
      const normalizedTag = tag.trim().toLowerCase();

      const removedCount = await WorkTypeTag.destroy({
        where: {
          work_type_id: workTypeId,
          tag: normalizedTag
        },
        transaction
      });

      if (removedCount === 0) {
        throw new NotFoundError(`Tag "${tag}" not found for work type ${workTypeId}`);
      }

      // Update work type revision
      await workType.update({
        revision: (workType.revision || 0) + 1
      }, { transaction });

      await transaction.commit();
      return true;
    } catch (error) {
      await transaction.rollback();
      logger.error(`Error removing tag ${tag} from work type ${workTypeId}:`, error);
      throw error;
    }
  }

  /**
   * Helper method to log cost history
   * @private
   * @param {Object} params - Parameters for cost history
   * @param {string} params.workTypeId - Work type UUID
   * @param {string} params.region - Region for cost data
   * @param {number} params.unitCostMaterial - Material cost per unit
   * @param {number} params.unitCostLabor - Labor cost per unit
   * @param {string} params.userId - User ID making the update
   * @param {Object} transaction - Sequelize transaction
   * @returns {Promise<Object>} Created cost history record
   */
  async _logCostHistory(params, transaction) {
    try {
      const { workTypeId, region, unitCostMaterial, unitCostLabor, userId } = params;

      return await WorkTypeCostHistory.create({
        id: uuidv4(),
        work_type_id: workTypeId,
        region,
        unit_cost_material: unitCostMaterial,
        unit_cost_labor: unitCostLabor,
        captured_at: new Date(),
        updated_by: userId
      }, { transaction });
    } catch (error) {
      logger.error(`Error logging cost history for work type ${params.workTypeId}:`, error);
      throw error;
    }
  }

  /**
   * Get cost history for a work type
   * @param {string} workTypeId - Work type UUID
   * @param {string} region - Region to filter by (optional)
   * @param {number} limit - Maximum number of records to return
   * @returns {Promise<Array>} Cost history records
   */
  async getCostHistory(workTypeId, region = null, limit = 10) {
    try {
      const workType = await WorkType.findByPk(workTypeId);

      if (!workType) {
        throw new NotFoundError(`Work type with ID ${workTypeId} not found`);
      }

      const where = { work_type_id: workTypeId };

      if (region) {
        where.region = region;
      }

      const costHistory = await WorkTypeCostHistory.findAll({
        where,
        order: [['captured_at', 'DESC']],
        limit
      });

      return costHistory;
    } catch (error) {
      logger.error(`Error getting cost history for work type ${workTypeId}:`, error);
      throw error;
    }
  }

  /**
   * Delete a work type
   * @param {string} id - Work type UUID
   * @returns {Promise<boolean>} Success status
   */
  async deleteWorkType(id) {
    try {
      const workType = await WorkType.findByPk(id);

      if (!workType) {
        throw new NotFoundError(`Work type with ID ${id} not found`);
      }

      await workType.destroy();
      return true;
    } catch (error) {
      logger.error(`Error deleting work type ${id}:`, error);
      throw error;
    }
  }

  /**
   * Find similar work types by name using trigram similarity
   * @param {string} name - Work type name to search
   * @param {number} threshold - Similarity threshold (0-1)
   * @returns {Promise<Array>} Similar work types
   */
  async findSimilarWorkTypes(name, threshold = 0.3) {
    try {
      // Generate cache key
      const cacheKey = `similar:${name}:${threshold}`;

      // Check cache first
      const cachedResult = this.similarWorkTypesCache.get(cacheKey);
      if (cachedResult) {
        logger.debug(`Cache hit for similar work types to "${name}"`);
        return cachedResult;
      }

      logger.debug(`Cache miss for similar work types to "${name}", fetching from database`);

      const query = `
        SELECT id, name, parent_bucket, measurement_type, suggested_units,
               similarity(name, :name) AS score
        FROM work_types
        WHERE similarity(name, :name) > :threshold
        ORDER BY score DESC
        LIMIT 10
      `;

      const results = await sequelize.query(query, {
        replacements: { name, threshold },
        type: sequelize.QueryTypes.SELECT
      });

      // Cache the results
      this.similarWorkTypesCache.set(cacheKey, results);

      return results;
    } catch (error) {
      logger.error(`Error finding similar work types for "${name}":`, error);
      throw error;
    }
  }

  /**
   * Get tags grouped by frequency
   * @param {number} minCount - Minimum count to include a tag
   * @returns {Promise<Array>} Tags with count
   */
  async getTagsByFrequency(minCount = 1) {
    try {
      // Generate cache key
      const cacheKey = `tags:frequency:${minCount}`;

      // Check cache first
      const cachedResult = this.tagFrequencyCache.get(cacheKey);
      if (cachedResult) {
        logger.debug(`Cache hit for tags frequency with minCount=${minCount}`);
        return cachedResult;
      }

      logger.debug(`Cache miss for tags frequency with minCount=${minCount}, fetching from database`);

      const query = `
        SELECT tag, COUNT(*) as count
        FROM work_type_tags
        GROUP BY tag
        HAVING COUNT(*) >= :minCount
        ORDER BY count DESC
      `;

      const results = await sequelize.query(query, {
        replacements: { minCount },
        type: sequelize.QueryTypes.SELECT
      });

      // Cache the results
      this.tagFrequencyCache.set(cacheKey, results);

      return results;
    } catch (error) {
      logger.error('Error getting tags by frequency:', error);
      throw error;
    }
  }

  /**
   * Import work types from CSV data
   * @param {Array} workTypesData - Array of work type objects
   * @returns {Promise<Object>} Import results
   */
  async importWorkTypes(workTypesData) {
    try {
      const results = {
        created: 0,
        failed: 0,
        details: []
      };

      // Process each work type
      for (const data of workTypesData) {
        try {
          // Set UUID if not provided or replace placeholder
          if (!data.id || data.id.startsWith('<uuid')) {
            data.id = uuidv4();
          }

          // Clean up name to ensure consistent formatting
          if (data.name) {
            // Replace unicode narrow-no-break space (U+202F) with standard hyphen
            data.name = data.name.replace(/\u202F/g, '-');
          }

          await this.createWorkType(data);
          results.created++;
          results.details.push({
            name: data.name,
            status: 'success',
            id: data.id
          });
        } catch (error) {
          results.failed++;
          results.details.push({
            name: data.name,
            status: 'error',
            error: error.message
          });
          logger.error(`Error importing work type ${data.name}:`, error);
        }
      }

      return results;
    } catch (error) {
      logger.error('Error importing work types:', error);
      throw error;
    }
  }
}

module.exports = new WorkTypeService();
