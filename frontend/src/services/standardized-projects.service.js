import BaseService from './base.service';
import api from './api.service';
import { standardizeResponse as apiStandardizeResponse, standardizeRequest as apiStandardizeRequest } from '../utils/apiAdapter';

/**
 * Standardized Projects service for handling project-related API calls
 * with consistent field naming and error handling
 */
class StandardizedProjectsService extends BaseService {
  constructor() {
    super('/projects');
    this.api = api; // Explicitly set the API reference
  }

  /**
   * Standardize response to ensure consistent format
   * @param {Object} response - API response
   * @returns {Object} Standardized response
   */
  standardizeResponse(response) {
    if (!response) return { success: false, message: 'No response received', data: null };
    
    // Handle different response formats
    if (response.data && (response.success !== undefined || response.data.success !== undefined)) {
      // Response already has success property
      const success = response.success !== undefined ? response.success : response.data.success;
      const message = response.message || response.data.message || '';
      const data = response.data?.data || response.data;
      
      return {
        success,
        message,
        data: apiStandardizeResponse(data) // Use imported function
      };
    }
    
    // Simple response format
    return {
      success: true,
      message: 'Operation successful',
      data: apiStandardizeResponse(response.data) // Use imported function
    };
  }

  /**
   * Get today's projects
   * @returns {Promise<Object>} Standardized response with today's projects
   */
  async getTodayProjects() {
    try {
      const response = await this.api.get(`${this.resourceUrl}/today`);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error('Get today projects error:', error);
      throw error;
    }
  }

  /**
   * Get all projects with optional filters
   * @param {Object} params - Filter parameters
   * @returns {Promise<Object>} Standardized response with projects
   */
  async getAllProjects(params = {}) {
    try {
      const response = await this.api.get(this.resourceUrl, { params });
      return this.standardizeResponse(response);
    } catch (error) {
      console.error('Get all projects error:', error);
      throw error;
    }
  }

  /**
   * Get project details by ID
   * @param {string} id - Project ID
   * @returns {Promise<Object>} Standardized response with project details
   */
  async getProject(id) {
    try {
      const response = await this.api.get(`${this.resourceUrl}/${id}`);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Get project error for ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Create a new project
   * @param {Object} data - Project data
   * @returns {Promise<Object>} Standardized response with created project
   */
  async createProject(data) {
    try {
      const requestData = apiStandardizeRequest(data); // Use imported function
      const response = await this.api.post(this.resourceUrl, requestData);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error('Create project error:', error);
      throw error;
    }
  }

  /**
   * Update project
   * @param {string} id - Project ID
   * @param {Object} data - Updated project data
   * @returns {Promise<Object>} Standardized response with updated project
   */
  async updateProject(id, data) {
    try {
      const requestData = apiStandardizeRequest(data); // Use imported function
      const response = await this.api.put(`${this.resourceUrl}/${id}`, requestData);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Update project error for ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Delete project
   * @param {string} id - Project ID
   * @returns {Promise<Object>} Standardized response
   */
  async deleteProject(id) {
    try {
      const response = await this.api.delete(`${this.resourceUrl}/${id}`);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Delete project error for ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Update project status
   * @param {string} id - Project ID
   * @param {string} status - New status
   * @returns {Promise<Object>} Standardized response with updated project
   */
  async updateStatus(id, status) {
    try {
      const response = await this.api.put(`${this.resourceUrl}/${id}/status`, { status });
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Update project status error for ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Add inspection to project
   * @param {string} id - Project ID
   * @param {Object} data - Inspection data
   * @returns {Promise<Object>} Standardized response with created inspection
   */
  async addInspection(id, data) {
    try {
      const requestData = apiStandardizeRequest(data); // Use imported function
      const response = await this.api.post(
        `${this.resourceUrl}/${id}/inspections`,
        requestData
      );
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Add inspection error for project ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Add photo to project
   * @param {string} id - Project ID
   * @param {File} file - Photo file
   * @param {Object} data - Additional photo data
   * @param {Function} onProgress - Progress callback
   * @param {AbortSignal} signal - AbortController signal
   * @returns {Promise<Object>} Standardized response with created photo
   */
  async addPhoto(id, file, data, onProgress = () => {}, signal = null) {
    try {
      const formData = new FormData();
      formData.append('photo', file);
      
      // Convert camelCase keys to snake_case for API
      const standardizedData = apiStandardizeRequest(data); // Use imported function
      
      Object.entries(standardizedData).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          formData.append(key, value);
        }
      });

      const response = await this.api.post(`${this.resourceUrl}/${id}/photos`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        },
        onUploadProgress: (progressEvent) => {
          if (signal?.aborted) return; // Skip progress if aborted
          const percentCompleted = Math.round((progressEvent.loaded * 100) / progressEvent.total);
          onProgress(percentCompleted);
        },
        signal // Pass the AbortController signal to axios
      });
      
      return this.standardizeResponse(response);
    } catch (error) {
      console.error('Photo upload error details:', {
        projectId: id,
        fileName: file.name,
        fileSize: file.size,
        error: error.message || 'Unknown error'
      });
      throw error;
    }
  }

  /**
   * Delete a photo from a project
   * @param {string} projectId - Project ID
   * @param {string} photoId - Photo ID
   * @returns {Promise<Object>} Standardized response
   */
  async deletePhoto(projectId, photoId) {
    try {
      const response = await this.api.delete(`${this.resourceUrl}/${projectId}/photos/${photoId}`);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Delete photo error for project ID ${projectId}, photo ID ${photoId}:`, error);
      throw error;
    }
  }

  /**
   * Convert project to estimate
   * @param {string} id - Project ID
   * @returns {Promise<Object>} Standardized response with conversion result
   */
  async convertToEstimate(id) {
    try {
      const response = await this.api.post(`${this.resourceUrl}/${id}/convert`);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Convert to estimate error for project ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Convert assessment to active job
   * @param {string} id - Assessment Project ID
   * @param {string} estimateId - Estimate ID
   * @returns {Promise<Object>} Standardized response with job project
   */
  async convertToJob(id, estimateId) {
    try {
      const response = await this.api.post(`${this.resourceUrl}/${id}/convert-to-job`, { 
        estimate_id: estimateId 
      });
      
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Convert to job error for project ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Update additional work notes for a project
   * @param {string} id - Project ID
   * @param {string} notes - Additional work notes
   * @returns {Promise<Object>} Standardized response with updated project
   */
  async updateAdditionalWork(id, notes) {
    try {
      const response = await this.api.put(`${this.resourceUrl}/${id}/additional-work`, { 
        additional_work: notes 
      });
      
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Update additional work error for project ID ${id}:`, error);
      throw error;
    }
  }

}

const standardizedProjectsService = new StandardizedProjectsService();

export { standardizedProjectsService };
export default standardizedProjectsService;