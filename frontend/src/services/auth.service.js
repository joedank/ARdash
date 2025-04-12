import api from './api.service';

/**
 * Authentication service for handling user authentication operations
 */
class AuthService {
  /**
   * Register a new user
   * @param {Object} userData - User registration data
   * @returns {Promise} - API response
   */
  async register(userData) {
    try {
      const response = await api.post('/auth/register', userData);
      if (response.success) {
        this.setToken(response.data.token);
      }
      return response;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Login a user
   * @param {Object} credentials - User login credentials
   * @returns {Promise} - API response
   */
  async login(credentials) {
    try {
      const response = await api.post('/auth/login', credentials);
      if (response.success) {
        this.setToken(response.data.token);
      }
      return response;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Logout the current user
   * @returns {Promise} - API response
   */
  async logout() {
    try {
      const response = await api.post('/auth/logout');
      this.clearToken();
      return response;
    } catch (error) {
      this.clearToken();
      throw this.handleError(error);
    }
  }

  /**
   * Get the current user's profile
   * @returns {Promise} - API response
   */
  async getProfile() {
    try {
      const response = await api.get('/auth/me');
      return response;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Refresh the access token
   * @returns {Promise} - API response
   */
  async refreshToken() {
    try {
      const response = await api.post('/auth/refresh-token');
      if (response.success) {
        this.setToken(response.data.token);
      }
      return response.data;
    } catch (error) {
      this.clearToken();
      throw this.handleError(error);
    }
  }

  /**
   * Check if user is authenticated
   * @returns {Boolean} - Authentication status
   */
  isAuthenticated() {
    return !!this.getToken();
  }

  /**
   * Set authentication token in localStorage
   * @param {String} token - JWT token
   */
  setToken(token) {
    localStorage.setItem('token', token);
    // Set the Authorization header for all future API requests
    api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  }

  /**
   * Get authentication token from localStorage
   * @returns {String|null} - JWT token or null
   */
  getToken() {
    return localStorage.getItem('token');
  }

  /**
   * Clear authentication token from localStorage
   */
  clearToken() {
    localStorage.removeItem('token');
    // Remove the Authorization header
    delete api.defaults.headers.common['Authorization'];
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

export default new AuthService();
