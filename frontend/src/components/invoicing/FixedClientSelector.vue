<template>
  <div class="client-selector">
    <div class="flex w-full flex-col mb-4">
      <div class="flex justify-between mb-2">
        <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
          {{ label }}
        </label>
        <button 
          v-if="selectedClient"
          type="button" 
          @click="resetSelection"
          class="text-xs text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-200"
        >
          Reset Selection
        </button>
      </div>
      
      <!-- Selected Client Card -->
      <div 
        v-if="selectedClient" 
        class="border border-gray-200 dark:border-gray-700 rounded-md p-4 bg-white dark:bg-gray-800"
      >
        <div class="flex justify-between items-start">
          <div>
            <h3 class="text-base font-medium text-gray-900 dark:text-white">
              {{ getDisplayName(selectedClient) }}
            </h3>
            <p v-if="getClientCompany(selectedClient)" class="mt-1 text-sm text-gray-600 dark:text-gray-400">
              {{ getClientCompany(selectedClient) }}
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
        <div class="mt-3 text-sm text-gray-600 dark:text-gray-400">
          <p v-if="getClientEmail(selectedClient)">
            <span class="font-medium">Email:</span> {{ getClientEmail(selectedClient) }}
          </p>
          <p v-if="getClientPhone(selectedClient)">
            <span class="font-medium">Phone:</span> {{ getClientPhone(selectedClient) }}
          </p>
          <p v-if="getClientAddressString(selectedClient)">
            <span class="font-medium">Address:</span> {{ getClientAddressString(selectedClient) }}
          </p>
        </div>
      </div>
      
      <!-- Client Selection Button -->
      <button 
        v-else
        type="button"
        @click="openSelector"
        class="flex justify-center items-center gap-2 p-4 border-2 border-dashed border-gray-300 dark:border-gray-700 rounded-md hover:border-gray-400 dark:hover:border-gray-600 transition-colors bg-white dark:bg-gray-800"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400 dark:text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
        </svg>
        <span class="text-sm text-gray-500 dark:text-gray-400">
          {{ placeholderText || 'Select a client for this document' }}
        </span>
      </button>
    </div>
    
    <!-- Error Message -->
    <p v-if="error" class="text-sm text-red-600 dark:text-red-400 mt-1">
      {{ error }}
    </p>
    
    <!-- Client Selection Modal -->
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
                  Select a Client
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
                    placeholder="Search clients..."
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
              
              <!-- Sync Button -->
              <div class="flex justify-end mb-2">
                <button
                  type="button"
                  @click="showAddClientForm"
                  :disabled="isSyncing"
                  class="flex items-center gap-1 text-sm px-3 py-1.5 text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30 rounded-md hover:bg-blue-100 dark:hover:bg-blue-900/40 disabled:opacity-50"
                >
                  <svg 
                    xmlns="http://www.w3.org/2000/svg" 
                    class="h-4 w-4" 
                    :class="{'animate-spin': isSyncing}"
                    fill="none" 
                    viewBox="0 0 24 24" 
                    stroke="currentColor"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                  </svg>
                  {{ isSyncing ? 'Syncing...' : 'Sync Contacts' }}
                </button>
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
              <div v-else-if="filteredClients.length === 0" class="py-8 text-center text-gray-500 dark:text-gray-400">
                <svg xmlns="http://www.w3.org/2000/svg" class="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <p class="mt-2">No clients found. Try changing your search or sync contacts.</p>
              </div>
              
              <!-- Debug Info (temporary) -->
              <div v-if="filteredClients.length > 0 && debugMode" class="mb-4 p-3 border border-orange-200 bg-orange-50 dark:bg-orange-900/20 dark:border-orange-700 rounded-md">
                <h4 class="font-medium text-orange-800 dark:text-orange-400 mb-2">Debug Info</h4>
                <p class="text-xs">First client data structure:</p>
                <pre class="text-xs overflow-auto max-h-32 bg-white dark:bg-gray-900 p-1 rounded">{{ JSON.stringify(filteredClients[0], null, 2) }}</pre>
              </div>
              
              <!-- Client List -->
              <div v-else class="overflow-y-auto max-h-96">
                <div
                  v-for="client in filteredClients"
                  :key="client.id || client.clientId"
                  @click="selectClient(client)"
                  class="mb-2 p-3 border border-gray-200 dark:border-gray-700 rounded-md cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700"
                >
                  <div class="flex justify-between items-start">
                    <div>
                      <h4 class="font-medium text-gray-900 dark:text-white">
                        {{ getDisplayName(client) }}
                      </h4>
                      <p v-if="getClientCompany(client)" class="text-sm text-gray-600 dark:text-gray-400">
                        {{ getClientCompany(client) }}
                      </p>
                    </div>
                  </div>
                  <div class="mt-1 text-xs text-gray-500 dark:text-gray-400">
                    <p v-if="getClientEmail(client)">
                      {{ getClientEmail(client) }}
                    </p>
                    <p v-if="getClientPhone(client)">
                      {{ getClientPhone(client) }}
                    </p>
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
import clientsService from '@/services/clients.service';
import { normalizeClient } from '@/utils/casing';

