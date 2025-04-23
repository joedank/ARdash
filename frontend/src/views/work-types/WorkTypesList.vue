<template>
  <div class="container mx-auto px-4 py-8">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold">Work Types</h1>
      <div class="flex gap-2">
        <BaseButton 
          v-if="canManageWorkTypes"
          variant="primary" 
          @click="$router.push({ path: '/work-types/new' })"
        >
          Add Work Type
        </BaseButton>
      </div>
    </div>

    <!-- Filters -->
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-4 mb-6">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Search</label>
          <input 
            type="text" 
            v-model="filters.search" 
            class="w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white"
            placeholder="Search by name..." 
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Parent Bucket</label>
          <select 
            v-model="filters.parentBucket" 
            class="w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white"
          >
            <option value="">All Buckets</option>
            <option value="Interior-Structural">Interior-Structural</option>
            <option value="Interior-Finish">Interior-Finish</option>
            <option value="Exterior-Structural">Exterior-Structural</option>
            <option value="Exterior-Finish">Exterior-Finish</option>
            <option value="Mechanical">Mechanical</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Measurement Type</label>
          <select 
            v-model="filters.measurementType" 
            class="w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white"
          >
            <option value="">All Types</option>
            <option value="area">Area</option>
            <option value="linear">Linear</option>
            <option value="quantity">Quantity</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Loading state -->
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
      <p class="mt-2 text-gray-600 dark:text-gray-400">Loading work types...</p>
    </div>

    <!-- Error state -->
    <div v-else-if="error" class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4 mb-6">
      <p class="text-red-800 dark:text-red-400">{{ error }}</p>
      <BaseButton variant="secondary" @click="fetchWorkTypes" class="mt-2">Try Again</BaseButton>
    </div>

    <!-- Empty state -->
    <div v-else-if="!loading && filteredWorkTypes.length === 0" class="text-center py-12 bg-gray-50 dark:bg-gray-800 rounded-lg">
      <div class="inline-block rounded-full p-3 bg-gray-100 dark:bg-gray-700">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
      </div>
      <h3 class="mt-2 text-sm font-medium text-gray-900 dark:text-gray-100">No work types found</h3>
      <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
        {{ filters.search || filters.parentBucket || filters.measurementType ? 
          'Try adjusting your filters or search term.' : 
          'Get started by creating a new work type.' }}
      </p>
      <div class="mt-6" v-if="canManageWorkTypes">
        <BaseButton 
          variant="primary" 
          @click="$router.push({ path: '/work-types/new' })"
        >
          Add Work Type
        </BaseButton>
      </div>
    </div>

    <!-- Work types list -->
    <div v-else class="bg-white dark:bg-gray-800 rounded-lg shadow">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-900/50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Name</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Parent Bucket</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Measurement Type</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Units</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            <tr 
              v-for="workType in filteredWorkTypes" 
              :key="workType.id"
              class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="font-medium text-gray-900 dark:text-white">{{ workType.name }}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full" 
                  :class="{
                    'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400': workType.parentBucket.includes('Interior'),
                    'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400': workType.parentBucket.includes('Exterior'),
                    'bg-purple-100 text-purple-800 dark:bg-purple-900/20 dark:text-purple-400': workType.parentBucket === 'Mechanical'
                  }">
                  {{ workType.parentBucket }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full" 
                  :class="{
                    'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-400': workType.measurementType === 'area',
                    'bg-indigo-100 text-indigo-800 dark:bg-indigo-900/20 dark:text-indigo-400': workType.measurementType === 'linear',
                    'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400': workType.measurementType === 'quantity'
                  }">
                  {{ workType.measurementType }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ workType.suggestedUnits }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <a 
                  @click="$router.push({ name: 'work-type-detail', params: { id: workType.id } })" 
                  class="text-blue-600 hover:text-blue-900 dark:text-blue-400 dark:hover:text-blue-300 cursor-pointer mr-3"
                >
                  View
                </a>
                <a 
                  v-if="canManageWorkTypes"
                  @click="$router.push({ name: 'work-type-detail', params: { id: workType.id } })" 
                  class="text-indigo-600 hover:text-indigo-900 dark:text-indigo-400 dark:hover:text-indigo-300 cursor-pointer"
                >
                  Edit
                </a>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useAuthStore } from '@/store/auth';
import workTypesService from '@/services/work-types.service';
import BaseButton from '@/components/base/BaseButton.vue';

// Authentication and permissions
const authStore = useAuthStore();
const canManageWorkTypes = computed(() => {
  return authStore.user?.role === 'admin' || authStore.user?.role === 'estimator_manager';
});

// State
const workTypes = ref([]);
const loading = ref(true);
const error = ref(null);
const filters = ref({
  search: '',
  parentBucket: '',
  measurementType: ''
});

// Computed
const filteredWorkTypes = computed(() => {
  let result = [...workTypes.value];

  // Apply filters
  if (filters.value.search) {
    const searchTerm = filters.value.search.toLowerCase();
    result = result.filter(wt => 
      wt.name.toLowerCase().includes(searchTerm)
    );
  }

  if (filters.value.parentBucket) {
    result = result.filter(wt => 
      wt.parentBucket === filters.value.parentBucket
    );
  }

  if (filters.value.measurementType) {
    result = result.filter(wt => 
      wt.measurementType === filters.value.measurementType
    );
  }

  return result;
});

// Methods
const fetchWorkTypes = async () => {
  loading.value = true;
  error.value = null;

  try {
    const response = await workTypesService.getAllWorkTypes();
    if (response.success) {
      workTypes.value = response.data;
    } else {
      error.value = response.message || 'Failed to load work types';
    }
  } catch (err) {
    console.error('Error fetching work types:', err);
    error.value = 'An error occurred while loading work types';
  } finally {
    loading.value = false;
  }
};

// Watchers
watch(filters, () => {
  // No need to refetch, we're filtering client-side
}, { deep: true });

// Lifecycle hooks
onMounted(() => {
  fetchWorkTypes();
});
</script>
