'use strict';

const { sequelize, WorkType } = require('../models');
const logger = require('../utils/logger');
const embeddingProvider = require('./embeddingProvider');
const { caching } = require('cache-manager');
const redisStore = require('cache-manager-ioredis-yet');

// Initialize Redis cache with TTL
const initializeCache = async (ttlSeconds = 600) => {
  try {
    return caching({
      store: redisStore,
      url: process.env.REDIS_URL || 'redis://localhost:6379',
      ttl: ttlSeconds
    });
  } catch (error) {
    logger.error(`Error initializing Redis cache: ${error.message}`, { error });
    // Fallback to memory cache if Redis initialization fails
    logger.warn('Falling back to memory cache');
    return caching({
      store: 'memory',
      max: 500,
      ttl: ttlSeconds * 1000
    });
  }
};

/**
 * Service for detecting work types from text conditions
 */
class WorkTypeDetectionService {
  constructor() {
    // Initialize cache for text detection with 10-minute TTL
    this.detectionCache = null;
    this.cacheReady = false;
    this.initializeCache();
  }
  
  async initializeCache() {
    try {
      this.detectionCache = await initializeCache(600);
      this.cacheReady = true;
      logger.info('Detection cache initialized successfully');
    } catch (error) {
      logger.error(`Failed to initialize detection cache: ${error.message}`, { error });
    }
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

      // Check cache first (if ready)
      if (this.cacheReady) {
        try {
          const cachedResult = await this.detectionCache.get(cacheKey);
          if (cachedResult) {
            logger.debug(`Cache hit for work type detection: "${text.substring(0, 20)}..."`);
            return cachedResult;
          }
        } catch (cacheError) {
          logger.warn(`Cache error when getting key ${cacheKey}: ${cacheError.message}`);
          // Continue execution even if cache fails
        }
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

      // Check if vector similarity is enabled
      const isVectorEnabled = await embeddingProvider.isEnabled();
      logger.debug(`Vector similarity enabled: ${isVectorEnabled}`);

      if (shouldUseVector && isVectorEnabled) {
        try {
          // Use embedding queue to generate embeddings
          const embedQueue = require('../queues/embedQueue');
          const job = await embedQueue.add('embed', { text });
          const jobId = job.id;
          const { vector: vec } = await embedQueue.waitUntilFinished(jobId);

          if (!vec) {
            logger.warn('Embedding provider returned null vector');
            return;
          }

          // Accept plain arrays *or* typed arrays
          if (!Array.isArray(vec)) {
            if (ArrayBuffer.isView(vec)) vec = Array.from(vec);
            else { logger.warn(`Embedding is not iterable: ${typeof vec}`); return; }
          }

          if (vec.length === 0) {
            logger.warn('Embedding array is empty');
            return;
          }

          // Convert JavaScript array to pgvector literal string format with reduced precision (4 dp is enough)
          const vecLiteral = '[' + vec.map(v => Number(v.toFixed(4))).join(',') + ']';

          logger.debug(`Generated vector literal for similarity search (${vec.length} dimensions)`);

          // Declare in outer scope so we can access it after the SQL call
          let vecResults = [];

          try {
            // Vector similarity query
            // Use a safer query that works even if pgvector operator <=> is not available
            // When ENABLE_VECTOR_SIMILARITY is true, this assumes the pgvector extension is installed
            const vectorQuery = `
              SELECT id, name, 1 - (name_vec <=> $1::vector) AS score
              FROM work_types
              WHERE name_vec IS NOT NULL
              ORDER BY score DESC
              LIMIT 10;
            `;

            logger.debug(`Executing vector query with literal: ${vecLiteral.substring(0, 50)}...`);

            vecResults = await sequelize.query(vectorQuery, {
              bind: [vecLiteral], // Pass only the vector as string literal with proper casting
              type: sequelize.QueryTypes.SELECT,
              raw: true
            });

            // Log the number of results for debugging
            logger.debug(`Vector similarity rows returned: ${vecResults ? vecResults.length : 0}`);
          } catch (sqlError) {
            logger.error(`SQL error in vector similarity: ${sqlError.message}`, sqlError);
            throw sqlError;
          }

          // Combine results and remove duplicates
          if (Array.isArray(vecResults) && vecResults.length > 0) {
            results = this._combineResults(results, vecResults);
          }
        } catch (vectorError) {
          logger.warn('Vector similarity failed, using trigram results only:', vectorError.message);
        }
      } else {
        logger.debug('Skipping vector similarity: either trigram score is high enough or vector similarity is disabled');
      }

      // Filter by minimum confidence and limit to top 5
      const filteredResults = results
        .filter(r => r.score !== null && r.score > 0.60)
        .slice(0, 5)
        .map(r => ({
          workTypeId: r.id,
          name: r.name,
          score: parseFloat(r.score)
        }));

      // Cache the results (if cache is ready)
      if (this.cacheReady) {
        try {
          await this.detectionCache.set(cacheKey, filteredResults);
          logger.debug(`Cached results for key: ${cacheKey}`);
        } catch (cacheError) {
          logger.warn(`Cache error when setting key ${cacheKey}: ${cacheError.message}`);
          // Continue even if caching fails
        }
      }

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
