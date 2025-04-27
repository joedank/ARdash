<template>
  <div>
    <BaseCard variant="bordered">
      <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">
        AI Provider Settings
      </h3>
      <p class="text-gray-600 dark:text-gray-400 mb-6">
        Configure the AI providers for language model tasks and vector embeddings
      </p>

      <!-- Loading state -->
      <div v-if="loading" class="flex justify-center my-8">
        <BaseLoader size="lg" />
      </div>

      <!-- Settings form -->
      <form v-else @submit.prevent="saveSettings" class="space-y-8">
        <!-- Language Model Provider Section -->
        <div>
          <h4 class="font-medium text-gray-800 dark:text-white mb-3">
            Language Model Configuration
          </h4>
          <div class="space-y-4">
            <BaseFormGroup
              label="Language Model Provider"
              input-id="languageModelProvider"
              helper-text="Select the provider for language tasks (e.g., estimate generation)"
            >
              <BaseSelect
                id="languageModelProvider"
                v-model="settings.language_model_provider"
                :options="providerOptions.languageModel"
                @change="onLanguageProviderChange"
              />
            </BaseFormGroup>

            <BaseFormGroup
              label="Language Model"
              input-id="languageModel"
              helper-text="Select the specific model to use for language tasks"
            >
              <BaseSelect
                id="languageModel"
                v-model="settings.language_model"
                :options="getModelsForProvider('languageModel', settings.language_model_provider)"
                :disabled="!settings.language_model_provider"
              />
            </BaseFormGroup>

            <BaseFormGroup
              label="API Key"
              input-id="languageModelApiKey"
              helper-text="Enter the API key for the selected language model provider"
            >
              <BaseInput
                id="languageModelApiKey"
                v-model="settings.language_model_api_key"
                type="password"
                placeholder="Enter API key"
                :disabled="!settings.language_model_provider"
              />
            </BaseFormGroup>

            <BaseFormGroup
              v-if="settings.language_model_provider === 'custom'"
              label="Base URL"
              input-id="languageModelBaseUrl"
              helper-text="Enter the base URL for the custom language model provider"
            >
              <BaseInput
                id="languageModelBaseUrl"
                v-model="settings.language_model_base_url"
                placeholder="https://api.example.com/v1"
              />
            </BaseFormGroup>

            <div class="mt-3">
              <BaseButton
                type="button"
                variant="secondary"
                @click="testLanguageModel"
                :loading="testingLanguageModel"
                :disabled="
                  !settings.language_model_provider ||
                  !settings.language_model_api_key ||
                  testingLanguageModel
                "
              >
                Test Connection
              </BaseButton>
              <div
                v-if="languageModelTestResult"
                :class="[
                  'mt-2 text-sm',
                  languageModelTestSuccess
                    ? 'text-green-600 dark:text-green-400'
                    : 'text-red-600 dark:text-red-400',
                ]"
              >
                {{ languageModelTestResult }}
              </div>
            </div>
          </div>
        </div>

        <!-- Embedding Provider Section -->
        <div>
          <h4 class="font-medium text-gray-800 dark:text-white mb-3">
            Embedding Model Configuration
          </h4>
          <div class="space-y-4">
            <div class="flex items-center justify-between mb-3">
              <div>
                <span class="text-gray-700 dark:text-gray-300">Enable Vector Similarity</span>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  Enable vector-based similarity search for enhanced matching
                </p>
              </div>
              <BaseToggleSwitch
                v-model="settings.enable_vector_similarity"
                @change="onVectorSimilarityToggle"
              />
            </div>

            <template v-if="settings.enable_vector_similarity">
              <BaseFormGroup
                label="Embedding Provider"
                input-id="embeddingProvider"
                helper-text="Select the provider for vector embeddings (e.g., similarity search)"
              >
                <BaseSelect
                  id="embeddingProvider"
                  v-model="settings.embedding_provider"
                  :options="providerOptions.embedding"
                  @change="onEmbeddingProviderChange"
                  :disabled="!settings.enable_vector_similarity"
                />
              </BaseFormGroup>

              <BaseFormGroup
                label="Embedding Model"
                input-id="embeddingModel"
                helper-text="Select the specific model to use for embeddings"
              >
                <BaseSelect
                  id="embeddingModel"
                  v-model="settings.embedding_model"
                  :options="getModelsForProvider('embedding', settings.embedding_provider)"
                  :disabled="!settings.embedding_provider || !settings.enable_vector_similarity"
                />
              </BaseFormGroup>

              <BaseFormGroup
                label="API Key"
                input-id="embeddingApiKey"
                helper-text="Enter the API key for the selected embedding provider"
              >
                <BaseInput
                  id="embeddingApiKey"
                  v-model="settings.embedding_api_key"
                  type="password"
                  placeholder="Enter API key"
                  :disabled="!settings.embedding_provider || !settings.enable_vector_similarity"
                />
              </BaseFormGroup>

              <BaseFormGroup
                v-if="settings.embedding_provider === 'custom'"
                label="Base URL"
                input-id="embeddingBaseUrl"
                helper-text="Enter the base URL for the custom embedding provider"
              >
                <BaseInput
                  id="embeddingBaseUrl"
                  v-model="settings.embedding_base_url"
                  placeholder="https://api.example.com/v1"
                  :disabled="!settings.enable_vector_similarity"
                />
              </BaseFormGroup>

              <div class="mt-3">
                <BaseButton
                  type="button"
                  variant="secondary"
                  @click="testEmbedding"
                  :loading="testingEmbedding"
                  :disabled="
                    !settings.embedding_provider ||
                    !settings.embedding_api_key ||
                    !settings.enable_vector_similarity ||
                    testingEmbedding
                  "
                >
                  Test Connection
                </BaseButton>
                <div
                  v-if="embeddingTestResult"
                  :class="[
                    'mt-2 text-sm',
                    embeddingTestSuccess
                      ? 'text-green-600 dark:text-green-400'
                      : 'text-red-600 dark:text-red-400',
                  ]"
                >
                  {{ embeddingTestResult }}
                </div>
              </div>
            </template>
          </div>
        </div>

        <!-- Save button -->
        <div class="flex justify-end">
          <BaseButton
            type="submit"
            variant="primary"
            :loading="saving"
            :disabled="saving"
          >
            Save Settings
          </BaseButton>
        </div>
      </form>

      <!-- Status message -->
      <div
        v-if="statusMessage"
        :class="[
          'mt-4 py-2 px-4 rounded-md text-sm',
          statusSuccess
            ? 'bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-200'
            : 'bg-red-100 text-red-700 dark:bg-red-900 dark:text-red-200',
        ]"
      >
        {{ statusMessage }}
      </div>
    </BaseCard>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue';
