#!/bin/sh
set -e

# Setup database config for Docker
if [ -f config/docker-config.json ]; then
  echo "Copying Docker database config..."
  cp config/docker-config.json config/config.json
fi

# Run migrations first
echo "Running database migrations..."
npx sequelize-cli db:migrate

# Then start the server
echo "Starting server..."
node src/server.js
