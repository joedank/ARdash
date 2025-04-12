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
- **Database**: PostgreSQL running locally (installed via Homebrew)
- **Service Management**: Custom services.sh script for controlling frontend and backend processes
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
