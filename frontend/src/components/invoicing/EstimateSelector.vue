<template>
  <div class="estimate-selector">
    <div class="flex w-full flex-col mb-4">
      <div class="flex justify-between mb-2">
        <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
          {{ label }}
        </label>
        <button 
          v-if="selectedEstimate"
          type="button" 
          @click="resetSelection"
          class="text-xs text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-200"
        >
          Reset Selection
        </button>
      </div>
      
      <!-- Selected Estimate Card -->
      <div 
        v-if="selectedEstimate" 
        class="border border-gray-200 dark:border-gray-700 rounded-md p-4 bg-white dark:bg-gray-800"
      >
        <div class="flex justify-between items-start">
          <div>
            <h3 class="text-base font-medium text-gray-900 dark:text-white">
              Estimate {{ selectedEstimate.number }}
            </h3>
            <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
              {{ formatDate(selectedEstimate.date_created) }}
            </p>
            <p class="mt-1 text-xs">
              <span class="px-2 py-0.5 rounded-full" 
                :class="getStatusClasses(selectedEstimate.status)">
                {{ formatStatus(selectedEstimate.status) }}
              </span>
            </p>
          </div>
          <div class="flex gap-2">
            <button 
              type="button"
              @click="openSelector"
              class="text-sm px-3 py-1.5 inline-flex items-center gap-1 text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30 rounded-md hover:bg-blue-100 dark:hover:bg-blue-900/40"
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
              </svg>
              Change
            </button>
          </div>
        </div>
        
        <!-- Estimate Total and Items Count -->
        <div class="mt-3 text-sm text-gray-600 dark:text-gray-400">
          <p>
            <span class="font-medium">Total:</span> ${{ formatCurrency(selectedEstimate.total) }}
          </p>
          <p>
            <span class="font-medium">Items:</span> {{ selectedEstimate.items?.length || 0 }} item(s)
          </p>
        </div>
      </div>
      
      <!-- Estimate Selection Button -->
      <button 
        v-else
        type="button"
        @click="openSelector"
        :disabled="!clientId"
        class="flex justify-center items-center gap-2 p-4 border-2 border-dashed border-gray-300 dark:border-gray-700 rounded-md hover:border-gray-400 dark:hover:border-gray-600 transition-colors bg-white dark:bg-gray-800 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400 dark:text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        <span class="text-sm text-gray-500 dark:text-gray-400">
          {{ !clientId ? 'Select a client first' : (placeholderText || 'Link an estimate to this project') }}
        </span>
      </button>
    </div>
    
    <!-- Error Message -->
    <p v-if="error" class="text-sm text-red-600 dark:text-red-400 mt-1">
      {{ error }}
    </p>
    
    <!-- Estimate Selection Modal -->
    <teleport to="body">
      <div
        v-if="isModalOpen"
        class="fixed inset-0 z-50 overflow-y-auto"
        @click.self="isModalOpen = false"
      >
        <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
          <!-- Background overlay -->
          <div class="fixed inset-0 bg-gray-500 bg-opacity-75 dark:bg-gray-900 dark:bg-opacity-75 transition-opacity"></div>
          
          <span class="hidden sm:inline-block sm:align-middle sm:h-screen">&#8203;</span>
          
          <div
            class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-2xl sm:w-full"
            role="dialog"
            aria-modal="true"
            @click.stop
          >
            <div class="bg-white dark:bg-gray-800 px-4 pt-5 pb-4 sm:p-6">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-medium text-gray-900 dark:text-white">
                  Select an Estimate
                </h3>
                <button
                  type="button"
                  @click="isModalOpen = false"
                  class="text-gray-400 hover:text-gray-500 dark:text-gray-500 dark:hover:text-gray-400"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
              
              <!-- Search Input -->
              <div class="mb-4">
                <div class="relative">
                  <input
                    type="text"
                    v-model="searchQuery"
                    placeholder="Search by estimate number..."
                    class="w-full pl-10 pr-4 py-2 border border-gray-300 dark:border-gray-700 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
                  />
                  <svg 
                    xmlns="http://www.w3.org/2000/svg" 
                    class="h-5 w-5 text-gray-400 dark:text-gray-500 absolute left-3 top-2.5" 
                    fill="none" 
                    viewBox="0 0 24 24" 
                    stroke="currentColor"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                  </svg>
                </div>
              </div>
              
              <!-- Filter Controls -->
              <div class="flex justify-end mb-2">
                <select
                  v-model="statusFilter"
                  class="text-sm px-3 py-1.5 border border-gray-300 dark:border-gray-700 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
                >
                  <option value="all">All Statuses</option>
                  <option value="draft">Draft</option>
                  <option value="sent">Sent</option>
                  <option value="accepted">Accepted</option>
                  <option value="rejected">Rejected</option>
                </select>
              </div>
              
              <!-- Loading Indicator -->
              <div v-if="isLoading" class="py-8 flex justify-center">
                <svg 
                  xmlns="http://www.w3.org/2000/svg" 
                  class="animate-spin h-8 w-8 text-blue-500"
                  fill="none" 
                  viewBox="0 0 24 24" 
                  stroke="currentColor"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                </svg>
              </div>
              
              <!-- No Results -->
              <div v-else-if="filteredEstimates.length === 0" class="py-8 text-center text-gray-500 dark:text-gray-400">
                <svg xmlns="http://www.w3.org/2000/svg" class="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <p class="mt-2">No estimates found for this client.</p>
              </div>
              
              <!-- Estimate List -->
              <div v-else class="overflow-y-auto max-h-96">
                <div
                  v-for="estimate in filteredEstimates"
                  :key="estimate.id"
                  @click="selectEstimate(estimate)"
                  class="mb-2 p-3 border border-gray-200 dark:border-gray-700 rounded-md cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700"
                >
                  <div class="flex justify-between items-start">
                    <div>
                      <h4 class="font-medium text-gray-900 dark:text-white">
                        Estimate {{ estimate.number }}
                      </h4>
                      <p class="text-sm text-gray-600 dark:text-gray-400">
                        {{ formatDate(estimate.date_created) }}
                      </p>
                      <p class="text-xs mt-1">
                        <span class="px-2 py-0.5 rounded-full" 
                          :class="getStatusClasses(estimate.status)">
                          {{ formatStatus(estimate.status) }}
                        </span>
                      </p>
                    </div>
                    <div class="text-right">
                      <p class="font-medium text-gray-900 dark:text-white">
                        ${{ formatCurrency(estimate.total) }}
                      </p>
                      <p class="text-xs text-gray-500 dark:text-gray-400">
                        {{ estimate.items?.length || 0 }} item(s)
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </teleport>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import estimatesService from '@/services/estimates.service';

