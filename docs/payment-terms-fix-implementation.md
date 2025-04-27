# Payment Terms Column Fix Implementation Guide

This guide provides instructions for implementing the fix for the `payment_terms` column type change error.

## Background

The application has been experiencing errors when trying to change the type of the `payment_terms` column in the `clients` table:

```
ERROR: cannot alter type of a column used by a view or rule
DETAIL: rule _RETURN on view client_view depends on column "payment_terms"
```

This error occurs because PostgreSQL prevents altering columns that are referenced by views without first dropping those views.

## Implementation Steps

### 1. Backup the Database

Before proceeding, create a backup of the database:

```bash
# Using the script
./backup-database.sh

# Or manually
docker exec -i management-db-1 pg_dump -U postgres management_db > /Volumes/4TB/Users/josephmcmyne/myProjects/management/database/backups/management_db_$(date +%Y%m%d_%H%M%S).sql
```

### 2. Run the Test Script

The test script verifies that the ViewManager utility works correctly without making permanent changes:

```bash
# Navigate to the scripts directory
cd /Volumes/4TB/Users/josephmcmyne/myProjects/management/scripts

# Run the test script
node test-view-manager.js
```

Review the output to ensure the ViewManager properly identifies view dependencies and can handle dropping and recreating views.

### 3. Apply the Migration

Run the migration to fix the column type:

```bash
# In development environment
cd /Volumes/4TB/Users/josephmcmyne/myProjects/management/backend
npx sequelize-cli db:migrate

# In Docker environment
docker exec -it management-backend-1 npx sequelize-cli db:migrate
```

The migration will:
1. Start a transaction
2. Use ViewManager to identify dependent views
3. Drop the dependent views
4. Change the column type
5. Recreate the views
6. Commit the transaction

### 4. Verify the Fix

After the migration completes, verify that:

1. The `payment_terms` column type has been changed:

```sql
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'clients' AND column_name = 'payment_terms';
```

2. The `client_view` view still exists and works correctly:

```sql
SELECT COUNT(*) FROM client_view;
```

3. The database startup no longer shows errors related to the column type change.

### 5. Restart the Backend Service

Restart the backend service to apply the changes:

```bash
# Using the services script
./docker-services.sh restart backend

# Or directly with Docker
docker restart management-backend-1
```

## Rollback Procedure

If issues occur, follow the rollback procedure in the [Migration Rollback Guide](migration-rollback-guide.md).

## Files Implemented

This fix includes the following files:

1. `/backend/migrations/20250424-fix-payment-terms-column.js` - Migration to fix the column type
2. `/backend/src/utils/ViewManager.js` - Utility class for managing view dependencies
3. `/backend/src/config/viewDefinitions.js` - Registry of view definitions
4. `/scripts/test-view-manager.js` - Test script for the ViewManager utility
5. `/docs/database-view-management.md` - Documentation for the ViewManager
6. `/docs/migration-rollback-guide.md` - Guide for rolling back migrations
7. `/docs/payment-terms-fix-implementation.md` - This implementation guide

## Next Steps

After implementing this fix:

1. Update any application code that relies on the specific type of the `payment_terms` field
2. Consider updating the Sequelize model to explicitly define the column type as VARCHAR(255)
3. Add view dependencies to your migration planning process
4. Ensure future migrations handle view dependencies using the ViewManager utility

## Support

If you encounter issues during implementation, consult the following resources:

1. Migration Rollback Guide
2. Database View Management documentation
3. PostgreSQL errors and logs
4. Contact the development team for assistance
