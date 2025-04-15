'use strict';

/**
 * Base error class that extends Error
 * All custom error classes should extend this class
 */
class BaseError extends Error {
  constructor(message) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * Error for when a resource is not found
 * Used for 404 responses
 */
class NotFoundError extends BaseError {
  constructor(resource, id) {
    super(`${resource} with id ${id} not found`);
    this.statusCode = 404;
    this.resource = resource;
    this.resourceId = id;
  }
}

/**
 * Error for validation failures
 * Used for 400 responses
 */
class ValidationError extends BaseError {
  constructor(message, fields = {}) {
    super(message);
    this.statusCode = 400;
    this.fields = fields;
  }
}

/**
 * Error for UUID validation failures
 * Used for 400 responses
 */
class UUIDValidationError extends ValidationError {
  constructor(paramName) {
    super(`Invalid UUID format for parameter: ${paramName}`, { [paramName]: 'Invalid UUID format' });
    this.paramName = paramName;
  }
}

/**
 * Error for authentication failures
 * Used for 401 responses
 */
class AuthenticationError extends BaseError {
  constructor(message = 'Authentication required') {
    super(message);
    this.statusCode = 401;
  }
}

/**
 * Error for authorization failures
 * Used for 403 responses
 */
class AuthorizationError extends BaseError {
  constructor(message = 'Insufficient permissions') {
    super(message);
    this.statusCode = 403;
  }
}

/**
 * Error for business logic constraints
 * Used for 422 responses
 */
class BusinessLogicError extends BaseError {
  constructor(message) {
    super(message);
    this.statusCode = 422;
  }
}

/**
 * Error for database operations
 * Used for 500 responses
 */
class DatabaseError extends BaseError {
  constructor(message, originalError = null) {
    super(message);
    this.statusCode = 500;
    this.originalError = originalError;
  }
}

module.exports = {
  BaseError,
  NotFoundError,
  ValidationError,
  UUIDValidationError,
  AuthenticationError,
  AuthorizationError,
  BusinessLogicError,
  DatabaseError
};
