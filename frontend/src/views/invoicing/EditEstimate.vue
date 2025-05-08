<template>
  <div class="edit-estimate">
    <div class="mb-6">
      <div class="flex items-center">
        <router-link :to="`/invoicing/estimate/${estimateId}`" class="text-blue-600 dark:text-blue-400 mr-2">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
        </router-link>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Edit Estimate</h1>
      </div>
      <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
        Update the estimate details below
      </p>
    </div>

    <form @submit.prevent="updateEstimate" class="space-y-6">
      <!-- Client and Date Info -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div class="mb-4">
          <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Client and Estimate Details</h2>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Client Selector -->
            <div class="col-span-1">
              <ClientSelector
                v-model="estimate.client"
                :error="errors.client"
                @update:modelValue="updateClient"
              />
              <!-- Hidden inputs to store IDs (use camelCase clientId) -->
               <input type="hidden" v-model="estimate.clientId">
               <input type="hidden" v-model="estimate.addressId">
            </div>

            <div class="col-span-1 space-y-4">
              <!-- Estimate Number -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Estimate Number
                </label>
                <input
                  type="text"
                  v-model="estimate.estimateNumber"
                  class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                  placeholder="e.g. EST-00001"
                  disabled
                />
                <div v-if="errors.estimateNumber" class="mt-1 text-sm text-red-600 dark:text-red-400">
                  {{ errors.estimateNumber }}
                </div>
              </div>

              <!-- Date Created -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Date Created
                </label>
                <input
                  type="date"
                  v-model="estimate.dateCreated"
                  class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                />
                <div v-if="errors.dateCreated" class="mt-1 text-sm text-red-600 dark:text-red-400">
                  {{ errors.dateCreated }}
                </div>
              </div>

              <!-- Valid Until -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Valid Until
                </label>
                <input
                  type="date"
                  v-model="estimate.validUntil"
                  class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                />
                <div v-if="errors.validUntil" class="mt-1 text-sm text-red-600 dark:text-red-400">
                  {{ errors.validUntil }}
                </div>
              </div>
              
              <!-- Status Dropdown -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Status
                </label>
                <select
                  v-model="estimate.status"
                  class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                  :disabled="isSubmitting"
                >
                  <option value="draft" :disabled="originalEstimate?.status !== 'draft'">Draft</option>
                  <option value="sent" :disabled="!['draft', 'sent'].includes(originalEstimate?.status)">Sent</option>
                  <option value="accepted" :disabled="!['sent', 'accepted'].includes(originalEstimate?.status)">Accepted</option>
                  <option value="rejected" :disabled="!['sent', 'rejected'].includes(originalEstimate?.status)">Rejected</option>
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
          <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Estimate Items</h2>

          <LineItemsEditor
            v-model="estimate.items" 
            @update:totals="updateTotals"
            :error="errors.items"
            :initial-discount="parseFloat(estimate.discountAmount) || 0"
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
                v-model="estimate.notes"
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
                v-model="estimate.terms"
                rows="4"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                placeholder="Add your estimate terms and conditions..."
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
              There was an error updating the estimate
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
          :to="`/invoicing/estimate/${estimateId}`"
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
          <span v-else>Update Estimate</span>
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, computed } from 'vue'; // Import computed
import { useRouter, useRoute } from 'vue-router';
import { toCamelCase, toSnakeCase } from '@/utils/casing';
import ClientSelector from '@/components/invoicing/ClientSelector.vue';
import LineItemsEditor from '@/components/invoicing/LineItemsEditor.vue';
import estimatesService from '@/services/estimates.service';

const router = useRouter();
const route = useRoute();
const estimateId = ref('');
const isEditing = computed(() => !!estimateId.value); // Define isEditing

// State
const estimate = ref({
  id: '',
  client: null,
  clientId: '',
  addressId: null,
  estimateNumber: '',
  dateCreated: '',
  validUntil: '',
  items: [],
  subtotal: 0,
  taxTotal: 0,
  discountAmount: 0,
  total: 0,
  notes: '',
  terms: '',
  status: 'draft'
});

const originalEstimate = ref(null); // To store the original state
const errors = ref({
  client: '',
  estimateNumber: '',
  dateCreated: '',
  validUntil: '',
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
    if (estimate.value.clientId !== newClientId || estimate.value.addressId !== newAddressId) {
      estimate.value.clientId = newClientId;
      estimate.value.addressId = newAddressId;
    }
  } else if (estimate.value.clientId || estimate.value.addressId) {
    // Clear values if client is null and values were previously set
    estimate.value.clientId = '';
    estimate.value.addressId = null;
  }
};

