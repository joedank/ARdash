<template>
  <div class="line-items-editor w-full">
    <div class="mb-2 flex justify-between items-center">
      <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
        {{ label }}
      </label>
      <div class="flex gap-2">
        <button
          type="button"
          @click="addLineItem"
          class="text-sm px-3 py-1.5 inline-flex items-center gap-1 text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30 rounded-md hover:bg-blue-100 dark:hover:bg-blue-900/40"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Add Item
        </button>
        <button
          v-if="showProductSelector"
          type="button"
          @click="openProductSelector"
          class="text-sm px-3 py-1.5 inline-flex items-center gap-1 text-green-600 dark:text-green-400 bg-green-50 dark:bg-green-900/30 rounded-md hover:bg-green-100 dark:hover:bg-green-900/40"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
          </svg>
          Add from Catalog
        </button>
      </div>
    </div>

    <!-- No Items Message -->
    <div
      v-if="items.length === 0"
      class="border-2 border-dashed border-gray-300 dark:border-gray-700 rounded-md p-6 text-center"
    >
      <svg xmlns="http://www.w3.org/2000/svg" class="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
      </svg>
      <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">
        No items added yet. Click "Add Item" to get started.
      </p>
    </div>

    <!-- Items Table -->
    <div v-else class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
        <thead class="bg-gray-50 dark:bg-gray-700">
          <tr>
            <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
              Description
            </th>
            <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider w-24">
              Quantity
            </th>
            <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider w-24">
              Unit
            </th>
            <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider w-32">
              Price
            </th>
            <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider w-32">
              Total
            </th>
            <th scope="col" class="px-3 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider w-16">
              Actions
            </th>
          </tr>
        </thead>
        <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
          <tr v-for="(item, index) in items" :key="index">
            <td class="px-3 py-4">
              <textarea
                v-model="item.description"
                rows="2"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white text-sm"
                placeholder="Item description"
              ></textarea>
            </td>
            <td class="px-3 py-4">
              <input
                type="number"
                v-model="item.quantity"
                min="0.01"
                step="0.01"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white text-sm"
                @change="calculateItemTotal(index)"
              />
            </td>
            <td class="px-3 py-4">
              <select
                v-model="item.unit"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white text-sm"
              >
                <option value="each">each</option>
                <option value="sq ft">sq ft</option>
                <option value="ln ft">ln ft</option>
                <option value="hours">hours</option>
                <option value="pieces">pieces</option>
              </select>
            </td>
            <td class="px-3 py-4">
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <span class="text-gray-500 dark:text-gray-400">$</span>
                </div>
                <input
                  type="number"
                  v-model="item.price"
                  min="0.01"
                  step="0.01"
                  class="pl-7 w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white text-sm"
                  @change="calculateItemTotal(index)"
                />
              </div>
            </td>
            <td class="px-3 py-4">
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <span class="text-gray-500 dark:text-gray-400">$</span>
                </div>
                <input
                  type="number"
                  v-model="item.itemTotal"
                  disabled
                  class="pl-7 w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm bg-gray-50 dark:bg-gray-600 dark:text-white text-sm"
                />
              </div>
            </td>
            <td class="px-3 py-4 text-right">
              <button
                type="button"
                @click="removeLineItem(index)"
                class="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Error Message -->
    <p v-if="error" class="text-sm text-red-600 dark:text-red-400 mt-2">
      {{ error }}
    </p>

    <!-- Totals Section -->
    <div class="mt-4 flex justify-end">
      <div class="w-64 space-y-2">
        <div class="flex justify-between text-sm">
          <span class="text-gray-600 dark:text-gray-400">Subtotal:</span>
          <span class="font-medium text-gray-900 dark:text-white">${{ formatNumber(subtotal) }}</span>
        </div>
        <div v-if="discount > 0" class="flex justify-between text-sm">
          <span class="text-gray-600 dark:text-gray-400">Discount:</span>
          <span class="font-medium text-gray-900 dark:text-white">-${{ formatNumber(discount) }}</span>
        </div>
        <div class="flex justify-between border-t border-gray-200 dark:border-gray-700 pt-2 text-base">
          <span class="font-medium text-gray-700 dark:text-gray-300">Total:</span>
          <span class="font-bold text-gray-900 dark:text-white">${{ formatNumber(total) }}</span>
        </div>
      </div>
    </div>

    <!-- Discount Section -->
    <div class="mt-4 border-t border-gray-200 dark:border-gray-700 pt-4">
      <label class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2 block">
        Discount
      </label>
      <div class="flex gap-4">
        <div class="flex-1">
          <div class="relative">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <span class="text-gray-500 dark:text-gray-400">$</span>
            </div>
            <input
              type="number"
              v-model="discount"
              min="0"
              step="0.01"
              class="pl-7 w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
              :disabled="discountPercentage > 0"
              @change="updateTotal"
            />
          </div>
          <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
            Amount ($)
          </p>
        </div>
        <div class="flex-1">
          <div class="relative">
            <input
              type="number"
              v-model="discountPercentage"
              min="0"
              max="100"
              step="0.1"
              class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
              :disabled="discount > 0"
              @change="calculateDiscountFromPercentage"
            />
            <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
              <span class="text-gray-500 dark:text-gray-400">%</span>
            </div>
          </div>
          <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
            Percentage (%)
          </p>
        </div>
      </div>
    </div>
    <!-- Product Selector Modal -->
    <teleport to="body">
      <div
        v-if="isProductSelectorOpen"
        class="fixed inset-0 z-50 overflow-y-auto"
        @click.self="isProductSelectorOpen = false"
      >
        <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
          <!-- Background overlay -->
          <div class="fixed inset-0 bg-gray-500 bg-opacity-75 dark:bg-gray-900 dark:bg-opacity-75 transition-opacity"></div>

          <span class="hidden sm:inline-block sm:align-middle sm:h-screen">&#8203;</span>

          <div
            class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full"
            role="dialog"
            aria-modal="true"
            @click.stop
          >
            <div class="bg-white dark:bg-gray-800 px-4 pt-5 pb-4 sm:p-6">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-medium text-gray-900 dark:text-white">
                  Select from Product Catalog
                </h3>
                <button
                  type="button"
                  @click="isProductSelectorOpen = false"
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
                    v-model="productSearchQuery"
                    placeholder="Search products..."
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

              <!-- Type Filter -->
              <div class="mb-4">
                <div class="flex items-center justify-start gap-4">
                  <label class="inline-flex items-center">
                    <input
                      type="radio"
                      v-model="productTypeFilter"
                      value="all"
                      class="rounded-full text-blue-600 focus:ring-blue-500 dark:bg-gray-700"
                    />
                    <span class="ml-2 text-sm text-gray-700 dark:text-gray-300">All</span>
                  </label>
                  <label class="inline-flex items-center">
                    <input
                      type="radio"
                      v-model="productTypeFilter"
                      value="product"
                      class="rounded-full text-blue-600 focus:ring-blue-500 dark:bg-gray-700"
                    />
                    <span class="ml-2 text-sm text-gray-700 dark:text-gray-300">Products</span>
                  </label>
                  <label class="inline-flex items-center">
                    <input
                      type="radio"
                      v-model="productTypeFilter"
                      value="service"
                      class="rounded-full text-blue-600 focus:ring-blue-500 dark:bg-gray-700"
                    />
                    <span class="ml-2 text-sm text-gray-700 dark:text-gray-300">Services</span>
                  </label>
                </div>
              </div>

              <!-- Loading Indicator -->
              <div v-if="isProductsLoading" class="py-8 flex justify-center">
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
              <div v-else-if="filteredProducts.length === 0" class="py-8 text-center text-gray-500 dark:text-gray-400">
                <svg xmlns="http://www.w3.org/2000/svg" class="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <p class="mt-2">No products found. Try changing your search or filters.</p>
              </div>

              <!-- Product List -->
              <div v-else class="overflow-y-auto max-h-96">
                <div
                  v-for="product in filteredProducts"
                  :key="product.id"
                  @click="addProductToLineItems(product)"
                  class="mb-2 p-3 border border-gray-200 dark:border-gray-700 rounded-md cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700"
                >
                  <div class="flex justify-between items-start">
                    <div>
                      <h4 class="font-medium text-gray-900 dark:text-white">
                        {{ product.name }}
                      </h4>
                      <p v-if="product.description" class="text-sm text-gray-600 dark:text-gray-400">
                        {{ truncateText(product.description, 100) }}
                      </p>
                    </div>
                    <div class="text-right">
                      <span class="font-bold text-gray-900 dark:text-white">
                        ${{ formatNumber(product.price) }}
                      </span>
                      <span
                        class="ml-2 px-2 py-0.5 text-xs rounded-full"
                        :class="product.type === 'product' ?
                          'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200' :
                          'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'"
                      >
                        {{ product.type === 'product' ? 'Product' : 'Service' }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="bg-gray-50 dark:bg-gray-700 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
              <button
                type="button"
                @click="isProductSelectorOpen = false"
                class="w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-base font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      </div>
    </teleport>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, nextTick } from 'vue';
