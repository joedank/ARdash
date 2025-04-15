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

### Standardized Service Pattern

- **Problem**: Direct API calls with manual data conversion between frontend and backend lead to inconsistent field naming, error handling, and response formats.
- **Solution**: Implement standardized service classes that handle data conversion, error handling, and API communication:

```javascript
// 1. Base service class with standardized methods
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
      this._handleError(error);
    }
  }

  // Other CRUD methods...

  standardizeRequest(data) {
    return apiStandardizeRequest(data); // Use imported function
  }

  standardizeResponse(response) {
    // Standardize response format
    return {
      success: true,
      message: 'Operation successful',
      data: apiStandardizeResponse(response.data)
    };
  }
}

// 2. Entity-specific service implementation
class EstimateService extends BaseService {
  constructor() {
    super('/estimates');
  }

  // Entity-specific methods...
}

export default new EstimateService();
```

- **Key Aspects**:
  - Centralized data conversion between camelCase (frontend) and snake_case (backend)
  - Consistent error handling across all API calls
  - Standardized response format with success flag, message, and normalized data
  - Entity-specific services inherit from base service for consistent implementation
  - Reduced code duplication and improved maintainability
  - Proper handling of ID fields with support for both naming conventions
