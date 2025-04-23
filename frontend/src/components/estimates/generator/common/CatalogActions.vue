<template>
  <div class="catalog-actions">
    <h3 class="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">Catalog Actions</h3>

    <!-- No items selected state -->
    <div v-if="!selectedItems.length" class="p-4 bg-gray-50 dark:bg-gray-700 rounded-md text-center">
      <p class="text-gray-600 dark:text-gray-400">Select items to perform catalog actions.</p>
    </div>

    <!-- Selected items -->
    <div v-else>
      <div class="mb-4 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-md border border-blue-200 dark:border-blue-800">
        <p class="text-blue-800 dark:text-blue-300 text-sm">
          <strong>{{ selectedItems.length }}</strong> item(s) selected
        </p>
      </div>

      <!-- Catalog match warnings -->
      <div v-if="hasCatalogMatches" class="mb-4 p-3 bg-yellow-50 dark:bg-yellow-900/20 rounded-md border border-yellow-200 dark:border-yellow-800">
        <p class="text-yellow-800 dark:text-yellow-300 text-sm font-medium mb-1">
          Similar items found in catalog
        </p>
        <ul class="text-yellow-700 dark:text-yellow-400 text-xs space-y-1">
          <li v-for="(match, index) in catalogMatches" :key="index" class="flex justify-between">
            <span>{{ match.name }}</span>
            <span>{{ formatSimilarity(match.similarity) }}</span>
          </li>
        </ul>
      </div>

      <!-- Action buttons -->
      <div class="space-y-2">
        <button
          @click="addToCatalog"
          class="w-full px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 dark:bg-green-700 dark:hover:bg-green-600"
          :disabled="loading"
        >
          Add to Catalog
        </button>

        <button
          v-if="hasCatalogMatches"
          @click="replaceCatalogItems"
          class="w-full px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 dark:bg-blue-700 dark:hover:bg-blue-600"
          :disabled="loading"
        >
          Replace with Catalog Items
        </button>

        <button
          v-if="selectedItems.length > 1"
          @click="standardizePricing"
          class="w-full px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 dark:bg-purple-700 dark:hover:bg-purple-600"
          :disabled="loading"
        >
          Standardize Pricing
        </button>

        <button
          @click="clearSelection"
          class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700"
          :disabled="loading"
        >
          Clear Selection
        </button>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="absolute inset-0 bg-white bg-opacity-75 dark:bg-gray-900 dark:bg-opacity-75 flex items-center justify-center">
      <svg class="animate-spin h-8 w-8 text-indigo-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
    </div>

    <!-- Add to Catalog Modal -->
    <BaseModal
      v-if="showAddModal"
      :model-value="showAddModal"
      @update:model-value="showAddModal = false"
      title="Add to Catalog"
      size="md"
    >
      <div class="p-4">
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          Are you sure you want to add {{ selectedItems.length }} item(s) to the catalog?
        </p>

        <div class="mb-4 max-h-60 overflow-y-auto">
          <div v-for="(item, index) in selectedItems" :key="index" class="p-2 border-b border-gray-200 dark:border-gray-700 last:border-b-0">
            <p class="font-medium text-gray-800 dark:text-gray-200">{{ item.description }}</p>
            <p class="text-sm text-gray-600 dark:text-gray-400">
              {{ item.quantity }} {{ item.unit }} at {{ formatCurrency(item.unit_price) }}
            </p>
          </div>
        </div>

        <div class="flex justify-end space-x-3">
          <button
            @click="showAddModal = false"
            class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700"
          >
            Cancel
          </button>
          <button
            @click="confirmAddToCatalog"
            class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 dark:bg-green-700 dark:hover:bg-green-600"
          >
            Add to Catalog
          </button>
        </div>
      </div>
    </BaseModal>

    <!-- Replace with Catalog Modal -->
    <BaseModal
      v-if="showReplaceModal"
      :model-value="showReplaceModal"
      @update:model-value="showReplaceModal = false"
      title="Replace with Catalog Items"
      size="md"
    >
      <div class="p-4">
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          Replace selected items with similar catalog items?
        </p>

        <div class="mb-4 max-h-60 overflow-y-auto">
          <div v-for="(match, index) in catalogMatches" :key="index" class="p-2 border-b border-gray-200 dark:border-gray-700 last:border-b-0">
            <div class="flex justify-between">
              <div>
                <p class="font-medium text-gray-800 dark:text-gray-200">{{ match.name }}</p>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  {{ formatCurrency(match.price) }} per {{ match.unit }}
                </p>
              </div>
              <div class="text-right">
                <p class="text-xs text-blue-600 dark:text-blue-400">
                  {{ formatSimilarity(match.similarity) }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <div class="flex justify-end space-x-3">
          <button
            @click="showReplaceModal = false"
            class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700"
          >
            Cancel
          </button>
          <button
            @click="confirmReplaceCatalogItems"
            class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 dark:bg-blue-700 dark:hover:bg-blue-600"
          >
            Replace Items
          </button>
        </div>
      </div>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useToast } from 'vue-toastification';
