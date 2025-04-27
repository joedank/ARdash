# Work Types Table Fix

## Issue Summary

The work_types table was referenced by two April-2025 migrations before it was created, causing the app to crash with the error "relation 'work_types' does not exist".

## Specific Issues

1. **Incorrect Migration Order**
   - `20250421000000-add-work-types-to-assessments.js` and `20250422-phase-b-work-types-enhancement.js` contained `ALTER TABLE work_types` statements
   - The table was only created in `20250425000000-create-work-types-tables.js`, which ran after these migrations
   - A later duplicate (`20250525000000-create-work-types-table.js`) would try to recreate the table and fail on reruns

2. **Multiple pgvector Extension Migrations**
   - Multiple migrations were trying to create the pgvector extension
   - This could lead to conflicts and errors

3. **Client View Migration Error**
   - The `20250423-drop-client-view.js` migration was trying to import modules that don't exist
   - This was causing the migration to fail

## Fixes Implemented

1. **Moved Problematic Migrations to Archive**
   - Moved `20250421000000-add-work-types-to-assessments.js` to `_archive/`
   - Moved `20250422-phase-b-work-types-enhancement.js` to `_archive/`
   - Moved `20250525000000-create-work-types-table.js` to `_archive/` (duplicate creator)
   - Moved `20250427000000-add-pgvector-extension.js` to `_archive/` (duplicate pgvector extension)
   - Moved `20250530000000-add-pgvector-support.js` to `_archive/` (duplicate pgvector extension)

2. **Fixed Client View Migration**
   - Simplified the `20250423-drop-client-view.js` migration to just drop the view without trying to recreate it
   - Removed dependencies on external modules that don't exist

3. **Created Direct SQL Script**
   - Created `fix-database.sh` script to manually create the work_types table and related tables
   - Added proper checks for existing constraints and indices
   - Fixed syntax errors in constraint creation

## Validation Steps

To verify that the fixes are working correctly:

1. Run the fix-database.sh script:
   ```bash
   chmod +x fix-database.sh
   ./fix-database.sh
   ```

2. Restart the services:
   ```bash
   ./docker-services.sh restart
   ```

3. Check that the work_types table exists in the database:
   ```bash
   docker exec -i management-db-1 psql -U postgres -d management_db -c "\d work_types"
   ```

4. Verify that all migrations are up and none are pending:
   ```bash
   docker exec -i management-api-1 npx sequelize-cli db:migrate:status
   ```

## Future Recommendations

1. **Follow Migration Order Best Practices**
   - Always create tables before referencing them in other migrations
   - Use a consistent naming convention for migrations that includes a timestamp prefix
   - Ensure that migrations are ordered correctly based on dependencies

2. **Make All Migrations Idempotent**
   - Always check if tables/columns exist before creating them
   - Use DO blocks with IF NOT EXISTS checks for constraints and indices
   - Add early exit conditions to avoid unnecessary work

3. **Avoid Duplicate Migrations**
   - Before creating a new migration, check if a similar one already exists
   - Use a centralized migration tracking system to avoid duplicates
   - Consider using a migration generator tool to ensure consistent naming and structure

4. **Test Migrations in Development**
   - Always test migrations in a development environment before deploying to production
   - Create a test database and run migrations against it to catch errors early
   - Use a migration testing framework to automate testing
