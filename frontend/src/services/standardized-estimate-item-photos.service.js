import api from './api.service';
import apiAdapter from '../utils/apiAdapter';
import { isValidUuid } from '../utils/casing';

/**
 * Service for managing estimate item photos
 */
const estimateItemPhotosService = {
  /**
   * Upload a photo for a specific estimate item
   * @param {string} estimateItemId - The UUID of the estimate item
   * @param {File} photoFile - The photo file to upload
   * @param {Object} metadata - Additional metadata for the photo
   * @returns {Promise<Object>} - Standardized response
   */
  async uploadPhoto(estimateItemId, photoFile, metadata = {}) {
    try {
      // Validate UUID
      if (!isValidUuid(estimateItemId)) {
        return {
          success: false,
          message: 'Invalid estimate item ID format'
        };
      }

      // Create form data for multipart upload
      const formData = new FormData();
      formData.append('photo', photoFile);

      // Add metadata
      if (metadata.photoType) {
        formData.append('photoType', metadata.photoType);
      }

      if (metadata.notes) {
        formData.append('notes', metadata.notes);
      }

      // Make API request
      const response = await api.post(
        `/estimate-items/${estimateItemId}/photos`,
        formData,
        {
          headers: {
            'Content-Type': 'multipart/form-data'
          }
        }
      );

      return apiAdapter.standardizeResponse(response);
    } catch (error) {
      return apiAdapter.standardizeError(error);
    }
  },

  /**
   * Get all photos for a specific estimate item
   * @param {string} estimateItemId - The UUID of the estimate item
   * @returns {Promise<Object>} - Standardized response
   */
  async getPhotos(estimateItemId) {
    try {
      // Validate UUID
      if (!isValidUuid(estimateItemId)) {
        return {
          success: false,
          message: 'Invalid estimate item ID format'
        };
      }

      // Make API request
      const response = await api.get(`/estimate-items/${estimateItemId}/photos`);
      return apiAdapter.standardizeResponse(response);
    } catch (error) {
      return apiAdapter.standardizeError(error);
    }
  },

  /**
   * Get a specific photo by ID
   * @param {string} estimateItemId - The UUID of the estimate item
   * @param {string} photoId - The UUID of the photo
   * @returns {Promise<Object>} - Standardized response
   */
  async getPhotoById(estimateItemId, photoId) {
    try {
      // Validate UUIDs
      if (!isValidUuid(estimateItemId) || !isValidUuid(photoId)) {
        return {
          success: false,
          message: 'Invalid ID format'
        };
      }

      // Make API request
      const response = await api.get(`/estimate-items/${estimateItemId}/photos/${photoId}`);
      return apiAdapter.standardizeResponse(response);
    } catch (error) {
      return apiAdapter.standardizeError(error);
    }
  },

  /**
   * Update a photo's metadata
   * @param {string} estimateItemId - The UUID of the estimate item
   * @param {string} photoId - The UUID of the photo
   * @param {Object} metadata - The metadata to update
   * @returns {Promise<Object>} - Standardized response
   */
  async updatePhoto(estimateItemId, photoId, metadata) {
    try {
      // Validate UUIDs
      if (!isValidUuid(estimateItemId) || !isValidUuid(photoId)) {
        return {
          success: false,
          message: 'Invalid ID format'
        };
      }

      // Prepare data for API
      const requestData = apiAdapter.standardizeRequest(metadata);

      // Make API request
      const response = await api.put(
        `/estimate-items/${estimateItemId}/photos/${photoId}`,
        requestData
      );

      return apiAdapter.standardizeResponse(response);
    } catch (error) {
      return apiAdapter.standardizeError(error);
    }
  },

  /**
   * Delete a photo
   * @param {string} estimateItemId - The UUID of the estimate item
   * @param {string} photoId - The UUID of the photo
   * @returns {Promise<Object>} - Standardized response
   */
  async deletePhoto(estimateItemId, photoId) {
    try {
      // Validate UUIDs
      if (!isValidUuid(estimateItemId) || !isValidUuid(photoId)) {
        return {
          success: false,
          message: 'Invalid ID format'
        };
      }

      // Make API request
      const response = await api.delete(`/estimate-items/${estimateItemId}/photos/${photoId}`);
      return apiAdapter.standardizeResponse(response);
    } catch (error) {
      return apiAdapter.standardizeError(error);
    }
  },

  /**
   * Get all photos for an entire estimate (organized by line item)
   * @param {string} estimateId - The UUID of the estimate
   * @returns {Promise<Object>} - Standardized response
   */
  async getPhotosByEstimate(estimateId) {
    try {
      // Validate UUID
      if (!isValidUuid(estimateId)) {
        return {
          success: false,
          message: 'Invalid estimate ID format'
        };
      }

      // Make API request
      // Removed leading /api as it's handled by the base URL in api.service.js
      const response = await api.get(`/estimates/${estimateId}/photos`);
      return apiAdapter.standardizeResponse(response);
    } catch (error) {
      // Re-throw the error to be handled by the interceptor or calling component
      throw error;
    }
  }
};

export default estimateItemPhotosService;
