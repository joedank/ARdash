<template>
  <div class="create-invoice">
    <div class="mb-6">
      <div class="flex items-center">
        <router-link to="/invoicing/invoices" class="text-blue-600 dark:text-blue-400 mr-2">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
        </router-link>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">{{ isEditing ? 'Edit Invoice' : 'Create New Invoice' }}</h1>
      </div>
      <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
        {{ isEditing ? 'Update the invoice details below' : 'Fill out the form below to create a new invoice' }}
      </p>
    </div>

    <form @submit.prevent="saveInvoice" class="space-y-6">
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
                  :disabled="isGeneratingNumber"
                />
                <div v-if="isGeneratingNumber" class="mt-1 text-sm text-gray-500 dark:text-gray-400">
                  Generating invoice number...
                </div>
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
            </div>
            
            <!-- Status Dropdown (only show when editing) -->
            <div v-if="isEditing">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Status
              </label>
              <select
                v-model="invoice.status"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                :disabled="isSubmitting"
              >
                <option value="draft" :disabled="invoice.status !== 'draft'">Draft</option>
                <option value="sent" :disabled="!['draft', 'sent'].includes(invoice.status)">Sent</option>
                <option value="viewed" :disabled="!['sent', 'viewed'].includes(invoice.status)">Viewed</option>
                <option value="paid" :disabled="!['sent', 'viewed', 'paid'].includes(invoice.status)">Paid</option>
                <!-- Overdue is usually set automatically, not manually -->
              </select>
              <div v-if="errors.status" class="mt-1 text-sm text-red-600 dark:text-red-400">
                {{ errors.status }}
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
            :initial-discount="invoice.discountAmount"
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
              There was an error creating the invoice
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
          to="/invoicing/invoices"
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
          <span v-if="isSubmitting &amp;&amp; !isGeneratingPdf">{{ isEditing ? 'Updating...' : 'Creating...' }}</span>
          <span v-else-if="isGeneratingPdf">Generating PDF...</span>
          <span v-else>{{ isEditing ? 'Update Invoice' : 'Create and Send' }}</span>
        </button>
      </div>
      
      <!-- PDF Generation Loading/Error -->
      <div v-if="pdfError" class="mt-4 text-sm text-red-600 dark:text-red-400">
        {{ pdfError }}
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import ClientSelector from '@/components/invoicing/ClientSelector.vue';
import LineItemsEditor from '@/components/invoicing/LineItemsEditor.vue';
import standardizedInvoicesService from '@/services/standardized-invoices.service';
import invoicesService from '@/services/invoices.service';
import settingsService from '@/services/settings.service';
import { toSnakeCase } from '@/utils/casing';

const router = useRouter();
const route = useRoute();

const invoiceId = ref(route.params.id || null);
const isEditing = computed(() => !!invoiceId.value);

// State
const invoice = ref({
  client: null,
  clientId: '',
  addressId: null, // Added for address selection
  invoiceNumber: '',
  dateCreated: new Date().toISOString().split('T')[0], // Today's date in YYYY-MM-DD format
  dateDue: '', // Will be calculated based on settings
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
  invoiceNumber: '',
  dateCreated: '',
  dateDue: '',
  items: '',
  status: '' // Added for status validation
});

const isSubmitting = ref(false);
const isGeneratingNumber = ref(true);
const formError = ref('');
const pdfError = ref(''); // For PDF specific errors
const isGeneratingPdf = ref(false); // PDF loading state

