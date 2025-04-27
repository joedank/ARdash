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

    return apiService.get(`/estimates?${queryParams.toString()}`);
  }

  /**
   * Create a new estimate
   * @param {Object} estimateData - Estimate data
   * @returns {Promise} Response data with created estimate
   */
  async createEstimate(estimateData) {
    return apiService.post('/estimates', estimateData);
  }

  /**
   * Get estimate details
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data with estimate details
   */
  async getEstimate(id) {
    return apiService.get(`/estimates/${id}`);
  }

  /**
   * Update an estimate
   * @param {string} id - Estimate ID
   * @param {Object} estimateData - Updated estimate data
   * @returns {Promise} Response data with updated estimate
   */
  async updateEstimate(id, estimateData) {
    return apiService.put(`/estimates/${id}`, estimateData);
  }

  /**
   * Delete an estimate
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data
   */
  async deleteEstimate(id) {
    return apiService.delete(`/estimates/${id}`);
  }

  /**
   * Mark estimate as sent
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data with updated estimate
   */
  async markEstimateAsSent(id) {
    return apiService.post(`/estimates/${id}/mark-sent`);
  }

  /**
   * Mark estimate as accepted
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data with updated estimate
   */
  async markEstimateAsAccepted(id) {
    return apiService.post(`/estimates/${id}/mark-accepted`);
  }

  /**
   * Mark estimate as rejected
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data with updated estimate
   */
  async markEstimateAsRejected(id) {
    return apiService.post(`/estimates/${id}/mark-rejected`);
  }

  /**
   * Convert estimate to invoice
   * @param {string} id - Estimate ID
   * @returns {Promise} Response data with created invoice
   */
  async convertToInvoice(id) {
    return apiService.post(`/estimates/${id}/convert`);
  }

  /**
   * Generate estimate PDF
   * @param {string} id - Estimate ID
   * @returns {Promise} PDF file as blob
   */
  async generatePdf(id) {
    return apiService.get(`/estimates/${id}/pdf`, { responseType: 'blob' });
  }

  /**
   * Get estimate PDF
   * @param {string} estimateId - Estimate ID
   * @returns {Promise<Blob>} PDF file as blob
   */
  async getEstimatePdf(estimateId) {
    try {
      const response = await apiService.get(`/estimates/${estimateId}/pdf`, {
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
    return apiService.get('/estimates/next-number');
  }

  /**
   * Calls the backend to analyze the project scope using the LLM.
   * @param {object} payload - Object containing 'description', optional 'targetPrice', and optional 'assessmentData'.
   * @returns {Promise} Response data from the analysis endpoint.
   */
  async analyzeScope(payload) {
    const TIMEOUT_MS = 60000; // 60 seconds

    try {
      // Log the assessment ID we're using
      console.log('Using assessment data:', !!payload.assessmentData);
      
      // Create a new object with all required properties
      const assessmentWithProjectId = { ...payload.assessmentData };
      
      // Ensure projectId is set at root level if available
      if (payload.assessmentData && payload.assessmentData.projectId) {
        assessmentWithProjectId.projectId = payload.assessmentData.projectId;
      }
      
      // Ensure project object exists with correct ID
      if (payload.assessmentData && payload.assessmentData.projectId) {
        assessmentWithProjectId.project = assessmentWithProjectId.project || {};
        assessmentWithProjectId.project.id = payload.assessmentData.projectId;
        // Also include project_id property for backward compatibility
        assessmentWithProjectId.project.project_id = payload.assessmentData.projectId;
      }
      
      // Format measurements in a more accessible structure for the LLM
      if (payload.assessmentData && payload.assessmentData.measurements) {
        assessmentWithProjectId.formattedMeasurements = payload.assessmentData.measurements.map(m => ({
          name: m.label,
          value: m.value,
          unit: m.unit,
          type: m.measurementType,
          location: m.location || ''
        }));
      }
      
      // Format conditions similarly
      if (payload.assessmentData && payload.assessmentData.conditions) {
        assessmentWithProjectId.formattedConditions = payload.assessmentData.conditions.map(c => ({
          issue: c.issue,
          severity: c.severity,
          location: c.location,
          notes: c.notes
        }));
      }
      
      // Prepare the complete payload similar to working implementation
      const enhancedPayload = {
        description: payload.description,
        ...(payload.targetPrice !== undefined && { targetPrice: payload.targetPrice }),
        projectId: payload.assessmentData?.projectId,
        assessment: assessmentWithProjectId,
        options: payload.assessmentOptions || {}
      };
      
      console.log('Enhanced payload structure:', JSON.stringify(enhancedPayload, null, 2));
      
      // Create an abort controller for timeout handling
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), TIMEOUT_MS);

      console.log('Calling API: /estimates/llm/analyze...');
      const startTime = new Date().getTime();
      
      const response = await apiService.post('/estimates/llm/analyze', enhancedPayload, {
        signal: controller.signal,
        timeout: TIMEOUT_MS
      });

      const endTime = new Date().getTime();
      console.log(`API response received after ${(endTime - startTime)/1000}s`);
      console.log('ANALYZE SCOPE - Response:', JSON.stringify(response, null, 2));

      clearTimeout(timeoutId);
      
      // Log detailed information about the response
      if (response && response.data) {
        console.log('API Response Structure:', {
          fullResponse: response,
          dataType: typeof response.data,
          isArray: Array.isArray(response.data),
          keys: response.data ? Object.keys(response.data) : 'N/A',
          requiredServices: response.data.required_services
        });
        
        // Pre-fill measurement values from assessment data if available
        if (response.data.required_measurements && 
            payload.assessmentData && 
            payload.assessmentData.measurements) {
              
          response.data.prefilled_measurements = {};
          
          response.data.required_measurements.forEach(measName => {
            const match = payload.assessmentData.measurements.find(m => 
              m.label.toLowerCase().includes(measName.toLowerCase().replace(/_/g, ' ')) ||
              (m.label.toLowerCase().includes('subfloor') && measName.toLowerCase().includes('subfloor')) ||
              (m.label.toLowerCase().includes('cabinet') && measName.toLowerCase().includes('cabinet'))
            );
            
            if (match) {
              response.data.prefilled_measurements[measName] = {
                value: match.value,
                unit: match.unit
              };
            }
          });
        }
        
        console.log('ANALYZE SCOPE - Response Data Structure:');
        console.log('- Has repair_type:', !!response.data.repair_type);
        console.log('- Has required_services:', !!response.data.required_services);
        console.log('- required_services is array:', Array.isArray(response.data.required_services));
        if (Array.isArray(response.data.required_services)) {
          console.log('- required_services length:', response.data.required_services.length);
          console.log('- required_services contents:', response.data.required_services);
        }
      } else {
        console.log('ANALYZE SCOPE - Response has unexpected format');
      }

      return {
        success: true,
        data: response.data,
        message: response.message
      };
    } catch (error) {
      if (error.name === 'AbortError' || error.code === 'ECONNABORTED') {
        // Handle timeout specifically
        console.error('LLM request timed out');
        return {
          success: false,
          message: 'Request timed out. The AI service is taking longer than expected to respond.'
        };
      }

      console.error('Error analyzing project scope:', error);
      console.log('Error details:', {
        name: error.name,
        message: error.message,
        response: error.response ? {
          status: error.response.status,
          statusText: error.response.statusText,
          data: error.response.data
        } : 'No response data'
      });
      
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to analyze project scope',
        error
      };
    }
  }

  /**
   * Get assessment data for a project
   * @param {string} projectId - Project ID to get assessment data for
   * @returns {Promise} Response data with assessment information
   */
  async getAssessmentData(projectId) {
    return apiService.get(`/estimates/llm/assessment/${projectId}`);
  }

  /**
   * Generate estimate based on measurements and answers
   * @param {object} payload - Object containing 'measurements', 'answers', 'originalDescription', 'analysisResult'.
   * @returns {Promise} Response data with generated line items
   */
  async generateEstimate(payload) {
    const TIMEOUT_MS = 90000; // 90 seconds - generation can take longer

    try {
      // Ensure payload contains the necessary fields
      const dataToSend = {
        measurements: payload.measurements || {},
        answers: payload.answers || {},
        originalDescription: payload.originalDescription || '',
        analysisResult: payload.analysisResult || {}, // Send back the original analysis for context
        ...(payload.targetPrice !== undefined && { targetPrice: payload.targetPrice }),
        ...(payload.assessmentData && { assessmentData: payload.assessmentData }),
        ...(payload.assessmentOptions && { assessmentOptions: payload.assessmentOptions })
      };

      // Create an abort controller for timeout handling
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), TIMEOUT_MS);

      const response = await apiService.post('/estimates/llm/generate', dataToSend, {
        signal: controller.signal,
        timeout: TIMEOUT_MS
      });

      clearTimeout(timeoutId);
      return {
        success: true,
        data: response.data,
        message: response.message
      };
    } catch (error) {
      if (error.name === 'AbortError' || error.code === 'ECONNABORTED') {
        // Handle timeout specifically
        console.error('LLM request timed out');
        return {
          success: false,
          message: 'Request timed out. The AI service is taking longer than expected to respond.'
        };
      }

      console.error('Error generating estimate:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to generate estimate',
        error
      };
    }
  }

  /**
   * Match LLM-generated line items to actual products in catalog.
   * @param {Array} lineItems - Array of line items to match.
   * @returns {Promise} Response data with matched products.
   */
  async matchProductsToLineItems(lineItems) {
    return apiService.post('/estimates/llm/match-products', { lineItems });
  }

  /**
   * Create new products from unmatched line items.
   * @param {Array} newProducts - Array of new product data to create.
   * @returns {Promise} Response data with created products.
   */
  async createProductsFromLineItems(newProducts) {
    return apiService.post('/estimates/llm/create-products', { newProducts });
  }

  /**
   * Finalize an estimate from matched products and line items.
   * @param {Object} finalData - Object containing finalized estimate data.
   * @returns {Promise} Response data with created estimate.
   */
  async finalizeEstimateFromMatches(finalData) {
    return apiService.post('/estimates/llm/finalize', finalData);
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

    return apiService.post('/estimates/llm/generate', payload);
  }

  /**
   * Process an external LLM response to generate estimate line items
   * @param {Object} payload - Object containing responseText and optional assessmentData
   * @returns {Promise} Response data with parsed line items
   */
  async processExternalLlmResponse(payload) {
    return apiService.post('/estimates/llm/process-external', payload);
  }

  /**
   * Get source map for bidirectional linking between assessment and estimate items
   * @param {string} estimateId - Estimate ID to get source map for
   * @returns {Promise} Response data with source map
   */
  async getEstimateSourceMap(estimateId) {
    return apiService.get(`/estimates/${estimateId}/source-map`);
  }

  /**
   * Save an estimate with source mapping for bidirectional linking
   * @param {Object} estimateData - Estimate data with line items and sourceMap
   * @returns {Promise} Response data with created estimate
   */
  async saveEstimateWithSourceMap(estimateData) {
    return apiService.post('/estimates/with-source-map', estimateData);
  }
}

export default new EstimatesService();