'use strict';

/**
 * Analyzes database object dependencies
 */
class DependencyAnalyzer {
  /**
   * Creates a new DependencyAnalyzer
   * @param {Object} queryInterface - Sequelize queryInterface
   */
  constructor(queryInterface) {
    this.queryInterface = queryInterface;
  }

  /**
   * Gets all objects that depend on a table
   * @param {string} tableName - Table to check
   * @returns {Promise<Object>} - Dependencies by type
   */
  async getTableDependencies(tableName) {
    const query = `
      WITH deps AS (
        SELECT DISTINCT
          d.refobjid,
          n.nspname as schema_name,
          c.relname as referenced_table,
          c.relkind as referenced_type,
          d.objid,
          co.relname as dependent_object,
          co.relkind as dependent_type
        FROM pg_depend d
        JOIN pg_class c ON c.oid = d.refobjid
        JOIN pg_class co ON co.oid = d.objid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = '${tableName}'
        AND d.deptype = 'n'  -- normal dependency
        AND co.relkind IN ('r', 'v', 'i', 't')  -- table, view, index, trigger
      )
      SELECT
        dependent_object,
        dependent_type,
        referenced_table,
        referenced_type
      FROM deps
      ORDER BY dependent_type, dependent_object;
    `;
    
    const results = await this.queryInterface.sequelize.query(
      query,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
    
    // Group by type
    const dependencies = {
      views: [],
      tables: [],
      indexes: [],
      triggers: [],
      other: []
    };
    
    results.forEach(dep => {
      switch(dep.dependent_type) {
        case 'v': dependencies.views.push(dep.dependent_object); break;
        case 'r': dependencies.tables.push(dep.dependent_object); break;
        case 'i': dependencies.indexes.push(dep.dependent_object); break;
        case 't': dependencies.triggers.push(dep.dependent_object); break;
        default: dependencies.other.push(dep.dependent_object);
      }
    });
    
    return dependencies;
  }

  /**
   * Check if a column has any dependencies
   * @param {string} tableName - Table name
   * @param {string} columnName - Column name
   * @returns {Promise<Array>} - List of dependent objects
   */
  async getColumnDependencies(tableName, columnName) {
    const query = `
      SELECT DISTINCT
        d.objid,
        co.relname as dependent_object,
        co.relkind as dependent_type,
        a.attname as column_name
      FROM pg_depend d
      JOIN pg_class c ON c.oid = d.refobjid
      JOIN pg_class co ON co.oid = d.objid
      JOIN pg_attribute a ON a.attrelid = d.refobjid AND a.attnum = d.refobjsubid
      WHERE c.relname = '${tableName}'
      AND a.attname = '${columnName}'
      AND d.deptype = 'n'
      ORDER BY dependent_type, dependent_object;
    `;
    
    const results = await this.queryInterface.sequelize.query(
      query,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
    
    return results.map(item => ({
      name: item.dependent_object,
      type: this.getObjectTypeName(item.dependent_type)
    }));
  }
  
  /**
   * Maps PostgreSQL object type codes to readable names
   * @param {string} typeCode - Single character type code
   * @returns {string} - Human-readable type name
   */
  getObjectTypeName(typeCode) {
    const types = {
      'r': 'table',
      'v': 'view',
      'i': 'index',
      't': 'trigger',
      'f': 'foreign table',
      'S': 'sequence',
      'c': 'composite type',
      'm': 'materialized view'
    };
    
    return types[typeCode] || 'unknown';
  }
}

module.exports = DependencyAnalyzer;