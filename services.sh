#!/bin/bash

# Explicit Configuration
FRONTEND_PORT=5173
BACKEND_PORT=3000
BASE_DIR="/Volumes/4TB/Users/josephmcmyne/myProjects/management"
LOGS_DIR="${BASE_DIR}/logs"
FRONTEND_DIR="${BASE_DIR}/frontend"
BACKEND_DIR="${BASE_DIR}/backend"
FRONTEND_LOG="${LOGS_DIR}/frontend.log"
BACKEND_LOG="${LOGS_DIR}/backend.log"
FORCE_KILL_TIMEOUT=5

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create necessary directories
echo "Ensuring required directories exist..."
mkdir -p "${LOGS_DIR}"
echo "Log directory: ${LOGS_DIR}"

# Function to get PIDs of processes using a specific port
get_process_by_port() {
  local port=$1
  # Try lsof first
  local pids=$(lsof -ti:${port} 2>/dev/null)
  
  # If lsof didn't find anything, try netstat
  if [ -z "$pids" ]; then
    if command -v netstat &> /dev/null; then
      pids=$(netstat -anp 2>/dev/null | grep ":${port} " | grep "LISTEN" | awk '{print $7}' | cut -d'/' -f1)
    fi
  fi
  
  echo "$pids"
}

# Function to get Node.js process PIDs regardless of port
get_node_processes() {
  local pattern=$1
  local pids=$(ps aux | grep "node" | grep "$pattern" | grep -v grep | awk '{print $2}')
  echo "$pids"
}

# Function to check if a port is in use
is_port_in_use() {
  local port=$1
  local in_use=$(lsof -i:${port} -P -n | grep LISTEN)
  if [ -n "$in_use" ]; then
    return 0 # true
  else
    return 1 # false
  fi
}

# Function to display status
service_status() {
  local service_name=$1
  local port=$2
  local log_file=$3
  
  if is_port_in_use $port; then
    pids=$(get_process_by_port $port)
    echo -e "${GREEN}$service_name is running on port $port (PID: $pids)${NC}"
    if [ -f "$log_file" ]; then
      echo "  Latest logs:"
      tail -n 3 "$log_file" | sed 's/^/  /'
    fi
  else
    echo -e "${RED}$service_name is not running${NC}"
  fi
}

# Enhanced function to stop a service
stop_service() {
  local service_name=$1
  local port=$2
  local dir=$3
  local pattern=$4
  
  echo "Stopping $service_name..."
  
  # First method: Find process by port
  local pids=$(get_process_by_port $port)
  
  # Second method: Find Node.js processes by pattern
  if [ -z "$pids" ]; then
    pids=$(get_node_processes "$pattern")
  fi
  
  if [ -z "$pids" ]; then
    echo -e "${YELLOW}No running $service_name processes found${NC}"
    # Check if parent npm process might be running
    local npm_pid=$(ps aux | grep "npm" | grep "$pattern" | grep -v grep | awk '{print $2}')
    if [ -n "$npm_pid" ]; then
      echo "Found npm process related to $service_name (PID: $npm_pid). Terminating..."
      kill $npm_pid 2>/dev/null
      sleep 2
      if ps -p $npm_pid > /dev/null; then
        echo "Using force kill on npm process..."
        kill -9 $npm_pid 2>/dev/null
      fi
    fi
    return 0
  fi
  
  # Iterate through all found PIDs
  for pid in $pids; do
    echo "Terminating $service_name process with PID: $pid"
    kill $pid 2>/dev/null
      
    # Wait for the process to terminate
    local counter=0
    while ps -p $pid > /dev/null && [ $counter -lt $FORCE_KILL_TIMEOUT ]; do
      sleep 1
      counter=$((counter + 1))
    done
      
    # Force kill if still running after timeout
    if ps -p $pid > /dev/null; then
      echo "Process did not terminate gracefully. Using force kill..."
      kill -9 $pid 2>/dev/null
    fi
  done
  
  # Double check to make sure the port is no longer in use
  sleep 1
  if is_port_in_use $port; then
    echo -e "${RED}Failed to stop $service_name on port $port. Forcing termination...${NC}"
    # Use direct port-based force kill as a fallback
    pids=$(get_process_by_port $port)
    for pid in $pids; do
      kill -9 $pid 2>/dev/null
    done
  fi
  
  # Final check
  if is_port_in_use $port; then
    echo -e "${RED}Failed to stop $service_name. Please check manually.${NC}"
    return 1
  else
    echo -e "${GREEN}$service_name stopped successfully${NC}"
    return 0
  fi
}

