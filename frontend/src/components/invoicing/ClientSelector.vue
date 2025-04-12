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
              {{ selectedClient.display_name }}
            </h3>
            <p v-if="selectedClient.company" class="mt-1 text-sm text-gray-600 dark:text-gray-400">
              {{ selectedClient.company }}
            </p>
            <p v-if="selectedClient.client_type" class="mt-1 text-xs text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30 px-2 py-0.5 rounded-full inline-block">
              {{ formatClientType(selectedClient.client_type) }}
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
        
        <!-- Client Email and Phone -->
        <div class="mt-3 text-sm text-gray-600 dark:text-gray-400">
          <p v-if="selectedClient.email">
            <span class="font-medium">Email:</span> {{ selectedClient.email }}
          </p>
          <p v-if="selectedClient.phone">
            <span class="font-medium">Phone:</span> {{ selectedClient.phone }}
          </p>
        </div>
        
        <!-- Address Selection -->
        <div v-if="clientAddresses.length > 0" class="mt-3">
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            Address
          </label>
          
          <select 
            v-if="clientAddresses.length > 1"
            v-model="selectedAddressId"
            class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
          >
            <option v-for="address in clientAddresses" :key="address.id" :value="address.id">
              {{ address.name }} - {{ formatAddressForDisplay(address) }}
            </option>
          </select>
          
          <div v-else class="text-sm text-gray-600 dark:text-gray-400 border border-gray-200 dark:border-gray-700 rounded-md p-2">
            <p class="font-medium">{{ clientAddresses[0].name }}</p>
            <p>{{ formatAddressForDisplay(clientAddresses[0]) }}</p>
          </div>
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
              
              <!-- Add New Client Button -->
              <div class="flex justify-end mb-2">
                <button
                  type="button"
                  @click="showAddClientForm"
                  class="flex items-center gap-1 text-sm px-3 py-1.5 text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30 rounded-md hover:bg-blue-100 dark:hover:bg-blue-900/40"
                >
                  <svg 
                    xmlns="http://www.w3.org/2000/svg" 
                    class="h-4 w-4"
                    fill="none" 
                    viewBox="0 0 24 24" 
                    stroke="currentColor"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                  </svg>
                  Add New Client
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
              <div v-else-if="filteredClients.length === 0 && !isAddingClient" class="py-8 text-center text-gray-500 dark:text-gray-400">
                <svg xmlns="http://www.w3.org/2000/svg" class="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <p class="mt-2">No clients found. Try changing your search or add a new client.</p>
              </div>
              
              <!-- Add Client Form -->
              <div v-if="isAddingClient" class="mb-4 p-4 border border-blue-200 dark:border-blue-700 bg-blue-50 dark:bg-blue-900/20 rounded-md">
                <h3 class="text-base font-medium text-gray-900 dark:text-white mb-2">Add New Client</h3>
                <form @submit.prevent="addNewClient">
                  <div class="space-y-3">
                    <div>
                      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Name *</label>
                      <input 
                        type="text" 
                        v-model="newClientForm.display_name" 
                        class="w-full p-2 border border-gray-300 dark:border-gray-700 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
                        required
                      />
                    </div>
                    <div>
                      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Company</label>
                      <input 
                        type="text" 
                        v-model="newClientForm.company" 
                        class="w-full p-2 border border-gray-300 dark:border-gray-700 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
                      />
                    </div>
                    <div>
                      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Email</label>
                      <input 
                        type="email" 
                        v-model="newClientForm.email" 
                        class="w-full p-2 border border-gray-300 dark:border-gray-700 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
                      />
                    </div>
                    <div>
                      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Phone</label>
                      <input 
                        type="text" 
                        v-model="newClientForm.phone" 
                        class="w-full p-2 border border-gray-300 dark:border-gray-700 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
                      />
                    </div>
                    <div>
                      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Client Type</label>
                      <select
                        v-model="newClientForm.client_type"
                        class="w-full p-2 border border-gray-300 dark:border-gray-700 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
                      >
                        <option value="resident">Resident</option>
                        <option value="property_manager">Property Manager</option>
                      </select>
                    </div>
                    <div class="flex justify-end space-x-2 pt-2">
                      <button
                        type="button"
                        @click="isAddingClient = false"
                        class="px-3 py-1.5 text-sm text-gray-600 dark:text-gray-400 border border-gray-300 dark:border-gray-700 rounded-md hover:bg-gray-100 dark:hover:bg-gray-800"
                      >
                        Cancel
                      </button>
                      <button
                        type="submit"
                        class="px-3 py-1.5 text-sm text-white bg-blue-600 rounded-md hover:bg-blue-700 dark:bg-blue-700 dark:hover:bg-blue-800"
                      >
                        Save Client
                      </button>
                    </div>
                  </div>
                </form>
              </div>
              
              <!-- Client List -->
              <div v-if="!isAddingClient" class="overflow-y-auto max-h-96">
                <div
                  v-for="client in filteredClients"
                  :key="client.id"
                  @click="selectClient(client)"
                  class="mb-2 p-3 border border-gray-200 dark:border-gray-700 rounded-md cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700"
                >
                  <div class="flex justify-between items-start">
                    <div>
                      <h4 class="font-medium text-gray-900 dark:text-white">
                        {{ client.display_name }}
                      </h4>
                      <p v-if="client.company" class="text-sm text-gray-600 dark:text-gray-400">
                        {{ client.company }}
                      </p>
                      <p v-if="client.client_type" class="text-xs text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30 px-1.5 py-0.5 rounded-full inline-block mt-1">
                        {{ formatClientType(client.client_type) }}
                      </p>
                    </div>
                  </div>
                  <div class="mt-1 text-xs text-gray-500 dark:text-gray-400">
                    <p v-if="client.email">{{ client.email }}</p>
                    <p v-if="client.phone">{{ client.phone }}</p>
                    <p v-if="client.addresses && client.addresses.length">{{ client.addresses.length }} address(es) available</p>
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
  }
});

