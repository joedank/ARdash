<template>
  <div class="product-catalog-manager">
    <!-- Add Button and Filter Controls -->
    <div class="flex justify-between items-center mb-4">
      <div class="flex gap-2">
        <div class="relative">
          <input 
            type="text" 
            v-model="searchQuery" 
            placeholder="Search products..." 
            class="pl-10 pr-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-white"
          />
          <div class="absolute left-3 top-2.5 text-gray-400 dark:text-gray-500">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
        </div>
        
        <select 
          v-model="typeFilter" 
          class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-white"
        >
          <option value="all">All Types</option>
          <option value="product">Products Only</option>
          <option value="service">Services Only</option>
        </select>
      </div>
      
      <button 
        @click="openProductModal()"
        class="px-4 py-2 bg-indigo-600 dark:bg-indigo-500 text-white rounded-md shadow-sm hover:bg-indigo-700 dark:hover:bg-indigo-600 transition inline-flex items-center"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
        </svg>
        Add New Item
      </button>
    </div>
    
    <!-- Loading State -->
    <div v-if="isLoading" class="flex justify-center py-8">
      <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-indigo-500"></div>
    </div>
    
    <!-- Empty State -->
    <div 
      v-else-if="filteredProducts.length === 0" 
      class="bg-gray-50 dark:bg-gray-800 border-2 border-dashed border-gray-300 dark:border-gray-700 rounded-lg p-8 text-center"
    >
      <svg xmlns="http://www.w3.org/2000/svg" class="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
      </svg>
      <h3 class="mt-4 text-lg font-medium text-gray-900 dark:text-white">No products found</h3>
      <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
        {{ searchQuery || typeFilter !== 'all' ? 'Try adjusting your filters.' : 'Get started by adding a new product or service to your catalog.' }}
      </p>
      <div class="mt-6">
        <button 
          @click="openProductModal()"
          class="px-4 py-2 bg-indigo-600 dark:bg-indigo-500 text-white rounded-md shadow-sm hover:bg-indigo-700 dark:hover:bg-indigo-600 transition inline-flex items-center"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
          </svg>
          Add New Item
        </button>
      </div>
    </div>
    
    <!-- Products Table -->
    <div v-else class="overflow-x-auto bg-white dark:bg-gray-800 shadow-md rounded-lg">
      <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
        <thead class="bg-gray-50 dark:bg-gray-700">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Name</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Type</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Price</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Unit</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Tax Rate</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Status</th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
          <tr v-for="product in filteredProducts" :key="product.id" class="hover:bg-gray-50 dark:hover:bg-gray-700">
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="font-medium text-gray-900 dark:text-white">{{ product.name }}</div>
              <div class="text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs">{{ truncateText(product.description, 50) }}</div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span 
                class="px-2 py-1 text-xs rounded-full"
                :class="product.type === 'product' ? 
                  'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200' : 
                  'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'"
              >
                {{ product.type === 'product' ? 'Product' : 'Service' }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">${{ formatNumber(product.price) }}</td>
            <td class="px-6 py-4 whitespace-nowrap">{{ product.unit || 'each' }}</td>
            <td class="px-6 py-4 whitespace-nowrap">{{ product.taxRate }}%</td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span 
                class="px-2 py-1 text-xs rounded-full"
                :class="product.isActive ? 
                  'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' : 
                  'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'"
              >
                {{ product.isActive ? 'Active' : 'Inactive' }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <button 
                @click="openProductModal(product)"
                class="text-indigo-600 dark:text-indigo-400 hover:text-indigo-900 dark:hover:text-indigo-300 mr-4"
              >
                Edit
              </button>
              <button 
                @click="confirmDelete(product)"
                class="text-red-600 dark:text-red-400 hover:text-red-900 dark:hover:text-red-300"
              >
                Delete
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    
    <!-- Product Modal -->
    <teleport to="body">
      <div v-if="showProductModal" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
        <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
          <div class="fixed inset-0 bg-gray-500 bg-opacity-75 dark:bg-gray-900 dark:bg-opacity-75 transition-opacity" aria-hidden="true" @click="showProductModal = false"></div>
          
          <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
          
          <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
            <div class="bg-white dark:bg-gray-800 px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
              <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white mb-4">
                {{ currentProduct.id ? 'Edit' : 'Add' }} Product/Service
              </h3>
              
              <form @submit.prevent="saveProduct">
                <div class="mb-4">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Type</label>
                  <div class="flex gap-4">
                    <label class="inline-flex items-center">
                      <input type="radio" v-model="currentProduct.type" value="product" class="form-radio">
                      <span class="ml-2">Product</span>
                    </label>
                    <label class="inline-flex items-center">
                      <input type="radio" v-model="currentProduct.type" value="service" class="form-radio">
                      <span class="ml-2">Service</span>
                    </label>
                  </div>
                </div>
                
                <div class="mb-4">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Name</label>
                  <input 
                    type="text" 
                    v-model="currentProduct.name"
                    class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-white"
                    required
                  >
                </div>
                
                <div class="mb-4">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Description</label>
                  <textarea 
                    v-model="currentProduct.description"
                    rows="3"
                    class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-white"
                  ></textarea>
                </div>
                
                <div class="grid grid-cols-2 gap-4 mb-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Price</label>
                    <div class="relative">
                      <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <span class="text-gray-500 dark:text-gray-400">$</span>
                      </div>
                      <input 
                        type="number" 
                        v-model="currentProduct.price"
                        min="0" 
                        step="0.01"
                        class="w-full pl-7 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-white"
                        required
                      >
                    </div>
                  </div>
                  
                  <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Unit</label>
                    <select 
                      v-model="currentProduct.unit"
                      class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-white"
                    >
                      <option value="each">Each</option>
                      <option value="sq ft">Square Foot</option>
                      <option value="ln ft">Linear Foot</option>
                      <option value="hour">Hour</option>
                      <option value="day">Day</option>
                      <option value="sheet">Sheet</option>
                      <option value="box">Box</option>
                      <option value="custom">Custom...</option>
                    </select>
                    <input 
                      v-if="currentProduct.unit === 'custom'"
                      type="text"
                      v-model="customUnit"
                      placeholder="Enter custom unit"
                      class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-white mt-2"
                    >
                  </div>
                </div>
                
                <div class="grid grid-cols-2 gap-4 mb-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Tax Rate (%)</label>
                    <input 
                      type="number" 
                      v-model="currentProduct.taxRate"
                      min="0" 
                      step="0.1"
                      class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-white"
                    >
                  </div>
                  
                  <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Status</label>
                    <div class="flex items-center mt-2">
                      <label class="inline-flex items-center">
                        <input type="checkbox" v-model="currentProduct.isActive" class="form-checkbox">
                        <span class="ml-2">Active</span>
                      </label>
                    </div>
                  </div>
                </div>
                
                <div class="bg-gray-50 dark:bg-gray-700 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                  <button 
                    type="submit"
                    class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-indigo-600 dark:bg-indigo-500 text-base font-medium text-white hover:bg-indigo-700 dark:hover:bg-indigo-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:ml-3 sm:w-auto sm:text-sm"
                    :disabled="saveLoading"
                  >
                    <svg v-if="saveLoading" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    {{ currentProduct.id ? 'Update' : 'Create' }}
                  </button>
                  <button 
                    type="button"
                    @click="showProductModal = false"
                    class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-base font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </teleport>
    
    <!-- Delete Confirmation Modal -->
    <teleport to="body">
      <div v-if="showDeleteModal" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
        <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
          <div class="fixed inset-0 bg-gray-500 bg-opacity-75 dark:bg-gray-900 dark:bg-opacity-75 transition-opacity" aria-hidden="true" @click="showDeleteModal = false"></div>
          
          <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
          
          <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
            <div class="bg-white dark:bg-gray-800 px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
              <div class="sm:flex sm:items-start">
                <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 dark:bg-red-900 sm:mx-0 sm:h-10 sm:w-10">
                  <svg class="h-6 w-6 text-red-600 dark:text-red-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                  </svg>
                </div>
                <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                  <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white" id="modal-title">
                    Delete {{ productToDelete?.name }}
                  </h3>
                  <div class="mt-2">
                    <p class="text-sm text-gray-500 dark:text-gray-400">
                      Are you sure you want to delete this item? This action cannot be undone.
                    </p>
                    <p class="text-sm text-red-500 dark:text-red-400 mt-2">
                      Deleting this item will remove it from all future estimates and invoices.
                    </p>
                  </div>
                </div>
              </div>
            </div>
            <div class="bg-gray-50 dark:bg-gray-700 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
              <button 
                type="button"
                @click="deleteProduct"
                class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-red-600 dark:bg-red-500 text-base font-medium text-white hover:bg-red-700 dark:hover:bg-red-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:ml-3 sm:w-auto sm:text-sm"
                :disabled="deleteLoading"
              >
                <svg v-if="deleteLoading" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Delete
              </button>
              <button 
                type="button"
                @click="showDeleteModal = false"
                class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-base font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
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
import { ref, computed, onMounted } from 'vue';
import productsService from '@/services/products.service';
import { useToast } from 'vue-toastification';

// Toast notifications
const toast = useToast();

// State
const products = ref([]);
const isLoading = ref(false);
const searchQuery = ref('');
const typeFilter = ref('all');
const saveLoading = ref(false);
const deleteLoading = ref(false);

// Modal state
const showProductModal = ref(false);
const showDeleteModal = ref(false);
const currentProduct = ref({
  name: '',
  description: '',
  price: 0,
  taxRate: 7.5,
  type: 'service',
  unit: 'each',
  isActive: true
});
const productToDelete = ref(null);
const customUnit = ref('');

// Computed
const filteredProducts = computed(() => {
  let result = [...products.value];
  
  // Apply search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    result = result.filter(product => {
      return product.name.toLowerCase().includes(query) ||
             (product.description && product.description.toLowerCase().includes(query));
    });
  }
  
  // Apply type filter
  if (typeFilter.value !== 'all') {
    result = result.filter(product => product.type === typeFilter.value);
  }
  
  return result;
});

