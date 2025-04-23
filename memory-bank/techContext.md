# Technical Context: Construction Management Web Application

## Technologies Used
### Database Extensions
- **work_type_materials**: Bidirectional mapping between work types and material products
  - Maps work types to their required materials with quantity calculations
  - Stores quantity per unit and measurement unit information
  - Enables detailed material lists for estimating
  - Integrated with the product catalog for consistent material references
- **work_type_tags**: Safety and permit requirements for work types
  - Stores flexible tag assignments for safety, permitting, and licensing requirements
  - Enables colored visual indicators based on risk level (red for high risk, amber for permit, etc.)
  - Allows filtering and searching for work types by safety requirements
  - Integrates with PromptEngine to provide safety guidance in LLM prompts
- **work_type_cost_history**: Historical cost tracking with region support
  - Records cost changes over time with timestamps and user attribution
  - Supports region-specific cost data to account for geographic variations
  - Enables trend analysis and cost tracking for business intelligence
  - Serves as an audit trail for cost changes
- **pgvector**: Vector similarity search extension for PostgreSQL enabling semantic similarity matching
  - Used for vector embeddings storage and similarity search
  - Creates 384-dimensional vector column in products and work_types tables
  - Provides efficient cosine similarity operations via `<=>` operator
  - Used with `ivfflat` index for optimized performance
  - Configured for future expansion with name_vec columns
- **pg_trgm**: Trigram matching extension for PostgreSQL enabling fuzzy text search and string similarity
  - Used for text-based similarity matching
  - Handles typos and small wording variations
  - Activated with `%%` operator and `similarity()` function
  - Provides duplicate protection with configurable threshold (0.85 for work types)
  - Implemented with GIN index on text columns for performance
  - Complements vector search for comprehensive matching

### Frontend
- **Vue.js**: Progressive JavaScript framework for building user interfaces
- **Pinia**: State management for Vue applications
- **Vue Router**: Official router for Vue.js
- **Axios**: Promise-based HTTP client
- **Vite**: Modern frontend build tool and development server with HMR (Hot Module Replacement)
- **Tailwind CSS**: Utility-first CSS framework for responsive design
- **OpenAI API**: Integration for AI-assisted estimate generation from assessment data
- **Chart.js**: JavaScript charting library for data visualization
- **ESLint**: Static code analysis for identifying problematic patterns
- **Prettier**: Code formatter for consistent style
- **Vitest**: Unit testing framework for Vue.js applications
### Backend
- **Node.js**: JavaScript runtime for building server-side applications
- **Express.js**: Web application framework for Node.js
- **PostgreSQL**: Powerful, open source object-relational database system (via Homebrew)
- **Sequelize**: Promise-based Node.js ORM for PostgreSQL and other databases
- **pgloader**: Tool for migrating data from SQLite to PostgreSQL
- **Nodemon**: Utility for automatically restarting Node.js applications
- **Jest**: JavaScript testing framework
- **Supertest**: Library for testing HTTP servers
- **Helmet**: Security middleware for Express
- **CORS**: Cross-Origin Resource Sharing middleware
- **dotenv**: Environment variable management
- **Winston**: Logging library
## Development Setup
- **Package Manager**: npm for dependency management
- **Version Control**: Git for source code management
- **Environment Management**: Different configurations for development and production
- **Linting**: ESLint and Prettier for code quality
- **Testing**: Vitest for frontend, Jest for backend
- **Build Process**: Vite for frontend bundling with integrated Tailwind CSS via the @tailwindcss/vite plugin
- **Development Servers**: Vite dev server for frontend, Nodemon for backend
- **Database**: PostgreSQL running locally (installed via Homebrew) or in Docker container
- **Service Management**: Custom services.sh script for controlling frontend and backend processes
- **Containerization**: Docker and Docker Compose for consistent development environments

## Docker Environment
- **Frontend Container**: Node.js 20 Alpine with Vite development server on port 5173
- **Backend Container**: Node.js 20 Alpine with Express server on port 3000
- **Database Container**: PostgreSQL 16 Alpine on port 5432
- **Volume Mounts**:
  - Named volumes for node_modules to prevent host overriding
  - Host source code mounted for live development
  - Persistent volume for database data
  - Persistent volume for uploaded files
- **Network**: Custom bridge network for inter-container communication
- **Environment Variables**: Configured in docker-compose.yml for each service
- **Health Checks**: Implemented for all services to ensure proper startup order
## Service Management
A custom services.sh Bash script manages the starting, stopping, and restarting of frontend and backend services:
- **Command Structure**: `./services.sh {start|stop|restart|status} [frontend|backend|all]`
- **Service Ports**: Frontend on 5173 (Vite), Backend on 3000 (Express)
- **Logging**: Logs stored in /logs directory for troubleshooting
- **Status Checking**: Uses lsof to check port usage and service status
Common commands:
```bash
# Start all services
./services.sh start all
# Check status of services
./services.sh status
# Restart only the frontend
./services.sh restart frontend
# Stop all services
./services.sh stop all
```
## Technical Constraints
- **Browser Compatibility**: Support for modern browsers (last 2 versions)
- **Accessibility**: WCAG 2.1 AA compliance
- **Performance**: Core application should load and respond quickly
- **Security**: Implementation of security best practices
- **Scalability**: Architecture should support growth
- **Visual Consistency**: Maintaining consistent UI patterns in both light and dark modes
- **Maintainability**: Clean code principles and documentation
## Dependencies
Dependencies are managed through package.json files in both frontend and backend projects. We use mcp-package-version to ensure all packages are up-to-date.
### Key Frontend Dependencies
- vue
- vue-router
- pinia
- axios
- tailwindcss (v4)
- primevue (v4, unstyled mode)
  - Timeline component for project progression
  - No theme or core styles imported
  - Icons from primeicons package
  - Component-level imports for tree-shaking
  - Styled with Tailwind utilities
  - Dark mode support through Tailwind classes

