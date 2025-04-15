#!/bin/bash

# This script tests the upcoming projects functionality
# It checks for upcoming projects and then tests the auto-update endpoint

# Get authentication token (replace with your login API details)
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "yourpassword"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "Error: Could not get authentication token. Please update login credentials."
  exit 1
fi

echo "Authentication successful."

# Check for upcoming projects
echo "Checking for upcoming projects..."
curl -s -X GET http://localhost:3000/api/projects/upcoming \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN"

echo -e "\n\nTesting update-upcoming endpoint..."
# Test the update endpoint
curl -s -X POST http://localhost:3000/api/projects/update-upcoming \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN"

echo -e "\n\nTest completed."
