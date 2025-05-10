### Docker Multi-Stage Build Pattern

- **Problem:** Single-stage Docker builds mix development and production needs, causing issues with package management and optional dependencies.
- **Pattern:** Use multi-stage Docker builds to separate concerns and optimize for both development and production.
- **Example Implementation:** Frontend Dockerfile with builder, development, build, and production stages.
- **Solution:**
  ```dockerfile
  # Stage 1: Build stage with all dependencies
  FROM node:20-alpine AS builder
  WORKDIR /app
  COPY package*.json ./
  # Install ALL dependencies including dev dependencies
  RUN npm ci
  COPY . .
  
  # Stage 2: Development image that uses all the dependencies
  FROM builder AS development
  EXPOSE 5173
  CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
  
  # Stage 3: Build the production assets
  FROM builder AS build
  RUN npm run build
  
  # Stage 4: Production image with minimal dependencies
  FROM nginx:alpine AS production
  COPY --from=build /app/dist /usr/share/nginx/html
  EXPOSE 80
  ```
- **Key Learning:**
  - Always use a multi-stage approach for Docker builds to separate build and runtime concerns
  - Install dev dependencies in builder/development stages but exclude them from production
  - Avoid volume-mounting node_modules to prevent native module issues
  - Pre-build assets and copy only what's needed to production images
  - Target specific stages in docker-compose.yml with the `target` parameter

## Database Migration Best Practices

### Idempotent Migration Pattern  

- **Problem**: Database migrations fail when run multiple times (such as during database restoration) or when database state doesn't match expectations
- **Pattern**: Make all migrations idempotent by checking for existing objects before attempting to create/modify
- **Implementation Examples**:
  
  **1. Enum Value Addition**
  ```javascript
  // Instead of direct ALTER TYPE statement
  await queryInterface.sequelize.query(`
    DO $
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM pg_enum
        WHERE enumtypid = 'enum_projects_status'::regtype
          AND enumlabel = 'rejected'
      ) THEN
        ALTER TYPE enum_projects_status ADD VALUE 'rejected';
      END IF;
    END$;
  `);
  ```
  
  **2. Extension Creation**
  ```javascript
  // Always use IF NOT EXISTS for extensions
  await queryInterface.sequelize.query(`
    CREATE EXTENSION IF NOT EXISTS pg_trgm;
  `);
  ```
  
  **3. Index Creation**
  ```javascript
  // Drop first, then create with IF NOT EXISTS
  await queryInterface.sequelize.query(`
    DROP INDEX IF EXISTS work_types_name_vec_hnsw;
    CREATE INDEX IF NOT EXISTS work_types_name_vec_hnsw
    ON work_types USING hnsw (name_vec vector_l2_ops)
    WITH (m = 16, ef_construction = 200);
  `);
  ```
  
  **4. Column NULL Timestamp Handling**
  ```javascript
  // Handle NULL timestamp values in existing data
  await queryInterface.sequelize.query(`
    UPDATE settings
    SET created_at = NOW(), updated_at = NOW()
    WHERE created_at IS NULL OR updated_at IS NULL;
  `);
  ```

  **5. Table and Constraint Removal**
  ```javascript
  // Check for table existence before dropping
  const tableExists = await queryInterface.sequelize.query(
    "SELECT EXISTS (SELECT FROM pg_catalog.pg_tables WHERE schemaname = 'public' AND tablename = 'pre_assessments')",
    { type: Sequelize.QueryTypes.SELECT }
  );
  
  if (tableExists[0].exists) {
    // Check for foreign key constraints
    const constraints = await queryInterface.sequelize.query(
      "SELECT conname FROM pg_constraint WHERE confrelid = 'pre_assessments'::regclass",
      { type: Sequelize.QueryTypes.SELECT }
    );
    
    // Remove all foreign key constraints
    for (const constraint of constraints) {
      const tableName = await queryInterface.sequelize.query(
        `SELECT conrelid::regclass::text FROM pg_constraint WHERE conname = '${constraint.conname}'`,
        { type: Sequelize.QueryTypes.SELECT }
      );
      
      await queryInterface.removeConstraint(tableName[0].conrelid, constraint.conname);
    }
    
    // Drop the table
    await queryInterface.dropTable('pre_assessments');
  }
  ```

- **Key Aspects**:
  - Always verify object existence before creation/modification  
  - Use PostgreSQL DO blocks with explicit existence checks for constraints
  - Use `DROP IF EXISTS` before creating objects to ensure clean state
  - Handle legacy data issues (like NULL timestamps in NOT NULL columns)
  - Use transaction-based approach for atomicity of related changes
  - Add detailed logging to help diagnose issues
  - Implement proper error handling with specific error messages
  - Check for dependent objects (foreign keys) before removing tables
  - Make migrations resilient to partial application states

### Function Signatures

- Use standard Sequelize migration function signature: `async up(queryInterface, Sequelize)`
- Avoid legacy pattern: `async up({ context: queryInterface })`
- For compatibility with existing code, use `const qi = queryInterface`
- Apply the same pattern to `down` methods

### PostgreSQL pgvector

- HNSW and IVFFLAT indexes have a 2000-dimension limit
- Check vector dimensions before creating indexes: `vector_dims(name_vec)`
- Provide explicit operator class: `vector_l2_ops`
- Implement fallbacks when specialized indexes are unavailable
- Drop all existing vector indexes before altering vector column dimensions

### Sequelize Models

- Avoid using the same name for both a column and an association in the same model
- Use descriptive suffixes for associations (e.g., `conditionInspection`) to avoid collisions
- When transitioning column names, update all association references in services and controllers

# System Patterns: Construction Management Web Application

## Frontend Integration Patterns

### API Path Prefixing Enforcement Pattern

- **Problem**: Hard-coded `/api/` prefixes in service files creating doubled URL paths (`/api/api/...`) when baseURL is already set to `/api`
- **Pattern**: Automated enforcement with ESLint rule and batch fix script
- **Solution**: Create custom ESLint rule and correction script to maintain consistent path prefixing

```javascript
// 1. Custom ESLint rule to prevent hard-coded prefixes
module.exports = {
  meta: { type: 'problem' },
  create: context => ({
    Literal(node) {
      if (typeof node.value === 'string' && /^[\/]api\//.test(node.value)) {
        context.report({
          node: node,
          message: 'Path already prefixed by baseURL; drop /api/.'
        });
      }
    }
  })
};

// 2. Auto-fix script to clean up existing prefix issues
import { promises as fs } from 'fs';
import fg from 'fast-glob';
const files = await fg('frontend/src/services/**/*.js');
for (const f of files) {
  const t = await fs.readFile(f,'utf8');
  const nt = t.replace(/(['"\`])\/api\/([^'"\`]+)/g,'$1/$2');
  if (t!==nt){
    await fs.writeFile(f,nt);
    console.log('fixed',f);
  }
}

// 3. Clear documentation in README.md
/**
 * API Path Prefixing Convention
 *
 * - In api.service.js, the baseURL is set to '/api'
 * - All service calls should use paths relative to this base URL
 * - Example: Use '/auth/login' instead of '/api/auth/login'
 *
 * If you encounter any doubled prefixes (e.g., '/api/api/auth/login'),
 * run the provided script: node scripts/stripApiPrefix.js
 */
```

- **Key Aspects**:
  - Custom ESLint rule (`no-hardcoded-api`) flags any string literals starting with `/api/`
  - Automated fix script with regex pattern matching (`scripts/stripApiPrefix.js`)
  - Clear documentation pattern in README.md to explain the convention
  - Prevention of regression through build-time validation
  - Consistent API path handling across all service files
  - Manual verification of edge cases that might not be caught by the script
  - Regular code audits to identify similar issues across the codebase

- **Implementation Details**:
  - The script successfully fixed 15 service files with duplicate API prefixes
  - Some instances in community.service.js required manual fixing
  - The fix was verified by testing login and communities page functionality
  - The browser network tab confirmed requests use correct paths without duplication

### API Boundary Case Normalization Pattern

- **Problem**: Frontend case conversion utilities (toSnakeCase) transform camelCase property names to snake_case, but backend destructuring expects specific casing, causing mismatches
- **Pattern**: Destructure with support for both case styles using property aliases and fallback mechanism
- **Solution**: Accept both camel and snake case versions at API boundaries with clear normalization

```javascript
// Handle both camelCase and snake_case naming conventions
const {
  addresses,
  _deleted_address_ids: deletedAddressIdsSnake,  // Handle snake_case (from frontend toSnakeCase)
  _deletedAddressIds: deletedAddressIdsCamel,    // Handle camelCase (potential direct API call)
  ...clientData
} = data;
const deletedAddressIds = deletedAddressIdsSnake || deletedAddressIdsCamel || [];
```

- **Key Aspects**:
  - Destructuring with property aliases creates clear mapping for both naming conventions
  - Fallback assignment with OR operator (`||`) creates a normalized variable for subsequent code
  - Empty array default ensures the variable is always a valid array even if both are undefined
  - Works transparently with both frontend (snake_case) and direct API calls (camelCase)
  - All subsequent code uses the normalized variable name for consistency
  - Pattern can be applied anywhere destructuring is used at API boundaries
  - Follows the project's rule for snake_case at API boundaries while maintaining compatibility

### Multiple Threshold NLP Matching Pattern

- **Problem**: Simple binary matching thresholds don't provide enough flexibility for AI-driven work type suggestions
- **Pattern**: Implement multiple confidence thresholds for different user actions
- **Solution**: Use separate thresholds for suggestions vs. creation candidates

```javascript
// Multiple threshold constants for different confidence levels
const MIN = 0.35;      // Minimum threshold for suggestions
const HARD_CREATE = 0.60;  // Threshold below which items should be creation candidates

// Fragment processing with multiple threshold logic
for (const p of parts) {
  const hits = await this._detectFragment(p);
  
  // Add to unmatched if best score is below HARD_CREATE threshold
  const bestScore = hits.length ? Math.max(...hits.map(h=>h.score)) : 0;
  if (bestScore < HARD_CREATE) {
    unmatchedFragments.push(p.trim());
  }
  
  agg.push(...hits);
}

// Result now contains both lists:
// - existing: Items with scores >= MIN
// - unmatched: Items with top score < HARD_CREATE (which could include some from existing list)
return {
  existing: existingWorkTypes,
  unmatched: unmatchedFragments
};
```

- **Key Aspects**:
  - Separate constants for different threshold levels
  - Items can appear in both suggestion and creation lists when 0.35 <= score < 0.60
  - Frontend can visually differentiate between the two categories (blue for suggestions, yellow for new)
  - Different actions available based on confidence level
  - Improved UX by providing both suggestions and creation options for ambiguous matches
  - Schema allows for future refinement of thresholds based on user feedback
  - Validation ensures fragments are properly trimmed and prepared

### API Path Prefixing Implementation

- **Problem**: Inconsistent API path handling causing 404 errors when Vite doesn't properly proxy requests
- **Pattern**: Single source of truth for API path prefixing
- **Solution**: Include `/api` in baseURL of API service client to ensure proper proxy routing

```javascript
// 1. API Service Configuration
const apiService = axios.create({
  baseURL: '/api',  // Dev proxy & prod routing share this prefix
  timeout: 360000,
  withCredentials: true,
  // Other axios configuration
});

// 2. Documentation to prevent regression
// NOTE: baseURL is set to '/api' - Vite proxies this to backend in dev, Nginx routes it properly in prod.
// IMPORTANT: Do not prepend '/api/' in individual service calls!

// 3. Correct service method implementation
async detectWorkTypes(conditionText) {
  // No '/api/' prefix - already added by baseURL setting
  const response = await apiClient.post('/assessments/detect-work-types', {
    condition: conditionText
  });
  // Response handling
}
```

