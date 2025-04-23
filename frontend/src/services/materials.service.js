/**
 * Materials Service
 */
import apiService from './api.service';
import { toCamelCase, toSnakeCase } from '../utils/casing';

/**
 * Materials Service
 */
class MaterialsService {
  /**
   * Get all materials
   * @param {Object} filters - Optional filters
   * @returns {Promise<Object>} Response with materials data
   */
  async getAll(filters = {}) {
    try {
      const snakeCaseFilters = toSnakeCase(filters);
      
      const response = await apiService.get('/materials', {
        params: snakeCaseFilters
      });
      
      if (response.success && response.data) {
        return {
          success: true,
          data: Array.isArray(response.data) 
            ? response.data.map(item => toCamelCase(item))
            : toCamelCase(response.data)
        };
      }
      
      return response;
    } catch (error) {
      console.error('Error getting materials:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to get materials',
        error
      };
    }
  }
  
  /**
   * Get material by ID
   * @param {string} id - Material UUID
   * @returns {Promise<Object>} Response with material data
   */
  async getById(id) {
    try {
      const response = await apiService.get(`/materials/${id}`);
      
      if (response.success && response.data) {
        return {
          success: true,
          data: toCamelCase(response.data)
        };
      }
      
      return response;
    } catch (error) {
      console.error(`Error getting material ${id}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to get material',
        error
      };
    }
  }
  
  /**
   * Search for materials
   * @param {string} query - Search query
   * @returns {Promise<Object>} Response with search results
   */
  async search(query) {
    try {
      const response = await apiService.get('/materials/search', {
        params: { q: query }
      });
      
      if (response.success && response.data) {
        return {
          success: true,
          data: Array.isArray(response.data)
            ? response.data.map(item => toCamelCase(item))
            : toCamelCase(response.data)
        };
      }
      
      return response;
    } catch (error) {
      console.error(`Error searching materials for "${query}":`, error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to search materials',
        error
      };
    }
  }

  /**
   * Get materials for a work type
   * @param {string} workTypeId - Work type UUID
   * @returns {Promise<Object>} Response with work type materials
   */
  async getForWorkType(workTypeId) {
    try {
      const response = await apiService.get(`/work-types/${workTypeId}/materials`);
      
      if (response.success && response.data) {
        return {
          success: true,
          data: Array.isArray(response.data)
            ? response.data.map(item => toCamelCase(item))
            : toCamelCase(response.data)
        };
      }
      
      return response;
    } catch (error) {
      console.error(`Error getting materials for work type ${workTypeId}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to get work type materials',
        error
      };
    }
  }
}

// Export singleton instance
export default new MaterialsService();