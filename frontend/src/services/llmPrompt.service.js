import apiService from './api.service';

/**
 * Service for managing LLM prompts
 */
class LLMPromptService {
  /**
   * Get all LLM prompts
   * @returns {Promise} - Promise with all prompts
   */
  async getAllPrompts() {
    return apiService.get('/llm-prompts');
  }

  /**
   * Get a specific prompt by ID
   * @param {number} id - Prompt ID
   * @returns {Promise} - Promise with prompt details
   */
  async getPromptById(id) {
    return apiService.get(`/llm-prompts/${id}`);
  }

  /**
   * Get a specific prompt by name
   * @param {string} name - Prompt name
   * @returns {Promise} - Promise with prompt details
   */
  async getPromptByName(name) {
    return apiService.get(`/llm-prompts/name/${name}`);
  }

  /**
   * Update a prompt
   * @param {number} id - Prompt ID
   * @param {Object} data - Updated prompt data
   * @returns {Promise} - Promise with update result
   */
  async updatePrompt(id, data) {
    return apiService.put(`/llm-prompts/${id}`, data);
  }
}

export default new LLMPromptService();
