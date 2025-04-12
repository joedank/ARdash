const { User } = require('../models'); // Import initialized model from index.js
const logger = require('../utils/logger');
const bcrypt = require('bcrypt');

/**
 * User controller
 */
class UserController {
  /**
   * Get all users
   */
  async getAllUsers(req, res, next) {
    try {
      const users = await User.findAll({
        attributes: { exclude: ['password'] } // Exclude password from response
      });
      
      res.status(200).json({
        status: 'success',
        results: users.length,
        data: {
          users
        }
      });
    } catch (error) {
      logger.error('Error getting users:', error);
      next(error);
    }
  }
  
  /**
   * Get user by ID
   */
  async getUserById(req, res, next) {
    try {
      const user = await User.findByPk(req.params.id, {
        attributes: { exclude: ['password'] } // Exclude password from response
      });
      
      if (!user) {
        return res.status(404).json({
          status: 'error',
          message: 'User not found'
        });
      }
      
      res.status(200).json({
        status: 'success',
        data: {
          user
        }
      });
    } catch (error) {
      logger.error('Error getting user:', error);
      next(error);
    }
  }
  
  /**
   * Create new user
   */
  async createUser(req, res, next) {
    try {
      const newUser = await User.create(req.body);
      
      // Remove password from response
      const userResponse = newUser.toJSON();
      delete userResponse.password;
      
      res.status(201).json({
        status: 'success',
        data: {
          user: userResponse
        }
      });
    } catch (error) {
      logger.error('Error creating user:', error);
      next(error);
    }
  }

  /**
   * Update user profile
   * @route PUT /api/users/profile
   */
  async updateProfile(req, res, next) {
    try {
      const userId = req.user.id;
      // Destructure all expected fields, including avatar
      const { firstName, lastName, email, avatar, emailNotifications, marketingEmails } = req.body;
      
      // Find the user
      const user = await User.findByPk(userId);
      
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }
      
      // Check if email is being changed and if it's already in use
      if (email && email !== user.email) {
        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
          return res.status(409).json({
            success: false,
            message: 'Email is already in use'
          });
        }
      }
      
      // Update user
      user.firstName = firstName !== undefined ? firstName : user.firstName;
      user.lastName = lastName !== undefined ? lastName : user.lastName;
      user.email = email !== undefined ? email : user.email;
      user.avatar = avatar !== undefined ? avatar : user.avatar; // Update avatar if provided
      // Store additional preferences if needed
      // Could be added to the user model or stored in a separate preferences table
      
      await user.save();
      
      // Return updated user data
      const userData = user.toJSON();
      delete userData.password;
      
      res.status(200).json({
        success: true,
        message: 'Profile updated successfully',
        data: {
          user: userData
        }
      });
    } catch (error) {
      logger.error('Error updating profile:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update profile',
        error: error.message
      });
    }
  }
  
  /**
   * Change user password
   * @route PUT /api/users/password
   */
  async changePassword(req, res, next) {
    try {
      const userId = req.user.id;
      const { currentPassword, newPassword } = req.body;
      
      // Validate input
      if (!currentPassword || !newPassword) {
        return res.status(400).json({
          success: false,
          message: 'Current password and new password are required'
        });
      }
      
      // Find the user
      const user = await User.findByPk(userId);
      
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }
      
      // Verify current password
      const isPasswordValid = await user.checkPassword(currentPassword);
      if (!isPasswordValid) {
        return res.status(401).json({
          success: false,
          message: 'Current password is incorrect'
        });
      }
      
      // Update password (will be hashed by the beforeUpdate hook)
      user.password = newPassword;
      await user.save();
      
      res.status(200).json({
        success: true,
        message: 'Password updated successfully'
      });
    } catch (error) {
      logger.error('Error changing password:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to change password',
        error: error.message
      });
    }
  }
  
  /**
   * Update user theme preference
   * @route PUT /api/users/preferences/theme
   */
  async updateThemePreference(req, res, next) {
    try {
      const userId = req.user.id;
      const { theme_preference } = req.body;
      
      // Validate input
      if (!theme_preference) {
        return res.status(400).json({
          success: false,
          message: 'Theme preference is required'
        });
      }
      
      // Validate theme value
      const validThemes = ['light', 'dark', 'system'];
      if (!validThemes.includes(theme_preference)) {
        return res.status(400).json({
          success: false,
          message: `Invalid theme preference. Must be one of: ${validThemes.join(', ')}`
        });
      }
      
      // Find the user
      const user = await User.findByPk(userId);
      
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }
      
      // Update theme preference
      user.theme_preference = theme_preference;
      await user.save();
      
      res.status(200).json({
        success: true,
        message: 'Theme preference updated successfully',
        data: {
          theme_preference: user.theme_preference
        }
      });
    } catch (error) {
      logger.error('Error updating theme preference:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update theme preference',
        error: error.message
      });
    }
  }
}

module.exports = new UserController();
