#!/bin/bash

# STEP 1: Find the Docker container IDs
BACKEND_CONTAINER=$(docker ps -qf "name=management-backend-1")
DB_CONTAINER=$(docker ps -qf "name=management-db-1")

if [ -z "$BACKEND_CONTAINER" ]; then
  echo "Backend container not found. Is the service running?"
  exit 1
fi

if [ -z "$DB_CONTAINER" ]; then
  echo "Database container not found. Is the service running?"
  exit 1
fi

echo "Found backend container: $BACKEND_CONTAINER"
echo "Found database container: $DB_CONTAINER"

# STEP 2: Install pgvector extension in the database container
echo "Installing pgvector extension in PostgreSQL..."
docker exec $DB_CONTAINER psql -U postgres management_db -c "CREATE EXTENSION IF NOT EXISTS vector;"

# STEP 3: Run the migration to add the embedding column
echo "Running database migration to add embedding column..."
docker exec $BACKEND_CONTAINER npx sequelize-cli db:migrate

# STEP 4: Run the embedding backfill
echo "Running embedding backfill for existing products..."
docker exec $BACKEND_CONTAINER node src/scripts/embed-backfill.js

echo "Vector search setup completed successfully!"