### Key Backend Dependencies
- express
- pg (PostgreSQL client)
- sequelize
- cors
- helmet
- winston
- bcryptjs (Password hashing and authentication)
- puppeteer (HTML-to-PDF rendering)
- ejs (PDF templates)
- multer (File uploads)

## Development Patterns
- **API Communication**: Standardized services extending BaseService for consistent data handling
- **Data Transformation**: Centralized conversion between camelCase (frontend) and snake_case (backend) using apiAdapter
- **Error Handling**: Standardized error handling with consistent response format and detailed logging
- **Form Validation**: Client-side validation with field-specific error messages and visual indicators
- **Component Structure**: Single-file components with script, template, and style sections
- **State Management**: Composition API with ref and reactive for local state
- **Entity ID Handling**: Dual property pattern (id and entityId) for backward compatibility
- **PDF Generation**: Robust error handling with fallbacks for undefined values
- **Docker Compatibility**: Special configuration for Puppeteer in containerized environments
- **File System Access**: Proper directory structure and permissions for file operations
- **Database Migration**: Strategies for migrating from SQLite to PostgreSQL with proper data conversion
- **View Management**: Transaction-based view handling for safe schema modifications
- **Dependency Analysis**: Database object dependency checking before modifications
- **Model-Schema Alignment**: Tools to identify and fix discrepancies between models and database
- **Documentation Generation**: Automated database documentation from actual schema

## WebSocket Security
- **HTTPS Compatibility**: WebSocket connections must use secure protocol (wss://) when the application is accessed over HTTPS
- **Vite HMR Configuration**: Host-based configuration in vite.config.js to support both HTTP and HTTPS environments
  ```javascript
  // In vite.config.js
  hmr: {
    // Enable HMR with host-based configuration
    host: 'job.806040.xyz',
    clientPort: 5173
    // No explicit protocol setting - browser will use wss:// for HTTPS
  }
  ```
- **Mixed Content Prevention**: Avoiding mixed content errors when accessing secure pages with insecure WebSocket connections
- **Nginx Proxy Manager**: SSL termination handled by Nginx Proxy Manager in production environment
- **Error Handling**: Proper error handling for WebSocket connection failures

## Database Migration
- **Migration Tool**: pgloader for transferring data from SQLite to PostgreSQL
- **Column Naming**: Consistent snake_case naming convention for all database columns
- **Data Type Conversion**: Proper handling of text to date conversions and other type transformations
- **Index Creation**: Adding appropriate indexes for performance optimization
- **Backup Strategy**: Creating database backups before and after migration
- **Column Renaming**: Handling column name changes to match model definitions
- **Post-Migration Verification**: Testing API endpoints to ensure proper functionality
- **View Dependency Management**: Transaction-based approach to handle dependent views during schema changes
- **Migration Testing**: Framework for safely testing migrations in isolated environments
- **Schema Documentation**: Automated generation of schema, view, relationship, and index documentation

## Database Schema Management Tools

### ViewManager Class
- Handles database views during schema changes and migrations
- Safely drops and recreates views within transactions
- Retrieves view definitions when needed
- Identifies dependent views for any table

### DependencyAnalyzer Class
- Analyzes database object dependencies using PostgreSQL system catalogs
- Finds all dependent objects (views, tables, indexes, triggers) for any table
- Identifies specific column dependencies for precise impact analysis
- Maps PostgreSQL type codes to readable names

### MigrationChecker Class
- Performs pre-migration checks to identify potential issues
- Checks for column dependencies before migration
- Generates migration code with proper handling of dependencies
- Makes recommendations based on identified issues

### ModelSchemaComparer Class
- Compares Sequelize models to actual database schema
- Identifies mismatches in column types, nullability, and existence
- Maps Sequelize types to PostgreSQL types
- Works with virtual fields and field aliases

### ModelSyncTool Class
- Generates migrations to fix model-schema mismatches
- Creates transaction-based migrations that handle dependencies
- Handles breaking and recreating database views
- Generates appropriate rollback (down) functions

### MigrationTester Class
- Provides utilities for testing migrations in isolation
- Creates and restores database backups
- Tests migrations with Sequelize CLI commands
- Recovers from failed migrations

### DatabaseVerifier Class
- Verifies that all views are valid after migrations
- Checks for data integrity issues like orphaned foreign keys
- Tests each view with sample queries
- Identifies potentially problematic dependencies

### DocumentationGenerator Class
- Generates Markdown documentation of database schema
- Documents tables, columns, relationships, and indexes
- Creates complete view documentation with definitions and dependencies
- Automatically updates documentation when schema changes

## Tech Context

- Node.js backend (Express)
- Vue.js frontend
- LLM integration (DeepSeek/OpenAI)
- Sequelize ORM for database
- PDF generation for estimates
- Standard RESTful API patterns
- Transaction-based schema modifications
- View registry for consistent recreation
- Database documentation generation
