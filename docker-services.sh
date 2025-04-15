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
  echo "  $0 up              # Start all services"
  echo "  $0 logs backend    # View backend logs"
  echo "  $0 restart frontend # Restart frontend"
}

# Default to "all" services if not specified
SERVICE="${2}"
COMMAND="$1"

case "$COMMAND" in
  up)
    if [ -z "$SERVICE" ]; then
      echo -e "${BLUE}Starting all services...${NC}"
      docker-compose up -d
    else
      echo -e "${BLUE}Starting ${SERVICE}...${NC}"
      docker-compose up -d ${SERVICE}
    fi
    ;;
    
  down)
    echo -e "${BLUE}Stopping all services...${NC}"
    docker-compose down
    ;;
    
  restart)
    if [ -z "$SERVICE" ]; then
      echo -e "${BLUE}Restarting all services...${NC}"
      # Stop and then start in detached mode
      docker-compose stop
      docker-compose up -d
    else
      echo -e "${BLUE}Restarting ${SERVICE}...${NC}"
      # Stop specific service and then start in detached mode
      docker-compose stop ${SERVICE}
      docker-compose up -d ${SERVICE}
    fi
    ;;
    
  status)
    echo -e "${BLUE}=== Service Status ===${NC}"
    docker-compose ps
    ;;
    
  logs)
    if [ -z "$SERVICE" ]; then
      echo -e "${BLUE}Showing logs for all services...${NC}"
      docker-compose logs -f
    else
      echo -e "${BLUE}Showing logs for ${SERVICE}...${NC}"
      docker-compose logs -f ${SERVICE}
    fi
    ;;
    
  *)
    show_usage
    exit 1
    ;;
esac

exit 0
