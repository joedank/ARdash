# Component Creation Guidelines

This document provides comprehensive guidelines for creating new components in the ARdash application. Following these guidelines will ensure consistency, reduce errors, and improve maintainability.

## Table of Contents
1. [Component Structure](#component-structure)
2. [Data Handling](#data-handling)
3. [API Communication](#api-communication)
4. [Error Handling](#error-handling)
5. [Field Naming Conventions](#field-naming-conventions)
6. [Validation](#validation)
7. [Styling](#styling)
8. [Testing](#testing)
9. [Common Pitfalls](#common-pitfalls)
10. [Checklist](#checklist)

## Component Structure

### Basic Component Template
```vue
<template>
  <div class="component-container">
    <!-- Component content -->
    <LoadingSpinner v-if="isLoading" />
    <ErrorAlert v-if="formError" :message="formError" />
    
    <!-- Main content (only shown when not loading and no errors) -->
    <div v-if="!isLoading && !formError">
      <!-- Component-specific content -->
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import LoadingSpinner from '@/components/common/LoadingSpinner.vue';
import ErrorAlert from '@/components/common/ErrorAlert.vue';
import { standardizedEntityService } from '@/services/standardized-entity.service';

export default {
  name: 'EntityComponent',
  components: {
    LoadingSpinner,
    ErrorAlert,
    // Other components...
  },
  props: {
    // Define props with validation
    entityId: {
      type: String,
      required: false,
      default: null
    }
  },
  setup(props) {
    // State variables
    const router = useRouter();
    const route = useRoute();
    const entity = ref({});
    const isLoading = ref(false);
    const formError = ref('');
    const errors = ref({});
    const isSubmitting = ref(false);
    
    // Computed properties
    const isEditing = computed(() => !!props.entityId);
    const pageTitle = computed(() => isEditing.value ? 'Edit Entity' : 'Create Entity');
    
    // Methods
    const loadEntity = async () => {
      if (!props.entityId) return;
      
      try {
        isLoading.value = true;
        formError.value = '';
        
        const response = await standardizedEntityService.getById(props.entityId);
        
        if (response.success) {
          entity.value = response.data;
        } else {
          formError.value = response.message || 'Failed to load entity';
        }
      } catch (error) {
        console.error('Error loading entity:', error);
        formError.value = 'An error occurred while loading the entity';
      } finally {
        isLoading.value = false;
      }
    };
    
    const validateForm = () => {
      let isValid = true;
      errors.value = {}; // Reset errors
      
      // Required fields validation
      if (!entity.value.name) {
        errors.value.name = 'Name is required';
        isValid = false;
      }
      
      // Other validations...
      
      return isValid;
    };
    
    const saveEntity = async () => {
      if (!validateForm()) return;
      
      try {
        isSubmitting.value = true;
        formError.value = '';
        
        const response = isEditing.value
          ? await standardizedEntityService.update(props.entityId, entity.value)
          : await standardizedEntityService.create(entity.value);
        
        if (response.success) {
          // Navigate or show success message
          router.push('/entities');
        } else {
          formError.value = response.message || 'Failed to save entity';
        }
      } catch (error) {
        console.error('Error saving entity:', error);
        formError.value = 'An error occurred while saving the entity';
      } finally {
        isSubmitting.value = false;
      }
    };
    
    // Lifecycle hooks
    onMounted(() => {
      loadEntity();
    });
    
    return {
      entity,
      isLoading,
      formError,
      errors,
      isSubmitting,
      isEditing,
      pageTitle,
      saveEntity
    };
  }
};
</script>

<style scoped>
.component-container {
  padding: 1rem;
}
/* Additional component-specific styles */
</style>
```

### Component Organization
- **Single Responsibility**: Each component should have a single responsibility
- **Modular Design**: Break complex components into smaller, reusable components
- **Logical Grouping**: Group related components in the same directory
- **Consistent Naming**: Use PascalCase for component names (e.g., `ClientSelector.vue`)

## Data Handling

### State Management
- Use `ref` and `reactive` for component-level state
- Use computed properties for derived state
- Initialize all reactive variables with appropriate default values
- Use `provide`/`inject` for sharing state between related components

### Props
- Define props with validation (type, required, default)
- Use camelCase for prop names
- Document props with comments
- Avoid mutating props directly

### Emits
- Define all emitted events in the `emits` option
- Use kebab-case for event names (e.g., `client-selected`)
- Document the payload structure for each event

## API Communication

### Standardized Services
- **Always use standardized services** for API communication:
  ```javascript
  // CORRECT: Use standardized service
  import { standardizedEntityService } from '@/services/standardized-entity.service';
  const response = await standardizedEntityService.create(entityData);
  
  // AVOID: Direct manual conversion
  const snakeCaseData = toSnakeCase(entityData);
  const response = await apiService.post('/entities', snakeCaseData);
  ```

### Creating New Services
- Create a new standardized service for each entity type:
  ```javascript
  // standardized-entity.service.js
  import BaseService from './base.service';
  
  class StandardizedEntityService extends BaseService {
    constructor() {
      super('/entities'); // API endpoint
    }
    
    // Add entity-specific methods here
  }
  
  export default new StandardizedEntityService();
  ```

### Request/Response Handling
- Handle loading states with a `isLoading` ref
- Always use try/catch blocks for API calls
- Set appropriate error messages on failure
- Use the standardized response format: `{ success, message, data }`

## Error Handling

### Form Errors
- Use a `formError` ref for general form errors
- Use an `errors` object for field-specific validation errors
- Display error messages prominently in the UI
- Clear errors when retrying operations

### API Errors
- Log detailed errors to the console for debugging
- Display user-friendly error messages in the UI
- Handle different error types appropriately (validation, server, network)
- Provide clear next steps for users when errors occur

## Field Naming Conventions

### Frontend (Vue.js)
- Use `camelCase` for all properties and variables
  ```javascript
  const newItem = {
    clientId: client.id,
    dateCreated: new Date().toISOString().split('T')[0]
  };
  ```

### Backend (Node.js/Express)
- Use `snake_case` for all database fields and API parameters
  ```javascript
  // This conversion is handled by the standardized service
  const dbRecord = {
    client_id: clientId,
    date_created: dateCreated
  };
  ```

### ID Fields
- Always use the pattern `entityId` in frontend code (e.g., `clientId`, `projectId`, `addressId`)
- When accessing entity references, check for both ID formats:
  ```javascript
  const id = entity.id || entity.entityId;
  ```

## Validation

### Form Validation
- Create a dedicated `validateForm` method that returns a boolean
- Reset errors at the start of validation
- Check all required fields and add specific error messages
- Validate field formats (email, phone, etc.) as needed
- Prevent form submission if validation fails

### Example Validation Pattern
```javascript
const validateForm = () => {
  let isValid = true;
  errors.value = {}; // Reset errors
  
  // Required fields
  if (!entity.value.name) {
    errors.value.name = 'Name is required';
    isValid = false;
  }
  
  // Email validation
  if (entity.value.email && !isValidEmail(entity.value.email)) {
    errors.value.email = 'Invalid email format';
    isValid = false;
  }
  
  return isValid;
};
```

## Styling

### CSS Organization
- Use scoped styles to prevent leakage
- Follow the project's CSS naming conventions
- Use utility classes for common styling needs
- Create component-specific styles for unique requirements

### Responsive Design
- Design for mobile-first, then enhance for larger screens
- Use responsive utility classes or media queries
- Test components at different viewport sizes

## Testing

### Manual Testing
- Test the component with various input combinations
- Verify all validation rules work as expected
- Test error handling by simulating API failures
- Check responsive behavior at different screen sizes

### Automated Testing
- Write unit tests for complex logic
- Test both success and failure paths
- Mock API calls to test different scenarios
- Verify that events are emitted correctly

## Common Pitfalls

### Field Naming Inconsistencies
- **Problem**: Using `id` in some places and `entityId` in others
- **Solution**: Use the dual property pattern in normalization functions:
  ```javascript
  return {
    id: entityId,
    entityId: entityId, // Include both properties with the same value
    // other properties...
  };
  ```

### Manual Data Conversion
- **Problem**: Manually converting between camelCase and snake_case
- **Solution**: Use standardized services that handle conversion automatically

### Missing Error Handling
- **Problem**: Not handling API errors properly
- **Solution**: Always use try/catch blocks and display appropriate error messages

### Incomplete Validation
- **Problem**: Not validating all required fields
- **Solution**: Create a comprehensive validation function that checks all fields

### Not Following Project Patterns
- **Problem**: Creating components that don't match the project's patterns
- **Solution**: Study existing components and follow the same patterns

## Checklist

Use this checklist when creating a new component:

### Setup
- [ ] Created component file with proper naming (PascalCase)
- [ ] Imported all necessary dependencies
- [ ] Defined props with validation
- [ ] Initialized all reactive variables
- [ ] Added appropriate computed properties

### API Communication
- [ ] Using standardized service for API calls
- [ ] Handling loading states properly
- [ ] Using try/catch blocks for error handling
- [ ] Displaying appropriate error messages

### Validation
- [ ] Created validateForm method
- [ ] Checking all required fields
- [ ] Adding specific error messages for each field
- [ ] Preventing form submission if validation fails

### UI
- [ ] Displaying loading indicator during API calls
- [ ] Showing error messages prominently
- [ ] Using consistent styling with the rest of the application
- [ ] Implementing responsive design

### Testing
- [ ] Tested component with various input combinations
- [ ] Verified all validation rules work as expected
- [ ] Tested error handling by simulating API failures
- [ ] Checked responsive behavior at different screen sizes

By following these guidelines, you'll create components that are consistent, maintainable, and free from common errors.
