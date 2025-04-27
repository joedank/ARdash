import api from './api.service';
import apiAdapter from '../utils/apiAdapter';
import { isValidUuid } from '../utils/casing';

/**
 * Service for managing estimate item additional work
 */
const estimateItemAdditionalWorkService = {
  /**
   * Get additional work for a specific estimate item
   * @param {string} estimateItemId - The UUID of the estimate item
   * @returns {Promise<Object>} - Standardized response
   */
  async getAdditionalWork(estimateItemId) {
    try {
      // Validate UUID
      if (!isValidUuid(estimateItemId)) {
        return { 
          success: false, 
          message: 'Invalid estimate item ID format' 
        };
      }

      // Make API request
      const response = await api.get(`/estimate-items/${estimateItemId}/additional-work`);
      return apiAdapter.standardizeResponse(response);
    } catch (error) {
      return apiAdapter.standardizeError(error);
    }
  },

  /**
   * Save additional work for a specific estimate item
   * @param {string} estimateItemId - The UUID of the estimate item
   * @param {string} description - The description of the additional work
   * @returns {Promise<Object>} - Standardized response
   */
  async saveAdditionalWork(estimateItemId, description) {
    try {
      // Validate UUID
      if (!isValidUuid(estimateItemId)) {
        return { 
          success: false, 
          message: 'Invalid estimate item ID format' 
        };
      }

      // Validate description
      if (!description || typeof description !== 'string' || description.trim() === '') {
        return {
          success: false,
          message: 'Description is required'
        };
      }

      // Make API request
      const response = await api.post(`/estimate-items/${estimateItemId}/additional-work`, {
        description
      });
      
      return apiAdapter.standardizeResponse(response);
    } catch (error) {
      return apiAdapter.standardizeError(error);
    }
  },

  /**
   * Delete additional work for a specific estimate item
   * @param {string} estimateItemId - The UUID of the estimate item
   * @returns {Promise<Object>} - Standardized response
   */
  async deleteAdditionalWork(estimateItemId) {
    try {
      // Validate UUID
      if (!isValidUuid(estimateItemId)) {
        return { 
          success: false, 
          message: 'Invalid estimate item ID format' 
        };
      }

      // Make API request
      const response = await api.delete(`/estimate-items/${estimateItemId}/additional-work`);
      return apiAdapter.standardizeResponse(response);
    } catch (error) {
      return apiAdapter.standardizeError(error);
    }
  },

  /**
   * Get all additional work for an entire estimate (organized by estimate item)
   * @param {string} estimateId - The UUID of the estimate
   * @returns {Promise<Object>} - Standardized response
   */
  async getAdditionalWorkByEstimate(estimateId) {
    try {
      // Validate UUID
      if (!isValidUuid(estimateId)) {
        return { 
          success: false, 
          message: 'Invalid estimate ID format' 
        };
      }

      // Make API request
      const response = await api.get(`/estimates/${estimateId}/additional-work`);
      return apiAdapter.standardizeResponse(response);
    } catch (error) {
      return apiAdapter.standardizeError(error);
    }
  }
};

export default estimateItemAdditionalWorkService;
