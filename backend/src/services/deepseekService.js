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
  async generateChatCompletion(messages, model = 'deepseek-chat', stream = false, options = {}) {
    if (!this.client) {
        throw new Error('DeepSeek client not initialized.');
    }
    if (!messages || messages.length === 0) {
        throw new Error('Messages array cannot be empty.');
    }

    console.log('\n===== DEEPSEEK SERVICE API CALL =====');
    console.log('Model:', model);
    console.log('Stream:', stream);
    console.log('Options:', JSON.stringify(options, null, 2));
    console.log('Messages:');
    messages.forEach((msg, i) => {
      console.log(`[${i}] Role: ${msg.role}`);
      console.log(`    Content: ${msg.content.substring(0, 100)}${msg.content.length > 100 ? '...' : ''}`);
    });

    try {
      logger.debug(`Sending request to DeepSeek model: ${model} with stream: ${stream}`);
      const requestParams = {
        messages: messages,
        model: model,
        stream: stream,
        ...options
      };

      // Log timestamp when request is sent
      const requestTime = new Date().toISOString();
      console.log('Request sent at:', requestTime);

      const completion = await this.client.chat.completions.create(requestParams);

      // Log timestamp when response is received
      const responseTime = new Date().toISOString();
      console.log('Response received at:', responseTime);
      console.log('Response ID:', completion.id);

      // Log the content of the first choice
      if (completion.choices && completion.choices.length > 0) {
        const content = completion.choices[0].message?.content || 'No content';
        console.log('Response Content (first 500 chars):');
        console.log(content.substring(0, 500) + (content.length > 500 ? '...' : ''));
      } else {
        console.log('No choices in response');
      }
      console.log('===== END DEEPSEEK SERVICE API CALL =====\n');

      logger.debug(`Received response from DeepSeek model: ${model}`);

      // Normalize response to match OpenAI format if needed
      if (completion && !completion.choices) {
        // If the response doesn't have the expected OpenAI structure
        logger.debug('Normalizing DeepSeek response to match OpenAI format');
        return {
          id: completion.id || `deepseek-${Date.now()}`,
          choices: [{
            message: {
              role: 'assistant',
              content: completion.content || completion.text || JSON.stringify(completion)
            }
          }]
        };
      }

      return completion;
    } catch (error) {
      console.log('\n===== DEEPSEEK SERVICE API ERROR =====');
      console.log('Error message:', error.message);
      console.log('Error details:', error.response?.data || 'No error details available');
      console.log('===== END DEEPSEEK SERVICE API ERROR =====\n');

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