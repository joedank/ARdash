<template>
  <div class="p-4 border rounded-lg shadow-lg bg-white dark:bg-gray-800 relative z-50 mt-16">
    <h3 class="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">Service Matching</h3>

    <!-- Loading State -->
    <div v-if="loading" class="text-center py-8">
      <svg class="animate-spin h-8 w-8 text-indigo-600 mx-auto" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      <p class="mt-4 text-gray-600 dark:text-gray-400">{{ loadingMessage }}</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="text-red-600 dark:text-red-400 p-4">
      <p><strong>Error:</strong> {{ error }}</p>
      <button @click="$emit('back')" class="mt-4 px-3 py-1 border border-gray-300 rounded-md text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600">
        Go Back
      </button>
    </div>

    <!-- Main Content - Product Matching Review -->
    <div v-else-if="matchResults && matchResults.lineItems" class="space-y-6">
      <!-- Match Summary -->
      <div class="bg-gray-50 dark:bg-gray-700 p-4 rounded-md">
        <h4 class="font-medium text-md text-gray-800 dark:text-gray-200 mb-2">Match Summary</h4>
        <div class="flex space-x-4 text-sm">
          <div class="flex flex-col items-center justify-center p-2 rounded bg-white dark:bg-gray-800">
            <span class="font-bold text-lg">{{ matchResults.summary?.total_items || 0 }}</span>
            <span class="text-gray-500 dark:text-gray-400">Total Items</span>
          </div>
          <div class="flex flex-col items-center justify-center p-2 rounded bg-green-50 dark:bg-green-900">
            <span class="font-bold text-lg text-green-600 dark:text-green-400">{{ matchResults.summary?.matched_items || 0 }}</span>
            <span class="text-green-500 dark:text-green-400">Matched</span>
          </div>
          <div class="flex flex-col items-center justify-center p-2 rounded bg-amber-50 dark:bg-amber-900">
            <span class="font-bold text-lg text-amber-600 dark:text-amber-400">{{ matchResults.summary?.unmatched_items || 0 }}</span>
            <span class="text-amber-500 dark:text-amber-400">Unmatched</span>
          </div>
        </div>
      </div>

      <!-- Line Items List -->
      <div v-for="(item, index) in matchResults.lineItems" :key="index" 
           class="border rounded-md p-4 transition-all duration-200"
           :class="{
             'border-green-300 dark:border-green-700 bg-green-50 dark:bg-green-900/20': item.match_status === 'CONFIDENT_MATCH',
             'border-amber-300 dark:border-amber-700 bg-amber-50 dark:bg-amber-900/20': item.match_status === 'POSSIBLE_MATCH',
             'border-red-300 dark:border-red-700 bg-red-50 dark:bg-red-900/20': item.match_status === 'WEAK_MATCH' || item.match_status === 'NO_MATCH'
           }">
        
        <!-- Original Line Item -->
        <div class="flex justify-between items-start mb-3">
          <div>
            <h5 class="text-md font-semibold">{{ item.original.product_name }}</h5>
            <div class="text-sm text-gray-600 dark:text-gray-400">
              <p>{{ item.original.quantity }} {{ item.original.unit }} × ${{ item.original.unit_price.toFixed(2) }} = ${{ (item.original.quantity * item.original.unit_price).toFixed(2) }}</p>
              <p class="text-xs mt-1 text-gray-500 dark:text-gray-500">{{ item.original.description }}</p>
            </div>
          </div>
          <div class="text-xs px-2 py-1 rounded-full"
               :class="{
                 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200': item.match_status === 'CONFIDENT_MATCH',
                 'bg-amber-100 text-amber-800 dark:bg-amber-900 dark:text-amber-200': item.match_status === 'POSSIBLE_MATCH',
                 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200': item.match_status === 'WEAK_MATCH',
                 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200': item.match_status === 'NO_MATCH'
               }">
            {{ formatMatchStatus(item.match_status) }}
          </div>
        </div>
        
        <!-- Service Matches -->
        <div v-if="item.matches && item.matches.length > 0" class="mt-4 border-t border-gray-200 dark:border-gray-700 pt-3">
          <h6 class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Service Matches</h6>
          
          <!-- Match Selection Radio Group -->
          <div class="space-y-2">
            <div v-for="(match, matchIndex) in item.matches" :key="matchIndex"
                 class="flex items-start p-2 rounded-md cursor-pointer"
                 :class="{
                   'bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800': selectedMatches[index] === matchIndex,
                   'hover:bg-gray-50 dark:hover:bg-gray-700/50': selectedMatches[index] !== matchIndex
                 }"
                 @click="selectMatch(index, matchIndex)">
              
              <input type="radio"
                     :id="`match-${index}-${matchIndex}`"
                     :name="`product-match-${index}`"
                     :value="matchIndex"
                     v-model="selectedMatches[index]"
                     class="mr-3 mt-1"
                     @click.stop>
              
              <label :for="`match-${index}-${matchIndex}`" class="flex-grow cursor-pointer">
                <div class="flex justify-between">
                  <span class="font-medium">{{ match.service.name }}</span>
                  <span class="text-xs bg-gray-100 dark:bg-gray-800 px-2 py-1 rounded-full text-gray-600 dark:text-gray-400">
                    Score: {{ (match.score * 100).toFixed(0) }}%
                  </span>
                </div>
                <div class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                  <p>Unit: {{ match.service.unit }} | Rate: ${{ match.service.rate.toFixed(2) }}/{{ match.service.unit }}</p>
                  <p v-if="match.service.description" class="text-xs mt-1 text-gray-500 dark:text-gray-500">{{ match.service.description }}</p>
                </div>
              </label>
            </div>
          </div>
          
          <!-- Create New Service Option -->
          <div class="mt-3 flex items-start p-2 rounded-md cursor-pointer"
               :class="{
                 'bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800': selectedMatches[index] === 'new',
                 'hover:bg-gray-50 dark:hover:bg-gray-700/50': selectedMatches[index] !== 'new'
               }"
               @click="selectMatch(index, 'new')">
            
            <input type="radio"
                   :id="`match-${index}-new`"
                   :name="`product-match-${index}`"
                   value="new"
                   v-model="selectedMatches[index]"
                   class="mr-3 mt-1"
                   @click.stop>
            
            <label :for="`match-${index}-new`" class="flex-grow cursor-pointer">
              <div class="font-medium text-green-600 dark:text-green-400">Create New Service</div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                Add this as a new service to your catalog
              </div>
            </label>
          </div>
        </div>
        
        <!-- No Matches Found -->
        <div v-else class="mt-4 border-t border-gray-200 dark:border-gray-700 pt-3">
          <p class="text-sm text-gray-600 dark:text-gray-400">No matching services found in your catalog.</p>
          
          <!-- Auto-select Create New Service -->
          <div class="mt-3 flex items-start p-2 rounded-md bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800">
            <input type="radio"
                   :id="`match-${index}-new-auto`"
                   :name="`product-match-${index}`"
                   value="new"
                   v-model="selectedMatches[index]"
                   class="mr-3 mt-1"
                   checked>
            
            <label :for="`match-${index}-new-auto`" class="flex-grow">
              <div class="font-medium text-green-600 dark:text-green-400">Create New Service</div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                Add this as a new service to your catalog
              </div>
            </label>
          </div>
        </div>
      </div>
      
      <!-- New Service Forms (shown when "Create New Service" is selected) -->
      <div v-if="showNewProductForms" class="mt-6 p-4 border rounded-md bg-gray-50 dark:bg-gray-700">
        <h4 class="text-md font-semibold mb-3 text-gray-800 dark:text-gray-200">New Services</h4>
        
        <div v-for="(item, index) in matchResults.lineItems" :key="`new-${index}`" 
             v-show="selectedMatches[index] === 'new'"
             class="mb-6 p-4 bg-white dark:bg-gray-800 rounded-md shadow-sm">
          
          <h5 class="font-medium mb-3">New Service: {{ item.original.product_name }}</h5>
          
          <div class="space-y-3">
            <div>
              <label :for="`new-product-name-${index}`" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
               Service Name
              </label>
              <input
                :id="`new-product-name-${index}`"
                type="text"
                v-model="newProducts[index].name"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
                required
              />
            </div>
            
            <div class="grid grid-cols-3 gap-3">
              <div>
                <label :for="`new-product-price-${index}`" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Price
                </label>
                <input
                  :id="`new-product-price-${index}`"
                  type="number"
                  v-model.number="newProducts[index].price"
                  class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
                  step="0.01"
                  min="0"
                  required
                />
              </div>
              
              <div>
                <label :for="`new-product-unit-${index}`" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Unit
                </label>
                <input
                  :id="`new-product-unit-${index}`"
                  type="text"
                  v-model="newProducts[index].unit"
                  class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
                  required
                />
              </div>
              
              <div>
                <label :for="`new-product-type-${index}`" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Type
                </label>
                <select
                  :id="`new-product-type-${index}`"
                  v-model="newProducts[index].type"
                  class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
                  required
                  disabled
                >
                  <option value="service">Service</option>
                </select>
              </div>
            </div>
            
            <div>
              <label :for="`new-product-description-${index}`" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
               Service Description
              </label>
              <textarea
                :id="`new-product-description-${index}`"
                v-model="newProducts[index].description"
                rows="2"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
              ></textarea>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Action Buttons -->
      <div class="flex justify-between pt-4 border-t border-gray-200 dark:border-gray-700">
        <button
          @click="$emit('back')"
          class="inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          Go Back
        </button>
        
        <div>
          <button
            v-if="showNewProductForms"
            @click="showNewProductForms = false"
            class="inline-flex items-center px-4 py-2 mr-3 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Back to Matches
          </button>
          
          <button
            v-if="hasNewProducts && !showNewProductForms"
            @click="showNewProductForms = true"
            class="inline-flex items-center px-4 py-2 mr-3 border border-indigo-300 dark:border-indigo-600 rounded-md shadow-sm text-sm font-medium text-indigo-700 dark:text-indigo-200 bg-indigo-50 dark:bg-indigo-900/20 hover:bg-indigo-100 dark:hover:bg-indigo-800/30 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Review New Services ({{ newProductCount }})
          </button>
          
          <button
            @click="finalizeMatches"
            :disabled="loading"
            class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="loading">Processing...</span>
            <span v-else>{{ showNewProductForms ? 'Save & Continue' : 'Use Selected Matches' }}</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useToast } from 'vue-toastification';
