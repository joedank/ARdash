# Migration Order Fix

## Issue Summary

The work_types table was referenced by two April-2025 migrations before it was created, causing the app to crash with the error "relation 'work_types' does not exist".

## Specific Issues

1. **Incorrect Migration Order**
   - `20250421000000-add-work-types-to-assessments.js` and `20250422-phase-b-work-types-enhancement.js` contained `ALTER TABLE work_types` statements
   - The table was only created in `20250425000000-create-work-types-tables.js`, which ran after these migrations
   - A later duplicate (`20250525000000-create-work-types-table.js`) would try to recreate the table and fail on reruns

## Fixes Implemented

1. **Moved Problematic Migrations to Archive**
   - Moved `20250421000000-add-work-types-to-assessments.js` to `_archive/`
   - Moved `20250422-phase-b-work-types-enhancement.js` to `_archive/`
   - Moved `20250525000000-create-work-types-table.js` to `_archive/` (duplicate creator)

2. **Enhanced Idempotency of Remaining Migration**
   - Added an additional guard at the top of `20250425000000-create-work-types-tables.js` to check if the table exists and exit early if it does
   - This ensures the migration is safe to run multiple times

## Validation Steps

To verify that the fixes are working correctly:

1. Run the application:
   ```bash
   docker compose up api
   ```

2. The server should start without SQL errors related to the work_types table

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
   - Use `IF NOT EXISTS` clauses when creating tables, columns, or constraints
   - Add early exit conditions to avoid unnecessary work

3. **Avoid Duplicate Migrations**
   - Before creating a new migration, check if a similar one already exists
   - Use a centralized migration tracking system to avoid duplicates
   - Consider using a migration generator tool to ensure consistent naming and structure
