<template>
  <div class="container mx-auto px-4 py-6">
    <div v-if="error" class="mb-4 p-4 bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200 rounded-lg">
      {{ error }}
    </div>

    <div v-if="loading" class="flex justify-center items-center py-12">
      <svg class="animate-spin h-8 w-8 text-indigo-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      <span class="ml-2 text-gray-700 dark:text-gray-300">Loading work type details...</span>
    </div>

    <div v-else-if="workType" class="space-y-6">
      <!-- Header -->
      <div class="flex flex-col md:flex-row md:items-center md:justify-between">
        <div>
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900 dark:text-gray-100">{{ workType.name }}</h1>
            <span
              v-if="workType.revision > 1"
              class="ml-2 inline-flex items-center rounded-full bg-blue-100 dark:bg-blue-900 px-2.5 py-0.5 text-xs font-medium text-blue-800 dark:text-blue-200"
            >
              Rev. {{ workType.revision }}
            </span>
          </div>
          <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
            {{ formatParentBucket(workType.parentBucket) }} |
            {{ formatMeasurementType(workType.measurementType) }} |
            {{ workType.suggestedUnits }}
          </p>
        </div>

        <div class="mt-4 flex space-x-3 md:mt-0">
          <BaseButton
            variant="secondary"
            size="sm"
            @click="$router.push('/work-types')"
          >
            Back to List
          </BaseButton>
          <BaseButton
            v-if="canManageWorkTypes"
            variant="primary"
            size="sm"
            @click="openCostEditor"
          >
            Edit Costs
          </BaseButton>
        </div>
      </div>

      <!-- Tabs -->
      <div>
        <div class="border-b border-gray-200 dark:border-gray-700">
          <nav class="-mb-px flex space-x-8">
            <button
              v-for="tab in tabs"
              :key="tab.key"
              @click="activeTab = tab.key"
              class="py-4 px-1 text-sm font-medium border-b-2 whitespace-nowrap"
              :class="[
                activeTab === tab.key
                  ? 'border-indigo-500 text-indigo-600 dark:text-indigo-400'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 dark:text-gray-400 dark:hover:text-gray-300 dark:hover:border-gray-500'
              ]"
            >
              {{ tab.label }}
            </button>
          </nav>
        </div>
      </div>

      <!-- Tab Content -->
      <div class="bg-white dark:bg-gray-900 shadow rounded-lg overflow-hidden">
        <!-- Details Tab -->
        <div v-if="activeTab === 'details'" class="px-4 py-5 sm:p-6">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100 mb-4">Work Type Information</h3>

              <div class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Name</label>
                  <div class="mt-1 text-gray-900 dark:text-gray-100">{{ workType.name }}</div>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Parent Bucket</label>
                  <div class="mt-1 text-gray-900 dark:text-gray-100">{{ formatParentBucket(workType.parentBucket) }}</div>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Measurement Type</label>
                  <div class="mt-1 text-gray-900 dark:text-gray-100">{{ formatMeasurementType(workType.measurementType) }}</div>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Suggested Units</label>
                  <div class="mt-1 text-gray-900 dark:text-gray-100">{{ workType.suggestedUnits }}</div>
                </div>
              </div>
            </div>

            <div>
              <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100 mb-4">Cost Information</h3>

              <div v-if="workType.unitCostMaterial !== null || workType.unitCostLabor !== null || workType.productivityUnitPerHr !== null" class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Material Cost (per unit)</label>
                  <div class="mt-1 text-gray-900 dark:text-gray-100">
                    {{ workType.unitCostMaterial !== null ? formatCurrency(workType.unitCostMaterial) : 'Not set' }}
                  </div>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Labor Cost (per unit)</label>
                  <div class="mt-1 text-gray-900 dark:text-gray-100">
                    {{ workType.unitCostLabor !== null ? formatCurrency(workType.unitCostLabor) : 'Not set' }}
                  </div>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Productivity (units per hour)</label>
                  <div class="mt-1 text-gray-900 dark:text-gray-100">
                    {{ workType.productivityUnitPerHr !== null ? workType.productivityUnitPerHr : 'Not set' }}
                  </div>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Total Cost (per unit)</label>
                  <div class="mt-1 text-lg font-medium text-gray-900 dark:text-gray-100">
                    {{ calculateTotalCost() }}
                  </div>
                </div>

                <div v-if="workType.productivityUnitPerHr">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Cost Per Hour</label>
                  <div class="mt-1 text-gray-900 dark:text-gray-100">
                    {{ calculateCostPerHour() }}
                  </div>
                </div>
              </div>

              <div v-else class="p-4 bg-yellow-50 dark:bg-yellow-900/30 rounded-lg">
                <div class="flex">
                  <div class="flex-shrink-0">
                    <svg class="h-5 w-5 text-yellow-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                      <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                    </svg>
                  </div>
                  <div class="ml-3">
                    <h3 class="text-sm font-medium text-yellow-800 dark:text-yellow-200">No cost data defined</h3>
                    <div class="mt-2 text-sm text-yellow-700 dark:text-yellow-300">
                      <p>Click "Edit Costs" to add cost information for this work type.</p>
                    </div>
                  </div>
                </div>
              </div>

              <div v-if="workType.tags && workType.tags.length > 0" class="mt-6">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Safety & Permit Tags</label>
                <div class="flex flex-wrap gap-2">
                  <SafetyTagChip
                    v-for="tag in workType.tags"
                    :key="tag.tag"
                    :tag="tag.tag"
                    :removable="false"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Costs Tab -->
        <div v-if="activeTab === 'costs'" class="px-4 py-5 sm:p-6">
          <div class="flex justify-between items-center mb-6">
            <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100">Cost Management</h3>
            <BaseButton
              v-if="canManageWorkTypes"
              variant="primary"
              size="sm"
              @click="openCostEditor"
            >
              Edit Costs
            </BaseButton>
          </div>

          <div class="bg-white dark:bg-gray-900 shadow overflow-hidden sm:rounded-lg">
            <div class="px-4 py-5 sm:px-6 bg-gray-50 dark:bg-gray-800">
              <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-gray-100">Current Cost Details</h3>
              <p class="mt-1 max-w-2xl text-sm text-gray-500 dark:text-gray-400">Cost data for {{ workType.name }}</p>
            </div>

            <div class="border-t border-gray-200 dark:border-gray-700 px-4 py-5 sm:px-6">
              <dl class="grid grid-cols-1 gap-x-4 gap-y-8 sm:grid-cols-2">
                <div class="sm:col-span-1">
                  <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Material Cost (per unit)</dt>
                  <dd class="mt-1 text-sm text-gray-900 dark:text-gray-100">
                    {{ workType.unitCostMaterial !== null ? formatCurrency(workType.unitCostMaterial) : 'Not set' }}
                  </dd>
                </div>

                <div class="sm:col-span-1">
                  <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Labor Cost (per unit)</dt>
                  <dd class="mt-1 text-sm text-gray-900 dark:text-gray-100">
                    {{ workType.unitCostLabor !== null ? formatCurrency(workType.unitCostLabor) : 'Not set' }}
                  </dd>
                </div>

                <div class="sm:col-span-1">
                  <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Productivity (units per hour)</dt>
                  <dd class="mt-1 text-sm text-gray-900 dark:text-gray-100">
                    {{ workType.productivityUnitPerHr !== null ? workType.productivityUnitPerHr : 'Not set' }}
                  </dd>
                </div>

                <div class="sm:col-span-1">
                  <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Cost (per unit)</dt>
                  <dd class="mt-1 text-sm font-bold text-gray-900 dark:text-gray-100">
                    {{ calculateTotalCost() }}
                  </dd>
                </div>

                <div class="sm:col-span-1">
                  <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Cost Per Hour</dt>
                  <dd class="mt-1 text-sm text-gray-900 dark:text-gray-100">
                    {{ calculateCostPerHour() }}
                  </dd>
                </div>

                <div class="sm:col-span-1">
                  <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Last Updated</dt>
                  <dd class="mt-1 text-sm text-gray-900 dark:text-gray-100">
                    {{ workType.updatedAt ? formatDate(workType.updatedAt) : 'Never' }}
                  </dd>
                </div>
              </dl>
            </div>
          </div>

          <div v-if="costHistory && costHistory.length > 0" class="mt-8">
            <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100 mb-4">Cost History</h3>

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
                      Region
                    </th>
                  </tr>
                </thead>
                <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
                  <tr v-for="entry in costHistory" :key="entry.id" class="hover:bg-gray-50 dark:hover:bg-gray-800">
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                      {{ formatDate(entry.capturedAt) }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                      {{ entry.unitCostMaterial !== null ? formatCurrency(entry.unitCostMaterial) : 'Not set' }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                      {{ entry.unitCostLabor !== null ? formatCurrency(entry.unitCostLabor) : 'Not set' }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                      {{ entry.region }}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Materials & Safety Tab -->
        <div v-if="activeTab === 'materials-safety'">
          <MaterialsTab
            :work-type-id="workTypeId"
            :work-type-name="workType?.name"
            @updated="loadWorkType"
          />
        </div>

        <!-- History Tab -->
        <div v-if="activeTab === 'history'">
          <CostHistoryTab
            :work-type-id="workTypeId"
          />
        </div>
      </div>
    </div>

    <!-- Cost Editor Modal -->
    <CostEditor
      v-if="workType"
      :show="showCostEditor"
      :work-type="workType"
      @close="showCostEditor = false"
      @updated="handleCostUpdated"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import { useAuthStore } from '@/store/auth';
import BaseButton from '@/components/base/BaseButton.vue';
import CostEditor from '@/components/work-types/CostEditor.vue';
import MaterialsTab from '@/components/work-types/MaterialsTab.vue';
import CostHistoryTab from '@/components/work-types/CostHistoryTab.vue';
import SafetyTagChip from '@/components/work-types/SafetyTagChip.vue';
import workTypesService from '@/services/work-types.service';

const route = useRoute();
const authStore = useAuthStore();
const workTypeId = computed(() => route.params.id);

// Check if user can manage work types (admin or estimator_manager)
const canManageWorkTypes = computed(() => authStore.canManageWorkTypes);

// Data
const workType = ref(null);
const costHistory = ref([]);
const loading = ref(true);
const error = ref(null);

// Modal state
const showCostEditor = ref(false);

// Tabs
const activeTab = ref('details');
const tabs = [
  { key: 'details', label: 'Details' },
  { key: 'costs', label: 'Costs' },
  { key: 'materials-safety', label: 'Materials & Safety' },
  { key: 'history', label: 'History' }
];

// Lifecycle hooks
onMounted(async () => {
  if (workTypeId.value) {
    await loadWorkType();
    await loadCostHistory();
  }
});

watch(() => workTypeId.value, async (newId, oldId) => {
  if (newId && newId !== oldId) {
    await loadWorkType();
    await loadCostHistory();
  }
});

// Methods
async function loadWorkType() {
  loading.value = true;
  error.value = null;

  try {
    const response = await workTypesService.getById(workTypeId.value, {
      include_tags: true
    });

    if (response.success && response.data) {
      workType.value = response.data;
    } else {
      error.value = response.message || 'Failed to load work type';
    }
  } catch (err) {
    error.value = err.message || 'An error occurred while loading work type';
  } finally {
    loading.value = false;
  }
}

async function loadCostHistory() {
  try {
    const response = await workTypesService.getCostHistory(workTypeId.value);

    if (response.success && response.data) {
      costHistory.value = response.data;
    }
  } catch (err) {
    console.error('Failed to load cost history:', err);
  }
}

function formatParentBucket(bucket) {
  if (!bucket) return '';

  return bucket.replace(/-/g, ' ');
}

function formatMeasurementType(type) {
  if (!type) return '';

  const typeMap = {
    'area': 'Area',
    'linear': 'Linear',
    'quantity': 'Quantity'
  };

  return typeMap[type] || type;
}

function formatCurrency(value) {
  if (value === null || value === undefined) return 'Not set';

  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2
  }).format(value);
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

function calculateTotalCost() {
  if (!workType.value) return 'Not set';

  const materialCost = workType.value.unitCostMaterial || 0;
  const laborCost = workType.value.unitCostLabor || 0;

  if (materialCost === 0 && laborCost === 0) return 'Not set';

  return formatCurrency(materialCost + laborCost);
}

function calculateCostPerHour() {
  if (!workType.value) return 'Not set';

  const materialCost = workType.value.unitCostMaterial || 0;
  const laborCost = workType.value.unitCostLabor || 0;
  const productivity = workType.value.productivityUnitPerHr;

  if (!productivity) return 'Not set';

  const totalCost = materialCost + laborCost;
  return formatCurrency(totalCost * productivity);
}

function openCostEditor() {
  showCostEditor.value = true;
}

function handleCostUpdated(updatedWorkType) {
  workType.value = updatedWorkType;
  loadCostHistory();
}
</script>
