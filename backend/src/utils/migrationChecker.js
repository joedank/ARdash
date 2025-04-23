'use strict';

const ViewManager = require('./viewManager');
const DependencyAnalyzer = require('./dependencyAnalyzer');
const viewDefinitions = require('../config/viewDefinitions');

/**
 * Performs pre-migration checks to identify potential issues
 */
class MigrationChecker {
  /**
   * Creates a new MigrationChecker
   * @param {Object} queryInterface - Sequelize queryInterface
   * @param {Object} options - Additional options
   */
  constructor(queryInterface, options = {}) {
    this.queryInterface = queryInterface;
    this.viewManager = new ViewManager(queryInterface, options);
    this.dependencyAnalyzer = new DependencyAnalyzer(queryInterface);
    this.logger = options.logger || console;
  }

  /**
   * Checks for issues before altering a column
   * @param {string} tableName - Table name
   * @param {string} columnName - Column name
   * @returns {Promise<Object>} - Issues found
   */
  async checkColumnAlteration(tableName, columnName) {
    const issues = {
      dependencies: [],
      viewsAffected: [],
      hasStoredViews: true,
      recommendations: []
    };
    
    // Check for dependencies
    const dependencies = await this.dependencyAnalyzer.getColumnDependencies(
      tableName, 
      columnName
    );
    
    issues.dependencies = dependencies;
    
    // Check for view dependencies specifically
    const viewDependencies = dependencies.filter(dep => dep.type === 'view');
    issues.viewsAffected = viewDependencies.map(dep => dep.name);
    
    // Check if we have stored definitions for affected views
    const missingViewDefinitions = issues.viewsAffected.filter(
      viewName => !viewDefinitions[viewName]
    );
    
    if (missingViewDefinitions.length > 0) {
      issues.hasStoredViews = false;
      issues.recommendations.push(
        `Add view definitions for: ${missingViewDefinitions.join(', ')}`
      );
    }
    
    // Add recommendations based on findings
    if (viewDependencies.length > 0) {
      issues.recommendations.push(
        'Use ViewManager.dropAndRecreateView to handle view dependencies'
      );
    }
    
    return issues;
  }
  
  /**
   * Generates migration code to handle column alteration with dependencies
   * @param {string} tableName - Table name
   * @param {string} columnName - Column name
   * @param {string} alterStatement - The SQL ALTER statement
   * @returns {Promise<string>} - Migration code
   */
  async generateMigrationCode(tableName, columnName, alterStatement) {
    const check = await this.checkColumnAlteration(tableName, columnName);
    let code = '';
    
    if (check.viewsAffected.length > 0) {
      code = `
'use strict';

const ViewManager = require('../utils/viewManager');
const viewDefinitions = require('../config/viewDefinitions');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    return queryInterface.sequelize.transaction(async (transaction) => {
      const viewManager = new ViewManager(queryInterface);
      
      // Drop dependent views
      ${check.viewsAffected.map(view => `
      await viewManager.dropAndRecreateView(
        '${view}', 
        'DROP VIEW IF EXISTS ${view};', 
        transaction
      );`).join('\n')}
      
      // Alter the column
      await queryInterface.sequelize.query(
        \`${alterStatement}\`,
        { transaction }
      );
      
      // Recreate views
      ${check.viewsAffected.map(view => `
      await viewManager.dropAndRecreateView(
        '${view}', 
        viewDefinitions.${view}, 
        transaction
      );`).join('\n')}
    });
  },
  
  down: async (queryInterface, Sequelize) => {
    // Add rollback logic here
  }
};
      `;
    } else {
      code = `
'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    return queryInterface.sequelize.query(\`${alterStatement}\`);
  },
  
  down: async (queryInterface, Sequelize) => {
    // Add rollback logic here
  }
};
      `;
    }
    
    return code;
  }
}

module.exports = MigrationChecker;