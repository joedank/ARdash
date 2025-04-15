# Technical Context: Construction Management Web Application

## Technologies Used
### Frontend
- **Vue.js**: Progressive JavaScript framework for building user interfaces
- **Pinia**: State management for Vue applications
- **Vue Router**: Official router for Vue.js
- **Axios**: Promise-based HTTP client
- **Vite**: Modern frontend build tool and development server
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
