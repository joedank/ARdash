#!/bin/sh
set -e

# Wait for the status endpoint to return 200 OK
if curl -f http://localhost:3000/api/status; then
  echo "Backend is healthy"
  exit 0
else
  echo "Backend is not healthy"
  exit 1
fi
