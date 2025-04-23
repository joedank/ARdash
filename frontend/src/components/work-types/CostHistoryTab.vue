<template>
  <div class="px-4 py-5 sm:p-6">
    <div v-if="error" class="mb-4 p-3 bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200 rounded-lg">
      {{ error }}
    </div>

    <div class="flex justify-between items-center mb-4">
      <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100">Cost History</h3>
      <div class="flex gap-2">
        <BaseSelect
          v-model="selectedRegion"
          :options="regionOptions"
          placeholder="All Regions"
          class="w-48"
        />
        <BaseButton
          variant="secondary"
          size="sm"
          @click="loadCostHistory"
        >
          Refresh
        </BaseButton>
      </div>
    </div>

    <div v-if="loading" class="flex justify-center items-center py-12">
      <svg class="animate-spin h-8 w-8 text-indigo-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
    </div>

    <div v-else-if="costHistory.length === 0" class="text-center py-12 bg-gray-50 dark:bg-gray-800 rounded-lg">
      <div class="inline-block rounded-full p-3 bg-gray-100 dark:bg-gray-700">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      </div>
      <h3 class="mt-2 text-sm font-medium text-gray-900 dark:text-gray-100">No cost history found</h3>
      <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
        {{ selectedRegion ? `No cost history found for region "${selectedRegion}".` : 'No cost history available for this work type.' }}
      </p>
    </div>

    <div v-else>
      <!-- Cost History Table -->
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-800">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Date
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
                Region
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-for="entry in costHistory" :key="entry.id" class="hover:bg-gray-50 dark:hover:bg-gray-800">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-gray-100">
                {{ formatDate(entry.capturedAt) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ formatCurrency(entry.unitCostMaterial) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ formatCurrency(entry.unitCostLabor) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ formatCurrency((entry.unitCostMaterial || 0) + (entry.unitCostLabor || 0)) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ entry.region }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Cost Trend Chart (if you have chart.js) -->
      <div v-if="costHistory.length > 1" class="mt-6">
        <h4 class="text-md font-medium text-gray-700 dark:text-gray-300 mb-4">Cost Trend Over Time</h4>
        <div class="bg-white dark:bg-gray-800 p-4 rounded-lg border border-gray-200 dark:border-gray-700">
          <!-- Placeholder for chart -->
          <div class="h-60 flex items-center justify-center">
            <p class="text-center text-gray-500 dark:text-gray-400">
              Cost trend chart would appear here if Chart.js is integrated.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseSelect from '@/components/form/BaseSelect.vue';
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
const regionOptions = ref([
  { value: '', label: 'All Regions' },
  { value: 'default', label: 'Default' },
  { value: 'northeast', label: 'Northeast' },
  { value: 'southeast', label: 'Southeast' },
  { value: 'midwest', label: 'Midwest' },
  { value: 'southwest', label: 'Southwest' },
  { value: 'west', label: 'West' },
  { value: 'pacific', label: 'Pacific' }
]);

// Watch for changes
watch(() => props.workTypeId, (newId) => {
  if (newId) {
    loadCostHistory();
  }
});

watch(() => selectedRegion.value, () => {
  loadCostHistory();
});

// Load cost history
onMounted(() => {
  if (props.workTypeId) {
    loadCostHistory();
  }
});

async function loadCostHistory() {
  loading.value = true;
  error.value = null;

  try {
    const response = await workTypesService.getCostHistory(props.workTypeId, selectedRegion.value);

    if (response.success) {
      costHistory.value = response.data;
    } else {
      error.value = response.message || 'Failed to load cost history';
    }
  } catch (err) {
    error.value = err.message || 'An error occurred while loading cost history';
  } finally {
    loading.value = false;
  }
}

// Formatting functions
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

function formatCurrency(value) {
  if (value === null || value === undefined) return 'Not set';

  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2
  }).format(value);
}
</script>