# Function to start a service
start_service() {
  local service_name=$1
  local port=$2
  local dir=$3
  local command=$4
  local log_file=$5
  
  echo "Starting $service_name..."
  
  # Check if service is already running
  if is_port_in_use $port; then
    echo -e "${YELLOW}$service_name is already running on port $port${NC}"
    return 0
  fi
  
  # Ensure log directory exists
  mkdir -p "$(dirname "$log_file")"
  touch "$log_file"
  echo "Using log file: $log_file"
  
  # Create a fresh log file
  [ -f "$log_file" ] && mv "$log_file" "${log_file}.old"
  touch "$log_file"
  
  echo "Changing to directory: $dir"
  if [ ! -d "$dir" ]; then
    echo -e "${RED}Directory $dir does not exist!${NC}"
    return 1
  fi
  
  # Save current directory
  local current_dir=$(pwd)
  
  # Start the service
  cd "$dir" && nohup $command > "$log_file" 2>&1 &
  
  # Return to original directory
  cd "$current_dir"
  
  # Check if service started
  local counter=0
  while ! is_port_in_use $port && [ $counter -lt 30 ]; do
    echo -n "."
    sleep 1
    counter=$((counter + 1))
  done
  echo ""
  
  if is_port_in_use $port; then
    pids=$(get_process_by_port $port)
    echo -e "${GREEN}$service_name started successfully on port $port (PID: $pids)${NC}"
    return 0
  else
    echo -e "${RED}Failed to start $service_name on port $port. Check logs at $log_file${NC}"
    echo "Current directory: $(pwd)"
    echo "Last few lines of the log:"
    if [ -f "$log_file" ]; then
      tail -n 10 "$log_file"
    else
      echo "Log file not found!"
    fi
    return 1
  fi
}

# Function to restart a service
restart_service() {
  local service_name=$1
  local port=$2
  local dir=$3
  local command=$4
  local log_file=$5
  local pattern=$6
  
  echo "Restarting $service_name..."
  
  # Stop the service
  stop_service "$service_name" "$port" "$dir" "$pattern"
  
  # Start the service
  start_service "$service_name" "$port" "$dir" "$command" "$log_file"
  
  if [ $? -ne 0 ]; then
    echo -e "${RED}$service_name restart failed${NC}"
    return 1
  else
    echo -e "${GREEN}$service_name restarted successfully${NC}"
    return 0
  fi
}

# Display usage information
show_usage() {
  echo "Usage: $0 {start|stop|restart|status} [frontend|backend|all]"
  echo ""
  echo "Commands:"
  echo "  start          Start the specified service(s)"
  echo "  stop           Stop the specified service(s)"
  echo "  restart        Restart the specified service(s)"
  echo "  status         Show status of the specified service(s)"
  echo ""
  echo "Services:"
  echo "  frontend       Frontend service (Vue.js on port $FRONTEND_PORT)"
  echo "  backend        Backend service (Node.js on port $BACKEND_PORT)"
  echo "  all            Both frontend and backend services (default)"
  echo ""
  echo "Examples:"
  echo "  $0 start frontend    # Start the frontend service"
  echo "  $0 restart all       # Restart both services"
  echo "  $0 status            # Show status of all services"
  echo ""
  echo "For CardDAV testing and client setup, use the separate scripts:"
  echo "  ./test-carddav.sh    # Test the CardDAV connection"
  echo "  ./setup-clients.sh   # Set up client functionality"
}

