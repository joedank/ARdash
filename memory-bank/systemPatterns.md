# System Patterns: Construction Management Web Application

## Deployment Patterns

### Development Mode Web Deployment
- **Nginx Proxy Manager Integration**: External domain access to development server using Nginx Proxy Manager as a reverse proxy while maintaining all development features.
- **Configuration Components**:
  - **Frontend Vite Proxy**: Configures `/api` and `/uploads` paths to forward to backend
  - **API Service Environment Detection**: Automatically selects appropriate baseURL based on domain
  - **Backend CORS Configuration**: Explicitly allows specific external domains
  - **Nginx Proxy Setup**: SSL, WebSocket support, and proper proxy forwarding
- **Technical Implementation**:
  - Vite server with `host: '0.0.0.0'` setting to allow external network access
  - Explicit `allowedHosts` configuration to permit specific domains
  - Environment detection using `window.location.hostname` checks
  - Cross-domain cookie handling with `withCredentials: true`
  - Origin-specific CORS headers for improved security
- **Benefits**:
  - Enables external access without moving to production mode
  - Maintains hot module replacement and other development tools
  - Provides secure SSL-encrypted connections
  - Preserves full functionality including authentication and file uploads
  - Facilitates testing in real-world scenarios while in development

## Core Architecture

The system follows a modular client-server architecture with clear separation of concerns:

### Backend Architecture
- **Node.js + Express.js**: Core server framework
- **RESTful API Design**: Standardized endpoints and responses
- **Controller-Service Pattern**: Controllers handle requests, services implement business logic
- **Repository Pattern**: Database access abstracted through Sequelize models
- **Authentication Middleware**: Token-based auth protects all routes
- **Error Handling Middleware**: Centralized error processing

### Frontend Architecture
- **Vue.js Component Structure**: Modular UI components
- **Pinia State Management**: Centralized state handling
- **Service Layer**: Abstracted API communication
- **Protected Routes**: Authentication-required navigation
- **Theme Management**: Light/dark mode with Tailwind CSS
- **Local Development Proxy**: Vite server proxy configured (`vite.config.js`) to forward requests for backend-served assets (e.g., `/uploads`) to the running backend server, enabling seamless local development.


## Data Models

### Core Entities
- **Users**: Authentication and system access
- **Clients**: Business contacts and customer data
- **Addresses**: Multiple addresses per client
- **Invoices**: Billing documents with items
- **Estimates**: Project quotations with items
- **Projects**: Job assessments and active projects
- **Settings**: System configuration

### Data Relationships
- User -> Clients (many-to-many)
- Client -> Addresses (one-to-many)
- Client -> Invoices (one-to-many)
- Client -> Estimates (one-to-many)
- Client -> Projects (one-to-many)
- Invoice -> Items (one-to-many)
- Estimate -> Items (one-to-many)
- Project -> Inspections (one-to-many)
- Project -> Photos (one-to-many)
- Project -> Estimate (many-to-one)
- Invoice -> ClientAddress (many-to-one)
- ClientAddress -> Invoices (one-to-many)
- Estimate -> ClientAddress (many-to-one)
- ClientAddress -> Estimates (one-to-many)

## API Design Patterns

### RESTful Endpoints
- Resource-based routing (/api/clients, /api/invoices, /api/projects)
- HTTP verbs for operations (GET, POST, PUT, DELETE)
- Consistent response format
- Complete CRUD operations for all sub-resources (including get operations)

### API Response Structure
```javascript
{
  success: true|false,
  data: {}, // Response data
  message: "" // Optional message
}
```

### UUID Validation Pattern
- **Problem**: When route parameters are undefined or invalid, passing them directly to database queries causes 500 errors with cryptic messages like "invalid input syntax for type uuid: 'undefined'"
- **Solution**: Implement a two-part validation strategy:
  ```javascript
  // Frontend validation in Vue component
  const loadEstimate = async () => {
    // Check if estimateId is defined before making the API call
    if (!estimateId) {
      console.error('Estimate ID is undefined');
      error.value = 'Invalid estimate ID. Please try again.';
      return;
    }
    // Proceed with API call...
  };

  // Backend validation in controller
  const getEstimate = async (req, res) => {
    const { id } = req.params;

    // Validate UUID format before querying the database
    if (!id || id === 'undefined' || id === 'null') {
      return res.status(400).json({
        success: false,
        message: 'Invalid estimate ID provided'
      });
    }

    // UUID validation using regex
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid UUID format'
      });
    }

    // Proceed with database query...
  };
  ```
- **Benefits**:
  - Prevents 500 errors by validating input before database queries
  - Returns appropriate 400 status codes for client errors
  - Provides clear error messages to help diagnose issues
  - Logs validation failures for easier debugging

### Authentication Flow
- JWT token generation and validation
- Protected routes requiring authentication
- Token refresh mechanism

