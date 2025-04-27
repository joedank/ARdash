/**
 * Work Types Service
 *
 * Service for interacting with work types API endpoints
 */

import apiService from './api.service';
import { toCamelCase, toSnakeCase } from '../utils/casing';

/**
 * Work Types Service
 */
class WorkTypesService {
  constructor() {
    // For debouncing similarity requests
    this._lastSimilarityRequest = 0;
  }

  /**
   * Get all work types with optional filtering
   * @param {Object} filters - Optional filter parameters
   * @returns {Promise<Object>} Response with work types data
   */
  async getAllWorkTypes(filters = {}) {
    try {
      // Convert camelCase filters to snake_case for API
      const snakeCaseFilters = toSnakeCase(filters);

      const response = await apiService.get('/work-types', {
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
      console.error('Error getting work types:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to get work types',
        error
      };
    }
  }

  /**
   * Get work type by ID
   * @param {string} id - Work type UUID
   * @param {Object} options - Additional options (include_materials, include_tags, etc.)
   * @returns {Promise<Object>} Response with work type data
   */
  async getById(id, options = {}) {
    try {
      // Convert camelCase options to snake_case for API
      const snakeCaseOptions = toSnakeCase(options);

      const response = await apiService.get(`/work-types/${id}`, {
        params: snakeCaseOptions
      });

      if (response.success && response.data) {
        return {
          success: true,
          data: toCamelCase(response.data)
        };
      }

      return response;
    } catch (error) {
      console.error(`Error getting work type ${id}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to get work type',
        error
      };
    }
  }

  /**
   * Create a new work type
   * @param {Object} data - Work type data
   * @returns {Promise<Object>} Response with created work type
   */
  async createWorkType(data) {
    try {
      // Convert camelCase data to snake_case for API
      const snakeCaseData = toSnakeCase(data);

      const response = await apiService.post('/work-types', snakeCaseData);

      if (response.success && response.data) {
        return {
          success: true,
          data: toCamelCase(response.data),
          message: response.message || 'Work type created successfully'
        };
      }

      return response;
    } catch (error) {
      console.error('Error creating work type:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to create work type',
        error
      };
    }
  }

  /**
   * Update a work type
   * @param {string} id - Work type UUID
   * @param {Object} data - Updated work type data
   * @returns {Promise<Object>} Response with updated work type
   */
  async updateWorkType(id, data) {
    try {
      // Convert camelCase data to snake_case for API
      const snakeCaseData = toSnakeCase(data);

      const response = await apiService.put(`/work-types/${id}`, snakeCaseData);

      if (response.success && response.data) {
        return {
          success: true,
          data: toCamelCase(response.data),
          message: response.message || 'Work type updated successfully'
        };
      }

      return response;
    } catch (error) {
      console.error(`Error updating work type ${id}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to update work type',
        error
      };
    }
  }

  /**
   * Delete a work type
   * @param {string} id - Work type UUID
   * @returns {Promise<Object>} Response with success status
   */
  async deleteWorkType(id) {
    try {
      const response = await apiService.delete(`/work-types/${id}`);

      return {
        success: true,
        message: response.message || 'Work type deleted successfully'
      };
    } catch (error) {
      console.error(`Error deleting work type ${id}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to delete work type',
        error
      };
    }
  }

  /**
   * Find similar work types by name
   * @param {string} name - Work type name to search
   * @param {number} threshold - Similarity threshold (0-1)
   * @returns {Promise<Object>} Response with similar work types
   */
  async findSimilarWorkTypes(name, threshold = 0.3) {
    try {
      // Rate limit - add delay between requests for at least 300ms
      if (this._lastSimilarityRequest && Date.now() - this._lastSimilarityRequest < 300) {
        await new Promise(resolve => setTimeout(resolve, 300));
      }
      this._lastSimilarityRequest = Date.now();

      const response = await apiService.get('/work-types/similar', {
        params: { q: name, threshold } // Use 'q' for compatibility with other search endpoints
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
      console.error(`Error finding similar work types for "${name}":`, error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to find similar work types',
        error
      };
    }
  }

  /**
   * Get work types by parent bucket
   * @param {string} parentBucket - Parent bucket name
   * @returns {Promise<Object>} Response with filtered work types
   */
  async getByParentBucket(parentBucket) {
    return this.getAllWorkTypes({ parentBucket });
  }

  /**
   * Get work types by measurement type
   * @param {string} measurementType - Measurement type (area, linear, quantity)
   * @returns {Promise<Object>} Response with filtered work types
   */
  async getByMeasurementType(measurementType) {
    return this.getAllWorkTypes({ measurementType });
  }

  /**
   * Get work type by ID with optional includes
   * @param {string} id - Work type UUID
   * @param {boolean} includeMaterials - Whether to include materials
   * @param {boolean} includeTags - Whether to include tags
   * @returns {Promise<Object>} Work type object
   */
  async getWorkTypeById(id, includeMaterials = false, includeTags = false) {
    try {
      const options = {};

      if (includeMaterials) {
        options.includeMaterials = true;
      }

      if (includeTags) {
        options.includeTags = true;
      }

      const response = await this.getById(id, options);

      if (response.success && response.data) {
        return response.data;
      }

      throw new Error(response.message || 'Failed to get work type');
    } catch (error) {
      console.error(`Error getting work type ${id}:`, error);
      throw error;
    }
  }

  /**
   * Update costs for a work type
   * @param {string} id - Work type UUID
   * @param {Object} costData - Cost data
   * @param {number} costData.unitCostMaterial - Material cost per unit
   * @param {number} costData.unitCostLabor - Labor cost per unit
   * @param {number} costData.productivityUnitPerHr - Productivity units per hour
   * @param {string} region - Region for cost data (optional)
   * @returns {Promise<Object>} Response with updated work type
   */
  async updateCosts(id, costData, region) {
    try {
      // Convert camelCase data to snake_case for API
      const snakeCaseData = toSnakeCase(costData);

      // Add region if provided
      if (region) {
        snakeCaseData.region = region;
      }

      const response = await apiService.patch(`/work-types/${id}/costs`, snakeCaseData);

      if (response.success && response.data) {
        return {
          success: true,
          data: toCamelCase(response.data),
          message: response.message || 'Work type costs updated successfully'
        };
      }

      return response;
    } catch (error) {
      console.error(`Error updating costs for work type ${id}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to update work type costs',
        error
      };
    }
  }

  /**
   * Get cost history for a work type
   * @param {string} id - Work type UUID
   * @param {string} region - Filter by region (optional)
   * @param {number} limit - Maximum number of history entries to return
   * @returns {Promise<Object>} Response with cost history
   */
  async getCostHistory(id, region, limit = 10) {
    try {
      const params = { limit };

      if (region) {
        params.region = region;
      }

      const response = await apiService.get(`/work-types/${id}/costs/history`, { params });

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
      console.error(`Error getting cost history for work type ${id}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to get cost history',
        error
      };
    }
  }

  /**
   * Add materials to a work type
   * @param {string} id - Work type UUID
   * @param {Array} materials - Array of material objects
   * @returns {Promise<Object>} Response with added materials
   */
  async addMaterials(id, materials) {
    try {
      // Convert camelCase data to snake_case for API
      const snakeCaseMaterials = materials.map(material => toSnakeCase(material));

      const response = await apiService.post(`/work-types/${id}/materials`, snakeCaseMaterials);

      if (response.success && response.data) {
        return {
          success: true,
          data: Array.isArray(response.data)
            ? response.data.map(item => toCamelCase(item))
            : toCamelCase(response.data),
          message: response.message || 'Materials added successfully'
        };
      }

      return response;
    } catch (error) {
      console.error(`Error adding materials to work type ${id}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to add materials',
        error
      };
    }
  }

  /**
   * Remove a material from a work type
   * @param {string} id - Work type UUID
   * @param {string} materialId - Material UUID to remove
   * @returns {Promise<Object>} Response with success status
   */
  async removeMaterial(id, materialId) {
    try {
      const response = await apiService.delete(`/work-types/${id}/materials/${materialId}`);

      return {
        success: true,
        message: response.message || 'Material removed successfully'
      };
    } catch (error) {
      console.error(`Error removing material ${materialId} from work type ${id}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to remove material',
        error
      };
    }
  }

  /**
   * Add tags to a work type
   * @param {string} id - Work type UUID
   * @param {Array} tags - Array of tag strings
   * @returns {Promise<Object>} Response with added tags
   */
  async addTags(id, tags) {
    try {
      const response = await apiService.post(`/work-types/${id}/tags`, tags);

      if (response.success && response.data) {
        return {
          success: true,
          data: Array.isArray(response.data)
            ? response.data.map(item => toCamelCase(item))
            : toCamelCase(response.data),
          message: response.message || 'Tags added successfully'
        };
      }

      return response;
    } catch (error) {
      console.error(`Error adding tags to work type ${id}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to add tags',
        error
      };
    }
  }

  /**
   * Remove a tag from a work type
   * @param {string} id - Work type UUID
   * @param {string} tag - Tag to remove
   * @returns {Promise<Object>} Response with success status
   */
  async removeTag(id, tag) {
    try {
      const response = await apiService.delete(`/work-types/${id}/tags/${encodeURIComponent(tag)}`);

      return {
        success: true,
        message: response.message || 'Tag removed successfully'
      };
    } catch (error) {
      console.error(`Error removing tag ${tag} from work type ${id}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to remove tag',
        error
      };
    }
  }

  /**
   * Get tags grouped by frequency
   * @param {number} minCount - Minimum count to include a tag
   * @returns {Promise<Object>} Response with tags and counts
   */
  async getTagsByFrequency(minCount = 1) {
    try {
      const response = await apiService.get('/work-types/tags/frequency', {
        params: { min_count: minCount }
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
      console.error('Error getting tags by frequency:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to get tags',
        error
      };
    }
  }
}

// Export singleton instance
export default new WorkTypesService();
