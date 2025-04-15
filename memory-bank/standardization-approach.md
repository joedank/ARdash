# Standardization Approach

This document outlines our standardized approach to development in the ARdash application, focusing on consistent patterns, naming conventions, and best practices.

## Core Principles

1. **Consistency**: Use consistent patterns and naming conventions throughout the codebase
2. **Robustness**: Implement proper error handling and fallback mechanisms
3. **Maintainability**: Write clean, well-documented code that's easy to understand and modify
4. **Compatibility**: Support both old and new patterns during the transition period

## Standardized Service Pattern

### Overview

The Standardized Service Pattern provides a consistent approach to API communication between the frontend and backend. It handles data conversion, error handling, and response formatting.

### Implementation

1. **Base Service Class**: All entity services extend the BaseService class
   ```javascript
   // base.service.js
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
   ```

2. **Entity-Specific Services**: Create a standardized service for each entity
   ```javascript
   // standardized-estimates.service.js
   import BaseService from './base.service';
   
   class EstimateService extends BaseService {
     constructor() {
       super('/estimates');
     }
     
     // Entity-specific methods...
   }
   
   export default new EstimateService();
   ```

3. **Usage in Components**: Use standardized services in components
   ```javascript
   import { standardizedEstimatesService } from '@/services/standardized-estimates.service';
   
   const saveEstimate = async () => {
     try {
       const response = await standardizedEstimatesService.create(estimateData);
       if (response.success) {
         // Handle success
       } else {
         // Handle error
       }
     } catch (error) {
       console.error('Error saving estimate:', error);
     }
   };
   ```

## Entity ID Dual Property Pattern

### Overview

The Entity ID Dual Property Pattern ensures compatibility between components that use different property names for the same entity ID.

### Implementation

1. **Normalization Functions**: Include both `id` and `entityId` properties with the same value
   ```javascript
   // casing.js
   const normalizeClient = (client) => {
     const clientId = client.id || client.clientId;
     const displayName = client.displayName || client.display_name;
     
     return {
       id: clientId,
       clientId: clientId, // Include both properties with the same value
       displayName: displayName,
       // other properties...
     };
   };
   ```

2. **Access Pattern**: Check for both properties when accessing entity IDs
   ```javascript
   const id = entity.id || entity.entityId;
   ```

## Data Conversion Pattern

### Overview

The Data Conversion Pattern ensures consistent conversion between camelCase (frontend) and snake_case (backend).

### Implementation

1. **API Adapter**: Use the apiAdapter utility for data conversion
   ```javascript
   // apiAdapter.js
   export const standardizeRequest = (data) => {
     return toSnakeCase(data);
   };
   
   export const standardizeResponse = (data) => {
     return toCamelCase(data);
   };
   ```

2. **Field Adapter**: Use the fieldAdapter utility for PDF generation
   ```javascript
   // field-adapter.js
   const toFrontend = (data) => {
     return toCamelCase(data);
   };
   
   const toBackend = (data) => {
     return toSnakeCase(data);
   };
   ```

## Error Handling Pattern

### Overview

The Error Handling Pattern ensures consistent error handling and response formatting throughout the application.

### Implementation

1. **Standardized Error Response**: Use a consistent error response format
   ```javascript
   {
     success: false,
     message: 'Error message',
     data: null // or error details
   }
   ```

2. **Try/Catch Blocks**: Always use try/catch blocks for API calls
   ```javascript
   try {
     const response = await standardizedService.create(data);
     // Handle success
   } catch (error) {
     console.error('Error:', error);
     // Handle error
   }
   ```

3. **Detailed Logging**: Add detailed logging for debugging
   ```javascript
   logger.error(`Error creating entity: ${error.message}`, {
     entityData: data,
     error: error.stack
   });
   ```

4. **Fallback Mechanisms**: Implement fallbacks for potentially undefined values
   ```javascript
   const estimateNumber = estimate.estimateNumber || estimate.estimate_number || `EST-${Date.now()}`;
   ```

## Form Validation Pattern

### Overview

The Form Validation Pattern ensures consistent form validation throughout the application.

### Implementation

1. **Validation Function**: Create a dedicated validation function
   ```javascript
   const validateForm = () => {
     let isValid = true;
     errors.value = {}; // Reset errors
     
     // Required fields
     if (!entity.value.name) {
       errors.value.name = 'Name is required';
       isValid = false;
     }
     
     return isValid;
   };
   ```

2. **Error Display**: Display field-specific error messages
   ```html
   <input
     v-model="entity.name"
     :state="errors.name ? 'error' : ''"
     :helper-text="errors.name"
   />
   ```

3. **Form Submission**: Prevent form submission if validation fails
   ```javascript
   const saveEntity = async () => {
     if (!validateForm()) return;
     
     // Proceed with saving
   };
   ```

## PDF Generation Pattern

### Overview

The PDF Generation Pattern ensures robust PDF generation with proper error handling and fallbacks.

### Implementation

1. **Error Handling**: Add robust error handling
   ```javascript
   try {
     const pdfPath = await pdfService.generatePdf({
       type: 'estimate',
       data: estimateData,
       // other parameters...
     });
     return pdfPath;
   } catch (error) {
     logger.error(`Error generating PDF: ${error.message}`, {
       error: error.stack
     });
     throw error; // Re-throw for higher-level handling
   }
   ```

2. **Fallback Mechanisms**: Implement fallbacks for potentially undefined values
   ```javascript
   const estimateNumber = estimate.estimateNumber || estimate.estimate_number || `EST-${Date.now()}`;
   const filename = `estimate_${estimateNumber.replace(/[^a-zA-Z0-9]/g, '_')}.pdf`;
   ```

3. **Directory Handling**: Add proper directory creation with error handling
   ```javascript
   try {
     await fs.mkdir(uploadsDir, { recursive: true });
     logger.info(`Ensured uploads directory exists at: ${uploadsDir}`);
   } catch (dirError) {
     logger.error(`Error creating uploads directory: ${uploadsDir}`, dirError);
     throw new Error(`Failed to create uploads directory: ${dirError.message}`);
   }
   ```

## Conclusion

By following these standardized patterns, we ensure consistency, robustness, and maintainability throughout the ARdash application. These patterns should be applied to all new components and gradually retrofitted to existing components as they are modified.
