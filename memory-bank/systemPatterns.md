# System Patterns: Construction Management Web Application

## API and Data Patterns

### API Route Parameter Validation Pattern

- **Problem**: Some API routes have UUID validation unnecessarily applied to non-parameter routes
- **Pattern**: Explicit validation middleware application based on route parameter presence
- **Solution**: Only apply UUID validation middleware to routes with ID parameters

```javascript
// Routes with ID parameters use UUID validation
router.get('/:id', authenticate, validateUuid('id'), controller.get);

// Routes without ID parameters skip UUID validation
router.get('/current-active', authenticate, controller.getCurrentActiveJob);
```

- **Key Aspects**:
  - Clear documentation in route definition comments about validation requirements
  - Explicit non-application of UUID validation for collection routes
  - Controller methods document their parameter expectations
  - Service methods handle empty results appropriately
  - Frontend services properly handle both success and error responses

### Project Status Management Pattern

- **Problem**: Project workflow lacks clarity without proper state representation for all business outcomes
- **Pattern**: Implement comprehensive status tracking with a complete workflow lifecycle
- **Solution**: Implement a full set of status values that match business workflow including negative outcomes

```javascript
// 1. Status-based filtering in service layer for rejected assessments
async getRejectedProjects(limit = 5) {
  try {
    const projects = await Project.findAll({
      where: {
        type: 'assessment',
        status: 'rejected'
      },
      // Include relationships and sorting...
    });
    return projects;
  } catch (error) {
    logger.error('Error getting rejected projects:', error);
    throw error;
  }
}

// 2. Rejection handling with reason tracking
async rejectAssessment(projectId, rejectionReason = null) {
  try {
    const project = await Project.findByPk(projectId);
    if (!project) {
      throw new ValidationError('Project not found');
    }

    if (project.type !== 'assessment') {
      throw new ValidationError('Only assessment projects can be rejected');
    }

    // Update status and capture reason
    const updateData = { status: 'rejected' };
    if (rejectionReason) {
      updateData.scope = project.scope
        ? `${project.scope}\n\nRejection Reason: ${rejectionReason}`
        : `Rejection Reason: ${rejectionReason}`;
    }

    await project.update(updateData);
    return await this.getProjectWithDetails(projectId);
  } catch (error) {
    logger.error(`Error rejecting assessment project ${projectId}:`, error);
    throw error;
  }
}

// 3. Validation to ensure status appropriateness by project type
if (project.type === 'assessment' && !['in_progress', 'completed', 'rejected'].includes(status)) {
  throw new ValidationError(`Invalid status '${status}' for assessment type projects`);
} else if (project.type === 'active' && !['upcoming', 'in_progress', 'active', 'completed'].includes(status)) {
  throw new ValidationError(`Invalid status '${status}' for active type projects`);
}
```

- **Key Aspects**:
  - Status values (`pending`, `upcoming`, `in_progress`, `completed`, `rejected`) reflect complete business workflow
  - Project types have appropriate statuses (`rejected` only for assessments)
  - Rejection reasons are captured for business intelligence
  - Dashboard shows separate section for rejected assessments
  - API endpoints provide filtered access to each status type
  - Status validation ensures type-appropriate transitions
  - Comprehensive workflow improves business analytics and planning

### Data-Driven Conditional Display Pattern

- **Problem**: Project management shows duplicate entries for related projects (assessment and converted job) cluttering the UI
- **Pattern**: Implement database-driven filtering with toggle option for additional visibility
- **Solution**: Filter out converted assessments by default while maintaining relationship data

```javascript
// Backend filtering based on converted_to_job_id
if (filters.includeConverted !== true) {
  where.converted_to_job_id = null; // Only show non-converted assessments by default
}

// Frontend toggle with clear visual indicators
<div class="flex items-center space-x-2">
  <input
    type="checkbox"
    id="showConverted"
    v-model="showConvertedProjects"
    class="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
  />
  <label for="showConverted" class="text-sm">
    Show converted assessments
  </label>
</div>

// Visual conversion indicator
<span
  v-if="project.convertedJob || project.assessment"
  class="ml-1 inline-flex items-center"
  title="This project has been converted"
>
  <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-blue-500">
    <!-- Arrow icon path -->
  </svg>
</span>
```

