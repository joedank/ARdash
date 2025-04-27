# Migration Rollback Guide

This document provides instructions for rolling back migrations in case issues occur during the migration process.

## Rolling Back a Specific Migration

If a specific migration fails or causes issues, you can roll it back using the Sequelize CLI:

```bash
# In development environment
cd backend
npx sequelize-cli db:migrate:undo --name 20250424-fix-payment-terms-column.js

# In Docker environment
docker exec -it management-backend-1 npx sequelize-cli db:migrate:undo --name 20250424-fix-payment-terms-column.js
```

## Rolling Back the Most Recent Migration

To undo the most recent migration:

```bash
# In development environment
cd backend
npx sequelize-cli db:migrate:undo

# In Docker environment
docker exec -it management-backend-1 npx sequelize-cli db:migrate:undo
```

## Rolling Back to a Specific Migration

To roll back to a specific migration (undoing all migrations after it):

```bash
# In development environment
cd backend
npx sequelize-cli db:migrate:undo:all --to YYYYMMDDHHMMSS-migration-name.js

# In Docker environment
docker exec -it management-backend-1 npx sequelize-cli db:migrate:undo:all --to YYYYMMDDHHMMSS-migration-name.js
```

## Using Database Backups

If migration rollbacks don't resolve the issue, you can restore from a backup:

```bash
# Restore from a specific backup
pg_restore -U postgres -d management_db /path/to/backup.sql

# In Docker environment
docker exec -i management-db-1 psql -U postgres -d management_db < /Volumes/4TB/Users/josephmcmyne/myProjects/management/database/backups/backup_file.sql
```

## Handling View Dependencies During Rollback

When rolling back migrations that involve views, ensure the following:

1. The rollback migration properly drops and recreates any dependent views
2. If rolling back manually with SQL, follow these steps:
   
   ```sql
   BEGIN;
   
   -- Drop dependent views
   DROP VIEW IF EXISTS client_view;
   
   -- Revert column changes
   ALTER TABLE clients ALTER COLUMN payment_terms TYPE text;
   
   -- Recreate views
   CREATE OR REPLACE VIEW client_view AS
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
   FROM clients;
   
   COMMIT;
   ```

## Recovery Checklist

If issues occur during migration:

1. Check the logs for specific error messages
2. Attempt a rollback of the problematic migration
3. Verify database integrity after rollback
4. If rollback fails, restore from backup
5. Test views and dependent functionality after recovery
6. Document the issue and solution for future reference

## Prevention Tips

To prevent migration issues:

1. Always create a backup before running migrations
2. Test migrations in development environment first
3. Use transactions in migrations for atomicity
4. Handle view dependencies properly with ViewManager
5. Keep the view definitions registry updated
6. Include both `up` and `down` functions in migrations

For questions or assistance with complex rollbacks, consult the database administrator.
