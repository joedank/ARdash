/**
 * Middleware to validate UUID format in route parameters
 * 
 * This middleware checks if the specified parameter is a valid UUID,
 * returning a 400 Bad Request error if not, preventing database errors.
 */

/**
 * Validates that a string is a valid UUID
 * @param {string} str - String to validate
 * @returns {boolean} - True if string is a valid UUID
 */
const isValidUuid = (str) => {
  if (!str || str === 'undefined' || str === 'null') return false;
  
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  return uuidRegex.test(str);
};

/**
 * Middleware to validate a UUID parameter
 * @param {string} paramName - Name of parameter to validate (default: 'id')
 * @returns {Function} - Express middleware function
 */
const validateUuid = (paramName = 'id') => (req, res, next) => {
  const paramValue = req.params[paramName];
  
  if (!isValidUuid(paramValue)) {
    return res.status(400).json({
      success: false,
      message: `Invalid UUID format for parameter '${paramName}'`
    });
  }
  
  next();
};

/**
 * Middleware to validate multiple UUID parameters
 * @param {Array<string>} paramNames - Names of parameters to validate
 * @returns {Function} - Express middleware function
 */
const validateMultipleUuids = (paramNames) => (req, res, next) => {
  for (const paramName of paramNames) {
    const paramValue = req.params[paramName];
    
    if (!isValidUuid(paramValue)) {
      return res.status(400).json({
        success: false,
        message: `Invalid UUID format for parameter '${paramName}'`
      });
    }
  }
  
  next();
};

module.exports = {
  isValidUuid,
  validateUuid,
  validateMultipleUuids
};
