'use strict';

const fs = require('fs');
const path = require('path');

/**
 * Generates database documentation from the actual schema
 */
class DocumentationGenerator {
  /**
   * Creates a new DocumentationGenerator
   * @param {Object} queryInterface - Sequelize queryInterface
   * @param {Object} options - Configuration options
   */
  constructor(queryInterface, options = {}) {
    this.queryInterface = queryInterface;
    this.outputDir = options.outputDir || path.join(process.cwd(), 'docs', 'database');
    this.logger = options.logger || console;
  }

  /**
   * Generates database documentation markdown files
   * @returns {Promise<boolean>} - Success indicator
   */
  async generateDocs() {
    try {
      // Ensure output directory exists
      if (!fs.existsSync(this.outputDir)) {
        fs.mkdirSync(this.outputDir, { recursive: true });
      }
      
      // Generate schema documentation
      await this.generateSchemaDoc();
      
      // Generate views documentation
      await this.generateViewsDoc();
      
      // Generate relationships documentation
      await this.generateRelationshipsDoc();
      
      // Generate indices documentation
      await this.generateIndicesDoc();
      
      return true;
    } catch (error) {
      this.logger.error(`Documentation generation failed: ${error.message}`);
      throw error;
    }
  }

  /**
   * Generates schema documentation
   * @returns {Promise<string>} - Path to the generated file
   */
  async generateSchemaDoc() {
    const tables = await this.getTables();
    const filePath = path.join(this.outputDir, 'schema.md');
    
    let content = `# Database Schema Documentation\n\n`;
    content += `Generated on: ${new Date().toISOString()}\n\n`;
    
    for (const table of tables) {
      content += `## ${table.table_name}\n\n`;
      
      // Get table columns
      const columns = await this.getTableColumns(table.table_name);
      
      content += `| Column | Type | Nullable | Default | Description |\n`;
      content += `|--------|------|----------|---------|-------------|\n`;
      
      for (const column of columns) {
        content += `| ${column.column_name} | ${column.data_type} | ${column.is_nullable} | ${column.column_default || 'NULL'} | ${column.description || ''} |\n`;
      }
      
      content += `\n`;
    }
    
    fs.writeFileSync(filePath, content);
    this.logger.info(`Schema documentation generated at ${filePath}`);
    
    return filePath;
  }

  /**
   * Generates views documentation
   * @returns {Promise<string>} - Path to the generated file
   */
  async generateViewsDoc() {
    const views = await this.getViews();
    const filePath = path.join(this.outputDir, 'views.md');
    
    let content = `# Database Views Documentation\n\n`;
    content += `Generated on: ${new Date().toISOString()}\n\n`;
    
    for (const view of views) {
      content += `## ${view.viewname}\n\n`;
      
      // Get view definition
      const definition = await this.getViewDefinition(view.viewname);
      
      content += `### Definition\n\n`;
      content += `\`\`\`sql\n${definition}\n\`\`\`\n\n`;
      
      // Get columns in the view
      const columns = await this.getViewColumns(view.viewname);
      
      content += `### Columns\n\n`;
      content += `| Column | Type | Description |\n`;
      content += `|--------|------|-------------|\n`;
      
      for (const column of columns) {
        content += `| ${column.column_name} | ${column.data_type} | ${column.description || ''} |\n`;
      }
      
      content += `\n`;
      
      // Get tables this view depends on
      content += `### Dependencies\n\n`;
      const dependencies = await this.getViewDependencies(view.viewname);
      
      if (dependencies.length > 0) {
        content += `This view depends on the following tables:\n\n`;
        
        for (const dep of dependencies) {
          content += `- ${dep.source_table}\n`;
        }
      } else {
        content += `This view has no dependencies.\n`;
      }
      
      content += `\n`;
    }
    
    fs.writeFileSync(filePath, content);
    this.logger.info(`Views documentation generated at ${filePath}`);
    
    return filePath;
  }

