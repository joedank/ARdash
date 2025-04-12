const { verifyToken } = require('../utils/jwt');
// Import the db object which contains all initialized models
const db = require('../models');
const { User } = db; // Destructure the User model from db
const logger = require('../utils/logger');

/**
 * Middleware to authenticate requests using JWT
 * Verifies the token from Authorization header or cookies
 * Attaches the user to the request object if authenticated
 */
const authenticate = async (req, res, next) => {
  try {
    // Get token from Authorization header or cookies
    let token;
    
    // Check Authorization header
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      token = authHeader.split(' ')[1];
    } 
    // Check cookies
    else if (req.cookies && req.cookies.token) {
      token = req.cookies.token;
    }

    // If no token found, return unauthorized
    if (!token) {
      return res.status(401).json({ 
        success: false, 
        message: 'Authentication required. Please log in.' 
      });
    }

    // Verify token
    const decoded = verifyToken(token);
    
    // Find user by id from decoded token
    const user = await User.findByPk(decoded.id);
    
    // If user not found or inactive, return unauthorized
    if (!user || !user.isActive) {
      return res.status(401).json({ 
        success: false, 
        message: 'User not found or inactive.' 
      });
    }

    // Attach user to request object
    req.user = user;
    
    // Proceed to next middleware or route handler
    next();
  } catch (error) {
    logger.error('Authentication error:', error);
    return res.status(401).json({ 
      success: false, 
      message: 'Invalid or expired token. Please log in again.' 
    });
  }
};

/**
 * Middleware to check if user has the required role(s)
 * Must be used after authenticate middleware
 */
const authorize = (roles = []) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required. Please log in.'
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Insufficient privileges.'
      });
    }

    next();
  };
};

module.exports = {
  authenticate,
  authorize
};
