<template>
  <div class="create-estimate">
    <div class="mb-6">
      <div class="flex items-center">
        <router-link to="/invoicing/estimates" class="text-blue-600 dark:text-blue-400 mr-2">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
        </router-link>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">{{ isEditing ? 'Edit Estimate' : 'Create New Estimate' }}</h1>
      </div>
      <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
        {{ isEditing ? 'Update the estimate details below' : 'Fill out the form below to create a new estimate' }}
      </p>
    </div>

    <form @submit.prevent="saveEstimate" class="space-y-6">
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
              <!-- Hidden inputs to store IDs -->
               <input type="hidden" v-model="estimate.client_fk_id">
               <input type="hidden" v-model="estimate.address_id">
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
                  :disabled="isGeneratingNumber || isEditing"
                />
                <div v-if="isGeneratingNumber &amp;&amp; !isEditing" class="mt-1 text-sm text-gray-500 dark:text-gray-400">
                  Generating estimate number...
                </div>
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

              <!-- Status Dropdown (only show when editing) -->
              <div v-if="isEditing">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Status
                </label>
                <select
                  v-model="estimate.status"
                  class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                  :disabled="isSubmitting"
                >
                  <option value="draft" :disabled="estimate.status !== 'draft'">Draft</option>
                  <option value="sent" :disabled="!['draft', 'sent'].includes(estimate.status)">Sent</option>
                  <option value="accepted" :disabled="!['sent', 'accepted'].includes(estimate.status)">Accepted</option>
                  <option value="rejected" :disabled="!['sent', 'rejected'].includes(estimate.status)">Rejected</option>
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
            :initial-discount="estimate.discountAmount"
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
              There was an error {{ isEditing ? 'updating' : 'creating' }} the estimate
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
          to="/invoicing/estimates"
          class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          Cancel
        </router-link>
        <button
          type="button"
          @click="saveDraft"
          class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          :disabled="isSubmitting"
        >
          Save as Draft
        </button>
        <button
          type="submit"
          class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 dark:bg-blue-500 dark:hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          :disabled="isSubmitting"
        >
          {{ isEditing ? 'Update Estimate' : 'Create and Send' }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, computed } from 'vue';
import { useRouter, useRoute } from 'vue-router'; // Import useRoute
import ClientSelector from '@/components/invoicing/ClientSelector.vue';
import LineItemsEditor from '@/components/invoicing/LineItemsEditor.vue';
import estimatesService from '@/services/estimates.service'; // Correct service import
import settingsService from '@/services/settings.service';

const router = useRouter();
const route = useRoute(); // Initialize useRoute

const estimateId = ref(route.params.id || null); // Get ID from route params
const isEditing = computed(() => !!estimateId.value); // Determine if editing

// State
const estimate = ref({ // Renamed invoice -> estimate
  client: null, // Client object from selector
  client_fk_id: '', // Foreign key to Client model
  address_id: '', // Foreign key to ClientAddress model
  estimateNumber: '', // Renamed
  dateCreated: new Date().toISOString().split('T')[0], // Today's date in YYYY-MM-DD format
  validUntil: '', // Renamed dateDue -> validUntil
  items: [],
  subtotal: 0,
  taxTotal: 0,
  discountAmount: 0,
  total: 0,
  notes: '',
  terms: '',
  status: 'draft'
});

const errors = ref({
  client: '',
  estimateNumber: '', // Renamed
  dateCreated: '',
  validUntil: '', // Renamed
  items: '',
  status: '' // Added status error
});

const isSubmitting = ref(false);
const isGeneratingNumber = ref(true);
const formError = ref('');

// Update client_fk_id and address_id when client/address selection changes
const updateClient = (client) => {
  // The client object passed from ClientSelector now includes selectedAddressId
  if (client && client.id) { // Check for client.id from the selected client object
    estimate.value.client_fk_id = client.id; // Use client.id for the foreign key
    estimate.value.address_id = client.selectedAddressId || null;
    errors.value.client = ''; // Clear client error if selected
  } else {
    estimate.value.client_fk_id = '';
    estimate.value.address_id = null;
  }
};

// Watch for changes emitted by ClientSelector (which includes selectedAddressId)
watch(() => estimate.value.client, (newClientValue) => {
    updateClient(newClientValue);
}, { deep: true });


// Update totals when line items change
const updateTotals = (totals) => {
  estimate.value.subtotal = totals.subtotal;
  estimate.value.taxTotal = totals.taxTotal;
  estimate.value.discountAmount = totals.discount;
  estimate.value.total = totals.total;
};

