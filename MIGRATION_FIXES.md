# Migration Fixes

## Issue Summary

Migrations were not idempotent, causing the following issues:
- They referenced dropped columns (assessment_id)
- They recreated existing constraints
- This forced the container into an endless restart loop

## Specific Issues

1. **assessment_id Column Reference**
   - `20250408000001-migrate-scope-to-condition.js` was querying the obsolete `assessment_id` column
   - The Project model still had the `assessment_id` attribute and associations

2. **Duplicate Constraint Creation**
   - `20250414161844-create-estimate-item-additional-work.js` recreated a relation already made by `20250414053000-create-estimate-item-additional-work.js`
   - This violated the one-migration-per-change rule

## Fixes Implemented

1. **Fixed scope-to-condition Migration**
   - Completely rewrote `20250408000001-migrate-scope-to-condition.js` to be idempotent
   - Now it checks if the `scope` column exists and the `condition` column doesn't exist before making changes
   - Removed all references to `assessment_id`

2. **Removed Duplicate Migration**
   - Moved `20250414161844-create-estimate-item-additional-work.js` to `_archive` directory
   - Made `20250414053000-create-estimate-item-additional-work.js` idempotent by adding checks for existing tables and indices

3. **Updated Project Model**
   - Removed `assessment_id` attribute from the Project model
   - Renamed `scope` to `condition` to match the database schema
   - Removed associations that referenced `assessment_id`

4. **Made All Migrations Idempotent**
   - Added checks for existing tables, columns, and constraints before trying to create or modify them
   - Added detailed logging to help diagnose issues
   - Made down migrations safer by checking if tables exist before trying to drop them

## Validation Steps

To verify that the fixes are working correctly:

1. Run the container:
   ```bash
   docker compose up --build api
   ```

2. Check that the container reaches "Server listening..." without errors

3. Inside the container, check migration status:
   ```bash
   docker exec -it management-api-1 npx sequelize-cli db:migrate:status
   ```
   All migrations should be listed as "up"

4. Check the projects table structure:
   ```bash
   docker exec -it management-db-1 psql -U postgres -d management_db -c "\d projects"
   ```
   It should show a `condition` column and no `assessment_id` column

## Future Recommendations

1. **Always Make Migrations Idempotent**
   - Check if tables/columns exist before creating them
   - Check if constraints exist before adding them
   - Use `ifNotExists` option when available

2. **Follow One-Migration-Per-Change Rule**
   - Each database change should have exactly one migration
   - Avoid duplicate migrations that create the same tables or constraints

3. **Keep Models in Sync with Database Schema**
   - Update models when database schema changes
   - Remove references to dropped columns
   - Add new columns to models when they're added to the database
