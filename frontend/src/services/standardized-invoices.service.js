import BaseService from './base.service';
import api from './api.service';
import { standardizeResponse as apiStandardizeResponse, standardizeRequest as apiStandardizeRequest } from '../utils/apiAdapter';

/**
 * Standardized Invoices service for handling invoice-related API calls
 * with consistent field naming and error handling
 */
class StandardizedInvoicesService extends BaseService {
  constructor() {
    super('/invoices');
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
   * List invoices with optional filters
   * @param {Object} filters - Query filters
   * @param {number} page - Page number (0-based)
   * @param {number} limit - Items per page
   * @returns {Promise<Object>} Standardized response with paginated invoices
   */
  async listInvoices(filters = {}, page = 0, limit = 10) {
    try {
      const queryParams = new URLSearchParams();
      
      // Add filters to query params
      if (filters.status) queryParams.append('status', filters.status);
      if (filters.clientId) queryParams.append('client_id', filters.clientId);
      if (filters.dateFrom) queryParams.append('date_from', filters.dateFrom);
      if (filters.dateTo) queryParams.append('date_to', filters.dateTo);
      
      // Add pagination
      queryParams.append('page', page);
      queryParams.append('limit', limit);
      
      const response = await this.api.get(`${this.resourceUrl}?${queryParams.toString()}`);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error('List invoices error:', error);
      throw error;
    }
  }

  /**
   * Create a new invoice
   * @param {Object} invoiceData - Invoice data
   * @returns {Promise<Object>} Standardized response with created invoice
   */
  async createInvoice(invoiceData) {
    try {
      console.log('Before standardization:', invoiceData);
      const requestData = apiStandardizeRequest(invoiceData); // Use imported function
      console.log('After standardization:', requestData);
      
      const response = await this.api.post(this.resourceUrl, requestData);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error('Create invoice error:', error);
      throw error;
    }
  }

  /**
   * Get invoice details
   * @param {string} id - Invoice ID
   * @returns {Promise<Object>} Standardized response with invoice details
   */
  async getInvoice(id) {
    try {
      const response = await this.api.get(`${this.resourceUrl}/${id}`);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Get invoice error for ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Update an invoice
   * @param {string} id - Invoice ID
   * @param {Object} invoiceData - Updated invoice data
   * @returns {Promise<Object>} Standardized response with updated invoice
   */
  async updateInvoice(id, invoiceData) {
    try {
      const requestData = apiStandardizeRequest(invoiceData); // Use imported function
      const response = await this.api.put(`${this.resourceUrl}/${id}`, requestData);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Update invoice error for ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Delete an invoice
   * @param {string} id - Invoice ID
   * @returns {Promise<Object>} Standardized response
   */
  async deleteInvoice(id) {
    try {
      const response = await this.api.delete(`${this.resourceUrl}/${id}`);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Delete invoice error for ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Mark invoice as sent
   * @param {string} id - Invoice ID
   * @returns {Promise<Object>} Standardized response with updated invoice
   */
  async markInvoiceAsSent(id) {
    try {
      const response = await this.api.post(`${this.resourceUrl}/${id}/mark-sent`);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Mark invoice as sent error for ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Mark invoice as viewed
   * @param {string} id - Invoice ID
   * @returns {Promise<Object>} Standardized response with updated invoice
   */
  async markInvoiceAsViewed(id) {
    try {
      const response = await this.api.post(`${this.resourceUrl}/${id}/mark-viewed`);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Mark invoice as viewed error for ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Add payment to invoice
   * @param {string} id - Invoice ID
   * @param {Object} paymentData - Payment data
   * @returns {Promise<Object>} Standardized response with updated invoice
   */
  async addPayment(id, paymentData) {
    try {
      const requestData = apiStandardizeRequest(paymentData); // Use imported function
      const response = await this.api.post(`${this.resourceUrl}/${id}/payments`, requestData);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Add payment error for invoice ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Get invoice PDF
   * @param {string} invoiceId - Invoice ID
   * @returns {Promise<Blob>} PDF file as blob
   */
  async getInvoicePdf(invoiceId) {
    try {
      const response = await this.api.get(`${this.resourceUrl}/${invoiceId}/pdf`, { 
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
      console.error('Error retrieving invoice PDF:', error);
      throw error;
    }
  }

  /**
   * Get the next available invoice number
   * @returns {Promise<Object>} Standardized response with next invoice number
   */
  async getNextInvoiceNumber() {
    try {
      const response = await this.api.get(`${this.resourceUrl}/next-number`);
      return this.standardizeResponse(response);
    } catch (error) {
      console.error('Get next invoice number error:', error);
      throw error;
    }
  }
}

const standardizedInvoicesService = new StandardizedInvoicesService();

export { standardizedInvoicesService };
export default standardizedInvoicesService;