const { Product } = require('../models');
const { Op } = require('sequelize');
const logger = require('../utils/logger');
const deepSeekService = require('../services/deepseekService');

/**
 * Service for catalog management with similarity matching capabilities
 * Uses pg_trgm and pgvector extensions for efficient similarity matching
 */
class CatalogService {
  /**
   * Constructor
   * @param {Object} sequelize - Sequelize instance for direct query execution
   */
  constructor(sequelize) {
    this.sequelize = sequelize || (Product && Product.sequelize);
  }

  /**
   * Find products by name similarity using pg_trgm extension
   * @param {string} name - The product name to find similar matches for
   * @param {number} limit - Maximum number of results to return (default: 5)
   * @param {number} threshold - Minimum similarity score (0-1) to include in results (default: 0.3)
   * @returns {Promise<Array>} - Array of matching products with similarity scores
   */
  async findByTrgm(name, limit = 5, threshold = 0.3) {
    try {
      logger.debug(`Finding similar products to "${name}" using trigram matching`);

      const [rows] = await this.sequelize.query(`
        SELECT id, name, similarity(name, $1) AS score
        FROM products
        WHERE name %% $1
          AND type = 'service'
          AND deleted_at IS NULL
          AND similarity(name, $1) > $2
        ORDER BY score DESC
        LIMIT $3;
      `, {
        bind: [name, threshold, limit],
        type: this.sequelize.QueryTypes.SELECT
      });

      logger.debug(`Found ${rows.length} similar products using trigram matching`);
      return rows;
    } catch (error) {
      logger.error(`Error finding products by trigram similarity: ${error.message}`, error);
      // If the pg_trgm extension isn't available, fall back to basic string matching
      if (error.message.includes('operator does not exist: text %% text')) {
        logger.warn('pg_trgm extension not available, falling back to basic string matching');
        return this.fallbackSimilaritySearch(name, limit, threshold);
      }
      throw error;
    }
  }

  /**
   * Find products by vector similarity using pgvector extension
   * @param {Array<number>} embedding - The vector embedding to compare against
   * @param {number} limit - Maximum number of results to return (default: 5)
   * @returns {Promise<Array>} - Array of matching products with similarity scores
   */
  async findByVector(embedding, limit = 5) {
    try {
      logger.debug('Finding similar products using vector similarity');

      // Check if embedding column exists
      const [hasColumn] = await this.sequelize.query(`
        SELECT EXISTS (
          SELECT FROM information_schema.columns
          WHERE table_name='products' AND column_name='embedding'
        );
      `);

      if (!hasColumn[0].exists) {
        logger.warn('embedding column does not exist in products table, skipping vector search');
        return [];
      }

      const [rows] = await this.sequelize.query(`
        SELECT id, name, 1 - (embedding <=> $1::vector) AS score
        FROM products
        WHERE deleted_at IS NULL
          AND type = 'service'
          AND embedding IS NOT NULL
        ORDER BY embedding <=> $1::vector
        LIMIT $2;
      `, {
        bind: [JSON.stringify(embedding), limit],
        type: this.sequelize.QueryTypes.SELECT
      });

      logger.debug(`Found ${rows.length} similar products using vector similarity`);
      return rows;
    } catch (error) {
      logger.error(`Error finding products by vector similarity: ${error.message}`, error);
      // If the pgvector extension isn't available, return empty result
      if (error.message.includes('operator does not exist: vector <=> vector')) {
        logger.warn('pgvector extension not available, skipping vector search');
        return [];
      }
      throw error;
    }
  }

  /**
   * Generate an embedding for a text string using the DeepSeek API (OpenAI compatible)
   * @param {string} text - The text to generate an embedding for
   * @returns {Promise<Array<number>>} - The embedding vector
   */
  async generateEmbedding(text) {
    try {
      const embeddingModel = process.env.EMBEDDING_MODEL || 'embedding-2';
      logger.debug(`Generating embedding for text using DeepSeek with model ${embeddingModel}`);
      
      // Use DeepSeek's OpenAI-compatible API
      const response = await deepSeekService.client.embeddings.create({
        model: embeddingModel,
        input: text,
      });

      if (response.data && response.data.length > 0) {
        logger.debug('Successfully generated embedding');
        return response.data[0].embedding;
      } else {
        logger.warn('Unexpected response structure from DeepSeek API');
        return null;
      }
    } catch (error) {
      logger.error(`Error generating embedding: ${error.message}`, error);
      return null;
    }
  }

  /**
   * Generate and store embedding for a product
   * @param {string} productId - The ID of the product to update
   * @param {string} name - The product name to generate embedding for
   * @returns {Promise<boolean>} - Success indicator
   */
  async generateAndStoreEmbedding(productId, name) {
    try {
      logger.debug(`Generating and storing embedding for product ${productId}`);
      
      // Generate embedding
      const embedding = await this.generateEmbedding(name);
      
      if (!embedding) {
        logger.warn(`Could not generate embedding for product ${productId}`);
        return false;
      }
      
      // Store embedding in database
      await this.sequelize.query(`
        UPDATE products
        SET embedding = $1::vector
        WHERE id = $2;
      `, {
        bind: [JSON.stringify(embedding), productId],
        type: this.sequelize.QueryTypes.UPDATE
      });
      
      logger.debug(`Successfully stored embedding for product ${productId}`);
      return true;
    } catch (error) {
      logger.error(`Error storing embedding for product ${productId}: ${error.message}`, error);
      return false;
    }
  }

