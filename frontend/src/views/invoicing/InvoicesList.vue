<template>
  <div class="invoices-list">
    <div class="mb-6 flex justify-between items-center">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Invoices</h1>
        <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
          Manage your invoices and get paid for your services
        </p>
      </div>
      <div class="flex gap-3">
        <router-link
          to="/invoicing/create-invoice"
          class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 dark:bg-blue-500 dark:hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="-ml-1 mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          New Invoice
        </router-link>
        <router-link
          to="/invoicing/estimates"
          class="inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          View Estimates
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
            @change="loadInvoices"
          >
            <option value="">All Statuses</option>
            <option value="draft">Draft</option>
            <option value="sent">Sent</option>
            <option value="viewed">Viewed</option>
            <option value="paid">Paid</option>
            <option value="overdue">Overdue</option>
          </select>
        </div>
        
        <!-- Client Filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Client</label>
          <select
            v-model="filters.clientId"
            class="w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
            @change="loadInvoices"
          >
            <option value="">All Clients</option>
            <!-- Assuming getAllClients returns objects with 'id' and 'display_name' -->
            <option v-for="client in clients" :key="client.id" :value="client.id">
              {{ client.display_name }}
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
            @change="loadInvoices"
          />
        </div>
        
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Date To</label>
          <input
            type="date"
            v-model="filters.dateTo"
            class="w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
            @change="loadInvoices"
          />
        </div>
      </div>
    </div>
    
    <!-- Invoice List -->
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
      <div v-if="isLoading" class="p-8 flex justify-center">
        <svg xmlns="http://www.w3.org/2000/svg" class="animate-spin h-8 w-8 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        </svg>
      </div>
      
      <div v-else-if="invoices.length === 0" class="p-8 text-center">
        <svg xmlns="http://www.w3.org/2000/svg" class="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        <p class="mt-2 text-gray-500 dark:text-gray-400">No invoices found. Create your first invoice to get started.</p>
        <div class="mt-4">
          <router-link
            to="/invoicing/create-invoice"
            class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 dark:bg-blue-500 dark:hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="-ml-1 mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            Create Invoice
          </router-link>
        </div>
      </div>
      
      <table v-else class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
        <thead class="bg-gray-50 dark:bg-gray-700">
          <tr>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
              Invoice #
            </th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
              Client
            </th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
              Date
            </th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
              Due Date
            </th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
              Total
            </th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
              Status
            </th>
            <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
              Actions
            </th>
          </tr>
        </thead>
        <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
          <tr v-for="invoice in invoices" :key="invoice.id" class="hover:bg-gray-50 dark:hover:bg-gray-700">
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm font-medium text-gray-900 dark:text-white">
                {{ invoice.invoiceNumber }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-900 dark:text-white">
                {{ getClientName(invoice.clientId) }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-500 dark:text-gray-400">
                {{ formatDate(invoice.dateCreated) }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-500 dark:text-gray-400">
                {{ formatDate(invoice.dateDue) }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm font-medium text-gray-900 dark:text-white">
                ${{ formatNumber(invoice.total) }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <select
                v-if="['draft', 'sent', 'viewed'].includes(invoice.status)"
                v-model="invoice.status"
                @change="updateInvoiceStatus(invoice)"
                class="text-xs leading-5 font-semibold rounded-full px-2 py-1 border-0 focus:ring-2 focus:ring-offset-0 focus:ring-blue-500"
                :class="getStatusClass(invoice.status)"
              >
                <option value="draft" v-if="invoice.status === 'draft'">Draft</option>
                <option value="sent" v-if="['draft', 'sent'].includes(invoice.status)">Sent</option>
                <option value="viewed" v-if="['sent', 'viewed'].includes(invoice.status)">Viewed</option>
                <option value="paid" v-if="['sent', 'viewed'].includes(invoice.status)">Paid</option>
              </select>
              <span v-else class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full" :class="getStatusClass(invoice.status)">
                {{ capitalize(invoice.status) }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <div class="flex justify-end gap-2">
                <router-link 
                  :to="`/invoicing/invoice/${invoice.id}`"
                  class="text-blue-600 dark:text-blue-400 hover:text-blue-900 dark:hover:text-blue-200"
                >
                  View
                </router-link>
                <a 
                  v-if="invoice.status === 'draft'"
                  @click.prevent="markAsSent(invoice.id)"
                  href="#"
                  class="text-green-600 dark:text-green-400 hover:text-green-900 dark:hover:text-green-200 cursor-pointer"
                >
                  Send
                </a>
                <a 
                  v-if="invoice.status === 'draft'"
                  @click.prevent="confirmDelete(invoice)"
                  href="#"
                  class="text-red-600 dark:text-red-400 hover:text-red-900 dark:hover:text-red-200 cursor-pointer"
                >
                  Delete
                </a>
                <a 
                  @click.prevent="downloadPdf(invoice.id)"
                  href="#"
                  class="text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200 cursor-pointer"
                >
                  PDF
                </a>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
      
      <!-- Pagination -->
      <div class="bg-white dark:bg-gray-800 px-4 py-3 flex items-center justify-between border-t border-gray-200 dark:border-gray-700 sm:px-6">
        <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
          <div>
            <p class="text-sm text-gray-700 dark:text-gray-300">
              Showing
              <span class="font-medium">{{ startIndex + 1 }}</span>
              to
              <span class="font-medium">{{ endIndex }}</span>
              of
              <span class="font-medium">{{ totalInvoices }}</span>
              results
            </p>
          </div>
          <div>
            <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
              <a
                href="#"
                @click.prevent="prevPage"
                :class="{ 'opacity-50 cursor-not-allowed': currentPage === 0 }"
                class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-sm font-medium text-gray-500 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-700"
              >
                <span class="sr-only">Previous</span>
                <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
                </svg>
              </a>
              <a
                href="#"
                @click.prevent="nextPage"
                :class="{ 'opacity-50 cursor-not-allowed': currentPage >= totalPages - 1 }"
                class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-sm font-medium text-gray-500 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-700"
              >
                <span class="sr-only">Next</span>
                <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
                </svg>
              </a>
            </nav>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <teleport to="body">
      <div v-if="showDeleteModal" class="fixed inset-0 z-50 overflow-y-auto">
        <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
          <div class="fixed inset-0 bg-gray-500 bg-opacity-75 dark:bg-gray-900 dark:bg-opacity-75 transition-opacity"></div>
          <span class="hidden sm:inline-block sm:align-middle sm:h-screen">&#8203;</span>
          <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full sm:p-6">
            <div>
              <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100 dark:bg-red-900">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-red-600 dark:text-red-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
              </div>
              <div class="mt-3 text-center sm:mt-5">
                <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white">
                  Delete Invoice
                </h3>
                <div class="mt-2">
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    Are you sure you want to delete invoice {{ invoiceToDelete?.invoiceNumber }}? This action cannot be undone.
                  </p>
                </div>
              </div>
            </div>
            <div class="mt-5 sm:mt-6 sm:grid sm:grid-cols-2 sm:gap-3 sm:grid-flow-row-dense">
              <button
                type="button"
                @click="deleteInvoice"
                class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-red-600 text-base font-medium text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:col-start-2 sm:text-sm"
              >
                Delete
              </button>
              <button
                type="button"
                @click="showDeleteModal = false"
                class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-base font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:col-start-1 sm:text-sm"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      </div>
    </teleport>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import invoicesService from '@/services/invoices.service';
import clientsService from '@/services/clients.service';

const router = useRouter();

// State
const invoices = ref([]);
const clients = ref([]);
const isLoading = ref(true);
const totalInvoices = ref(0);
const currentPage = ref(0);
const itemsPerPage = ref(10);
const totalPages = ref(1);
const filters = ref({
  status: '',
  clientId: '',
  dateFrom: '',
  dateTo: ''
});
const showDeleteModal = ref(false);
const invoiceToDelete = ref(null);

// Computed properties
const startIndex = computed(() => currentPage.value * itemsPerPage.value);
const endIndex = computed(() => {
  const end = startIndex.value + itemsPerPage.value;
  return end > totalInvoices.value ? totalInvoices.value : end;
});

// Load clients for filter dropdown
const loadClients = async () => {
  try {
    const response = await clientsService.getAllClients();
    if (response && response.success && Array.isArray(response.data)) { // Check if data is an array
      clients.value = response.data;
      console.log('Clients loaded for dropdown:', JSON.stringify(clients.value)); // Log loaded clients
    } else {
      console.error('Error loading clients or invalid data format:', response);
      clients.value = []; // Ensure it's an empty array on failure
    }
  } catch (error) {
    console.error('Exception loading clients:', error);
    clients.value = []; // Ensure it's an empty array on exception
  }
};

// Load invoices with pagination and filters
const loadInvoices = async () => {
  try {
    isLoading.value = true;
    
    const response = await invoicesService.listInvoices(
      filters.value,
      currentPage.value,
      itemsPerPage.value
    );
    
    if (response && response.success && response.data) {
      invoices.value = response.data.invoices || [];
      totalInvoices.value = response.data.total || 0;
      totalPages.value = response.data.totalPages || 1;
    } else {
      console.error('Error loading invoices:', response);
    }
  } catch (error) {
    console.error('Error loading invoices:', error);
  } finally {
    isLoading.value = false;
  }
};

// Pagination methods
const prevPage = () => {
  if (currentPage.value > 0) {
    currentPage.value--;
    loadInvoices();
  }
};

const nextPage = () => {
  if (currentPage.value < totalPages.value - 1) {
    currentPage.value++;
    loadInvoices();
  }
};

// Actions
const markAsSent = async (id) => {
  try {
    const response = await invoicesService.markInvoiceAsSent(id);
    if (response && response.success) {
      // Reload invoices to reflect status change
      loadInvoices();
    } else {
      console.error('Error marking invoice as sent:', response);
    }
  } catch (error) {
    console.error('Error marking invoice as sent:', error);
  }
};

const confirmDelete = (invoice) => {
  invoiceToDelete.value = invoice;
  showDeleteModal.value = true;
};

const deleteInvoice = async () => {
  if (!invoiceToDelete.value) return;
  
  try {
    const response = await invoicesService.deleteInvoice(invoiceToDelete.value.id);
    if (response && response.success) {
      // Remove invoice from list
      invoices.value = invoices.value.filter(inv => inv.id !== invoiceToDelete.value.id);
      
      // Adjust total count
      totalInvoices.value--;
      
      // Reset modal
      showDeleteModal.value = false;
      invoiceToDelete.value = null;
    } else {
      console.error('Error deleting invoice:', response);
    }
  } catch (error) {
    console.error('Error deleting invoice:', error);
  }
};

const downloadPdf = async (id) => {
  try {
    // Get and download PDF
    const blob = await invoicesService.getInvoicePdf(id);
    
    // Create download link
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.style.display = 'none';
    a.href = url;
    a.download = `invoice_${id}.pdf`;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
  } catch (error) {
    console.error('Error downloading PDF:', error);
  }
};

// Helper methods
const getStatusClass = (status) => {
  switch (status) {
    case 'draft':
      return 'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-300';
    case 'sent':
      return 'bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-300';
    case 'viewed':
      return 'bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-300';
    case 'paid':
      return 'bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-300';
    case 'overdue':
      return 'bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-300';
    default:
      return 'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-300';
  }
};

const getClientName = (clientId) => {
  if (!clientId || !clients.value || clients.value.length === 0) return 'Unknown Client'; // Add check for populated clients array
  // Ensure comparison uses the correct ID property from the client object (likely 'id')
  const client = clients.value.find(c => c.id === clientId);
  // Use display_name which matches the backend model field name
  return client ? client.display_name : 'Unknown Client';
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleDateString();
};

const formatNumber = (value) => {
  return parseFloat(value).toFixed(2);
};

// Function to update invoice status
const updateInvoiceStatus = async (invoice) => {
  try {
    const response = await invoicesService.updateInvoice(invoice.id, { status: invoice.status });
    if (response && response.success) {
      // Reload the invoices to get updated data
      await loadInvoices();
    } else {
      console.error('Error updating invoice status:', response);
      // Reload to revert status if update failed
      await loadInvoices();
    }
  } catch (error) {
    console.error('Error updating invoice status:', error);
    // Reload to revert status if update failed
    await loadInvoices();
  }
};

const capitalize = (str) => {
  if (!str) return '';
  return str.charAt(0).toUpperCase() + str.slice(1);
};

// Initialize
onMounted(async () => {
  await Promise.all([loadClients(), loadInvoices()]);
});
</script>
