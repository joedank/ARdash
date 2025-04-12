import api from './api.service';

/**
 * Projects service for handling project-related API calls
 */
class ProjectsService {
  /**
   * Create a new project
   * @param {Object} data Project data
   * @returns {Promise} API response
   */
  createProject(data) {
    return api.post('/projects', data);
  }

  /**
   * Get all projects with optional filters
   * @param {Object} params Filter parameters
   * @returns {Promise} API response
   */
  getAllProjects(params = {}) {
    return api.get('/projects', { params });
  }

  /**
   * Get today's projects
   * @returns {Promise} API response
   */
  getTodayProjects() {
    return api.get('/projects/today');
  }

  /**
   * Get project details by ID
   * @param {string} id Project ID
   * @returns {Promise} API response
   */
  getProject(id) {
    return api.get(`/projects/${id}`);
  }

  /**
   * Update project status
   * @param {string} id Project ID
   * @param {string} status New status
   * @returns {Promise} API response
   */
  updateStatus(id, status) {
    return api.put(`/projects/${id}/status`, { status });
  }

  /**
   * Update project
   * @param {string} id Project ID
   * @param {Object} data Updated project data
   * @returns {Promise} API response
   */
  updateProject(id, data) {
    return api.put(`/projects/${id}`, data);
  }

  /**
   * Update additional work notes for a project
   * @param {string} id Project ID
   * @param {string} notes Additional work notes
   * @returns {Promise} API response
   */
  updateAdditionalWork(id, notes) {
    return api.put(`/projects/${id}/additional-work`, { additional_work: notes });
  }

  /**
   * Delete project
   * @param {string} id Project ID
   * @returns {Promise} API response
   */
  deleteProject(id) {
    return api.delete(`/projects/${id}`);
  }

  /**
   * Add inspection to project
   * @param {string} id Project ID
   * @param {Object} data Inspection data
   * @returns {Promise} API response
   */
  addInspection(id, data) {
    return api.post(`/projects/${id}/inspections`, data);
  }

  /**
   * Add photo to project
   * @param {string} id Project ID
   * @param {File} file Photo file
   * @param {Object} data Additional photo data
   * @returns {Promise} API response
   */
  async addPhoto(id, file, data, onProgress = () => {}, signal = null) {
    if (!id || !file) {
      throw new Error('Project ID and file are required');
    }

    const formData = new FormData();
    formData.append('photo', file);
    Object.entries(data).forEach(([key, value]) => {
      if (value !== undefined && value !== null) {
        formData.append(key, value);
      }
    });

    try {
      return await api.post(`/projects/${id}/photos`, formData, {
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
   * Convert project to estimate
   * @param {string} id Project ID
   * @returns {Promise} API response
   */
  convertToEstimate(id) {
    return api.post(`/projects/${id}/convert`);
  }

  /**
   * Convert assessment to active job
   * @param {string} id Assessment Project ID
   * @param {string} estimateId Estimate ID
   * @returns {Promise} API response
   */
  convertToJob(id, estimateId) {
    return api.post(`/projects/${id}/convert-to-job`, { estimate_id: estimateId });
  }

  /**
   * Delete a photo from a project
   * @param {string} projectId Project ID
   * @param {string} photoId Photo ID
   * @returns {Promise} API response
   */
  deletePhoto(projectId, photoId) {
    return api.delete(`/projects/${projectId}/photos/${photoId}`);
  }

  /**
   * Format the inspection data based on category
   * @param {string} category Inspection category
   * @param {Object} data Raw form data
   * @returns {Object} Formatted inspection data
   */
  formatInspectionData(category, data) {
    switch (category) {
      case 'condition':
        return {
          category,
          content: {
            assessment: data.assessment || '',
            notes: data.notes || ''
          }
        };

      case 'measurements':
        return {
          category,
          content: {
            items: Array.isArray(data.items) ? data.items.map(item => {
              // Base item with common properties
              const formattedItem = {
                description: item.description || '',
                measurementType: item.measurementType || 'area'
              };

              // Add type-specific properties based on measurement type
              if (item.measurementType === 'area') {
                formattedItem.dimensions = {
                  length: item.length || '',
                  width: item.width || '',
                  units: item.units || 'feet'
                };
              } else if (item.measurementType === 'linear') {
                formattedItem.dimensions = {
                  length: item.length || '',
                  units: item.units || 'feet'
                };
              } else if (item.measurementType === 'quantity') {
                formattedItem.quantity = item.quantity || '1';
                formattedItem.quantityUnit = item.quantityUnit || 'each';
              } else {
                // Default to area if no measurement type specified
                formattedItem.dimensions = {
                  length: item.length || '',
                  width: item.width || '',
                  units: item.units || 'feet'
                };
              }

              return formattedItem;
            }) : [
              // Handle legacy format as single measurement
              data.length || data.width ? {
                description: 'Main measurement',
                measurementType: 'area',
                dimensions: {
                  length: data.length || '',
                  width: data.width || '',
                  units: data.units || 'feet'
                }
              } : null
            ].filter(Boolean),
            notes: data.notes || ''
          }
        };

      case 'materials':
        return {
          category,
          content: {
            items: Array.isArray(data.items) ? data.items : [],
            notes: data.notes || ''
          }
        };

      default:
        throw new Error(`Invalid inspection category: ${category}`);
    }
  }
}

const projectsService = new ProjectsService();

export { projectsService };
export default projectsService;