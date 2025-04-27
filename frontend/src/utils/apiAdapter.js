/**
 * API Adapter for standardizing data between frontend and backend
 * 
 * This adapter handles conversion between snake_case (backend) and camelCase (frontend),
 * normalizes entity references, and ensures consistent field naming during the
 * standardization transition period.
 */

import { toCamelCase, toSnakeCase, isValidUuid } from './casing';

/**
 * Standardizes incoming API response data for frontend use
 * - Converts snake_case to camelCase
 * - Normalizes ID fields
 * - Handles data structure consistency
 * 
 * @param {Object|Array} data - API response data
 * @returns {Object|Array} - Standardized data for frontend use
 */
export const standardizeResponse = (data) => {
  // Handle null/undefined case
  if (!data) return data;
  
  // Convert snake_case to camelCase
  const camelCaseData = toCamelCase(data);
  
  // If it's an array, map through and standardize each item
  if (Array.isArray(camelCaseData)) {
    return camelCaseData.map(item => standardizeEntity(item));
  }
  
  // Otherwise standardize the single entity
  return standardizeEntity(camelCaseData);
};

/**
 * Standardizes outgoing request data for API consumption
 * - Converts camelCase to snake_case
 * - Ensures consistent ID field naming
 * - Removes frontend-only properties
 * 
 * @param {Object|Array} data - Frontend data to send to API
 * @returns {Object|Array} - Standardized data for API use
 */
export const standardizeRequest = (data) => {
  // Handle null/undefined case
  if (!data) return data;
  
  // If it's an array, map through and standardize each item
  if (Array.isArray(data)) {
    return data.map(item => prepareEntityForApi(item));
  }
  
  // Otherwise standardize the single entity
  return prepareEntityForApi(data);
};

/**
 * Standardizes an entity object for frontend use
 * Handles specific entity types (projects, clients, addresses, etc.)
 * 
 * @param {Object} entity - Entity to standardize
 * @returns {Object} - Standardized entity
 */
function standardizeEntity(entity) {
  if (!entity || typeof entity !== 'object') return entity;
  
  // Create a copy to avoid mutating the original
  const result = { ...entity };
  
  // Standardize client ID references
  if (result.clientId || result.client_id || result.clientFkId || result.client_fk_id) {
    result.clientId = result.clientId || result.client_id || result.clientFkId || result.client_fk_id;
    // Remove non-standard properties to avoid duplication
    delete result.client_id;
    delete result.clientFkId;
    delete result.client_fk_id;
  }
  
  // Standardize address ID references
  if (result.addressId || result.address_id || result.addressFkId || result.address_fk_id) {
    result.addressId = result.addressId || result.address_id || result.addressFkId || result.address_fk_id;
    // Remove non-standard properties to avoid duplication
    delete result.address_id;
    delete result.addressFkId;
    delete result.address_fk_id;
  }
  
  // Standardize estimate ID references
  if (result.estimateId || result.estimate_id || result.estimateFkId || result.estimate_fk_id) {
    result.estimateId = result.estimateId || result.estimate_id || result.estimateFkId || result.estimate_fk_id;
    // Remove non-standard properties to avoid duplication
    delete result.estimate_id;
    delete result.estimateFkId;
    delete result.estimate_fk_id;
  }
  
  // Standardize project ID references
  if (result.projectId || result.project_id || result.projectFkId || result.project_fk_id) {
    result.projectId = result.projectId || result.project_id || result.projectFkId || result.project_fk_id;
    // Remove non-standard properties to avoid duplication
    delete result.project_id;
    delete result.projectFkId;
    delete result.project_fk_id;
  }
  
  // Handle nested entities (recursively)
  if (result.client && typeof result.client === 'object') {
    result.client = standardizeEntity(result.client);
  }
  
  if (result.address && typeof result.address === 'object') {
    result.address = standardizeEntity(result.address);
  }
  
  if (result.estimate && typeof result.estimate === 'object') {
    result.estimate = standardizeEntity(result.estimate);
  }
  
  if (result.project && typeof result.project === 'object') {
    result.project = standardizeEntity(result.project);
  }
  
  // Handle arrays of nested entities
  if (result.addresses && Array.isArray(result.addresses)) {
    result.addresses = result.addresses.map(address => standardizeEntity(address));
  }
  
  if (result.inspections && Array.isArray(result.inspections)) {
    result.inspections = result.inspections.map(inspection => standardizeEntity(inspection));
  }
  
  if (result.photos && Array.isArray(result.photos)) {
    result.photos = result.photos.map(photo => standardizeEntity(photo));
  }
  
  // Standardize dates if needed (convert strings to Date objects)
  if (result.createdAt && typeof result.createdAt === 'string') {
    result.createdAt = new Date(result.createdAt);
  }
  
  if (result.updatedAt && typeof result.updatedAt === 'string') {
    result.updatedAt = new Date(result.updatedAt);
  }
  
  if (result.scheduledDate && typeof result.scheduledDate === 'string') {
    result.scheduledDate = new Date(result.scheduledDate);
  }
  
  return result;
}

/**
 * Prepares an entity for API request by standardizing field names
 * and converting to the expected backend format
 * 
 * @param {Object} entity - Entity to prepare for API
 * @returns {Object} - API-ready entity
 */
function prepareEntityForApi(entity) {
  if (!entity || typeof entity !== 'object') return entity;
  
  // Create a working copy
  let prepared = { ...entity };
  
  // Remove frontend-only properties
  const frontendOnlyProps = ['error', 'loading', 'touched', 'valid'];
  frontendOnlyProps.forEach(prop => {
    delete prepared[prop];
  });
  
  // Ensure client_id is consistently named for backward compatibility
  if (prepared.clientId && isValidUuid(prepared.clientId)) {
    prepared.client_id = prepared.clientId;
  }
  
  // Ensure address_id is consistently named for backward compatibility
  if (prepared.addressId && isValidUuid(prepared.addressId)) {
    prepared.address_id = prepared.addressId;
  }
  
  // Ensure estimate_id is consistently named for backward compatibility
  if (prepared.estimateId && isValidUuid(prepared.estimateId)) {
    prepared.estimate_id = prepared.estimateId;
  }
  
  // Ensure project_id is consistently named for backward compatibility
  if (prepared.projectId && isValidUuid(prepared.projectId)) {
    prepared.project_id = prepared.projectId;
  }
  
  // Convert camelCase to snake_case for API
  return toSnakeCase(prepared);
}

/**
 * Standardizes error responses from API for consistent frontend error handling
 * @param {Error|Object} error - Error object from API response
 * @returns {Object} - Standardized error response
 */
export const standardizeError = (error) => {
  // Default error structure
  const standardError = {
    success: false,
    message: 'An error occurred',
    data: null
  };
  
  // Check if the error has a response from axios
  if (error.response) {
    // The request was made and the server responded with an error status
    const { data, status } = error.response;
    
    // Handle API formatted errors
    if (data) {
      if (data.message) {
        standardError.message = data.message;
      }
      
      if (data.data) {
        standardError.data = toCamelCase(data.data);
      }
      
      // Include HTTP status code for debugging
      standardError.statusCode = status;
    }
  } else if (error.request) {
    // The request was made but no response was received
    standardError.message = 'No response from server';
    standardError.data = { request: error.request };
  } else if (error.message) {
    // Something happened in setting up the request
    standardError.message = error.message;
  }
  
  // Log the error for debugging (in development)
  if (process.env.NODE_ENV !== 'production') {
    console.error('API Error:', standardError);
  }
  
  return standardError;
};

export default {
  standardizeResponse,
  standardizeRequest,
  standardizeError
};
