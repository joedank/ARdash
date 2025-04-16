import apiService from './api.service';

/**
 * Service for handling invoice operations
 */
class InvoicesService {
  /**
   * List invoices with optional filters
   * @param {Object} filters - Query filters
   * @param {number} page - Page number (0-based)
   * @param {number} limit - Items per page
   * @returns {Promise} Response data with paginated invoices
   */
  async listInvoices(filters = {}, page = 0, limit = 10) {
    const queryParams = new URLSearchParams();

    // Add filters to query params
    if (filters.status) queryParams.append('status', filters.status);
    if (filters.clientId) queryParams.append('clientId', filters.clientId);
    if (filters.dateFrom) queryParams.append('dateFrom', filters.dateFrom);
    if (filters.dateTo) queryParams.append('dateTo', filters.dateTo);

    // Add pagination
    queryParams.append('page', page);
    queryParams.append('limit', limit);

    return apiService.get(`/api/invoices?${queryParams.toString()}`);
  }

  /**
   * Create a new invoice
   * @param {Object} invoiceData - Invoice data
   * @returns {Promise} Response data with created invoice
   */
  async createInvoice(invoiceData) {
    console.log('In invoices.service.js - Creating invoice with data:', invoiceData);
    return apiService.post('/api/invoices', invoiceData);
  }

  /**
   * Get invoice details
   * @param {string} id - Invoice ID
   * @returns {Promise} Response data with invoice details
   */
  async getInvoice(id) {
    return apiService.get(`/api/invoices/${id}`);
  }

  /**
   * Update an invoice
   * @param {string} id - Invoice ID
   * @param {Object} invoiceData - Updated invoice data
   * @returns {Promise} Response data with updated invoice
   */
  async updateInvoice(id, invoiceData) {
    return apiService.put(`/api/invoices/${id}`, invoiceData);
  }

  /**
   * Delete an invoice
   * @param {string} id - Invoice ID
   * @returns {Promise} Response data
   */
  async deleteInvoice(id) {
    return apiService.delete(`/api/invoices/${id}`);
  }

  /**
   * Mark invoice as sent
   * @param {string} id - Invoice ID
   * @returns {Promise} Response data with updated invoice
   */
  async markInvoiceAsSent(id) {
    return apiService.post(`/api/invoices/${id}/mark-sent`);
  }

  /**
   * Mark invoice as viewed
   * @param {string} id - Invoice ID
   * @returns {Promise} Response data with updated invoice
   */
  async markInvoiceAsViewed(id) {
    return apiService.post(`/api/invoices/${id}/mark-viewed`);
  }

  /**
   * Add payment to invoice
   * @param {string} id - Invoice ID
   * @param {Object} paymentData - Payment data
   * @returns {Promise} Response data with updated invoice
   */
  async addPayment(id, paymentData) {
    return apiService.post(`/api/invoices/${id}/payments`, paymentData);
  }

  /**
   * Get invoice PDF
   * @param {string} invoiceId - Invoice ID
   * @returns {Promise<Blob>} PDF file as blob
   */
  async getInvoicePdf(invoiceId) {
    try {
      const response = await apiService.get(`/api/invoices/${invoiceId}/pdf`, {
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
   * @returns {Promise} Response data with next invoice number
   */
  async getNextInvoiceNumber() {
    return apiService.get('/api/invoices/next-number');
  }
}

export default new InvoicesService();
