const OpenAI = require('openai');
const logger = require('../utils/logger'); // Assuming logger uses CommonJS

/**
 * Service for interacting with the DeepSeek API.
 * Uses the OpenAI SDK for compatibility.
 */
class DeepSeekService {
  constructor() {
    const apiKey = process.env.DEEPSEEK_API_KEY;
    // Updated default baseURL to include /v1 for OpenAI SDK compatibility
    const baseURL = process.env.DEEPSEEK_BASE_URL || 'https://api.deepseek.com/v1';

    if (!apiKey) {
      logger.error('DEEPSEEK_API_KEY environment variable is not set.');
      throw new Error('DeepSeek API key is missing. Please set the DEEPSEEK_API_KEY environment variable.');
    }

    try {
      this.client = new OpenAI({
        baseURL: baseURL,
        apiKey: apiKey,
      });
      logger.info(`DeepSeekService initialized with base URL: ${baseURL}`);
    } catch (error) {
      logger.error('Failed to initialize OpenAI client for DeepSeek:', error);
      throw new Error('Could not initialize DeepSeek client.');
    }
  }

  /**
   * Sends a request to the DeepSeek Chat API.
   * @param {Array<object>} messages - Array of message objects (e.g., [{ role: "system", content: "..." }, { role: "user", content: "..." }])
   * @param {string} model - The model to use ('deepseek-chat' or 'deepseek-reasoner'). Defaults to 'deepseek-chat'.
   * @param {boolean} stream - Whether to use streaming response. Defaults to false.
   * @returns {Promise<object|Stream>} - The API response or stream.
   * @throws {Error} If the API call fails.
   */
  async generateChatCompletion(messages, model = 'deepseek-chat', stream = false) {
    if (!this.client) {
        throw new Error('DeepSeek client not initialized.');
    }
    if (!messages || messages.length === 0) {
        throw new Error('Messages array cannot be empty.');
    }

    try {
      logger.debug(`Sending request to DeepSeek model: ${model} with stream: ${stream}`);
      const requestParams = {
        messages: messages,
        model: model,
        stream: stream,
      };
      
      logger.debug(`Request parameters: ${JSON.stringify(requestParams, null, 2)}`);
      
      const completion = await this.client.chat.completions.create(requestParams);
      logger.debug(`Received response from DeepSeek model: ${model}`);
      return completion;
    } catch (error) {
      logger.error(`Error calling DeepSeek API (${model}):`, error.response ? error.response.data : error.message);
      // Rethrow or handle specific errors (e.g., rate limits, auth errors)
      throw new Error(`DeepSeek API request failed: ${error.message}`);
    }
  }

  /**
   * Helper method to parse structured JSON from LLM response content.
   * @param {string} content - The string content potentially containing JSON.
   * @returns {object|null} - Parsed JSON object or null if parsing fails.
   */
  parseJsonResponse(content) {
    if (!content) return null; // Handle null or empty content
    try {
        // Attempt to find JSON block within ```json ... ``` markers or just parse directly
        const jsonMatch = content.match(/```json\s*([\s\S]*?)\s*```/);
        const jsonString = jsonMatch ? jsonMatch[1].trim() : content.trim(); // Trim whitespace

        // Basic check if it looks like JSON before parsing
        if (!jsonString.startsWith('{') || !jsonString.endsWith('}')) {
             logger.warn('Content does not appear to be a JSON object string.');
             return null;
        }

        return JSON.parse(jsonString);
    } catch (error) {
        logger.warn('Failed to parse JSON response from LLM content:', error);
        return null; // Return null or throw an error depending on desired strictness
    }
  }
}

// Export a singleton instance using CommonJS
const deepSeekServiceInstance = new DeepSeekService();
module.exports = deepSeekServiceInstance;