// Methods
const loadProducts = async () => {
  isLoading.value = true;
  try {
    const response = await productsService.listProducts();
    if (response && response.success && response.data) {
      products.value = response.data;
    } else {
      toast.error(`Error loading products: ${response.message}`);
    }
  } catch (error) {
    console.error('Error loading products:', error);
    toast.error(`Error loading products: ${error.message}`);
  } finally {
    isLoading.value = false;
  }
};

const openProductModal = (product = null) => {
  if (product) {
    // Edit existing product
    currentProduct.value = { ...product };
    // Handle custom unit
    if (!['each', 'sq ft', 'ln ft', 'hour', 'day', 'sheet', 'box'].includes(product.unit)) {
      customUnit.value = product.unit;
      currentProduct.value.unit = 'custom';
    } else {
      customUnit.value = '';
    }
  } else {
    // Create new product
    currentProduct.value = {
      name: '',
      description: '',
      price: 0,
      taxRate: 7.5,
      type: 'service',
      unit: 'each',
      isActive: true
    };
    customUnit.value = '';
  }
  showProductModal.value = true;
};

const saveProduct = async () => {
  try {
    saveLoading.value = true;
    
    // Process custom unit if selected
    if (currentProduct.value.unit === 'custom' && customUnit.value) {
      currentProduct.value.unit = customUnit.value;
    }
    
    let response;
    if (currentProduct.value.id) {
      // Update existing product
      const { id, ...productData } = currentProduct.value;
      response = await productsService.updateProduct(id, productData);
      if (response && response.success) {
        toast.success('Product updated successfully');
      } else if (response) {
        throw new Error(response.message || 'Failed to update product');
      }
    } else {
      // Create new product
      response = await productsService.createProduct(currentProduct.value);
      if (response && response.success) {
        toast.success('Product created successfully');
      } else if (response) {
        throw new Error(response.message || 'Failed to create product');
      }
    }
    
    // Reload products
    await loadProducts();
    showProductModal.value = false;
  } catch (error) {
    console.error('Error saving product:', error);
    toast.error(`Error saving product: ${error.message}`);
  } finally {
    saveLoading.value = false;
  }
};

const confirmDelete = (product) => {
  productToDelete.value = product;
  showDeleteModal.value = true;
};

const deleteProduct = async () => {
  try {
    deleteLoading.value = true;
    if (!productToDelete.value?.id) return;
    
    const response = await productsService.deleteProduct(productToDelete.value.id);
    if (response && response.success) {
      toast.success('Product deleted successfully');
      // Remove product from local array for immediate UI update
      products.value = products.value.filter(p => p.id !== productToDelete.value.id);
      showDeleteModal.value = false;
    } else if (response) {
      throw new Error(response.message || 'Failed to delete product');
    }
  } catch (error) {
    console.error('Error deleting product:', error);
    toast.error(`Error deleting product: ${error.message}`);
  } finally {
    deleteLoading.value = false;
  }
};

const formatNumber = (value) => {
  return parseFloat(value).toFixed(2);
};

const truncateText = (text, maxLength) => {
  if (!text) return '';
  if (text.length <= maxLength) return text;
  return text.substring(0, maxLength) + '...';
};

// Load products on component mount
onMounted(() => {
  loadProducts();
});
</script>
