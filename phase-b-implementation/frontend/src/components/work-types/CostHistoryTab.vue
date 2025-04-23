<template>
  <div class="px-4 py-5 sm:p-6">
    <div v-if="error" class="mb-4 p-3 bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200 rounded-lg">
      {{ error }}
    </div>
    
    <!-- Cost History Table -->
    <div class="mb-6">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100">Cost History</h3>
        <div class="flex items-center space-x-2">
          <label for="region-filter" class="text-sm text-gray-700 dark:text-gray-300">Region:</label>
          <select
            id="region-filter"
            v-model="selectedRegion"
            class="rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-gray-200 dark:ring-gray-600"
          >
            <option value="">All Regions</option>
            <option v-for="region in uniqueRegions" :key="region" :value="region">{{ region }}</option>
          </select>
        </div>
      </div>
      
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-800">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Date
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Region
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Material Cost
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Labor Cost
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Total Cost
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Updated By
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-if="loading">
              <td colspan="6" class="px-6 py-4 whitespace-nowrap text-center text-sm">
                <div class="flex justify-center items-center space-x-2">
                  <svg class="animate-spin h-5 w-5 text-indigo-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  <span>Loading cost history...</span>
                </div>
              </td>
            </tr>
            <tr v-else-if="filteredHistory.length === 0">
              <td colspan="6" class="px-6 py-4 whitespace-nowrap text-center text-sm text-gray-500 dark:text-gray-400">
                No cost history available.
              </td>
            </tr>
            <tr v-for="item in filteredHistory" :key="item.id" class="hover:bg-gray-50 dark:hover:bg-gray-800">
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                {{ formatDate(item.capturedAt) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                {{ item.region }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                {{ formatCurrency(item.unitCostMaterial) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                {{ formatCurrency(item.unitCostLabor) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-gray-100">
                {{ formatCurrency(item.unitCostMaterial + item.unitCostLabor) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                {{ item.updatedBy || 'System' }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    
    <!-- Cost Trend Chart (placeholder for future enhancement) -->
    <div class="mt-8">
      <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100 mb-4">Cost Trend</h3>
      <div class="bg-gray-100 dark:bg-gray-800 rounded-lg p-6 text-center">
        <p class="text-gray-600 dark:text-gray-400">
          Cost trend visualization will be implemented in a future update.
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import workTypesService from '@/services/work-types.service';

// Props
const props = defineProps({
  workTypeId: {
    type: String,
    required: true
  }
});

// Data
const costHistory = ref([]);
const loading = ref(true);
const error = ref(null);
const selectedRegion = ref('');

// Computed properties
const uniqueRegions = computed(() => {
  const regions = costHistory.value.map(item => item.region);
  return [...new Set(regions)];
});

const filteredHistory = computed(() => {
  if (!selectedRegion.value) {
    return costHistory.value;
  }
  
  return costHistory.value.filter(item => item.region === selectedRegion.value);
});

// Lifecycle hooks
onMounted(async () => {
  if (props.workTypeId) {
    await loadCostHistory();
  }
});

watch(() => props.workTypeId, async (newId) => {
  if (newId) {
    await loadCostHistory();
  }
});

// Methods
async function loadCostHistory() {
  loading.value = true;
  error.value = null;
  
  try {
    const response = await workTypesService.getCostHistory(props.workTypeId);
    
    if (response.success && response.data) {
      costHistory.value = Array.isArray(response.data) ? response.data : [response.data];
    } else {
      error.value = response.message || 'Failed to load cost history';
    }
  } catch (err) {
    error.value = err.message || 'An error occurred while loading cost history';
  } finally {
    loading.value = false;
  }
}

function formatCurrency(value) {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2
  }).format(value || 0);
}

function formatDate(dateString) {
  if (!dateString) return '';
  
  const date = new Date(dateString);
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date);
}
</script>
