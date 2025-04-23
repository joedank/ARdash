# Database Management Tools

## Overview

This directory contains documentation and tools for managing the database schema and migrations in the Construction Management Web Application.

## Tools

### View Management System

The View Management System provides a structured approach to handle database views during schema changes, preventing errors like the one encountered with `client_view`.

Key components:
- `ViewManager` class in `utils/viewManager.js`
- View definitions registry in `config/viewDefinitions.js`

### Dependency Analysis Utilities

These utilities identify database dependencies before migrations run, preventing errors caused by linked objects like views, triggers, or foreign keys.

Key components:
- `DependencyAnalyzer` class in `utils/dependencyAnalyzer.js`
- `MigrationChecker` class in `utils/migrationChecker.js`

### Migration Testing Framework

This framework enables safe testing of migrations before applying them to production, allowing developers to verify changes won't break the application.

Key components:
- `MigrationTester` class in `utils/migrationTester.js`
- `DatabaseVerifier` class in `utils/databaseVerifier.js`

### Documentation System

This system ensures that database structure is well-documented and keeps the documentation in sync with the actual schema.

Key components:
- `DocumentationGenerator` class in `utils/documentationGenerator.js`

### Model-Database Alignment Tool

This tool ensures that Sequelize models accurately reflect the database schema and generates migrations to fix any mismatches.

Key components:
- `ModelSchemaComparer` class in `utils/modelSchemaComparer.js`
- `ModelSyncTool` class in `utils/modelSyncTool.js`
- Migration generator script in `scripts/generate-fix-migration.js`

## Usage

### Running the Immediate Fix Migration

```bash
# First, backup the database
docker exec -i management-db-1 pg_dump -U postgres management_db > /Volumes/4TB/Users/josephmcmyne/myProjects/management/database/backups/management_db_$(date +%Y%m%d_%H%M%S).sql

# Then, run the migration
cd /Volumes/4TB/Users/josephmcmyne/myProjects/management/backend
npx sequelize-cli db:migrate
```

### Checking for Model-Schema Mismatches

```bash
node src/scripts/generate-fix-migration.js
```

### Testing a Specific Migration

```bash
node src/scripts/test-payment-terms-migration.js
```

### Running the Documentation Generator

```bash
node src/scripts/generate-documentation.js
```

## Documentation

This directory contains auto-generated documentation about the database schema:

- `schema.md`: Detailed information about tables and columns
- `views.md`: Definitions and dependencies of database views
- `relationships.md`: Foreign key relationships between tables
- `indices.md`: Indices defined on database tables

These files are generated using the DocumentationGenerator tool.

## Migration Best Practices

1. **Always check for dependencies before modifying columns**
   - Use the `MigrationChecker` to identify views or other objects that depend on the column
   - Handle these dependencies explicitly in your migration

2. **Use transactions for complex migrations**
   - Always wrap multi-step migrations in transactions
   - Ensure all steps either succeed together or fail together

3. **Test migrations before applying to production**
   - Use the `MigrationTester` to verify migrations work correctly
   - Create a backup before testing

4. **Document view definitions**
   - Add all view definitions to the `viewDefinitions.js` file
   - This ensures views can be properly recreated during migrations

5. **Keep models in sync with the database**
   - Use `ModelSchemaComparer` to identify discrepancies
   - Generate migrations to fix mismatches

## Troubleshooting

If you encounter issues with migrations:

1. Check for dependent views with:
   ```javascript
   const ViewManager = require('../src/utils/viewManager');
   const viewManager = new ViewManager(queryInterface);
   const dependentViews = await viewManager.getDependentViews('table_name');
   console.log(dependentViews);
   ```

2. Verify database integrity with:
   ```javascript
   const DatabaseVerifier = require('../src/utils/databaseVerifier');
   const verifier = new DatabaseVerifier(queryInterface);
   const viewStatus = await verifier.verifyViews();
   console.log(viewStatus);
   ```

3. Generate a complete schema documentation to understand relationships:
   ```bash
   node src/scripts/generate-documentation.js
   ```