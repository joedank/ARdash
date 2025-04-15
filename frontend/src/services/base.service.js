import api from './api.service';
import { standardizeResponse as apiStandardizeResponse, standardizeRequest as apiStandardizeRequest } from '../utils/apiAdapter';

/**
 * Base service class for standardized API communication
 * Provides consistent error handling and data transformation
 */
export default class BaseService {
  /**
   * Create a new service instance for a resource
   * @param {string} resourceUrl - API endpoint for the resource
   */
  constructor(resourceUrl) {
    this.resourceUrl = resourceUrl;
    this.api = api; // Explicitly set the API reference
    // this.fieldAdapter = fieldAdapter; // Removed - using imported functions directly
  }
  
  /**
   * Get all resources with optional filters
   * @param {Object} params - Query parameters for filtering
   * @returns {Promise<Object>} Standardized response
   */
  async getAll(params = {}) {
    try {
      console.log(`BaseService.getAll: ${this.resourceUrl} with params:`, params.toString ? params.toString() : params);
      const response = await this.api.get(this.resourceUrl, { params });
      
      // Log the raw response to see what's coming back
      if (params.toString && params.toString().includes('page=')) {
        console.log(`BaseService.getAll pagination raw response:`, response.data);
      }
      
      return this.standardizeResponse(response);
    } catch (error) {
      this._handleError(error);
    }
  }
  
  /**
   * Get a resource by ID
   * @param {string} id - Resource ID
   * @returns {Promise<Object>} Standardized response
   */
  async getById(id) {
    try {
      if (!id || id === 'undefined' || id === 'null') {
        throw new Error(`Invalid ID provided: ${id}`);
      }
      
      const response = await this.api.get(`${this.resourceUrl}/${id}`);
      return this.standardizeResponse(response);
    } catch (error) {
      this._handleError(error);
    }
  }
  
  /**
   * Create a new resource
   * @param {Object} data - Resource data
   * @returns {Promise<Object>} Standardized response
   */
  async create(data) {
    try {
      const response = await this.api.post(
        this.resourceUrl, 
        this.standardizeRequest(data)
      );
      
      return this.standardizeResponse(response);
    } catch (error) {
      this._handleError(error);
    }
  }
  
  /**
   * Update an existing resource
   * @param {string} id - Resource ID
   * @param {Object} data - Updated resource data
   * @returns {Promise<Object>} Standardized response
   */
  async update(id, data) {
    try {
      if (!id || id === 'undefined' || id === 'null') {
        throw new Error(`Invalid ID provided: ${id}`);
      }
      
      const response = await this.api.put(
        `${this.resourceUrl}/${id}`, 
        this.standardizeRequest(data)
      );
      
      return this.standardizeResponse(response);
    } catch (error) {
      this._handleError(error);
    }
  }
  
  /**
   * Delete a resource by ID
   * @param {string} id - Resource ID
   * @returns {Promise<Object>} Standardized response
   */
  async delete(id) {
    try {
      if (!id || id === 'undefined' || id === 'null') {
        throw new Error(`Invalid ID provided: ${id}`);
      }
      
      const response = await this.api.delete(`${this.resourceUrl}/${id}`);
      return this.standardizeResponse(response);
    } catch (error) {
      this._handleError(error);
    }
  }
  
  /**
   * Standardize request data for consistent field naming
   * @param {Object} data - Request data
   * @returns {Object} Standardized data
   */
  standardizeRequest(data) {
    return apiStandardizeRequest(data); // Use imported function
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
   * Handle and standardize errors
   * @param {Error} error - Error object
   * @private
   */
  _handleError(error) {
    console.error(`${this.resourceUrl} Service Error:`, error);
    throw error;
  }
}