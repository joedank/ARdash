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
  } else {
    settings.embedding_model = '';
  }
  
  // Reset connection test result
  embeddingTestResult.value = '';
};

// Handle vector similarity toggle
const onVectorSimilarityToggle = () => {
  if (!settings.enable_vector_similarity) {
    // Clear embedding test result when disabled
    embeddingTestResult.value = '';
  }
};

// Load settings and options
const loadData = async () => {
  loading.value = true;
  
  try {
    // Get available provider options
    const optionsResponse = await aiProviderService.getAiProviderOptions();
    console.log('AI provider options response:', optionsResponse);
    
    if (optionsResponse.success && optionsResponse.data && optionsResponse.data.data) {
      // Check if providers property exists
      if (optionsResponse.data.data.providers) {
        // Set provider options with fallbacks for missing properties
        providerOptions.languageModel = optionsResponse.data.data.providers.languageModel || [];
        providerOptions.embedding = optionsResponse.data.data.providers.embedding || [];
      } else {
        console.warn('No providers found in API response, using empty defaults');
        providerOptions.languageModel = [];
        providerOptions.embedding = [];
      }
      
      // Check if models property exists
      if (optionsResponse.data.data.models) {
        // Set model options with fallbacks
        Object.assign(modelOptions.languageModel, optionsResponse.data.data.models.languageModel || {});
        Object.assign(modelOptions.embedding, optionsResponse.data.data.models.embedding || {});
      } else {
        console.warn('No models found in API response, using empty defaults');
        modelOptions.languageModel = {};
        modelOptions.embedding = {};
      }
    } else {
      console.warn('Invalid response format from getAiProviderOptions, using empty defaults');
      providerOptions.languageModel = [];
      providerOptions.embedding = [];
      modelOptions.languageModel = {};
      modelOptions.embedding = {};
    }
    
    // Get current settings
    const settingsResponse = await aiProviderService.getAiProviderSettings();
    console.log('AI provider settings response (raw):', settingsResponse);
    
    // Display detailed debugging info for troubleshooting
    if (settingsResponse) {
      console.log('Response success?', settingsResponse.success);
      console.log('Response data exists?', !!settingsResponse.data); 
      if (settingsResponse.data) {
        console.log('Response data.data exists?', !!settingsResponse.data.data);
        if (settingsResponse.data.data) {
          console.log('Response data.data keys:', Object.keys(settingsResponse.data.data));
          console.log('Settings array exists?', !!settingsResponse.data.data.settings);
          console.log('Providers object exists?', !!settingsResponse.data.data.providers);
        }
      }
    }
    
    if (settingsResponse.success && settingsResponse.data && settingsResponse.data.data) {
      // Extract settings from response
      const dbSettings = settingsResponse.data.data.settings || [];
      
      // Convert settings array to object
      dbSettings.forEach(setting => {
        if (setting && setting.key) {
          settings[setting.key] = setting.value;
        }
      });
      
      // Convert string 'true'/'false' to boolean for toggle
      settings.enable_vector_similarity = String(settings.enable_vector_similarity).toLowerCase() === 'true';
      
      // Set provider status if providers data exists
      if (settingsResponse.data.data.providers) {
        const providers = settingsResponse.data.data.providers;
        
        // Set language model provider settings
        if (providers.languageModel) {
          if (providers.languageModel.provider) {
            settings.language_model_provider = providers.languageModel.provider;
          }
          if (providers.languageModel.model) {
            settings.language_model = providers.languageModel.model;
          }
        }
        
        // Set embedding provider settings
        if (providers.embedding) {
          if (providers.embedding.provider) {
            settings.embedding_provider = providers.embedding.provider;
          }
          if (providers.embedding.model) {
            settings.embedding_model = providers.embedding.model;
          }
          if (providers.embedding.enabled !== undefined) {
            settings.enable_vector_similarity = Boolean(providers.embedding.enabled);
          }
        }
      } else {
        console.warn('No providers data found in settings response');
      }
    } else {
      console.warn('Invalid response format from getAiProviderSettings, using default values');
    }
  } catch (error) {
    console.error('Error loading AI provider data:', error);
    statusMessage.value = 'Failed to load AI provider settings';
    statusSuccess.value = false;
  } finally {
    loading.value = false;
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
      languageModelTestResult.value = `Connection successful! Model ${response.data.data.model} responded: "${response.data.data.response}"`;
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
      embeddingTestResult.value = `Connection successful! Generated a ${response.data.data.dimensions}-dimensional embedding with ${response.data.data.provider} model.`;
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
    
    // Update settings in the database
    const response = await aiProviderService.updateAiProviderSettings(settingsToSave);
    
    if (response.success) {
      if (!silent) {
        statusMessage.value = 'AI provider settings saved successfully';
        statusSuccess.value = true;
      }
    } else {
      if (!silent) {
        statusMessage.value = response.message || 'Failed to save settings';
        statusSuccess.value = false;
      }
    }
  } catch (error) {
    console.error('Error saving AI provider settings:', error);
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
