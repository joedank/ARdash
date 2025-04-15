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
      
      const response = await apiService.post(`${this.resourceUrl}/llm/analyze`, dataToSend, {
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
      this._handleError(error);
    }
  }
  
  /**
   * Get assessment data for a project
   * @param {string} projectId - Project ID to get assessment data for
   * @returns {Promise} Response data with assessment information
   */
  async getAssessmentData(projectId) {
    try {
      if (!projectId || projectId === 'undefined' || projectId === 'null') {
        throw new Error(`Invalid project ID provided: ${projectId}`);
      }
      
      return await apiService.get(`${this.resourceUrl}/llm/assessment/${projectId}`);
    } catch (error) {
      this._handleError(error);
    }
  }

  /**
   * Submits user-provided measurements and answers to the backend.
   * @param {object} payload - Object containing 'measurements', 'answers', 'originalDescription', 'analysisResult'.
   * @returns {Promise} Response data from the clarification endpoint.
   */
  async submitClarifications(payload) {
    try {
      // Ensure payload contains the necessary fields
      const dataToSend = {
        measurements: payload.measurements || {},
        answers: payload.answers || {},
        originalDescription: payload.originalDescription || '',
        analysisResult: payload.analysisResult || {} // Send back the original analysis for context
      };
      
      return await apiService.post(`${this.resourceUrl}/llm/clarify`, dataToSend);
    } catch (error) {
      this._handleError(error);
    }
  }

  /**
   * Match LLM-generated line items to actual products in catalog.
   * @param {Array} lineItems - Array of line items to match.
   * @returns {Promise} Response data with matched products.
   */
  async matchProductsToLineItems(lineItems) {
    try {
      return await apiService.post(`${this.resourceUrl}/llm/match-products`, { lineItems });
    } catch (error) {
      this._handleError(error);
    }
  }

  /**
   * Create new products from unmatched line items.
   * @param {Array} newProducts - Array of new product data to create.
   * @returns {Promise} Response data with created products.
   */
  async createProductsFromLineItems(newProducts) {
    try {
      return await apiService.post(`${this.resourceUrl}/llm/create-products`, { newProducts });
    } catch (error) {
      this._handleError(error);
    }
  }

  /**
   * Finalize an estimate from matched products and line items.
   * @param {Object} finalData - Object containing finalized estimate data.
   * @returns {Promise} Response data with created estimate.
   */
  async finalizeEstimateFromMatches(finalData) {
    try {
      return await apiService.post(`${this.resourceUrl}/llm/finalize`, finalData);
    } catch (error) {
      this._handleError(error);
    }
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
    try {
      const payload = {
        assessment,
        options: {
          aggressiveness: options.aggressiveness !== undefined ? options.aggressiveness : 0.6,
          mode: options.mode || 'replace-focused',
          debug: options.debug === true,
          includeBidirectionalLinks: true // Always include source mapping for bidirectional linking
        }
      };
      
      return await apiService.post(`${this.resourceUrl}/llm/generate`, payload);
    } catch (error) {
      this._handleError(error);
    }
  }

  /**
   * Process an external LLM response to generate estimate line items
   * @param {Object} payload - Object containing responseText and optional assessmentData
   * @returns {Promise} Response data with parsed line items
   */
  async processExternalLlmResponse(payload) {
    try {
      return await apiService.post(`${this.resourceUrl}/llm/process-external`, payload);
    } catch (error) {
      this._handleError(error);
    }
  }

  /**
   * Get source map for bidirectional linking between assessment and estimate items
   * @param {string} estimateId - Estimate ID to get source map for
   * @returns {Promise} Response data with source map
   */
  async getEstimateSourceMap(estimateId) {
    try {
      if (!estimateId || estimateId === 'undefined' || estimateId === 'null') {
        throw new Error(`Invalid estimate ID provided: ${estimateId}`);
      }
      
      return await apiService.get(`${this.resourceUrl}/${estimateId}/source-map`);
    } catch (error) {
      this._handleError(error);
    }
  }

  /**
   * Save an estimate with source mapping for bidirectional linking
   * @param {Object} estimateData - Estimate data with line items and sourceMap
   * @returns {Promise} Response data with created estimate
   */
  async saveEstimateWithSourceMap(estimateData) {
    try {
      return await apiService.post(`${this.resourceUrl}/with-source-map`, estimateData);
    } catch (error) {
      this._handleError(error);
    }
  }
}

export default new EstimateService();
