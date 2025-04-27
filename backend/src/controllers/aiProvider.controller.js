const settingsService = require('../services/settingsService');
const languageModelProvider = require('../services/languageModelProvider');
const embeddingProvider = require('../services/embeddingProvider');
const logger = require('../utils/logger');

/**
 * Get all AI provider settings
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getAiProviderSettings = async (req, res) => {
  try {
    // Get settings from the AI provider group
    const settings = await settingsService.getSettingsByGroup('ai_provider');

    // Get current provider status from runtime service and settings
    const languageModelName = await languageModelProvider.getProviderName();
    const embeddingModelName = await embeddingProvider.getProviderName();
    const languageModel = await languageModelProvider.getModelName();
    const embeddingModel = await embeddingProvider.getModelName();
    const vectorSimilarityEnabled = await embeddingProvider.isEnabled();
    
    // Check if API keys are configured in settings
    const languageApiKey = await settingsService.getSettingValue('language_model_api_key', '');
    const providerSpecificApiKey = await settingsService.getSettingValue(`${languageModelName}_api_key`, '');
    
    // Get database values for comparison and fallback
    const dbEmbeddingProvider = await settingsService.getSettingValue('embedding_provider', '');
    const dbEmbeddingModel = await settingsService.getSettingValue('embedding_model', '');

    // Add detailed logging for debugging
    logger.debug('AI provider settings being returned:', {
      settingsCount: settings.length,
      runtime: {
        languageModelName,
        embeddingModelName,
        languageModel,
        embeddingModel,
        vectorSimilarityEnabled
      },
      database: {
        embeddingProvider: dbEmbeddingProvider,
        embeddingModel: dbEmbeddingModel
      }
    });

    // Combine into response, preferring database values when provider is not initialized
    return res.status(200).json({
      success: true,
      data: {
        settings,
        providers: {
          languageModel: {
            provider: languageModelName || 'Not configured',
            model: languageModel || 'Not configured',
            status: (languageApiKey || providerSpecificApiKey) ? 'Configured' : 'Missing'
          },
          embedding: {
            provider: dbEmbeddingProvider || embeddingModelName || 'Not configured',
            model: dbEmbeddingModel || embeddingModel || 'Not configured',
            enabled: vectorSimilarityEnabled
          }
        }
      }
    });
  } catch (error) {
    logger.error('Error getting AI provider settings:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get AI provider settings',
      error: error.message
    });
  }
};

/**
 * Update AI provider settings
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const updateAiProviderSettings = async (req, res) => {
  try {
    // Enhanced request logging for debugging
    logger.debug('Update AI provider settings request body:', {
      body: req.body,
      headers: req.headers['content-type'],
      userId: req.user?.id
    });

    // Extract settings with more robust error handling
    const { settings } = req.body || {};

    if (!settings || !Object.keys(settings).length) {
      logger.warn('Settings object missing or empty in request');
      return res.status(400).json({
        success: false,
        message: 'Settings object is required'
      });
    }
    
    // Log all embedding-related settings
    logger.debug('Embedding settings received:', {
      provider: settings.embedding_provider,
      model: settings.embedding_model,
      enabled: settings.enable_vector_similarity
    });

    logger.debug('Processing settings update with values:', settings);

    // Update settings in the database
    await settingsService.updateMultipleSettings(settings, 'ai_provider');
    logger.info('AI provider settings updated in database successfully');

    // Reinitialize providers to pick up new settings
    try {
      await Promise.all([
        languageModelProvider.reinitialize(),
        embeddingProvider.reinitialize()
      ]);
      logger.info('AI providers reinitialized successfully');
    } catch (reinitError) {
      logger.warn('Error during provider reinitialization, continuing anyway:', reinitError);
      // Continue execution - settings are saved even if reinit fails
    }

    // Get updated provider status
    const languageModelName = await languageModelProvider.getProviderName();
    const embeddingModelName = await embeddingProvider.getProviderName();
    const embeddingEnabled = await embeddingProvider.isEnabled();

    logger.debug('Providers after update:', { 
      languageModelName, 
      embeddingModelName, 
      embeddingEnabled 
    });

    // Send successful response
    return res.status(200).json({
      success: true,
      message: 'AI provider settings updated successfully',
      data: {
        languageModelProvider: languageModelName || 'Not configured',
        embeddingProvider: embeddingModelName || 'Not configured',
        embeddingEnabled
      }
    });
  } catch (error) {
    logger.error('Error updating AI provider settings:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to update AI provider settings: ' + error.message,
      error: error.message
    });
  }
};

/**
 * Test language model connection
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const testLanguageModelConnection = async (req, res) => {
  try {
    // Track start time for latency calculation
    const start = Date.now();
    
    // Create a simple test message
    const messages = [
      { role: 'system', content: 'You are a helpful assistant.' },
      { role: 'user', content: 'Hello, are you working?' }
    ];

    // Try to generate a completion
    const completion = await languageModelProvider.generateChatCompletion(messages, {
      max_tokens: 20,
      temperature: 0.5
    });

    // Extract the response content
    const responseContent = completion.choices?.[0]?.message?.content;
    
    // Accept empty string as a valid minimal completion
    if (responseContent === null || responseContent === undefined) {
      logger.warn('Language model returned null/undefined content');
      return res.status(200).json({
        success: false,
        message: 'Language model returned null/undefined'
      });
    }

    logger.info('Language model test successful');
    return res.status(200).json({
      success: true,
      message: 'Language model connection test successful',
      data: {
        provider: await languageModelProvider.getProviderName(),
        model: await languageModelProvider.getModelName(),
        response: responseContent,
        latencyMs: Date.now() - start
      }
    });
  } catch (error) {
    logger.error('Error testing language model connection:', error);
    return res.status(500).json({
      success: false,
      message: 'Language model connection test failed',
      error: error.message
    });
  }
};

/**
 * Test embedding model connection
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const testEmbeddingConnection = async (req, res) => {
  try {
    // Check if embedding is enabled
    const isEnabled = await embeddingProvider.isEnabled();
    if (!isEnabled) {
      return res.status(400).json({
        success: false,
        message: 'Embedding is disabled in settings'
      });
    }

    // Try to generate an embedding
    const embedding = await embeddingProvider.embed('This is a test for embedding generation.');

    if (!embedding) {
      return res.status(500).json({
        success: false,
        message: 'Embedding generation failed'
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Embedding connection test successful',
      data: {
        provider: await embeddingProvider.getProviderName(),
        model: await embeddingProvider.getModelName(),
        dimensions: embedding.length,
        sample: embedding.slice(0, 5) // Just show a few values as sample
      }
    });
  } catch (error) {
    logger.error('Error testing embedding connection:', error);
    return res.status(500).json({
      success: false,
      message: 'Embedding connection test failed',
      error: error.message
    });
  }
};

/**
 * Get available AI provider options
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getAiProviderOptions = async (req, res) => {
  try {
    // Define available providers
    const providers = {
      languageModel: [
        { value: 'deepseek', label: 'DeepSeek AI' },
        { value: 'openai', label: 'OpenAI' },
        { value: 'custom', label: 'Custom Provider' }
      ],
      embedding: [
        { value: 'gemini', label: 'Google Gemini' },
        { value: 'openai', label: 'OpenAI' },
        { value: 'custom', label: 'Custom Provider' }
      ]
    };

    // Define available models for each provider
    const models = {
      languageModel: {
        deepseek: [
          { value: 'deepseek-chat', label: 'DeepSeek Chat' },
          { value: 'deepseek-reasoner', label: 'DeepSeek Reasoner' }
        ],
        openai: [
          { value: 'gpt-3.5-turbo', label: 'GPT-3.5 Turbo' },
          { value: 'gpt-4', label: 'GPT-4' },
          { value: 'gpt-4o', label: 'GPT-4o' }
        ]
      },
      embedding: {
        openai: [
          { value: 'text-embedding-3-small', label: 'Embedding v3 Small' },
          { value: 'text-embedding-3-large', label: 'Embedding v3 Large' }
        ],
        gemini: [
          { value: 'gemini-embedding-exp-03-07', label: 'Gemini Embedding' }
        ]
      }
    };

    return res.status(200).json({
      success: true,
      data: {
        providers,
        models
      }
    });
  } catch (error) {
    logger.error('Error getting AI provider options:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get AI provider options',
      error: error.message
    });
  }
};

module.exports = {
  getAiProviderSettings,
  updateAiProviderSettings,
  testLanguageModelConnection,
  testEmbeddingConnection,
  getAiProviderOptions
};
