import apiClient from './api.service';
import { toCamelCase, toSnakeCase } from '@/utils/casing';

/**
 * Service for handling community-related API requests
 */
class CommunityService {
  /**
   * Get all communities with optional filtering
   * @param {Object} filters - Optional filters including isActive
   * @returns {Promise<Array>} - List of communities
   */
  async getAllCommunities(filters = {}) {
    try {
      // Convert filters to snake_case for API
      const snakeCaseFilters = toSnakeCase(filters);

      // Debug the filters being sent to the API
      console.log('Fetching communities with filters:', snakeCaseFilters);

      const response = await apiClient.get('/communities', { params: snakeCaseFilters });

      // Debug the response from the API
      console.log('Communities API response:', response);

      // Ensure we're properly converting snake_case to camelCase
      const communities = toCamelCase(response.data);
      return communities;
    } catch (error) {
      console.error('Error fetching communities:', error);
      throw error;
    }
  }

  /**
   * Get a community by ID
   * @param {number} id - Community ID
   * @returns {Promise<Object>} - Community data
   */
  async getCommunityById(id) {
    try {
      console.log(`Fetching community with ID: ${id}`);
      const response = await apiClient.get(`/communities/${id}`);

      // Debug the raw API response to see its structure
      console.log('Raw API response:', response);

      // Handle different response structures
      let communityData;
      if (response.data && response.data.data) {
        // Standard structure: { data: { data: {...} } }
        communityData = response.data.data;
      } else if (response.data) {
        // Alternative structure: { data: {...} }
        communityData = response.data;
      } else {
        // Unexpected structure
        console.error('Unexpected API response structure:', response);
        return null;
      }

      // Convert to camelCase and debug the result
      const camelCaseData = toCamelCase(communityData);
      console.log('Converted community data:', camelCaseData);

      return camelCaseData;
    } catch (error) {
      console.error(`Error fetching community ${id}:`, error);
      throw error;
    }
  }

  /**
   * Create a new community
   * @param {Object} communityData - Community data
   * @returns {Promise<Object>} - Created community
   */
  async createCommunity(communityData) {
    try {
      // Convert data to snake_case for API
      const snakeCaseData = toSnakeCase(communityData);

      const response = await apiClient.post('/communities', snakeCaseData);
      return toCamelCase(response.data.data);
    } catch (error) {
      console.error('Error creating community:', error);
      throw error;
    }
  }

  /**
   * Update a community
   * @param {number} id - Community ID
   * @param {Object} communityData - Updated community data
   * @returns {Promise<Object>} - Updated community
   */
  async updateCommunity(id, communityData) {
    try {
      // Convert data to snake_case for API
      const snakeCaseData = toSnakeCase(communityData);

      console.log(`Updating community ${id} with data:`, snakeCaseData);
      const response = await apiClient.put(`/communities/${id}`, snakeCaseData);

      // Debug the raw API response
      console.log('Update community API response:', response);

      // Handle different response structures
      let updatedData;
      if (response.data && response.data.data) {
        // Standard structure: { data: { data: {...} } }
        updatedData = response.data.data;
      } else if (response.data && response.data.success) {
        // Alternative structure: { success: true, data: {...} }
        updatedData = response.data.data;
      } else if (response.data) {
        // Fallback: use the entire data object
        updatedData = response.data;
      } else {
        console.error('Unexpected API response structure for update:', response);
        throw new Error('No data returned from update operation');
      }

      // Convert to camelCase and debug the result
      const camelCaseData = toCamelCase(updatedData);
      console.log('Converted updated community data:', camelCaseData);

      return camelCaseData;
    } catch (error) {
      console.error(`Error updating community ${id}:`, error);
      throw error;
    }
  }

  /**
   * Delete a community
   * @param {number} id - Community ID
   * @returns {Promise<boolean>} - Success status
   */
  async deleteCommunity(id) {
    try {
      const response = await apiClient.delete(`/communities/${id}`);
      return response.data.success;
    } catch (error) {
      console.error(`Error deleting community ${id}:`, error);
      throw error;
    }
  }

  /**
   * Search communities
   * @param {string} query - Search query
   * @returns {Promise<Array>} - Matching communities
   */
  async searchCommunities(query) {
    try {
      const response = await apiClient.get('/communities/search', { params: { q: query } });
      // Handle different response structures
      let searchData;
      if (response.data && response.data.data) {
        // Standard structure: { data: { data: [...] } }
        searchData = response.data.data;
      } else if (response.data) {
        // Alternative structure: { data: [...] }
        searchData = response.data;
      } else {
        // Unexpected structure
        console.error('Unexpected API response structure for search:', response);
        return [];
      }
      return toCamelCase(searchData);
    } catch (error) {
      console.error(`Error searching communities with query "${query}":`, error);
      throw error;
    }
  }

  /**
   * Set a community's active status
   * @param {number} id - Community ID
   * @param {boolean} isActive - Active status
   * @returns {Promise<Object>} - Updated community
   */
  async setActiveStatus(id, isActive) {
    try {
      const response = await apiClient.put(`/communities/${id}/active-status`, { isActive });
      return toCamelCase(response.data.data);
    } catch (error) {
      console.error(`Error setting active status for community ${id}:`, error);
      throw error;
    }
  }