// Load existing estimate data if editing
const loadEstimateData = async () => {
  if (!isEditing.value) {
    await loadDefaults(); // Load defaults only for new estimates
    return;
  }

  try {
    isSubmitting.value = true; // Use submitting state for loading indicator
    const response = await estimatesService.getEstimate(estimateId.value);
    if (response && response.success && response.data) {
      const loadedEstimate = response.data;

      // Map loaded data to the estimate ref
      estimate.value = {
        ...estimate.value, // Keep potential defaults if some fields are missing
        client: loadedEstimate.client || null, // Assuming client object is included
        client_fk_id: loadedEstimate.client_fk_id || loadedEstimate.clientId, // Handle potential naming variations
        address_id: loadedEstimate.address_id,
        estimateNumber: loadedEstimate.estimateNumber,
        dateCreated: loadedEstimate.dateCreated ? new Date(loadedEstimate.dateCreated).toISOString().split('T')[0] : '',
        validUntil: loadedEstimate.validUntil ? new Date(loadedEstimate.validUntil).toISOString().split('T')[0] : '',
        items: loadedEstimate.items || [],
        subtotal: loadedEstimate.subtotal || 0,
        taxTotal: loadedEstimate.taxTotal || 0,
        discountAmount: loadedEstimate.discountAmount || 0,
        total: loadedEstimate.total || 0,
        notes: loadedEstimate.notes || '',
        terms: loadedEstimate.terms || '',
        status: loadedEstimate.status || 'draft' // Load existing status
      };

      // Ensure client object is correctly set for ClientSelector if needed
      if (estimate.value.client_fk_id && !estimate.value.client) {
        console.warn("Client object not fully loaded for estimate, ClientSelector might need to fetch details.");
      }

    } else {
      formError.value = 'Failed to load estimate data. Please try again.';
      console.error("Error loading estimate:", response);
    }
  } catch (error) {
    formError.value = 'An error occurred while loading the estimate.';
    console.error("Exception loading estimate:", error);
  } finally {
    isSubmitting.value = false;
    isGeneratingNumber.value = false; // Don't generate number when editing
  }
};


// Generate estimate number and set default terms (for NEW estimates)
const loadDefaults = async () => {
  try {
    isGeneratingNumber.value = true;

    // Fetch all settings
    const settingsResponse = await settingsService.getAllSettings();
    let allSettings = {};
    if (settingsResponse && settingsResponse.success && Array.isArray(settingsResponse.data)) {
        allSettings = settingsResponse.data.reduce((acc, setting) => {
            acc[setting.key] = setting.value;
            return acc;
        }, {});
    } else {
        console.error("Failed to load settings or invalid format:", settingsResponse);
    }

    // Get specific settings with defaults
    const estimatePrefix = allSettings['estimate_prefix'] || 'EST-';
    const validDays = allSettings['estimate_valid_days'] || '30';
    const defaultTerms = allSettings['default_estimate_terms'] || '';

    // Attempt to generate estimate number via backend service
    try {
        const response = await estimatesService.getNextEstimateNumber(); // Call the new service function
        if (response && response.success && response.data && response.data.estimateNumber) {
            estimate.value.estimateNumber = response.data.estimateNumber;
        } else {
             console.error("Failed to generate estimate number from API:", response);
             // Fallback if API call fails or returns unexpected data
             estimate.value.estimateNumber = `${estimatePrefix}${Math.floor(1000 + Math.random() * 9000)}`;
        }
    } catch (numError) {
        console.error("Error fetching next estimate number:", numError); // Updated error message
        // Fallback if API call fails
        estimate.value.estimateNumber = `${estimatePrefix}${Math.floor(1000 + Math.random() * 9000)}`;
    }

    // Calculate valid until date (today + valid days)
    const today = new Date();
    const validUntilDate = new Date(today);
    validUntilDate.setDate(today.getDate() + parseInt(validDays, 10));
    estimate.value.validUntil = validUntilDate.toISOString().split('T')[0];

    // Set default terms, replacing placeholder
    const termsWithDays = (defaultTerms || 'This estimate is valid for {valid_days} days.')
                          .replace('{valid_days}', validDays);
    estimate.value.terms = termsWithDays;

  } catch (error) {
    console.error('Error loading defaults:', error); // Reverted to console

    // Set fallback values
    estimate.value.estimateNumber = `EST-${Math.floor(1000 + Math.random() * 9000)}`; // Fallback number

    const fallbackToday = new Date();
    const fallbackValidUntilDate = new Date(fallbackToday);
    fallbackValidUntilDate.setDate(fallbackToday.getDate() + 30); // Default to 30 days
    estimate.value.validUntil = fallbackValidUntilDate.toISOString().split('T')[0];

  } finally {
    isGeneratingNumber.value = false;
  }
};

