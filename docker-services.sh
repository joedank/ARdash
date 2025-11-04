#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_usage() {
  echo "Usage: $0 {up|down|restart|status|logs} [service_name]"
  echo ""
  echo "Commands:"
  echo "  up          Start all services or a specific service"
  echo "  down        Stop all services"
  echo "  restart     Restart all services or a specific service"
  echo "  status      Show status of all services"
  echo "  logs        View logs of all services or a specific service"
  echo ""
  echo "Services:"
  echo "  db          PostgreSQL database"
  echo "  backend     Node.js backend"
  echo "  frontend    Vue.js frontend"
  echo ""
  echo "Examples:"
  echo "  $0 up               # Start all services"
  echo "  $0 logs backend     # View backend logs"
  echo "  $0 restart frontend # Restart frontend"
}

# Default to "all" services if not specified
SERVICE="${2}"
COMMAND="$1"

# Prefer modern 'docker compose' if available; fallback to legacy 'docker-compose'
if docker compose version >/dev/null 2>&1; then
  DC="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  DC="docker-compose"
else
  echo -e "${RED}Docker Compose not found. Install Docker Desktop or docker-compose.${NC}"
  exit 1
fi

case "$COMMAND" in
  up)
    if [ -z "$SERVICE" ]; then
      echo -e "${BLUE}Starting all services...${NC}"
      ${DC} up -d
    else
      echo -e "${BLUE}Starting ${SERVICE}...${NC}"
      ${DC} up -d ${SERVICE}
    fi
    ;;
    
  down)
    echo -e "${BLUE}Stopping all services...${NC}"
    ${DC} down
    ;;
    
  restart)
    if [ -z "$SERVICE" ]; then
      echo -e "${BLUE}Restarting all services...${NC}"
      # Stop and then start in detached mode
      ${DC} stop
      ${DC} up -d
    else
      echo -e "${BLUE}Restarting ${SERVICE}...${NC}"
      # Stop specific service and then start in detached mode
      ${DC} stop ${SERVICE}
      ${DC} up -d ${SERVICE}
    fi
    ;;
    
  status)
    echo -e "${BLUE}=== Service Status ===${NC}"
    ${DC} ps
    ;;
    
  logs)
    if [ -z "$SERVICE" ]; then
      echo -e "${BLUE}Showing logs for all services...${NC}"
      ${DC} logs -f
    else
      echo -e "${BLUE}Showing logs for ${SERVICE}...${NC}"
      ${DC} logs -f ${SERVICE}
    fi
    ;;
    
  *)
    show_usage
    exit 1
    ;;
esac

exit 0
