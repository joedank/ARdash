const logger = require('../utils/logger');

/**
 * Error handling middleware
 */
function errorMiddleware(err, req, res, next) {
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';
  
  logger.error(`${statusCode} - ${message} - ${req.originalUrl} - ${req.method} - ${req.ip}`);
  
  // Send error response
  res.status(statusCode).json({
    status: 'error',
    statusCode,
    message
  });
}

module.exports = errorMiddleware;
