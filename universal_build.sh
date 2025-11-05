#!/usr/bin/env bash

# Universal build script for Docker-based construction management application
# Supports both development and production/release builds

set -euo pipefail

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Build mode flags
RELEASE_MODE=0
NO_CACHE=0

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --release)
      RELEASE_MODE=1
      shift
      ;;
    --no-cache)
      NO_CACHE=1
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --release    Build for production (uses production Docker targets)"
      echo "  --no-cache   Build without using Docker cache"
      echo "  -h, --help   Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                    # Development build"
      echo "  $0 --release          # Production build"
      echo "  $0 --release --no-cache  # Clean production build"
      exit 0
      ;;
    *)
      echo -e "${RED}Error: Unknown option $1${NC}" >&2
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Detect Docker Compose command
if docker compose version >/dev/null 2>&1; then
  DC="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  DC="docker-compose"
else
  echo -e "${RED}Error: Docker Compose not found. Install Docker Desktop or docker-compose.${NC}" >&2
  exit 1
fi

cd "${SCRIPT_DIR}"

# Display build mode
if [ "${RELEASE_MODE}" -eq 1 ]; then
  echo -e "${GREEN}>>> Building in RELEASE mode (production)${NC}"
else
  echo -e "${BLUE}>>> Building in DEVELOPMENT mode${NC}"
fi

# Step 1: Stop running containers
echo -e "${BLUE}>>> Stopping running containers...${NC}"
${DC} down

# Step 2: Build Docker images
echo -e "${BLUE}>>> Building Docker images...${NC}"

BUILD_ARGS=""
if [ "${NO_CACHE}" -eq 1 ]; then
  BUILD_ARGS="--no-cache"
  echo -e "${YELLOW}    Building without cache${NC}"
fi

if [ "${RELEASE_MODE}" -eq 1 ]; then
  # Production build - need to temporarily modify docker-compose.yml or use override
  echo -e "${BLUE}    Building frontend with production target...${NC}"

  # Build backend
  ${DC} build ${BUILD_ARGS} backend
  ${DC} build ${BUILD_ARGS} embedding-worker
  ${DC} build ${BUILD_ARGS} estimate-worker

  # Build frontend for production
  docker build ${BUILD_ARGS} \
    --target production \
    -t management-frontend:production \
    "${SCRIPT_DIR}/frontend"

  echo -e "${YELLOW}    Note: Production frontend uses Nginx. Update docker-compose.yml to use the production image.${NC}"
else
  # Development build - use existing docker-compose.yml targets
  echo -e "${BLUE}    Building all services...${NC}"
  ${DC} build ${BUILD_ARGS}
fi

# Step 3: Start services
echo -e "${BLUE}>>> Starting services...${NC}"
${DC} up -d

# Step 4: Wait for services to be healthy
echo -e "${BLUE}>>> Waiting for services to be ready...${NC}"

MAX_WAIT=60
ELAPSED=0

while [ $ELAPSED -lt $MAX_WAIT ]; do
  # Check if backend is healthy
  if docker compose ps backend | grep -q "healthy"; then
    echo -e "${GREEN}>>> All services are ready!${NC}"
    break
  fi

  echo -e "${YELLOW}    Waiting for services... (${ELAPSED}s/${MAX_WAIT}s)${NC}"
  sleep 5
  ELAPSED=$((ELAPSED + 5))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
  echo -e "${YELLOW}>>> Warning: Services may not be fully ready. Check logs with: ./docker-services.sh logs${NC}"
fi

# Step 5: Display service status and access information
echo ""
echo -e "${GREEN}=== Build Complete ===${NC}"
echo ""
${DC} ps
echo ""
echo -e "${GREEN}Access URLs:${NC}"
echo -e "  Frontend:  ${BLUE}http://localhost:5173${NC}"
echo -e "  Backend:   ${BLUE}http://localhost:3000${NC}"
echo -e "  Database:  ${BLUE}localhost:5432${NC} (postgres/postgres)"
echo -e "  Redis:     ${BLUE}localhost:6379${NC}"
echo ""
echo -e "${GREEN}Useful commands:${NC}"
echo -e "  View logs:        ${BLUE}./docker-services.sh logs [service]${NC}"
echo -e "  Stop services:    ${BLUE}./docker-services.sh down${NC}"
echo -e "  Restart service:  ${BLUE}./docker-services.sh restart [service]${NC}"
echo -e "  Service status:   ${BLUE}./docker-services.sh status${NC}"
echo ""

if [ "${RELEASE_MODE}" -eq 1 ]; then
  echo -e "${YELLOW}Note: For production deployment, update docker-compose.yml to use the production frontend image.${NC}"
  echo ""
fi

echo -e "${GREEN}>>> All done! Application is running.${NC}"