- **Key Aspects**:
  - API service uses `/api` in baseURL to ensure all requests are properly proxied in development
  - Vite proxy configuration routes /api/* requests to the backend server
  - Services use routes without `/api/` prefix since it's already in the baseURL
  - Clear documentation prevents reintroduction of the issue
  - Consistent approach across all service files

### Work Types Frontend Integration Pattern

- **Problem**: Completed backend work types knowledge base (Phase B) needed frontend components for user management
- **Pattern**: Component-based modular design with specialized functionality
- **Solution**: Created reusable components with clear responsibilities and consistent design

```javascript
// 1. Component structure with tabbed interface for complex data
<template>
  <div>
    <!-- Tabs for organizing complex data -->
    <div class="border-b border-gray-200 dark:border-gray-700">
      <nav class="-mb-px flex space-x-8">
        <button
          v-for="tab in tabs"
          :key="tab.key"
          @click="activeTab = tab.key"
          class="py-4 px-1 text-sm font-medium border-b-2 whitespace-nowrap"
          :class="[
            activeTab === tab.key
              ? 'border-indigo-500 text-indigo-600 dark:text-indigo-400'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          ]"
        >
          {{ tab.label }}
        </button>
      </nav>
    </div>

    <!-- Dynamic content based on active tab -->
    <div>
      <div v-if="activeTab === 'details'"><!-- Details content --></div>
      <div v-if="activeTab === 'costs'"><!-- Costs content --></div>
      <MaterialsTab v-if="activeTab === 'materials-safety'" />
      <CostHistoryTab v-if="activeTab === 'history'" />
    </div>
  </div>
</template>

// 2. Contextual component styling based on content
const tagClasses = computed(() => {
  const lowerTag = props.tag.toLowerCase();

  if (lowerTag.includes('hazard') || lowerTag.includes('danger')) {
    return 'bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200';
  }

  if (lowerTag.includes('permit') || lowerTag.includes('license')) {
    return 'bg-amber-100 dark:bg-amber-900 text-amber-800 dark:text-amber-200';
  }

  // Default styling
  return 'bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200';
});

// 3. Dashboard widget integration for data visualization
<template>
  <BaseCard title="Work Types Knowledge Base" :loading="loading">
    <div class="grid grid-cols-2 gap-4">
      <div class="flex flex-col items-center justify-center p-4 bg-blue-50 rounded-lg">
        <span class="text-2xl font-bold text-blue-600">{{ stats.totalCount }}</span>
        <span class="text-sm text-gray-600">Total Work Types</span>
      </div>
      <div class="flex flex-col items-center justify-center p-4 bg-green-50 rounded-lg">
        <span class="text-2xl font-bold text-green-600">{{ stats.withCostsCount }}</span>
        <span class="text-sm text-gray-600">With Cost Data</span>
      </div>
    </div>
  </BaseCard>
</template>
```

- **Key Aspects**:
  - Tabbed interface pattern for organizing complex data in limited space
  - Component-based architecture with clear separation of concerns
  - Contextual styling based on content semantics for improved user experience
  - Reuse of existing permissions system for consistent access control
  - Dashboard integration for at-a-glance information
  - Form validation with real-time feedback for user input
  - Modals for focused editing experience without page navigation

## Database Schema Management Patterns

### Transaction-Based View Management Pattern

- **Problem**: Database schema changes fail when columns are referenced by views or other dependent objects
- **Pattern**: Transaction-based view handling with dependency detection
- **Solution**: Implement a comprehensive system for safely managing schema changes with view dependencies

```javascript
// Transaction-based approach to dropping and recreating views
module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Using a transaction to ensure all operations succeed or fail together
    return queryInterface.sequelize.transaction(async (transaction) => {
      // First drop the view that depends on the column
      await queryInterface.sequelize.query(
        'DROP VIEW IF EXISTS client_view;',
        { transaction }
      );

      // Now alter the column type (since it's already nullable with no default)
      await queryInterface.sequelize.query(
        'ALTER TABLE "clients" ALTER COLUMN "payment_terms" TYPE TEXT;',
        { transaction }
      );

      // Recreate the view with the exact same definition
      await queryInterface.sequelize.query(
        `CREATE OR REPLACE VIEW client_view AS
         SELECT id,
           display_name AS name,
           company,
           email,
           phone,
           payment_terms,
           default_tax_rate,
           default_currency,
           notes,
           is_active,
           client_type,
           created_at,
           updated_at
         FROM clients;`,
        { transaction }
      );
    });
  }
};

// Reusable ViewManager class for view operations
class ViewManager {
  constructor(queryInterface) {
    this.queryInterface = queryInterface;
  }

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
}
```

- **Key Aspects**:
  - Transaction wrapping ensures atomicity (all operations succeed or fail together)
  - View management follows a three-step pattern: drop view, modify object, recreate view
  - Using queryInterface.sequelize.query for direct SQL operations
  - View definitions stored in a central registry for consistent recreation
  - View dependencies identified before modification to prevent cascading errors
  - OOP approach with ViewManager class for encapsulating view operations
  - Error handling with transaction rollback when issues occur

### Idempotent Migration Pattern

- **Problem**: Database migrations fail when run multiple times or when database state doesn't match expectations
- **Pattern**: Make migrations idempotent by checking for existing objects before modifications
- **Solution**: Implement checks for tables, columns, constraints, and indices before attempting to create or modify them

```javascript
// 1. Check if table exists before creating it
const tableExists = await queryInterface.sequelize.query(
  `SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_name = 'work_types'
  );`,
  { type: Sequelize.QueryTypes.SELECT }
);

if (tableExists[0].exists) {
  console.log('work_types table already exists, skipping creation');
  return; // Exit early if the table already exists
}

// 2. Check if column exists before adding it
const columnExists = async (tableName, columnName) => {
  try {
    const tableInfo = await queryInterface.describeTable(tableName);
    return !!tableInfo[columnName];
  } catch (error) {
    return false;
  }
};

if (!(await columnExists('invoices', 'client_id'))) {
  console.log('Adding client_id column to invoices table...');
  await queryInterface.addColumn('invoices', 'client_id', {
    type: Sequelize.UUID,
    allowNull: true,
    references: {
      model: 'clients',
      key: 'id'
    }
  });
}

// 3. Check if constraint exists before adding it (using DO blocks)
await queryInterface.sequelize.query(`
  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM pg_constraint
      WHERE conname = 'check_unit_cost_material_non_negative'
    ) THEN
      ALTER TABLE work_types
      ADD CONSTRAINT check_unit_cost_material_non_negative
      CHECK (unit_cost_material IS NULL OR unit_cost_material >= 0);
    END IF;
  END $$;
`);
```

- **Key Aspects**:
  - Always check if objects exist before creating or modifying them
  - Use `queryInterface.describeTable()` to check for column existence
  - Use `information_schema.tables` to check for table existence
  - Use `pg_constraint` to check for constraint existence
  - Use `pg_indexes` to check for index existence
  - Use DO blocks with IF NOT EXISTS checks for constraints (PostgreSQL doesn't support IF NOT EXISTS for constraints)
  - Add detailed logging to help diagnose issues
  - Make down migrations safe by checking for object existence before dropping
  - Follow one-migration-per-change rule to prevent duplicate operations
  - Use transaction-based migrations for atomicity

### Model-Schema Reconciliation Pattern

- **Problem**: Sequelize model definitions can drift from actual database schema during development
- **Pattern**: Automated comparison and migration generation for model-schema alignment
- **Solution**: Implement tools to identify discrepancies and generate corrective migrations

```javascript
// Find mismatches between models and database schema
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

    // Compare types and other attributes...
  }

  return results;
}

// Generate migration to fix mismatches
async generateFixMigration() {
  // Get comparison results
  const comparison = await this.comparer.compareAll();

  let migrationContent = `'use strict';\n\n`;
  migrationContent += `const ViewManager = require('../utils/viewManager');\n`;
  migrationContent += `const viewDefinitions = require('../config/viewDefinitions');\n\n`;

  migrationContent += `module.exports = {\n`;
  migrationContent += `  up: async (queryInterface, Sequelize) => {\n`;
  migrationContent += `    return queryInterface.sequelize.transaction(async (transaction) => {\n`;
  migrationContent += `      const viewManager = new ViewManager(queryInterface);\n\n`;

  // Process each table with mismatches
  for (const mismatch of comparison.mismatches) {
    // Generate SQL operations to handle dependencies and changes
  }

  // Write migration file
  return { created: true, path: filePath, mismatches: comparison.mismatches };
}
```

- **Key Aspects**:
  - Automated detection of discrepancies between models and database
  - Support for virtual fields and field aliases in comparisons
  - Type comparison with mapping between Sequelize and PostgreSQL types
  - Generation of corrective migrations that handle dependencies
  - Transaction-based migration to ensure consistency
  - View dependency management in generated migrations
  - Both up and down migration functions for rollback support

### Automated Database Documentation Pattern

- **Problem**: Database schema documentation becomes outdated and disconnected from actual schema
- **Pattern**: Real-time documentation generation from actual database structure
- **Solution**: Create a documentation generator that queries database metadata

```javascript
// Generate schema documentation from actual database
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
  return filePath;
}

// Generate views documentation
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

    // Get dependencies and generate documentation
  }

  fs.writeFileSync(filePath, content);
  return filePath;
}
```

- **Key Aspects**:
  - Documentation generated directly from database metadata
  - Comprehensive coverage of schema: tables, columns, views, relationships, and indexes
  - Markdown format for easy reading and GitHub integration
  - Includes column details like types, nullability, defaults, and descriptions
  - View documentation with full SQL definitions and dependency lists
  - Relationship documentation showing foreign keys and referenced tables
  - Index documentation with type and covered columns
  - Completely automated with no manual intervention required

## Settings Management Patterns

### Unified Settings Provider Pattern

- **Problem:** Settings retrieval was inconsistent across different services and keys were checked in different orders
- **Pattern:** Implement a standardized settings retrieval pattern with consistent fallback chains
- **Solution:** Unified suffix map for consistent key lookups with abstracted helper methods

```javascript
// Map for suffix conversion
#suffixMap = {
  apiKey: 'api_key',
  baseUrl: 'base_url',
  model: 'model'
};

// Generic settings getter with consistent fallback pattern
async _getSetting(providerName, settingType, defaultValue = '') {
  const suffix = this.#suffixMap[settingType];
  if (!suffix) {
    throw new Error(`Invalid setting type: ${settingType}`);
  }

  // Try generic key first
  const genericKey = settingType === 'model' ? 'language_model' : `language_model_${suffix}`;
  const genericValue = await settingsService.getSettingValue(genericKey, null);
  if (genericValue) {
    return genericValue;
  }

  // Fallback to provider-specific key
  const specificKey = `${providerName.toLowerCase()}_${suffix}`;
  const envKey = `${providerName.toUpperCase()}_${suffix.toUpperCase()}`;

  return await settingsService.getSettingValue(specificKey, process.env[envKey] || defaultValue);
}
```

- **Key Aspects:**
  - Private suffix map with camelCase to snake_case mappings
  - Generic method for all setting types that follows consistent pattern
  - Prioritizes generic settings over provider-specific ones
  - Environment variable fallback for each setting
  - Default values based on provider type
  - Consistent error handling for all setting types
  - Clear debugging logs for tracing settings resolution
  - Special handling for non-standard naming patterns

### Provider Abstraction Pattern

- **Problem:** Service implementations hard-code specific providers, causing maintenance issues
- **Pattern:** Abstract provider selection and instantiation behind uniform interface
- **Solution:** Provider factory pattern with standardized methods and fallbacks

```javascript
class LanguageModelProvider {
  constructor() {
    this._initialized = false;
    this._provider = null;
    this._client = null;
    this._initPromise = this._initialize();
  }

  async generateChatCompletion(messages, options = {}) {
    // Ensure provider is initialized
    if (!this._initialized) {
      await this._initPromise;
    }

    // Common implementation with provider-specific handling
    // ...
  }
}
```

- **Key Aspects:**
  - Asynchronous initialization with caching for performance
  - Runtime provider selection based on settings
  - Interface that hides implementation details
  - Consistent error handling and recovery
  - Transparent reinitialize capability for configuration changes
  - Settings-driven dependency injection
  - Isolated API client instances for each provider

### Embedding Provider Migration Pattern

- **Problem:** Changing AI embedding providers requires updates across multiple layers (code, database, UI)
- **Pattern:** Coordinated changes to default provider, database settings, and UI options
- **Solution:** Three-part migration strategy with database, code, and UI updates

```javascript
// 1. Code Default Updates - Change provider fallback in service
let providerName = await settingsService.getSettingValue(
  'embedding_provider',
  process.env.EMBEDDING_PROVIDER || 'gemini' // Changed from 'deepseek'
);

// 2. Database Migration - Create with proper cleanup
module.exports = {
  async up(queryInterface) {
    await queryInterface.sequelize.query(`
      DELETE FROM settings WHERE "key" ILIKE 'deepseek_%';
      UPDATE settings SET value='gemini' WHERE "key"='embedding_provider';
    `);
  }
};

// 3. UI Options Update - Remove deprecated provider from selection
const providers = {
  embedding: [
    { value: 'gemini', label: 'Google Gemini' }, // Primary option first
    { value: 'openai', label: 'OpenAI' },
    { value: 'custom', label: 'Custom Provider' }
  ]
};
```

- **Key Aspects:**
  - Changing default fallback provider in service code
  - Creating a migration to clean database of deprecated settings
  - Moving deprecated seed migrations to a _deprecated folder
  - Updating UI options to remove deprecated providers
  - Making the supported provider the first option in UI selection
  - Ensuring all conditional branches for deprecated providers are removed

## API and Data Patterns

### Enhanced Work Types Knowledge Base Pattern (Phase A)

- **Problem**: AI Wizard needed standardized work types for mobile-home repairs with consistent measurements and units, but required additional validation and extensibility
- **Pattern**: Structured taxonomy with parent buckets, ENUM-based measurement types, and similarity protection
- **Solution**: Enhanced work_types table with ENUM constraints, vector embedding support, revision tracking and similarity validation

```javascript
// Sequelize migration for enhanced work_types table
module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Create the ENUM type for measurement types
    await queryInterface.sequelize.query(
      `CREATE TYPE enum_work_types_measurement_type AS ENUM ('area', 'linear', 'quantity');`
    );

    // Create the work_types table
    await queryInterface.createTable('work_types', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
      },
      name: {
        type: Sequelize.STRING(255),
        allowNull: false
      },
      parent_bucket: {
        type: Sequelize.STRING(100),
        allowNull: false
      },
      measurement_type: {
        type: Sequelize.ENUM('area', 'linear', 'quantity'),
        allowNull: false
      },
      suggested_units: {
        type: Sequelize.STRING(50),
        allowNull: false
      },
      name_vec: {
        type: Sequelize.VECTOR(384), // For future embeddings
        allowNull: true
      },
      revision: {
        type: Sequelize.INTEGER,
        defaultValue: 1
      },
      updated_by: {
        type: Sequelize.UUID,
        allowNull: true
      },
      created_at: Sequelize.DATE,
      updated_at: Sequelize.DATE
    });

    // Add check constraint for units based on measurement type
    await queryInterface.sequelize.query(`
      ALTER TABLE work_types ADD CONSTRAINT check_suggested_units
      CHECK (
        (measurement_type = 'area' AND suggested_units IN ('sq ft', 'sq yd', 'sq m')) OR
        (measurement_type = 'linear' AND suggested_units IN ('ft', 'in', 'yd', 'm')) OR
        (measurement_type = 'quantity' AND suggested_units IN ('each', 'job', 'set'))
      );
    `);

    // Trigram index for similarity search
    await queryInterface.sequelize.query(`
      CREATE INDEX idx_work_types_name ON work_types USING gin (name gin_trgm_ops);
    `);
  }
};

// Enhanced service with duplicate protection using transactions
async createWorkType(data) {
  const transaction = await sequelize.transaction();

  try {
    // Check for duplicates using trigram similarity
    const similar = await this.findSimilarWorkTypes(data.name, 0.85);
    if (similar.length > 0) {
      throw new ValidationError(
        `A similar work type already exists: "${similar[0].name}" (${similar[0].score.toFixed(2)} similarity)`
      );
    }

    // Clean up name for consistency
    if (data.name) {
      data.name = data.name.replace(/\u202F/g, '-'); // Fix Unicode issues
    }

    const workType = await WorkType.create(data, { transaction });
    await transaction.commit();
    return workType;
  } catch (error) {
    await transaction.rollback();
    throw error;
  }
}

// Enhanced frontend service with rate limiting
async findSimilarWorkTypes(name, threshold = 0.3) {
  // Rate limit - add delay between requests
  if (this._lastSimilarityRequest &&
      Date.now() - this._lastSimilarityRequest < 300) {
    await new Promise(resolve => setTimeout(resolve, 300));
  }
  this._lastSimilarityRequest = Date.now();

  try {
    const response = await apiService.get('/work-types/similar', {
      params: { q: name, threshold } // Use 'q' for consistency
    });

    // Return similar work types with scores
    return response.success ? response.data : [];
  } catch (error) {
    console.error('Error finding similar work types:', error);
    return [];
  }
}
```

- **Key Aspects**:
  - Five standardized parent buckets: Interior-Structural, Interior-Finish, Exterior-Structural, Exterior-Finish, Mechanical
  - Three measurement types (area, linear, quantity) with ENUM-constrained validation
  - Suggested units validated with database check constraints
  - Strong duplicate prevention with 0.85 similarity threshold
  - Transaction handling for data consistency
  - Rate limiting (300ms) for similarity API
  - Name vector column for future semantic similarity
  - Revision tracking for audit purposes
  - Integration with both pg_trgm and support for pgvector

### API Route Parameter Validation Pattern

- **Problem**: Some API routes have UUID validation unnecessarily applied to non-parameter routes
- **Pattern**: Explicit validation middleware application based on route parameter presence
- **Solution**: Only apply UUID validation middleware to routes with ID parameters

```javascript
// Routes with ID parameters use UUID validation
router.get('/:id', authenticate, validateUuid('id'), controller.get);

// Routes without ID parameters skip UUID validation
router.get('/current-active', authenticate, controller.getCurrentActiveJob);
```

- **Key Aspects**:
  - Clear documentation in route definition comments about validation requirements
  - Explicit non-application of UUID validation for collection routes
  - Controller methods document their parameter expectations
  - Service methods handle empty results appropriately
  - Frontend services properly handle both success and error responses

### Project Status Management Pattern

- **Problem**: Project workflow lacks clarity without proper state representation for all business outcomes
- **Pattern**: Implement comprehensive status tracking with a complete workflow lifecycle
- **Solution**: Implement a full set of status values that match business workflow including negative outcomes

```javascript
// 1. Status-based filtering in service layer for rejected assessments
async getRejectedProjects(limit = 5) {
  try {
    const projects = await Project.findAll({
      where: {
        type: 'assessment',
        status: 'rejected'
      },
      // Include relationships and sorting...
    });
    return projects;
  } catch (error) {
    logger.error('Error getting rejected projects:', error);
    throw error;
  }
}

// 2. Rejection handling with reason tracking
async rejectAssessment(projectId, rejectionReason = null) {
  try {
    const project = await Project.findByPk(projectId);
    if (!project) {
      throw new ValidationError('Project not found');
    }

    if (project.type !== 'assessment') {
      throw new ValidationError('Only assessment projects can be rejected');
    }

    // Update status and capture reason
    const updateData = { status: 'rejected' };
    if (rejectionReason) {
      updateData.scope = project.scope
        ? `${project.scope}\n\nRejection Reason: ${rejectionReason}`
        : `Rejection Reason: ${rejectionReason}`;
    }

    await project.update(updateData);
    return await this.getProjectWithDetails(projectId);
  } catch (error) {
    logger.error(`Error rejecting assessment project ${projectId}:`, error);
    throw error;
  }
}

// 3. Validation to ensure status appropriateness by project type
if (project.type === 'assessment' && !['in_progress', 'completed', 'rejected'].includes(status)) {
  throw new ValidationError(`Invalid status '${status}' for assessment type projects`);
} else if (project.type === 'active' && !['upcoming', 'in_progress', 'active', 'completed'].includes(status)) {
  throw new ValidationError(`Invalid status '${status}' for active type projects`);
}
```

- **Key Aspects**:
  - Status values (`pending`, `upcoming`, `in_progress`, `completed`, `rejected`) reflect complete business workflow
  - Project types have appropriate statuses (`rejected` only for assessments)
  - Rejection reasons are captured for business intelligence
  - Dashboard shows separate section for rejected assessments
  - API endpoints provide filtered access to each status type
  - Status validation ensures type-appropriate transitions
  - Comprehensive workflow improves business analytics and planning

### Data-Driven Conditional Display Pattern

- **Problem**: Project management shows duplicate entries for related projects (assessment and converted job) cluttering the UI
- **Pattern**: Implement database-driven filtering with toggle option for additional visibility
- **Solution**: Filter out converted assessments by default while maintaining relationship data

```javascript
// Backend filtering based on converted_to_job_id
if (filters.includeConverted !== true) {
  where.converted_to_job_id = null; // Only show non-converted assessments by default
}

// Frontend toggle with clear visual indicators
<div class="flex items-center space-x-2">
  <input
    type="checkbox"
    id="showConverted"
    v-model="showConvertedProjects"
    class="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
  />
  <label for="showConverted" class="text-sm">
    Show converted assessments
  </label>
</div>

// Visual conversion indicator
<span
  v-if="project.convertedJob || project.assessment"
  class="ml-1 inline-flex items-center"
  title="This project has been converted"
>
  <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-blue-500">
    <!-- Arrow icon path -->
  </svg>
</span>
```

- **Key Aspects**:
  - The database filtering occurs at the API level for efficiency
  - Relationship data is always included in the API response for complete context
  - Conversion indicators with arrow icons provide visual cues about relationships
  - User toggle provides explicit control over view complexity
  - Reduces UI clutter while maintaining data integrity
  - Visual indicators make relationships clear when viewing both items

### Workflow-Focused Dashboard Pattern

- **Problem**: Small construction companies typically focus on one job at a time, but project dashboards often show all projects with equal emphasis
- **Pattern**: Structure dashboard to highlight the current active job while providing context about the project pipeline
- **Solution**: Create specialized API endpoints with focused queries and a UI hierarchy that matches the company's workflow

- **System Architecture**:
  - Service-oriented backend (Node.js/Express)
  - Vue.js frontend with modular components for estimates
  - Defensive programming for numeric fields (unitPrice, total, etc.)
  - Mapping backend property names (unitCost/totalCost) to frontend fields for compatibility
  - Use of LLM-based services (llmEstimateService, deepSeekService) for estimate analysis and generation

```javascript
// Backend service - Get the current active job (most recently updated)
async getCurrentActiveJob() {
  const activeJob = await Project.findOne({
    where: {
      type: 'active',
      status: 'in_progress'
    },
    include: [ /* Relations */ ],
    order: [
      ['updated_at', 'DESC']
    ]
  });

  return activeJob;
}

