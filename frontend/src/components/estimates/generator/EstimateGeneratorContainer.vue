<template>
  <div class="estimate-generator-container p-4 border border-gray-200 dark:border-gray-700 rounded-lg shadow-lg bg-white dark:bg-gray-800 relative z-50 mt-16">
    <h3 class="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">Service Estimate Generator</h3>

    <!-- Mode Toggle -->
    <div class="mb-6 border-b border-gray-200 dark:border-gray-700">
      <div class="flex space-x-4">
        <button
          @click="activeMode = 'builtin'"
          class="pb-2 px-1 font-medium text-sm border-b-2 transition-colors"
          :class="activeMode === 'builtin' ? 'text-blue-600 border-blue-600 dark:text-blue-400 dark:border-blue-400' : 'text-gray-500 border-transparent hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300'"
        >
          Built-in AI Generator
        </button>
        <button
          @click="activeMode = 'external'"
          class="pb-2 px-1 font-medium text-sm border-b-2 transition-colors"
          :class="activeMode === 'external' ? 'text-blue-600 border-blue-600 dark:text-blue-400 dark:border-blue-400' : 'text-gray-500 border-transparent hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300'"
        >
          External LLM Input
        </button>
        <button
          v-if="showWizardTab"
          @click="activeMode = 'wizard'"
          class="pb-2 px-1 font-medium text-sm border-b-2 transition-colors"
          :class="activeMode === 'wizard' ? 'text-blue-600 border-blue-600 dark:text-blue-400 dark:border-blue-400' : 'text-gray-500 border-transparent hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300'"
        >
          AI Wizard (v2)
        </button>
      </div>
    </div>

    <!-- Assessment Context Section (if assessment data is available) -->
    <div v-if="assessmentData" class="mb-4 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-md border border-blue-200 dark:border-blue-800">
      <div class="flex justify-between items-center mb-2">
        <h4 class="font-medium text-blue-800 dark:text-blue-300">Assessment Data Available</h4>
        <button
          @click="clearAssessment"
          class="text-xs text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300"
        >
          Clear
        </button>
      </div>
      <p class="text-sm text-blue-700 dark:text-blue-300">
        Using assessment data from project: {{ assessmentData.projectName || 'Unknown Project' }}
      </p>
    </div>

    <!-- Mode Components -->
    <BuiltInAIMode
      v-if="activeMode === 'builtin'"
      :assessment-data="assessmentData"
      @generated-items="handleGeneratedItems"
      @close="$emit('close')"
    />

    <ExternalPasteMode
      v-else-if="activeMode === 'external'"
      :assessment-data="assessmentData"
      @generated-items="handleGeneratedItems"
      @close="$emit('close')"
    />
    
    <EstimateWizard
      v-else-if="activeMode === 'wizard'"
      :assessment-data="assessmentData"
      @generated-items="handleGeneratedItems"
      @close="$emit('close')"
    />

    <!-- Items List and Catalog Actions -->
    <div v-if="showProductMatching && generatedItems.length > 0" class="mt-6 grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="md:col-span-2">
        <ItemsList
          :items="generatedItems"
          :catalog-matches="catalogMatches"
          @update:items="updateItems"
          @update:selected-indices="updateSelectedIndices"
          @highlight-source="highlightSource"
        />
      </div>
      <div class="md:col-span-1">
        <CatalogActions
          :items="generatedItems"
          :selected-item-indices="selectedItemIndices"
          @update:selected-item-indices="updateSelectedIndices"
          @update:items="updateItems"
        />
      </div>
    </div>

    <!-- Finish Button -->
    <div v-if="showProductMatching && generatedItems.length > 0" class="mt-6 flex justify-end">
      <button
        @click="finishEstimate"
        class="px-6 py-3 bg-green-600 text-white font-medium rounded-lg shadow hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 transition-colors"
      >
        Create Estimate
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, provide, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useToast } from 'vue-toastification';
import BuiltInAIMode from './modes/BuiltInAIMode.vue';
import ExternalPasteMode from './modes/ExternalPasteMode.vue';
import EstimateWizard from './modes/EstimateWizard.vue';
import ItemsList from './common/ItemsList.vue';
import CatalogActions from './common/CatalogActions.vue';
import catalogMatcherService from '@/services/catalog-matcher.service.js';

const props = defineProps({
  assessmentData: {
    type: Object,
    default: null
  }
});

const emit = defineEmits(['close', 'clearAssessment']);

const router = useRouter();
const toast = useToast();

// Feature flag check for showing the wizard tab
const showWizardTab = computed(() => {
  return import.meta.env.VITE_USE_ESTIMATE_V2 === 'true';
});

// State
const activeMode = ref('builtin');
const generatedItems = ref([]);
const showProductMatching = ref(false);
const selectedItemIndices = ref([]);
const catalogMatches = ref({});
const highlightedSourceId = ref(null);

// Provide shared state to child components
provide('generatorState', {
  activeMode,
  generatedItems,
  showProductMatching,
  selectedItemIndices,
  catalogMatches,
  highlightedSourceId
});

// Methods
const clearAssessment = () => {
  emit('clearAssessment');
};

const handleGeneratedItems = async (items) => {
  generatedItems.value = items;
  showProductMatching.value = true;

  // Check for catalog matches when items are generated
  await checkCatalogMatches(items);
};

const updateItems = (newItems) => {
  generatedItems.value = newItems;
};

const updateSelectedIndices = (indices) => {
  selectedItemIndices.value = indices;
};

const highlightSource = (sourceId) => {
  highlightedSourceId.value = sourceId;
};

const checkCatalogMatches = async (items) => {
  try {
    // Extract descriptions for similarity checking
    const descriptions = items.map(item => item.description);
    if (!descriptions.length) return;

    // Call the similarity checking service
    const response = await catalogMatcherService.checkSimilarity(descriptions);

    if (response.success && response.data) {
      // Convert array of matches to an object keyed by description
      const matchesMap = {};
      response.data.forEach(result => {
        // Find the best match for each description
        if (result.matches && result.matches.length > 0) {
          // Get the best match (already sorted by similarity)
          const bestMatch = result.matches[0];
          matchesMap[result.description] = bestMatch;
        }
      });

      catalogMatches.value = matchesMap;
      console.log('Catalog matches found:', Object.keys(matchesMap).length);
    }
  } catch (error) {
    console.error('Error checking catalog matches:', error);
    toast.error('Failed to check catalog matches');
  }
};

const finishEstimate = async () => {
  toast.success('Estimate preparation complete. Creating estimate...');

  await router.push({
    path: '/invoicing/create-estimate',
    query: {
      prefill: 'true',
      items: encodeURIComponent(JSON.stringify(generatedItems.value))
    }
  });

  emit('close');
};
</script>

<style scoped>
/* Component-specific styles */
</style>
