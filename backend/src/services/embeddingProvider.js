const OpenAI = require('openai');
const logger = require('../utils/logger');
const settingsService = require('./settingsService');

/**
 * Service for managing embeddings across different providers
 * Supports OpenAI-compatible interfaces (Gemini, OpenAI, etc)
 */
class EmbeddingProvider {
  constructor() {
    this._initialized = false;
    this._provider = null;
    this._client = null;
    this._lastApiKey = null;
    this._lastBaseUrl = null;
    this._lastModelName = null;
    this._lastSimilarityRequest = 0;
    this._initPromise = this._initialize();
  }

  /**
   * Initialize the provider based on settings
   * @private
   */
  async _initialize() {
    try {
      // Load settings from DB or use environment variables as fallback
      let providerName = await settingsService.getSettingValue(
        'embedding_provider',
        process.env.EMBEDDING_PROVIDER || 'gemini'
      );

      // If no provider is set but vector similarity is enabled, ensure we have a provider
      if (!providerName) {
        const vectorSimilarityEnabled = await settingsService.getSettingValue('enable_vector_similarity', false);
        if (vectorSimilarityEnabled) {
          logger.info('Vector similarity enabled but no provider set, using default provider');
          providerName = process.env.EMBEDDING_PROVIDER || 'gemini';
        }
      }

      const apiKey = await this._getApiKey(providerName);
      const baseUrl = await this._getBaseUrl(providerName);
      const modelName = await this._getModelName(providerName);

      if (!apiKey) {
        logger.warn(`No API key found for embedding provider: ${providerName}`);
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
        logger.info(`Initializing embedding provider: ${providerName}`);

        this._provider = providerName;
        this._lastApiKey = apiKey;
        this._lastBaseUrl = baseUrl;
        this._lastModelName = modelName;

        // Create OpenAI client for OpenAI and Gemini (all use OpenAI-compatible API)
      if (providerName === 'openai' || providerName === 'gemini') {
        let headers = undefined;

        // Gemini requires special header
        if (providerName === 'gemini') {
          headers = { 'x-goog-api-key': apiKey };
        }

        this._client = new OpenAI({
          apiKey: apiKey,
          baseURL: baseUrl,
          defaultHeaders: headers,
        });
      }

        this._initialized = true;
        logger.info(`Embedding provider initialized: ${providerName} with model ${modelName}`);
      }
    } catch (error) {
      logger.error('Error initializing embedding provider:', error);
      this._initialized = false;
    }
  }

  // Map for suffix conversion
  #suffixMap = {
    apiKey: 'api_key',
    baseUrl: 'base_url',
    model: 'embedding_model'
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

    const specificKey = `${providerName.toLowerCase()}_${suffix}`;
    const genericKey = `embedding_${suffix}`;
    const envSpecific = `${providerName.toUpperCase()}_${suffix.toUpperCase()}`;
    const envGeneric = `EMBEDDING_${suffix.toUpperCase()}`;

    logger.debug(`Looking for setting: ${specificKey} with fallback to ${genericKey}`);

