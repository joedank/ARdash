#!/bin/bash

# Script to migrate SQLite database to PostgreSQL using pgloader

# Define paths and connection details
SQLITE_DB_PATH="/Volumes/4TB/Users/josephmcmyne/myProjects/management/database.sqlite"
PG_HOST="localhost"
PG_PORT="5432"
PG_DB="management_db"
PG_USER="postgres"
PG_PASSWORD="postgres"  # Change this if your password is different

# Create a pgloader configuration file
cat > migration.load << EOF
LOAD DATABASE
    FROM sqlite://$SQLITE_DB_PATH
    INTO postgresql://$PG_USER:$PG_PASSWORD@$PG_HOST:$PG_PORT/$PG_DB

WITH include drop, create tables, create indexes, reset sequences
     set work_mem to '128MB', maintenance_work_mem to '512 MB'

-- Handle SQLite specific data types and constraints
CAST
    type text to varchar,
    type integer to integer,
    type real to float

-- Set timezone to UTC for timestamp conversions
SET timezone TO 'UTC'

-- Explicitly define table transformations
TRANSFORM
    -- Fix column names with hyphens in SQLite to use underscores in PostgreSQL
    column names from 'ad-specialist-name' to 'ad_specialist_name',
    column names from 'ad-specialist-email' to 'ad_specialist_email',
    column names from 'ad-specialist-phone' to 'ad_specialist_phone',
    
    -- Add created_at and updated_at columns with current timestamp
    table names matching 'communities' add columns (
        created_at timestamp with time zone default now(),
        updated_at timestamp with time zone default now()
    ),
    table names matching 'ad_types' add columns (
        created_at timestamp with time zone default now(),
        updated_at timestamp with time zone default now()
    ),
    
    -- Add active boolean column based on state column
    table names matching 'communities' add columns (
        active boolean using (case when state = 'Active' then true else false end)
    );
EOF

# Check if pgloader is installed
if ! command -v pgloader &> /dev/null; then
    echo "pgloader is not installed. Installing..."
    # For macOS with Homebrew
    if command -v brew &> /dev/null; then
        brew install pgloader
    # For Ubuntu/Debian
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y pgloader
    else
        echo "Error: Could not install pgloader. Please install it manually."
        exit 1
    fi
fi

# Run pgloader with the configuration file
echo "Starting migration with pgloader..."
pgloader migration.load

# Check if migration was successful
if [ $? -eq 0 ]; then
    echo "Migration completed successfully!"
    
    # Create a backup of the PostgreSQL database after migration
    echo "Creating backup of PostgreSQL database after migration..."
    docker exec -i management-db-1 pg_dump -U postgres management_db > /Volumes/4TB/Users/josephmcmyne/myProjects/management/database/backups/management_db_post_migration_$(date +%Y%m%d_%H%M%S).sql
    
    # Clean up
    echo "Cleaning up temporary files..."
    rm migration.load
else
    echo "Migration failed. Please check the error messages above."
fi
