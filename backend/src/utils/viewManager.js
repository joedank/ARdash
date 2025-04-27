'use strict';

/**
 * Utility class for managing database views during schema changes
 * Handles the dropping and recreation of views within transactions
 */
class ViewManager {
  /**
   * Create a ViewManager instance
   * @param {Object} queryInterface - Sequelize QueryInterface instance
   */
  constructor(queryInterface) {
    this.queryInterface = queryInterface;
  }

  /**
   * Drop and recreate a view within a transaction
   * @param {string} viewName - Name of the view to manage
   * @param {string} viewDefinition - SQL definition for recreating the view
   * @param {Object} transaction - Sequelize transaction object
   * @returns {Promise<boolean>} - Resolves to true on success
   */
  async dropAndRecreateView(viewName, viewDefinition, transaction) {
    // Drop the view if it exists
    await this.queryInterface.sequelize.query(
      `DROP VIEW IF EXISTS ${viewName};`,
      { transaction }
    );

    // Recreate the view with the provided definition
    await this.queryInterface.sequelize.query(
      viewDefinition,
      { transaction }
    );

    return true;
  }

  /**
   * Get dependent views for a table
   * @param {string} tableName - Name of the table to check for dependent views
   * @returns {Promise<Array<string>>} - Array of view names that depend on the table
   */
  async getDependentViews(tableName) {
    const query = `
      SELECT dependent_view.relname AS view_name
      FROM pg_depend
      JOIN pg_rewrite ON pg_depend.objid = pg_rewrite.oid
      JOIN pg_class as dependent_view ON pg_rewrite.ev_class = dependent_view.oid
      JOIN pg_class as source_table ON pg_depend.refobjid = source_table.oid
      WHERE source_table.relname = '${tableName}'
      AND dependent_view.relkind = 'v'
      GROUP BY dependent_view.relname;
    `;

    const result = await this.queryInterface.sequelize.query(
      query,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );

    return result.map(row => row.view_name);
  }

  /**
   * Get the definition of a view
   * @param {string} viewName - Name of the view
   * @returns {Promise<string>} - SQL definition of the view
   */
  async getViewDefinition(viewName) {
    const query = `
      SELECT pg_get_viewdef('${viewName}', true) AS view_definition;
    `;

    const result = await this.queryInterface.sequelize.query(
      query,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );

    return result[0]?.view_definition || null;
  }

  /**
   * Get dependent views for a specific column
   * @param {string} tableName - Name of the table
   * @param {string} columnName - Name of the column
   * @returns {Promise<Array<string>>} - Array of view names that depend on the column
   */
  async getDependentViewsForColumn(tableName, columnName) {
    const query = `
      SELECT dependent_view.relname AS view_name
      FROM pg_depend
      JOIN pg_rewrite ON pg_depend.objid = pg_rewrite.oid
      JOIN pg_class as dependent_view ON pg_rewrite.ev_class = dependent_view.oid
      JOIN pg_class as source_table ON pg_depend.refobjid = source_table.oid
      JOIN pg_attribute as source_attr ON 
        pg_depend.refobjid = source_attr.attrelid AND 
        pg_depend.refobjsubid = source_attr.attnum
      WHERE source_table.relname = '${tableName}'
      AND source_attr.attname = '${columnName}'
      AND dependent_view.relkind = 'v'
      GROUP BY dependent_view.relname;
    `;

    const result = await this.queryInterface.sequelize.query(
      query,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );

    return result.map(row => row.view_name);
  }

  /**
   * Check if modifying a column would affect any views
   * @param {string} tableName - Name of the table
   * @param {string} columnName - Name of the column
   * @returns {Promise<boolean>} - True if views depend on this column
   */
  async checkColumnUsedInViews(tableName, columnName) {
    const views = await this.getDependentViewsForColumn(tableName, columnName);
    return views.length > 0;
  }

  /**
   * Safely alter a column type by handling dependent views
   * @param {string} tableName - Name of the table
   * @param {string} columnName - Name of the column
   * @param {string} newType - New column type (e.g., 'VARCHAR(255)')
   * @param {Object} transaction - Sequelize transaction object
   * @returns {Promise<boolean>} - Resolves to true on success
   */
  async safelyAlterColumnType(tableName, columnName, newType, transaction) {
    // Get dependent views for this column
    const viewNames = await this.getDependentViewsForColumn(tableName, columnName);
    
    // Store view definitions for recreation
    const viewDefs = {};
    for (const viewName of viewNames) {
      viewDefs[viewName] = await this.getViewDefinition(viewName);
    }
    
    // Drop all dependent views
    for (const viewName of viewNames) {
      await this.queryInterface.sequelize.query(
        `DROP VIEW IF EXISTS ${viewName};`,
        { transaction }
      );
    }
    
    // Alter the column type
    await this.queryInterface.sequelize.query(
      `ALTER TABLE "${tableName}" ALTER COLUMN "${columnName}" TYPE ${newType};`,
      { transaction }
    );
    
    // Recreate all views in reverse order (to handle dependencies between views)
    for (const viewName of [...viewNames].reverse()) {
      await this.queryInterface.sequelize.query(
        viewDefs[viewName],
        { transaction }
      );
    }
    
    return true;
  }
}

module.exports = ViewManager;