- **Key Aspects**:
  - The database filtering occurs at the API level for efficiency
  - Relationship data is always included in the API response for complete context
  - Conversion indicators with arrow icons provide visual cues about relationships
  - User toggle provides explicit control over view complexity
  - Reduces UI clutter while maintaining data integrity
  - Visual indicators make relationships clear when viewing both items

### Workflow-Focused Dashboard Pattern

- **Problem**: Small construction companies typically focus on one job at a time, but project dashboards often show all projects with equal emphasis
- **Pattern**: Structure dashboard to highlight the current active job while providing context about the project pipeline
- **Solution**: Create specialized API endpoints with focused queries and a UI hierarchy that matches the company's workflow

```javascript
// Backend service - Get the current active job (most recently updated)
async getCurrentActiveJob() {
  const activeJob = await Project.findOne({
    where: {
      type: 'active',
      status: 'in_progress'
    },
    include: [ /* Relations */ ],
    order: [
      ['updated_at', 'DESC']
    ]
  });

  return activeJob;
}

// Frontend - Highlight current job with visual emphasis
<div
  v-if="currentActiveJob"
  class="border-2 border-blue-400 dark:border-blue-600 rounded-lg overflow-hidden shadow-md"
>
  <ProjectCard
    :project="currentActiveJob"
    @click="navigateToProject(currentActiveJob.id)"
    class="cursor-pointer"
  />
</div>
```

- **Key Aspects**:
  - Separate API endpoints for different project categories (active job, assessments, upcoming, completed)
  - Database queries optimized for each specific use case rather than frontend filtering
  - Visual hierarchy that matches the company's actual workflow
  - Clear section headings with descriptive text explaining their purpose
  - Prominent display of the current active job with visual emphasis
  - Contextual grouping of projects by workflow phase (assessment, upcoming, completed)
  - Independent loading states for each section to improve perceived performance

### Project Relationship Display Pattern

- **Problem**: Project management shows duplicate entries for related projects (assessment and converted job) cluttering the UI
- **Pattern**: Implement database-driven filtering with toggle option for additional visibility
- **Solution**: Filter out converted assessments by default while maintaining relationship data

```javascript
// Backend filtering based on converted_to_job_id
if (filters.includeConverted !== true) {
  where.converted_to_job_id = null; // Only show non-converted assessments by default
}

// Frontend toggle with clear visual indicators
<div class="flex items-center space-x-2">
  <input
    type="checkbox"
    id="showConverted"
    v-model="showConvertedProjects"
    class="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
  />
  <label for="showConverted" class="text-sm">
    Show converted assessments
  </label>
</div>

// Visual conversion indicator
<span
  v-if="project.convertedJob || project.assessment"
  class="ml-1 inline-flex items-center"
  title="This project has been converted"
>
  <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-blue-500">
    <!-- Arrow icon path -->
  </svg>
</span>
```

- **Key Aspects**:
  - The database filtering occurs at the API level for efficiency
  - Relationship data is always included in the API response for complete context
  - Conversion indicators with arrow icons provide visual cues about relationships
  - User toggle provides explicit control over view complexity
  - Reduces UI clutter while maintaining data integrity

### Vue Component Tag Structure Pattern

- **Problem**: Improper component tag structure can cause rendering issues and unexpected behavior in Vue templates
- **Solution**: Implement consistent component tag structure following Vue best practices

```html
<!-- For components with children, use opening and closing tags -->
<ParentComponent
  prop1="value1"
  :prop2="dynamicValue"
  @event="handleEvent"
>
  <ChildComponent />
</ParentComponent>

<!-- For components without children, use self-closing tags -->
<StandaloneComponent
  prop1="value1"
  :prop2="dynamicValue"
  @event="handleEvent"
/>
```

- **Key Aspects**:
  - Always place attributes inside the opening tag, never after the closing tag
  - Use self-closing tags (`<Component />`) for components without children
  - Use opening and closing tags (`<Component></Component>`) for components with children
  - Never place HTML comments inside attribute areas (`<!-- comment -->` should be on separate lines)
  - Use proper indentation to improve readability
  - Ensure all required props are provided to prevent Vue console warnings

### Form State Reset Pattern

- **Problem**: Form state can become contaminated with data from previous edits, especially with complex nested objects
- **Solution**: Implement a two-step form reset and population process:

