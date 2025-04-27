# Docker and BullMQ Configuration Fix

This document outlines the issues identified with the Docker and BullMQ configuration and the steps taken to fix them.

## Issues Identified

1. **BullMQ Redis Configuration Issue**
   - Error: "BullMQ: Your redis options maxRetriesPerRequest must be null"
   - Both embedding and estimate workers were affected

2. **Settings Table Missing**
   - Error: "Error getting setting value 'deepseek_model': relation 'settings' does not exist"
   - The settings table was not being created before the workers tried to access it

3. **DeepSeek Embedding API 404 Error**
   - Error: "Error generating embedding: 404 status code (no body)"
   - The DeepSeek embedding model specified in the settings was not available

4. **Migration Errors**
   - Error: "Cannot find module '/app/backend/src/models'" when running migrations
   - Error: "column Project.assessment_id does not exist" in scope migration
   - Error: "column client_id of relation invoices already exists" in standardize-id-fields migration
   - Error: "column client_fk_id does not exist" when reverting to older database implementations
   - Error: "relation estimate_item_additional_work_estimate_item_id already exists"
   - Migrations were failing due to path issues, missing columns, deprecated column references, and duplicate relations

## Solutions Implemented

### 1. Fixed Redis Connection Configuration

- Added `maxRetriesPerRequest: null` to Redis connection options in both worker files
- This addresses the specific BullMQ error

### 2. Fixed Settings Table and Default Values

- Created a SQL script (`02-create-settings-table.sql`) to create the settings table if it doesn't exist
- Added default values for `deepseek_embedding_model`, `embedding_provider`, and `enable_vector_similarity`
- Created a migration file (`20250426000000-create-settings-table.js`) to ensure the settings table exists
- Updated `docker-compose.yml` to include the new SQL script in the database initialization
- Updated `docker-entrypoint.sh` to run migrations before starting the server
- Created a direct SQL script (`create-settings-table.sh`) to create the settings table without relying on migrations

### 3. Fixed Migration Issues

- Made migrations idempotent by adding checks for existing columns and constraints
- Added detailed logging to help diagnose issues
- Ensured the uuid-ossp extension is enabled for UUID generation
- Added direct SQL fixes for common migration issues
- Fixed the "column client_id of relation invoices already exists" error
- Created a new migration to handle the case where client_fk_id is deprecated
- Added checks for the "relation estimate_item_additional_work_estimate_item_id already exists" error
- Updated SQL scripts to check if tables and relations exist before trying to modify them
- This makes migrations more robust and less likely to fail due to database state inconsistencies

### 4. Enhanced EmbeddingProvider Service

- Added fallback mechanism in `embeddingProvider.js` to handle 404 errors
- If the specified model returns a 404, it will automatically try the OpenAI `text-embedding-3-small` model
- Added detailed error logging to help diagnose issues

### 5. Created Reset Script

- Created `reset-db-and-restart.sh` to easily reset the database and restart the services
- This script removes the database volume, starts the database, runs migrations, and starts the services

## How to Apply the Fix

### Option 1: All-in-One Fix Script (Recommended)

This approach uses a single script that creates the settings table and restarts the services, bypassing migrations entirely:

```bash
# Make the script executable if needed
chmod +x fix-settings-and-restart.sh

# Run the all-in-one fix script
./fix-settings-and-restart.sh
```

### Option 2: Direct SQL Fix

This approach directly creates the settings table and inserts the required values using SQL, but requires you to restart services manually:

```bash
# Make the script executable if needed
chmod +x create-settings-table.sh

# Run the script to create the settings table
./create-settings-table.sh

# Restart the services
docker compose restart backend embedding-worker estimate-worker
```

### Option 3: Full Reset (For Fresh Start)

This will completely reset the database and start fresh:

```bash
# Make the script executable if needed
chmod +x reset-db-and-restart.sh

# Run the reset script
./reset-db-and-restart.sh
```

### Option 4: Apply Changes Without Database Reset

If you want to keep your existing data but use the migration approach:

1. Update the Docker Compose file:

   ```bash
   docker compose down
   ```

2. Fix the migration files:
   - We've updated the migration files to use absolute paths for models
   - This should prevent the "Cannot find module '../models'" error

3. Run the migrations:

   ```bash
   docker compose run --rm backend npx sequelize-cli db:migrate
   ```

4. Restart the services:

   ```bash
   docker compose up -d backend embedding-worker estimate-worker
   ```

## Verifying the Fix

After applying the fix, you can verify that everything is working correctly:

1. Check the logs for the embedding worker:

   ```bash
   docker compose logs -f embedding-worker
   ```

2. Check the logs for the estimate worker:

   ```bash
   docker compose logs -f estimate-worker
   ```

3. Check the logs for the backend:

   ```bash
   docker compose logs -f backend
   ```

You should see messages indicating that the workers have started successfully and no errors related to Redis configuration or missing settings.

## Additional Recommendations

1. **Worker Health Monitoring**
   - Implement a health check endpoint for workers
   - Add periodic self-diagnostics to verify Redis and database connectivity

2. **Improved Job Error Recovery**
   - Add automatic retries with exponential backoff for transient failures
   - Implement a dead letter queue for permanently failed jobs

3. **Redis Connection Pooling**
   - Consider implementing a Redis connection pool for better resource management
   - Add connection event listeners to handle connection errors

4. **Configuration Management**
   - Create an admin UI for managing embedding model settings
   - Add environment variable fallbacks for all settings

5. **Performance Optimization**
   - Add metrics collection for job processing times
   - Implement job batching for embedding tasks
   - Consider adding a caching layer for frequently used embeddings
