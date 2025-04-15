# Docker Setup for Construction Management Application

This document explains how to run the Construction Management application using Docker containers.

## Prerequisites

- Docker installed on your machine
- Docker Compose installed on your machine

## Quick Start

1. Make the docker services script executable:
   ```
   chmod +x docker-services.sh
   ```

2. Start all services:
   ```
   ./docker-services.sh up
   ```

3. Access the application:
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:3000/api

## Available Commands

The `docker-services.sh` script provides convenient commands to manage your Docker environment:

- **Start all services**:
  ```
  ./docker-services.sh up
  ```

- **Start a specific service** (e.g., backend):
  ```
  ./docker-services.sh up backend
  ```

- **Stop all services**:
  ```
  ./docker-services.sh down
  ```

- **Restart all services**:
  ```
  ./docker-services.sh restart
  ```

- **Restart a specific service** (e.g., frontend):
  ```
  ./docker-services.sh restart frontend
  ```

- **View service status**:
  ```
  ./docker-services.sh status
  ```

- **View logs of all services**:
  ```
  ./docker-services.sh logs
  ```

- **View logs of a specific service** (e.g., db):
  ```
  ./docker-services.sh logs db
  ```

## Architecture

The Docker setup includes three main services:

1. **PostgreSQL Database** (`db`):
   - Runs PostgreSQL 16 with Alpine Linux
   - Persists data in a Docker volume
   - Initialized with your existing database schema and data backups
   - Available on port 5432

2. **Node.js Backend** (`backend`):
   - Built from your Express application
   - Connected to the PostgreSQL database 
   - Persists uploads in a Docker volume
   - Available on port 3000

3. **Vue.js Frontend** (`frontend`):
   - Built from your Vue.js application using Vite
   - Configured to connect to the backend service
   - Available on port 5173

## Volumes and Persistence

The Docker setup uses volumes to persist data:

- `postgres_data`: Stores PostgreSQL database files
- `uploads_data`: Stores uploaded files from the application

## Configuration Files

The Docker setup uses modified configuration files:

- `backend/src/utils/database.docker.js`: Database configuration for Docker
- `frontend/vite.config.docker.js`: Vite configuration for Docker
- `.env.docker`: Environment variables for Docker

These files are copied to their respective locations when containers start.

## Database Initialization

The database is initialized with your existing backups:

- `schema_backup_20250414.sql`: Database schema
- `project_estimates_data_backup_20250414.sql`: Project and estimate data

## Troubleshooting

If you encounter issues:

1. **Database connection errors**:
   - Check if the database container is running: `./docker-services.sh status`
   - View database logs: `./docker-services.sh logs db`
   - Make sure the database initialization script has completed: `docker-compose logs db | grep "database system is ready"`

2. **Backend service not starting**:
   - Check backend logs: `./docker-services.sh logs backend`
   - Verify database is healthy and accessible
   - Make sure the database.docker.js configuration is being used: `docker-compose exec backend cat src/utils/database.js`

3. **Frontend not connecting to backend**:
   - Check if backend is running: `./docker-services.sh status`
   - Check frontend logs: `./docker-services.sh logs frontend`
   - Verify that the Vite configuration is properly set: `docker-compose exec frontend cat vite.config.js`

4. **Missing files or import errors**:
   - Check if the fix-imports.js script ran successfully: `docker-compose logs frontend | grep "Import fixes complete"`
   - If not, manually run the fix script: `docker-compose exec frontend node fix-imports.js`
   - Restart the frontend after fixing imports: `./docker-services.sh restart frontend`

5. **Reset and rebuild services**:
   ```
   ./docker-services.sh down
   docker-compose build --no-cache
   ./docker-services.sh up
   ```

6. **Permission issues with wait-for-it.sh**:
   - If you encounter permission issues with the wait script, make it executable:
   ```
   chmod +x wait-for-it.sh
   ```
   - Then rebuild and restart the services:
   ```
   ./docker-services.sh down
   docker-compose build
   ./docker-services.sh up
   ```

## Production Deployment

For production environments, consider making these changes:

1. Update the frontend Dockerfile to build for production:
   ```
   CMD ["serve", "-s", "dist", "-l", "5173"]
   ```

2. Set environment variables for production in docker-compose.yml:
   ```
   NODE_ENV=production
   ```

3. Use a stronger JWT secret and ensure sensitive data is properly managed