import aiProviderService from '../../services/ai-provider.service';
import BaseCard from '../../components/data-display/BaseCard.vue';
import BaseInput from '../../components/form/BaseInput.vue';
import BaseButton from '../../components/base/BaseButton.vue';
import BaseSelect from '../../components/form/BaseSelect.vue';
import BaseFormGroup from '../../components/form/BaseFormGroup.vue';
import BaseToggleSwitch from '../../components/form/BaseToggleSwitch.vue';
import BaseLoader from '../../components/feedback/BaseLoader.vue';

// State
const loading = ref(true);
const saving = ref(false);
const testingLanguageModel = ref(false);
const testingEmbedding = ref(false);
const statusMessage = ref('');
const statusSuccess = ref(true);
const languageModelTestResult = ref('');
const languageModelTestSuccess = ref(false);
const embeddingTestResult = ref('');
const embeddingTestSuccess = ref(false);

// Provider options
const providerOptions = reactive({
  languageModel: [],
  embedding: []
});

// Models for each provider
const modelOptions = reactive({
  languageModel: {},
  embedding: {}
});

// Settings form
const settings = reactive({
  language_model_provider: '',
  language_model: '',
  language_model_api_key: '',
  language_model_base_url: '',
  embedding_provider: '',
  embedding_model: '',
  embedding_api_key: '',
  embedding_base_url: '',
  enable_vector_similarity: false
});

// Computed function to get models for a provider
const getModelsForProvider = (type, provider) => {
  if (!provider || !modelOptions[type][provider]) {
    return [];
  }
  return modelOptions[type][provider];
};

// Handle language provider change
const onLanguageProviderChange = () => {
  // Set default model for the selected provider
  const models = getModelsForProvider('languageModel', settings.language_model_provider);
  if (models && models.length > 0) {
    settings.language_model = models[0].value;
  } else {
    settings.language_model = '';
  }

  // Reset connection test result
  languageModelTestResult.value = '';
};

// Handle embedding provider change
const onEmbeddingProviderChange = () => {
  // Set default model for the selected provider
  const models = getModelsForProvider('embedding', settings.embedding_provider);
  if (models && models.length > 0) {
    settings.embedding_model = models[0].value;
    console.log(`Setting default embedding model to ${settings.embedding_model} for provider ${settings.embedding_provider}`);
  } else {
    settings.embedding_model = '';
    console.log('No models available for selected embedding provider');
  }

  // Reset connection test result
  embeddingTestResult.value = '';
};

