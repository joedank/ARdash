#!/bin/bash

echo "Checking database backup file..."
BACKUP_FILE="/Volumes/4TB/Users/josephmcmyne/myProjects/management/database/backups/management_db_20250414_145056.sql"

if [ -f "$BACKUP_FILE" ]; then
    echo "✅ Backup file exists at: $BACKUP_FILE"
    echo "File size: $(du -h "$BACKUP_FILE" | cut -f1)"
    echo "First few lines of the backup file:"
    head -n 10 "$BACKUP_FILE"
else
    echo "❌ Error: Backup file not found at: $BACKUP_FILE"
    echo "Please make sure the backup file exists before starting Docker."
fi
