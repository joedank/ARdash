'use strict';

/**
 * Provides utilities for verifying database integrity
 */
class DatabaseVerifier {
  /**
   * Creates a new DatabaseVerifier
   * @param {Object} queryInterface - Sequelize queryInterface
   */
  constructor(queryInterface) {
    this.queryInterface = queryInterface;
  }

  /**
   * Verifies that all views are valid
   * @returns {Promise<Object>} - Verification results
   */
  async verifyViews() {
    const query = `
      SELECT viewname 
      FROM pg_catalog.pg_views 
      WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
    `;
    
    const views = await this.queryInterface.sequelize.query(
      query,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
    
    const results = {
      valid: [],
      invalid: []
    };
    
    // Test each view by selecting from it
    for (const view of views) {
      try {
        await this.queryInterface.sequelize.query(
          `SELECT * FROM ${view.viewname} LIMIT 1`
        );
        results.valid.push(view.viewname);
      } catch (error) {
        results.invalid.push({
          name: view.viewname,
          error: error.message
        });
      }
    }
    
    return results;
  }

  /**
   * Checks for data integrity issues
   * @returns {Promise<Object>} - Integrity check results
   */
  async checkDataIntegrity() {
    // Get all tables with foreign keys
    const tableQuery = `
      SELECT DISTINCT tc.table_name
      FROM information_schema.table_constraints tc
      JOIN information_schema.constraint_column_usage ccu 
        ON tc.constraint_name = ccu.constraint_name
      WHERE tc.constraint_type = 'FOREIGN KEY'
    `;
    
    const tables = await this.queryInterface.sequelize.query(
      tableQuery,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
    
    const results = {
      checked: [],
      issues: []
    };
    
    // For each table, check for orphaned foreign keys
    for (const table of tables) {
      const tableName = table.table_name;
      
      // Get foreign key constraints for this table
      const fkQuery = `
        SELECT
          tc.constraint_name,
          tc.table_name,
          kcu.column_name,
          ccu.table_name AS foreign_table_name,
          ccu.column_name AS foreign_column_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu
          ON tc.constraint_name = kcu.constraint_name
        JOIN information_schema.constraint_column_usage ccu
          ON tc.constraint_name = ccu.constraint_name
        WHERE tc.constraint_type = 'FOREIGN KEY'
        AND tc.table_name = '${tableName}'
      `;
      
      const foreignKeys = await this.queryInterface.sequelize.query(
        fkQuery,
        { type: this.queryInterface.sequelize.QueryTypes.SELECT }
      );
      
      results.checked.push(tableName);
      
      // Check each foreign key for orphaned references
      for (const fk of foreignKeys) {
        // Skip if the column allows nulls (we only care about non-null references)
        const columnQuery = `
          SELECT is_nullable
          FROM information_schema.columns
          WHERE table_name = '${tableName}'
          AND column_name = '${fk.column_name}'
        `;
        
        const columnInfo = await this.queryInterface.sequelize.query(
          columnQuery,
          { type: this.queryInterface.sequelize.QueryTypes.SELECT }
        );
        
        if (columnInfo[0].is_nullable === 'YES') {
          continue;
        }
        
        // Check for orphaned references
        const orphanedQuery = `
          SELECT COUNT(*) as count
          FROM ${tableName} t
          LEFT JOIN ${fk.foreign_table_name} ft 
            ON t.${fk.column_name} = ft.${fk.foreign_column_name}
          WHERE ft.${fk.foreign_column_name} IS NULL 
            AND t.${fk.column_name} IS NOT NULL
        `;
        
        const orphanedCount = await this.queryInterface.sequelize.query(
          orphanedQuery,
          { type: this.queryInterface.sequelize.QueryTypes.SELECT }
        );
        
        if (parseInt(orphanedCount[0].count) > 0) {
          results.issues.push({
            table: tableName,
            foreignKey: fk.column_name,
            referencedTable: fk.foreign_table_name,
            referencedColumn: fk.foreign_column_name,
            orphanedCount: parseInt(orphanedCount[0].count)
          });
        }
      }
    }
    
    return results;
  }
}

module.exports = DatabaseVerifier;