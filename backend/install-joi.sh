#!/bin/bash
# Script to install Joi in the Docker container

# Make the script executable
chmod +x install-joi.sh

# Run the command to install Joi in the container
docker exec -it management-backend-1 npm install joi

# Restart the backend container
docker-compose restart backend
