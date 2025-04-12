<template>
  <div class="estimate-controls border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <!-- Aggressiveness Slider -->
      <div class="md:col-span-2">
        <div class="mb-1 flex justify-between items-center">
          <label class="block text-xs font-medium text-gray-700 dark:text-gray-300">
            Aggressiveness: {{ Math.round(aggressiveness * 100) }}%
          </label>
          <span class="text-xs text-gray-500 dark:text-gray-400">
            {{ aggressiveness < 0.3 ? 'Conservative' : aggressiveness > 0.7 ? 'Aggressive' : 'Balanced' }}
          </span>
        </div>
        <input 
          type="range" 
          v-model.number="localAggressiveness" 
          min="0" 
          max="1" 
          step="0.05"
          class="w-full"
          @change="emitSettingsChange"
        />
        <div class="flex justify-between text-xs text-gray-500 dark:text-gray-400">
          <span>Conservative</span>
          <span>Balanced</span>
          <span>Aggressive</span>
        </div>
      </div>
      
      <!-- Estimation Mode Dropdown -->
      <div>
        <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
          Estimation Mode
        </label>
        <select 
          v-model="localMode" 
          class="w-full px-3 py-1.5 text-sm border rounded-md bg-white dark:bg-gray-700 dark:text-gray-200"
          @change="emitSettingsChange"
        >
          <option value="replace-focused">Replace-Focused</option>
          <option value="repair-focused">Repair-Focused</option>
          <option value="maintenance-focused">Maintenance-Focused</option>
          <option value="comprehensive">Comprehensive</option>
        </select>
        <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
          {{ getModeDescription() }}
        </p>
      </div>
      
      <!-- Regenerate Button -->
      <div class="flex items-end">
        <button
          @click="regenerate"
          :disabled="isLoading"
          class="w-full px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <span v-if="isLoading" class="flex items-center justify-center">
            <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            Regenerating...
          </span>
          <span v-else>
            Regenerate Estimate
          </span>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue';

const props = defineProps({
  aggressiveness: {
    type: Number,
    default: 0.6
  },
  mode: {
    type: String,
    default: 'replace-focused'
  },
  isLoading: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['regenerate', 'settingsChange']);

// Local state for controls
const localAggressiveness = ref(props.aggressiveness);
const localMode = ref(props.mode);

// Watch for props changes
watch(() => props.aggressiveness, (newValue) => {
  localAggressiveness.value = newValue;
});

watch(() => props.mode, (newValue) => {
  localMode.value = newValue;
});

/**
 * Emit settings change event
 */
const emitSettingsChange = () => {
  emit('settingsChange', {
    aggressiveness: localAggressiveness.value,
    mode: localMode.value
  });
};

/**
 * Emit regenerate event
 */
const regenerate = () => {
  emit('regenerate');
};

/**
 * Get description for the selected estimation mode
 */
const getModeDescription = () => {
  switch(localMode.value) {
    case 'replace-focused':
      return 'Prioritizes replacement over repair for damaged components.';
    case 'repair-focused':
      return 'Emphasizes repair solutions when possible, with fewer replacements.';
    case 'maintenance-focused':
      return 'Focuses on preventative maintenance to avoid future issues.';
    case 'comprehensive':
      return 'Includes all necessary work: repairs, replacements, and maintenance.';
    default:
      return '';
  }
};
</script>

<style scoped>
/* Add any component-specific styles here */
</style>