// Handle vector similarity toggle
const onVectorSimilarityToggle = () => {
  if (!settings.enable_vector_similarity) {
    // Clear embedding test result when disabled
    embeddingTestResult.value = '';
  } else {
    // If enabling and no provider is selected, set default provider
    if (!settings.embedding_provider && providerOptions.embedding.length > 0) {
      settings.embedding_provider = providerOptions.embedding[0].value;
      onEmbeddingProviderChange();
    }
  }
};

// Load settings and options
const loadData = async () => {
  loading.value = true;

  try {
    // Load provider options
    await loadProviderOptions();

    // Load settings
    await loadProviderSettings();
  } catch (error) {
    console.error('Error loading AI provider data:', error);
    statusMessage.value = 'Failed to load AI provider settings';
    statusSuccess.value = false;
  } finally {
    loading.value = false;
  }
};

// Load provider options from API
const loadProviderOptions = async () => {
  try {
    // Get available provider options
    const optionsResponse = await aiProviderService.getAiProviderOptions();
    console.log('AI provider options response:', optionsResponse);

    // Enhanced debugging information
    console.log('Response structure check:', {
      hasSuccessFlag: !!optionsResponse?.success,
      hasDataProperty: !!optionsResponse?.data,
      hasNestedData: !!optionsResponse?.data?.data,
      responseType: typeof optionsResponse,
      dataType: optionsResponse?.data ? typeof optionsResponse.data : 'undefined'
    });

    if (optionsResponse?.success && optionsResponse?.data?.data) {
      // Get data from response
      const data = optionsResponse.data.data || {};

      // Process providers with better error handling
      handleProviders(data);

      // Process models with better error handling
      handleModels(data);
    } else if (optionsResponse?.success && optionsResponse?.data) {
      // Alternative structure - data directly in data property
      const data = optionsResponse.data || {};

      // Process providers with better error handling
      handleProviders(data);

      // Process models with better error handling
      handleModels(data);
    } else {
      console.warn('Invalid response format from getAiProviderOptions, using empty defaults');
      resetProviderOptions();
    }
  } catch (error) {
    console.error('Error loading provider options:', error);
    resetProviderOptions();
  }
};

// Process provider data
const handleProviders = (data) => {
  if (data.providers) {
    // Set provider options with fallbacks for missing properties
    providerOptions.languageModel = Array.isArray(data.providers.languageModel) ?
      data.providers.languageModel : [];
    providerOptions.embedding = Array.isArray(data.providers.embedding) ?
      data.providers.embedding : [];

    console.log('Found providers:', {
      languageModelLength: providerOptions.languageModel.length,
      embeddingLength: providerOptions.embedding.length
    });
  } else {
    console.warn('No providers found in API response, using empty defaults');
    providerOptions.languageModel = [];
    providerOptions.embedding = [];
  }
};

// Process models data
const handleModels = (data) => {
  if (data.models) {
    // Clear existing models first
    Object.keys(modelOptions.languageModel).forEach(key => delete modelOptions.languageModel[key]);
    Object.keys(modelOptions.embedding).forEach(key => delete modelOptions.embedding[key]);

    // Set model options with fallbacks
    if (data.models.languageModel) {
      Object.assign(modelOptions.languageModel, data.models.languageModel);
    }
    if (data.models.embedding) {
      Object.assign(modelOptions.embedding, data.models.embedding);
    }

    console.log('Found models:', {
      languageModelProviders: Object.keys(modelOptions.languageModel),
      embeddingProviders: Object.keys(modelOptions.embedding)
    });
  } else {
    console.warn('No models found in API response, using empty defaults');
    modelOptions.languageModel = {};
    modelOptions.embedding = {};
  }
};

// Reset provider options to defaults
const resetProviderOptions = () => {
  providerOptions.languageModel = [];
  providerOptions.embedding = [];
  modelOptions.languageModel = {};
  modelOptions.embedding = {};
};