// Frontend - Highlight current job with visual emphasis
<div
  v-if="currentActiveJob"
  class="border-2 border-blue-400 dark:border-blue-600 rounded-lg overflow-hidden shadow-md"
>
  <ProjectCard
    :project="currentActiveJob"
    @click="navigateToProject(currentActiveJob.id)"
    class="cursor-pointer"
  />
</div>
```

- **Key Aspects**:
  - Separate API endpoints for different project categories (active job, assessments, upcoming, completed)
  - Database queries optimized for each specific use case rather than frontend filtering
  - Visual hierarchy that matches the company's actual workflow
  - Clear section headings with descriptive text explaining their purpose
  - Prominent display of the current active job with visual emphasis
  - Contextual grouping of projects by workflow phase (assessment, upcoming, completed)
  - Independent loading states for each section to improve perceived performance

### Project Relationship Display Pattern

- **Problem**: Project management shows duplicate entries for related projects (assessment and converted job) cluttering the UI
- **Pattern**: Implement database-driven filtering with toggle option for additional visibility
- **Solution**: Filter out converted assessments by default while maintaining relationship data

```javascript
// Backend filtering based on converted_to_job_id
if (filters.includeConverted !== true) {
  where.converted_to_job_id = null; // Only show non-converted assessments by default
}

