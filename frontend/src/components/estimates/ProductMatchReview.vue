<template>
  <div class="product-match-review p-4 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg">
    <h3 class="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">Review Generated Items</h3>

    <!-- Loading state -->
    <div v-if="loading" class="flex items-center justify-center h-64">
      <svg class="animate-spin h-8 w-8 text-blue-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      <p class="ml-3 text-gray-600 dark:text-gray-400">{{ loadingMessage }}</p>
    </div>

    <!-- Error state -->
    <div v-else-if="error" class="p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-900 rounded-md">
      <p class="text-red-700 dark:text-red-300">{{ error }}</p>
      <button
        @click="retryMatching"
        class="mt-2 px-3 py-1 bg-red-600 text-white rounded-md text-sm hover:bg-red-700"
      >
        Retry
      </button>
    </div>

    <!-- Main content -->
    <div v-else>
      <div class="mb-4 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-md border border-blue-200 dark:border-blue-800">
        <p class="text-blue-800 dark:text-blue-300 text-sm">
          <strong>{{ lineItems.length }}</strong> items generated. Please review and make any necessary adjustments.
        </p>
      </div>

      <!-- Items table -->
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-800">
            <tr>
              <th scope="col" class="px-3 py-2 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                <div class="flex items-center">
                  <input
                    type="checkbox"
                    :checked="allSelected"
                    @change="toggleSelectAll"
                    class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                  />
                  <span class="ml-2">Description</span>
                </div>
              </th>
              <th scope="col" class="px-3 py-2 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Quantity
              </th>
              <th scope="col" class="px-3 py-2 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Unit
              </th>
              <th scope="col" class="px-3 py-2 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Unit Price
              </th>
              <th scope="col" class="px-3 py-2 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Total
              </th>
              <th scope="col" class="px-3 py-2 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Match
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
            <tr
              v-for="(item, index) in lineItems"
              :key="index"
              class="hover:bg-gray-50 dark:hover:bg-gray-800"
            >
              <td class="px-3 py-2 whitespace-normal text-sm text-gray-900 dark:text-gray-200">
                <div class="flex items-start">
                  <input
                    type="checkbox"
                    v-model="selectedItems"
                    :value="index"
                    class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded mt-1"
                  />
                  <div class="ml-2">
                    {{ item.description }}
                    <div v-if="item.sourceType" class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                      Source: {{ formatSourceType(item.sourceType) }}
                    </div>
                  </div>
                </div>
              </td>
              <td class="px-3 py-2 whitespace-nowrap text-sm text-right text-gray-900 dark:text-gray-200">
                {{ item.quantity }}
              </td>
              <td class="px-3 py-2 whitespace-nowrap text-sm text-gray-900 dark:text-gray-200">
                {{ item.unit }}
              </td>
              <td class="px-3 py-2 whitespace-nowrap text-sm text-right text-gray-900 dark:text-gray-200">
                {{ formatCurrency(item.unit_price) }}
              </td>
              <td class="px-3 py-2 whitespace-nowrap text-sm text-right font-medium text-gray-900 dark:text-gray-200">
                {{ formatCurrency(item.total) }}
              </td>
              <td class="px-3 py-2 whitespace-nowrap text-sm text-right">
                <span v-if="catalogMatches[index] && catalogMatches[index].length > 0" class="text-yellow-500 dark:text-yellow-400">
                  {{ catalogMatches[index].length }} match(es)
                </span>
                <span v-else class="text-gray-400 dark:text-gray-500">No matches</span>
              </td>
            </tr>
          </tbody>
          <tfoot class="bg-gray-50 dark:bg-gray-800">
            <tr>
              <td colspan="4" class="px-3 py-2 text-right text-sm font-medium text-gray-900 dark:text-gray-200">
                Subtotal:
              </td>
              <td class="px-3 py-2 text-right text-sm font-medium text-gray-900 dark:text-gray-200">
                {{ formatCurrency(subtotal) }}
              </td>
              <td></td>
            </tr>
          </tfoot>
        </table>
      </div>

      <!-- Catalog match section -->
      <div v-if="hasSelectedItems" class="mt-6">
        <h4 class="text-base font-medium mb-3 text-gray-800 dark:text-gray-200">Catalog Matches for Selected Items</h4>

        <div v-if="selectedItemsWithMatches.length === 0" class="p-3 bg-yellow-50 dark:bg-yellow-900/20 rounded-md border border-yellow-200 dark:border-yellow-800">
          <p class="text-yellow-800 dark:text-yellow-300 text-sm">
            No catalog matches found for selected items.
          </p>
        </div>

        <div v-else class="space-y-4">
          <div v-for="(item, itemIndex) in selectedItemsWithMatches" :key="itemIndex" class="p-3 bg-gray-50 dark:bg-gray-700 rounded-md">
            <div class="flex justify-between items-start mb-2">
              <div>
                <p class="font-medium text-gray-800 dark:text-gray-200">{{ item.description }}</p>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  {{ item.quantity }} {{ item.unit }} at {{ formatCurrency(item.unit_price) }}
                </p>
              </div>
              <div>
                <button
                  @click="useOriginal(item.index)"
                  class="text-xs text-gray-600 dark:text-gray-400 hover:text-gray-800 dark:hover:text-gray-200"
                >
                  Use as is
                </button>
              </div>
            </div>

            <div class="mt-2 space-y-2">
              <div v-for="(match, matchIndex) in catalogMatches[item.index]" :key="matchIndex" class="p-2 border border-gray-200 dark:border-gray-600 rounded-md flex justify-between items-center">
                <div>
                  <p class="font-medium text-gray-800 dark:text-gray-200">{{ match.name }}</p>
                  <p class="text-xs text-gray-600 dark:text-gray-400">
                    {{ formatCurrency(match.price) }} per {{ match.unit }}
                  </p>
                </div>
                <div class="flex items-center space-x-2">
                  <span class="text-xs px-2 py-1 rounded-full" :class="getSimilarityClass(match.similarity)">
                    {{ formatSimilarity(match.similarity) }}
                  </span>
                  <button
                    @click="useMatch(item.index, match)"
                    class="px-2 py-1 bg-blue-600 text-white rounded-md text-xs hover:bg-blue-700"
                  >
                    Use
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Action buttons -->
      <div class="mt-6 flex justify-between">
        <button
          @click="$emit('back')"
          class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700"
        >
          Back
        </button>
        <button
          @click="finishReview"
          class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 dark:bg-indigo-700 dark:hover:bg-indigo-600"
        >
          Continue to Estimate
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useToast } from 'vue-toastification';
import productsService from '@/services/products.service.js';
import { formatCurrency } from '@/utils/estimate-formatter.js';

