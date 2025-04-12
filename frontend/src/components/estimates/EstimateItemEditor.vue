<template>
  <div class="estimate-item-editor h-full flex flex-col overflow-hidden">
    <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center">
      <h3 class="text-lg font-semibold text-gray-900 dark:text-gray-100">Estimate Items</h3>
      <button
        @click="addItem"
        class="px-3 py-1.5 inline-flex items-center gap-1 text-white bg-blue-600 dark:bg-blue-700 rounded-md hover:bg-blue-700 dark:hover:bg-blue-800"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
        </svg>
        Add Item
      </button>
    </div>

    <!-- No items state -->
    <div v-if="items.length === 0" class="flex-1 flex items-center justify-center p-4">
      <div class="text-center">
        <svg xmlns="http://www.w3.org/2000/svg" class="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">
          No estimate items generated yet.
        </p>
      </div>
    </div>

    <!-- Items list -->
    <div v-else class="flex-1 overflow-auto">
      <div class="p-4 space-y-4">
        <div 
          v-for="(item, index) in items" 
          :key="index"
          class="border border-gray-200 dark:border-gray-700 rounded-lg p-4 relative"
          :class="{ 'border-blue-300 dark:border-blue-700 bg-blue-50 dark:bg-blue-900/20': item.sourceId === activeSourceId }"
          @mouseenter="handleMouseEnter(item.sourceId)"
          @mouseleave="handleMouseLeave()"
        >
          <!-- Source badge -->
          <div 
            v-if="item.sourceId && sourceMap[item.sourceId]"
            class="absolute top-2 right-2 px-2 py-1 text-xs rounded-full"
            :class="getSourceBadgeClass(item.sourceType)"
          >
            {{ getSourceLabel(item.sourceType) }}
            <span 
              v-if="sourceMap[item.sourceId].label" 
              class="ml-1 font-normal"
              :title="sourceMap[item.sourceId].label"
            >
              ({{ truncateSourceLabel(sourceMap[item.sourceId].label) }})
            </span>
          </div>

          <!-- Item editor fields -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Description
              </label>
              <textarea
                v-model="item.description"
                rows="2"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white text-sm"
                placeholder="Item description"
                @change="updateItem(index)"
              ></textarea>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Quantity
              </label>
              <div class="flex gap-2">
                <input
                  type="number"
                  v-model="item.quantity"
                  min="0.01"
                  step="0.01"
                  class="w-2/3 rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white text-sm"
                  @change="updateItem(index)"
                />
                <input
                  type="text"
                  v-model="item.unit"
                  class="w-1/3 rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white text-sm"
                  placeholder="Unit"
                  @change="updateItem(index)"
                />
              </div>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Unit Price
              </label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <span class="text-gray-500 dark:text-gray-400">$</span>
                </div>
                <input
                  type="number"
                  v-model="item.unitPrice"
                  min="0.01"
                  step="0.01"
                  class="pl-7 w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white text-sm"
                  @change="updateItem(index)"
                />
              </div>
            </div>
            
            <div class="md:col-span-2 flex justify-between items-center">
              <div class="flex items-center">
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300 mr-2">Total:</span>
                <span class="text-lg font-bold text-gray-900 dark:text-white">${{ formatNumber(item.total) }}</span>
              </div>
              
              <button
                @click="removeItem(index)"
                class="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300 p-1"
                title="Remove item"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Totals section -->
    <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800">
      <div class="flex justify-end">
        <div class="w-64 space-y-2">
          <div class="flex justify-between text-sm">
            <span class="text-gray-600 dark:text-gray-400">Subtotal:</span>
            <span class="font-medium text-gray-900 dark:text-white">${{ formatNumber(subtotal) }}</span>
          </div>
          <div class="flex justify-between border-t border-gray-200 dark:border-gray-700 pt-2 text-base">
            <span class="font-medium text-gray-700 dark:text-gray-300">Total:</span>
            <span class="font-bold text-gray-900 dark:text-white">${{ formatNumber(subtotal) }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue';

const props = defineProps({
  items: {
    type: Array,
    default: () => []
  },
  sourceMap: {
    type: Object,
    default: () => ({})
  },
  activeSourceId: {
    type: String,
    default: null
  }
});

const emit = defineEmits(['updateItem', 'highlightSource']);

// Clone the items for internal state
const localItems = ref(JSON.parse(JSON.stringify(props.items)));

// Watch for changes from parent
watch(() => props.items, (newItems) => {
  // Only update if the arrays are different
  if (JSON.stringify(localItems.value) !== JSON.stringify(newItems)) {
    localItems.value = JSON.parse(JSON.stringify(newItems));
  }
}, { deep: true });

// Calculate subtotal based on items
const subtotal = computed(() => {
  return localItems.value.reduce((sum, item) => {
    return sum + (parseFloat(item.total) || 0);
  }, 0);
});

// --- Methods ---

/**
 * Add a new empty item
 */
const addItem = () => {
  const newItem = {
    description: '',
    quantity: 1,
    unit: 'sq ft',
    unitPrice: 0,
    total: 0,
    sourceType: null,
    sourceId: null
  };
  
  localItems.value.push(newItem);
  emit('updateItem', localItems.value);
};

/**
 * Remove an item by index
 */
const removeItem = (index) => {
  if (index >= 0 && index < localItems.value.length) {
    localItems.value.splice(index, 1);
    emit('updateItem', localItems.value);
  }
};

/**
 * Update an item after editing
 */
const updateItem = (index) => {
  if (index >= 0 && index < localItems.value.length) {
    const item = localItems.value[index];
    
    // Calculate total
    const quantity = parseFloat(item.quantity) || 0;
    const unitPrice = parseFloat(item.unitPrice) || 0;
    item.total = quantity * unitPrice;
    
    // Update parent
    emit('updateItem', localItems.value);
  }
};

/**
 * Handle mouse enter on an item
 */
const handleMouseEnter = (sourceId) => {
  if (sourceId) {
    emit('highlightSource', sourceId);
  }
};

/**
 * Handle mouse leave on an item
 */
const handleMouseLeave = () => {
  emit('highlightSource', null);
};

/**
 * Get source badge class based on source type
 */
const getSourceBadgeClass = (sourceType) => {
  switch (sourceType) {
    case 'measurement':
      return 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200';
    case 'condition':
      return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200';
    case 'material':
      return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200';
    default:
      return 'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200';
  }
};

/**
 * Get source label based on source type
 */
const getSourceLabel = (sourceType) => {
  switch (sourceType) {
    case 'measurement':
      return '📐 Measurement';
    case 'condition':
      return '⚠️ Condition';
    case 'material':
      return '🧱 Material';
    default:
      return 'Source';
  }
};

/**
 * Truncate source label for display
 */
const truncateSourceLabel = (label) => {
  if (!label) return '';
  return label.length > 15 ? label.substring(0, 12) + '...' : label;
};

/**
 * Format number for display
 */
const formatNumber = (value) => {
  return parseFloat(value).toFixed(2);
};
</script>

<style scoped>
/* Add any component-specific styles here */
</style>