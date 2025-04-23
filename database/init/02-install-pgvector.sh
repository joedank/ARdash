#!/bin/bash
set -e

# This script installs the pgvector extension in the PostgreSQL container

echo "Installing pgvector extension..."

# Install build dependencies
apk add --no-cache git build-base postgresql-dev

# Clone pgvector repository
cd /tmp
git clone --branch v0.5.1 https://github.com/pgvector/pgvector.git
cd pgvector

# Build and install
make
make install

# Clean up
cd /
rm -rf /tmp/pgvector

echo "pgvector extension installed successfully"

# Create the extension in the database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS vector;
    SELECT * FROM pg_extension WHERE extname = 'vector';
EOSQL

echo "pgvector extension created in database"
