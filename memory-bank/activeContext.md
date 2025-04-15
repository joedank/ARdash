# Active Context: Docker Containerization, PDF Generation, Project Management, and Vue Component Fixes

## Current Focus
- Dockerizing the application for consistent development and deployment
- Resolving PDF generation issues in containerized environment
- Ensuring proper communication between frontend, backend, and database containers
- Standardizing service patterns across the application
- Improving project management with enhanced deletion capabilities
- Fixing Vue component syntax issues to ensure proper rendering
- Addressing data structure mismatches between components

## Environment Details
- Frontend: Vue.js 3 with Vite running in Docker container on port 5173
- Backend: Node.js/Express running in Docker container on port 3000
- Database: PostgreSQL 16 running in Docker container on port 5432
- Docker Compose for orchestration
- Volume mounts for code, node_modules, and persistent data

## Recent Challenges

### Vue Component Structure Issues
- Improper component tag syntax causing rendering errors
- HTML comments inside attribute areas showing up as visible text
- Missing required props causing console warnings
- Client objects not displaying properly in edit forms
- Data structure mismatches between component expectations

### Docker Configuration Issues
- Port conflicts between host and container environments
- Database connection issues when running in containers
- Volume mounting and permissions for persistent data
- Container startup order and dependency management

### PDF Generation in Docker
- Puppeteer requires specific dependencies in Alpine-based containers
- Chromium installation and configuration in Docker environment
- File system access for PDF storage and retrieval
- Error handling for PDF generation process

### Data Type Compatibility
- ENUM type conversion issues between PostgreSQL and Sequelize
- Handling of payment_method field in Payment model
- Client view dependencies on column types

### Project Management Challenges
- Circular references between assessments and jobs causing transaction errors
- Bidirectional relationships complicating deletion operations
- Need for transparent deletion process with user control
- Transaction management for complex delete operations

## Current Solutions

### Frontend Component Structure
- Implemented consistent Vue component tag structure pattern
- Fixed self-closing tags for components without children
- Ensured attributes are properly placed inside opening tags
- Removed HTML comments from attribute areas
- Added form state reset pattern to prevent data contamination
- Implemented proper object structure for component data binding
- Added debugging logs to troubleshoot data flow issues

### Docker Environment
- Using Alpine-based Node.js images with specific dependencies for Puppeteer
- Setting environment variables for Puppeteer to use system Chromium
- Creating necessary directory structure for uploads
- Using wait-for-it script to ensure proper service startup order

### PDF Generation
- Enhanced Puppeteer configuration with Docker-specific arguments
- Improved error handling and logging throughout PDF generation process
- Direct file reading instead of streaming for better reliability
- Proper content type and disposition headers for browser download

### Module System Compatibility
- Updated fix-imports.js to use ES modules instead of CommonJS
- Proper re-exporting of services for backward compatibility
- Consistent error handling across service layers

### Project Management
- Enhanced dependency checking before deletion operations
- UI controls for choosing deletion strategy (break references vs. delete everything)
- Transaction-safe deletion methods that properly handle circular references
- Detailed dependency information shown to users before confirmation