```javascript
// Two-step form reset and population process
const editItem = (item) => {
  // Step 1: Reset form to default values
  Object.assign(editingItem, {
    id: '',
    name: '',
    relatedObject: null,
    // Other default values
  });

  // Step 2: Populate with item data
  Object.assign(editingItem, {
    id: item.id,
    name: item.name,
    relatedObject: item.relatedObject || null,
    // Other values with fallbacks
  });

  // Open modal or proceed with editing
  showEditModal.value = true;
};
```

- **Key Aspects**:
  - Reset form state to default values before populating with new data
  - Use `Object.assign()` for efficient object property updates
  - Provide fallbacks for potentially undefined values
  - Consider the complete object structure expected by form components
  - Use console logging during development to verify object structures

### Enhanced Deletion Pattern with Dependency Checking

- **Problem**: Project deletion can fail when circular references exist (e.g., assessment → job and job → assessment)
- **Solution**: Implement a two-phase deletion process with dependency checking and options:

```javascript
// 1. Dependency checking before deletion
async getProjectDependencies(projectId) {
  // Check for related assessments/jobs, photos, inspections, estimates
  return {
    hasRelatedJob: !!relatedJob,
    relatedJob,
    hasRelatedAssessment: !!relatedAssessment,
    relatedAssessment,
    inspectionsCount,
    photosCount,
    estimatesCount,
    hasDependencies: /* boolean summary */
  };
}

// 2. Reference-safe deletion that breaks circular dependencies
async deleteProject(projectId) {
  // Within transaction:
  // 1. If assessment with converted job, update job: assessment_id = null
  // 2. If job with assessment reference, update assessment: converted_to_job_id = null
  // 3. Delete photos, inspections, etc.
  // 4. Delete project
}

// 3. Optional complete reference deletion (cascade-like behavior)
async deleteProjectWithReferences(projectId) {
  // Delete both sides of relationships and all connected entities
}
```

- **UI Implementation**: Modal with dependency details and deletion options

  ```html
  <!-- Show detailed dependency impact -->
  <div v-if="projectDependencies.hasDependencies" class="rounded-lg border p-3">
    <h4>Deletion Impact</h4>
    <div class="text-sm">{{ detailedDeleteMessage }}</div>
  </div>

  <!-- Deletion options as radio buttons -->
  <div class="flex items-start space-x-2">
    <input type="radio" v-model="deletionOption" value="break" />
    <label>Break references only</label>
  </div>
  <div class="flex items-start space-x-2">
    <input type="radio" v-model="deletionOption" value="all" />
    <label>Delete everything</label>
  </div>
  ```

- **Key Aspects**:
  - Explicit display of deletion impact before confirmation
  - User control over deletion strategy
  - Proper transaction management for data integrity
  - Breaking circular references to prevent database constraint issues
  - Consistent user experience across the application

### Additional Work Integration Pattern

- **Problem**: Construction projects often require additional work beyond the original estimate line items, but there's no structured way to track this
- **Solution**: Implement a one-to-one relationship between line items and additional work records with a visibility toggle:

```javascript
// 1. Database side: One-to-one relationship with an estimate item
EstimateItem.hasOne(EstimateItemAdditionalWork, {
  foreignKey: 'estimate_item_id',
  as: 'additionalWork'
});

// 2. UI implementation: Conditional visibility with checkbox toggle
<div class="flex items-center mb-2">
  <input
    type="checkbox"
    v-model="additionalWorkChecked[item.id]"
    class="mr-2 h-4 w-4"
  />
  <label class="text-md font-medium">
    Additional work performed
  </label>
</div>

<div v-if="additionalWorkChecked[item.id]" class="mt-2">
  <textarea
    v-model="additionalWorkText[item.id]"
    class="w-full rounded-lg border p-2"
    placeholder="Describe what additional work was performed..."
  ></textarea>
</div>
```

- **Key Aspects**:
  - Only create database entries when additional work is actually performed
  - Use visual indicators (badges) to show items with additional work
  - Implement clear toggle UI pattern to reduce interface complexity
  - Handle both front-end state (checkbox) and back-end state (database record) separately
  - Map multiple entries by item ID for efficient data transfer// This would be added to the file in the Document Generation section, right after the PDF Generation explanation

