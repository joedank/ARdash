#!/bin/bash

# Get the container ID of the backend service
CONTAINER_ID=$(docker ps -qf "name=management-backend-1")

if [ -z "$CONTAINER_ID" ]; then
  echo "Backend container not found. Is the service running?"
  exit 1
fi

echo "Found backend container: $CONTAINER_ID"
echo "Starting embedding backfill process..."

# Execute the backfill script inside the container
docker exec $CONTAINER_ID node src/scripts/embed-backfill.js

echo "Embedding backfill process completed"
