import apiService from './api.service';

/**
 * Service for interacting with the V2 estimate generation API
 */
const estimatesV2Service = {
  /**
   * Generate an estimate using the smart AI conversation workflow
   * @param {Object} payload - The request payload
   * @param {string} payload.assessment - The assessment text
   * @param {Object} payload.options - Optional settings for generation
   * @returns {Promise} - The API response
   */
  generate(payload) {
    return apiService.post('/api/estimates/v2/generate', payload);
  }
};

export default estimatesV2Service;