### Standardized Service Pattern

- **Problem**: Inconsistent data handling between frontend and backend causing errors and maintenance issues
- **Solution**: Implement a standardized service pattern with BaseService class:

```javascript
// 1. Create a base service class that handles common operations:
class BaseService {
  constructor(resourceUrl) {
    this.resourceUrl = resourceUrl;
    this.api = api;
  }

  async create(data) {
    try {
      const response = await this.api.post(
        this.resourceUrl,
        this.standardizeRequest(data) // Convert camelCase to snake_case
      );
      return this.standardizeResponse(response); // Convert snake_case to camelCase
    } catch (error) {
      return this._handleError(error);
    }
  }

  // Other CRUD methods...

  standardizeRequest(data) {
    return apiAdapter.standardizeRequest(data);
  }

  standardizeResponse(response) {
    return {
      success: true,
      message: 'Operation successful',
      data: apiAdapter.standardizeResponse(response.data)
    };
  }

  _handleError(error) {
    console.error(`/${this.resourceUrl.replace(/^\//, '')} Service Error:`, error);
    return {
      success: false,
      message: error.message || 'An error occurred',
      data: null
    };
  }
}

// 2. Create entity-specific services that extend the base service:
class EstimateService extends BaseService {
  constructor() {
    super('/estimates');
  }

  // Entity-specific methods...
}

export default new EstimateService();
```

- **Key Aspects**:
  - Centralized data conversion between camelCase and snake_case
  - Consistent error handling with standardized response format
  - Proper logging for debugging
  - Reusable base class for all entity services
  - Standardized CRUD operations with consistent behavior
  - Entity-specific services can add custom methods as needed

### PDF Generation Data Normalization Pattern

- **Problem**: Mixed case conventions (snake_case from database, camelCase in frontend) causing issues in PDF templates
- **Solution**: Implement normalization with fallback handling:

```javascript
// 1. In service layer, normalize data before passing to template:
const pdfPath = await pdfService.generatePdf({
  type: 'estimate',
  data: fieldAdapter.toFrontend(estimate.toJSON()), // Convert to camelCase
  client: fieldAdapter.toFrontend(estimate.client.toJSON()), // Convert to camelCase
  clientAddress: clientAddress ? fieldAdapter.toFrontend(clientAddress.toJSON()) : null,
  filename,
  outputDir: uploadsDir
});

// 2. In EJS template, implement fallback for calculated values:
<td class="text-right text-bold">
  <%
  // Calculate the item total if it's not available
  const itemTotal = item.item_total || item.itemTotal || (parseFloat(item.price || 0) * parseFloat(item.quantity || 0));
  %>
  <%= formatCurrency(itemTotal) %>
</td>
```

- **Key Aspects**:
  - Use field adapter to normalize data at service layer
  - Implement fallback in templates to handle both naming conventions
  - Include on-the-fly calculation as final fallback
  - Keep field adapter implementations consistent between frontend and backend

### Database Migration Case Handling Pattern

- **Problem**: After database migrations (e.g., SQLite to PostgreSQL), case conventions between frontend and backend can cause data display issues
- **Pattern**: Implement robust case conversion with debugging and fallbacks
- **Solution**: Use standardized service pattern with explicit case conversion and debugging

```javascript
// 1. Frontend service with explicit case conversion and debugging
async getAllCommunities(filters = {}) {
  try {
    // Convert filters to snake_case for API
    const snakeCaseFilters = toSnakeCase(filters);

    // Debug the filters being sent to the API
    console.log('Fetching communities with filters:', snakeCaseFilters);

    const response = await apiClient.get('/communities', { params: snakeCaseFilters });

    // Debug the response from the API
    console.log('Communities API response:', response);

    // Ensure we're properly converting snake_case to camelCase
    const communities = toCamelCase(response.data);
    return communities;
  } catch (error) {
    console.error('Error fetching communities:', error);
    throw error;
  }
}