// Frontend toggle with clear visual indicators
<div class="flex items-center space-x-2">
  <input
    type="checkbox"
    id="showConverted"
    v-model="showConvertedProjects"
    class="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
  />
  <label for="showConverted" class="text-sm">
    Show converted assessments
  </label>
</div>

// Visual conversion indicator
<span
  v-if="project.convertedJob || project.assessment"
  class="ml-1 inline-flex items-center"
  title="This project has been converted"
>
  <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-blue-500">
    <!-- Arrow icon path -->
  </svg>
</span>
```

- **Key Aspects**:
  - The database filtering occurs at the API level for efficiency
  - Relationship data is always included in the API response for complete context
  - Conversion indicators with arrow icons provide visual cues about relationships
  - User toggle provides explicit control over view complexity
  - Reduces UI clutter while maintaining data integrity

### Smart Data Reuse Pattern

- **Problem**: Users are asked to re-enter information that is already available from previous steps in the workflow
- **Pattern**: Implement intelligent detection of existing data with visual feedback
- **Solution**: Create helpers and computed properties to compare required vs. available data

```javascript
// Core implementation approach
// 1. Detection function to identify existing data
const dataAlreadyExists = (requiredIdentifier) => {
  // Check if this identifier or semantically similar data exists in source
  return sourceData.some(item => {
    return matchesIdentifier(item, requiredIdentifier);
  });
};

// 2. Computed properties to separate data needs
const existingData = computed(() => {
  return requiredData.filter(data => dataAlreadyExists(data));
});

const missingData = computed(() => {
  return requiredData.filter(data => !dataAlreadyExists(data));
});

// 3. UI that clearly shows what data is being reused
<div v-if="existingData.length > 0" class="data-reuse-indicator">
  <h5>Using existing data:</h5>
  <ul>
    <li v-for="data in existingData">{{ data.name }}: {{ data.value }}</li>
  </ul>
</div>

// 4. Only request missing information
<div v-if="missingData.length > 0">
  <h5>Please provide additional information:</h5>
  <div v-for="data in missingData">
    <input v-model="inputs[data.id]" />
  </div>
</div>
```

- **Key Aspects**:
  - Semantic matching considers variations in naming (e.g., "subfloor area" matches "subfloor_area_sq_ft")
  - Visual indicators clearly show what data is being reused from earlier steps
  - Only truly missing information is requested, eliminating redundant data entry
  - Combined with proper data structure formatting for optimal API integration
  - Enhanced user experience by reducing friction and data entry errors

### Cost-Augmented PromptEngine Pattern

- **Problem**: LLM-generated estimates lacked realistic cost information and safety considerations
- **Pattern**: Augment LLM prompts with reference costs and safety guidance from the work types knowledge base
- **Solution**: Enhance PromptEngine to extract tasks from prompts, find matching work types, and inject cost/safety data

```javascript
// Extract potential work type names and find matching work types with costs/tags
async buildDraft(scopedAssessment, opts = {}) {
  // ... existing code ...

  // Extract work type names from the assessment
  const workTypeNames = this.extractWorkTypeNames(userContent);

  // Find matching work types with costs and safety tags
  const references = await Promise.all(
    workTypeNames.map(name => this.findMatchingWorkTypes(name))
  );

  // Add cost and safety guidance to the system prompt
  if (validReferences.length > 0) {
    // Add cost references
    for (const ref of validReferences) {
      if (ref.unit_cost_material !== null || ref.unit_cost_labor !== null) {
        systemContent += `\n\nFor "${ref.name}" (${ref.measurement_type}):\n"reference_cost": { ... }`;
      }

      // Add safety tags if available
      if (ref.tags && ref.tags.length > 0) {
        systemContent += `\n"safety_tags": [${ref.tags.map(tag => `"${tag}"`).join(', ')}]`;

        // Add specific safety guidance for certain tags
        const safetyGuidance = [];
        if (ref.tags.includes('asbestos')) {
          safetyGuidance.push('Add appropriate PPE and testing as line items.');
        }
        // ... other safety rules ...
      }
    }
  }
}
```

- **Key Aspects**:
  - Extracts potential work type names from user prompts using regex patterns
  - Uses trigram similarity to find matching work types in the database
  - Injects material and labor cost references into the prompt when available
  - Includes safety tags with specific guidance for high-risk tasks like asbestos removal
  - Adds regulatory compliance hints for tasks requiring permits or licensed professionals
  - Maintains backward compatibility with the existing prompt format
  - Improves estimate accuracy without requiring user awareness of the feature

### Work Type Material & Safety Management Pattern

- **Problem**: Work types needed to track associated materials and safety requirements for better estimates
- **Pattern**: Bidirectional relationship between work types and materials with safety tag support
- **Solution**: Implement related tables with transaction-protected operations and visual safety indicators

```javascript
// Transaction-protected material addition
async addMaterials(workTypeId, materials) {
  const transaction = await sequelize.transaction();

  try {
    const workType = await WorkType.findByPk(workTypeId, { transaction });
    // ... validation ...

    const results = [];
    for (const material of materials) {
      // Check for existing material
      const existingMaterial = await WorkTypeMaterial.findOne({
        where: { work_type_id: workTypeId, product_id: material.product_id },
        transaction
      });

      if (existingMaterial) {
        // Update existing material
        await existingMaterial.update({
          qty_per_unit: material.qty_per_unit || existingMaterial.qty_per_unit,
          unit: material.unit || existingMaterial.unit
        }, { transaction });

        results.push(existingMaterial);
      } else {
        // Create new material
        const newMaterial = await WorkTypeMaterial.create({
          id: uuidv4(),
          work_type_id: workTypeId,
          product_id: material.product_id,
          qty_per_unit: material.qty_per_unit || 1,
          unit: material.unit || 'each'
        }, { transaction });

        results.push(newMaterial);
      }
    }

    // Increment revision counter
    await workType.update({ revision: workType.revision + 1 }, { transaction });
    await transaction.commit();
    return results;
  } catch (error) {
    await transaction.rollback();
    throw error;
  }
}
```

- **Key Aspects**:
  - Bidirectional relationship between work types and materials via products
  - Transaction-protected operations to ensure data integrity
  - Intelligent updating of existing materials vs. creating new ones
  - Revision tracking for audit purposes
  - Visual color-coding of safety tags based on risk level
  - Support for multiple materials per work type with quantity calculations
  - Centralized service methods for consistent access patterns

### Cost History Tracking Pattern

- **Problem**: Work type costs change over time and vary by region, making historical analysis valuable
- **Pattern**: Record cost changes over time with user attribution and region support
- **Solution**: Implement a dedicated cost history table with transaction-protected updates

```javascript
// Update costs and record in history
async updateCosts(id, costData, userId, region = 'default') {
  const transaction = await sequelize.transaction();

  try {
    // ... validation ...

    const workType = await WorkType.findByPk(id, { transaction });

    // Update the work type costs
    const updateData = {
      revision: (workType.revision || 0) + 1,
      updated_by: userId
    };

    if (costData.unit_cost_material !== undefined) {
      updateData.unit_cost_material = costData.unit_cost_material;
    }

    if (costData.unit_cost_labor !== undefined) {
      updateData.unit_cost_labor = costData.unit_cost_labor;
    }

    if (costData.productivity_unit_per_hr !== undefined) {
      updateData.productivity_unit_per_hr = costData.productivity_unit_per_hr;
    }

    await workType.update(updateData, { transaction });

    // Record in cost history
    await WorkTypeCostHistory.create({
      id: uuidv4(),
      work_type_id: id,
      region,
      unit_cost_material: costData.unit_cost_material !== undefined ?
                         costData.unit_cost_material : workType.unit_cost_material,
      unit_cost_labor: costData.unit_cost_labor !== undefined ?
                     costData.unit_cost_labor : workType.unit_cost_labor,
      captured_at: new Date(),
      updated_by: userId
    }, { transaction });

    await transaction.commit();
    return workType;
  } catch (error) {
    await transaction.rollback();
    throw error;
  }
}
```

- **Key Aspects**:
  - Preserves complete history of cost changes over time
  - Supports region-specific cost data to account for geographic variations
  - Includes user attribution for audit and accountability
  - Records snapshot of all cost fields, even those not being updated
  - Uses transaction protection to ensure consistent data
  - Increments revision counter on the work type for tracking
  - Provides API for historical analysis and trend visualization

### Unified LLM Estimate Generator Component Architecture Pattern

- **Problem**: Multiple separate LLM estimate generation methods lead to inconsistent UX, code duplication, and maintenance challenges
- **Pattern**: Hierarchical component architecture with container, mode-specific, and shared components
- **Solution**: Implement a container component with mode toggle and shared component reuse

```text
EstimateGenerator/
├── EstimateGeneratorContainer.vue (Container with state management)
│   ├── State: activeMode, generatedItems, assessmentData
│   ├── Methods: handleGeneratedItems, clearAssessment
│   └── Events: close, clearAssessment
├── modes/
│   ├── BuiltInAIMode.vue (Integrated AI interface)
│   │   ├── State: description, targetPrice, analysisResult
│   │   ├── Methods: analyzeScope, submitDetails
│   │   └── Events: generated-items, close
│   └── ExternalPasteMode.vue (External paste interface)
│       ├── State: llmResponse, validationMessage
│       ├── Methods: processResponse, tryParseAsJson
│       └── Events: generated-items, close
└── common/
    ├── ItemsList.vue (Shared item display/edit)
    │   ├── Props: items, catalogMatches
    │   ├── Methods: addItem, editItem, removeItem
    │   └── Events: update:items, highlightSource
    ├── CatalogActions.vue (Catalog integration)
    │   ├── Props: items, selectedItemIndices
    │   ├── Methods: addToCatalog, replaceCatalogItems
    │   └── Events: update:selectedItemIndices, update:items
    └── AssessmentContext.vue (Assessment data display)
        ├── Props: assessmentData
        └── Events: clearAssessment
```

- **Key Aspects**:
  - Container component manages shared state using provide/inject
  - Mode-specific components encapsulate different generation approaches
  - Common components reused between modes for consistency
  - Event-based communication maintains loose coupling
  - Props drilling minimized through strategic state placement

### Smart AI Conversation Pattern

- **Problem:** Traditional LLM prompts often lead to hallucination when information is incomplete, and lead to repetitive user input
- **Pattern:** Split AI interaction into two targeted phases with different objectives
- **Solution:** Implement a two-phase approach with structured schema validation

```javascript
// Phase 1: Scope Analysis - identify only what's missing
const scopePrompt = {
  messages: [
    { role: 'system', content: 'You are a construction estimation assistant.' },
    { role: 'user',   content: `Assessment:\n${assessment}` },
    { role: 'user',   content: 'Return JSON {"requiredMeasurements":[],"questions":[]}' }
  ],
  max_tokens: 600,
  temperature: 0.2, // Low temperature for consistent, focused responses
};

