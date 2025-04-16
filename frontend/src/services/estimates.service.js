import apiService from './api.service';

/**
 * Service for handling estimate operations
 */
class EstimatesService {
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

    return apiService.get(`/api/estimates?${queryParams.toString()}`);
  }

  /**
   * Create a new estimate
   * @param {Object} estimateData - Estimate data
   * @returns {Promise} Response data with created estimate
   */
  async createEstimate(estimateData) {
    return apiService.post('/api/estimates', estimateData);
  }

  /**
   * Get estimate details
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data with estimate details
   */
  async getEstimate(id) {
    return apiService.get(`/api/estimates/${id}`);
  }

  /**
   * Update an estimate
   * @param {string} id - Estimate ID
   * @param {Object} estimateData - Updated estimate data
   * @returns {Promise} Response data with updated estimate
   */
  async updateEstimate(id, estimateData) {
    return apiService.put(`/api/estimates/${id}`, estimateData);
  }

  /**
   * Delete an estimate
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data
   */
  async deleteEstimate(id) {
    return apiService.delete(`/api/estimates/${id}`);
  }

  /**
   * Mark estimate as sent
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data with updated estimate
   */
  async markEstimateAsSent(id) {
    return apiService.post(`/api/estimates/${id}/mark-sent`);
  }

  /**
   * Mark estimate as accepted
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data with updated estimate
   */
  async markEstimateAsAccepted(id) {
    return apiService.post(`/api/estimates/${id}/mark-accepted`);
  }

  /**
   * Mark estimate as rejected
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data with updated estimate
   */
  async markEstimateAsRejected(id) {
    return apiService.post(`/api/estimates/${id}/mark-rejected`);
  }

  /**
   * Convert estimate to invoice
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data with created invoice
   */
  async convertToInvoice(id) {
    return apiService.post(`/api/estimates/${id}/convert`);
  }

  /**
   * Generate estimate PDF
   * @param {string} id - Estimate ID
   * @returns {Promise} PDF file as blob
   */
  async generatePdf(id) {
    return apiService.get(`/api/estimates/${id}/pdf`, { responseType: 'blob' });
  }

  /**
   * Get estimate PDF
   * @param {string} estimateId - Estimate ID
   * @returns {Promise<Blob>} PDF file as blob
   */
  async getEstimatePdf(estimateId) {
    try {
      const response = await apiService.get(`/api/estimates/${estimateId}/pdf`, {
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
      console.error('Error retrieving estimate PDF:', error);
      throw error;
    }
  }

  /**
   * Get the next available estimate number
   * @returns {Promise} Response data with { estimateNumber: '...' }
   */
  async getNextEstimateNumber() {
    return apiService.get('/api/estimates/next-number');
  }

  /**
   * Calls the backend to analyze the project scope using the LLM.
   * @param {object} payload - Object containing 'description', optional 'targetPrice', and optional 'assessmentData'.
   * @returns {Promise} Response data from the analysis endpoint.
   */
  async analyzeScope(payload) {
    const TIMEOUT_MS = 60000; // 60 seconds

    try {
      // Ensure payload is structured correctly
      const dataToSend = {
        description: payload.description,
        ...(payload.targetPrice !== undefined && { targetPrice: payload.targetPrice }),
        ...(payload.assessmentData && { assessmentData: payload.assessmentData }),
        ...(payload.assessmentOptions && { assessmentOptions: payload.assessmentOptions })
      };

      // Create an abort controller for timeout handling
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), TIMEOUT_MS);

      const response = await apiService.post('/api/estimates/llm/analyze', dataToSend, {
        signal: controller.signal,
        timeout: TIMEOUT_MS
      });

      clearTimeout(timeoutId);
      return response;
    } catch (error) {
      if (error.name === 'AbortError' || error.code === 'ECONNABORTED') {
        // Handle timeout specifically
        console.error('LLM request timed out');
        return {
          success: false,
          message: 'Request timed out. The AI service is taking longer than expected to respond.'
        };
      }
      throw error;
    }
  }

  /**
   * Get assessment data for a project
   * @param {string} projectId - Project ID to get assessment data for
   * @returns {Promise} Response data with assessment information
   */
  async getAssessmentData(projectId) {
    return apiService.get(`/api/estimates/llm/assessment/${projectId}`);
  }

  /**
   * Submits user-provided measurements and answers to the backend.
   * @param {object} payload - Object containing 'measurements', 'answers', 'originalDescription', 'analysisResult'.
   * @returns {Promise} Response data from the clarification endpoint.
   */
  async submitClarifications(payload) {
    // Ensure payload contains the necessary fields
    const dataToSend = {
      measurements: payload.measurements || {},
      answers: payload.answers || {},
      originalDescription: payload.originalDescription || '',
      analysisResult: payload.analysisResult || {} // Send back the original analysis for context
    };
    return apiService.post('/api/estimates/llm/clarify', dataToSend);
  }

  /**
   * Match LLM-generated line items to actual products in catalog.
   * @param {Array} lineItems - Array of line items to match.
   * @returns {Promise} Response data with matched products.
   */
  async matchProductsToLineItems(lineItems) {
    return apiService.post('/api/estimates/llm/match-products', { lineItems });
  }

  /**
   * Create new products from unmatched line items.
   * @param {Array} newProducts - Array of new product data to create.
   * @returns {Promise} Response data with created products.
   */
  async createProductsFromLineItems(newProducts) {
    return apiService.post('/api/estimates/llm/create-products', { newProducts });
  }

  /**
   * Finalize an estimate from matched products and line items.
   * @param {Object} finalData - Object containing finalized estimate data.
   * @returns {Promise} Response data with created estimate.
   */
  async finalizeEstimateFromMatches(finalData) {
    return apiService.post('/api/estimates/llm/finalize', finalData);
  }

  /**
   * Generate estimate directly from assessment data with enhanced parameters.
   * @param {Object} assessment - Assessment data object
   * @param {Object} options - Options object with aggressiveness and mode parameters
   * @param {number} options.aggressiveness - Value between 0-1 controlling estimation aggressiveness (default: 0.6)
   * @param {string} options.mode - Estimation approach mode (default: 'replace-focused')
   * @param {boolean} options.debug - Include debug information in response (default: false)
   * @returns {Promise} Response data with estimate line items and source map
   */
  async generateFromAssessment(assessment, options = {}) {
    const payload = {
      assessment,
      options: {
        aggressiveness: options.aggressiveness !== undefined ? options.aggressiveness : 0.6,
        mode: options.mode || 'replace-focused',
        debug: options.debug === true,
        includeBidirectionalLinks: true // Always include source mapping for bidirectional linking
      }
    };

    return apiService.post('/api/estimates/llm/generate', payload);
  }

  /**
   * Process an external LLM response to generate estimate line items
   * @param {Object} payload - Object containing responseText and optional assessmentData
   * @returns {Promise} Response data with parsed line items
   */
  async processExternalLlmResponse(payload) {
    return apiService.post('/api/estimates/llm/process-external', payload);
  }

  /**
   * Get source map for bidirectional linking between assessment and estimate items
   * @param {string} estimateId - Estimate ID to get source map for
   * @returns {Promise} Response data with source map
   */
  async getEstimateSourceMap(estimateId) {
    return apiService.get(`/api/estimates/${estimateId}/source-map`);
  }

  /**
   * Save an estimate with source mapping for bidirectional linking
   * @param {Object} estimateData - Estimate data with line items and sourceMap
   * @returns {Promise} Response data with created estimate
   */
  async saveEstimateWithSourceMap(estimateData) {
    return apiService.post('/api/estimates/with-source-map', estimateData);
  }
}

export default new EstimatesService();