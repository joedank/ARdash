#!/bin/bash
set -e

# Create database if it doesn't exist
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE management_db;
    GRANT ALL PRIVILEGES ON DATABASE management_db TO postgres;
EOSQL

# Import the database schema and data
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "management_db" < /docker-entrypoint-initdb.d/schema_backup_20250414.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "management_db" < /docker-entrypoint-initdb.d/project_estimates_data_backup_20250414.sql