// Phase 2: Draft Generation - create line items with complete information
const draftPrompt = {
  messages: [
    { role: 'system', content: 'Respond ONLY with a JSON array of line items.' },
    { role: 'user',   content: JSON.stringify(completedAssessment) }
  ],
  max_tokens: 1200,
  temperature: 0.5, // Higher for more creative line item generation
};
```

- **Key Benefits:**
  - First phase is quick (1-2 seconds) and focuses only on identifying gaps
  - Second phase only runs after all information is available, preventing hallucination
  - Schema validation ensures structured, predictable responses
  - User only provides information that's truly missing
  - Faster overall workflow and higher quality results

### Tiered Catalog Matching Pattern

- **Problem:** Duplicate items in the product catalog cause inconsistency and management challenges
- **Pattern:** Multi-level confidence scoring with different actions at each tier
- **Solution:** Implement a three-tier matching system with database-level similarity checks

```javascript
async upsertOrMatch(draftItem, { hard = 0.85, soft = 0.60 } = {}) {
  // Find similar products using trigram similarity
  const trgmHits = await this.findByTrgm(draftItem.name);

  // High confidence (>85%) - automatic match
  if (trgmHits[0]?.score >= hard) {
    return { kind: 'match', productId: trgmHits[0].id };
  }

  // Medium confidence (60-85%) - suggest for review
  if (trgmHits[0]?.score >= soft) {
    return { kind: 'review', matches: trgmHits };
  }

  // Low confidence (<60%) - create new product
  const created = await Product.create({ name: draftItem.name });
  return { kind: 'created', productId: created.id };
}
```

- **Key Benefits:**
  - Automatic handling of high-confidence matches saves time
  - User review for medium-confidence matches prevents false positives
  - Database-level similarity matching is significantly faster than application-level
  - Configurable thresholds allow adaptation to catalog size and quality
  - Provides a clean, consistent catalog without duplicates

### Feature Flag Rollout Pattern

- **Problem:** Implementing large new features can be risky if released all at once
- **Pattern:** Use feature flags to control visibility and rollout of new functionality
- **Solution:** Environment variable flags with computed visibility in components

```javascript
// Environment variable in .env.development
VITE_USE_ESTIMATE_V2=true

// In component
const showWizardTab = computed(() => {
  return import.meta.env.VITE_USE_ESTIMATE_V2 === 'true';
});

// Conditional rendering
<button
  v-if="showWizardTab"
  @click="activeMode = 'wizard'"
  class="tab-button"
>
  AI Wizard (v2)
</button>
```

- **Key Benefits:**
  - New functionality can be hidden in production until ready
  - Enables A/B testing by selectively enabling for certain users
  - Allows complete development and testing in parallel with existing functionality
  - No code changes needed to toggle features on and off
  - Can be extended to support gradual rollout percentages

### Vector Search and Similarity Matching Pattern

- **Problem**: Need efficient and accurate detection of similar products to prevent catalog duplication
- **Pattern**: Multi-method similarity matching with confidence-based actions
- **Solution**: Implement both trigram and vector similarity with tiered confidence levels

```javascript
// Combined similarity approach with confidence-based actions
async upsertOrMatch(draftItem, { hard = 0.85, soft = 0.60 } = {}) {
  try {
    // First try trigram matching for text similarity
    const trgmHits = await this.findByTrgm(draftItem.name);

    // High confidence (>85%) - automatic match
    if (trgmHits[0]?.score >= hard) {
      return { kind: 'match', productId: trgmHits[0].id };
    }

    // Medium confidence (60-85%) - suggest for review
    if (trgmHits[0]?.score >= soft) {
      return { kind: 'review', matches: trgmHits };
    }

    // Low confidence (<60%) - create new product
    const created = await Product.create({ name: draftItem.name });

    // Auto-generate embedding for new product
    this.generateAndStoreEmbedding(created.id, created.name)
      .catch(err => logger.error(`Embedding generation failed: ${err.message}`));

    return { kind: 'created', productId: created.id };
  } catch (error) {
    logger.error(`Error in upsertOrMatch: ${error.message}`);
    throw error;
  }
}
```

- **Key Aspects**:
  - Combined approach using text-based trigram matching and semantic vector similarity
  - Three confidence tiers with different actions for each level
  - Automatic embedding generation for new products
  - Database-level similarity queries for performance
  - Integration with existing DeepSeek API infrastructure
  - Confidence thresholds configurable for different contexts

### Advanced Catalog Similarity Integration Pattern

- **Problem**: LLM-generated estimates may create duplicate items already in the product catalog
- **Pattern**: Multi-method similarity checking with database-level matching and user decision workflows
- **Solution**: Implement frontend/backend similarity checking with pg_trgm and pgvector for both text and semantic matching

```javascript
// Frontend service call
async checkSimilarity(descriptions) {
  try {
    const response = await apiService.post('/api/estimates/llm/similarity-check', { descriptions });
    return {
      success: true,
      data: response.data
    };
  } catch (error) {
    console.error('Error checking catalog similarity:', error);
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to check catalog similarity',
      error
    };
  }
}

// Backend implementation with pg_trgm
async checkCatalogSimilarityWithTrgm(descriptions) {
  // Directly leverage pg_trgm in the database query
  const results = [];
  for (const description of descriptions) {
    const matches = await sequelize.query(`
      SELECT
        id,
        name,
        similarity(name, :description) as similarity
      FROM products
      WHERE
        type = 'service'
        AND deleted_at IS NULL
        AND similarity(name, :description) > 0.3
      ORDER BY similarity DESC
      LIMIT 3
    `, {
      replacements: { description },
      type: sequelize.QueryTypes.SELECT
    });

    if (matches.length > 0) {
      results.push(...matches);
    }
  }

  return results;
}

// Backend implementation with pgvector (when using semantic vectors)
async checkCatalogSimilarityWithVector(description, embedding) {
  // Using pgvector for semantic similarity via cosine distance
  const matches = await sequelize.query(`
    SELECT
      id,
      name,
      1 - (embedding <=> :embedding) as similarity
    FROM products
    WHERE type = 'service' AND deleted_at IS NULL
    ORDER BY embedding <=> :embedding
    LIMIT 5
  `, {
    replacements: { embedding },
    type: sequelize.QueryTypes.SELECT
  });

  return matches;
}
```

- **Key Aspects**:
  - Frontend service calls backend for dual similarity checking approaches
  - Trigram-based text similarity via pg_trgm directly in SQL for exact matching and typo resilience
  - Optional vector similarity via pgvector for semantic matching (synonyms, related concepts)
  - Confidence scoring system to categorize matches as high, medium, or low confidence
  - Visual indicators in UI show potential duplicates with confidence levels
  - Automatic linking for high-confidence matches (>0.8 similarity)
  - Interactive resolution UI for medium-confidence matches (0.5-0.8 similarity)
  - User can choose to keep or replace items with catalog equivalents
  - Database-level similarity calculations for better performance

### Vue Component Tag Structure Pattern

- **Problem**: Improper component tag structure can cause rendering issues and unexpected behavior in Vue templates
- **Solution**: Implement consistent component tag structure following Vue best practices

```html
<!-- For components with children, use opening and closing tags -->
<ParentComponent
  prop1="value1"
  :prop2="dynamicValue"
  @event="handleEvent"
>
  <ChildComponent />
</ParentComponent>

<!-- For components without children, use self-closing tags -->
<StandaloneComponent
  prop1="value1"
  :prop2="dynamicValue"
  @event="handleEvent"
/>
```

- **Key Aspects**:
  - Always place attributes inside the opening tag, never after the closing tag
  - Use self-closing tags (`<Component />`) for components without children
  - Use opening and closing tags (`<Component></Component>`) for components with children
  - Never place HTML comments inside attribute areas (`<!-- comment -->` should be on separate lines)
  - Use proper indentation to improve readability
  - Ensure all required props are provided to prevent Vue console warnings

### API Response Format Handling Pattern

- **Problem**: API response structures may vary, especially after database migrations or when accessed through different environments
- **Pattern**: Flexible response handling with fallbacks and enhanced debugging
- **Solution**: Implement service methods that handle different response structures with robust error handling

### Consistent API Response Unwrapping Pattern

- **Problem**: Double unwrapping of API responses can lead to missing properties and broken UI components
- **Pattern**: Standardized response processing with consistent unwrapping strategy
- **Solution**: Choose a single layer (service OR component) to unwrap API responses, with clear documentation

```javascript
// BAD APPROACH - Double unwrapping
// 1. First unwrap in api.service.js via axios interceptor
axiomInstance.interceptors.response.use(response => {
  // First unwrapping happens here
  return response.data;
});

// 2. Second unwrap in ai-provider.service.js
async testLanguageModelConnection() {
  try {
    const response = await apiService.post('/ai-provider/test-language-model');
    // Second unwrapping - BAD! The success flag is lost
    return response.data;
  } catch (error) {
    // Error handling
  }
}

// GOOD APPROACH - Choose one unwrapping strategy
// Option 1: No interceptor unwrapping, explicit service unwrapping
async testLanguageModelConnection() {
  try {
    const response = await apiService.post('/ai-provider/test-language-model');
    return response.data; // Single unwrapping point
  } catch (error) {
    // Error handling
  }
}

// Option 2: Interceptor unwrapping, service preserves structure
async testLanguageModelConnection() {
  try {
    const response = await apiService.post('/ai-provider/test-language-model');
    return response; // No additional unwrapping - PREFERRED
  } catch (error) {
    // Error handling
  }
}
```

- **Key Aspects**:
  - Choose a consistent unwrapping strategy across the entire application
  - Document the chosen strategy clearly in `api.service.js`
  - Include clear comments in service methods about response structure expectations
  - Use debug logging to validate response structures during development
  - Handle different possible response structures with explicit conditions
  - Preserve the standard `{ success, data?, message? }` wrapper convention
  - Ensure component access patterns align with the chosen unwrapping strategy
  - Use defensive programming with optional chaining for property access

```javascript
// Enhanced response handling in service methods with multiple structure support
async getAiProviderSettings() {
  try {
    const response = await apiService.get('/ai-provider');

    // Enhanced response structure handling with better debugging
    console.log('Raw AI provider settings response:', response);

    // Check for different possible response structures
    if (response?.success && response?.data) {
      // Direct response from apiService
      return {
        success: true,
        data: response.data
      };
    } else if (response?.data?.success && response?.data?.data) {
      // Nested response structure
      return {
        success: true,
        data: response.data.data
      };
    } else if (response?.data) {
      // Response with just data property
      return {
        success: true,
        data: response.data
      };
    } else {
      console.warn('Response from AI provider settings endpoint has unexpected format:', response);
      return {
        success: false,
        message: 'Invalid response format from API',
        data: {
          settings: [],
          providers: {
            languageModel: { provider: null, model: null },
            embedding: { provider: null, model: null, enabled: false }
          }
        }
      };
    }
  } catch (error) {
    console.error('Error getting AI provider settings:', error);
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to get AI provider settings',
      error
    };
  }
}

