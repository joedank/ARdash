<template>
  <div class="estimates-list">
    <div class="mb-6 flex justify-between items-center">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Estimates</h1>
        <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
          Create and manage estimates for your clients
        </p>
      </div>
      <div class="flex gap-3">
        <router-link
          to="/invoicing/create-estimate"
          class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 dark:bg-blue-500 dark:hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="-ml-1 mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Create Estimate
        </router-link>

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
              {{ client.displayName }}
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
        <div class="mt-4 flex justify-center">
          <router-link
            to="/invoicing/create-estimate"
            class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 dark:bg-blue-500 dark:hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="-ml-1 mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            Create Estimate
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
              <td class="px-6 py-4 whitespace-nowrap">{{ estimate.client?.displayName || 'N/A' }}</td>
              <td class="px-6 py-4 whitespace-nowrap">{{ formatDate(estimate.dateCreated) }}</td>
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
                <span v-else class="text-gray-400">View</span>
                <router-link
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
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
// Standardized Services
import estimateService from '@/services/standardized-estimates.service.js'
import clientService from '@/services/clients.service.js'
import { formatDate, formatCurrency } from '@/utils/formatters'
import useErrorHandler from '@/composables/useErrorHandler.js'
import BasePagination from '@/components/navigation/BasePagination.vue'

const router = useRouter()
const { handleError } = useErrorHandler()
const isLoading = ref(true)
const estimates = ref([])
const clients = ref([])

// Pagination state
const currentPage = ref(1)
const pageSize = ref(10)
const totalItems = ref(0)
const totalPages = ref(0)

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

const loadEstimates = async () => {
  isLoading.value = true
  try {
    const calculatedPage = currentPage.value - 1; // Convert to 0-based for API
    const response = await estimateService.listEstimates(filters.value, calculatedPage, pageSize.value)
    console.log('Raw estimates response data:', response.data)

    // Check if the response has the expected structure (estimates + pagination)
    if (response.success && response.data) {
      // Verify we have actual estimate data by checking for estimate-specific properties
      if (Array.isArray(response.data)) {
        // Backend returned an array instead of paginated data structure
        // Only include items that are definitely estimates by checking for estimate-specific properties
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
      totalItems.value = estimates.value.length
      totalPages.value = 1
    } else {
      console.error('Unexpected response format:', response)
      estimates.value = []
      totalItems.value = 0
      totalPages.value = 1
    }
  } catch (err) {
    handleError(err, 'Failed to load estimates.')
    estimates.value = []
    totalItems.value = 0
    totalPages.value = 1
  } finally {
    isLoading.value = false
  }
}

const loadClients = async () => {
  try {
    const response = await clientService.getAllClients()
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
</script>

<style scoped>
/* No custom styles needed */
</style>