import estimatesService from '@/services/estimates.service.js';

const toast = useToast();

// Props
const props = defineProps({
  lineItems: {
    type: Array,
    required: true
  }
});

// Emits
const emit = defineEmits(['back', 'finished']);

// State
const loading = ref(false);
const loadingMessage = ref('Matching products...');
const error = ref(null);
const matchResults = ref(null);
const selectedMatches = ref({});
const newProducts = ref({});
const showNewProductForms = ref(false);

// Computed properties
const hasNewProducts = computed(() => {
  return Object.values(selectedMatches.value).some(match => match === 'new');
});

const newProductCount = computed(() => {
  return Object.values(selectedMatches.value).filter(match => match === 'new').length;
});

// Initialize component
onMounted(async () => {
  if (props.lineItems && props.lineItems.length > 0) {
    await matchProducts();
  } else {
    error.value = 'No line items provided for matching.';
  }
});

// Method to format match status for display
const formatMatchStatus = (status) => {
  switch(status) {
    case 'CONFIDENT_MATCH': return 'Strong Match';
    case 'POSSIBLE_MATCH': return 'Possible Match';
    case 'WEAK_MATCH': return 'Weak Match';
    case 'NO_MATCH': return 'No Match';
    default: return status;
  }
};

// Match products using backend service
const matchProducts = async () => {
  loading.value = true;
  error.value = null;
  loadingMessage.value = 'Matching products to your catalog...';
  
  try {
    const response = await estimatesService.matchProductsToLineItems(props.lineItems);
    
    if (response.success && response.data) {
      matchResults.value = response.data;
      
      // Initialize selected matches (default to first match or 'new' if no matches)
      matchResults.value.lineItems.forEach((item, index) => {
        if (item.matches && item.matches.length > 0 && item.matches.some(m => m.is_primary)) {
          // Find index of primary match
          const primaryIndex = item.matches.findIndex(m => m.is_primary);
          selectedMatches.value[index] = primaryIndex;
        } else {
          // No matches or no primary match, default to 'new'
          selectedMatches.value[index] = 'new';
        }
        
        // Initialize new product data from original line item
        newProducts.value[index] = {
          name: item.original.product_name || '',
          price: item.original.unit_price || 0,
          unit: item.original.unit || '',
          description: item.original.description || '',
          type: 'product'
        };
      });
      
      toast.success('Product matching completed.');
    } else {
      error.value = response.message || 'Failed to match products.';
      toast.error(error.value);
    }
  } catch (err) {
    console.error('Error calling product matching API:', err);
    error.value = err.response?.data?.message || err.message || 'An unexpected error occurred during product matching.';
    toast.error(error.value);
  } finally {
    loading.value = false;
  }
};