  /**
   * Select an ad type for a community
   * @param {number} communityId - Community ID
   * @param {number} adTypeId - Ad Type ID
   * @returns {Promise<Object>} - Updated community
   */
  async selectAdType(communityId, adTypeId) {
    try {
      console.log(`Selecting ad type ${adTypeId} for community ${communityId}`);
      const response = await apiClient.put(`/communities/${communityId}/select-ad-type`, { adTypeId });

      // Debug the raw API response
      console.log('Select ad type API response:', response);

      // Handle different response structures
      let updatedData;
      if (response.data && response.data.data) {
        // Standard structure: { data: { data: {...} } }
        updatedData = response.data.data;
      } else if (response.data && response.data.success) {
        // Alternative structure: { success: true, data: {...} }
        updatedData = response.data.data;
      } else if (response.data) {
        // Fallback: use the entire data object
        updatedData = response.data;
      } else {
        console.error('Unexpected API response structure for select ad type:', response);
        throw new Error('No data returned from select ad type operation');
      }

      // Convert to camelCase and debug the result
      const camelCaseData = toCamelCase(updatedData);
      console.log('Converted selected ad type data:', camelCaseData);

      return camelCaseData;
    } catch (error) {
      console.error(`Error selecting ad type for community ${communityId}:`, error);
      throw error;
    }
  }

  /**
   * Get all ad types for a community
   * @param {number} communityId - Community ID
   * @returns {Promise<Array>} - List of ad types
   */
  async getAdTypes(communityId) {
    try {
      console.log(`Fetching ad types for community ID: ${communityId}`);
      const response = await apiClient.get(`/communities/${communityId}/ad-types`);

      // Debug the raw API response to see its structure
      console.log('Raw ad types API response:', response);

      // Handle different response structures
      let adTypesData;
      if (response.data && response.data.data) {
        // Standard structure: { data: { data: [...] } }
        adTypesData = response.data.data;
      } else if (response.data) {
        // Alternative structure: { data: [...] }
        adTypesData = response.data;
      } else {
        // Unexpected structure
        console.error('Unexpected API response structure for ad types:', response);
        return [];
      }

      // Convert to camelCase and debug the result
      const camelCaseData = toCamelCase(adTypesData);
      console.log('Converted ad types data:', camelCaseData);

      return camelCaseData;
    } catch (error) {
      console.error(`Error fetching ad types for community ${communityId}:`, error);
      // Return empty array on error to prevent undefined errors
      return [];
    }
  }

  /**
   * Get an ad type by ID
   * @param {number} id - Ad Type ID
   * @returns {Promise<Object>} - Ad type data
   */
  async getAdTypeById(id) {
    try {
      const response = await apiClient.get(`/communities/ad-types/${id}`);
      return toCamelCase(response.data.data);
    } catch (error) {
      console.error(`Error fetching ad type ${id}:`, error);
      throw error;
    }
  }

  /**
   * Create a new ad type for a community
   * @param {number} communityId - Community ID
   * @param {Object} adTypeData - Ad type data
   * @returns {Promise<Object>} - Created ad type
   */
  async createAdType(communityId, adTypeData) {
    try {
      // Convert data to snake_case for API
      const snakeCaseData = toSnakeCase(adTypeData);

      console.log(`Creating ad type for community ${communityId} with data:`, snakeCaseData);
      const response = await apiClient.post(`/communities/${communityId}/ad-types`, snakeCaseData);

      // Debug the raw API response
      console.log('Create ad type API response:', response);

      // Handle different response structures
      let createdData;
      if (response.data && response.data.data) {
        // Standard structure: { data: { data: {...} } }
        createdData = response.data.data;
      } else if (response.data && response.data.success) {
        // Alternative structure: { success: true, data: {...} }
        createdData = response.data.data;
      } else if (response.data) {
        // Fallback: use the entire data object
        createdData = response.data;
      } else {
        console.error('Unexpected API response structure for create ad type:', response);
        throw new Error('No data returned from create ad type operation');
      }

      // Convert to camelCase and debug the result
      const camelCaseData = toCamelCase(createdData);
      console.log('Converted created ad type data:', camelCaseData);

      return camelCaseData;
    } catch (error) {
      console.error(`Error creating ad type for community ${communityId}:`, error);
      throw error;
    }
  }

  /**
   * Update an ad type
   * @param {number} id - Ad Type ID
   * @param {Object} adTypeData - Updated ad type data
   * @returns {Promise<Object>} - Updated ad type
   */
  async updateAdType(id, adTypeData) {
    try {
      // Convert data to snake_case for API
      const snakeCaseData = toSnakeCase(adTypeData);

      console.log(`Updating ad type ${id} with data:`, snakeCaseData);
      const response = await apiClient.put(`/communities/ad-types/${id}`, snakeCaseData);

      // Debug the raw API response
      console.log('Update ad type API response:', response);

      // Handle different response structures
      let updatedData;
      if (response.data && response.data.data) {
        // Standard structure: { data: { data: {...} } }
        updatedData = response.data.data;
      } else if (response.data && response.data.success) {
        // Alternative structure: { success: true, data: {...} }
        updatedData = response.data.data;
      } else if (response.data) {
        // Fallback: use the entire data object
        updatedData = response.data;
      } else {
        console.error('Unexpected API response structure for update ad type:', response);
        throw new Error('No data returned from update ad type operation');
      }

      // Convert to camelCase and debug the result
      const camelCaseData = toCamelCase(updatedData);
      console.log('Converted updated ad type data:', camelCaseData);

      return camelCaseData;
    } catch (error) {
      console.error(`Error updating ad type ${id}:`, error);
      throw error;
    }
  }

  /**
   * Delete an ad type
   * @param {number} id - Ad Type ID
   * @returns {Promise<boolean>} - Success status
   */
  async deleteAdType(id) {
    try {
      const response = await apiClient.delete(`/communities/ad-types/${id}`);
      return response.data.success;
    } catch (error) {
      console.error(`Error deleting ad type ${id}:`, error);
      throw error;
    }
  }
}

export default new CommunityService();