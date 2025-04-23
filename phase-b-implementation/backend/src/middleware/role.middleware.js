'use strict';

/**
 * Middleware to check if user has admin role
 */
exports.isAdmin = (req, res, next) => {
  // Check if user exists and has role information
  if (!req.user || !req.user.role) {
    return res.status(403).json({
      success: false,
      message: 'Access denied: User role not found'
    });
  }

  // Check if user has admin role
  if (req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Access denied: Admin privileges required'
    });
  }

  next();
};

/**
 * Middleware to check if user has estimator_manager or admin role
 */
exports.isEstimatorManagerOrAdmin = (req, res, next) => {
  // Check if user exists and has role information
  if (!req.user || !req.user.role) {
    return res.status(403).json({
      success: false,
      message: 'Access denied: User role not found'
    });
  }

  // Check if user has estimator_manager or admin role
  if (req.user.role !== 'estimator_manager' && req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Access denied: Estimator manager or admin privileges required'
    });
  }

  next();
};