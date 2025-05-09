/**
 * Middleware to validate that all request keys conform to snake_case
 * This ensures consistency at the API boundary.
 */

/**
 * Check if a string contains any uppercase letters
 * @param {string} key - Object key to check
 * @returns {boolean} - true if the key contains uppercase letters
 */
function containsUpperCase(key) {
  return /[A-Z]/.test(key);
}

/**
 * Recursively validate all keys in an object to ensure they use snake_case
 * @param {Object} obj - Object to validate
 * @returns {Array} - Array of invalid keys found
 */
function findInvalidKeys(obj) {
  if (!obj || typeof obj !== 'object' || Array.isArray(obj)) {
    return [];
  }

  let invalidKeys = [];
  
  // Check all direct keys on this object
  for (const key of Object.keys(obj)) {
    // Skip keys that start with _ as they might be special
    if (!key.startsWith('_') && containsUpperCase(key)) {
      invalidKeys.push(key);
    }
    
    // Recursively check nested objects
    if (obj[key] && typeof obj[key] === 'object' && !Array.isArray(obj[key])) {
      invalidKeys = [...invalidKeys, ...findInvalidKeys(obj[key])];
    }
  }
  
  return invalidKeys;
}

/**
 * Middleware function to validate all request keys use snake_case
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
function validateKeys(req, res, next) {
  // Only validate on routes that accept json payloads
  if (['POST', 'PUT', 'PATCH'].includes(req.method) && req.body && typeof req.body === 'object') {
    const invalidKeys = findInvalidKeys(req.body);
    
    if (invalidKeys.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Request keys must use snake_case',
        data: {
          invalidKeys
        }
      });
    }
  }
  
  next();
}

module.exports = validateKeys;