// 2. Utility functions for case conversion
export const toCamelCase = (obj) => {
  if (obj === null || typeof obj !== 'object') return obj;

  if (Array.isArray(obj)) {
    return obj.map(item => toCamelCase(item));
  }

  return Object.keys(obj).reduce((result, key) => {
    // Skip conversion for keys that should remain unchanged
    if (key === 'created_at' || key === 'updated_at' || key === 'deleted_at') {
      result[key] = toCamelCase(obj[key]);
      return result;
    }

    // Convert snake_case to camelCase
    const camelKey = key.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
    result[camelKey] = toCamelCase(obj[key]);
    return result;
  }, {});
};
```

- **Key Aspects**:
  - Add debugging logs at key points in the data flow to identify issues
  - Ensure proper import paths for API services
  - Use utility functions for consistent case conversion
  - Handle both directions: frontend → backend (camelCase → snake_case) and backend → frontend (snake_case → camelCase)
  - Verify data structure at each step of the process
  - Restart services after making changes to ensure clean state
  - Test with authenticated API requests to verify end-to-end flow

### Bidirectional Entity Relationship Pattern

- **Problem**: Entities with two-way relationships (like projects and estimates) can become inconsistent if only one side is updated
- **Solution**: Implement transaction-based updates that maintain both sides of the relationship:

```javascript
// In createEstimate service method
async createEstimate(estimateData) {
  let transaction = null;

  try {
    // Start a transaction to ensure data consistency
    transaction = await sequelize.transaction();

    // Create the estimate with all its data
    const estimate = await Estimate.create({
      // ... estimate data
    }, { transaction });

    // If this estimate is for a project, update the project too
    if (estimateData.project_id) {
      await Project.update(
        { estimate_id: estimate.id },
        { where: { id: estimateData.project_id }, transaction }
      );

      logger.info(`Updated project ${estimateData.project_id} with estimate ${estimate.id}`);
    }

    // Commit the transaction
    await transaction.commit();
    return estimate;
  } catch (error) {
    // Roll back on any error
    if (transaction) await transaction.rollback();
    throw error;
  }
}
```

- **Key Aspects**:
  - Use database transactions to ensure atomicity
  - Update both sides of bidirectional relationships
  - Log relationship changes for debugging purposes
  - Implement proper error handling with rollback
  - Create database backups that maintain referential integrity

### Component Prop Validation and v-model Binding Pattern

- **Problem**: Vue components can generate console warnings and errors when props are not properly validated or when v-model binding is inconsistent
- **Solution**: Implement robust prop validation with defaults and conditional rendering to prevent errors during loading states

```javascript
// 1. Make props optional with default values when they might be undefined during loading
const props = defineProps({
  projectId: {
    type: String,
    required: false, // Not required to prevent errors during loading
    default: ''      // Default value to prevent undefined errors
  },
  show: {
    type: Boolean,
    required: true
  }
});

// 2. Add validation in methods that use potentially undefined props
const confirmReject = async () => {
  // Validate projectId before proceeding
  if (!props.projectId) {
    handleError(new Error('Project ID is missing. Cannot reject assessment.'));
    return;
  }

  // Continue with API call...
};

// 3. Use conditional rendering to prevent component from rendering during loading
<template>
  <RejectAssessmentModal
    v-if="project && project.id" // Only render when data is available
    :project-id="project.id"
    :show="showRejectModal"
    @close="showRejectModal = false"
  />
</template>

// 4. Use correct v-model binding with model-value prop
<BaseModal
  :model-value="show"           // Use model-value instead of show
  @update:model-value="$emit('close')" // Emit event for v-model binding
  @close="onClose"
  size="md"
  :title="'Reject Assessment'"
>
  <!-- Modal content -->
</BaseModal>
```

- **Key Aspects**:
  - Make props optional with default values when they might be undefined during loading
  - Add validation in methods that use potentially undefined props
  - Use conditional rendering (`v-if`) to prevent components from rendering during loading
  - Use correct v-model binding with `model-value` prop and `@update:model-value` event
  - Ensure component documentation clearly states which props are required and which are optional
  - Test components with both defined and undefined prop values to ensure robustness

### Secure WebSocket Connection Pattern

- **Problem**: When accessing the application over HTTPS, WebSocket connections fail with mixed content errors if they use insecure `ws://` protocol
- **Pattern**: Configure Vite to use secure WebSockets when the application is accessed over HTTPS
- **Solution**: Update Vite configuration to handle secure WebSocket connections

