<template>
  <div class="estimates-list"> <!-- Root element starts -->
    <div class="mb-6 flex justify-between items-center">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Estimates</h1>
        <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
          Create and manage estimates for your clients
        </p>
      </div>
      <div class="flex gap-3">
        <ActionMenu
          buttonText="Create Estimate"
          :icon="true"
          :actions="createEstimateActions"
          @action="handleAction"
        >
          <template #icon>
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
          </template>
        </ActionMenu>

        <router-link
          to="/invoicing/invoices"
          class="inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          View Invoices
        </router-link>
      </div>
    </div>

    <!-- Filters -->
    <div class="mb-6 bg-white dark:bg-gray-800 rounded-lg shadow p-4">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <!-- Status Filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Status</label>
          <select
            v-model="filters.status"
            class="w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
            @change="loadEstimates"
          >
            <option value="">All Statuses</option>
            <option value="draft">Draft</option>
            <option value="sent">Sent</option>
            <option value="accepted">Accepted</option>
            <option value="rejected">Rejected</option>
          </select>
        </div>

        <!-- Client Filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Client</label>
          <select
            v-model="filters.clientId"
            class="w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
            @change="loadEstimates"
          >
            <option value="">All Clients</option>
            <option v-for="client in clients" :key="client.id" :value="client.id">
              {{ client.displayName }} <!-- Use camelCase -->
            </option>
          </select>
        </div>

        <!-- Date Range -->
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Date From</label>
          <input
            type="date"
            v-model="filters.dateFrom"
            class="w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
            @change="loadEstimates"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Date To</label>
          <input
            type="date"
            v-model="filters.dateTo"
            class="w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
            @change="loadEstimates"
          />
        </div>
      </div>
    </div>

    <!-- Estimate List -->
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
      <div v-if="isLoading" class="p-8 flex justify-center">
        <svg xmlns="http://www.w3.org/2000/svg" class="animate-spin h-8 w-8 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        </svg>
      </div>

      <div v-else-if="estimates.length === 0" class="p-8 text-center">
        <svg xmlns="http://www.w3.org/2000/svg" class="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        <p class="mt-2 text-gray-500 dark:text-gray-400">No estimates found. Create your first estimate to get started.</p>
        <div class="mt-4 flex justify-center space-x-4">
          <router-link
            to="/invoicing/create-estimate"
            class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 dark:bg-blue-500 dark:hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="-ml-1 mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            Create Estimate
          </router-link>          <router-link
            to="/invoicing/assessment-to-estimate"
            class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 dark:bg-purple-500 dark:hover:bg-purple-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="-ml-1 mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
            </svg>
            Create From Assessment
          </router-link>
        </div>
      </div>

      <!-- Estimate Table -->
      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Estimate #</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Client</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Date</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Status</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Total</th>
              <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-for="estimate in estimates" :key="estimate.id" class="hover:bg-gray-50 dark:hover:bg-gray-700">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm font-medium text-gray-900 dark:text-white">
                  {{ estimate.estimateNumber }}
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">{{ estimate.client?.displayName || 'N/A' }}</td> <!-- Use camelCase -->
              <td class="px-6 py-4 whitespace-nowrap">{{ formatDate(estimate.dateCreated) }}</td> <!-- Use dateCreated instead of createdAt -->
              <td class="px-6 py-4 whitespace-nowrap">
                <span :class="getStatusClass(estimate.status)" class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full">
                  {{ estimate.status }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">{{ formatCurrency(estimate.total) }}</td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                <router-link
                  v-if="estimate && estimate.id"
                  :to="`/invoicing/estimate/${estimate.id}`"
                  class="text-blue-600 hover:text-blue-900 dark:text-blue-400 dark:hover:text-blue-300"
                >View</router-link>
                <span v-else class="text-gray-400">View</span>                <router-link
                  v-if="estimate && estimate.id && estimate.status === 'draft'"
                  :to="`/invoicing/edit-estimate/${estimate.id}`"
                  class="text-indigo-600 hover:text-indigo-900 dark:text-indigo-400 dark:hover:text-indigo-300"
                >Edit</router-link>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="estimates.length > 0" class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-t border-gray-200 dark:border-gray-600">
        <BasePagination
          :current-page="currentPage"
          :total-pages="totalPages"
          :total-items="totalItems"
          :items-per-page="pageSize"
          @update:current-page="handlePageChange"
        />
      </div>
    </div> <!-- End of Estimate List div -->

    <!-- Generator Modal -->
    <Transition name="modal-fade">
      <div v-if="showGeneratorModal" class="fixed inset-0 z-40 overflow-y-auto">
        <!-- Background overlay with transition -->
        <Transition name="overlay-fade">
          <div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity"></div>
        </Transition>

        <!-- Modal content with transition -->
        <Transition name="modal-slide">
          <div class="flex min-h-screen items-center justify-center p-4">
            <div class="relative w-full max-w-4xl">
              <!-- Close Button -->
              <button
                @click="showGeneratorModal = false"
                class="absolute right-2 top-2 rounded-full bg-white p-1 text-gray-400 hover:text-gray-500 dark:bg-gray-800 dark:text-gray-400 dark:hover:text-gray-300"
              >
                <svg class="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>


              <!-- Unified LLM Estimate Generator -->
              <EstimateGeneratorContainer
                @close="showGeneratorModal = false"
                :assessmentData="selectedAssessmentData"
                @clearAssessment="selectedAssessmentData = null"
              />
            </div>
          </div>
        </Transition>
      </div>
    </Transition>

    <!-- Assessment Selection Modal for External LLM -->
    <div v-if="showAssessmentSelectionModal" class="fixed inset-0 z-40 overflow-y-auto">
      <!-- Modal Background Overlay -->
      <div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity"></div>

      <!-- Modal Content Container -->
      <div class="flex min-h-screen items-center justify-center p-4">
        <div class="relative w-full max-w-md bg-white dark:bg-gray-800 rounded-lg shadow-xl overflow-hidden">
          <!-- Header -->
          <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center">
            <h3 class="text-lg font-medium text-gray-900 dark:text-white">Select Assessment</h3>
            <button
              @click="showAssessmentSelectionModal = false"
              class="rounded-full p-1 text-gray-400 hover:text-gray-500 dark:text-gray-400 dark:hover:text-gray-300 focus:outline-none"
            >
              <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <!-- Modal Body -->
          <div class="px-6 py-4">
            <p class="mb-4 text-sm text-gray-600 dark:text-gray-400">
              Select an assessment to include context in your AI estimate generator. This will help generate more accurate estimates.
            </p>
            <div v-if="loadingAssessmentProjects" class="text-center py-4">
              <svg class="animate-spin h-6 w-6 text-blue-500 mx-auto" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">Loading assessment projects...</p>
            </div>

            <div v-else>
              <div class="mb-4">
                <label for="assessment-select" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Assessment Project
                </label>
                <select
                  id="assessment-select"
                  v-model="selectedAssessmentId"
                  class="w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                >
                  <option value="">Continue without assessment data</option>
                  <option v-for="project in assessmentProjects" :key="project.id" :value="project.id">
                    {{ project.client?.displayName || 'Unknown Client' }} - {{ formatDate(project.scheduledDate) }} <!-- Use camelCase -->
                  </option>
                </select>

                <div v-if="assessmentProjects.length === 0" class="mt-2 text-sm text-yellow-600 dark:text-yellow-400">
                  No assessment projects found. You can proceed without assessment data.
                </div>
              </div>
            </div>
          </div>

          <!-- Footer -->
          <div class="px-6 py-3 bg-gray-50 dark:bg-gray-700 text-right space-x-2">
            <button
              @click="showAssessmentSelectionModal = false"
              class="px-3 py-1.5 border border-gray-300 dark:border-gray-600 rounded text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Cancel
            </button>
            <button
              @click="proceedToAIGenerator"
              :disabled="loadingAssessmentData"
              class="px-3 py-1.5 bg-blue-600 border border-transparent rounded text-sm text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >            <span v-if="loadingAssessmentData">
                <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white inline-block" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Loading...
              </span>
              <span v-else>Continue</span>
            </button>
          </div>
        </div>
      </div>
    </div> <!-- End of Assessment Selection Modal -->

  </div> <!-- Root element ends -->
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
// Standardized Services
import estimateService from '@/services/standardized-estimates.service.js'
// Assuming standardized services exist for clients and projects
import clientService from '@/services/clients.service.js'
import projectsService from '@/services/standardized-projects.service.js'
import { formatDate, formatCurrency } from '@/utils/formatters'
import useErrorHandler from '@/composables/useErrorHandler.js' // Import error handler
import EstimateGeneratorContainer from '../../components/estimates/generator/EstimateGeneratorContainer.vue'
import ActionMenu from '@/components/common/ActionMenu.vue'
import BasePagination from '@/components/navigation/BasePagination.vue'

const router = useRouter()
const { handleError } = useErrorHandler() // Instantiate error handler
const isLoading = ref(true)
const estimates = ref([])
const clients = ref([])
// LLM generator state
const showGeneratorModal = ref(false)

// Pagination state
const currentPage = ref(1) // for BasePagination
const pageSize = ref(10)
const totalItems = ref(0)
const totalPages = ref(0)

// Assessment selection for external LLM
const showAssessmentSelectionModal = ref(false)
const assessmentProjects = ref([])
const loadingAssessmentProjects = ref(false)
const selectedAssessmentId = ref('')
const selectedAssessmentData = ref(null)
const loadingAssessmentData = ref(false)

const filters = ref({
  status: '',
  clientId: '',
  dateFrom: '',
  dateTo: ''
})

// Pagination methods
const handlePageChange = (newPage) => {
  currentPage.value = newPage;
  loadEstimates();
}

// Define actions for the Create Estimate dropdown menu
const createEstimateActions = computed(() => [
  {
    text: 'New Blank Estimate',
    to: '/invoicing/create-estimate',
    icon: '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" /></svg>'
  },
  {
    text: 'From Assessment',
    to: '/invoicing/assessment-to-estimate',
    icon: '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" /></svg>'
  },
  { divider: true },
  {
    text: 'Use AI Estimate Generator',
    action: () => {
      // First show assessment selection modal
      loadAssessmentProjects();
      showAssessmentSelectionModal.value = true;
    },
    icon: '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>'
  },
]);

// Handle action from the ActionMenu component
const handleAction = (action) => {
  if (action.action && typeof action.action === 'function') {
    action.action();
  }
};

const loadEstimates = async () => {
  isLoading.value = true
  try {
    // Use currentPage directly
    const calculatedPage = currentPage.value - 1; // Convert to 0-based for API
    const response = await estimateService.listEstimates(filters.value, calculatedPage, pageSize.value)
    console.log('Raw estimates response data:', response.data)

    // Check if the response has the expected structure (estimates + pagination)
    if (response.success && response.data) {
      // Verify we have actual estimate data by checking for estimate-specific properties
      if (Array.isArray(response.data)) {
        // Backend returned an array instead of paginated data structure
        // IMPORTANT FIX: Only include items that are definitely estimates by checking for estimate-specific properties
        // This prevents mixing with other entity types like clients, invoices, etc.
        const filteredEstimates = response.data.filter(item => {
          // Check for estimate-specific properties to ensure we only get estimates
          return (item.estimateNumber || item.estimate_number) &&
                 // Additional check to ensure it's not an invoice
                 !(item.invoiceNumber || item.invoice_number);
        });
        console.log(`Found ${filteredEstimates.length} actual estimates out of ${response.data.length} items`);

        // Create a proper paginated response structure
        estimates.value = filteredEstimates;
        totalItems.value = filteredEstimates.length;
        totalPages.value = Math.ceil(filteredEstimates.length / pageSize.value);
      } else if (response.data.estimates) {
        // The backend returns { estimates: [...], total, page, limit, totalPages }
        estimates.value = response.data.estimates
        totalItems.value = response.data.total || 0
        totalPages.value = response.data.totalPages || 1

        // Ensure current page is valid
        if (currentPage.value > totalPages.value && totalPages.value > 0) {
          currentPage.value = totalPages.value;
        }

        console.log('Pagination info:', {
          totalItems: totalItems.value,
          totalPages: totalPages.value,
          pageSize: pageSize.value,
          currentPage: currentPage.value,
          estimatesShown: estimates.value.length
        });
      } else {
        // Unexpected data structure
        console.error('Unexpected response format - no estimates array found:', response.data);
        estimates.value = [];
        totalItems.value = 0;
        totalPages.value = 1;
      }
    } else if (response.success && Array.isArray(response.data)) {
      // Handle case where response.data might be the array directly
      estimates.value = response.data
      // Can't set pagination metadata in this case
      totalItems.value = estimates.value.length
      totalPages.value = 1
    } else {
      console.error('Unexpected response format:', response)
      estimates.value = []
      totalItems.value = 0
      totalPages.value = 1
    }
  } catch (err) { // Use err convention for error object
    handleError(err, 'Failed to load estimates.') // Use handleError
    estimates.value = []
    totalItems.value = 0
    totalPages.value = 1
  } finally {
    isLoading.value = false
  }
}

const loadClients = async () => {
  try {
    const response = await clientService.getAllClients() // Correct method name
    if (response.success) {
      clients.value = response.data
    } else {
      handleError(new Error(response.message || 'Failed to load clients'), 'Failed to load clients.')
      clients.value = []
    }
  } catch (err) {
    handleError(err, 'Failed to load clients.')
    clients.value = []
  }
}

const getStatusClass = (status) => {
  const classes = {
    draft: 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300',
    sent: 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300',
    accepted: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300',
    rejected: 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'
  }
  return classes[status] || classes.draft
}

onMounted(() => {
  loadEstimates()
  loadClients()
})

// Load assessment projects for selection
const loadAssessmentProjects = async () => {
  loadingAssessmentProjects.value = true
  try {
    // Using standardized projectsService
    const response = await projectsService.getAll({ type: 'assessment' }) // Use BaseService method

    if (response.success && response.data) {
      // Filter for assessment projects with appropriate status using camelCase
      assessmentProjects.value = response.data
        .filter(p => p.type === 'assessment' && ['pending', 'in_progress'].includes(p.status))
        .sort((a, b) => new Date(b.scheduledDate) - new Date(a.scheduledDate)) // Use camelCase
    } else {
      handleError(new Error(response.message || 'Failed to load assessment projects'), 'Failed to load assessment projects.')
      assessmentProjects.value = []
    }
  } catch (err) {
    handleError(err, 'Failed to load assessment projects.')
    assessmentProjects.value = []
  } finally {
    loadingAssessmentProjects.value = false
  }
}

// Fetch assessment data and proceed to AI generator
const proceedToAIGenerator = async () => {
  // If no assessment is selected, simply proceed
  if (!selectedAssessmentId.value) {
    showAssessmentSelectionModal.value = false
    showGeneratorModal.value = true
    return
  }

  // Otherwise, fetch the assessment data first
  loadingAssessmentData.value = true
  try {
    const response = await estimateService.getAssessmentData(selectedAssessmentId.value)

    if (response.success && response.data) {
      selectedAssessmentData.value = response.data.rawAssessmentData
    } else {
      handleError(new Error(response.message || 'Failed to load assessment data'), 'Failed to load assessment data.')
      selectedAssessmentData.value = null
    }
  } catch (err) {
    handleError(err, 'Error fetching assessment data.')
    selectedAssessmentData.value = null
  } finally {
    loadingAssessmentData.value = false

    // Proceed to AI generator
    showAssessmentSelectionModal.value = false
    showGeneratorModal.value = true
  }
}
</script>

<style scoped>
.modal-fade-enter-active,
.modal-fade-leave-active,
.overlay-fade-enter-active,
.overlay-fade-leave-active,
.modal-slide-enter-active,
.modal-slide-leave-active {
  transition: all 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to,
.overlay-fade-enter-from,
.overlay-fade-leave-to {
  opacity: 0;
}

.modal-slide-enter-from,
.modal-slide-leave-to {
  transform: translateY(-20px);
  opacity: 0;
}
</style>
