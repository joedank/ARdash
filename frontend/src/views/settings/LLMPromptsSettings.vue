<template>
  <div class="llm-prompts-settings">
    <div class="bg-white dark:bg-gray-800 shadow overflow-hidden sm:rounded-lg">
      <div class="px-4 py-5 sm:px-6 flex justify-between items-center">
        <div>
          <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-gray-100">LLM Prompts Settings</h3>
          <p class="mt-1 max-w-2xl text-sm text-gray-500 dark:text-gray-400">
            Configure prompts used by the AI estimate generator
          </p>
        </div>
        <div>
          <button
            @click="saveAllPrompts"
            class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 dark:bg-indigo-700 dark:hover:bg-indigo-600"
            :disabled="loading"
          >
            <span v-if="loading">Saving...</span>
            <span v-else>Save All Changes</span>
          </button>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="px-4 py-5 sm:p-6 text-center">
        <svg class="animate-spin h-8 w-8 text-indigo-600 mx-auto" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        <p class="mt-2 text-gray-600 dark:text-gray-400">Loading prompts...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="px-4 py-5 sm:p-6">
        <div class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-md p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-red-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-red-800 dark:text-red-300">Error loading prompts</h3>
              <div class="mt-2 text-sm text-red-700 dark:text-red-400">
                <p>{{ error }}</p>
              </div>
              <div class="mt-4">
                <button
                  @click="loadPrompts"
                  class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-red-700 dark:text-red-300 bg-red-100 dark:bg-red-900/40 hover:bg-red-200 dark:hover:bg-red-900/60 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                >
                  Try Again
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Prompts List -->
      <div v-else class="border-t border-gray-200 dark:border-gray-700 px-4 py-5 sm:p-0">
        <dl class="sm:divide-y sm:divide-gray-200 sm:dark:divide-gray-700">
          <div v-for="(prompt, index) in prompts" :key="prompt.id" class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
            <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">
              <div class="flex flex-col">
                <span>{{ prompt.name }}</span>
                <span class="text-xs text-gray-400 dark:text-gray-500 mt-1">{{ prompt.description }}</span>
              </div>
            </dt>
            <dd class="mt-1 text-sm text-gray-900 dark:text-gray-100 sm:mt-0 sm:col-span-2">
              <div class="space-y-2">
                <textarea
                  v-model="prompt.prompt_text"
                  rows="6"
                  class="shadow-sm block w-full focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm border border-gray-300 dark:border-gray-600 rounded-md dark:bg-gray-700 dark:text-gray-200"
                  :placeholder="`Enter ${prompt.name} prompt...`"
                ></textarea>
                <div class="flex justify-between items-center">
                  <button
                    @click="resetPrompt(index)"
                    class="inline-flex items-center px-2.5 py-1.5 border border-gray-300 dark:border-gray-600 shadow-sm text-xs font-medium rounded text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                    :disabled="!prompt.isModified"
                  >
                    Reset to Default
                  </button>
                  <span v-if="prompt.isModified" class="text-xs text-yellow-600 dark:text-yellow-400">Modified</span>
                </div>
              </div>
            </dd>
          </div>
        </dl>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import { useToast } from 'vue-toastification';
import llmPromptService from '@/services/llm-prompt.service.js';

const toast = useToast();

// State
const loading = ref(true);
const error = ref(null);
const prompts = ref([]);
const originalPrompts = ref({});

// Load prompts from the server
const loadPrompts = async () => {
  loading.value = true;
  error.value = null;

  try {
    const response = await llmPromptService.getAllPrompts();

    if (response.success && response.data) {
      // Initialize prompts with isModified flag
      const promptsData = response.data.data || response.data;
      prompts.value = promptsData.map(prompt => ({
        ...prompt,
        isModified: false
      }));

      // Store original values for reset functionality
      originalPrompts.value = {};
      promptsData.forEach(prompt => {
        originalPrompts.value[prompt.id] = prompt.prompt_text;
      });

      toast.success('Prompts loaded successfully');
    } else {
      error.value = response.message || 'Failed to load prompts';
      toast.error(error.value);
    }
  } catch (err) {
    console.error('Error loading prompts:', err);
    error.value = err.response?.data?.message || err.message || 'An unexpected error occurred';
    toast.error(error.value);
  } finally {
    loading.value = false;
  }
};

// Reset a prompt to its original value
const resetPrompt = (index) => {
  const prompt = prompts.value[index];
  if (prompt && originalPrompts.value[prompt.id]) {
    prompt.prompt_text = originalPrompts.value[prompt.id];
    prompt.isModified = false;
    toast.info(`Reset ${prompt.name} to default`);
  }
};

// Save all modified prompts
const saveAllPrompts = async () => {
  loading.value = true;

  try {
    // Filter only modified prompts
    const modifiedPrompts = prompts.value.filter(prompt => prompt.isModified);

    if (modifiedPrompts.length === 0) {
      toast.info('No changes to save');
      loading.value = false;
      return;
    }

    // Prepare data for update
    const promptsToUpdate = modifiedPrompts.map(prompt => ({
      id: prompt.id,
      description: prompt.description,
      prompt_text: prompt.prompt_text
    }));

    const response = await llmPromptService.updatePrompts(promptsToUpdate);

    if (response.success) {
      // Update original values and reset modified flags
      modifiedPrompts.forEach(prompt => {
        originalPrompts.value[prompt.id] = prompt.prompt_text;
        prompt.isModified = false;
      });

      toast.success(`Successfully updated ${modifiedPrompts.length} prompt(s)`);
    } else {
      error.value = response.message || 'Failed to save prompts';
      toast.error(error.value);
    }
  } catch (err) {
    console.error('Error saving prompts:', err);
    error.value = err.response?.data?.message || err.message || 'An unexpected error occurred';
    toast.error(error.value);
  } finally {
    loading.value = false;
  }
};

// Watch for changes in prompt content to set isModified flag
watch(() => prompts.value, (newPrompts) => {
  newPrompts.forEach(prompt => {
    if (originalPrompts.value[prompt.id] !== undefined && prompt.prompt_text !== originalPrompts.value[prompt.id]) {
      prompt.isModified = true;
    } else {
      prompt.isModified = false;
    }
  });
}, { deep: true });

// Load prompts on component mount
onMounted(() => {
  loadPrompts();
});
</script>

<style scoped>
/* Component-specific styles */
</style>