// Validate form
const validateForm = () => {
  let isValid = true;

  // Reset errors
  errors.value = {
    client: '',
    estimateNumber: '', // Renamed
    dateCreated: '',
    validUntil: '', // Renamed
    items: '',
    status: '' // Added status error
  };

  // Client validation (check fk_id)
  if (!estimate.value.client_fk_id) {
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

  // Status validation (only relevant if editing)
  if (isEditing.value && !['draft', 'sent', 'accepted', 'rejected'].includes(estimate.value.status)) {
    errors.value.status = 'Invalid status selected';
    isValid = false;
  }

  return isValid;
};

// Save as draft
const saveDraft = async () => {
  // Basic validation (check fk_id)
  if (!estimate.value.client_fk_id) {
    errors.value.client = 'Client is required';
    return;
  }

  if (!estimate.value.estimateNumber) {
    errors.value.estimateNumber = 'Estimate number is required';
    return;
  }

  // When editing, saving as draft should keep the current status if it's not 'draft' already
  const targetStatus = isEditing.value && estimate.value.status !== 'draft' ? estimate.value.status : 'draft';
  await saveEstimateToServer(targetStatus);
};

// Create and send estimate (or update)
const saveEstimate = async () => {
  if (!validateForm()) {
    return;
  }

  // If editing, use the status from the dropdown. If creating, default to 'sent'.
  const targetStatus = isEditing.value ? estimate.value.status : 'sent';
  await saveEstimateToServer(targetStatus);
};

// Save estimate to server
const saveEstimateToServer = async (status) => {
  try {
    isSubmitting.value = true;
    formError.value = '';

    // Prepare estimate data for API
    const estimateDataPayload = {
      client_fk_id: estimate.value.client_fk_id, // Use foreign key
      address_id: estimate.value.address_id, // Include selected address
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
      status,
      generatePdf: status === 'sent', // Only generate PDF if sending immediately
      project_id: estimate.value.project_id // Include project_id if it exists
    };

    let response;
    if (isEditing.value) {
      // Update existing estimate
      response = await estimatesService.updateEstimate(estimateId.value, estimateDataPayload);
    } else {
      // Create new estimate
      response = await estimatesService.createEstimate(estimateDataPayload);
    }

    if (response && response.success && response.data) {
      // If this estimate was created from a project, handle redirection back to project
      if (!isEditing.value && response.success && estimate.value.project_id) {
        // Get the original project service
        const projectsService = await import('@/services/projects.service');
                  
        try {
          // Redirect back to the project page
          router.push(`/projects/${estimate.value.project_id}`);
          return; // Exit early to prevent the default redirection
        } catch (error) {
          console.error('Error navigating back to project:', error);
        }
      }
      
      // Default navigation if not redirecting to a project
      router.push(`/invoicing/estimates`);
    } else {
      formError.value = response?.message || `Failed to ${isEditing.value ? 'update' : 'create'} estimate. Please try again.`;
    }
  } catch (error) {
    console.error(`Error ${isEditing.value ? 'updating' : 'creating'} estimate:`, error); // Reverted to console
    formError.value = error.message || `An unexpected error occurred while ${isEditing.value ? 'updating' : 'creating'} the estimate. Please try again.`;
  } finally {
    isSubmitting.value = false;
  }
};

// Initialize
onMounted(async () => { // Make onMounted async
  // Check for query parameters
  const clientId = route.query.clientId;
  const projectId = route.query.projectId;
  
  if (clientId) {
    // Set client_fk_id from query parameter
    estimate.value.client_fk_id = clientId;
    
    // Try to fetch the client details if needed for the client selector
    try {
      const clientsService = await import('@/services/clients.service');
      if (clientsService.default && clientsService.default.getClientById) {
        const response = await clientsService.default.getClientById(clientId);
        if (response && response.success && response.data) {
          estimate.value.client = response.data;
          // If client has addresses, select the first one or primary one
          if (response.data.addresses && response.data.addresses.length > 0) {
            const primaryAddress = response.data.addresses.find(addr => addr.is_primary);
            const addressToUse = primaryAddress || response.data.addresses[0];
            estimate.value.address_id = addressToUse.id;
            if (estimate.value.client) {
              estimate.value.client.selectedAddressId = addressToUse.id;
            }
          }
        }
      }
    } catch (error) {
      console.error('Error fetching client details:', error);
    }
  }
  
  // Store projectId for later use when saving the estimate
  if (projectId) {
    // Store the projectId to associate with the estimate
    estimate.value.project_id = projectId;
  }
  
  // Check for prefilled items from LLM generator
  const prefill = route.query.prefill;
  const items = route.query.items;
  
  if (prefill === 'true' && items) {
    try {
      const prefillItems = JSON.parse(decodeURIComponent(items));
      estimate.value.items = prefillItems;
      // Calculate totals for the prefilled items
      const totals = prefillItems.reduce((acc, item) => {
        acc.subtotal += item.quantity * item.unit_price;
        return acc;
      }, { subtotal: 0 });
      updateTotals({
        subtotal: totals.subtotal,
        taxTotal: 0,
        discount: 0,
        total: totals.subtotal
      });
    } catch (error) {
      console.error('Error parsing prefilled items:', error);
    }
  }
  
  await loadEstimateData(); // Call the correct loading function
});
</script>
