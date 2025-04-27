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

      // Enhanced response structure handling with better debugging
      console.log('Raw AI provider settings response:', response);

      // Check for different possible response structures
      if (response?.success && response?.data) {
        // Direct response from apiService
        return {
          success: true,
          data: response.data
        };
      } else if (response?.data?.success && response?.data?.data) {
        // Nested response structure
        return {
          success: true,
          data: response.data.data
        };
      } else if (response?.data) {
        // Response with just data property
        return {
          success: true,
          data: response.data
        };
      } else {
        console.warn('Response from AI provider settings endpoint has unexpected format:', response);
        return {
          success: false,
          message: 'Invalid response format from API',
          data: {
            settings: [],
            providers: {
              languageModel: { provider: null, model: null },
              embedding: { provider: null, model: null, enabled: false }
            }
          }
        };
      }
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

      // Enhanced response structure handling with better debugging
      console.log('Raw AI provider options response:', response);

      // Check for different possible response structures
      if (response?.success && response?.data) {
        // Direct response from apiService
        return {
          success: true,
          data: {
            data: response.data // Preserve the data nesting expected by the component
          }
        };
      } else if (response?.data?.success && response?.data?.data) {
        // Nested response structure
        return {
          success: true,
          data: {
            data: response.data.data // Preserve the data nesting expected by the component
          }
        };
      } else if (response?.data) {
        // Response with just data property
        return {
          success: true,
          data: {
            data: response.data // Preserve the data nesting expected by the component
          }
        };
      } else {
        console.warn('Response from AI provider options endpoint has unexpected format:', response);
        return {
          success: false,
          message: 'Invalid response format from API',
          data: {
            data: {
              providers: {
                languageModel: [],
                embedding: []
              },
              models: {
                languageModel: {},
                embedding: {}
              }
            }
          }
        };
      }
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
      // Enhanced debugging information
      console.log('Updating AI provider settings with:', settings);
      
      // Format the settings payload correctly
      const payload = { settings };
      console.log('Payload being sent to API:', payload);
      
      const response = await apiService.post('/ai-provider', payload);
      
      // Enhanced response logging
      console.log('Update AI provider settings response:', response);
      
      // Handle different response structures
      if (response?.success) {
        return response;
      } else if (response?.data?.success) {
        return response.data;
      } else {
        return {
          success: true,
          data: response
        };
      }
    } catch (error) {
      console.error('Error updating AI provider settings:', error);
      console.error('Error details:', {
        message: error.message,
        response: error.response,
        stack: error.stack
      });
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to update AI provider settings',
        error: error.message
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
      return response;
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
      return response;
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