// Component-side handling of response structures
const processSettingsData = (settingsData) => {
  // Add more detailed logging to understand the structure
  console.log('Processing settings data:', settingsData);

  // Handle different possible data structures
  let dbSettings = [];
  let providers = {};

  // Check if settingsData has a settings array
  if (Array.isArray(settingsData.settings)) {
    dbSettings = settingsData.settings;
  } else if (Array.isArray(settingsData)) {
    // If settingsData itself is an array, it might be the settings
    dbSettings = settingsData;
  }

  console.log(`Found ${dbSettings.length} settings in the response`);

  // Apply database settings to the form
  dbSettings.forEach(setting => {
    if (setting && setting.key && setting.key in settings) {
      console.log(`Setting ${setting.key} = ${setting.value}`);
      settings[setting.key] = setting.value;
    }
  });

  // Additional processing...
};
```

- **Key Aspects**:
  - Service methods check for multiple possible response structures with explicit conditions
  - Detailed logging helps identify the exact structure of API responses at each stage
  - Fallback mechanisms ensure the UI remains functional even with unexpected responses
  - Default values provided for all expected properties to prevent undefined errors
  - Consistent error handling with appropriate error messages and error objects
  - Comprehensive structure validation with optional chaining (`?.`) for safe property access
  - Component-side processing with flexible data structure handling
  - Defensive programming with null/undefined checking at all levels
  - Clear debugging information to trace data flow through the application

### Form State Reset Pattern

- **Problem**: Form state can become contaminated with data from previous edits, especially with complex nested objects
- **Solution**: Implement a two-step form reset and population process:

```javascript
// Two-step form reset and population process
const editItem = (item) => {
  // Step 1: Reset form to default values
  Object.assign(editingItem, {
    id: '',
    name: '',
    relatedObject: null,
    // Other default values
  });

  // Step 2: Populate with item data
  Object.assign(editingItem, {
    id: item.id,
    name: item.name,
    relatedObject: item.relatedObject || null,
    // Other values with fallbacks
  });

  // Open modal or proceed with editing
  showEditModal.value = true;
};
```

- **Key Aspects**:
  - Reset form state to default values before populating with new data
  - Use `Object.assign()` for efficient object property updates
  - Provide fallbacks for potentially undefined values
  - Consider the complete object structure expected by form components
  - Use console logging during development to verify object structures

### Enhanced Deletion Pattern with Dependency Checking

- **Problem**: Project deletion can fail when circular references exist (e.g., assessment → job and job → assessment)
- **Solution**: Implement a two-phase deletion process with dependency checking and options:

```javascript
// 1. Dependency checking before deletion
async getProjectDependencies(projectId) {
  // Check for related assessments/jobs, photos, inspections, estimates
  return {
    hasRelatedJob: !!relatedJob,
    relatedJob,
    hasRelatedAssessment: !!relatedAssessment,
    relatedAssessment,
    inspectionsCount,
    photosCount,
    estimatesCount,
    hasDependencies: /* boolean summary */
  };
}

// 2. Reference-safe deletion that breaks circular dependencies
async deleteProject(projectId) {
  // Within transaction:
  // 1. If assessment with converted job, update job: assessment_id = null
  // 2. If job with assessment reference, update assessment: converted_to_job_id = null
  // 3. Delete photos, inspections, etc.
  // 4. Delete project
}

// 3. Optional complete reference deletion (cascade-like behavior)
async deleteProjectWithReferences(projectId) {
  // Delete both sides of relationships and all connected entities
}
```

- **UI Implementation**: Modal with dependency details and deletion options

  ```html
  <!-- Show detailed dependency impact -->
  <div v-if="projectDependencies.hasDependencies" class="rounded-lg border p-3">
    <h4>Deletion Impact</h4>
    <div class="text-sm">{{ detailedDeleteMessage }}</div>
  </div>

  <!-- Deletion options as radio buttons -->
  <div class="flex items-start space-x-2">
    <input type="radio" v-model="deletionOption" value="break" />
    <label>Break references only</label>
  </div>
  <div class="flex items-start space-x-2">
    <input type="radio" v-model="deletionOption" value="all" />
    <label>Delete everything</label>
  </div>
  ```

- **Key Aspects**:
  - Explicit display of deletion impact before confirmation
  - User control over deletion strategy
  - Proper transaction management for data integrity
  - Breaking circular references to prevent database constraint issues
  - Consistent user experience across the application

### Additional Work Integration Pattern

- **Problem**: Construction projects often require additional work beyond the original estimate line items, but there's no structured way to track this
- **Solution**: Implement a one-to-one relationship between line items and additional work records with a visibility toggle:

```javascript
// 1. Database side: One-to-one relationship with an estimate item
EstimateItem.hasOne(EstimateItemAdditionalWork, {
  foreignKey: 'estimate_item_id',
  as: 'additionalWork'
});

// 2. UI implementation: Conditional visibility with checkbox toggle
<div class="flex items-center mb-2">
  <input
    type="checkbox"
    v-model="additionalWorkChecked[item.id]"
    class="mr-2 h-4 w-4"
  />
  <label class="text-md font-medium">
    Additional work performed
  </label>
</div>

<div v-if="additionalWorkChecked[item.id]" class="mt-2">
  <textarea
    v-model="additionalWorkText[item.id]"
    class="w-full rounded-lg border p-2"
    placeholder="Describe what additional work was performed..."
  ></textarea>
</div>
```

- **Key Aspects**:
  - Only create database entries when additional work is actually performed
  - Use visual indicators (badges) to show items with additional work
  - Implement clear toggle UI pattern to reduce interface complexity
  - Handle both front-end state (checkbox) and back-end state (database record) separately
  - Map multiple entries by item ID for efficient data transfer// This would be added to the file in the Document Generation section, right after the PDF Generation explanation

### Standardized Service Pattern

- **Problem**: Inconsistent data handling between frontend and backend causing errors and maintenance issues
- **Solution**: Implement a standardized service pattern with BaseService class:

```javascript
// 1. Create a base service class that handles common operations:
class BaseService {
  constructor(resourceUrl) {
    this.resourceUrl = resourceUrl;
    this.api = api;
  }

  async create(data) {
    try {
      const response = await this.api.post(
        this.resourceUrl,
        this.standardizeRequest(data) // Convert camelCase to snake_case
      );
      return this.standardizeResponse(response); // Convert snake_case to camelCase
    } catch (error) {
      return this._handleError(error);
    }
  }

  // Other CRUD methods...

  standardizeRequest(data) {
    return apiAdapter.standardizeRequest(data);
  }

  standardizeResponse(response) {
    return {
      success: true,
      message: 'Operation successful',
      data: apiAdapter.standardizeResponse(response.data)
    };
  }

  _handleError(error) {
    console.error(`/${this.resourceUrl.replace(/^\//, '')} Service Error:`, error);
    return {
      success: false,
      message: error.message || 'An error occurred',
      data: null
    };
  }
}

// 2. Create entity-specific services that extend the base service:
class EstimateService extends BaseService {
  constructor() {
    super('/estimates');
  }

  // Entity-specific methods...
}

export default new EstimateService();
```

- **Key Aspects**:
  - Centralized data conversion between camelCase and snake_case
  - Consistent error handling with standardized response format
  - Proper logging for debugging
  - Reusable base class for all entity services
  - Standardized CRUD operations with consistent behavior
  - Entity-specific services can add custom methods as needed

### PDF Generation Data Normalization Pattern

- **Problem**: Mixed case conventions (snake_case from database, camelCase in frontend) causing issues in PDF templates
- **Solution**: Implement normalization with fallback handling:

```javascript
// 1. In service layer, normalize data before passing to template:
const pdfPath = await pdfService.generatePdf({
  type: 'estimate',
  data: fieldAdapter.toFrontend(estimate.toJSON()), // Convert to camelCase
  client: fieldAdapter.toFrontend(estimate.client.toJSON()), // Convert to camelCase
  clientAddress: clientAddress ? fieldAdapter.toFrontend(clientAddress.toJSON()) : null,
  filename,
  outputDir: uploadsDir
});

// 2. In EJS template, implement fallback for calculated values:
<td class="text-right text-bold">
  <%
  // Calculate the item total if it's not available
  const itemTotal = item.item_total || item.itemTotal || (parseFloat(item.price || 0) * parseFloat(item.quantity || 0));
  %>
  <%= formatCurrency(itemTotal) %>
</td>
```

- **Key Aspects**:
  - Use field adapter to normalize data at service layer
  - Implement fallback in templates to handle both naming conventions
  - Include on-the-fly calculation as final fallback
  - Keep field adapter implementations consistent between frontend and backend

### Database Migration Case Handling Pattern

- **Problem**: After database migrations (e.g., SQLite to PostgreSQL), case conventions between frontend and backend can cause data display issues
- **Pattern**: Implement robust case conversion with debugging and fallbacks
- **Solution**: Use standardized service pattern with explicit case conversion and debugging

```javascript
// 1. Frontend service with explicit case conversion and debugging
async getAllCommunities(filters = {}) {
  try {
    // Convert filters to snake_case for API
    const snakeCaseFilters = toSnakeCase(filters);

    // Debug the filters being sent to the API
    console.log('Fetching communities with filters:', snakeCaseFilters);

    const response = await apiClient.get('/communities', { params: snakeCaseFilters });

    // Debug the response from the API
    console.log('Communities API response:', response);

    // Ensure we're properly converting snake_case to camelCase
    const communities = toCamelCase(response.data);
    return communities;
  } catch (error) {
    console.error('Error fetching communities:', error);
    throw error;
  }
}

// 2. Utility functions for case conversion
export const toCamelCase = (obj) => {
  if (obj === null || typeof obj !== 'object') return obj;

  if (Array.isArray(obj)) {
    return obj.map(item => toCamelCase(item));
  }

  return Object.keys(obj).reduce((result, key) => {
    // Skip conversion for keys that should remain unchanged
    if (key === 'created_at' || key === 'updated_at' || key === 'deleted_at') {
      result[key] = toCamelCase(obj[key]);
      return result;
    }

    // Convert snake_case to camelCase
    const camelKey = key.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
    result[camelKey] = toCamelCase(obj[key]);
    return result;
  }, {});
};
```

- **Key Aspects**:
  - Add debugging logs at key points in the data flow to identify issues
  - Ensure proper import paths for API services
  - Use utility functions for consistent case conversion
  - Handle both directions: frontend → backend (camelCase → snake_case) and backend → frontend (snake_case → camelCase)
  - Verify data structure at each step of the process
  - Restart services after making changes to ensure clean state
  - Test with authenticated API requests to verify end-to-end flow

### Bidirectional Entity Relationship Pattern

- **Problem**: Entities with two-way relationships (like projects and estimates) can become inconsistent if only one side is updated
- **Solution**: Implement transaction-based updates that maintain both sides of the relationship:

```javascript
// In createEstimate service method
async createEstimate(estimateData) {
  let transaction = null;

  try {
    // Start a transaction to ensure data consistency
    transaction = await sequelize.transaction();

    // Create the estimate with all its data
    const estimate = await Estimate.create({
      // ... estimate data
    }, { transaction });

    // If this estimate is for a project, update the project too
    if (estimateData.project_id) {
      await Project.update(
        { estimate_id: estimate.id },
        { where: { id: estimateData.project_id }, transaction }
      );

      logger.info(`Updated project ${estimateData.project_id} with estimate ${estimate.id}`);
    }

    // Commit the transaction
    await transaction.commit();
    return estimate;
  } catch (error) {
    // Roll back on any error
    if (transaction) await transaction.rollback();
    throw error;
  }
}
```

- **Key Aspects**:
  - Use database transactions to ensure atomicity
  - Update both sides of bidirectional relationships
  - Log relationship changes for debugging purposes
  - Implement proper error handling with rollback
  - Create database backups that maintain referential integrity

### Component Prop Validation and v-model Binding Pattern

- **Problem**: Vue components can generate console warnings and errors when props are not properly validated or when v-model binding is inconsistent
- **Solution**: Implement robust prop validation with defaults and conditional rendering to prevent errors during loading states

```javascript
// 1. Make props optional with default values when they might be undefined during loading
const props = defineProps({
  projectId: {
    type: String,
    required: false, // Not required to prevent errors during loading
    default: ''      // Default value to prevent undefined errors
  },
  show: {
    type: Boolean,
    required: true
  }
});

