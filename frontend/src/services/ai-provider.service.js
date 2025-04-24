import apiService from './api.service';

/**
 * Service for managing AI provider settings
 */
class AiProviderService {
  /**
   * Get all AI provider settings
   * @returns {Promise} Response with AI provider settings
   */
  async getAiProviderSettings() {
    try {
      const response = await apiService.get('/ai-provider');
      return response.data;
    } catch (error) {
      console.error('Error getting AI provider settings:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to get AI provider settings',
        error
      };
    }
  }

  /**
   * Get available AI provider options
   * @returns {Promise} Response with available providers and models
   */
  async getAiProviderOptions() {
    try {
      const response = await apiService.get('/ai-provider/options');
      return response.data;
    } catch (error) {
      console.error('Error getting AI provider options:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to get AI provider options',
        error
      };
    }
  }

  /**
   * Update AI provider settings
   * @param {Object} settings - Settings to update
   * @returns {Promise} Response with update status
   */
  async updateAiProviderSettings(settings) {
    try {
      const response = await apiService.post('/ai-provider', { settings });
      return response.data;
    } catch (error) {
      console.error('Error updating AI provider settings:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to update AI provider settings',
        error
      };
    }
  }

  /**
   * Test language model connection
   * @returns {Promise} Response with test results
   */
  async testLanguageModelConnection() {
    try {
      const response = await apiService.post('/ai-provider/test-language-model');
      return response.data;
    } catch (error) {
      console.error('Error testing language model connection:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Language model connection test failed',
        error
      };
    }
  }

  /**
   * Test embedding model connection
   * @returns {Promise} Response with test results
   */
  async testEmbeddingConnection() {
    try {
      const response = await apiService.post('/ai-provider/test-embedding');
      return response.data;
    } catch (error) {
      console.error('Error testing embedding connection:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Embedding connection test failed',
        error
      };
    }
  }
}

export default new AiProviderService();
