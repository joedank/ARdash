#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Checking if PostgreSQL is running locally...${NC}"
BACKUP_FILE="/Volumes/4TB/Users/josephmcmyne/myProjects/management/database/backups/management_db_20250414_145056.sql"

# If PostgreSQL is running locally on port 5432, stop it to avoid conflicts
if lsof -i:5432 > /dev/null; then
  echo -e "${YELLOW}PostgreSQL is running locally on port 5432.${NC}"
  echo -e "${YELLOW}Please stop your local PostgreSQL server before continuing.${NC}"
  echo -e "${YELLOW}You can do this with: brew services stop postgresql or sudo service postgresql stop${NC}"
  read -p "Press enter when you've stopped PostgreSQL or Ctrl+C to cancel" 
fi

echo -e "${YELLOW}Stopping all Docker services...${NC}"
./docker-services.sh down

echo -e "${YELLOW}Removing Docker volumes...${NC}"
docker volume rm management_postgres_data management_uploads_data 2>/dev/null || true

echo -e "${YELLOW}Checking database backup file...${NC}"
./check-db-backup.sh

echo -e "${YELLOW}Making sure scripts are executable...${NC}"
chmod +x wait-for-it.sh docker-services.sh
chmod +x database/init/00-init.sh

echo -e "${YELLOW}Rebuilding Docker images...${NC}"
docker-compose build

echo -e "${GREEN}Starting Docker services with verbose output...${NC}"
echo -e "${GREEN}Press Ctrl+C to stop watching logs${NC}"
docker-compose up

# Add extra diagnostics if something goes wrong
if [ $? -ne 0 ]; then
  echo -e "${RED}Something went wrong with Docker services...${NC}"
  echo -e "${YELLOW}Checking container status:${NC}"
  docker-compose ps
  
  # Check database logs specifically
  echo -e "${YELLOW}Last 20 lines of database logs:${NC}"
  docker-compose logs --tail=20 db
  
  echo -e "${YELLOW}Checking if database is accessible:${NC}"
  docker-compose exec db pg_isready -U postgres -d management_db || echo "Database is not ready"
  
  echo -e "${YELLOW}Useful troubleshooting commands:${NC}"
  echo "- View database logs: docker-compose logs db"
  echo "- View backend logs: docker-compose logs backend"
  echo "- Access database: docker-compose exec db psql -U postgres -d management_db"
  echo "- Restart just the backend: docker-compose restart backend"
fi
