# Construction Management App

- Maintain a structured Memory Bank system with required core files (projectbrief.md, productContext.md, activeContext.md, systemPatterns.md, techContext.md, progress.md, database-routes-map.md) that follow a specific hierarchy for documenting the project.
- The memory-bank files are located at /Volumes/4TB/Users/josephmcmyne/myProjects/management/memory-bank.

## 1. Project Overview & Environment
* **Environment** Docker
* **Project:** Construction Management Web Application
* **Base Directory:** `/Volumes/4TB/Users/josephmcmyne/myProjects/management/`
* **Tech Stack:**
    * Frontend: Vue.js 3
    * Backend: Node.js / Express
    * Database: PostgreSQL with Sequelize ORM
* **Core Goal:** Assist with development tasks within this specific project environment, adhering strictly to its established standards and conventions.

## 2. Core Development Principles & Conventions

### Case Convention

* **Frontend (Vue.js):** Strictly use `camelCase` for all props, data, computed properties, methods, variables, and template bindings.
* **Backend (Node.js/Sequelize/PostgreSQL):** Strictly use `snake_case` for all database table names, field names, and API response/request keys *at the boundary*.
* **Database Naming:** Primary keys are `id`. Foreign keys follow the `{table_name}_id` pattern (e.g., `client_id`).

### Data Normalization (API Boundary)

* **Incoming Data (Backend -> Frontend):** Use `apiAdapter.standardizeResponse()` or utilities like `casing.js` (`toCamelCase`, `normalizeClient`) to convert `snake_case` data from the API into `camelCase` *before* it's used in Vue components.
* **Outgoing Data (Frontend -> Backend):** Use `apiAdapter.standardizeRequest()` or utilities like `casing.js` (`toSnakeCase`) to convert internal frontend `camelCase` data into `snake_case` *before* sending it in API requests (unless the specific backend service/endpoint handles this conversion automatically, e.g., via `BaseService`).

### UUID Validation

* **Backend Routes:** Always apply `uuidValidator.js` middleware (`validateUuid`, `validateMultipleUuids`) to routes expecting UUID parameters to prevent invalid IDs reaching the database.
* **Frontend Services:** Use `isValidUuid` (from `utils/casing.js`) to validate IDs *before* making API calls.

### Error Handling (Backend)

* Utilize the standardized error handling middleware (`standardized-error.middleware.js`).
* Throw appropriate custom error classes (e.g., `NotFoundError`, `ValidationError`) from controllers/services.
* Ensure all API responses adhere to the standard format: `{ success: boolean, data?: any, message?: string }`.
* Use docker commands to check backend and frontend logs for debugging.

### Address Management

* Use the dedicated `addressService` (backend) and `address.service.js` (frontend) for address-related logic, including fetching, formatting, and implementing primary address fallbacks (`getAddressWithFallback`).

### Service Usage

* When interacting with entities (e.g., Projects, Clients), prefer using the standardized services (like `standardized-projects.service.js`) which incorporate proper casing, validation, and error handling.

## 3. Tool Usage & Operations

### File Operations

* Use `edit_file` for modifying existing files. **Crucially, avoid using `write_file` on existing files** unless explicitly required for new functionality or refactoring, to prevent accidental truncation or data loss.
* When creating new files, use descriptive, meaningful names (e.g., `client-details-form.vue`, `project-validation.utils.js`).

### Github commit and database backup
* Use 'git add .' then
'git commit -m "Your descriptive commit message"'
* Use 'docker exec -i management-db-1 pg_dump -U postgres management_db > /Volumes/4TB/Users/josephmcmyne/myProjects/management/database/backups/management_db_$(date +%Y%m%d_%H%M%S).sql'

### Directory Exploration

* Use `list_directory` for initial viewing of a directory's contents.
* Use `directory_tree` for a deeper, recursive view of subdirectories.

### Database Interaction

* For **read-only** database checks or exploration, you *can* use the `query` tool.
* For other operations use following connection details: `psql -U josephmcmyne -d management_db -h localhost -p 5432`

### Service Restarts

* If changes are made to backend services, they may need restarting.
* Use './docker-services.sh restart backend' etc as referenced below.
  up          Start all services or a specific service
  down        Stop all services
  restart     Restart all services or a specific service
  status      Show status of all services
  logs        View logs of all services or a specific service

## 4. Core Restrictions

* Operate *only* within the provided toolset. Do not request external actions or access to tools not listed.
* Strictly adhere to the file modification rules (`edit_file` vs. `write_file`) to preserve data integrity.
* Prioritize using the project's established standardization utilities (`apiAdapter.js`, `casing.js`, `uuidValidator.js`, etc.) over generic solutions.