    try {
      return await settingsService.getSettingValue(
        specificKey,
        await settingsService.getSettingValue(
          genericKey,
          process.env[envSpecific] || process.env[envGeneric] || defaultValue
        )
      );
    } catch (error) {
      logger.warn(`Error getting setting ${specificKey}, using default value: ${error.message}`);
      return defaultValue;
    }
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
    } else if (providerName === 'gemini') {
      defaultBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
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
      defaultModel = 'text-embedding-3-small';
    } else if (providerName === 'gemini') {
      defaultModel = 'gemini-embedding-exp-03-07';
    }

    return await this._getSetting(providerName, 'model', defaultModel);
  }

  /**
   * Check if embedding is enabled in settings or environment
   * @returns {Promise<boolean>} Whether embedding is enabled
   */
  async isEnabled() {
    return await settingsService.getSettingValue('enable_vector_similarity', process.env.ENABLE_VECTOR_SIMILARITY === 'true');
  }

  /**
   * Get the current embedding provider name
   * @returns {Promise<string>} Provider name
   */
  async getProviderName() {
    if (!this._initialized) {
      await this._initPromise;
    }
    return this._provider;
  }

  /**
   * Get the current embedding model name
   * @returns {Promise<string>} Model name
   */
  async getModelName() {
    if (!this._initialized) {
      await this._initPromise;
    }
    return this._lastModelName;
  }

  /**
   * Generate an embedding for the input text
   * @param {string} text - Text to generate embedding for
   * @returns {Promise<Float32Array|null>} Embedding vector or null if disabled/error
   */
  async embed(text) {
    try {
      // Ensure provider is initialized
      if (!this._initialized) {
        await this._initPromise;
      }

      // Check if embedding is enabled
      const isEnabled = await this.isEnabled();
      if (!isEnabled) {
        logger.warn('Vector similarity disabled - returning null embedding');
        return null;
      }

      // Rate limit embeddings - add delay between requests
      if (this._lastSimilarityRequest && Date.now() - this._lastSimilarityRequest < 300) {
        await new Promise(resolve => setTimeout(resolve, 300));
      }
      this._lastSimilarityRequest = Date.now();

      // Generate embedding based on provider
      if (this._provider === 'openai' || this._provider === 'gemini') {
        if (!this._client) {
          // Try initializing if client is not ready
          await this.reinitialize();

          // If still not initialized, throw an error
          if (!this._client) {
            throw new Error('Embedding client not initialized');
          }
        }

        let resp;
        try {
          resp = await this._client.embeddings.create({
            model: this._lastModelName,
            input: text,
          });

          logger.debug('Successfully generated embedding');
        } catch (err) {
          // If we get a 404 error, the model might not exist - try a fallback model
          if (err.status === 404) {
            logger.warn(`Model ${this._lastModelName} not found (404) - falling back to text-embedding-3-small`);
            resp = await this._client.embeddings.create({
              model: 'text-embedding-3-small',
              input: text,
            });
            logger.info('Successfully generated embedding with fallback model');
          } else {
            // Re-throw other errors
            throw err;
          }
        }
        // Check for different response formats based on provider
        let embedding;
        if (this._provider === 'gemini') {
          // Gemini format might vary
          if (resp.data && Array.isArray(resp.data) && resp.data.length > 0) {
            if (resp.data[0].embedding) {
              embedding = resp.data[0].embedding;
            } else if (resp.data[0].values) {
              embedding = resp.data[0].values;
            }
          }
          // Additional fallbacks for Gemini's response structure
          if (!embedding && resp.embedding) embedding = resp.embedding;
          if (!embedding && resp.values) embedding = resp.values;

          if (!embedding) {
            logger.warn('Unexpected Gemini embedding response format:', resp);
            throw new Error('Unexpected Gemini embedding response format');
          }
        } else {
          // Default OpenAI format
          embedding = resp.data[0].embedding;
        }

        // Check if dimensionality reduction is needed
        const targetDim = parseInt(process.env.EMBEDDING_DIM || '1536', 10);
        if (embedding.length > targetDim) {
          logger.info(`Reducing embedding dimensions from ${embedding.length} to ${targetDim}`);
          // Simple dimensionality reduction by taking every nth element
          const ratio = embedding.length / targetDim;
          const reducedEmbedding = new Array(targetDim);
          for (let i = 0; i < targetDim; i++) {
            reducedEmbedding[i] = embedding[Math.floor(i * ratio)];
          }
          return reducedEmbedding;
        }

        return embedding;
      // All providers use the OpenAI-compatible client pattern
      }

      logger.warn(`Unsupported embedding provider: ${this._provider}`);
      return null;
    } catch (error) {
      logger.error(`Error generating embedding: ${error.message}`, error);
      if (this._provider === 'gemini') {
        logger.error(`Gemini API details - Provider: ${this._provider}, Model: ${this._lastModelName}, Base URL: ${this._lastBaseUrl}`);
        logger.error('Check if your Gemini API key is correct and has embedding permissions');
      }
      // Return null instead of throwing to prevent cascading failures
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
const embeddingProvider = new EmbeddingProvider();
module.exports = embeddingProvider;
