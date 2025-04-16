#!/bin/bash

# Script to migrate SQLite database to PostgreSQL using pgloader in Docker

# Define paths and connection details
SQLITE_DB_PATH="/Volumes/4TB/Users/josephmcmyne/myProjects/management/database.sqlite"
PG_HOST="management-db-1"  # Docker container name
PG_PORT="5432"
PG_DB="management_db"
PG_USER="postgres"
PG_PASSWORD="postgres"  # Change this if your password is different

# Create a directory for the migration files
mkdir -p migration_temp
cd migration_temp

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

# Create a Dockerfile for pgloader
cat > Dockerfile << EOF
FROM dimitri/pgloader:latest

WORKDIR /app
COPY migration.load /app/
COPY $SQLITE_DB_PATH /app/database.sqlite

CMD ["pgloader", "migration.load"]
EOF

# Build and run the Docker container
echo "Building pgloader Docker container..."
docker build -t pgloader-migration .

echo "Running migration with pgloader in Docker..."
docker run --rm --network=management_default pgloader-migration

# Check if migration was successful
if [ $? -eq 0 ]; then
    echo "Migration completed successfully!"
    
    # Create a backup of the PostgreSQL database after migration
    echo "Creating backup of PostgreSQL database after migration..."
    docker exec -i management-db-1 pg_dump -U postgres management_db > /Volumes/4TB/Users/josephmcmyne/myProjects/management/database/backups/management_db_post_migration_$(date +%Y%m%d_%H%M%S).sql
    
    # Clean up
    echo "Cleaning up temporary files..."
    cd ..
    rm -rf migration_temp
else
    echo "Migration failed. Please check the error messages above."
fi
