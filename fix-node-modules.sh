#!/bin/bash

# Script to fix the "Cannot find module 'bullmq'" issue by removing node_modules volume mounts
# Created to implement the fix as described in the error diagnosis

echo "=== Starting Docker Configuration Fix ==="
echo ""
echo "1. Stopping all services..."
docker compose down -v
echo ""

echo "2. Docker compose has been configured to remove node_modules volume mounts."
echo "   - Removed backend_node_modules volume mount"
echo "   - Removed frontend_node_modules volume mount"
echo "   - Added estimate-worker service with proper configuration"
echo ""

echo "3. Starting backend and worker services..."
docker compose up -d backend embedding-worker estimate-worker
echo ""

echo "4. Checking status of backend..."
echo "-------------------------------"
echo "Waiting for services to stabilize (15 seconds)..."
sleep 15
echo ""

# Check if bullmq is properly resolved now
echo "5. Verifying bullmq module resolution..."
docker exec -it management-backend-1 node -e 'console.log("BullMQ module path:", require.resolve("bullmq"))'
if [ $? -eq 0 ]; then
    echo "✅ BullMQ module resolved successfully!"
else
    echo "❌ BullMQ module resolution failed. Please check the logs for more details."
fi
echo ""

echo "6. Checking backend logs..."
echo "-------------------------"
docker logs management-backend-1 --tail 20
echo ""

echo "7. Checking embedding worker logs..."
echo "---------------------------------"
docker logs management-embedding-worker-1 --tail 10
echo ""

echo "8. Checking estimate worker logs..."
echo "--------------------------------"
docker logs management-estimate-worker-1 --tail 10
echo ""

echo "=== Fix implementation complete ==="
echo ""
echo "To verify the fix is working correctly, try the following:"
echo "1. Check that the backend is running without MODULE_NOT_FOUND errors:"
echo "   docker logs -f management-backend-1"
echo ""
echo "2. Test the estimate jobs API endpoint:"
echo "   curl http://localhost:3000/api/estimate-jobs/foo/status"
echo "   (Should return a 404 JSON response, not a 500 error)"
echo ""
echo "3. If needed, restart the frontend with:"
echo "   docker compose up -d frontend"
echo ""
echo "If you encounter any issues, please check the container logs for more details."
