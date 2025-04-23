import apiService from './api.service';
import { toCamelCase, toSnakeCase } from '@/utils/casing';

/**
 * Service for managing LLM prompts
 */
class LLMPromptService {
  /**
   * Get all LLM prompts
   * @returns {Promise} Promise with all prompts
   */
  async getAllPrompts() {
    try {
      const response = await apiService.get('/api/llm-prompts');

      // Convert snake_case to camelCase
      const data = response.data ? toCamelCase(response.data) : null;

      return {
        success: true,
        data
      };
    } catch (error) {
      console.error('Error fetching LLM prompts:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to fetch LLM prompts',
        error
      };
    }
  }

  /**
   * Get a specific LLM prompt by ID
   * @param {string} id - Prompt ID
   * @returns {Promise} Promise with the prompt
   */
  async getPromptById(id) {
    try {
      const response = await apiService.get(`/api/llm-prompts/${id}`);

      // Convert snake_case to camelCase
      const data = response.data ? toCamelCase(response.data) : null;

      return {
        success: true,
        data
      };
    } catch (error) {
      console.error(`Error fetching LLM prompt with ID ${id}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || `Failed to fetch LLM prompt with ID ${id}`,
        error
      };
    }
  }

  /**
   * Update a single LLM prompt
   * @param {Object} prompt - Prompt object with id and prompt_text
   * @returns {Promise} Promise with the updated prompt
   */
  async updatePrompt(prompt) {
    try {
      // Convert camelCase to snake_case
      const snakeCasePrompt = toSnakeCase(prompt);

      const response = await apiService.put(`/api/llm-prompts/${prompt.id}`, {
        description: snakeCasePrompt.description,
        prompt_text: snakeCasePrompt.prompt_text
      });

      // Convert snake_case to camelCase
      const data = response.data ? toCamelCase(response.data) : null;

      return {
        success: true,
        data
      };
    } catch (error) {
      console.error(`Error updating LLM prompt with ID ${prompt.id}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || `Failed to update LLM prompt with ID ${prompt.id}`,
        error
      };
    }
  }

  /**
   * Update multiple LLM prompts
   * @param {Array} prompts - Array of prompt objects with id and prompt_text
   * @returns {Promise} Promise with the result
   */
  async updatePrompts(prompts) {
    try {
      // Since batch update is not implemented in the backend,
      // we'll update each prompt individually
      const results = [];

      for (const prompt of prompts) {
        const result = await this.updatePrompt(prompt);
        results.push(result);

        if (!result.success) {
          console.error(`Failed to update prompt ${prompt.id}:`, result.message);
        }
      }

      const allSuccessful = results.every(result => result.success);

      return {
        success: allSuccessful,
        data: results.map(result => result.data),
        message: allSuccessful ? 'All prompts updated successfully' : 'Some prompts failed to update'
      };
    } catch (error) {
      console.error('Error updating LLM prompts:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to update LLM prompts',
        error
      };
    }
  }

  /**
   * Reset a prompt to its default value
   * @param {string} id - Prompt ID
   * @returns {Promise} Promise with the reset prompt
   */
  async resetPrompt(id) {
    try {
      // Since reset is not implemented in the backend,
      // we'll return a not implemented error
      return {
        success: false,
        message: 'Reset functionality is not implemented yet'
      };
    } catch (error) {
      console.error(`Error resetting LLM prompt with ID ${id}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || `Failed to reset LLM prompt with ID ${id}`,
        error
      };
    }
  }
}

export default new LLMPromptService();