const props = defineProps({
  modelValue: {
    type: Object,
    default: null
  },
  clientId: {
    type: String,
    default: null
  },
  label: {
    type: String,
    default: 'Estimate'
  },
  required: {
    type: Boolean,
    default: false
  },
  error: {
    type: String,
    default: ''
  },
  placeholderText: {
    type: String,
    default: ''
  }
});

const emit = defineEmits(['update:modelValue']);

// State
const estimates = ref([]);
const selectedEstimate = ref(props.modelValue);
const isModalOpen = ref(false);
const isLoading = ref(false);
const searchQuery = ref('');
const statusFilter = ref('all');

// Computed properties
const filteredEstimates = computed(() => {
  if (!estimates.value || estimates.value.length === 0) {
    return [];
  }
  
  let filtered = estimates.value;
  
  // Filter by status if not "all"
  if (statusFilter.value !== 'all') {
    filtered = filtered.filter(estimate => estimate.status === statusFilter.value);
  }
  
  // Filter by search query
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase();
    filtered = filtered.filter(estimate => {
      const number = estimate.number?.toLowerCase() || '';
      return number.includes(query);
    });
  }
  
  return filtered;
});

// Watch for model value changes
watch(() => props.modelValue, (newValue) => {
  // Avoid recursive updates by checking if the values are already equal
  if (JSON.stringify(selectedEstimate.value) !== JSON.stringify(newValue)) {
    selectedEstimate.value = newValue;
  }
});

// Watch for selected estimate changes
watch(selectedEstimate, (newValue) => {
  // Only emit update if there's an actual change
  if (JSON.stringify(props.modelValue) !== JSON.stringify(newValue)) {
    emit('update:modelValue', newValue);
  }
});

// Watch for client ID changes to reload estimates
watch(() => props.clientId, (newValue, oldValue) => {
  if (newValue !== oldValue) {
    if (newValue) {
      loadEstimates();
    } else {
      // Reset when client is cleared
      estimates.value = [];
      selectedEstimate.value = null;
    }
  }
});

// Format date as "Apr 2, 2025"
const formatDate = (dateString) => {
  if (!dateString) return 'N/A';
  
  const date = new Date(dateString);
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  });
};

// Format status for display
const formatStatus = (status) => {
  if (!status) return 'N/A';
  
  switch (status) {
    case 'draft': return 'Draft';
    case 'sent': return 'Sent';
    case 'accepted': return 'Accepted';
    case 'rejected': return 'Rejected';
    default: return status.charAt(0).toUpperCase() + status.slice(1);
  }
};

// Get status badge classes
const getStatusClasses = (status) => {
  switch (status) {
    case 'draft':
      return 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
    case 'sent':
      return 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300';
    case 'accepted':
      return 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300';
    case 'rejected':
      return 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300';
    default:
      return 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
  }
};

// Format currency
const formatCurrency = (value) => {
  if (value === undefined || value === null) return '0.00';
  return parseFloat(value).toFixed(2);
};

// Methods
const loadEstimates = async () => {
  if (!props.clientId) return;
  
  try {
    isLoading.value = true;
    const response = await estimatesService.listEstimates({ clientId: props.clientId }, 0, 100);
    
    if (response && response.data) {
      estimates.value = response.data.estimates || [];
    } else {
      console.error('Error loading estimates:', response);
      estimates.value = [];
    }
  } catch (error) {
    console.error('Error loading estimates:', error);
    estimates.value = [];
  } finally {
    isLoading.value = false;
  }
};

const selectEstimate = (estimate) => {
  // Check if this estimate is already selected to avoid unnecessary updates
  if (selectedEstimate.value && selectedEstimate.value.id === estimate.id) {
    isModalOpen.value = false;
    return;
  }
  
  selectedEstimate.value = estimate;
  isModalOpen.value = false;
};

const resetSelection = () => {
  selectedEstimate.value = null;
};

const openSelector = () => {
  if (!props.clientId) return;
  
  isModalOpen.value = true;
  loadEstimates();
};

// Load estimates on mount if client is already selected
onMounted(() => {
  if (props.clientId) {
    loadEstimates();
  }
});
</script>
