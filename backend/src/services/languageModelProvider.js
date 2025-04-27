const OpenAI = require('openai');
const logger = require('../utils/logger');
const settingsService = require('./settingsService');

/**
 * Service for managing language model providers
 * Supports OpenAI-compatible interfaces (DeepSeek, OpenAI, etc)
 */
class LanguageModelProvider {
  constructor() {
    this._initialized = false;
    this._provider = null;
    this._client = null;
    this._lastApiKey = null;
    this._lastBaseUrl = null;
    this._lastModelName = null;
    this._initPromise = this._initialize();
  }

  /**
   * Initialize the provider based on settings
   * @private
   */
  async _initialize() {
    try {
      // Load settings from DB or use environment variables as fallback
      const providerName = await settingsService.getSettingValue(
        'language_model_provider', 
        process.env.LANGUAGE_MODEL_PROVIDER || 'deepseek'
      );
      
      const apiKey = await this._getApiKey(providerName);
      const baseUrl = await this._getBaseUrl(providerName);
      const modelName = await this._getModelName(providerName);

      if (!apiKey) {
        logger.warn(`No API key found for language model provider: ${providerName}`);
        this._initialized = false;
        return;
      }

      // Only re-initialize if settings have changed
      if (
        this._lastApiKey !== apiKey ||
        this._lastBaseUrl !== baseUrl ||
        this._lastModelName !== modelName ||
        this._provider !== providerName
      ) {
        logger.info(`Initializing language model provider: ${providerName}`);
        
        this._provider = providerName;
        this._lastApiKey = apiKey;
        this._lastBaseUrl = baseUrl;
        this._lastModelName = modelName;

        // Initialize client (all providers use OpenAI-compatible API)
        this._client = new OpenAI({
          apiKey: apiKey,
          baseURL: baseUrl,
        });
        
        this._initialized = true;
        logger.info(`Language model provider initialized: ${providerName} with model ${modelName}`);
      }
    } catch (error) {
      logger.error('Error initializing language model provider:', error);
      this._initialized = false;
    }
  }

  // Map for suffix conversion
  #suffixMap = {
    apiKey: 'api_key',
    baseUrl: 'base_url',
    model: 'model'
  };

  /**
   * Generic getter for provider settings with fallback
   * @private
   * @param {string} providerName - Name of the provider
   * @param {string} settingType - Type of setting (apiKey, baseUrl, model)
   * @param {string} defaultValue - Default value if not found
   * @returns {Promise<string>} Setting value
   */
  async _getSetting(providerName, settingType, defaultValue = '') {
    const suffix = this.#suffixMap[settingType];
    if (!suffix) {
      throw new Error(`Invalid setting type: ${settingType}`);
    }

    // Try generic key first (language_model_api_key, language_model_base_url, language_model)
    const genericKey = settingType === 'model' ? 'language_model' : `language_model_${suffix}`;
    const genericValue = await settingsService.getSettingValue(genericKey, null);
    if (genericValue) {
      return genericValue;
    }

    // Fallback to provider-specific key
    const specificKey = `${providerName.toLowerCase()}_${suffix}`;
    const envKey = `${providerName.toUpperCase()}_${suffix.toUpperCase()}`;
    
    logger.debug(`Looking for setting: ${specificKey} with fallback to ${genericKey}`);
    return await settingsService.getSettingValue(specificKey, process.env[envKey] || defaultValue);
  }

  /**
   * Get the API key for the specified provider
   * @private
   * @param {string} providerName - Name of the provider
   * @returns {Promise<string>} API key
   */
  async _getApiKey(providerName) {
    return await this._getSetting(providerName, 'apiKey');
  }

  /**
   * Get the base URL for the specified provider
   * @private
   * @param {string} providerName - Name of the provider
   * @returns {Promise<string>} Base URL
   */
  async _getBaseUrl(providerName) {
    let defaultBaseUrl = '';
    
    // Set default base URLs based on provider
    if (providerName === 'openai') {
      defaultBaseUrl = 'https://api.openai.com/v1';
    } else if (providerName === 'deepseek') {
      defaultBaseUrl = 'https://api.deepseek.com/v1';
    }
    
    return await this._getSetting(providerName, 'baseUrl', defaultBaseUrl);
  }

  /**
   * Get the model name for the specified provider
   * @private
   * @param {string} providerName - Name of the provider
   * @returns {Promise<string>} Model name
   */
  async _getModelName(providerName) {
    let defaultModel = '';
    
    // Set default models based on provider
    if (providerName === 'openai') {
      defaultModel = 'gpt-3.5-turbo';
    } else if (providerName === 'deepseek') {
      defaultModel = 'deepseek-chat';
    }
    
    return await this._getSetting(providerName, 'model', defaultModel);
  }

  /**
   * Get the current language model provider name
   * @returns {Promise<string>} Provider name
   */
  async getProviderName() {
    if (!this._initialized) {
      await this._initPromise;
    }
    return this._provider;
  }

  /**
   * Get the current language model name
   * @returns {Promise<string>} Model name
   */
  async getModelName() {
    if (!this._initialized) {
      await this._initPromise;
    }
    return this._lastModelName;
  }

  /**
   * Generate a chat completion
   * @param {Array<object>} messages - Array of message objects
   * @param {object} options - Additional options for the API call
   * @returns {Promise<object>} API response
   */
  async generateChatCompletion(messages, options = {}) {
    try {
      // Ensure provider is initialized
      if (!this._initialized) {
        await this._initPromise;
      }

      if (!this._client) {
        throw new Error('Language model client not initialized');
      }

      if (!messages || messages.length === 0) {
        throw new Error('Messages array cannot be empty');
      }

      logger.debug(`Sending request to ${this._provider} model: ${this._lastModelName}`);
      
      const requestParams = {
        messages: messages,
        model: options.model || this._lastModelName,
        ...options
      };

      // Log request details
      const requestTime = new Date().toISOString();
      logger.debug('Request sent at:', requestTime);

      const completion = await this._client.chat.completions.create(requestParams);

      // Log response details
      const responseTime = new Date().toISOString();
      logger.debug('Response received at:', responseTime);
      logger.debug('Response ID:', completion.id);

      return completion;
    } catch (error) {
      logger.error(`Error generating chat completion: ${error.message}`, error);
      throw error;
    }
  }

  /**
   * Parse JSON from LLM response content
   * @param {string} content - Content to parse
   * @returns {object|null} Parsed JSON or null if parsing fails
   */
  parseJsonResponse(content) {
    if (!content) return null;
    try {
      // Attempt to find JSON block within ```json ... ``` markers or just parse directly
      const jsonMatch = content.match(/```json\s*([\s\S]*?)\s*```/);
      const jsonString = jsonMatch ? jsonMatch[1].trim() : content.trim();

      // Basic check if it looks like JSON before parsing
      if (!jsonString.startsWith('{') && !jsonString.startsWith('[')) {
        logger.warn('Content does not appear to be valid JSON');
        return null;
      }

      return JSON.parse(jsonString);
    } catch (error) {
      logger.warn('Failed to parse JSON response from LLM content:', error);
      return null;
    }
  }

  /**
   * Force reinitialization of the provider (used after settings changes)
   */
  async reinitialize() {
    this._initialized = false;
    this._provider = null;
    this._client = null;
    this._lastApiKey = null;
    this._lastBaseUrl = null;
    this._lastModelName = null;
    await this._initialize();
  }
}

// Create and export a singleton instance
const languageModelProvider = new LanguageModelProvider();
module.exports = languageModelProvider;
