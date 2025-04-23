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
    super('/api/estimates');
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

      console.log(`Fetching assessment data for project ID: ${projectId}`);

      // Flag to track attempt success
      let primarySucceeded = false;
      let fallbackSucceeded = false;
      let response = null;
      let error = null;

      // Try primary endpoint first - explicitly include /api prefix for production
      try {
        // Explicitly include /api prefix to ensure correct routing
        const primaryEndpoint = `/api/estimates/llm/assessment/${projectId}`;
        console.log(`Trying primary endpoint: ${primaryEndpoint}`);

        response = await apiService.get(primaryEndpoint);
        primarySucceeded = true;
        console.log('Successfully fetched data from primary endpoint');
      } catch (primaryError) {
        console.warn(`Primary endpoint failed:`, primaryError);
        error = primaryError;
      }

      // If primary failed, try the legacy endpoint
      if (!primarySucceeded) {
        try {
          // For the legacy endpoint, explicitly include /api prefix
          const fallbackEndpoint = `/api/assessments/for-project/${projectId}`;
          console.log(`Trying fallback endpoint: ${fallbackEndpoint}`);

          response = await apiService.get(fallbackEndpoint);
          fallbackSucceeded = true;
          console.log('Successfully fetched data from fallback endpoint');
        } catch (fallbackError) {
          console.error(`All endpoints failed. Cannot fetch assessment data.`);
          error = fallbackError;
        }
      }

      // If all attempts failed, throw the last error
      if (!primarySucceeded && !fallbackSucceeded) {
        throw error || new Error('Failed to fetch assessment data from any endpoint');
      }

      // Process and return the response
      return this.standardizeResponse(response);
    } catch (error) {
      console.error(`Error in getAssessmentData for project ${projectId}:`, error);
      return {
        success: false,
        message: error.message || 'Failed to fetch assessment data',
        data: null
      };
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
   * @param {Object} payload - Assessment payload which may include both projectId and assessment
   * @param {string} payload.projectId - The explicit project ID for the assessment
   * @param {Object} payload.assessment - The assessment data object
   * @param {Object} payload.options - Options for generation (aggressiveness, mode, etc.)
   * @param {Object} options - (Optional) Legacy options object for backward compatibility
   * @returns {Promise} Response data with estimate line items and source map
   */
  async generateFromAssessment(payload, options = {}) {
    try {
      console.log('Payload received in generateFromAssessment:', JSON.stringify(payload, null, 2));

      // Handle both new payload format and legacy format
      let finalPayload;

      // Check if this is the new payload format (object with projectId, assessment, and options)
      if (payload && payload.projectId && payload.assessment) {
        console.log('Using new payload format with explicit projectId');
        finalPayload = payload;
      }
      // Legacy format: assessment object passed directly with separate options
      else {
        console.log('Using legacy payload format, extracting projectId from assessment');
        const assessment = payload; // In legacy format, payload is the assessment object

        // Extract project ID from assessment object using the same logic as before
        let projectId = null;

        // Try to find project ID in different possible locations
        if (assessment) {
          // Direct project ID
          if (assessment.projectId) {
            projectId = assessment.projectId;
            console.log('Found projectId directly on assessment object:', projectId);
          }
          // Project ID in project object
          else if (assessment.project && assessment.project.id) {
            projectId = assessment.project.id;
            console.log('Found projectId in assessment.project.id:', projectId);
          }
          // Project ID in project object with snake_case
          else if (assessment.project && assessment.project.project_id) {
            projectId = assessment.project.project_id;
            console.log('Found projectId in assessment.project.project_id:', projectId);
          }
          // ID directly on assessment object (if assessment itself is a project)
          else if (assessment.id) {
            projectId = assessment.id;
            console.log('Using assessment.id as projectId:', projectId);
          }
          // Try to find project ID in client object
          else if (assessment.client && assessment.client.projectId) {
            projectId = assessment.client.projectId;
            console.log('Found projectId in assessment.client.projectId:', projectId);
          }
          // Try to find project ID in client object with snake_case
          else if (assessment.client && assessment.client.project_id) {
            projectId = assessment.client.project_id;
            console.log('Found projectId in assessment.client.project_id:', projectId);
          }
          // Try to find project ID in assessmentId
          else if (assessment.assessmentId) {
            projectId = assessment.assessmentId;
            console.log('Using assessment.assessmentId as projectId:', projectId);
          }
        }

        // If still no project ID, try to extract it from the URL
        if (!projectId) {
          const currentUrl = window.location.href;
          const urlMatch = currentUrl.match(/\/projects\/([0-9a-f-]+)/);
          if (urlMatch && urlMatch[1]) {
            projectId = urlMatch[1];
            console.log('Extracted projectId from URL:', projectId);
          }
        }

        if (!projectId) {
          console.error('No project ID found in assessment data', assessment);
          throw new Error('Project ID is required but not found in assessment data');
        }

        // Validate projectId before constructing the payload
        const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
        if (!projectId || typeof projectId !== 'string' || !uuidRegex.test(projectId)) {
          // Use toast if available, otherwise fallback to alert/console
          if (typeof window !== 'undefined' && window.$toast) {
            window.$toast.error(`Invalid or missing project ID: ${projectId || '(none)'}. Please select a valid project before generating an estimate.`);
          } else if (typeof window !== 'undefined' && window.Vue && window.Vue.$toast) {
            window.Vue.$toast.error(`Invalid or missing project ID: ${projectId || '(none)'}. Please select a valid project before generating an estimate.`);
          } else if (typeof alert !== 'undefined') {
            alert(`Invalid or missing project ID: ${projectId || '(none)'}. Please select a valid project before generating an estimate.`);
          } else {
            console.error(`Invalid or missing project ID: ${projectId || '(none)'}. Please select a valid project before generating an estimate.`);
          }
          throw new Error(`Invalid or missing project ID: ${projectId || '(none)'}. Please select a valid project before generating an estimate.`);
        }
        // Construct the payload in the expected format
        finalPayload = {
          projectId, // Include the extracted project ID
          assessment, // Still include the full assessment for backward compatibility
          options: {
            aggressiveness: options.aggressiveness !== undefined ? options.aggressiveness : 0.6,
            mode: options.mode || 'replace-focused',
            debug: options.debug === true,
            includeBidirectionalLinks: true // Always include source mapping for bidirectional linking
          }
        };
      }

      // Ensure options are always properly set
      if (!finalPayload.options) {
        finalPayload.options = {
          aggressiveness: 0.6,
          mode: 'replace-focused',
          debug: false,
          includeBidirectionalLinks: true
        };
      }

      // Explicitly include /api prefix to ensure correct routing
      const endpoint = `/api/estimates/llm/generate`;

      // Log the final endpoint being called
      console.log('Sending estimate generation payload to endpoint:', endpoint);

      // Ensure the payload is properly formatted for the backend
      const formattedPayload = {
        projectId: finalPayload.projectId,
        assessment: finalPayload.assessment,
        options: finalPayload.options
      };

      // Log the formatted payload for debugging
      console.log('Formatted payload for backend:', JSON.stringify(formattedPayload, null, 2));

      // Make the API call with the properly formatted payload
      const response = await apiService.post(endpoint, formattedPayload);

      // Log the response for debugging
      console.log('Response from estimate generation:', response);

      // Return the standardized response
      return this.standardizeResponse(response);
    } catch (error) {
      console.error('Error in generateFromAssessment:', error);
      return {
        success: false,
        message: error.message || 'Failed to generate estimate from assessment',
        data: []
      };
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