import BaseModal from '../../../../components/base/BaseModal.vue';
import productsService from '../../../../services/products.service.js';
import catalogMatcherService from '../../../../services/catalog-matcher.service.js';

const props = defineProps({
  items: {
    type: Array,
    default: () => []
  },
  selectedItemIndices: {
    type: Array,
    default: () => []
  }
});

const emit = defineEmits(['update:selectedItemIndices', 'update:items']);

const toast = useToast();

// State
const loading = ref(false);
const showAddModal = ref(false);
const showReplaceModal = ref(false);
const catalogMatches = ref([]);

// Computed
const selectedItems = computed(() => {
  return props.selectedItemIndices.map(index => props.items[index]).filter(Boolean);
});

const hasCatalogMatches = computed(() => {
  return catalogMatches.value.length > 0;
});

// Methods
const formatCurrency = (value) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2
  }).format(value || 0);
};

const formatSimilarity = (similarity) => {
  if (similarity >= 0.9) {
    return 'Very similar';
  } else if (similarity >= 0.7) {
    return 'Similar';
  } else {
    return 'Somewhat similar';
  }
};

const clearSelection = () => {
  emit('update:selectedItemIndices', []);
};

const addToCatalog = async () => {
  if (!selectedItems.value.length) {
    toast.error('No items selected');
    return;
  }

  // Check for catalog matches first
  loading.value = true;

  try {
    const descriptions = selectedItems.value.map(item => item.description);
    const response = await catalogMatcherService.checkSimilarity(descriptions);

    if (response.success && response.data) {
      catalogMatches.value = response.data;

      // If there are matches, show warning
      if (catalogMatches.value.length > 0) {
        const highSimilarityMatches = catalogMatches.value.filter(match => match.similarity >= 0.9);

        if (highSimilarityMatches.length > 0) {
          toast.warning(`${highSimilarityMatches.length} very similar items found in catalog`);
        }
      }
    }

    // Show add modal
    showAddModal.value = true;
  } catch (error) {
    console.error('Error checking catalog similarity:', error);
    toast.error('Failed to check catalog similarity');
  } finally {
    loading.value = false;
  }
};

const confirmAddToCatalog = async () => {
  loading.value = true;
  showAddModal.value = false;

  try {
    // Convert items to product format
    const products = selectedItems.value.map(item => ({
      name: item.description,
      description: item.description,
      price: parseFloat(item.unit_price) || 0,
      unit: item.unit,
      type: 'service',
      tax_rate: 0
    }));

    const response = await productsService.createBulkProducts(products);

    if (response.success) {
      toast.success(`Added ${products.length} item(s) to catalog`);
      clearSelection();
    } else {
      toast.error(response.message || 'Failed to add items to catalog');
    }
  } catch (error) {
    console.error('Error adding to catalog:', error);
    toast.error('Failed to add items to catalog');
  } finally {
    loading.value = false;
  }
};

const replaceCatalogItems = async () => {
  if (!selectedItems.value.length) {
    toast.error('No items selected');
    return;
  }

  // Check for catalog matches
  loading.value = true;

  try {
    const descriptions = selectedItems.value.map(item => item.description);
    const response = await catalogMatcherService.checkSimilarity(descriptions);

    if (response.success && response.data) {
      catalogMatches.value = response.data;

      // If there are matches, show replace modal
      if (catalogMatches.value.length > 0) {
        showReplaceModal.value = true;
      } else {
        toast.info('No similar catalog items found');
      }
    }
  } catch (error) {
    console.error('Error checking catalog similarity:', error);
    toast.error('Failed to check catalog similarity');
  } finally {
    loading.value = false;
  }
};