import productsService from '@/services/products.service';

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  },
  label: {
    type: String,
    default: 'Items'
  },
  error: {
    type: String,
    default: ''
  },
  showProductSelector: {
    type: Boolean,
    default: true
  },
  initialDiscount: {
    type: Number,
    default: 0
  }
});

const emit = defineEmits(['update:modelValue', 'update:totals']);

// State
const items = ref([...props.modelValue]);
const discount = ref(props.initialDiscount || 0);
const discountPercentage = ref(0);
const isProductSelectorOpen = ref(false);
const products = ref([]);
const isProductsLoading = ref(false);
const productSearchQuery = ref('');
const productTypeFilter = ref('all');

// Flags to prevent recursive updates
let isUpdatingFromProps = false;
let isTotalsUpdatePending = false;
let totalsUpdateTimer = null;

// Watch for model value changes, but avoid recursive updates
watch(() => props.modelValue, (newValue) => {
  if (isUpdatingFromProps) return; // Skip if we're already updating from props

  isUpdatingFromProps = true;
  items.value = [...newValue];

  // Calculate totals without emitting modelValue update
  calculateTotalsWithoutEmit();

  // Reset flag after next render cycle
  nextTick(() => {
    isUpdatingFromProps = false;
  });
}, { deep: true });

// Watch for items changes, but avoid recursive updates
watch(items, (newValue) => {
  if (isUpdatingFromProps) return; // Skip if update is coming from props change

  // Emit update for v-model binding
  emit('update:modelValue', newValue);

  // Debounced totals calculation to avoid excessive updates
  if (!isTotalsUpdatePending) {
    isTotalsUpdatePending = true;

    // Use a timer to debounce calculations
    if (totalsUpdateTimer) clearTimeout(totalsUpdateTimer);

    totalsUpdateTimer = setTimeout(() => {
      calculateTotalsWithoutEmit();
      isTotalsUpdatePending = false;
    }, 50);
  }
}, { deep: true });

