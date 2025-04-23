'use strict';

/**
 * Compares Sequelize models to actual database schema
 */
class ModelSchemaComparer {
  /**
   * Creates a new ModelSchemaComparer
   * @param {Object} queryInterface - Sequelize queryInterface
   * @param {Object} models - Sequelize models
   */
  constructor(queryInterface, models) {
    this.queryInterface = queryInterface;
    this.models = models;
    this.sequelize = queryInterface.sequelize;
  }

  /**
   * Compares models to actual database schema
   * @returns {Promise<Object>} - Comparison results
   */
  async compareAll() {
    const results = {
      matches: [],
      mismatches: [],
      modelsMissingTable: [],
      tablesWithoutModel: []
    };
    
    // Get all models
    const modelNames = Object.keys(this.models).filter(key => {
      const model = this.models[key];
      return model.prototype && model.prototype.constructor.name !== 'SequelizeMeta';
    });
    
    // Get all tables
    const tablesResult = await this.queryInterface.sequelize.query(
      `SELECT table_name FROM information_schema.tables 
       WHERE table_schema = 'public' AND table_type = 'BASE TABLE';`,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
    
    const tables = tablesResult.map(t => t.table_name);
    
    // Find tables without models
    for (const table of tables) {
      const matchingModel = modelNames.find(model => {
        const tableName = this.models[model].getTableName();
        return tableName === table;
      });
      
      if (!matchingModel) {
        results.tablesWithoutModel.push(table);
      }
    }
    
    // Compare each model to its table
    for (const modelName of modelNames) {
      const model = this.models[modelName];
      const tableName = model.getTableName();
      
      // Check if table exists
      if (!tables.includes(tableName)) {
        results.modelsMissingTable.push({
          model: modelName,
          tableName
        });
        continue;
      }
      
      // Compare columns
      const comparison = await this.compareModelToTable(model);
      
      if (comparison.mismatches.length === 0) {
        results.matches.push({
          model: modelName,
          tableName
        });
      } else {
        results.mismatches.push({
          model: modelName,
          tableName,
          mismatches: comparison.mismatches
        });
      }
    }
    
    return results;
  }

  /**
   * Compares a specific model to its table
   * @param {Object} model - Sequelize model
   * @returns {Promise<Object>} - Comparison results
   */
  async compareModelToTable(model) {
    const tableName = model.getTableName();
    const modelAttributes = model.getAttributes();
    
    // Get table columns from database
    const columnsResult = await this.queryInterface.sequelize.query(
      `SELECT column_name, data_type, is_nullable, column_default 
       FROM information_schema.columns 
       WHERE table_name = '${tableName}';`,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
    
    const results = {
      model: model.name,
      tableName,
      matches: [],
      mismatches: []
    };
    
    // Check each model attribute against table columns
    for (const [attrName, attrOptions] of Object.entries(modelAttributes)) {
      // Skip virtual fields
      if (attrOptions.type && attrOptions.type.key === 'VIRTUAL') {
        continue;
      }
      
      // Get the actual column name (accounting for field option)
      const columnName = attrOptions.field || attrName;
      
      // Find matching column in database
      const column = columnsResult.find(col => col.column_name === columnName);
      
      if (!column) {
        results.mismatches.push({
          field: attrName,
          issue: 'missing_in_db',
          modelType: attrOptions.type && attrOptions.type.key ? attrOptions.type.key : 'unknown'
        });
        continue;
      }
      
      // Compare types
      const typeMatch = this.compareTypes(attrOptions.type, column.data_type);
      
      if (!typeMatch.match) {
        results.mismatches.push({
          field: attrName,
          column: columnName,
          issue: 'type_mismatch',
          modelType: typeMatch.modelType,
          dbType: column.data_type
        });
        continue;
      }
      
      // Compare nullability
      const nullableInModel = attrOptions.allowNull !== false;
      const nullableInDb = column.is_nullable === 'YES';
      
      if (nullableInModel !== nullableInDb) {
        results.mismatches.push({
          field: attrName,
          column: columnName,
          issue: 'nullable_mismatch',
          modelNullable: nullableInModel,
          dbNullable: nullableInDb
        });
        continue;
      }
      
      // Match found
      results.matches.push({
        field: attrName,
        column: columnName,
        type: {
          model: typeMatch.modelType,
          db: column.data_type
        }
      });
    }
    
    // Check for columns in DB but missing in model
    for (const column of columnsResult) {
      const exists = Object.entries(modelAttributes).some(([attrName, attrOptions]) => {
        const columnName = attrOptions.field || attrName;
        return columnName === column.column_name;
      });
      
      if (!exists) {
        results.mismatches.push({
          column: column.column_name,
          issue: 'missing_in_model',
          dbType: column.data_type
        });
      }
    }
    
    return results;
  }

  /**
   * Compares Sequelize type to PostgreSQL type
   * @param {Object} sequelizeType - Sequelize type object
   * @param {string} dbType - PostgreSQL data type
   * @returns {Object} - Comparison result
   */
  compareTypes(sequelizeType, dbType) {
    if (!sequelizeType || !sequelizeType.key) {
      return { match: false, modelType: 'unknown' };
    }
    
    const modelType = sequelizeType.key;
    
    // Type mapping from Sequelize to PostgreSQL
    const typeMap = {
      'STRING': ['character varying', 'varchar', 'text'],
      'TEXT': ['text'],
      'INTEGER': ['integer', 'int4'],
      'BIGINT': ['bigint', 'int8'],
      'FLOAT': ['double precision', 'float8'],
      'REAL': ['real', 'float4'],
      'DOUBLE': ['double precision'],
      'DECIMAL': ['numeric', 'decimal'],
      'DATE': ['timestamp with time zone', 'timestamptz'],
      'DATEONLY': ['date'],
      'BOOLEAN': ['boolean'],
      'UUID': ['uuid'],
      'JSONB': ['jsonb'],
      'JSON': ['json'],
      'BLOB': ['bytea'],
      'ARRAY': dbType.startsWith('ARRAY'),
      'ENUM': ['USER-DEFINED', 'character varying']
    };
    
    // Check if db type matches the expected type
    const match = typeMap[modelType] && typeMap[modelType].includes(dbType.toLowerCase());
    
    return { match, modelType };
  }
}

module.exports = ModelSchemaComparer;