// Load provider settings from API
const loadProviderSettings = async () => {
  try {
    // Get current settings
    const settingsResponse = await aiProviderService.getAiProviderSettings();
    console.log('AI provider settings response (raw):', settingsResponse);

    // Enhanced debugging information
    console.log('Settings response structure check:', {
      hasSuccessFlag: !!settingsResponse?.success,
      hasDataProperty: !!settingsResponse?.data,
      dataType: settingsResponse?.data ? typeof settingsResponse.data : 'undefined'
    });

    // Process settings with better error handling for different response structures
    if (settingsResponse?.success && settingsResponse?.data) {
      resetSettingsToDefaults();
      processSettingsData(settingsResponse.data);
      validateProviderModelCombinations();
    } else {
      console.warn('Invalid response format from getAiProviderSettings, using defaults');
      resetSettingsToDefaults();
    }
  } catch (error) {
    console.error('Error loading provider settings:', error);
    resetSettingsToDefaults();
  }
};

// Reset settings to default values
const resetSettingsToDefaults = () => {
  Object.assign(settings, {
    language_model_provider: '',
    language_model: '',
    language_model_api_key: '',
    language_model_base_url: '',
    embedding_provider: '',
    embedding_model: '',
    embedding_api_key: '',
    embedding_base_url: '',
    enable_vector_similarity: false
  });
};

// Process settings data from API response
const processSettingsData = (settingsData) => {
  // Add more detailed logging to understand the structure
  console.log('Processing settings data:', settingsData);

  // Handle different possible data structures
  let dbSettings = [];
  let providers = {};

  // Check if settingsData has a settings array
  if (Array.isArray(settingsData.settings)) {
    dbSettings = settingsData.settings;
  } else if (Array.isArray(settingsData)) {
    // If settingsData itself is an array, it might be the settings
    dbSettings = settingsData;
  }

  console.log(`Found ${dbSettings.length} settings in the response`);

  // Apply database settings to the form
  dbSettings.forEach(setting => {
    if (setting && setting.key && setting.key in settings) {
      console.log(`Setting ${setting.key} = ${setting.value}`);
      // Ensure we don't set undefined or null values
      if (setting.value !== undefined && setting.value !== null) {
        settings[setting.key] = setting.value;
      }
    }
  });

  // Convert string 'true'/'false' to boolean for toggle
  settings.enable_vector_similarity = String(settings.enable_vector_similarity).toLowerCase() === 'true';
  
  // Ensure embedding settings are properly initialized
  // If vector similarity is enabled but no provider is set, set default
  if (settings.enable_vector_similarity && !settings.embedding_provider && providerOptions.embedding.length > 0) {
    settings.embedding_provider = providerOptions.embedding[0].value;
    // And set a default model
    onEmbeddingProviderChange();
  }

  // Set provider status if providers data exists
  if (settingsData.providers) {
    providers = settingsData.providers;
  }

  // Set language model provider settings
  if (providers.languageModel) {
    const lm = providers.languageModel;
    if (lm.provider) {
      console.log(`Setting language provider to ${lm.provider}`);
      settings.language_model_provider = lm.provider;
    }
    if (lm.model) {
      console.log(`Setting language model to ${lm.model}`);
      settings.language_model = lm.model;
    }
  }

  // Set embedding provider settings
  if (providers.embedding) {
    const em = providers.embedding;
    if (em.provider) {
      console.log(`Setting embedding provider to ${em.provider}`);
      settings.embedding_provider = em.provider;
    }
    if (em.model) {
      console.log(`Setting embedding model to ${em.model}`);
      settings.embedding_model = em.model;
    }
    if (em.enabled !== undefined) {
      const enabled = typeof em.enabled === 'boolean' ? em.enabled : String(em.enabled).toLowerCase() === 'true';
      console.log(`Setting vector similarity to ${enabled}`);
      settings.enable_vector_similarity = enabled;
    }
  }
};

// Validate provider/model combinations
const validateProviderModelCombinations = () => {
  // Check language model validity
  const hasValidLanguageModel = settings.language_model_provider && settings.language_model &&
    modelOptions.languageModel[settings.language_model_provider] &&
    modelOptions.languageModel[settings.language_model_provider].some(m => m.value === settings.language_model);

  if (!hasValidLanguageModel && settings.language_model_provider && modelOptions.languageModel[settings.language_model_provider]) {
    // Set to first available model
    const models = modelOptions.languageModel[settings.language_model_provider];
    if (models && models.length > 0) {
      console.log(`Setting default language model for ${settings.language_model_provider} to ${models[0].value}`);
      settings.language_model = models[0].value;
    }
  }

  // Check embedding model validity
  const hasValidEmbeddingModel = settings.embedding_provider && settings.embedding_model &&
    modelOptions.embedding[settings.embedding_provider] &&
    modelOptions.embedding[settings.embedding_provider].some(m => m.value === settings.embedding_model);

  if (!hasValidEmbeddingModel && settings.embedding_provider && modelOptions.embedding[settings.embedding_provider]) {
    // Set to first available model
    const models = modelOptions.embedding[settings.embedding_provider];
    if (models && models.length > 0) {
      console.log(`Setting default embedding model for ${settings.embedding_provider} to ${models[0].value}`);
      settings.embedding_model = models[0].value;
    }
  }
};

