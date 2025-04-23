<template>
  <div class="space-y-4">
    <!-- Wizard Progress Indicator -->
    <div class="flex justify-between items-center mb-4">
      <div class="flex space-x-2 items-center">
        <div 
          class="w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium"
          :class="state.phase === 'idle' 
            ? 'bg-blue-600 text-white dark:bg-blue-500' 
            : 'bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-300'"
        >1</div>
        <div class="text-sm font-medium" :class="state.phase === 'idle' ? 'text-gray-900 dark:text-gray-100' : 'text-gray-500 dark:text-gray-400'">Assessment</div>
      </div>
      <div class="w-12 h-0.5" :class="state.phase === 'idle' || state.phase === 'clarify' ? 'bg-blue-600 dark:bg-blue-500' : 'bg-gray-200 dark:bg-gray-700'"></div>
      <div class="flex space-x-2 items-center">
        <div 
          class="w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium"
          :class="state.phase === 'clarify' 
            ? 'bg-blue-600 text-white dark:bg-blue-500' 
            : 'bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-300'"
        >2</div>
        <div class="text-sm font-medium" :class="state.phase === 'clarify' ? 'text-gray-900 dark:text-gray-100' : 'text-gray-500 dark:text-gray-400'">Clarifications</div>
      </div>
      <div class="w-12 h-0.5" :class="state.phase === 'review' ? 'bg-blue-600 dark:bg-blue-500' : 'bg-gray-200 dark:bg-gray-700'"></div>
      <div class="flex space-x-2 items-center">
        <div 
          class="w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium"
          :class="state.phase === 'review' 
            ? 'bg-blue-600 text-white dark:bg-blue-500' 
            : 'bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-300'"
        >3</div>
        <div class="text-sm font-medium" :class="state.phase === 'review' ? 'text-gray-900 dark:text-gray-100' : 'text-gray-500 dark:text-gray-400'">Review</div>
      </div>
    </div>

    <!-- Step 1: Initial Assessment Form -->
    <div v-if="state.phase === 'idle'" class="bg-white dark:bg-gray-800 p-4 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700">
      <StartForm @submit="startEstimate" :loading="state.loading" />
    </div>

    <!-- Step 2: Clarify Additional Information -->
    <div v-else-if="state.phase === 'clarify'" class="bg-white dark:bg-gray-800 p-4 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700">
      <ClarifyForm
        :required-measurements="state.clarify.requiredMeasurements"
        :questions="state.clarify.questions"
        :loading="state.loading"
        @submit="submitClarifications"
      />
    </div>

    <!-- Step 3: Review Generated Items -->
    <div v-else-if="state.phase === 'review'" class="bg-white dark:bg-gray-800 p-4 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700">
      <ItemsReview
        :items="state.items"
        :loading="state.loading"
        @accept-match="acceptMatch"
        @create-estimate="createEstimate"
      />
    </div>

    <!-- Error State -->
    <div v-if="state.error" class="mt-4 p-3 bg-red-50 dark:bg-red-900/20 text-red-700 dark:text-red-300 rounded-md border border-red-200 dark:border-red-800">
      {{ state.error }}
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { useEstimateGenStore } from '@/stores/estimateGen';
import StartForm from './wizard/StartForm.vue';
import ClarifyForm from './wizard/ClarifyForm.vue';
import ItemsReview from './wizard/ItemsReview.vue';

// Use the Pinia store
const estimateStore = useEstimateGenStore();

// Computed state from the store
const state = computed(() => ({
  phase: estimateStore.getPhase,
  clarify: estimateStore.getClarify,
  items: estimateStore.getItems,
  loading: estimateStore.isLoading,
  error: estimateStore.getError
}));

// Start the estimate generation process
const startEstimate = (payload) => {
  return estimateStore.startGeneration(payload);
};

// Submit clarifications
const submitClarifications = (answers) => {
  return estimateStore.submitClarifications(answers);
};

// Accept a catalog match
const acceptMatch = ({ index, productId }) => {
  return estimateStore.acceptMatch({ index, productId });
};

// Create the final estimate
const createEstimate = (items) => {
  // This would typically call an API to create the estimate
  console.log('Creating estimate with items:', items);
  // You can add your own implementation here
};

// Reset the wizard state
const resetWizard = () => {
  estimateStore.resetState();
};
</script>

<style scoped>
/* All styling now uses Tailwind classes */
</style>
