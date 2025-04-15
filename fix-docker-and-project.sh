#!/bin/bash

# Step 1: Fix the database circular reference
echo "Breaking circular reference between projects..."
docker exec -i management-db-1 psql -U postgres management_db << EOF
-- Fix project deletion circular reference issue
BEGIN;

-- Step 1: Update the job to remove its reference to the assessment
UPDATE projects 
SET assessment_id = NULL 
WHERE id = '859f67ad-d08d-44c1-88f0-c3d2ff9c9524';

-- Step 2: Check if it worked
SELECT id, assessment_id FROM projects WHERE id = '859f67ad-d08d-44c1-88f0-c3d2ff9c9524';

COMMIT;
EOF

echo "Circular reference broken. You should now be able to delete the project."

# Step 2: Make sure bcryptjs is installed and available
echo "Ensuring bcryptjs is properly installed..."
docker exec -i management-backend-1 npm install bcryptjs --save

# Step 3: Restart the backend service
echo "Restarting backend service..."
./docker-services.sh restart backend

echo "Done! Try deleting the project again through the UI."
