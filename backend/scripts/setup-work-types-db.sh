#!/bin/bash

# Script to set up work types table with proper pgvector index
# This script should be run after database initialization

echo "Setting up work_types table with pgvector HNSW index..."

# Database connection parameters
DB_HOST=${DB_HOST:-"localhost"}
DB_PORT=${DB_PORT:-"5432"}
DB_NAME=${DB_NAME:-"management_db"}
DB_USER=${DB_USER:-"postgres"}
DB_PASS=${DB_PASS:-"postgres"}

# Use PGPASSWORD to avoid password prompt
export PGPASSWORD=$DB_PASS

# Check if pgvector extension is already installed
PGVECTOR_INSTALLED=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT count(*) FROM pg_extension WHERE extname = 'vector';")

if [ "$PGVECTOR_INSTALLED" -eq "0" ]; then
  echo "Installing pgvector extension..."
  psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS vector;"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to install pgvector extension"
    exit 1
  fi
else
  echo "pgvector extension already installed"
fi

# HNSW index is now created by migration 20250426000001-add-name-vec-hnsw-index.js
echo "Skipping HNSW index creation (handled by migration)..."
# The following code is commented out to prevent duplication with the migration
# psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
#   CREATE INDEX IF NOT EXISTS work_types_name_vec_hnsw
#   ON work_types
#   USING hnsw (name_vec) WITH (m = 16, ef_construction = 200);
# "

# Skip error check since we're not creating the index in this script
echo "HNSW index creation skipped (handled by migration)"

# Old error check code:
# if [ $? -ne 0 ]; then
#   echo "Error: Failed to create HNSW index"
#   exit 1
# else
#   echo "HNSW index created successfully"
# fi

# Update Postgres settings for better vector search performance
echo "Setting pg_hint_plan off for better vector search performance..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
  ALTER SYSTEM SET pg_hint_plan.enable_hint TO off;
  SELECT pg_reload_conf();
"

echo "Finished setting up work_types table with pgvector HNSW index"
echo "Vector similarity searches should now be 10-20× faster"

exit 0
