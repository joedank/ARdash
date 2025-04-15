# Active Context: UUID Validation, Project Dashboard, Project States, and Data Structure Standardization

## Current Focus
- Implementing 'upcoming' project status for improved workflow visibility
- Automating project state transitions based on scheduled dates
- Fixing UUID validation issues in API endpoints that don't require path parameters
- Optimizing project dashboard for single active job workflow with proper error handling
- Improving error handling in service layer to prevent cascading failures
- Standardizing route documentation related to parameter validation
- Ensuring consistent API response formats for both success and error cases
- Addressing data structure mismatches between frontend and backend
- Improving dashboard information hierarchy for better workflow clarity

## Environment Details
- Frontend: Vue.js 3 with Vite running in Docker container on port 5173
- Backend: Node.js/Express running in Docker container on port 3000
- Database: PostgreSQL 16 running in Docker container on port 5432
- Docker Compose for orchestration
- Volume mounts for code, node_modules, and persistent data

## Recent Challenges

### API Endpoint UUID Validation Issues
- UUID validation incorrectly applied to routes without URL parameters
- Error handling inconsistencies in service methods
- 400 Bad Request errors preventing dashboard from displaying data
- Frontend service error handling not properly showing user-friendly messages

### Data Structure Standardization
- Standardized services expecting consistent field naming
- Converting between snake_case (backend) and camelCase (frontend)
- Ensuring proper error and response format consistency
- Managing bidirectional relationships between related entities

### Empty Result Handling
- Service methods not consistently handling empty result sets
- Need for explicit null or empty array returns instead of errors
- Proper logging of expected vs. unexpected empty results
- Frontend conditional rendering based on empty state

### Project Management Challenges
- Circular references between assessments and jobs affecting dashboard display
- Bidirectional relationships complicating data retrieval
- Need for transparent error handling in dashboard components
- Efficient loading of independent dashboard sections

## Current Solutions

### API Routing and Validation
- Added explicit documentation for routes that don't require UUID validation
- Enhanced controller methods with clear comments about parameter expectations
- Improved service methods with proper empty result handling
- Added comprehensive error handling in service layer to prevent cascading errors

### Error Handling and Logging
- Implemented standardized error response format across all controllers
- Enhanced logging to capture context of errors (request details, parameters, etc.)
- Service methods now handling all DB errors and returning appropriate responses
- Frontend services properly handling and displaying error messages

### Dashboard Structure
- Implemented independent loading states for each dashboard section
- Enhanced error handling to prevent entire dashboard failure if one section fails
- Added visual hierarchy that matches company workflow (active job, assessments, upcoming, completed)
- Created empty state handling for each dashboard section

### Project Data Standardization
- Standardized project services consistent with API adapter pattern
- Proper conversion between snake_case and camelCase through dedicated utility functions
- Consistent response format with success flag, message, and normalized data
- Applying system patterns consistently across service implementations

### Project Management
- Enhanced dependency checking before deletion operations
- UI controls for choosing deletion strategy (break references vs. delete everything)
- Transaction-safe deletion methods that properly handle circular references
- Detailed dependency information shown to users before confirmation
