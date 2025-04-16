#!/bin/bash

# Script to run the SQLite to PostgreSQL migration

# Install required Python packages if not already installed
echo "Installing required Python packages..."
pip3 install psycopg2-binary

# Make the migration script executable
chmod +x migrate_sqlite_to_postgres.py

# Run the migration script
echo "Running migration script..."
python3 migrate_sqlite_to_postgres.py

# Backup the PostgreSQL database after migration
echo "Creating backup of PostgreSQL database after migration..."
docker exec -i management-db-1 pg_dump -U postgres management_db > /Volumes/4TB/Users/josephmcmyne/myProjects/management/database/backups/management_db_post_migration_$(date +%Y%m%d_%H%M%S).sql

echo "Migration process completed!"