// Load estimate data
const loadEstimate = async () => {
  try {
    isLoading.value = true;
    formError.value = '';
    
    estimateId.value = route.params.id;
    const response = await estimatesService.getEstimate(estimateId.value);
    
    if (response && response.success && response.data) {
      const rawEstimateData = response.data;
      const clientData = rawEstimateData.client; // Keep client separate
      
      // Convert main estimate data to camelCase
      const camelCaseEstimate = toCamelCase(rawEstimateData);
      
      // Re-assign potentially normalized client data
      const camelClient = toCamelCase(clientData);
      camelClient.address =
        (camelClient.addresses ?? []).find(a => a.isPrimary) ||
        (camelClient.addresses ?? [])[0] || null;
      camelCaseEstimate.client = camelClient;
      
      // Normalize nested items array
      if (Array.isArray(camelCaseEstimate.items)) {
          camelCaseEstimate.items = camelCaseEstimate.items.map(item => toCamelCase(item));
      }
      
      // Set up client object for ClientSelector component (using camelCase addressId)
      if (camelCaseEstimate.client) {
        camelCaseEstimate.client.selectedAddressId = camelCaseEstimate.addressId;
      }
      
      // Create deep copy to use as original state reference
      originalEstimate.value = JSON.parse(JSON.stringify(camelCaseEstimate));
      
      // Apply all the data to our estimate ref
      // Ensure dates are formatted correctly for input type="date"
      camelCaseEstimate.dateCreated = camelCaseEstimate.dateCreated ? new Date(camelCaseEstimate.dateCreated).toISOString().split('T')[0] : '';
      camelCaseEstimate.validUntil = camelCaseEstimate.validUntil ? new Date(camelCaseEstimate.validUntil).toISOString().split('T')[0] : '';
      
      // clientId should now be populated by toCamelCase if client_id/client_fk_id existed
      
      estimate.value = camelCaseEstimate;
    } else {
      formError.value = response?.message || 'Failed to load estimate. Please try again.';
      router.push('/invoicing/estimates');
    }
  } catch (err) {
    console.error('Error loading estimate:', err);
    formError.value = err.message || 'An unexpected error occurred. Please try again.';
    router.push('/invoicing/estimates');
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
      estimate.value.subtotal = totals.subtotal;
      estimate.value.taxTotal = totals.taxTotal;
      estimate.value.discountAmount = totals.discount;
      estimate.value.total = totals.total;
      
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
    estimateNumber: '',
    dateCreated: '',
    validUntil: '',
    items: '',
    status: '' // Reset status error
  };
  
  // Client validation (use clientId for consistency)
  if (!estimate.value.clientId) {
    errors.value.client = 'Client is required';
    isValid = false;
  }
  
  // Estimate number validation
  if (!estimate.value.estimateNumber) {
    errors.value.estimateNumber = 'Estimate number is required';
    isValid = false;
  }
  
  // Date validation
  if (!estimate.value.dateCreated) {
    errors.value.dateCreated = 'Date created is required';
    isValid = false;
  }
  
  if (!estimate.value.validUntil) {
    errors.value.validUntil = 'Valid until date is required';
    isValid = false;
  }
  
  // Items validation
  if (estimate.value.items.length === 0) {
    errors.value.items = 'At least one estimate item is required';
    isValid = false;
  }

  // Status validation
  if (!['draft', 'sent', 'accepted', 'rejected'].includes(estimate.value.status)) {
    errors.value.status = 'Invalid status selected';
    isValid = false;
  }
  
  return isValid;
};

// Update estimate
const updateEstimate = async () => {
  if (!validateForm()) {
    return;
  }
  
  isSubmitting.value = true;
  formError.value = '';
  
  try {
    // Prepare estimate data for API, sending only necessary fields
    const estimateData = {
      // Only include clientId if it's actually changing
      ...(originalEstimate.value && originalEstimate.value.clientId !== estimate.value.clientId
        ? { clientId: estimate.value.clientId }
        : {}),
      // Only include addressId if it has changed
      ...(originalEstimate.value.addressId !== estimate.value.addressId
        ? { addressId: estimate.value.addressId }
        : {}),
      estimateNumber: estimate.value.estimateNumber,
      dateCreated: estimate.value.dateCreated,
      validUntil: estimate.value.validUntil,
      items: estimate.value.items,
      subtotal: estimate.value.subtotal,
      taxTotal: estimate.value.taxTotal,
      discountAmount: estimate.value.discountAmount,
      total: estimate.value.total,
      notes: estimate.value.notes,
      terms: estimate.value.terms,
      status: estimate.value.status, // Include the status
      generatePdf: estimate.value.status === 'sent' // Regenerate PDF only if marking as sent
    };
    
    // Convert payload to snake_case before sending
    const snakeCaseEstimateData = toSnakeCase(estimateData);
    
    // Update estimate
    const response = await estimatesService.updateEstimate(estimateId.value, snakeCaseEstimateData);
    
    if (response && response.success) { // Use &&
      // Navigate back to estimate details
      router.push(`/invoicing/estimate/${estimateId.value}`);
    } else { // Corrected else placement
      formError.value = response?.message || 'Failed to update estimate. Please try again.';
    }
  } catch (error) {
    console.error('Error updating estimate:', error);
    formError.value = error.message || 'An unexpected error occurred. Please try again.';
  } finally {
    isSubmitting.value = false;
  }
};

// Watch for client changes and update clientId and addressId
watch(
  () => estimate.value.client,
  (newClient) => {
    if (!newClient) return;
    estimate.value.clientId = newClient.id || newClient.clientId;
    estimate.value.addressId = newClient.selectedAddressId || null;
  },
  { deep: true }          // <- ensures address changes trigger
);

// Initialize component
onMounted(() => {
  loadEstimate();
});
</script>