### Address Management
- **Client-Address Relationship**: One-to-many relationship allowing multiple addresses per client
- **Address Retrieval**: GetClientAddress endpoint for fetching specific addresses by ID
- **Flexible ID Referencing**: Support for client_id, client_fk_id, and clientId variations
- **Error Resiliency**: Graceful fallback for address loading failures in document workflows
- **Address Selection**: Support for specific address selection in invoices and estimates
- **Primary Address Flag**: Special is_primary field for default address designation
- **Address Format Standardization**: Consistent address formatting across display contexts

### Robust Sequential ID Generation (Invoice/Estimate Numbers)
- **Problem**: Simple incrementing based on the highest existing number can lead to duplicates if records are deleted (leaving gaps) or during race conditions. Unique database constraints will then cause errors.
- **Solution**:
    1. Retrieve the highest existing number for the sequence (e.g., `INV-00004`), including soft-deleted records (`paranoid: false`).
    2. Calculate the next potential sequence number (e.g., 5).
    3. Enter a loop:
        a. Format the potential number with prefix and padding (e.g., `INV-00005`).
        b. Check if a record with this exact number already exists (including soft-deleted: `paranoid: false`).
        c. If it exists, increment the sequence number and repeat the loop.
        d. If it does not exist, exit the loop and return the unique formatted number.
- **Implementation**: See `generateInvoiceNumber` in `invoiceService.js` and `generateEstimateNumber` in `estimateService.js`.
- **Benefit**: Guarantees uniqueness even with soft deletes or potential race conditions, preventing database constraint violations.

### Project Management
- **Two-Phase Project Workflow**: Projects start as assessments, then convert to active jobs
- **Project-to-Estimate Conversion**: Assessment data is used to generate estimates
- **Project-Estimate-Job Relationship**: Estimates are required before converting assessments to jobs
- **Timeline Visualization Pattern**: Visual representation of project progression through stages
- **Collapsible Previous State Pattern**: Previous state information is available but tucked away
- **State-Specific Content Display**: Content changes based on project type (assessment vs. active)
- **Photo Management**: Different photo types (before, after, receipt, assessment) with categorization
- **Inspection Data Structure**: Structured JSON for measurements, conditions, and materials
- **Filtering Pattern**: Support for filtering projects by type, status, and scheduled date
- **Client Integration**: Each project is linked to a client record

### Assessment-to-Estimate Data Flow Pattern
- **Problem**: Assessment data contains valuable measurements, conditions, and materials information that should be reused when creating estimates
- **Pattern**: Implement data flow from assessment to estimate generation through the LLM interface
- **Solution**:
  ```javascript
  // Frontend assessment data selection
  <select
    v-model="assessmentProjectId"
    class="flex-grow px-3 py-1 text-sm border rounded-md"
  >
    <option value="" disabled>Select a project</option>
    <option v-for="project in availableProjects" :key="project.id" :value="project.id">
      {{ project.client?.display_name || 'Unknown Client' }} - {{ formatDate(project.scheduled_date) }}
    </option>
  </select>

  // Backend assessment data formatting
  _formatAssessmentData(assessmentData) {
    if (!assessmentData || !assessmentData.inspections) return "No assessment data.";

    let formattedText = "ASSESSMENT DATA:\n";

    // Add project scope
    if (assessmentData.scope) {
      formattedText += `Project Scope: ${assessmentData.scope}\n\n`;
    }

    // Process inspections by category
    const conditionInspections = assessmentData.inspections.filter(i => i.category === 'condition');
    const measurementInspections = assessmentData.inspections.filter(i => i.category === 'measurements');
    const materialsInspections = assessmentData.inspections.filter(i => i.category === 'materials');

    // Format each category appropriately
    // ...

    return formattedText;
  }
  ```
- **Benefits**:
  - Eliminates duplicate data entry
  - Ensures consistency between assessment and estimate
  - Leverages specialist measurements for more accurate estimates
  - Reduces clarifying questions needed from customer
  - Provides clear visual feedback about assessment data incorporation

### Photo Management Pattern
- **Component Structure**: `PhotoUploadSection.vue` for uploads, `PhotoGrid.vue` for display and management.
- **Display**: Grid layout (`PhotoGrid.vue`) showing thumbnails.
- **Preview**: Modal (`BaseModal` integration in `PhotoGrid.vue`) for full-size view with details (notes, timestamp).
- **Navigation**: Keyboard (arrow keys) and button navigation within the preview modal.
- **Actions**: Context menu on thumbnails (`PhotoGrid.vue`) with options for 'View Full Size' and 'Delete'. Delete action also available in the preview modal header.
- **Deletion Workflow**:
    - Frontend triggers delete request via `projectsService.deletePhoto`.
    - Browser confirmation dialog presented to the user.
    - Backend API endpoint (`DELETE /projects/:projectId/photos/:photoId`) handles database record removal and file system cleanup (Backend implementation pending).
    - Frontend updates UI upon success/failure using `vue-toastification` and refreshes project data.
