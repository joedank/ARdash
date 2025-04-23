#!/bin/bash

# Create a backup directory if it doesn't exist
mkdir -p database/backups

# Generate a timestamp for the backup file
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="database/backups/management_db_${TIMESTAMP}.sql"

# Backup the database
echo "Creating database backup to $BACKUP_FILE..."
docker exec -i management-db-1 pg_dump -U postgres management_db > "$BACKUP_FILE"

echo "Backup completed successfully!"
