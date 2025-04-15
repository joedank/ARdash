/**
 * Utilities for generating standardized response formats
 * This ensures consistent response structures across all API endpoints
 */

/**
 * Creates a standardized success response
 * @param {Object} data - Response data
 * @param {string} message - Success message
 * @returns {Object} Standardized response object
 */
const success = (data = null, message = 'Operation successful') => ({
  success: true,
  message,
  data
});

/**
 * Creates a standardized error response
 * @param {string} message - Error message
 * @param {Object} data - Additional error data
 * @returns {Object} Standardized error response object
 */
const error = (message = 'Operation failed', data = null) => ({
  success: false,
  message,
  data
});

module.exports = {
  success,
  error
};
