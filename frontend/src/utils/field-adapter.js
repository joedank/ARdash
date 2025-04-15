/**
 * Field adapter utilities for standardizing field names
 * between frontend (camelCase) and backend (snake_case)
 */

/**
 * Converts snake_case database fields to camelCase for frontend
 * @param {Object} dbObject - Database object with snake_case fields
 * @returns {Object} Frontend object with camelCase fields
 */
const toFrontend = (dbObject) => {
  if (!dbObject || typeof dbObject !== 'object') return dbObject;
  
  const result = {};
  
  Object.entries(dbObject).forEach(([key, value]) => {
    // Convert snake_case to camelCase
    const camelKey = key.replace(/_([a-z])/g, (match, p1) => p1.toUpperCase());
    
    // Handle nested objects and arrays
    if (value && typeof value === 'object') {
      if (Array.isArray(value)) {
        result[camelKey] = value.map(item => typeof item === 'object' ? toFrontend(item) : item);
      } else {
        result[camelKey] = toFrontend(value);
      }
    } else {
      result[camelKey] = value;
    }
  });
  
  return result;
};

/**
 * Converts camelCase frontend fields to snake_case for database
 * @param {Object} frontendObject - Frontend object with camelCase fields
 * @returns {Object} Database object with snake_case fields
 */
const toDatabase = (frontendObject) => {
  if (!frontendObject || typeof frontendObject !== 'object') return frontendObject;
  
  const result = {};
  
  Object.entries(frontendObject).forEach(([key, value]) => {
    // Convert camelCase to snake_case
    const snakeKey = key.replace(/[A-Z]/g, match => `_${match.toLowerCase()}`);
    
    // Handle nested objects and arrays
    if (value && typeof value === 'object') {
      if (Array.isArray(value)) {
        result[snakeKey] = value.map(item => typeof item === 'object' ? toDatabase(item) : item);
      } else {
        result[snakeKey] = toDatabase(value);
      }
    } else {
      result[snakeKey] = value;
    }
  });
  
  return result;
};

// Convert to ES Module exports for use in Vue components
export {
  toFrontend,
  toDatabase
};
