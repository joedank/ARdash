import api from './api.service';

/**
 * User service for handling user-related operations
 */
class UserService {
  /**
   * Update user profile
   * @param {Object} userData - User profile data to update
   * @returns {Promise} - API response
   */
  async updateProfile(userData) {
    try {
      const response = await api.put('/users/profile', userData);
      return response;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Change user password
   * @param {Object} passwordData - Password change data
   * @returns {Promise} - API response
   */
  async changePassword(passwordData) {
    try {
      const response = await api.put('/users/password', passwordData);
      return response;
    } catch (error) {
      throw this.handleError(error);
    }
  }
  
  /**
   * Update user theme preference
   * @param {string} theme - Theme preference ('light', 'dark', or 'system')
   * @returns {Promise} - API response
   */
  async updateThemePreference(theme) {
    try {
      const response = await api.put('/users/preferences/theme', { theme_preference: theme });
      return response;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Handle API errors
   * @param {Error} error - Error object
   * @returns {Error} - Processed error
   */
  handleError(error) {
    // If the error is a response error, return the error message from the API
    if (error.response && error.response.data) {
      return {
        message: error.response.data.message || 'An error occurred',
        status: error.response.status,
        data: error.response.data
      };
    }
    
    // Otherwise, return a generic error
    return {
      message: error.message || 'An unexpected error occurred',
      status: 500
    };
  }
}

export default new UserService();