const props = defineProps({
  lineItems: {
    type: Array,
    required: true
  }
});

const emit = defineEmits(['back', 'finished']);

const toast = useToast();

// State
const loading = ref(true);
const loadingMessage = ref('Checking catalog matches...');
const error = ref(null);
const selectedItems = ref([]);
const catalogMatches = ref({});
const processedItems = ref([]);

// Computed
const allSelected = computed(() => {
  return selectedItems.value.length === props.lineItems.length;
});

const subtotal = computed(() => {
  return props.lineItems.reduce((sum, item) => {
    return sum + (parseFloat(item.total) || 0);
  }, 0);
});

const hasSelectedItems = computed(() => {
  return selectedItems.value.length > 0;
});

const selectedItemsWithMatches = computed(() => {
  return selectedItems.value
    .map(index => {
      const item = props.lineItems[index];
      return {
        ...item,
        index
      };
    })
    .filter(item => catalogMatches.value[item.index] && catalogMatches.value[item.index].length > 0);
});

// Methods
const formatSourceType = (sourceType) => {
  switch (sourceType) {
    case 'assessment':
      return 'Assessment Data';
    case 'llm':
      return 'AI Generated';
    case 'manual':
      return 'Manually Added';
    case 'catalog':
      return 'Catalog Item';
    default:
      return sourceType;
  }
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

const getSimilarityClass = (similarity) => {
  if (similarity >= 0.9) {
    return 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300';
  } else if (similarity >= 0.7) {
    return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300';
  } else {
    return 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
  }
};

const toggleSelectAll = () => {
  if (allSelected.value) {
    selectedItems.value = [];
  } else {
    selectedItems.value = props.lineItems.map((_, index) => index);
  }
};

const checkCatalogMatches = async () => {
  loading.value = true;
  loadingMessage.value = 'Checking catalog matches...';
  error.value = null;

  try {
    // Get descriptions from all line items
    const descriptions = props.lineItems.map(item => item.description);

    // Check for catalog matches in batches to avoid overwhelming the API
    const batchSize = 10;
    const batches = [];

    for (let i = 0; i < descriptions.length; i += batchSize) {
      batches.push(descriptions.slice(i, i + batchSize));
    }

    // Process each batch
    for (let i = 0; i < batches.length; i++) {
      const batchDescriptions = batches[i];
      const startIndex = i * batchSize;

      // Get catalog matches for this batch
      const response = await productsService.findSimilarProducts(batchDescriptions);

      if (response.success && response.data) {
        // Map the results to the correct indices
        response.data.forEach((matches, batchIndex) => {
          const itemIndex = startIndex + batchIndex;
          catalogMatches.value[itemIndex] = matches;
        });
      }
    }

    // Pre-select items with high-similarity matches
    const itemsWithHighSimilarity = Object.entries(catalogMatches.value)
      .filter(([_, matches]) => matches.some(match => match.similarity >= 0.9))
      .map(([index]) => parseInt(index));

    if (itemsWithHighSimilarity.length > 0) {
      selectedItems.value = itemsWithHighSimilarity;
      toast.info(`${itemsWithHighSimilarity.length} items have high-similarity catalog matches`);
    }
  } catch (err) {
    console.error('Error checking catalog matches:', err);
    error.value = 'Failed to check catalog matches. Please try again.';
  } finally {
    loading.value = false;
  }
};

const retryMatching = () => {
  checkCatalogMatches();
};

const useOriginal = (index) => {
  // Mark this item as processed with the original values
  processedItems.value[index] = {
    ...props.lineItems[index],
    processed: true,
    useOriginal: true
  };

  toast.success('Using original item');
};

const useMatch = (index, match) => {
  // Create a new item based on the catalog match
  const originalItem = props.lineItems[index];

  processedItems.value[index] = {
    description: match.name,
    product_name: match.name,
    quantity: originalItem.quantity,
    unit: match.unit,
    unit_price: match.price,
    total: originalItem.quantity * match.price,
    sourceType: 'catalog',
    sourceId: match.id,
    product_id: match.id,
    processed: true,
    useOriginal: false
  };

  toast.success('Using catalog item');
};

const finishReview = () => {
  // Prepare final line items
  const finalLineItems = props.lineItems.map((item, index) => {
    // If this item has been processed, use the processed version
    if (processedItems.value[index]) {
      return processedItems.value[index];
    }

    // Otherwise use the original
    return item;
  });

  emit('finished', { lineItems: finalLineItems });
};

// Initialize on mount
onMounted(() => {
  checkCatalogMatches();
});
</script>

<style scoped>
/* Add any component-specific styles here */
</style>