const confirmReplaceCatalogItems = async () => {
  loading.value = true;
  showReplaceModal.value = false;

  try {
    // Get catalog items
    const catalogItems = await Promise.all(
      catalogMatches.value.map(async match => {
        const response = await productsService.getProductById(match.id);
        return response.success ? response.data : null;
      })
    );

    // Filter out null values
    const validCatalogItems = catalogItems.filter(Boolean);

    if (validCatalogItems.length === 0) {
      toast.error('Failed to retrieve catalog items');
      return;
    }

    // Replace selected items with catalog items
    const updatedItems = [...props.items];

    props.selectedItemIndices.forEach((index, i) => {
      if (i < validCatalogItems.length) {
        const catalogItem = validCatalogItems[i];
        const currentItem = props.items[index];

        updatedItems[index] = {
          description: catalogItem.name,
          product_name: catalogItem.name,
          quantity: currentItem.quantity,
          unit: catalogItem.unit,
          unit_price: catalogItem.price,
          total: currentItem.quantity * catalogItem.price,
          sourceType: 'catalog',
          sourceId: catalogItem.id,
          product_id: catalogItem.id
        };
      }
    });

    emit('update:items', updatedItems);
    toast.success(`Replaced ${validCatalogItems.length} item(s) with catalog items`);
    clearSelection();
  } catch (error) {
    console.error('Error replacing with catalog items:', error);
    toast.error('Failed to replace with catalog items');
  } finally {
    loading.value = false;
  }
};

/**
 * Standardize pricing across selected items
 * - Identifies items with the same unit and standardizes their unit price
 * - Uses either the most common price or the average price
 */
const standardizePricing = () => {
  if (selectedItems.value.length < 2) {
    toast.info('Select at least two items to standardize pricing');
    return;
  }

  // Group items by unit
  const itemsByUnit = {};
  selectedItems.value.forEach(item => {
    const unit = item.unit || 'each';
    if (!itemsByUnit[unit]) {
      itemsByUnit[unit] = [];
    }
    itemsByUnit[unit].push(item);
  });

  // Process each unit group
  const updatedItems = [...props.items];
  let changesMade = 0;

  Object.entries(itemsByUnit).forEach(([unit, unitItems]) => {
    // Skip if only one item with this unit
    if (unitItems.length < 2) return;

    // Calculate the most common price
    const priceFrequency = {};
    let mostCommonPrice = null;
    let highestFrequency = 0;

    unitItems.forEach(item => {
      const price = parseFloat(item.unit_price) || 0;
      if (!priceFrequency[price]) {
        priceFrequency[price] = 0;
      }
      priceFrequency[price]++;

      if (priceFrequency[price] > highestFrequency) {
        highestFrequency = priceFrequency[price];
        mostCommonPrice = price;
      }
    });

    // If no clear most common price, use average
    if (highestFrequency < 2) {
      const sum = unitItems.reduce((total, item) => total + (parseFloat(item.unit_price) || 0), 0);
      mostCommonPrice = sum / unitItems.length;
    }

    // Update all items with this unit
    for (const unitItem of unitItems) {
      // Find the index of this item in the original items array
      const itemIndex = props.selectedItemIndices.find(index => props.items[index] === unitItem);
      if (itemIndex !== undefined) {
        // Only update if the price is different
        if (parseFloat(updatedItems[itemIndex].unit_price) !== mostCommonPrice) {
          updatedItems[itemIndex] = {
            ...updatedItems[itemIndex],
            unit_price: mostCommonPrice,
            total: (parseFloat(updatedItems[itemIndex].quantity) || 0) * mostCommonPrice
          };
          changesMade++;
        }
      }
    }
  });

  // Update items if changes were made
  if (changesMade > 0) {
    emit('update:items', updatedItems);
    toast.success(`Standardized pricing for ${changesMade} items`);
  } else {
    toast.info('No pricing changes needed, all selected items already have standardized pricing');
  }
};
</script>

<style scoped>
.catalog-actions {
  position: relative;
}
</style>
