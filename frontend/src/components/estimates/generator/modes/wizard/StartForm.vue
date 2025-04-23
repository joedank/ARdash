<template>
  <div class="space-y-4">
    <h3 class="text-lg font-semibold text-gray-900 dark:text-gray-100">Smart AI Estimate Generation</h3>
    
    <div class="text-sm text-gray-700 dark:text-gray-300">
      <p>Enter your inspection notes below. The AI will analyze them and either:</p>
      <ul class="list-disc pl-5 mt-2 space-y-1">
        <li>Ask you for specific missing information (measurements or details)</li>
        <li>Generate a complete list of repair items with prices</li>
      </ul>
    </div>
    
    <div class="space-y-2">
      <label for="assessment" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Inspection Notes</label>
      <textarea
        id="assessment"
        v-model="assessment"
        class="w-full px-3 py-2 text-gray-700 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-300"
        rows="8"
        placeholder="Enter detailed inspection notes here..."
        :disabled="loading"
      ></textarea>
    </div>
    
    <div class="border-t border-gray-200 dark:border-gray-700 pt-4">
      <div class="mb-2">
        <button 
          type="button" 
          class="text-sm text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 underline focus:outline-none" 
          @click="showAdvanced = !showAdvanced"
        >
          {{ showAdvanced ? 'Hide' : 'Show' }} Advanced Options
        </button>
      </div>
      
      <div v-if="showAdvanced" class="bg-gray-50 dark:bg-gray-800/50 p-4 rounded-md border border-gray-200 dark:border-gray-700 space-y-4">
        <div class="space-y-2">
          <label for="temperature" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            Temperature: {{ options.temperature.toFixed(1) }}
          </label>
          <input
            id="temperature"
            v-model.number="options.temperature"
            type="range"
            class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"
            min="0"
            max="1"
            step="0.1"
            :disabled="loading"
          />
          <p class="text-xs text-gray-500 dark:text-gray-400">
            Lower values (0.1-0.3) give more consistent results. Higher values (0.7-1.0) give more creative results.
          </p>
        </div>
        
        <div class="space-y-2">
          <label for="hardThreshold" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            High Confidence Threshold: {{ options.hardThreshold.toFixed(2) }}
          </label>
          <input
            id="hardThreshold"
            v-model.number="options.hardThreshold"
            type="range"
            class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"
            min="0.5"
            max="0.95"
            step="0.05"
            :disabled="loading"
          />
          <p class="text-xs text-gray-500 dark:text-gray-400">
            Minimum similarity score (0-1) for automatic matching to existing products.
          </p>
        </div>
        
        <div class="space-y-2">
          <label for="softThreshold" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            Medium Confidence Threshold: {{ options.softThreshold.toFixed(2) }}
          </label>
          <input
            id="softThreshold"
            v-model.number="options.softThreshold"
            type="range"
            class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"
            min="0.3"
            max="0.8"
            step="0.05"
            :disabled="loading"
          />
          <p class="text-xs text-gray-500 dark:text-gray-400">
            Minimum similarity score (0-1) for suggesting matches. Anything below this is treated as a new product.
          </p>
        </div>
      </div>
    </div>
    
    <div class="flex justify-end mt-4">
      <BaseButton
        variant="primary"
        size="md"
        :loading="loading"
        :disabled="!isValid"
        @click="submitForm"
      >
        {{ loading ? 'Processing...' : 'Generate Estimate' }}
      </BaseButton>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import BaseButton from '@/components/base/BaseButton.vue';

const props = defineProps({
  loading: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['submit']);

const assessment = ref('');
const showAdvanced = ref(false);
const options = ref({
  temperature: 0.5,
  hardThreshold: 0.85,
  softThreshold: 0.60
});

// Validation
const isValid = computed(() => {
  return assessment.value.trim().length > 10;
});

// Form submission
const submitForm = () => {
  if (!isValid.value) return;
  
  emit('submit', {
    assessment: assessment.value,
    options: options.value
  });
};
</script>

<style scoped>
/* All styling now uses Tailwind classes */
</style>
