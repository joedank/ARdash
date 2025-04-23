'use strict';

/**
 * Manages database views during migrations and schema changes
 */
class ViewManager {
  /**
   * Creates a new ViewManager instance
   * @param {Object} queryInterface - Sequelize queryInterface
   * @param {Object} [options] - Additional options
   */
  constructor(queryInterface, options = {}) {
    this.queryInterface = queryInterface;
    this.options = options;
    this.logger = options.logger || console;
  }

  /**
   * Drops and recreates a view within a transaction
   * @param {string} viewName - Name of the view to manage
   * @param {string} viewDefinition - SQL definition of the view
   * @param {Object} [transaction] - Optional transaction object
   * @returns {Promise<boolean>} - Success status
   */
  async dropAndRecreateView(viewName, viewDefinition, transaction) {
    const t = transaction || await this.queryInterface.sequelize.transaction();
    const managedTransaction = !transaction;
    
    try {
      // Drop the view if it exists
      await this.queryInterface.sequelize.query(
        `DROP VIEW IF EXISTS ${viewName};`, 
        { transaction: t }
      );
      
      // Recreate the view with the provided definition
      await this.queryInterface.sequelize.query(
        viewDefinition, 
        { transaction: t }
      );
      
      // Commit transaction if we created it
      if (managedTransaction) {
        await t.commit();
      }
      
      this.logger.info(`Successfully dropped and recreated view: ${viewName}`);
      return true;
    } catch (error) {
      // Rollback transaction if we created it
      if (managedTransaction) {
        await t.rollback();
      }
      
      this.logger.error(`Failed to manage view ${viewName}: ${error.message}`);
      throw error;
    }
  }

  /**
   * Retrieves the definition of an existing view
   * @param {string} viewName - Name of the view
   * @returns {Promise<string>} - SQL definition of the view
   */
  async getViewDefinition(viewName) {
    const result = await this.queryInterface.sequelize.query(
      `SELECT pg_get_viewdef('${viewName}', true) AS definition;`,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
    
    if (result && result.length > 0) {
      return result[0].definition;
    }
    
    throw new Error(`View ${viewName} not found`);
  }

  /**
   * Gets all views that depend on a specific table
   * @param {string} tableName - Table name to check dependencies for
   * @returns {Promise<Array>} - List of dependent view names
   */
  async getDependentViews(tableName) {
    const query = `
      SELECT dependent_view.relname AS view_name
      FROM pg_depend 
      JOIN pg_rewrite ON pg_depend.objid = pg_rewrite.oid 
      JOIN pg_class as dependent_view ON pg_rewrite.ev_class = dependent_view.oid 
      JOIN pg_class as source_table ON pg_depend.refobjid = source_table.oid 
      JOIN pg_namespace ON source_table.relnamespace = pg_namespace.oid 
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
}

module.exports = ViewManager;