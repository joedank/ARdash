<template>
  <div class="llm-prompt-manager p-4">
    <h2 class="text-xl font-semibold mb-4">LLM Prompt Settings</h2>
    <p class="text-sm text-gray-600 dark:text-gray-300 mb-4">
      Manage the prompts used by the LLM estimate generator. These prompts guide the AI in generating accurate estimates for repair services.
    </p>
    
    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center py-4">
      <svg class="animate-spin h-5 w-5 text-indigo-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      <p class="ml-2">Loading prompts...</p>
    </div>
    
    <!-- Error Message -->
    <div v-if="error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
      {{ error }}
    </div>
    
    <!-- Success Message -->
    <div v-if="success" class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
      {{ success }}
    </div>
    
    <!-- No Prompts Message -->
    <div v-if="!loading && prompts.length === 0" class="text-center py-4">
      No prompts found.
    </div>
    
    <!-- Prompt Selector and Editor -->
    <div v-else>
      <div class="mb-4">
        <label for="promptSelector" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Select a prompt to edit
        </label>
        <select 
          id="promptSelector"
          v-model="selectedPromptId" 
          class="w-full rounded border border-gray-300 px-3 py-2 dark:bg-gray-700 dark:border-gray-600"
        >
          <option value="" disabled>Select a prompt to edit</option>
          <option v-for="prompt in prompts" :key="prompt.id" :value="prompt.id">
            {{ prompt.name }} - {{ prompt.description }}
          </option>
        </select>
      </div>
      
      <!-- Prompt Editor -->
      <div v-if="selectedPrompt" class="bg-white dark:bg-gray-800 rounded shadow p-4">
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-1">Name</label>
          <input 
            type="text" 
            v-model="selectedPrompt.name" 
            disabled 
            class="w-full rounded border border-gray-300 px-3 py-2 bg-gray-100 dark:bg-gray-700 dark:border-gray-600" 
          />
          <p class="text-xs text-gray-500 mt-1">
            Prompt names cannot be changed as they are used as identifiers in the system.
          </p>
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-1">Description</label>
          <input 
            type="text" 
            v-model="editForm.description" 
            class="w-full rounded border border-gray-300 px-3 py-2 dark:bg-gray-700 dark:border-gray-600" 
          />
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-1">Prompt Text</label>
          <textarea 
            v-model="editForm.prompt_text" 
            class="w-full rounded border border-gray-300 px-3 py-2 h-64 font-mono dark:bg-gray-700 dark:border-gray-600"
            placeholder="Enter prompt text"
          ></textarea>
          <p class="text-xs text-gray-500 mt-1">
            Format prompt templates carefully. Available placeholders depend on the prompt type.
          </p>
        </div>
        
        <div class="flex justify-end space-x-2">
          <button 
            @click="resetForm" 
            class="px-4 py-2 border border-gray-300 rounded shadow-sm hover:bg-gray-50 dark:border-gray-600 dark:hover:bg-gray-700"
          >
            Reset
          </button>
          <button 
            @click="savePrompt" 
            class="px-4 py-2 bg-indigo-600 text-white rounded shadow-sm hover:bg-indigo-700"
          >
            Save Changes
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, watch } from 'vue';
import llmPromptService from '@/services/llmPrompt.service';

export default {
  name: 'LLMPromptManager',
  
  setup() {
    const prompts = ref([]);
    const loading = ref(false);
    const error = ref('');
    const success = ref('');
    const selectedPromptId = ref('');
    const editForm = ref({
      description: '',
      prompt_text: ''
    });
    
    const selectedPrompt = computed(() => {
      return prompts.value.find(p => p.id === selectedPromptId.value) || null;
    });
    
    // Load prompts from the API
    const loadPrompts = async () => {
      loading.value = true;
      error.value = '';
      
      try {
        const response = await llmPromptService.getAllPrompts();
        prompts.value = response.data;
      } catch (err) {
        console.error('Error loading prompts:', err);
        error.value = 'Failed to load prompts. Please try again.';
      } finally {
        loading.value = false;
      }
    };
    
    // Update form when selected prompt changes
    watch(selectedPrompt, (newPrompt) => {
      if (newPrompt) {
        editForm.value = {
          description: newPrompt.description,
          prompt_text: newPrompt.prompt_text
        };
      } else {
        resetForm();
      }
    });
    
    // Reset form to current prompt values
    const resetForm = () => {
      if (selectedPrompt.value) {
        editForm.value = {
          description: selectedPrompt.value.description,
          prompt_text: selectedPrompt.value.prompt_text
        };
      }
    };
    
    // Save changes to the selected prompt
    const savePrompt = async () => {
      if (!selectedPrompt.value) return;
      
      loading.value = true;
      error.value = '';
      success.value = '';
      
      try {
        await llmPromptService.updatePrompt(selectedPrompt.value.id, editForm.value);
        success.value = 'Prompt updated successfully!';
        
        // Reload prompts to get updated data
        await loadPrompts();
      } catch (err) {
        console.error('Error saving prompt:', err);
        error.value = 'Failed to save prompt changes. Please try again.';
      } finally {
        loading.value = false;
      }
      
      // Clear success message after 3 seconds
      if (success.value) {
        setTimeout(() => {
          success.value = '';
        }, 3000);
      }
    };
    
    // Load prompts on component mount
    loadPrompts();
    
    return {
      prompts,
      loading,
      error,
      success,
      selectedPromptId,
      selectedPrompt,
      editForm,
      resetForm,
      savePrompt
    };
  }
};
</script>