const emit = defineEmits(['update:modelValue']);

// State
const clients = ref([]);
const selectedClient = ref(props.modelValue);
const isModalOpen = ref(false);
const isLoading = ref(false);
const searchQuery = ref('');
const selectedAddressId = ref(null);

// Add a new client form data
const newClientForm = ref({
  display_name: '',
  company: '',
  email: '',
  phone: '',
  client_type: 'resident' // Default value is resident
});

const isAddingClient = ref(false);

const showAddClientForm = () => {
  // Reset the form
  newClientForm.value = {
    display_name: '',
    company: '',
    email: '',
    phone: '',
    client_type: 'resident' // Set default value when showing form
  };
  isAddingClient.value = true;
};

const addNewClient = async () => {
  try {
    if (!newClientForm.value.display_name) {
      // Display validation error
      return;
    }
    
    const response = await clientsService.createClient(newClientForm.value);
    
    if (response && response.success) {
      // After creation, reload the clients and close the form
      await loadClients();
      isAddingClient.value = false;
      
      // Select the newly created client
      if (response.data) {
        selectClient(response.data);
      }
    } else {
      console.error('Error creating client:', response);
    }
  } catch (error) {
    console.error('Error creating client:', error);
  }
};

// Computed properties
const clientAddresses = computed(() => {
  if (!selectedClient.value || !selectedClient.value.addresses) {
    return [];
  }
  return selectedClient.value.addresses;
});

const filteredClients = computed(() => {
  if (!searchQuery.value.trim()) {
    return clients.value;
  }
  
  const query = searchQuery.value.toLowerCase();
  return clients.value.filter(client => {
    const displayName = client.display_name?.toLowerCase() || '';
    const company = client.company?.toLowerCase() || '';
    const email = client.email?.toLowerCase() || '';
    
    return displayName.includes(query) || 
           company.includes(query) || 
           email.includes(query);
  });
});

// Watch for model value changes
watch(() => props.modelValue, (newValue) => {
  // Avoid recursive updates by checking if the values are already equal
  if (JSON.stringify(selectedClient.value) !== JSON.stringify(newValue)) {
    selectedClient.value = newValue;
    
    // Set default address if available
    if (newValue && newValue.addresses && newValue.addresses.length > 0) {
      // Find primary address first
      const primaryAddress = newValue.addresses.find(addr => addr.is_primary);
      if (primaryAddress) {
        selectedAddressId.value = primaryAddress.id;
      } else {
        // Otherwise use the first address
        selectedAddressId.value = newValue.addresses[0].id;
      }
    } else {
      selectedAddressId.value = null;
    }
  }
});

// Watch for selected client changes
watch(selectedClient, (newValue) => {
  // Only emit update if there's an actual change
  if (JSON.stringify(props.modelValue) !== JSON.stringify(newValue)) {
    if (newValue) {
      // Add selected address to the client object
      const clientWithAddress = {
        ...newValue,
        selectedAddressId: selectedAddressId.value
      };
      emit('update:modelValue', clientWithAddress);
    } else {
      emit('update:modelValue', null);
    }
  }
});

// Watch for selected address changes
watch(selectedAddressId, (newValue) => {
  if (selectedClient.value && newValue) {
    // Prevent recursive updates by checking if already updated
    if (selectedClient.value.selectedAddressId !== newValue) {
      // Update model with the new selected address
      emit('update:modelValue', {
        ...selectedClient.value,
        selectedAddressId: newValue
      });
    }
  }
});

// Format client type for display
const formatClientType = (type) => {
  if (type === 'property_manager') {
    return 'Property Manager';
  } else if (type === 'resident') {
    return 'Resident';
  }
  return type;
};

// Format address for display
const formatAddressForDisplay = (address) => {
  if (!address) return '';
  
  const parts = [
    address.street_address,
    address.city,
    address.state,
    address.postal_code,
    address.country
  ].filter(Boolean);
  
  return parts.join(', ');
};

// Methods
const loadClients = async () => {
  try {
    isLoading.value = true;
    const response = await clientsService.getAllClients();
    
    if (response && response.success && response.data) {
      clients.value = response.data;
    } else {
      console.error('Error loading clients:', response);
    }
  } catch (error) {
    console.error('Error loading clients:', error);
  } finally {
    isLoading.value = false;
  }
};

const selectClient = (client) => {
  // Check if this client is already selected to avoid unnecessary updates
  if (selectedClient.value && selectedClient.value.id === client.id) {
    isModalOpen.value = false;
    return;
  }
  
  selectedClient.value = client;
  
  // Set default address if client has addresses
  if (client && client.addresses && client.addresses.length > 0) {
    // Find primary address first
    const primaryAddress = client.addresses.find(addr => addr.is_primary);
    if (primaryAddress) {
      selectedAddressId.value = primaryAddress.id;
    } else {
      // Otherwise use the first address
      selectedAddressId.value = client.addresses[0].id;
    }
  } else {
    selectedAddressId.value = null;
  }
  
  isModalOpen.value = false;
};

const resetSelection = () => {
  selectedClient.value = null;
  selectedAddressId.value = null;
};

const openSelector = () => {
  isModalOpen.value = true;
  // Load clients if not already loaded
  if (clients.value.length === 0) {
    loadClients();
  }
};

// Load clients on mount
onMounted(() => {
  // If we have a selected client but not a full list, preload the clients
  if (selectedClient.value && clients.value.length === 0) {
    loadClients();
  }
});
</script>
