/**
 * Custom API error class for standardized error handling
 */
class ApiError extends Error {
  /**
   * Create a new API error
   * @param {number} statusCode - HTTP status code
   * @param {string} message - Error message
   * @param {Object} data - Additional error data
   */
  constructor(statusCode, message, data = {}) {
    super(message);
    this.statusCode = statusCode;
    this.name = 'ApiError';
    
    // Store additional data
    Object.keys(data).forEach(key => {
      this[key] = data[key];
    });
    
    Error.captureStackTrace(this, this.constructor);
  }
}

module.exports = ApiError;