// 2. Add validation in methods that use potentially undefined props
const confirmReject = async () => {
  // Validate projectId before proceeding
  if (!props.projectId) {
    handleError(new Error('Project ID is missing. Cannot reject assessment.'));
    return;
  }

  // Continue with API call...
};

// 3. Use conditional rendering to prevent component from rendering during loading
<template>
  <RejectAssessmentModal
    v-if="project && project.id" // Only render when data is available
    :project-id="project.id"
    :show="showRejectModal"
    @close="showRejectModal = false"
  />
</template>

// 4. Use correct v-model binding with model-value prop
<BaseModal
  :model-value="show"           // Use model-value instead of show
  @update:model-value="$emit('close')" // Emit event for v-model binding
  @close="onClose"
  size="md"
  :title="'Reject Assessment'"
>
  <!-- Modal content -->
</BaseModal>
```

- **Key Aspects**:
  - Make props optional with default values when they might be undefined during loading
  - Add validation in methods that use potentially undefined props
  - Use conditional rendering (`v-if`) to prevent components from rendering during loading
  - Use correct v-model binding with `model-value` prop and `@update:model-value` event
  - Ensure component documentation clearly states which props are required and which are optional
  - Test components with both defined and undefined prop values to ensure robustness

### Secure WebSocket Connection Pattern

- **Problem**: When accessing the application over HTTPS, WebSocket connections fail with mixed content errors if they use insecure `ws://` protocol
- **Pattern**: Configure Vite to use secure WebSockets when the application is accessed over HTTPS
- **Solution**: Update Vite configuration to handle secure WebSocket connections

```javascript
// In vite.config.js
export default defineConfig({
  // ... other config
  server: {
    // ... other server config
    hmr: {
      // Enable HMR with host-based configuration
      // This lets the browser determine the appropriate protocol
      host: 'job.806040.xyz',
      clientPort: 5173
      // No explicit protocol setting - browser will use wss:// for HTTPS
    }
  }
});
```

