# Assessment Transition Documentation

## Overview

This document describes the transition from using `assessment_id` to the new pattern using `project_inspections` with `category = 'condition'`.

## Old Pattern vs New Pattern

### Old Pattern
- Projects had an `assessment_id` column that referenced another project
- Assessments were stored in the same `projects` table
- The relationship was maintained through foreign keys

### New Pattern
- The `assessment_id` column has been removed
- Condition-style "assessment" is now a `project_inspections` row where `category = 'condition'`
- The relationship is maintained through a scoped association

## Changes Made

1. **Project Model**
   - Removed `assessment_id` attribute
   - Renamed `scope` to `condition` to match the database schema
   - Added scoped association for condition inspection:
     ```javascript
     Project.hasOne(models.ProjectInspection, {
       foreignKey: 'project_id',
       as: 'condition',
       scope: {
         category: 'condition'
       }
     });
     ```

2. **Project Service**
   - Updated `getProjectWithDetails` to include the condition association
   - Updated `createProject` to use `condition` instead of `scope`
   - Updated `updateProject` to use `condition` instead of `scope`
   - Updated `convertAssessmentToJob` to not use `assessment_id`
   - Updated `rejectAssessment` to use `condition` instead of `scope`

3. **Project Service Additions**
   - Updated `getProjectDependencies` to use condition inspection instead of `assessment_id`
   - Updated `deleteProjectWithReferences` to handle condition inspections

## Verification Steps

To verify that the changes are working correctly:

1. Create a new project with condition data
2. Check that the condition data is stored in the `project_inspections` table
3. View the project details and verify that the condition data is displayed correctly
4. Convert an assessment to a job and verify that the relationship is maintained
5. Delete a project and verify that related data is deleted correctly

## Regression Testing

1. Run the test suite to ensure all tests pass
2. Test the Project Detail view in the UI to verify that the "Condition" textarea shows existing data and saves edits
3. Insert a new project, add a condition entry, and confirm the record appears in `project_inspections`

## Conclusion

The transition from `assessment_id` to using `project_inspections` with `category = 'condition'` has been completed. This change makes the codebase more consistent and easier to maintain, as it follows the pattern of using inspections for different types of project data.