// Update client ID and address ID when client is selected
// Use @update instead of @update:modelValue to avoid double handling
const updateClient = (client) => {
  // Only update if there's an actual change
  if (client) {
    // Since client object should be normalized by clientsService, we only need to use clientId
    // No need for fallback to snake_case property
    const newClientId = client.clientId;
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

// Update totals when line items change - with enhanced debouncing to prevent recursive updates
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

// Load existing invoice data if editing
const loadInvoiceData = async () => {
  if (!isEditing.value) {
    await loadDefaults(); // Load defaults only for new invoices
    return;
  }
  
  try {
    isSubmitting.value = true; // Use submitting state for loading indicator
    const response = await standardizedInvoicesService.getInvoice(invoiceId.value);
    if (response && response.success && response.data) {
      const loadedInvoice = response.data;
      
      // Map loaded data to the invoice ref
      invoice.value = {
        ...invoice.value, // Keep potential defaults if some fields are missing
        client: loadedInvoice.client || null, // Assuming client object is included
        clientId: loadedInvoice.clientId,
        addressId: loadedInvoice.addressId,
        invoiceNumber: loadedInvoice.invoiceNumber,
        dateCreated: loadedInvoice.dateCreated ? new Date(loadedInvoice.dateCreated).toISOString().split('T')[0] : '',
        dateDue: loadedInvoice.dateDue ? new Date(loadedInvoice.dateDue).toISOString().split('T')[0] : '',
        items: loadedInvoice.items || [],
        subtotal: loadedInvoice.subtotal || 0,
        taxTotal: loadedInvoice.taxTotal || 0,
        discountAmount: loadedInvoice.discountAmount || 0,
        total: loadedInvoice.total || 0,
        notes: loadedInvoice.notes || '',
        terms: loadedInvoice.terms || '',
        status: loadedInvoice.status || 'draft' // Load existing status
      };
      
      // Ensure client object is correctly set for ClientSelector if clientId exists but client object wasn't loaded
      if (invoice.value.clientId && !invoice.value.client) {
        // We might need to fetch the client details separately if not included in getInvoice response
        // For now, let ClientSelector handle loading based on clientId if needed
        console.warn("Client object not fully loaded, ClientSelector might need to fetch details.");
      }
      
    } else {
      formError.value = 'Failed to load invoice data. Please try again.';
      console.error("Error loading invoice:", response);
    }
  } catch (error) {
    formError.value = 'An error occurred while loading the invoice.';
    console.error("Exception loading invoice:", error);
  } finally {
    isSubmitting.value = false;
    isGeneratingNumber.value = false; // Don't generate number when editing
  }
};

// Generate invoice number and set default terms (for NEW invoices)
const loadDefaults = async () => {
  try {
    isGeneratingNumber.value = true;
    
    // Get invoice prefix and due days from settings
    let invoicePrefix = 'INV-';
    let dueDays = 30;
    let terms = '';
    
    // Get settings using the correct method names
    try {
      // Get invoice prefix
      const prefixSetting = await settingsService.getSetting('invoice_prefix');
      if (prefixSetting && prefixSetting.success && prefixSetting.data) {
        invoicePrefix = prefixSetting.data.value || 'INV-';
      }
      
      // Get due days
      const dueDaysSetting = await settingsService.getSetting('invoice_due_days');
      if (dueDaysSetting && dueDaysSetting.success && dueDaysSetting.data) {
        dueDays = parseInt(dueDaysSetting.data.value || '30', 10);
      }
      
      // Get terms
      const termsSetting = await settingsService.getSetting('default_invoice_terms');
      if (termsSetting && termsSetting.success && termsSetting.data) {
        terms = termsSetting.data.value || '';
      }
    } catch (settingsError) {
      console.error('Error fetching settings:', settingsError);
      // Continue with defaults if settings can't be fetched
    }
    
    // Generate next invoice number
    try {
      const response = await standardizedInvoicesService.getNextInvoiceNumber();
      if (response && response.success && response.data) {
        invoice.value.invoiceNumber = response.data.invoiceNumber;
      } else {
        // Fallback to a default pattern if API fails
        const randomNum = Math.floor(10000 + Math.random() * 90000);
        invoice.value.invoiceNumber = `${invoicePrefix}${randomNum}`;
      }
    } catch (numberError) {
      console.error('Error generating invoice number:', numberError);
      // Fallback to a default pattern
      const randomNum = Math.floor(10000 + Math.random() * 90000);
      invoice.value.invoiceNumber = `${invoicePrefix}${randomNum}`;
    }
    
    // Calculate due date (today + due days)
    const today = new Date();
    const dueDate = new Date(today);
    dueDate.setDate(today.getDate() + dueDays);
    invoice.value.dateDue = dueDate.toISOString().split('T')[0];
    
    // Set default terms
    invoice.value.terms = terms;
    
  } catch (error) {
    console.error('Error loading defaults:', error);
    
    // Set fallback values
    invoice.value.invoiceNumber = `INV-${Math.floor(10000 + Math.random() * 90000)}`;
    
    const today = new Date();
    const dueDate = new Date(today);
    dueDate.setDate(today.getDate() + 30); // Default to 30 days
    invoice.value.dateDue = dueDate.toISOString().split('T')[0];
    
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
    invoiceNumber: '',
    dateCreated: '',
    dateDue: '',
    items: '',
    status: ''
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
  
  // Status validation (only relevant if editing, but doesn't hurt to check)
  if (!['draft', 'sent', 'viewed', 'paid', 'overdue'].includes(invoice.value.status)) {
    errors.value.status = 'Invalid status selected';
    isValid = false;
  }
  
  return isValid;
};

// Save as draft
const saveDraft = async () => {
  // Basic validation
  if (!invoice.value.clientId) {
    errors.value.client = 'Client is required';
    return;
  }
  
  if (!invoice.value.invoiceNumber) {
    errors.value.invoiceNumber = 'Invoice number is required';
    return;
  }
  
  // When editing, saving as draft should keep the current status if it's not 'draft' already
  const targetStatus = isEditing.value && invoice.value.status !== 'draft' ? invoice.value.status : 'draft';
  await saveInvoiceToServer(targetStatus);
};

// Create and send invoice (or update)
const saveInvoice = async () => {
  if (!validateForm()) {
    return;
  }
  // If editing, use the status from the dropdown. If creating, default to 'sent'.
  const targetStatus = isEditing.value ? invoice.value.status : 'sent';
  await saveInvoiceToServer(targetStatus);
};

// Save invoice to server and handle PDF generation
const saveInvoiceToServer = async (status) => {
  isSubmitting.value = true;
  formError.value = '';
  pdfError.value = ''; // Clear previous PDF errors
  isGeneratingPdf.value = false; // Reset PDF loading state

  try {
    // Debug client information before submission
    console.log('Before preparing invoice data:');
    console.log('invoice.value.client:', invoice.value.client);
    console.log('invoice.value.clientId:', invoice.value.clientId);
    console.log('invoice.value.addressId:', invoice.value.addressId);

    // Prepare invoice data for API using standardized approach
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
      status,
      // Always generate PDF - we need it for both types of invoices
      generatePdf: true
    };
    
    // Use the standardized service instead of direct snake_case conversion
    let response;
    if (isEditing.value) {
      // --- 1a. Update Invoice ---
      console.log("Updating invoice:", invoiceId.value, "with data:", invoiceData);
      response = await standardizedInvoicesService.updateInvoice(invoiceId.value, invoiceData);
    } else {
      // --- 1b. Create Invoice ---
      console.log("Creating invoice with data:", invoiceData);
      response = await standardizedInvoicesService.createInvoice(invoiceData);
    }
    
    const resultInvoice = response?.data; // Use optional chaining

    if (!response || !response.success || !resultInvoice) {
      formError.value = response?.message || `Failed to ${isEditing.value ? 'update' : 'create'} invoice. Please try again.`;
      isSubmitting.value = false;
      return;
    }

    const savedInvoiceId = resultInvoice.id;
    console.log(`Successfully ${isEditing.value ? 'updated' : 'created'} invoice with ID:`, savedInvoiceId);

    // --- 2. Fetch PDF if status is 'sent' (or potentially other statuses if needed later) ---
    // Only attempt PDF generation/opening if NOT just saving a draft
    if (status !== 'draft') { 
      isGeneratingPdf.value = true; // Show PDF loading state
      pdfError.value = ''; // Clear previous PDF errors

      try {
        // Add a small delay to let the server generate the PDF fully
        await new Promise(resolve => setTimeout(resolve, 500));
        
        console.log('Requesting PDF for invoice:', savedInvoiceId);
        const pdfResponse = await standardizedInvoicesService.getInvoicePdf(savedInvoiceId);
        
        if (pdfResponse instanceof Blob && pdfResponse.type === 'application/pdf') {
          console.log('Received PDF blob of size:', pdfResponse.size);
          const pdfUrl = URL.createObjectURL(pdfResponse);
          window.open(pdfUrl, '_blank');
          // Revoke URL after a short delay
          setTimeout(() => URL.revokeObjectURL(pdfUrl), 1000);
          
          // Wait for a moment before navigating away
          setTimeout(() => {
            router.push('/invoicing/invoices');
          }, 500);
        } else {
          // Handle cases where the response might not be a PDF
          console.error('Received invalid response for PDF:', pdfBlob);
          pdfError.value = 'Failed to retrieve PDF: Invalid format received.';
        }
      } catch (pdfFetchError) {
        console.error('Error fetching invoice PDF:', pdfFetchError);
        pdfError.value = pdfFetchError.message || 'Failed to retrieve the generated PDF. You can download it later from the invoice details page.';
        
        // Despite PDF error, invoice was created/updated successfully, so offer navigation
        setTimeout(() => {
          const confirmNav = window.confirm('Invoice was saved successfully but there was a problem getting the PDF. Would you like to view the invoice details?');
          if (confirmNav) {
            router.push(`/invoicing/invoice/${savedInvoiceId}`);
          }
        }, 500);
      } finally {
        isGeneratingPdf.value = false; // Hide PDF loading state regardless of outcome
      }
    }
    
    // If it was just a draft save or an update without PDF generation issues, navigate back
    if (status === 'draft' || (isEditing.value && !pdfError.value)) {
       // If saving as draft or updating, navigate to invoice details
       router.push(`/invoicing/invoice/${savedInvoiceId}`);
    }

  } catch (error) {
    console.error(`Error ${isEditing.value ? 'updating' : 'creating'} invoice:`, error);
    // Ensure a general error is shown if not already handled
    if (!formError.value && !pdfError.value) {
       formError.value = error.message || `An unexpected error occurred while ${isEditing.value ? 'updating' : 'creating'} the invoice. Please try again.`;
    }
  } finally {
    // Ensure both loading states are reset
    isSubmitting.value = false;
    isGeneratingPdf.value = false;
  }
};

// Watch for client changes and update clientId and addressId
watch(() => invoice.value.client, (newClient) => {
  if (newClient) {
    // Since client object should be normalized by clientsService, we only need to use clientId
    // No need for fallback to snake_case property
    const newClientId = newClient.clientId;
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
}); // Closing brace for watch

// Initialize
onMounted(async () => { // Make onMounted async
  await loadInvoiceData(); // Call the correct loading function
}); // Closing brace for onMounted
</script>