- **Key Aspects**:
  - Avoid explicitly setting the WebSocket protocol and let the browser determine it based on the page protocol
  - When the page is loaded over HTTPS, the browser will automatically use secure WebSockets (wss://)
  - When the page is loaded over HTTP, the browser will use regular WebSockets (ws://)
  - Configure `host` to match the domain name used for access
  - This pattern ensures WebSocket connections work properly in both HTTP and HTTPS environments
  - Prevents mixed content errors in modern browsers
  - Works with Nginx Proxy Manager for SSL termination

### Contextual Help Tooltip Pattern

- **Problem**: Explanatory text on UI elements (especially buttons) can make interfaces cluttered and text-heavy
- **Pattern**: Replace inline explanatory text with tooltips that appear only when needed
- **Solution**: Use the BaseTooltip component to provide contextual help without cluttering the UI

```html
<!-- Before: Button with explanatory text -->
<BaseButton
  type="button"
  :variant="primary"
  :disabled="!isValid"
>
  Submit Form
  <span v-if="!isValid" class="text-xs ml-1">
    (requires all fields to be filled)
  </span>
</BaseButton>

<!-- After: Button with tooltip -->
<BaseTooltip
  content="All fields must be filled"
  position="top"
  :disabled="isValid"
>
  <BaseButton
    type="button"
    :variant="primary"
    :disabled="!isValid"
  >
    Submit Form
  </BaseButton>
</BaseTooltip>
```

- **Key Aspects**:
  - Tooltips only appear when needed (typically on hover or focus)
  - The `:disabled` prop on BaseTooltip controls when the tooltip should be shown
  - Tooltip text should be concise and clear (e.g., "Ad type required" instead of "A community must have at least one selected ad type to be active")
  - Tooltips can be positioned relative to the trigger element (top, bottom, left, right)
  - This pattern creates cleaner UI while still providing necessary contextual information
  - Follows modern UI design principles where help is available on demand rather than always visible

### UI Component Animation Pattern

- **Problem**: Static UI components lack visual feedback and feel less interactive
- **Pattern**: Apply consistent animations to UI components for better user experience
- **Solution**: Implement Vue transition components with CSS animations

```html
<!-- Card transition with fade and slide effects -->
<transition name="fade" appear>
  <BaseCard
    variant="bordered"
    class="overflow-hidden card-hover-effect"
  >
    <!-- Card content -->
  </BaseCard>
</transition>

<!-- Table row transitions -->
<transition-group name="row" tag="tbody" class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
  <tr
    v-for="item in items"
    :key="item.id"
    class="hover:bg-gray-50 dark:hover:bg-gray-800 transition-all duration-200"
  >
    <!-- Row content -->
  </tr>
</transition-group>
```

```css
/* CSS animations */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

.row-enter-active,
.row-leave-active {
  transition: all 0.3s ease;
}

.row-enter-from,
.row-leave-to {
  opacity: 0;
  transform: translateX(-10px);
}

.card-hover-effect {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.card-hover-effect:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}
```

- **Key Aspects**:
  - Use Vue's built-in transition components for smooth animations
  - Apply consistent animation patterns across the application
  - Combine fade and transform effects for more natural transitions
  - Use hover effects to provide visual feedback for interactive elements
  - Ensure animations are subtle and enhance rather than distract from the user experience
  - Apply transitions to both initial appearance (with `appear` attribute) and dynamic updates
  - Use transition-group for list items with unique keys

### Sequelize Include Alias and Frontend Data Access Pattern

- **Problem**: Frontend components fail to display associated data (e.g., estimate items) even when the backend API call successfully fetches it, often due to mismatched keys.
- **Solution**: Ensure strict consistency between the `as` alias used in backend Sequelize `include` statements and the property key accessed in the frontend component after data normalization.

```javascript
// 1. Backend Model Association (e.g., models/Estimate.js)
Estimate.hasMany(models.EstimateItem, {
  foreignKey: 'estimate_id',
  as: 'items' // Define the alias here
});

// 2. Backend Controller/Service Query (e.g., services/estimateService.js)
const estimate = await Estimate.findByPk(estimateId, {
  include: [
    {
      model: db.EstimateItem,
      as: 'items' // MUST match the alias defined in the association
    },
    // ... other includes
  ]
});

// 3. Frontend Component Data Access (e.g., EstimateItemPhotos.vue)
// Assuming standardized service returns camelCase data
const estimateResponse = await estimatesService.getById(props.estimateId);

if (estimateResponse.success && estimateResponse.data && Array.isArray(estimateResponse.data.items)) {
  // Access using the camelCased version of the backend alias ('items')
  estimateItems.value = estimateResponse.data.items;
}
```

- **Key Aspects**:
  - The `as` alias defined in the Sequelize model association dictates the key name in the fetched data object.
  - The `include` statement in the backend query *must* use the exact same `as` alias.
  - Frontend components, after any case normalization (e.g., snake_case to camelCase by a service), must access the associated data using the corresponding (potentially normalized) key (e.g., `items` if the alias was `items`).
  - Mismatches (e.g., backend alias `items`, frontend access `estimateItems`) will lead to data not being displayed, even if fetched correctly.
  - Verify aliases in model definitions when debugging missing associated data issues.

### Service Method Empty Result Handling Pattern

- **Problem**: Service methods often don't handle empty result sets properly, causing errors when no data is found
- **Pattern**: Consistent empty result handling pattern with explicit returns and error handling
- **Solution**: Return null or empty arrays for expected empty results, with proper logging

```javascript
// Handle empty result for a single entity
async getCurrentActiveJob() {
  try {
    const activeJob = await Project.findOne({
      where: { type: 'active', status: 'in_progress' },
      include: [...], // Relations
      order: [['updated_at', 'DESC']]
    });

    // If no active job is found, return null without error
    if (!activeJob) {
      logger.info('No active job found');
      return null; // Explicit null return, not an error
    }

    return activeJob;
  } catch (error) {
    logger.error('Error getting current active job:', error);
    throw error; // Only throw for unexpected errors
  }
}

// Handle empty result for collections
async getUpcomingProjects(limit = 5) {
  try {
    const projects = await Project.findAll({
      where: { /* criteria */ },
      include: [...], // Relations
      limit
    });

    // Return empty array if no projects found, not an error
    if (!projects || projects.length === 0) {
      logger.info('No upcoming projects found');
      return [];
    }

    return projects;
  } catch (error) {
    logger.error('Error getting upcoming projects:', error);
    throw error; // Only throw for unexpected errors
  }
}
```

- **Key Aspects**:
  - Distinguish between expected empty results and unexpected errors
  - For single entities: return null for expected empty results
  - For collections: return empty array ([]) for expected empty results
  - Add appropriate logging for both empty results and errors
  - Use try/catch blocks to handle unexpected errors
  - Frontend components handle null and empty array returns properly

### Vector Dimensionality Adaptation Pattern

- **Problem**: Different embedding models produce vectors of varying dimensions, incompatible with database columns of fixed dimension
- **Pattern**: Environment-driven dimension configuration with automatic dimensionality reduction
- **Solution**: Implement a configurable dimension system with runtime adaptation

```javascript
// 1. Environment-based dimension configuration
const EMBED_DIM = parseInt(process.env.EMBEDDING_DIM || '1536', 10);

// 2. Dynamic vector dimension in models
this.VECTOR = () => `vector(${EMBED_DIM})`; // No hardcoded dimensions

// 3. Runtime dimensionality reduction
if (embedding.length > targetDim) {
  logger.info(`Reducing embedding dimensions from ${embedding.length} to ${targetDim}`);
  // Simple striding approach for dimension reduction
  const ratio = embedding.length / targetDim;
  const reducedEmbedding = new Array(targetDim);
  for (let i = 0; i < targetDim; i++) {
    reducedEmbedding[i] = embedding[Math.floor(i * ratio)];
  }
  return reducedEmbedding;
}
```

- **Key Aspects**:
  - Environment variable as single source of truth for vector dimensions
  - Database column type auto-adapts to environment setting
  - Model definitions use dynamic dimension function without hardcoding
  - Automatic dimensionality reduction for oversized vectors
  - Simple striding approach preserves semantic information
  - Database migration ensures schema compatibility
  - Compatible with pgvector's 2000-dimension limit for ivfflat indexes

## AI Provider Management Pattern

- **Problem**: AI features require flexible provider integrations for language tasks and embeddings with clean abstractions
- **Pattern**: Provider-agnostic services with dependency injection and settings-based configuration
- **Solution**: Create abstraction layers for language and embedding services with provider interfaces

```javascript
// Embedding provider with support for multiple providers
class EmbeddingProvider {
  constructor() {
    this._initialized = false;
    this._provider = null;
    this._client = null;
    this._lastApiKey = null;
    this._lastBaseUrl = null;
    this._lastModelName = null;
    this._initPromise = this._initialize();
  }

  async _initialize() {
    // Load provider settings from database or environment variables
    const providerName = await settingsService.getSettingValue(
      'embedding_provider',
      process.env.EMBEDDING_PROVIDER || 'deepseek'
    );

    // Load API key, base URL, and model name for the provider
    const apiKey = await this._getApiKey(providerName);
    const baseUrl = await this._getBaseUrl(providerName);
    const modelName = await this._getModelName(providerName);

    // Initialize the appropriate client based on provider
    if (providerName === 'openai' || providerName === 'gemini') {
      this._client = new OpenAI({
        apiKey: apiKey,
        baseURL: baseUrl,
      });
    }

    this._provider = providerName;
    this._initialized = true;
  }

  // Generate embedding with the configured provider
  async embed(text) {
    // Ensure provider is initialized
    if (!this._initialized) {
      await this._initPromise;
    }

    // Check if embedding is enabled
    const isEnabled = await this.isEnabled();
    if (!isEnabled) {
      return null;
    }

    // Generate embedding based on provider
    if (this._provider === 'openai' || this._provider === 'gemini') {
      const resp = await this._client.embeddings.create({
        model: this._lastModelName,
        input: text,
      });
      return resp.data[0].embedding;
    } else if (this._provider === 'deepseek') {
      // Use the DeepSeek service for this provider
      const deepseekService = require('./deepseekService');
      return await deepseekService.generateEmbedding(text);
    }

    return null;
  }

  // Force reinitialization of the provider (used after settings changes)
  async reinitialize() {
    this._initialized = false;
    this._provider = null;
    this._client = null;
    await this._initialize();
  }
}

// Frontend settings component for AI provider configuration
<BaseFormGroup
  label="Embedding Provider"
  input-id="embeddingProvider"
  helper-text="Select the provider for vector embeddings"
>
  <BaseSelect
    id="embeddingProvider"
    v-model="settings.embedding_provider"
    :options="providerOptions.embedding"
    @change="onEmbeddingProviderChange"
  />
</BaseFormGroup>

// API endpoint for testing connections
async testEmbeddingConnection(req, res) {
  try {
    // Check if embedding is enabled
    const isEnabled = await embeddingProvider.isEnabled();
    if (!isEnabled) {
      return res.status(400).json({
        success: false,
        message: 'Embedding is disabled in settings'
      });
    }

    // Try to generate an embedding
    const embedding = await embeddingProvider.embed('This is a test');

    if (!embedding) {
      return res.status(500).json({
        success: false,
        message: 'Embedding generation failed'
      });
    }

    // Return success with embedding details
    return res.status(200).json({
      success: true,
      message: 'Embedding connection test successful',
      data: {
        provider: await embeddingProvider.getProviderName(),
        model: await embeddingProvider.getModelName(),
        dimensions: embedding.length
      }
    });
  } catch (error) {
    logger.error('Error testing embedding connection:', error);
    return res.status(500).json({
      success: false,
      message: 'Embedding connection test failed',
      error: error.message
    });
  }
}
```

- **Key Aspects**:
  - Provider-agnostic interfaces for language models and embeddings
  - Settings-based configuration with database storage and environment variable fallbacks
  - Support for multiple providers (DeepSeek, OpenAI, Gemini) through a consistent API
  - Settings UI for managing API keys, base URLs, and model selection
  - Connection testing capabilities to verify API credentials
  - Just-in-time provider initialization to reduce startup overhead
  - Support for runtime provider switching with reinitialize method
  - Seamless integration with existing services (workTypeDetectionService)
  - Error handling and logging throughout the provider lifecycle
  - Admin-only access controls for sensitive API configuration

### Vue Component Data Initialization Pattern

- **Problem**: Vue components can throw "Cannot read properties of undefined (reading 'length')" errors when accessing properties of data that hasn't been loaded yet
- **Pattern**: Defensive data initialization with fallbacks and proper error handling
- **Solution**: Initialize reactive data with appropriate default values and add fallback handling in data processing

```javascript
// 1. Initialize reactive data with appropriate default values
const communities = ref([]); // Initialize as empty array, not undefined

// 2. Add fallback handling when setting data from API responses
const loadCommunities = async () => {
  try {
    const result = await communityService.getAllCommunities(filters);
    // Ensure communities is always an array, even if API returns null/undefined
    communities.value = result || [];
  } catch (err) {
    console.error('Failed to load communities:', err);
    error.value = 'Failed to load communities. Please try again.';
    // Reset to empty array on error to prevent undefined errors
    communities.value = [];
  }
};

// 3. Use optional chaining and nullish coalescing in computed properties
const filteredCommunities = computed(() => {
  return (communities.value || []).filter(c => {
    return c?.name?.toLowerCase().includes(searchQuery.value.toLowerCase());
  });
});

// 4. Defensive template rendering with v-if
<div v-if="communities && communities.length > 0" class="communities-grid">
  <!-- Render communities -->
</div>
<div v-else-if="!loading" class="empty-state">
  <p>No communities found.</p>
</div>
```

- **Key Aspects**:
  - Initialize reactive data with appropriate default values (empty arrays for collections, objects with default properties)
  - Add fallback handling when setting data from API responses using logical OR (`result || []` for arrays, `{...defaults, ...data}` for objects)
  - Reset collections to empty arrays or objects to default values on error to prevent undefined errors
  - Use optional chaining (`?.`) and nullish coalescing (`||`) in templates and computed properties
  - Implement defensive template rendering with proper v-if conditions
  - Check for both existence and length when rendering collections
  - Use two-step form reset and population to prevent stale data issues
  - Add validation in methods to check for required values before API calls
  - Enhance utility methods like formatDate() and formatPhone() with robust error handling

### Entity ID Dual Property Pattern

- **Problem**: Different components across the application may use different property names (`id` vs `clientId`) to reference the same entity ID, causing validation errors and data inconsistencies.
- **Solution**: Implement normalization functions that include both property names with the same value:

```javascript
// In utils/casing.js normalizeClient function
return {
  id: clientId,
  clientId: clientId, // Include both property names with the same value
  displayName: displayName,
  // ... other properties
};
```

- **Key Aspects**:
  - Maintain backward compatibility by supporting both property naming conventions
  - Ensure normalization functions include both `id` and `[entity]Id` properties
  - Use consistent property access patterns in validation functions
  - Document the dual property pattern in code comments for clarity
  - This approach supports the ongoing standardization effort while preventing errors during the transition

### Communities Module Pattern

- **Problem**: Mobile home communities need to manage newsletter advertisements with different sizes, costs, and term periods
- **Pattern**: Implement a hierarchical data structure with Communities containing multiple AdTypes and a selected active type
- **Solution**: Create models, services, and UI components that manage the relationship between communities and their advertisement types

```javascript
// 1. Community model with ad specialist contact info and selected ad type
Community.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  // Basic community info (address, city, etc.)
  // Ad specialist contact information
  ad_specialist_name: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'ad_specialist_name'
  },
  ad_specialist_email: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'ad_specialist_email'
  },
  ad_specialist_phone: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'ad_specialist_phone'
  },
  // Reference to the currently selected ad type
  selected_ad_type_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'ad_types',
      key: 'id'
    },
    field: 'selected_ad_type_id'
  },
  // Active status based on current advertising
  is_active: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: false,
    field: 'is_active'
  }
});

// 2. AdType model with dimensions, cost, and term periods
AdType.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  community_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'communities',
      key: 'id'
    },
    field: 'community_id'
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  width: {
    type: DataTypes.DECIMAL(5, 2),
    allowNull: true,
    defaultValue: 0
  },
  height: {
    type: DataTypes.DECIMAL(5, 2),
    allowNull: true,
    defaultValue: 0
  },
  cost: {
    type: DataTypes.DECIMAL(10, 1),
    allowNull: true,
    defaultValue: 0
  },
  // Contract dates and terms
  start_date: {
    type: DataTypes.DATE,
    allowNull: true,
    field: 'start_date'
  },
  end_date: {
    type: DataTypes.DATE,
    allowNull: true,
    field: 'end_date'
  },
  deadline_date: {
    type: DataTypes.DATE,
    allowNull: true,
    field: 'deadline_date'
  },
  term_months: {
    type: DataTypes.DECIMAL(3, 1),
    allowNull: true,
    field: 'term_months'
  }
});

// 3. Frontend service with case conversion
class CommunityService {
  async getAllCommunities(filters = {}) {
    try {
      const snakeCaseFilters = toSnakeCase(filters);
      const response = await apiClient.get('/communities', { params: snakeCaseFilters });
      return toCamelCase(response.data.data);
    } catch (error) {
      console.error('Error fetching communities:', error);
      throw error;
    }
  }

  // Other methods for CRUD operations...
}
```

- **Key Aspects**:
  - Communities have basic information plus ad specialist contact details
  - Each community can have multiple ad types with different dimensions and costs
  - The selected_ad_type_id field points to the currently active advertisement
  - Ad types track contract details like start date, end date, and deadline date
  - The UI provides separate sections for community info, ad specialist contacts, and ad types
  - Modal interfaces handle all CRUD operations with proper data validation
  - Standardized services ensure proper case conversion between frontend and backend

## Vector Embeddings and Similarity Search Patterns

### Vector Embedding Generation Pattern

- **Problem:** Need consistent vector embeddings for text similarity search that works with different embedding providers
- **Pattern:** Standardized embedding generation with typed array support
- **Solution:** Create a unified interface for embedding generation with proper error handling and type conversion

```javascript
// Embedding generation with provider abstraction
async function generateEmbedding(text) {
  // Get the configured provider
  const provider = await embeddingProviderFactory.getProvider();

  try {
    // Generate embedding using the provider
    const embedding = await provider.embed(text);

    // Handle typed arrays (Float32Array, etc.)
    if (ArrayBuffer.isView(embedding)) {
      return Array.from(embedding);
    }

    // Validate the embedding
    if (!embedding || !Array.isArray(embedding) || embedding.length === 0) {
      logger.warn('Invalid embedding returned from provider');
      return null;
    }

    return embedding;
  } catch (error) {
    logger.error(`Error generating embedding: ${error.message}`);
    return null;
  }
}
```

- **Key Aspects:**
  - Provider abstraction allows switching embedding models without changing code
  - Support for both plain arrays and typed arrays (Float32Array) from different providers
  - Type checking with ArrayBuffer.isView() to detect typed arrays
  - Consistent error handling with detailed logging
  - Embedding validation ensures downstream processes receive valid data
  - Null return for invalid embeddings allows graceful fallbacks
  - Configuration from environment variables or database settings

### Vector Similarity Search Pattern

- **Problem:** Need efficient vector similarity search in PostgreSQL
- **Pattern:** Properly formatted vector literals with pgvector
- **Solution:** Convert JavaScript arrays to pgvector-compatible format with proper casting

```javascript
// Convert embedding to pgvector literal format
function formatVectorForPgVector(vec) {
  // Accept plain arrays or typed arrays
  if (!Array.isArray(vec)) {
    if (ArrayBuffer.isView(vec)) vec = Array.from(vec);
    else {
      logger.warn(`Embedding is not iterable: ${typeof vec}`);
      return null;
    }
  }

  // Format with controlled precision for consistent representation
  return '[' + vec.map(v => Number(v.toFixed(6))).join(',') + ']';
}

// Use in SQL query with proper casting
const vectorQuery = `
  SELECT id, name, 1 - (name_vec <=> $1::vector) AS score
  FROM work_types
  WHERE name_vec IS NOT NULL
  ORDER BY score DESC
  LIMIT 10;
`;

// Execute query with proper binding
const results = await sequelize.query(vectorQuery, {
  bind: [vectorLiteral], // Pass vector as string literal with proper casting
  type: sequelize.QueryTypes.SELECT,
  raw: true
});

// Filter results with null check
const filteredResults = results
  .filter(r => r.score !== null && r.score > 0.60)
  .slice(0, 5);
```

- **Key Aspects:**
  - Proper handling of typed arrays (Float32Array) common in ML libraries
  - Precision control with toFixed(6) for consistent vector representation
  - Explicit ::vector casting in SQL to ensure proper type conversion
  - Proper parameter binding to prevent SQL injection
  - Null check in filter to prevent runtime errors
  - Variable scope management for proper access to query results
  - Fallback to trigram similarity when vector search fails
