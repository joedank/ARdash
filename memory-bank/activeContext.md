# Active Context: Construction Management Web Application

This document captures the current work focus, recent changes, active decisions, and important patterns and preferences.

## Current Focus

- Fixing bugs in estimate generation, especially missing/undefined functions (e.g., analyzeScope)
- Ensuring the UI displays all relevant estimate data correctly (unit prices, totals, etc.)
- Making sure both new and legacy estimate workflows are compatible

## Recent Changes

- Implemented `analyzeScope` in `llmEstimateService.js`
- Refactored frontend mapping and data handling for estimates

- Enhancing project workflow with complete status lifecycle including rejected assessments
- Improving assessment workflow with clearer status transition options and reason tracking
- Implementing dashboard view for rejected assessments to improve business analytics
- Automating project state transitions based on scheduled dates
- Fixing UUID validation issues in API endpoints that don't require path parameters
- Optimizing project dashboard for single active job workflow with proper error handling

## Recent Achievements

### Fixed Assessment Data Display in Estimate Conversion

- Fixed assessment data not displaying after selection in the assessment-to-estimate conversion workflow
- Corrected API endpoint URL in standardized-estimates.service.js to use the proper endpoint
- Enhanced frontend components to handle both formattedMarkdown and formattedData properties
- Added computed property normalizedAssessment to ensure consistent data structure
- Improved error handling and debugging for assessment data loading

### WebSocket Security Implementation

- Fixed WebSocket connection issues when accessing the application over HTTPS
- Updated Vite configuration to use host-based settings instead of explicit protocol
- Prevented mixed content errors in modern browsers
- Ensured compatibility with Nginx Proxy Manager for SSL termination

### UI Enhancement with Tooltips

- Replaced explanatory text on buttons with tooltips for cleaner UI
- Implemented BaseTooltip component for contextual help
- Used concise tooltip text (e.g., "Ad type required") instead of longer explanations
- Fixed button variant validation issues to prevent console warnings

### Communities Module Implementation

- Created models for Communities and AdTypes with proper relationships
- Implemented API endpoints for managing communities and ad types
- Built frontend components following project conventions
- Ensured communities can be created without ad types but require them for activation
- Added validation to prevent setting communities as active without ad types

### Database Migration

- Successfully migrated from SQLite to PostgreSQL
- Fixed column naming issues (active vs is_active) in communities table
- Implemented proper case conversion between frontend and backend
- Added debugging to trace data flow through the application

## Environment Details

- Frontend: Vue.js 3 with Vite running in Docker container on port 5173
- Backend: Node.js/Express running in Docker container on port 3000
- Database: PostgreSQL 16 running in Docker container on port 5432 (migrated from SQLite)
- Docker Compose for orchestration
- Nginx Proxy Manager for SSL termination in production

## Next Steps

- Complete the communities module with additional filtering options
- Enhance project workflow with complete status lifecycle
- Implement dashboard view for rejected assessments
- Automate project state transitions based on scheduled dates
- Fix remaining UUID validation issues in API endpoints
- Implement comprehensive error handling for missing or malformed inspection data
- Add validation to ensure all required data is present before allowing estimate creation
