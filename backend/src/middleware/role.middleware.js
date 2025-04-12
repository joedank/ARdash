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