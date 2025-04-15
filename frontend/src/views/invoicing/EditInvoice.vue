<template>
  <div class="edit-invoice">
    <div class="mb-6">
      <div class="flex items-center">
        <router-link :to="`/invoicing/invoice/${invoiceId}`" class="text-blue-600 dark:text-blue-400 mr-2">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
        </router-link>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Edit Invoice</h1>
      </div>
      <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
        Update the invoice details below
      </p>
    </div>

    <form @submit.prevent="updateInvoice" class="space-y-6">
      <!-- Client and Date Info -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div class="mb-4">
          <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Client and Invoice Details</h2>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Client Selector -->
            <div class="col-span-1">
              <ClientSelector 
                v-model="invoice.client"
                :error="errors.client"
                @update:modelValue="updateClient"
              />
            </div>
            
            <div class="col-span-1 space-y-4">
              <!-- Invoice Number -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Invoice Number
                </label>
                <input
                  type="text"
                  v-model="invoice.invoiceNumber"
                  class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                  placeholder="e.g. INV-00001"
                />
                <div v-if="errors.invoiceNumber" class="mt-1 text-sm text-red-600 dark:text-red-400">
                  {{ errors.invoiceNumber }}
                </div>
              </div>
              
              <!-- Date Created -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Date Created
                </label>
                <input
                  type="date"
                  v-model="invoice.dateCreated"
                  class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                />
                <div v-if="errors.dateCreated" class="mt-1 text-sm text-red-600 dark:text-red-400">
                  {{ errors.dateCreated }}
                </div>
              </div>
              
              <!-- Due Date -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Due Date
                </label>
                <input
                  type="date"
                  v-model="invoice.dateDue"
                  class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                />
                <div v-if="errors.dateDue" class="mt-1 text-sm text-red-600 dark:text-red-400">
                  {{ errors.dateDue }}
                </div>
              </div>

              <!-- Status Dropdown -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Status
                </label>
                <select
                  v-model="invoice.status"
                  class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                  :disabled="isSubmitting"
                >
                  <option value="draft" :disabled="originalInvoice?.status !== 'draft'">Draft</option>
                  <option value="sent" :disabled="!['draft', 'sent'].includes(originalInvoice?.status)">Sent</option>
                  <option value="viewed" :disabled="!['sent', 'viewed'].includes(originalInvoice?.status)">Viewed</option>
                  <option value="paid" :disabled="!['sent', 'viewed', 'paid'].includes(originalInvoice?.status)">Paid</option>
                  <!-- Overdue is usually set automatically, not manually -->
                </select>
                <div v-if="errors.status" class="mt-1 text-sm text-red-600 dark:text-red-400">
                  {{ errors.status }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Line Items -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div class="mb-4">
          <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Invoice Items</h2>
          
          <LineItemsEditor 
            v-model="invoice.items"
            @update:totals="updateTotals"
            :error="errors.items"
            :initial-discount="parseFloat(invoice.discountAmount) || 0"
          />
        </div>
      </div>
      
      <!-- Notes and Terms -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div class="mb-4">
          <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Notes and Terms</h2>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Notes -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Notes (Optional)
              </label>
              <textarea
                v-model="invoice.notes"
                rows="4"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                placeholder="Add any notes for your client..."
              ></textarea>
            </div>
            
            <!-- Terms -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Terms and Conditions (Optional)
              </label>
              <textarea
                v-model="invoice.terms"
                rows="4"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                placeholder="Add your payment terms..."
              ></textarea>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Error Alert -->
      <div v-if="formError" class="bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-700 rounded-md p-4">
        <div class="flex">
          <div class="flex-shrink-0">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-red-400 dark:text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div class="ml-3">
            <h3 class="text-sm font-medium text-red-800 dark:text-red-300">
              There was an error updating the invoice
            </h3>
            <div class="mt-2 text-sm text-red-700 dark:text-red-400">
              {{ formError }}
            </div>
          </div>
        </div>
      </div>
      
      <!-- Submit Buttons -->
      <div class="flex justify-end space-x-3">
        <router-link
          :to="`/invoicing/invoice/${invoiceId}`"
          class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          Cancel
        </router-link>
        <button
          type="submit"
          class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 dark:bg-blue-500 dark:hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          :disabled="isSubmitting"
        >
          <span v-if="isSubmitting">Updating...</span>
          <span v-else>Update Invoice</span>
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { toCamelCase, toSnakeCase } from '@/utils/casing';
import { ref, onMounted, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import ClientSelector from '@/components/invoicing/ClientSelector.vue';
import LineItemsEditor from '@/components/invoicing/LineItemsEditor.vue';
import invoicesService from '@/services/invoices.service';

const router = useRouter();
const route = useRoute();
const invoiceId = ref('');

// State
const invoice = ref({
  id: '',
  client: null,
  clientId: '',
  addressId: null,
  invoiceNumber: '',
  dateCreated: '',
  dateDue: '',
  items: [],
  subtotal: 0,
  taxTotal: 0,
  discountAmount: 0,
  total: 0,
  notes: '',
  terms: '',
  status: 'draft'
});

const originalInvoice = ref(null); // To store the original state
const errors = ref({
  client: '',
  invoiceNumber: '',
  dateCreated: '',
  dateDue: '',
  items: '',
  status: '' // Added status error
});

const isSubmitting = ref(false);
const isLoading = ref(true);
const formError = ref('');

// Update client ID and address ID when client is selected
const updateClient = (client) => {
  // Only update if there's an actual change
  if (client) {
    const newClientId = client.id || client.clientId;
    const newAddressId = client.selectedAddressId || null;
    
    // Check if values are already set to avoid unnecessary updates
    if (invoice.value.clientId !== newClientId || invoice.value.addressId !== newAddressId) {
      invoice.value.clientId = newClientId;
      invoice.value.addressId = newAddressId;
    }
  } else if (invoice.value.clientId || invoice.value.addressId) {
    // Clear values if client is null and values were previously set
    invoice.value.clientId = '';
    invoice.value.addressId = null;
  }
};

// Load invoice data
const loadInvoice = async () => {
  try {
    isLoading.value = true;
    formError.value = '';
    
    invoiceId.value = route.params.id;
    const response = await invoicesService.getInvoice(invoiceId.value);
    
    if (response && response.success && response.data) { // Use &&
      const invoiceData = response.data;
      
      // Set up client object for ClientSelector component
      if (invoiceData.client) {
        invoiceData.client.selectedAddressId = invoiceData.addressId;
      }
      
      // Create deep copy to use as original state reference
      originalInvoice.value = JSON.parse(JSON.stringify(invoiceData));
      
      // Apply all the data to our invoice ref
      // Ensure dates are formatted correctly for input type="date"
      invoiceData.dateCreated = invoiceData.dateCreated ? new Date(invoiceData.dateCreated).toISOString().split('T')[0] : '';
      invoiceData.dateDue = invoiceData.dateDue ? new Date(invoiceData.dateDue).toISOString().split('T')[0] : '';
      invoice.value = invoiceData;

    } else { // Corrected else placement
      formError.value = response?.message || 'Failed to load invoice. Please try again.';
      router.push('/invoicing/invoices');
    }
  } catch (err) {
    console.error('Error loading invoice:', err);
    formError.value = err.message || 'An unexpected error occurred. Please try again.';
    router.push('/invoicing/invoices');
  } finally {
    isLoading.value = false;
  }
};

// Update totals when line items change with debouncing
let updateInProgress = false;
let updateTimer = null;

const updateTotals = (totals) => {
  // Cancel any pending updates
  if (updateTimer) {
    clearTimeout(updateTimer);
  }
  
  // Prevent recursive updates
  if (updateInProgress) return;
  
  try {
    updateInProgress = true;
    
    // Use a slightly longer timeout for better debouncing
    updateTimer = setTimeout(() => {
      invoice.value.subtotal = totals.subtotal;
      invoice.value.taxTotal = totals.taxTotal;
      invoice.value.discountAmount = totals.discount;
      invoice.value.total = totals.total;
      
      updateInProgress = false;
      updateTimer = null;
    }, 50);
  } catch (error) {
    console.error('Error updating totals:', error);
    updateInProgress = false;
  }
};

// Validate form
const validateForm = () => {
  let isValid = true;
  
  // Reset errors
  errors.value = {
    client: '',
    invoiceNumber: '',
    dateCreated: '',
    dateDue: '',
    items: '',
    status: '' // Reset status error
  };
  
  // Client validation
  if (!invoice.value.clientId) {
    errors.value.client = 'Client is required';
    isValid = false;
  }
  
  // Invoice number validation
  if (!invoice.value.invoiceNumber) {
    errors.value.invoiceNumber = 'Invoice number is required';
    isValid = false;
  }
  
  // Date validation
  if (!invoice.value.dateCreated) {
    errors.value.dateCreated = 'Date created is required';
    isValid = false;
  }
  
  if (!invoice.value.dateDue) {
    errors.value.dateDue = 'Due date is required';
    isValid = false;
  }
  
  // Items validation
  if (invoice.value.items.length === 0) {
    errors.value.items = 'At least one invoice item is required';
    isValid = false;
  }

  // Status validation
  if (!['draft', 'sent', 'viewed', 'paid', 'overdue'].includes(invoice.value.status)) {
    errors.value.status = 'Invalid status selected';
    isValid = false;
  }
  
  return isValid;
};

// Update invoice
const updateInvoice = async () => {
  if (!validateForm()) {
    return;
  }
  
  isSubmitting.value = true;
  formError.value = '';
  
  try {
    // Prepare invoice data for API
    const invoiceData = {
      clientId: invoice.value.clientId,
      addressId: invoice.value.addressId,
      invoiceNumber: invoice.value.invoiceNumber,
      dateCreated: invoice.value.dateCreated,
      dateDue: invoice.value.dateDue,
      items: invoice.value.items,
      subtotal: invoice.value.subtotal,
      taxTotal: invoice.value.taxTotal,
      discountAmount: invoice.value.discountAmount,
      total: invoice.value.total,
      notes: invoice.value.notes,
      terms: invoice.value.terms,
      status: invoice.value.status,
      generatePdf: true // Regenerate PDF with the updated information
    };
    
    // Convert payload to snake_case before sending
    const snakeCaseInvoiceData = toSnakeCase(invoiceData);
    
    // Update invoice
    const response = await invoicesService.updateInvoice(invoiceId.value, snakeCaseInvoiceData); // Send snake_case
    
    if (response && response.success) { // Use &&
      // Navigate back to invoice details
      router.push(`/invoicing/invoice/${invoiceId.value}`);
    } else { // Corrected else placement
      formError.value = response?.message || 'Failed to update invoice. Please try again.';
    }
  } catch (error) {
    console.error('Error updating invoice:', error);
    formError.value = error.message || 'An unexpected error occurred. Please try again.';
  } finally {
    isSubmitting.value = false;
  }
};

// Watch for client changes and update clientId and addressId
watch(() => invoice.value.client, (newClient) => {
  if (newClient) {
    const newClientId = newClient.id || newClient.clientId;
    const newAddressId = newClient.selectedAddressId || null;
    
    // Only update if values have changed to avoid unnecessary updates
    if (invoice.value.clientId !== newClientId || invoice.value.addressId !== newAddressId) {
      invoice.value.clientId = newClientId;
      invoice.value.addressId = newAddressId;
    }
  } else if (invoice.value.clientId || invoice.value.addressId) {
    // Clear values if client is null and values were previously set
    invoice.value.clientId = '';
    invoice.value.addressId = null;
  }
});

// Initialize component
onMounted(() => {
  loadInvoice();
});
</script>
