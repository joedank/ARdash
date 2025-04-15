#!/bin/sh
# wait-for-it.sh: Wait for a service to be available
# Usage: ./wait-for-it.sh host:port [-t timeout] [-- command args]

TIMEOUT=15
QUIET=0
HOST=""
PORT=""
COMMAND=""

# Function to output usage information
usage() {
  echo "Usage: $0 host:port [-t timeout] [-- command args]"
  echo "  -t TIMEOUT                  Timeout in seconds, default is 15"
  echo "  -q, --quiet                 Don't output any status messages"
  echo "  -- COMMAND ARGS             Execute command with args after the test finishes"
  exit $1
}

# Parse arguments
while [ $# -gt 0 ]
do
  case "$1" in
    *:* )
    HOST=$(printf "%s\n" "$1"| cut -d : -f 1)
    PORT=$(printf "%s\n" "$1"| cut -d : -f 2)
    shift 1
    ;;
    -q | --quiet)
    QUIET=1
    shift 1
    ;;
    -t)
    TIMEOUT="$2"
    if [ -z "$TIMEOUT" ] ; then break; fi
    shift 2
    ;;
    --timeout=*)
    TIMEOUT="${1#*=}"
    shift 1
    ;;
    --)
    shift
    COMMAND="$@"
    break
    ;;
    --help)
    usage 0
    ;;
    *)
    echo "Unknown argument: $1"
    usage 1
    ;;
  esac
done

# Validate host and port
if [ -z "$HOST" ] || [ -z "$PORT" ]; then
  echo "Error: you need to provide a host and port to test."
  usage 2
 fi

# Wait for the service to be available
wait_for_service() {
  if [ $QUIET -eq 0 ]; then
    echo "Waiting for $HOST:$PORT for up to $TIMEOUT seconds..."
  fi

  for i in $(seq 1 $TIMEOUT); do
    nc -z "$HOST" "$PORT" > /dev/null 2>&1
    result=$?
    if [ $result -eq 0 ]; then
      if [ $QUIET -eq 0 ]; then
        echo "$HOST:$PORT is available after $i seconds"
      fi
      if [ -n "$COMMAND" ]; then
        if [ $QUIET -eq 0 ]; then
          echo "Executing command: $COMMAND"
        fi
        exec $COMMAND
      fi
      exit 0
    fi
    sleep 1
  done

  echo "Timeout occurred after waiting $TIMEOUT seconds for $HOST:$PORT"
  exit 1
}

wait_for_service