// Watch for discount changes
watch(discount, () => {
  if (discount.value > 0) {
    discountPercentage.value = 0;
  }
  if (!isUpdatingFromProps) {
    calculateTotalsWithoutEmit();
  }
});

// Computed properties
const subtotal = ref(0);
const taxTotal = ref(0);
const total = ref(0);

const filteredProducts = computed(() => {
  if (products.value.length === 0) {
    return [];
  }

  let filtered = [...products.value];

  // Apply type filter
  if (productTypeFilter.value !== 'all') {
    filtered = filtered.filter(product => product.type === productTypeFilter.value);
  }

  // Apply search filter
  if (productSearchQuery.value.trim()) {
    const query = productSearchQuery.value.toLowerCase();
    filtered = filtered.filter(product => {
      const name = product.name?.toLowerCase() || '';
      const description = product.description?.toLowerCase() || '';

      return name.includes(query) || description.includes(query);
    });
  }

  return filtered;
});

// Methods
const loadProducts = async () => {
  try {
    isProductsLoading.value = true;
    const response = await productsService.listProducts({ isActive: true });

    if (response && response.success && response.data) {
      products.value = response.data;
    } else {
      console.error('Error loading products:', response);
    }
  } catch (error) {
    console.error('Error loading products:', error);
  } finally {
    isProductsLoading.value = false;
  }
};