```javascript
// In vite.config.js
export default defineConfig({
  // ... other config
  server: {
    // ... other server config
    hmr: {
      // Enable HMR with host-based configuration
      // This lets the browser determine the appropriate protocol
      host: 'job.806040.xyz',
      clientPort: 5173
      // No explicit protocol setting - browser will use wss:// for HTTPS
    }
  }
});
```

- **Key Aspects**:
  - Avoid explicitly setting the WebSocket protocol and let the browser determine it based on the page protocol
  - When the page is loaded over HTTPS, the browser will automatically use secure WebSockets (wss://)
  - When the page is loaded over HTTP, the browser will use regular WebSockets (ws://)
  - Configure `host` to match the domain name used for access
  - This pattern ensures WebSocket connections work properly in both HTTP and HTTPS environments
  - Prevents mixed content errors in modern browsers
  - Works with Nginx Proxy Manager for SSL termination

### Contextual Help Tooltip Pattern

- **Problem**: Explanatory text on UI elements (especially buttons) can make interfaces cluttered and text-heavy
- **Pattern**: Replace inline explanatory text with tooltips that appear only when needed
- **Solution**: Use the BaseTooltip component to provide contextual help without cluttering the UI

```html
<!-- Before: Button with explanatory text -->
<BaseButton
  type="button"
  :variant="primary"
  :disabled="!isValid"
>
  Submit Form
  <span v-if="!isValid" class="text-xs ml-1">
    (requires all fields to be filled)
  </span>
</BaseButton>

<!-- After: Button with tooltip -->
<BaseTooltip
  content="All fields must be filled"
  position="top"
  :disabled="isValid"
>
  <BaseButton
    type="button"
    :variant="primary"
    :disabled="!isValid"
  >
    Submit Form
  </BaseButton>
</BaseTooltip>
```

- **Key Aspects**:
  - Tooltips only appear when needed (typically on hover or focus)
  - The `:disabled` prop on BaseTooltip controls when the tooltip should be shown
  - Tooltip text should be concise and clear (e.g., "Ad type required" instead of "A community must have at least one selected ad type to be active")
  - Tooltips can be positioned relative to the trigger element (top, bottom, left, right)
  - This pattern creates cleaner UI while still providing necessary contextual information
  - Follows modern UI design principles where help is available on demand rather than always visible

### UI Component Animation Pattern

- **Problem**: Static UI components lack visual feedback and feel less interactive
- **Pattern**: Apply consistent animations to UI components for better user experience
- **Solution**: Implement Vue transition components with CSS animations

```html
<!-- Card transition with fade and slide effects -->
<transition name="fade" appear>
  <BaseCard
    variant="bordered"
    class="overflow-hidden card-hover-effect"
  >
    <!-- Card content -->
  </BaseCard>
</transition>

<!-- Table row transitions -->
<transition-group name="row" tag="tbody" class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
  <tr
    v-for="item in items"
    :key="item.id"
    class="hover:bg-gray-50 dark:hover:bg-gray-800 transition-all duration-200"
  >
    <!-- Row content -->
  </tr>
</transition-group>
```

```css
/* CSS animations */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

.row-enter-active,
.row-leave-active {
  transition: all 0.3s ease;
}

.row-enter-from,
.row-leave-to {
  opacity: 0;
  transform: translateX(-10px);
}

.card-hover-effect {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.card-hover-effect:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}
```

- **Key Aspects**:
  - Use Vue's built-in transition components for smooth animations
  - Apply consistent animation patterns across the application
  - Combine fade and transform effects for more natural transitions
  - Use hover effects to provide visual feedback for interactive elements
  - Ensure animations are subtle and enhance rather than distract from the user experience
  - Apply transitions to both initial appearance (with `appear` attribute) and dynamic updates
  - Use transition-group for list items with unique keys

### Sequelize Include Alias and Frontend Data Access Pattern

- **Problem**: Frontend components fail to display associated data (e.g., estimate items) even when the backend API call successfully fetches it, often due to mismatched keys.
- **Solution**: Ensure strict consistency between the `as` alias used in backend Sequelize `include` statements and the property key accessed in the frontend component after data normalization.

```javascript
// 1. Backend Model Association (e.g., models/Estimate.js)
Estimate.hasMany(models.EstimateItem, {
  foreignKey: 'estimate_id',
  as: 'items' // Define the alias here
});

// 2. Backend Controller/Service Query (e.g., services/estimateService.js)
const estimate = await Estimate.findByPk(estimateId, {
  include: [
    {
      model: db.EstimateItem,
      as: 'items' // MUST match the alias defined in the association
    },
    // ... other includes
  ]
});

// 3. Frontend Component Data Access (e.g., EstimateItemPhotos.vue)
// Assuming standardized service returns camelCase data
const estimateResponse = await estimatesService.getById(props.estimateId);

if (estimateResponse.success && estimateResponse.data && Array.isArray(estimateResponse.data.items)) {
  // Access using the camelCased version of the backend alias ('items')
  estimateItems.value = estimateResponse.data.items;
}
```

- **Key Aspects**:
  - The `as` alias defined in the Sequelize model association dictates the key name in the fetched data object.
  - The `include` statement in the backend query *must* use the exact same `as` alias.
  - Frontend components, after any case normalization (e.g., snake_case to camelCase by a service), must access the associated data using the corresponding (potentially normalized) key (e.g., `items` if the alias was `items`).
  - Mismatches (e.g., backend alias `items`, frontend access `estimateItems`) will lead to data not being displayed, even if fetched correctly.
  - Verify aliases in model definitions when debugging missing associated data issues.

### Service Method Empty Result Handling Pattern

- **Problem**: Service methods often don't handle empty result sets properly, causing errors when no data is found
- **Pattern**: Consistent empty result handling pattern with explicit returns and error handling
- **Solution**: Return null or empty arrays for expected empty results, with proper logging

```javascript
// Handle empty result for a single entity
async getCurrentActiveJob() {
  try {
    const activeJob = await Project.findOne({
      where: { type: 'active', status: 'in_progress' },
      include: [...], // Relations
      order: [['updated_at', 'DESC']]
    });

    // If no active job is found, return null without error
    if (!activeJob) {
      logger.info('No active job found');
      return null; // Explicit null return, not an error
    }

    return activeJob;
  } catch (error) {
    logger.error('Error getting current active job:', error);
    throw error; // Only throw for unexpected errors
  }
}

// Handle empty result for collections
async getUpcomingProjects(limit = 5) {
  try {
    const projects = await Project.findAll({
      where: { /* criteria */ },
      include: [...], // Relations
      limit
    });

    // Return empty array if no projects found, not an error
    if (!projects || projects.length === 0) {
      logger.info('No upcoming projects found');
      return [];
    }

    return projects;
  } catch (error) {
    logger.error('Error getting upcoming projects:', error);
    throw error; // Only throw for unexpected errors
  }
}
```

- **Key Aspects**:
  - Distinguish between expected empty results and unexpected errors
  - For single entities: return null for expected empty results
  - For collections: return empty array ([]) for expected empty results
  - Add appropriate logging for both empty results and errors
  - Use try/catch blocks to handle unexpected errors
  - Frontend components handle null and empty array returns properly

### Vue Component Data Initialization Pattern

- **Problem**: Vue components can throw "Cannot read properties of undefined (reading 'length')" errors when accessing properties of data that hasn't been loaded yet
- **Pattern**: Defensive data initialization with fallbacks and proper error handling
- **Solution**: Initialize reactive data with appropriate default values and add fallback handling in data processing

```javascript
// 1. Initialize reactive data with appropriate default values
const communities = ref([]); // Initialize as empty array, not undefined

// 2. Add fallback handling when setting data from API responses
const loadCommunities = async () => {
  try {
    const result = await communityService.getAllCommunities(filters);
    // Ensure communities is always an array, even if API returns null/undefined
    communities.value = result || [];
  } catch (err) {
    console.error('Failed to load communities:', err);
    error.value = 'Failed to load communities. Please try again.';
    // Reset to empty array on error to prevent undefined errors
    communities.value = [];
  }
};

// 3. Use optional chaining and nullish coalescing in computed properties
const filteredCommunities = computed(() => {
  return (communities.value || []).filter(c => {
    return c?.name?.toLowerCase().includes(searchQuery.value.toLowerCase());
  });
});

// 4. Defensive template rendering with v-if
<div v-if="communities && communities.length > 0" class="communities-grid">
  <!-- Render communities -->
</div>
<div v-else-if="!loading" class="empty-state">
  <p>No communities found.</p>
</div>
```

- **Key Aspects**:
  - Initialize reactive data with appropriate default values (empty arrays for collections, objects with default properties)
  - Add fallback handling when setting data from API responses using logical OR (`result || []` for arrays, `{...defaults, ...data}` for objects)
  - Reset collections to empty arrays or objects to default values on error to prevent undefined errors
  - Use optional chaining (`?.`) and nullish coalescing (`||`) in templates and computed properties
  - Implement defensive template rendering with proper v-if conditions
  - Check for both existence and length when rendering collections
  - Use two-step form reset and population to prevent stale data issues
  - Add validation in methods to check for required values before API calls
  - Enhance utility methods like formatDate() and formatPhone() with robust error handling

### Entity ID Dual Property Pattern

- **Problem**: Different components across the application may use different property names (`id` vs `clientId`) to reference the same entity ID, causing validation errors and data inconsistencies.
- **Solution**: Implement normalization functions that include both property names with the same value:

```javascript
// In utils/casing.js normalizeClient function
return {
  id: clientId,
  clientId: clientId, // Include both property names with the same value
  displayName: displayName,
  // ... other properties
};
```

- **Key Aspects**:
  - Maintain backward compatibility by supporting both property naming conventions
  - Ensure normalization functions include both `id` and `[entity]Id` properties
  - Use consistent property access patterns in validation functions
  - Document the dual property pattern in code comments for clarity
  - This approach supports the ongoing standardization effort while preventing errors during the transition

### Communities Module Pattern

- **Problem**: Mobile home communities need to manage newsletter advertisements with different sizes, costs, and term periods
- **Pattern**: Implement a hierarchical data structure with Communities containing multiple AdTypes and a selected active type
- **Solution**: Create models, services, and UI components that manage the relationship between communities and their advertisement types

```javascript
// 1. Community model with ad specialist contact info and selected ad type
Community.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  // Basic community info (address, city, etc.)
  // Ad specialist contact information
  ad_specialist_name: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'ad_specialist_name'
  },
  ad_specialist_email: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'ad_specialist_email'
  },
  ad_specialist_phone: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'ad_specialist_phone'
  },
  // Reference to the currently selected ad type
  selected_ad_type_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'ad_types',
      key: 'id'
    },
    field: 'selected_ad_type_id'
  },
  // Active status based on current advertising
  is_active: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: false,
    field: 'is_active'
  }
});

// 2. AdType model with dimensions, cost, and term periods
AdType.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  community_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'communities',
      key: 'id'
    },
    field: 'community_id'
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  width: {
    type: DataTypes.DECIMAL(5, 2),
    allowNull: true,
    defaultValue: 0
  },
  height: {
    type: DataTypes.DECIMAL(5, 2),
    allowNull: true,
    defaultValue: 0
  },
  cost: {
    type: DataTypes.DECIMAL(10, 1),
    allowNull: true,
    defaultValue: 0
  },
  // Contract dates and terms
  start_date: {
    type: DataTypes.DATE,
    allowNull: true,
    field: 'start_date'
  },
  end_date: {
    type: DataTypes.DATE,
    allowNull: true,
    field: 'end_date'
  },
  deadline_date: {
    type: DataTypes.DATE,
    allowNull: true,
    field: 'deadline_date'
  },
  term_months: {
    type: DataTypes.DECIMAL(3, 1),
    allowNull: true,
    field: 'term_months'
  }
});

// 3. Frontend service with case conversion
class CommunityService {
  async getAllCommunities(filters = {}) {
    try {
      const snakeCaseFilters = toSnakeCase(filters);
      const response = await apiClient.get('/communities', { params: snakeCaseFilters });
      return toCamelCase(response.data.data);
    } catch (error) {
      console.error('Error fetching communities:', error);
      throw error;
    }
  }

  // Other methods for CRUD operations...
}
```

- **Key Aspects**:
  - Communities have basic information plus ad specialist contact details
  - Each community can have multiple ad types with different dimensions and costs
  - The selected_ad_type_id field points to the currently active advertisement
  - Ad types track contract details like start date, end date, and deadline date
  - The UI provides separate sections for community info, ad specialist contacts, and ad types
  - Modal interfaces handle all CRUD operations with proper data validation
  - Standardized services ensure proper case conversion between frontend and backend
