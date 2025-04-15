/**
 * Middleware to validate UUID format in route parameters
 * 
 * This middleware can be used to validate that specific parameters
 * are valid UUIDs, avoiding database errors from malformed IDs.
 */

/**
 * Validates a parameter is a valid UUID
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 * @param {string} paramName - Name of parameter to validate (default: 'id')
 * @returns {Object|void} Error response or calls next()
 */
const validateUuid = (req, res, next, paramName = 'id') => {
  const id = req.params[paramName];
  
  // Check if ID is present
  if (!id || id === 'undefined' || id === 'null') {
    return res.status(400).json({
      success: false,
      message: `Invalid ${paramName} provided: missing or null value`
    });
  }

  // UUID validation regex
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  if (!uuidRegex.test(id)) {
    return res.status(400).json({
      success: false,
      message: `Invalid UUID format for ${paramName}: ${id}`
    });
  }
  
  next();
};

module.exports = validateUuid;