  /**
   * Generates relationships documentation
   * @returns {Promise<string>} - Path to the generated file
   */
  async generateRelationshipsDoc() {
    const relationships = await this.getRelationships();
    const filePath = path.join(this.outputDir, 'relationships.md');
    
    let content = `# Database Relationships Documentation\n\n`;
    content += `Generated on: ${new Date().toISOString()}\n\n`;
    
    // Group by table
    const tables = {};
    
    for (const rel of relationships) {
      if (!tables[rel.table_name]) {
        tables[rel.table_name] = {
          foreignKeys: [],
          referencedBy: []
        };
      }
      
      tables[rel.table_name].foreignKeys.push(rel);
    }
    
    // Add "referenced by" relationships
    for (const rel of relationships) {
      if (!tables[rel.referenced_table]) {
        tables[rel.referenced_table] = {
          foreignKeys: [],
          referencedBy: []
        };
      }
      
      tables[rel.referenced_table].referencedBy.push({
        table: rel.table_name,
        column: rel.column_name,
        foreignColumn: rel.referenced_column
      });
    }
    
    // Generate content
    for (const [tableName, tableInfo] of Object.entries(tables)) {
      content += `## ${tableName}\n\n`;
      
      if (tableInfo.foreignKeys.length > 0) {
        content += `### Foreign Keys\n\n`;
        content += `| Column | References | On Delete | On Update |\n`;
        content += `|--------|------------|-----------|----------|\n`;
        
        for (const fk of tableInfo.foreignKeys) {
          content += `| ${fk.column_name} | ${fk.referenced_table}.${fk.referenced_column} | ${fk.delete_rule} | ${fk.update_rule} |\n`;
        }
        
        content += `\n`;
      }
      
      if (tableInfo.referencedBy.length > 0) {
        content += `### Referenced By\n\n`;
        content += `| Table | Column | References |\n`;
        content += `|-------|--------|------------|\n`;
        
        for (const ref of tableInfo.referencedBy) {
          content += `| ${ref.table} | ${ref.column} | ${tableName}.${ref.foreignColumn} |\n`;
        }
        
        content += `\n`;
      }
    }
    
    fs.writeFileSync(filePath, content);
    this.logger.info(`Relationships documentation generated at ${filePath}`);
    
    return filePath;
  }

  /**
   * Generates indices documentation
   * @returns {Promise<string>} - Path to the generated file
   */
  async generateIndicesDoc() {
    const indices = await this.getIndices();
    const filePath = path.join(this.outputDir, 'indices.md');
    
    let content = `# Database Indices Documentation\n\n`;
    content += `Generated on: ${new Date().toISOString()}\n\n`;
    
    // Group by table
    const tables = {};
    
    for (const idx of indices) {
      if (!tables[idx.table_name]) {
        tables[idx.table_name] = [];
      }
      
      tables[idx.table_name].push(idx);
    }
    
    // Generate content
    for (const [tableName, tableIndices] of Object.entries(tables)) {
      content += `## ${tableName}\n\n`;
      content += `| Name | Columns | Type | Unique |\n`;
      content += `|------|---------|------|--------|\n`;
      
      for (const idx of tableIndices) {
        content += `| ${idx.index_name} | ${idx.column_names} | ${idx.index_type} | ${idx.is_unique} |\n`;
      }
      
      content += `\n`;
    }
    
    fs.writeFileSync(filePath, content);
    this.logger.info(`Indices documentation generated at ${filePath}`);
    
    return filePath;
  }

