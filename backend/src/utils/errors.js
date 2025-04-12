/**
 * Custom error class for validation errors
 */
class ValidationError extends Error {
  constructor(message, field = null) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
    this.statusCode = 400; // HTTP status code for validation errors
  }
}

/**
 * Custom error class for not found errors
 */
class NotFoundError extends Error {
  constructor(message) {
    super(message);
    this.name = 'NotFoundError';
    this.statusCode = 404;
  }
}

module.exports = {
  ValidationError,
  NotFoundError
};