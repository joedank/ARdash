-- Fix project deletion circular reference issue
-- This script breaks the circular reference between assessment and job projects

BEGIN;

-- Step 1: Update the job to remove its reference to the assessment
UPDATE projects 
SET assessment_id = NULL 
WHERE id = '859f67ad-d08d-44c1-88f0-c3d2ff9c9524';

-- Step 2: Check if it worked
SELECT id, assessment_id FROM projects WHERE id = '859f67ad-d08d-44c1-88f0-c3d2ff9c9524';

COMMIT;

-- After running this script, try deleting the project again through the UI