  /**
   * Fallback method for similarity matching when pg_trgm is not available
   * Uses basic JavaScript string comparison
   * @param {string} name - The product name to find similar matches for
   * @param {number} limit - Maximum number of results to return
   * @param {number} threshold - Minimum similarity score to include in results
   * @returns {Promise<Array>} - Array of matching products with similarity scores
   */
  async fallbackSimilaritySearch(name, limit, threshold) {
    logger.debug('Using fallback similarity search method');

    // Get all active service products
    const products = await Product.findAll({
      where: {
        type: 'service',
        deleted_at: null
      },
      raw: true
    });

    // Calculate similarity using Levenshtein distance
    const results = products.map(product => {
      const score = this.calculateStringSimilarity(name.toLowerCase(), product.name.toLowerCase());
      return { ...product, score };
    })
    .filter(product => product.score >= threshold)
    .sort((a, b) => b.score - a.score)
    .slice(0, limit);

    logger.debug(`Found ${results.length} similar products using fallback method`);
    return results;
  }

  /**
   * Calculate string similarity score between two strings (0-1)
   * @param {string} str1 - First string to compare
   * @param {string} str2 - Second string to compare
   * @returns {number} - Similarity score between 0 and 1
   */
  calculateStringSimilarity(str1, str2) {
    if (str1 === str2) return 1.0;
    if (str1.length === 0 || str2.length === 0) return 0.0;

    // Calculate Levenshtein distance
    const len1 = str1.length;
    const len2 = str2.length;
    const matrix = Array(len1 + 1).fill().map(() => Array(len2 + 1).fill(0));

    for (let i = 0; i <= len1; i++) matrix[i][0] = i;
    for (let j = 0; j <= len2; j++) matrix[0][j] = j;

    for (let i = 1; i <= len1; i++) {
      for (let j = 1; j <= len2; j++) {
        const cost = str1[i - 1] === str2[j - 1] ? 0 : 1;
        matrix[i][j] = Math.min(
          matrix[i - 1][j] + 1,     // deletion
          matrix[i][j - 1] + 1,     // insertion
          matrix[i - 1][j - 1] + cost // substitution
        );
      }
    }

    // Convert distance to similarity score (0-1)
    const maxLen = Math.max(len1, len2);
    return 1 - (matrix[len1][len2] / maxLen);
  }

  /**
   * Upsert or match a draft item with the catalog
   * @param {Object} draftItem - The draft item to match or create
   * @param {Object} options - Options for matching
   * @param {number} options.hard - Threshold for automatic matching (default: 0.85)
   * @param {number} options.soft - Threshold for suggesting matches (default: 0.60)
   * @returns {Promise<Object>} - Result object with kind (match, review, created) and product info
   */
  async upsertOrMatch(draftItem, { hard = 0.85, soft = 0.60 } = {}) {
    try {
      logger.debug(`Checking catalog for matches to "${draftItem.name}"`);

      // First try trigram matching
      const trgmHits = await this.findByTrgm(draftItem.name);

      // If we have a high confidence match, return it
      if (trgmHits.length > 0 && trgmHits[0].score >= hard) {
        logger.debug(`Found high confidence match (${trgmHits[0].score}) for "${draftItem.name}"`);
        return {
          kind: 'match',
          productId: trgmHits[0].id,
          score: trgmHits[0].score,
          matchedName: trgmHits[0].name
        };
      }

      // If we have medium confidence matches, suggest review
      if (trgmHits.length > 0 && trgmHits[0].score >= soft) {
        logger.debug(`Found medium confidence matches for "${draftItem.name}", suggesting review`);
        return {
          kind: 'review',
          matches: trgmHits
        };
      }

      // No good matches, create new product
      logger.debug(`No good matches found for "${draftItem.name}", creating new product`);

      const created = await Product.create({
        name: draftItem.name,
        price: draftItem.unitPrice,
        type: 'service',
        unit: this.getUnitFromMeasurementType(draftItem.measurementType)
      });

      // Generate and store embedding for the new product
      this.generateAndStoreEmbedding(created.id, created.name)
        .catch(err => logger.error(`Failed to generate embedding for new product ${created.id}: ${err.message}`));

      return {
        kind: 'created',
        productId: created.id,
        name: created.name,
        createdAt: created.created_at
      };
    } catch (error) {
      logger.error(`Error in upsertOrMatch: ${error.message}`, error);
      throw error;
    }
  }

  /**
   * Bulk create products from multiple draft items
   * @param {Array<Object>} draftItems - The draft items to create as products
   * @returns {Promise<Array>} - Array of created products
   */
  async bulkCreateProducts(draftItems) {
    try {
      logger.debug(`Bulk creating ${draftItems.length} products`);

      // Prepare product data from draft items
      const productsToCreate = draftItems.map(item => ({
        name: item.name,
        price: item.unitPrice || 0,
        type: 'service',
        unit: this.getUnitFromMeasurementType(item.measurementType)
      }));

      // Bulk create products
      const createdProducts = await Product.bulkCreate(productsToCreate);
      
      // Generate embeddings for all new products
      for (const product of createdProducts) {
        this.generateAndStoreEmbedding(product.id, product.name)
          .catch(err => logger.error(`Failed to generate embedding for new product ${product.id}: ${err.message}`));
      }

      logger.debug(`Successfully created ${createdProducts.length} products`);
      return createdProducts;
    } catch (error) {
      logger.error(`Error in bulkCreateProducts: ${error.message}`, error);
      throw error;
    }
  }

  /**
   * Get the appropriate unit based on measurement type
   * @param {string} measurementType - The measurement type (AREA, LINEAR, QUANTITY)
   * @returns {string} - The appropriate unit
   */
  getUnitFromMeasurementType(measurementType) {
    switch (measurementType) {
      case 'AREA': return 'sq ft';
      case 'LINEAR': return 'ln ft';
      case 'QUANTITY': return 'each';
      default: return 'each';
    }
  }
}

module.exports = { CatalogService, default: new CatalogService() };