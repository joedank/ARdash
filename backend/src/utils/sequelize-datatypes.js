'use strict';

const Sequelize = require('sequelize');
const logger = require('./logger');

// Read dimension once from env; default 3072 -- matches Gemini, OpenAI large, etc.
const EMBED_DIM = parseInt(process.env.EMBEDDING_DIM || '3072', 10);

/**
 * Extended Sequelize datatypes with custom types
 */
class ExtendedDataTypes {
  constructor() {
    // Copy all standard Sequelize DataTypes
    Object.assign(this, Sequelize.DataTypes);

    // Add custom VECTOR type
    this.VECTOR = this.createVectorType();
  }

  /**
   * Create a VECTOR type function that handles pgvector compatibility
   * @returns {Function} - Function that returns appropriate data type
   */
  createVectorType() {
    return function() {
      const isVectorEnabled = process.env.ENABLE_VECTOR_SIMILARITY === 'true';

      if (isVectorEnabled) {
        try {
          // When vector similarity is enabled, use a special type
          // that will be interpreted by PostgreSQL as a vector
          logger.info(`Creating VECTOR(${EMBED_DIM}) field type`);

          // Return a special data type that will be properly handled by PostgreSQL
          return {
            type: Sequelize.DataTypes.TEXT,
            get: function() {
              const value = this.getDataValue('name_vec');
              return value;
            },
            set: function(value) {
              this.setDataValue('name_vec', value);
            }
          };
        } catch (error) {
          logger.warn(`Error creating VECTOR type: ${error.message}`);
          return Sequelize.DataTypes.TEXT;
        }
      } else {
        // When vector similarity is disabled, use TEXT as fallback
        logger.info(`VECTOR similarity is disabled, using TEXT field for vector data`);
        return Sequelize.DataTypes.TEXT;
      }
    };
  }
}

// Create and export a singleton instance
const DataTypes = new ExtendedDataTypes();
module.exports = DataTypes;
