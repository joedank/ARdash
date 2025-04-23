'use strict';

const fs = require('fs');
const path = require('path');
const ModelSchemaComparer = require('./modelSchemaComparer');

/**
 * Tools for synchronizing Sequelize models with database schema
 */
class ModelSyncTool {
  /**
   * Creates a new ModelSyncTool
   * @param {Object} queryInterface - Sequelize queryInterface
   * @param {Object} models - Sequelize models
   * @param {Object} options - Additional options
   */
  constructor(queryInterface, models, options = {}) {
    this.queryInterface = queryInterface;
    this.models = models;
    this.migrationPath = options.migrationPath || path.join(process.cwd(), 'src', 'migrations');
    this.comparer = new ModelSchemaComparer(queryInterface, models);
    this.logger = options.logger || console;
  }

  /**
   * Generates migration file for fixing model-database mismatches
   * @returns {Promise<Object>} - Result with created migrations
   */
  async generateFixMigration() {
    // Get comparison results
    const comparison = await this.comparer.compareAll();
    
    if (comparison.mismatches.length === 0) {
      this.logger.info('No mismatches found. Database schema matches models.');
      return { created: false, message: 'No mismatches found' };
    }
    
    // Prepare timestamp for migration file
    const timestamp = new Date().toISOString().replace(/[-T:.Z]/g, '').substring(0, 14);
    const fileName = `${timestamp}-fix-model-schema-mismatches.js`;
    const filePath = path.join(this.migrationPath, fileName);
    
    // Generate migration content
    let migrationContent = `'use strict';\n\n`;
    migrationContent += `// Fix mismatches between models and database schema\n`;
    migrationContent += `// Generated on ${new Date().toISOString()}\n\n`;
    
    migrationContent += `const ViewManager = require('../utils/viewManager');\n`;
    migrationContent += `const viewDefinitions = require('../config/viewDefinitions');\n\n`;
    
    migrationContent += `module.exports = {\n`;
    migrationContent += `  up: async (queryInterface, Sequelize) => {\n`;
    migrationContent += `    return queryInterface.sequelize.transaction(async (transaction) => {\n`;
    migrationContent += `      const viewManager = new ViewManager(queryInterface);\n\n`;
    
    // Process each table with mismatches
    for (const mismatch of comparison.mismatches) {
      migrationContent += `      // Fix mismatches for ${mismatch.model} (${mismatch.tableName})\n`;
      
      // Check for dependent views first
      migrationContent += `      // Drop dependent views\n`;
      migrationContent += `      const dependentViews = await viewManager.getDependentViews('${mismatch.tableName}');\n`;
      migrationContent += `      for (const viewName of dependentViews) {\n`;
      migrationContent += `        if (viewDefinitions[viewName]) {\n`;
      migrationContent += `          await viewManager.dropAndRecreateView(\n`;
      migrationContent += `            viewName,\n`;
      migrationContent += `            'DROP VIEW IF EXISTS ' + viewName + ';',\n`;
      migrationContent += `            transaction\n`;
      migrationContent += `          );\n`;
      migrationContent += `        } else {\n`;
      migrationContent += `          // Store current view definition for later recreation\n`;
      migrationContent += `          const viewDef = await viewManager.getViewDefinition(viewName);\n`;
      migrationContent += `          await viewManager.dropAndRecreateView(\n`;
      migrationContent += `            viewName,\n`;
      migrationContent += `            'DROP VIEW IF EXISTS ' + viewName + ';',\n`;
      migrationContent += `            transaction\n`;
      migrationContent += `          );\n`;
      migrationContent += `          // Add to temporary viewDefinitions\n`;
      migrationContent += `          viewDefinitions[viewName] = 'CREATE OR REPLACE VIEW ' + viewName + ' AS ' + viewDef;\n`;
      migrationContent += `        }\n`;
      migrationContent += `      }\n\n`;
      
      // Process individual mismatches
      for (const issue of mismatch.mismatches) {
        if (issue.issue === 'type_mismatch') {
          migrationContent += `      // Change type of ${issue.column} from ${issue.dbType} to ${issue.modelType}\n`;
          migrationContent += `      await queryInterface.sequelize.query(\n`;
          migrationContent += `        'ALTER TABLE "${mismatch.tableName}" ALTER COLUMN "${issue.column}" TYPE ${this.mapTypeToPostgres(issue.modelType)};',\n`;
          migrationContent += `        { transaction }\n`;
          migrationContent += `      );\n\n`;
        } 
        else if (issue.issue === 'nullable_mismatch') {
          if (issue.modelNullable) {
            migrationContent += `      // Make ${issue.column} nullable\n`;
            migrationContent += `      await queryInterface.sequelize.query(\n`;
            migrationContent += `        'ALTER TABLE "${mismatch.tableName}" ALTER COLUMN "${issue.column}" DROP NOT NULL;',\n`;
            migrationContent += `        { transaction }\n`;
            migrationContent += `      );\n\n`;
          } else {
            migrationContent += `      // Make ${issue.column} not nullable\n`;
            migrationContent += `      await queryInterface.sequelize.query(\n`;
            migrationContent += `        'ALTER TABLE "${mismatch.tableName}" ALTER COLUMN "${issue.column}" SET NOT NULL;',\n`;
            migrationContent += `        { transaction }\n`;
            migrationContent += `      );\n\n`;
          }
        }
        else if (issue.issue === 'missing_in_db') {
          migrationContent += `      // Add missing column ${issue.field}\n`;
          migrationContent += `      await queryInterface.sequelize.query(\n`;
          migrationContent += `        'ALTER TABLE "${mismatch.tableName}" ADD COLUMN "${issue.field}" ${this.mapTypeToPostgres(issue.modelType)};',\n`;
          migrationContent += `        { transaction }\n`;
          migrationContent += `      );\n\n`;
        }
        // Skip missing_in_model issues as they shouldn't be fixed automatically
      }
      
      // Recreate views
      migrationContent += `      // Recreate dependent views\n`;
      migrationContent += `      for (const viewName of dependentViews) {\n`;
      migrationContent += `        if (viewDefinitions[viewName]) {\n`;
      migrationContent += `          await viewManager.dropAndRecreateView(\n`;
      migrationContent += `            viewName,\n`;
      migrationContent += `            viewDefinitions[viewName],\n`;
      migrationContent += `            transaction\n`;
      migrationContent += `          );\n`;
      migrationContent += `        }\n`;
      migrationContent += `      }\n\n`;
    }
    
    migrationContent += `    });\n`;
    migrationContent += `  },\n\n`;
    
    // Generate down function (this should be customized manually)
    migrationContent += `  down: async (queryInterface, Sequelize) => {\n`;
    migrationContent += `    // WARNING: This is an auto-generated down function.\n`;
    migrationContent += `    // It attempts to reverse the changes, but may not be complete.\n`;
    migrationContent += `    // Please review and modify as needed.\n`;
    migrationContent += `    return queryInterface.sequelize.transaction(async (transaction) => {\n`;
    migrationContent += `      const viewManager = new ViewManager(queryInterface);\n\n`;
    
    // Create basic rollback operations (reverse order)
    for (const mismatch of [...comparison.mismatches].reverse()) {
      migrationContent += `      // Revert changes for ${mismatch.model} (${mismatch.tableName})\n`;
      
      // Handle dependent views first
      migrationContent += `      // Drop dependent views\n`;
      migrationContent += `      const dependentViews = await viewManager.getDependentViews('${mismatch.tableName}');\n`;
      migrationContent += `      for (const viewName of dependentViews) {\n`;
      migrationContent += `        if (viewDefinitions[viewName]) {\n`;
      migrationContent += `          await viewManager.dropAndRecreateView(\n`;
      migrationContent += `            viewName,\n`;
      migrationContent += `            'DROP VIEW IF EXISTS ' + viewName + ';',\n`;
      migrationContent += `            transaction\n`;
      migrationContent += `          );\n`;
      migrationContent += `        }\n`;
      migrationContent += `      }\n\n`;
      
      // Process individual mismatches (reversed)
      for (const issue of [...mismatch.mismatches].reverse()) {
        if (issue.issue === 'type_mismatch') {
          migrationContent += `      // Revert type of ${issue.column} from ${issue.modelType} to ${issue.dbType}\n`;
          migrationContent += `      await queryInterface.sequelize.query(\n`;
          migrationContent += `        'ALTER TABLE "${mismatch.tableName}" ALTER COLUMN "${issue.column}" TYPE ${issue.dbType};',\n`;
          migrationContent += `        { transaction }\n`;
          migrationContent += `      );\n\n`;
        } 
        else if (issue.issue === 'nullable_mismatch') {
          if (!issue.modelNullable) {
            migrationContent += `      // Make ${issue.column} nullable again\n`;
            migrationContent += `      await queryInterface.sequelize.query(\n`;
            migrationContent += `        'ALTER TABLE "${mismatch.tableName}" ALTER COLUMN "${issue.column}" DROP NOT NULL;',\n`;
            migrationContent += `        { transaction }\n`;
            migrationContent += `      );\n\n`;
          } else {
            migrationContent += `      // Make ${issue.column} not nullable again\n`;
            migrationContent += `      await queryInterface.sequelize.query(\n`;
            migrationContent += `        'ALTER TABLE "${mismatch.tableName}" ALTER COLUMN "${issue.column}" SET NOT NULL;',\n`;
            migrationContent += `        { transaction }\n`;
            migrationContent += `      );\n\n`;
          }
        }
        else if (issue.issue === 'missing_in_db') {
          migrationContent += `      // Remove added column ${issue.field}\n`;
          migrationContent += `      await queryInterface.sequelize.query(\n`;
          migrationContent += `        'ALTER TABLE "${mismatch.tableName}" DROP COLUMN IF EXISTS "${issue.field}";',\n`;
          migrationContent += `        { transaction }\n`;
          migrationContent += `      );\n\n`;
        }
      }
      
      // Recreate views
      migrationContent += `      // Recreate dependent views\n`;
      migrationContent += `      for (const viewName of dependentViews) {\n`;
      migrationContent += `        if (viewDefinitions[viewName]) {\n`;
      migrationContent += `          await viewManager.dropAndRecreateView(\n`;
      migrationContent += `            viewName,\n`;
      migrationContent += `            viewDefinitions[viewName],\n`;
      migrationContent += `            transaction\n`;
      migrationContent += `          );\n`;
      migrationContent += `        }\n`;
      migrationContent += `      }\n\n`;
    }
    
    migrationContent += `    });\n`;
    migrationContent += `  }\n`;
    migrationContent += `};\n`;
    
    // Write migration file
    fs.writeFileSync(filePath, migrationContent);
    
    this.logger.info(`Generated migration file: ${filePath}`);
    
    return {
      created: true,
      path: filePath,
      mismatches: comparison.mismatches
    };
  }

  /**
   * Maps Sequelize type to PostgreSQL type
   * @param {string} sequelizeType - Sequelize type name
   * @returns {string} - PostgreSQL type
   */
  mapTypeToPostgres(sequelizeType) {
    const typeMap = {
      'STRING': 'VARCHAR(255)',
      'TEXT': 'TEXT',
      'INTEGER': 'INTEGER',
      'BIGINT': 'BIGINT',
      'FLOAT': 'DOUBLE PRECISION',
      'REAL': 'REAL',
      'DOUBLE': 'DOUBLE PRECISION',
      'DECIMAL': 'NUMERIC',
      'DATE': 'TIMESTAMP WITH TIME ZONE',
      'DATEONLY': 'DATE',
      'BOOLEAN': 'BOOLEAN',
      'UUID': 'UUID',
      'JSONB': 'JSONB',
      'JSON': 'JSON',
      'BLOB': 'BYTEA',
      'ARRAY': 'TEXT[]',
      'ENUM': 'VARCHAR(255)'
    };
    
    return typeMap[sequelizeType] || 'VARCHAR(255)';
  }
}

module.exports = ModelSyncTool;