import BaseService from './base.service';
import apiService from './api.service';

/**
 * Service for estimate operations with standardized methods
 */
class EstimateService extends BaseService {
  /**
   * Create a new EstimateService instance
   */
  constructor() {
    super('/estimates');
  }

  /**
   * List estimates with optional filters
   * @param {Object} filters - Query filters
   * @param {number} page - Page number (0-based)
   * @param {number} limit - Items per page
   * @returns {Promise} Response data with paginated estimates
   */
  async listEstimates(filters = {}, page = 0, limit = 10) {
    const queryParams = new URLSearchParams();

    // Add filters to query params
    if (filters.status) queryParams.append('status', filters.status);
    if (filters.clientId) queryParams.append('clientId', filters.clientId);
    if (filters.dateFrom) queryParams.append('dateFrom', filters.dateFrom);
    if (filters.dateTo) queryParams.append('dateTo', filters.dateTo);

    // Add pagination
    queryParams.append('page', page);
    queryParams.append('limit', limit);

    console.log('Sending estimate pagination request:', { page, limit });

    try {
      const response = await this.getAll(queryParams);
      console.log('Pagination response from backend:', response);
      return response;
    } catch (error) {
      console.error('Error fetching paginated estimates:', error);
      throw error;
    }
  }
  
  /**
   * Mark estimate as sent
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data with updated estimate
   */
  async markEstimateAsSent(id) {
    try {
      if (!id || id === 'undefined' || id === 'null') {
        throw new Error(`Invalid ID provided: ${id}`);
      }

      return await apiService.post(`${this.resourceUrl}/${id}/mark-sent`);
    } catch (error) {
      this._handleError(error);
    }
  }

  /**
   * Mark estimate as accepted
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data with updated estimate
   */
  async markEstimateAsAccepted(id) {
    try {
      if (!id || id === 'undefined' || id === 'null') {
        throw new Error(`Invalid ID provided: ${id}`);
      }

      return await apiService.post(`${this.resourceUrl}/${id}/mark-accepted`);
    } catch (error) {
      this._handleError(error);
    }
  }

  /**
   * Mark estimate as rejected
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data with updated estimate
   */
  async markEstimateAsRejected(id) {
    try {
      if (!id || id === 'undefined' || id === 'null') {
        throw new Error(`Invalid ID provided: ${id}`);
      }

      return await apiService.post(`${this.resourceUrl}/${id}/mark-rejected`);
    } catch (error) {
      this._handleError(error);
    }
  }

  /**
   * Convert estimate to invoice
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data with created invoice
   */
  async convertToInvoice(id) {
    try {
      if (!id || id === 'undefined' || id === 'null') {
        throw new Error(`Invalid ID provided: ${id}`);
      }

      return await apiService.post(`${this.resourceUrl}/${id}/convert`);
    } catch (error) {
      this._handleError(error);
    }
  }

  /**
   * Generate estimate PDF
   * @param {string} id - Estimate ID
   * @returns {Promise} PDF file as blob
   */
  async generatePdf(id) {
    try {
      if (!id || id === 'undefined' || id === 'null') {
        throw new Error(`Invalid ID provided: ${id}`);
      }

      return await apiService.get(`${this.resourceUrl}/${id}/pdf`, { responseType: 'blob' });
    } catch (error) {
      this._handleError(error);
    }
  }

  /**
   * Get estimate PDF
   * @param {string} estimateId - Estimate ID
   * @returns {Promise<Blob>} PDF file as blob
   */
  async getEstimatePdf(estimateId) {
    try {
      if (!estimateId || estimateId === 'undefined' || estimateId === 'null') {
        throw new Error(`Invalid ID provided: ${estimateId}`);
      }

      const response = await apiService.get(`${this.resourceUrl}/${estimateId}/pdf`, {
        responseType: 'blob',
        validateStatus: status => status === 200 // Only treat 200 as success
      });

      // Verify that we got a PDF
      if (response instanceof Blob && response.type === 'application/pdf') {
        return response;
      } else {
        // If we got a blob but it's not a PDF (might be an error message as text/html)
        if (response instanceof Blob) {
          // Try to convert blob to text to see the error message
          const text = await response.text();
          throw new Error(`Received non-PDF response: ${text || 'Unknown error'}`);
        }
        throw new Error('Invalid response format when retrieving PDF');
      }
    } catch (error) {
      this._handleError(error);
    }
  }

  /**
   * Get the next available estimate number
   * @returns {Promise} Response data with { estimateNumber: '...' }
   */
  async getNextEstimateNumber() {
    try {
      return await apiService.get(`${this.resourceUrl}/next-number`);
    } catch (error) {
      this._handleError(error);
    }
  }
}

export default new EstimateService();