  /**
   * Gets all database tables
   * @returns {Promise<Array>} - List of tables
   */
  async getTables() {
    const query = `
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      AND table_type = 'BASE TABLE'
      ORDER BY table_name
    `;
    
    return this.queryInterface.sequelize.query(
      query,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
  }

  /**
   * Gets columns for a specific table
   * @param {string} tableName - Table name
   * @returns {Promise<Array>} - List of columns
   */
  async getTableColumns(tableName) {
    const query = `
      SELECT 
        column_name,
        data_type,
        is_nullable,
        column_default,
        col_description(
          (table_schema || '.' || table_name)::regclass::oid, 
          ordinal_position
        ) as description
      FROM information_schema.columns
      WHERE table_schema = 'public'
      AND table_name = '${tableName}'
      ORDER BY ordinal_position
    `;
    
    return this.queryInterface.sequelize.query(
      query,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
  }

  /**
   * Gets all database views
   * @returns {Promise<Array>} - List of views
   */
  async getViews() {
    const query = `
      SELECT viewname
      FROM pg_catalog.pg_views
      WHERE schemaname = 'public'
      ORDER BY viewname
    `;
    
    return this.queryInterface.sequelize.query(
      query,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
  }

  /**
   * Gets the definition for a specific view
   * @param {string} viewName - View name
   * @returns {Promise<string>} - View definition
   */
  async getViewDefinition(viewName) {
    const query = `SELECT pg_get_viewdef('${viewName}', true) AS definition`;
    
    const result = await this.queryInterface.sequelize.query(
      query,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
    
    return result[0].definition;
  }

  /**
   * Gets columns for a specific view
   * @param {string} viewName - View name
   * @returns {Promise<Array>} - List of columns
   */
  async getViewColumns(viewName) {
    const query = `
      SELECT 
        column_name,
        data_type,
        col_description(
          (table_schema || '.' || table_name)::regclass::oid, 
          ordinal_position
        ) as description
      FROM information_schema.columns
      WHERE table_schema = 'public'
      AND table_name = '${viewName}'
      ORDER BY ordinal_position
    `;
    
    return this.queryInterface.sequelize.query(
      query,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
  }

  /**
   * Gets dependencies for a specific view
   * @param {string} viewName - View name
   * @returns {Promise<Array>} - List of dependencies
   */
  async getViewDependencies(viewName) {
    const query = `
      SELECT DISTINCT
        source_table.relname AS source_table
      FROM pg_depend 
      JOIN pg_rewrite ON pg_depend.objid = pg_rewrite.oid 
      JOIN pg_class as dependent_view ON pg_rewrite.ev_class = dependent_view.oid 
      JOIN pg_class as source_table ON pg_depend.refobjid = source_table.oid 
      WHERE dependent_view.relname = '${viewName}'
      AND source_table.relkind = 'r'
      ORDER BY source_table
    `;
    
    return this.queryInterface.sequelize.query(
      query,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
  }

  /**
   * Gets all foreign key relationships
   * @returns {Promise<Array>} - List of relationships
   */
  async getRelationships() {
    const query = `
      SELECT
        tc.table_name,
        kcu.column_name,
        ccu.table_name AS referenced_table,
        ccu.column_name AS referenced_column,
        rc.delete_rule,
        rc.update_rule
      FROM information_schema.table_constraints tc
      JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name
      JOIN information_schema.constraint_column_usage ccu
        ON tc.constraint_name = ccu.constraint_name
      JOIN information_schema.referential_constraints rc
        ON tc.constraint_name = rc.constraint_name
      WHERE tc.constraint_type = 'FOREIGN KEY'
      ORDER BY tc.table_name, kcu.column_name
    `;
    
    return this.queryInterface.sequelize.query(
      query,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
  }

  /**
   * Gets all indices
   * @returns {Promise<Array>} - List of indices
   */
  async getIndices() {
    const query = `
      SELECT
        t.relname AS table_name,
        i.relname AS index_name,
        array_to_string(array_agg(a.attname), ', ') AS column_names,
        CASE 
          WHEN i.relkind = 'i' THEN 'btree'
          ELSE ix.amname
        END AS index_type,
        ix.indisunique AS is_unique
      FROM pg_index ix
      JOIN pg_class i ON i.oid = ix.indexrelid
      JOIN pg_class t ON t.oid = ix.indrelid
      JOIN pg_attribute a ON a.attrelid = t.oid
      JOIN pg_namespace n ON n.oid = t.relnamespace
      WHERE a.attnum = ANY(ix.indkey)
        AND t.relkind = 'r'
        AND n.nspname = 'public'
      GROUP BY t.relname, i.relname, ix.indisunique, ix.indrelid, ix.indexrelid, i.relkind, ix.amname
      ORDER BY t.relname, i.relname
    `;
    
    return this.queryInterface.sequelize.query(
      query,
      { type: this.queryInterface.sequelize.QueryTypes.SELECT }
    );
  }
}

module.exports = DocumentationGenerator;