// Test language model connection
const testLanguageModel = async () => {
  testingLanguageModel.value = true;
  languageModelTestResult.value = '';

  try {
    // Save settings first to ensure we're testing the current config
    await saveSettings(true); // Silent save

    // Test the connection
    const response = await aiProviderService.testLanguageModelConnection();

    if (response.success) {
      languageModelTestSuccess.value = true;
      languageModelTestResult.value = `Connection successful! Model ${response.data.model} responded: "${response.data.response}"`;
    } else {
      languageModelTestSuccess.value = false;
      languageModelTestResult.value = response.message || 'Connection test failed';
    }
  } catch (error) {
    console.error('Error testing language model connection:', error);
    languageModelTestSuccess.value = false;
    languageModelTestResult.value = 'Connection test failed: ' + (error.message || 'Unknown error');
  } finally {
    testingLanguageModel.value = false;
  }
};

// Test embedding connection
const testEmbedding = async () => {
  testingEmbedding.value = true;
  embeddingTestResult.value = '';

  try {
    // Save settings first to ensure we're testing the current config
    await saveSettings(true); // Silent save

    // Test the connection
    const response = await aiProviderService.testEmbeddingConnection();

    if (response.success) {
      embeddingTestSuccess.value = true;
      embeddingTestResult.value = `Connection successful! Generated a ${response.data.dimensions}-dimensional embedding with ${response.data.provider} model.`;
    } else {
      embeddingTestSuccess.value = false;
      embeddingTestResult.value = response.message || 'Connection test failed';
    }
  } catch (error) {
    console.error('Error testing embedding connection:', error);
    embeddingTestSuccess.value = false;
    embeddingTestResult.value = 'Connection test failed: ' + (error.message || 'Unknown error');
  } finally {
    testingEmbedding.value = false;
  }
};

// Save settings
const saveSettings = async (silent = false) => {
  if (!silent) {
    saving.value = true;
    statusMessage.value = '';
  }

  try {
    // Convert settings to string before saving
    const settingsToSave = {
      language_model_provider: settings.language_model_provider,
      language_model: settings.language_model,
      language_model_api_key: settings.language_model_api_key,
      language_model_base_url: settings.language_model_base_url,
      embedding_provider: settings.embedding_provider,
      embedding_model: settings.embedding_model,
      embedding_api_key: settings.embedding_api_key,
      embedding_base_url: settings.embedding_base_url,
      enable_vector_similarity: String(settings.enable_vector_similarity)
    };
    
    // Debug log to see what we're actually saving
    console.log('Saving embedding settings:', {
      provider: settings.embedding_provider,
      model: settings.embedding_model,
      enabled: settings.enable_vector_similarity
    });

    // Enhanced debugging - log what we're trying to save
    console.log('Preparing to save AI provider settings:', settingsToSave);

    // Update settings in the database
    const response = await aiProviderService.updateAiProviderSettings(settingsToSave);
    
    // Enhanced response logging
    console.log('Save settings response:', response);

    // Improved response handling with more robust checks
    if (response && response.success) {
      if (!silent) {
        statusMessage.value = 'AI provider settings saved successfully';
        statusSuccess.value = true;
      }
    } else {
      if (!silent) {
        // More detailed error handling
        const errorMsg = response?.message || 
                         response?.error || 
                         'Failed to save settings - check console for details';
        statusMessage.value = errorMsg;
        statusSuccess.value = false;
        console.error('Settings save error details:', response);
      }
    }
  } catch (error) {
    console.error('Error saving AI provider settings:', error);
    // Log detailed error information
    console.error('Error details:', {
      message: error.message,
      name: error.name,
      stack: error.stack,
      response: error.response
    });
    
    if (!silent) {
      statusMessage.value = 'Failed to save settings: ' + (error.message || 'Unknown error');
      statusSuccess.value = false;
    }
  } finally {
    if (!silent) {
      saving.value = false;
    }
  }
};

// Initialize component
onMounted(() => {
  loadData();
});
</script>
