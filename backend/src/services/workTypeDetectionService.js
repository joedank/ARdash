'use strict';

const { sequelize, WorkType } = require('../models');
const logger = require('../utils/logger');
const deepseekService = require('./deepseekService');

// Simple in-memory cache with TTL
class Cache {
  constructor(ttlMs = 600000) { // Default 10 minutes TTL
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
 * Service for detecting work types from text conditions
 */
class WorkTypeDetectionService {
  constructor() {
    // Initialize cache for text detection with 10-minute TTL
    this.detectionCache = new Cache(600000);
  }

  /**
   * Detect work types that match the given text condition
   * @param {string} text - The condition text to analyze
   * @returns {Promise<Array>} Matching work types with confidence scores
   */
  async detect(text) {
    try {
      if (!text || typeof text !== 'string' || text.trim().length < 10) {
        logger.warn('Text too short for work type detection:', text);
        return [];
      }

      // Generate hash for cache key
      const cacheKey = `detect:${this._hashText(text)}`;

      // Check cache first
      const cachedResult = this.detectionCache.get(cacheKey);
      if (cachedResult) {
        logger.debug(`Cache hit for work type detection: "${text.substring(0, 20)}..."`);
        return cachedResult;
      }

      logger.debug(`Cache miss for work type detection: "${text.substring(0, 20)}..."`);

      // Step 1 – trigram top-N
      const trigramQuery = `
        SELECT id, name, similarity(name, $1) AS score
        FROM work_types
        WHERE name % $1
        ORDER BY score DESC
        LIMIT 15;
      `;

      const [triResults] = await sequelize.query(trigramQuery, {
        bind: [text],
        type: sequelize.QueryTypes.SELECT,
        raw: true,
        nest: true
      });

      let results = Array.isArray(triResults) ? triResults : [];

      // Step 2 – embed & vector if tri scores < hard threshold
      // Only do vector similarity if trigram top result < 0.85
      const shouldUseVector =
        !results.length ||
        results.length === 0 ||
        !results[0].score ||
        results[0].score < 0.85;

      // Check if vector similarity is enabled in environment
      const isVectorEnabled = process.env.ENABLE_VECTOR_SIMILARITY === 'true';
      logger.debug(`Vector similarity enabled: ${isVectorEnabled}`);

      if (shouldUseVector && isVectorEnabled) {
        try {
          // Use DeepSeek service to generate embeddings
          const embed = await deepseekService.generateEmbedding(text);

          if (embed && Array.isArray(embed)) {
            // Vector similarity query
            // Use a safer query that works even if pgvector operator <=> is not available
            // When ENABLE_VECTOR_SIMILARITY is true, this assumes the pgvector extension is installed
            const vectorQuery = `
              SELECT id, name,
                CASE WHEN pg_typeof(name_vec) = 'text'::regtype
                  THEN similarity(name, $2) -- Fallback to trigram if name_vec is text
                  ELSE 1-(name_vec <=> $1) -- Use vector similarity if available
                END AS score
              FROM work_types
              WHERE name_vec IS NOT NULL
              ORDER BY score DESC
              LIMIT 10;
            `;

            const [vecResults] = await sequelize.query(vectorQuery, {
              bind: [embed, text], // Pass both the embedding and the text for fallback
              type: sequelize.QueryTypes.SELECT,
              raw: true,
              nest: true
            });

            // Combine results and remove duplicates
            if (Array.isArray(vecResults) && vecResults.length > 0) {
              results = this._combineResults(results, vecResults);
            }
          }
        } catch (vectorError) {
          logger.warn('Vector similarity failed, using trigram results only:', vectorError.message);
        }
      } else {
        logger.debug('Skipping vector similarity: either trigram score is high enough or vector similarity is disabled');
      }

      // Filter by minimum confidence and limit to top 5
      const filteredResults = results
        .filter(r => r.score > 0.60)
        .slice(0, 5)
        .map(r => ({
          workTypeId: r.id,
          name: r.name,
          score: parseFloat(r.score)
        }));

      // Cache the results
      this.detectionCache.set(cacheKey, filteredResults);

      return filteredResults;
    } catch (error) {
      logger.error(`Error detecting work types for text: "${text.substring(0, 20)}..."`, error);
      return [];
    }
  }

  /**
   * Simple hash function for text to create cache keys
   * @private
   * @param {string} text - Text to hash
   * @returns {string} Hash of the text
   */
  _hashText(text) {
    let hash = 0;
    if (text.length === 0) return hash.toString();

    for (let i = 0; i < text.length; i++) {
      const char = text.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }

    return hash.toString();
  }

  /**
   * Combine and deduplicate results from different similarity methods
   * @private
   * @param {Array} triResults - Results from trigram similarity
   * @param {Array} vecResults - Results from vector similarity
   * @returns {Array} Combined and deduplicated results
   */
  _combineResults(triResults, vecResults) {
    // Create a map to store deduplicated results
    const resultMap = new Map();

    // Add trigram results to the map
    if (Array.isArray(triResults)) {
      triResults.forEach(r => {
        if (r && r.id) {
          resultMap.set(r.id, r);
        }
      });
    }

    // Add vector results, keeping the higher score if duplicate
    if (Array.isArray(vecResults)) {
      vecResults.forEach(r => {
        if (r && r.id) {
          if (!resultMap.has(r.id) || r.score > resultMap.get(r.id).score) {
            resultMap.set(r.id, r);
          }
        }
      });
    }

    // Convert map back to array
    return Array.from(resultMap.values());
  }
}

module.exports = new WorkTypeDetectionService();
