#!/bin/bash

# Create the migrations directory if it doesn't exist
mkdir -p /Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/migrations

# Move all migration files from src/migrations to migrations
for file in /Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/src/migrations/*.js; do
  if [ -f "$file" ]; then
    filename=$(basename "$file")
    echo "Moving $filename to backend/migrations/"
    cp "$file" "/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/migrations/"
  fi
done

# Also move SQL files
for file in /Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/src/migrations/*.sql; do
  if [ -f "$file" ]; then
    filename=$(basename "$file")
    echo "Moving $filename to backend/migrations/"
    cp "$file" "/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/migrations/"
  fi
done

# Move README.md if it exists
if [ -f "/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/src/migrations/README.md" ]; then
  echo "Moving README.md to backend/migrations/"
  cp "/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/src/migrations/README.md" "/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/migrations/"
fi

echo "Migration files have been copied to backend/migrations/"
echo "Please verify the files are correct before removing the originals"