- **Upload Handling (`PhotoUploadSection.vue`)**:
    - Supports standard web formats (JPEG, PNG, GIF, WebP).
    - Includes file size validation (max 10MB).
    - Provides progress indication and cancellation option.
    - HEIC/HEIF conversion removed to simplify dependencies.
- **Categorization**: Photos are associated with a `photo_type` (e.g., 'before', 'after', 'receipt', 'assessment', 'condition').

## Document Generation
- **PDF Generation**: Uses Puppeteer (headless Chrome) to render EJS HTML templates with CSS into PDF documents for both Invoices and Estimates. Modern, clean design with consistent styling between document types provides professional appearance and improved readability. Features include status badges, responsive layout, and optimized typography.

## Component Communication Patterns

### Parent-Child Communication
- **Props Down**: Data flows from parent to child components through props
- **Events Up**: Children communicate to parents through custom events
- **v-model Binding**: Two-way binding using modelValue prop and update:modelValue event
- **Event Naming**: Components using v-model emit update:modelValue events
- **Watchers**: Used to synchronize derived data when component state changes
- **Property Synchronization**: Client ID and address ID extracted from client objects

### LLM-Enhanced Service Estimation Pattern
- **Component Structure**: `LLMEstimateInput.vue` for user input and LLM interaction, `ProductMatchReview.vue` for service matching.
- **Assessment Data Integration**:
  - Project dropdown for selecting assessment data
  - Visual indicators when assessment data is incorporated
  - Formatted assessment data sent to LLM for improved accuracy
  - Reduced clarifying questions when assessment data is available
- **Data Workflow**:
  1. User selects assessment project (optional)
  2. System fetches and formats assessment inspection data
  3. User enters project description
  4. Combined data sent to LLM for analysis
  5. LLM identifies required measurements and services
  6. User provides additional details if needed
  7. LLM generates service line items
  8. Services matched to catalog with weighted scoring algorithm
  9. User reviews and confirms service matches
  10. Finalized estimate created and routed to estimate creation page
- **Service Focus**:
  - All LLM prompts specifically target repair services
  - UI clearly communicates service-focused approach
  - Service matching algorithm prioritizes service catalog items
  - Line item creation always sets type to 'service'

### Product Catalog Management Pattern
- **Component Structure**: `ProductCatalogManager.vue` for product management in admin settings.
- **Modal Approach**: Uses modals for product creation/editing with form validation.
- **Display**: Table layout for product listings with type-specific styling.
- **Actions**: Edit and delete functions with confirmation modals for destructive actions.
- **Filters**: Type filtering (products vs services) and text search functionality.
- **Unit-Based Pricing**: Products defined with specific unit types (sq ft, ln ft, each, etc.) for precise estimates.
- **State Management**:
    - Local state for product listings and search/filter state
    - Toast notifications for operation feedback
    - Loading indicators for async operations
- **Workflow**:
    1. Products managed in admin settings
    2. Products made available in estimate line item selection
    3. Product quantities entered based on unit type
    4. Line item totals calculated based on quantity * price

## Frontend Structure

### Component Organization
- Layouts (structural components)
- Views (page components)
- Components (reusable UI elements)
  - Base components (buttons, inputs, icons)
  - Form components (text fields, selectors, toggles)
  - Data display components (cards, badges, tables)
  - Feedback components (alerts, loaders)
  - Overlay components (modals, dropdowns)
  - Progress components
    - Minimalist Timeline (PrimeVue integration)
      - Icon-only display with tooltips
      - Horizontal state progression
      - Small markers (5x5) with connecting lines
      - Unstyled PrimeVue components with Tailwind styling
      - Dark mode support through CSS variables
- Services (API communication)
- Stores (state management)

### Navigation System
- Vue Router with nested routes
- Protected route guards
- Role-based access control
- Dynamic component loading with forced rerendering when necessary
- Interactive navigation elements with both toggle switches and clickable labels

### Component Lifecycle Management
- Dynamic key attributes for forcing component reloading
- Timestamp-based parameters to ensure fresh component mounting
- Context-specific routing and component loading
- Careful management of component state during navigation

### Settings Interface Pattern
- Context switching between personal and admin settings
- Tab-based organization of settings categories
- Admin-only sections with permission checks
- Form validation and error handling
- Success messages for user feedback
- Settings persistence through API calls

## Authentication System

### Authentication Flow
- Login form submission
- JWT token generation
- Token storage in browser
- Automatic token refresh
- Protected route access

### Authorization Model
- Role-based access (Admin, User)
- Permission checking middleware
- Component-level permission gates
- Admin toggle in settings interface

## Component Relationships
- Protected route system ensures all routes require authentication by default
- Login and register forms are the only components accessible without authentication
- The router handles redirects based on authentication status
- App.vue conditionally renders navigation and content based on authentication state
- Frontend components communicate with backend through service layer
- Backend controllers coordinate with services to fulfill requests
- Models interact with the database, defining schema and relationships
- Middleware processes requests before they reach controllers
- Vue Router maps URLs to Vue components
- Pinia stores maintain application state accessible by components
