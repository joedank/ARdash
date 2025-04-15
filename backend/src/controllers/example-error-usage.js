/**
 * Example Controller Demonstrating Error Usage
 * This file shows how to use the standardized error classes in controllers
 */

// Import error classes from utils/errors.js
const { 
  ValidationError, 
  NotFoundError,
  AuthenticationError,
  AuthorizationError,
  UUIDValidationError,
  BusinessLogicError
} = require('../utils/errors');

/**
 * Example controller method showing various error scenarios
 */
async function exampleController(req, res, next) {
  try {
    const { id } = req.params;
    
    // Example: UUID validation
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    if (id && !uuidRegex.test(id)) {
      throw new UUIDValidationError(`Invalid UUID format for id: ${id}`);
    }
    
    // Example: Validation error
    const { name, email } = req.body;
    if (!name) {
      throw new ValidationError('Name is required', 'name', name);
    }
    
    if (!email || !email.includes('@')) {
      throw new ValidationError('Valid email is required', 'email', email);
    }
    
    // Example: Not found error
    const item = await SomeModel.findByPk(id);
    if (!item) {
      throw new NotFoundError(`Item with id ${id} not found`);
    }
    
    // Example: Authentication error
    if (!req.user) {
      throw new AuthenticationError('You must be logged in to access this resource');
    }
    
    // Example: Authorization error
    if (item.userId !== req.user.id && !req.user.isAdmin) {
      throw new AuthorizationError('You do not have permission to modify this resource');
    }
    
    // Example: Business logic error
    if (item.status === 'completed') {
      throw new BusinessLogicError('Cannot modify a completed item');
    }
    
    // Success response uses standardized format
    return res.status(200).json({
      success: true,
      message: 'Operation successful',
      data: item
    });
    
  } catch (error) {
    // Pass any errors to the standardized error middleware
    next(error);
  }
}

module.exports = {
  exampleController
};