// Select a match for a line item
const selectMatch = (lineItemIndex, matchIndex) => {
  selectedMatches.value[lineItemIndex] = matchIndex;
};

// Finalize matches and proceed
const finalizeMatches = async () => {
  // If showing new product forms, validate and save new products
  if (showNewProductForms && hasNewProducts) {
    // Validate new product forms
    const invalidProducts = [];
    
    Object.entries(selectedMatches.value).forEach(([lineItemIndex, matchValue]) => {
      if (matchValue === 'new') {
        const product = newProducts.value[lineItemIndex];
        if (!product.name || !product.price || !product.unit) {
          invalidProducts.push(parseInt(lineItemIndex));
        }
      }
    });
    
    if (invalidProducts.length > 0) {
      const itemNumbers = invalidProducts.map(i => i + 1).join(', ');
      toast.error(`Please complete all required fields for new product(s) ${itemNumbers}.`);
      return;
    }
    
    // Create new products
    loading.value = true;
    loadingMessage.value = 'Creating new products...';
    
    try {
      // Prepare array of new products to create
      const productsToCreate = [];
      
      Object.entries(selectedMatches.value).forEach(([lineItemIndex, matchValue]) => {
        if (matchValue === 'new') {
          productsToCreate.push(newProducts.value[lineItemIndex]);
        }
      });
      
      if (productsToCreate.length > 0) {
        const response = await estimatesService.createProductsFromLineItems(productsToCreate);
        
        if (response.success && response.data) {
          toast.success(`Successfully created ${response.data.length} new products.`);
          
          // Update the finalData with newly created product IDs
          // This would require matching new products back to their line items
          // For now, just toggle back to matches view to continue
          showNewProductForms.value = false;
        } else {
          error.value = response.message || 'Failed to create new products.';
          toast.error(error.value);
          return;
        }
      }
    } catch (err) {
      console.error('Error creating new products:', err);
      error.value = err.response?.data?.message || err.message || 'An unexpected error occurred while creating products.';
      toast.error(error.value);
      return;
    } finally {
      loading.value = false;
    }
  }
  
  // Prepare finalized data for creating estimate
  const finalizedLineItems = matchResults.value.lineItems.map((item, index) => {
    const matchIndex = selectedMatches.value[index];
    
    // If using existing product
    if (matchIndex !== 'new' && item.matches && item.matches[matchIndex]) {
      const selectedProduct = item.matches[matchIndex].product;
      return {
        product_id: selectedProduct.id,
        product_name: selectedProduct.name,
        quantity: item.original.quantity,
        unit: selectedProduct.unit,
        unit_price: selectedProduct.price,
        description: item.original.description || selectedProduct.description || '',
        notes: item.original.notes || ''
      };
    }
    // If creating new product
    else {
      return {
        product_id: null, // Will be populated after product creation
        product_name: newProducts.value[index].name,
        quantity: item.original.quantity,
        unit: newProducts.value[index].unit,
        unit_price: newProducts.value[index].price,
        description: newProducts.value[index].description || '',
        notes: item.original.notes || ''
      };
    }
  });
  
  // Emit finished event with finalized data
  emit('finished', {
    lineItems: finalizedLineItems,
    // Additional estimate metadata could be included here
  });
};
</script>

<style scoped>
/* Add any component-specific styles here */
</style>