# Main execution
echo "Starting script from: ${BASE_DIR}"
echo "Frontend directory: ${FRONTEND_DIR}"
echo "Backend directory: ${BACKEND_DIR}"
echo "Logs directory: ${LOGS_DIR}"

# Default to "all" services if not specified
SERVICE="${2:-all}"
COMMAND="$1"

if [ -z "$COMMAND" ]; then
  # Default to showing status if no command is provided
  COMMAND="status"
fi

case "$COMMAND" in
  start)
    if [ "$SERVICE" = "frontend" ] || [ "$SERVICE" = "all" ]; then
      start_service "Frontend" "$FRONTEND_PORT" "$FRONTEND_DIR" "npm run dev" "$FRONTEND_LOG"
      FRONTEND_RESULT=$?
    fi
    
    if [ "$SERVICE" = "backend" ] || [ "$SERVICE" = "all" ]; then
      start_service "Backend" "$BACKEND_PORT" "$BACKEND_DIR" "node src/server.js" "$BACKEND_LOG"
      BACKEND_RESULT=$?
    fi
    
    if [ "$SERVICE" = "all" ]; then
      if [ $FRONTEND_RESULT -eq 0 ] && [ $BACKEND_RESULT -eq 0 ]; then
        echo -e "${GREEN}All services started successfully${NC}"
      else
        echo -e "${RED}Failed to start all services${NC}"
        exit 1
      fi
    fi
    ;;
    
  stop)
    if [ "$SERVICE" = "frontend" ] || [ "$SERVICE" = "all" ]; then
      stop_service "Frontend" "$FRONTEND_PORT" "$FRONTEND_DIR" "dev"
      FRONTEND_RESULT=$?
    fi
    
    if [ "$SERVICE" = "backend" ] || [ "$SERVICE" = "all" ]; then
      stop_service "Backend" "$BACKEND_PORT" "$BACKEND_DIR" "server.js"
      BACKEND_RESULT=$?
    fi
    
    if [ "$SERVICE" = "all" ]; then
      if [ $FRONTEND_RESULT -eq 0 ] && [ $BACKEND_RESULT -eq 0 ]; then
        echo -e "${GREEN}All services stopped successfully${NC}"
      else
        echo -e "${RED}Failed to stop all services${NC}"
        exit 1
      fi
    fi
    ;;
    
  restart)
    if [ "$SERVICE" = "frontend" ] || [ "$SERVICE" = "all" ]; then
      restart_service "Frontend" "$FRONTEND_PORT" "$FRONTEND_DIR" "npm run dev" "$FRONTEND_LOG" "dev"
      FRONTEND_RESULT=$?
    fi
    
    if [ "$SERVICE" = "backend" ] || [ "$SERVICE" = "all" ]; then
      restart_service "Backend" "$BACKEND_PORT" "$BACKEND_DIR" "node src/server.js" "$BACKEND_LOG" "server.js"
      BACKEND_RESULT=$?
    fi
    
    if [ "$SERVICE" = "all" ]; then
      if [ $FRONTEND_RESULT -eq 0 ] && [ $BACKEND_RESULT -eq 0 ]; then
        echo -e "${GREEN}All services restarted successfully${NC}"
      else
        echo -e "${RED}Failed to restart all services${NC}"
        exit 1
      fi
    fi
    ;;
    
  status)
    echo -e "${BLUE}=== Service Status ===${NC}"
    service_status "Frontend" "$FRONTEND_PORT" "$FRONTEND_LOG"
    echo ""
    service_status "Backend" "$BACKEND_PORT" "$BACKEND_LOG"
    echo ""
    ;;
    
  *)
    show_usage
    exit 1
    ;;
esac

exit 0
