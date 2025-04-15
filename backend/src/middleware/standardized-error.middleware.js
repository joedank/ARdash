'use strict';

const logger = require('../utils/logger');
const {
  BaseError,
  NotFoundError,
  ValidationError,
  UUIDValidationError,
  AuthenticationError,
  AuthorizationError,
  BusinessLogicError,
  DatabaseError
} = require('../utils/errors');

/**
 * Standardized error handling middleware
 * Formats errors into a consistent response structure
 * 
 * @param {Error} err - The error object
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
const standardizedErrorMiddleware = (err, req, res, next) => {
  // Default to internal server error if statusCode is not set
  let statusCode = err.statusCode || 500;
  let message = err.message || 'An unexpected error occurred';
  let errorData = {};

  // Log the error with context
  logger.error(`Error: ${err.message}`, {
    url: req.originalUrl,
    method: req.method,
    ip: req.ip,
    errorName: err.name,
    statusCode,
    stack: err.stack
  });

  // Handle specific error types
  if (err instanceof ValidationError) {
    errorData.fields = err.fields;
  } else if (err instanceof UUIDValidationError) {
    errorData.param = err.paramName;
  } else if (err instanceof NotFoundError) {
    errorData.resource = err.resource;
    errorData.resourceId = err.resourceId;
  } else if (err instanceof DatabaseError && err.originalError) {
    // Include safe details from the original database error
    errorData.type = err.originalError.name;
    errorData.detail = err.originalError.message;
  }

  // Multer error handling for file uploads
  if (err.code === 'LIMIT_FILE_SIZE') {
    statusCode = 400;
    message = 'File size limit exceeded';
    errorData.maxSize = err.limit;
  }

  // Handle Sequelize errors
  if (err.name === 'SequelizeValidationError' || err.name === 'SequelizeUniqueConstraintError') {
    statusCode = 400;
    message = 'Validation error';
    errorData.fields = {};
    
    err.errors.forEach(error => {
      errorData.fields[error.path] = error.message;
    });
  }

  // Construct the standardized error response
  const response = {
    success: false,
    message: message
  };

  // Add error data if it exists
  if (Object.keys(errorData).length > 0) {
    response.data = errorData;
  }

  // Send the response
  res.status(statusCode).json(response);
};

// Export middleware and error classes
module.exports = {
  standardizedErrorMiddleware,
  BaseError,
  NotFoundError,
  ValidationError,
  UUIDValidationError,
  AuthenticationError,
  AuthorizationError,
  BusinessLogicError,
  DatabaseError
};
