import apiService from './api.service';

/**
 * Service for catalog similarity checking and matching
 */
class CatalogMatcherService {
  /**
   * Check similarity between provided descriptions and existing catalog items
   * @param {Array<string>} descriptions - Array of item descriptions to check
   * @returns {Promise} - Promise with similarity results
   */
  async checkSimilarity(descriptions) {
    try {
      const response = await apiService.post('/api/estimates/llm/similarity-check', { descriptions });
      
      return {
        success: true,
        data: response.data
      };
    } catch (error) {
      console.error('Error checking catalog similarity:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to check catalog similarity',
        error
      };
    }
  }

  /**
   * Get catalog-eligible items from a list of descriptions
   * @param {Array<string>} descriptions - Array of item descriptions to check
   * @param {number} threshold - Similarity threshold (0-1)
   * @returns {Promise} - Promise with eligible items
   */
  async getCatalogEligibleItems(descriptions, threshold = 0.7) {
    try {
      const response = await apiService.post('/api/estimates/llm/catalog-eligible', { 
        descriptions,
        threshold
      });
      
      return {
        success: true,
        data: response.data
      };
    } catch (error) {
      console.error('Error getting catalog-eligible items:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to get catalog-eligible items',
        error
      };
    }
  }
}

export default new CatalogMatcherService();