// Modified to prevent recursive updates
const addLineItem = () => {
  console.log('Adding new line item');
  // Use the current items array directly
  const newItem = {
    description: '',
    quantity: 1,
    unit: 'each',
    price: 0.00,
    taxRate: 0.00,
    itemTotal: 0.00
  };

  // Add the new item directly to the current items array
  items.value.push(newItem);

  // Vue will detect this change and trigger the watcher
  // The watcher will handle the emit and totals calculation
};

const removeLineItem = (index) => {
  items.value.splice(index, 1);
  // The watcher will handle updates
};

const calculateItemTotal = (index) => {
  const item = items.value[index];

  if (!item) return;

  const quantity = parseFloat(item.quantity) || 0;
  const price = parseFloat(item.price) || 0;

  const subtotal = quantity * price;
  item.itemTotal = subtotal.toFixed(2);

  // The watcher on items will handle the rest
};

// Calculate totals without emitting modelValue update
const calculateTotalsWithoutEmit = () => {
  let newSubtotal = 0;

  items.value.forEach(item => {
    const quantity = parseFloat(item.quantity) || 0;
    const price = parseFloat(item.price) || 0;

    const itemSubtotal = quantity * price;
    newSubtotal += itemSubtotal;

    // Update item total
    item.itemTotal = itemSubtotal.toFixed(2);
  });

  subtotal.value = newSubtotal;
  taxTotal.value = 0; // No tax calculation

  // Calculate total with discount
  const discountAmount = parseFloat(discount.value) || 0;
  total.value = newSubtotal - discountAmount;

  // Emit totals update in a safe, debounced way
  emitTotalsUpdate();
};

// Debounced emitter for totals updates
let totalsEmitTimer = null;
const emitTotalsUpdate = () => {
  if (totalsEmitTimer) clearTimeout(totalsEmitTimer);

  totalsEmitTimer = setTimeout(() => {
    emit('update:totals', {
      subtotal: subtotal.value,
      taxTotal: taxTotal.value,
      discount: parseFloat(discount.value) || 0,
      total: total.value
    });
  }, 50);
};

const updateTotal = () => {
  calculateTotalsWithoutEmit();
};

const calculateDiscountFromPercentage = () => {
  if (discountPercentage.value > 0) {
    discount.value = ((subtotal.value + taxTotal.value) * (discountPercentage.value / 100)).toFixed(2);
  }

  calculateTotalsWithoutEmit();
};

const openProductSelector = () => {
  isProductSelectorOpen.value = true;

  // Load products if not already loaded
  if (products.value.length === 0) {
    loadProducts();
  }
};

const addProductToLineItems = (product) => {
  console.log('Adding product to line items:', product);
  const newItem = {
    description: product.name + (product.description ? '\n' + product.description : ''),
    quantity: 1,
    unit: product.unit || 'each',
    price: product.price,
    taxRate: product.taxRate || 0,
    itemTotal: 0 // Will be calculated
  };

  // Add the item directly
  items.value.push(newItem);

  // Calculate the new item's total - watch will handle the rest
  calculateItemTotal(items.value.length - 1);

  isProductSelectorOpen.value = false;
};

const formatNumber = (value) => {
  return parseFloat(value).toFixed(2);
};

const truncateText = (text, maxLength) => {
  if (!text) return '';
  if (text.length <= maxLength) return text;
  return text.substring(0, maxLength) + '...';
};

// Initialize totals
onMounted(() => {
  calculateTotalsWithoutEmit();
});
</script>
