#!/bin/bash
set -e

# The PostgreSQL container will automatically execute this script 
# since it's mounted in /docker-entrypoint-initdb.d/

echo "Setting up PostgreSQL for the Construction Management App..."

# Create josephmcmyne role with appropriate permissions
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE ROLE josephmcmyne WITH LOGIN SUPERUSER PASSWORD '';
  ALTER ROLE josephmcmyne WITH CREATEDB;
  GRANT ALL PRIVILEGES ON DATABASE management_db TO josephmcmyne;
EOSQL

echo "Created josephmcmyne role with required permissions"