const props = defineProps({
  modelValue: {
    type: Object,
    default: null
  },
  label: {
    type: String,
    default: 'Client'
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
  },
  debugMode: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['update:modelValue', 'update']);

// State
const clients = ref([]);
const selectedClient = ref(props.modelValue);
const isModalOpen = ref(false);
const isLoading = ref(false);
const isSyncing = ref(false);
const searchQuery = ref('');

// Watch for model value changes
watch(() => props.modelValue, (newValue) => {
  selectedClient.value = newValue;
});

// Watch for selected client changes
watch(selectedClient, (newValue) => {
  emit('update:modelValue', newValue);
  emit('update', newValue);
});

// Helper function to get display name from client object (uses normalized data)
const getDisplayName = (client) => {
  if (!client) return 'Unnamed Client';
  
  // Rely on normalized displayName
  if (client.displayName) {
    return client.displayName;
  }
  
  // Fallback options if displayName is somehow missing after normalization
  if (client.name) {
    return client.name;
  }
  if (client.email) {
    return client.email;
  }
  if (client.phone) {
    return client.phone;
  }
  
  // Final fallback
  return 'Unnamed Client'; // Should rarely be needed if normalization works
};

// Helper function to get client company (uses normalized data)
const getClientCompany = (client) => {
  if (!client) return '';
  return client.company || ''; // Rely on normalized company
};

// Helper function to get client email (uses normalized data)
const getClientEmail = (client) => {
  if (!client) return '';
  return client.email || ''; // Rely on normalized email
};

// Helper function to get client phone (uses normalized data)
const getClientPhone = (client) => {
  if (!client) return '';
  return client.phone || ''; // Rely on normalized phone
};

// Helper function to get client address string (uses normalized data)
const getClientAddressString = (client) => {
  if (!client) return '';
  const addressString = client.address || ''; // Rely on normalized address string if available
  // Existing formatAddress logic can be reused or integrated here
  return formatAddress(addressString);
};


// Computed properties
const filteredClients = computed(() => {
  if (!searchQuery.value.trim()) {
    return clients.value;
  }
  
  const query = searchQuery.value.toLowerCase();
  return clients.value.filter(client => {
    // Get display name using the helper function
    const displayName = getDisplayName(client).toLowerCase();
    
    // Check company from either direct property or contactInfo
    const company = (client.company || (client.contactInfo && client.contactInfo.company) || '').toLowerCase();
    
    // Check email from either direct property or contactInfo
    const email = (client.email || (client.contactInfo && client.contactInfo.email) || '').toLowerCase();
    
    return displayName.includes(query) || 
           company.includes(query) || 
           email.includes(query);
  });
});

// Methods
const loadClients = async () => {
  try {
    isLoading.value = true;
    console.log('Loading clients...');
    
    const response = await clientsService.getAllClients();
    
    if (response && response.success && response.data) {
      console.log('Clients loaded successfully:', response.data.length);
      
      // Normalize clients and ensure clientId is present
      clients.value = response.data.map(client => {
        const normalized = normalizeClient(client); // Normalize first
        // Ensure clientId is present after normalization
        const clientId = normalized.id || normalized.clientId || client.contactInfo?.client_id || client.id;
        
        return {
          ...normalized,
          clientId // Ensure clientId is explicitly set if needed elsewhere
        };
      });
      
      // Log the first client for debugging
      if (clients.value.length > 0) {
        console.log('First client structure:', clients.value[0]);
      }
    } else {
      console.error('Error loading clients:', response);
    }
  } catch (error) {
    console.error('Error loading clients:', error);
  } finally {
    isLoading.value = false;
  }
};

const showAddClientForm = () => {
  isAddingClient.value = true;
};
const selectClient = (client) => {
  console.log('Selected client (raw):', client);
  // Normalize the client object before assigning it
  const normalizedClient = normalizeClient(client);
  console.log('Selected client (normalized):', normalizedClient);
  selectedClient.value = normalizedClient;
  isModalOpen.value = false;
};

const resetSelection = () => {
  selectedClient.value = null;
};

const openSelector = () => {
  isModalOpen.value = true;
  // Load clients if not already loaded
  if (clients.value.length === 0) {
    loadClients();
  }
};

const formatAddress = (address) => {
  if (!address) return '';
  // Replace semicolons with commas and spaces
  return address.replace(/;/g, ', ');
};

// Load clients on mount
onMounted(() => {
  // If we have a selected client but not a full list, preload the clients
  if (selectedClient.value && clients.value.length === 0) {
    loadClients();
  }
});
</script>
