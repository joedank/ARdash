<template>
  <div class="items-list">
    <h3 class="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">Generated Items</h3>

    <!-- Empty state -->
    <div v-if="!items.length" class="p-4 bg-gray-50 dark:bg-gray-700 rounded-md text-center">
      <p class="text-gray-600 dark:text-gray-400">No items generated yet.</p>
    </div>

    <!-- Items table -->
    <div v-else class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
        <thead class="bg-gray-50 dark:bg-gray-800">
          <tr>
            <th scope="col" class="px-3 py-2 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              Description
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
              Actions
            </th>
          </tr>
        </thead>
        <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
          <tr
            v-for="(item, index) in items"
            :key="index"
            class="hover:bg-gray-50 dark:hover:bg-gray-800"
            :class="{ 'bg-blue-50 dark:bg-blue-900/20': selectedIndices.includes(index) }"
            @mouseenter="handleMouseEnter(item.sourceId)"
            @mouseleave="handleMouseLeave()"
            @click="toggleItemSelection(index)"
          >
            <td class="px-3 py-2 whitespace-normal text-sm text-gray-900 dark:text-gray-200">
              <div class="flex items-start">
                <div class="flex-grow">
                  {{ item.description }}
                  <div v-if="item.sourceType" class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                    Source: {{ formatSourceType(item.sourceType) }}
                  </div>
                </div>
                <div v-if="hasCatalogMatch(item)" class="ml-2 flex items-center">
                  <div class="text-yellow-500 dark:text-yellow-400" title="Similar item exists in catalog">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                      <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                    </svg>
                  </div>
                  <span class="ml-1 text-xs text-yellow-600 dark:text-yellow-300">
                    {{ getCatalogMatchScore(item) }}% match
                  </span>
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
              <button
                @click="editItem(index)"
                class="text-indigo-600 dark:text-indigo-400 hover:text-indigo-900 dark:hover:text-indigo-300 mr-2"
              >
                Edit
              </button>
              <button
                @click="removeItem(index)"
                class="text-red-600 dark:text-red-400 hover:text-red-900 dark:hover:text-red-300"
              >
                Remove
              </button>
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

    <!-- Add Item Button -->
    <div class="mt-4 flex justify-end">
      <button
        @click="addItem"
        class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 dark:bg-indigo-700 dark:hover:bg-indigo-600"
      >
        Add Item
      </button>
    </div>

    <!-- Item Editor Modal -->
    <BaseModal
      v-if="showEditModal"
      :model-value="showEditModal"
      @update:model-value="showEditModal = false"
      title="Edit Item"
      size="md"
    >
      <div class="p-4">
        <div class="mb-4">
          <label for="edit-description" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            Description
          </label>
          <textarea
            id="edit-description"
            v-model="editingItem.description"
            rows="3"
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
            placeholder="Item description..."
          ></textarea>
        </div>

        <div class="grid grid-cols-2 gap-4 mb-4">
          <div>
            <label for="edit-quantity" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Quantity
            </label>
            <input
              id="edit-quantity"
              type="number"
              v-model.number="editingItem.quantity"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
              min="0"
              step="any"
            />
          </div>

          <div>
            <label for="edit-unit" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Unit
            </label>
            <select
              id="edit-unit"
              v-model="editingItem.unit"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
            >
              <option value="sq ft">Square Feet (sq ft)</option>
              <option value="ln ft">Linear Feet (ln ft)</option>
              <option value="each">Each</option>
              <option value="hour">Hour</option>
              <option value="day">Day</option>
            </select>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4 mb-4">
          <div>
            <label for="edit-unit-price" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Unit Price
            </label>
            <input
              id="edit-unit-price"
              type="number"
              v-model.number="editingItem.unit_price"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
              min="0"
              step="any"
              @input="calculateTotal"
            />
          </div>

          <div>
            <label for="edit-total" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Total
            </label>
            <input
              id="edit-total"
              type="number"
              v-model.number="editingItem.total"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
              min="0"
              step="any"
              disabled
            />
          </div>
        </div>

        <!-- Catalog Match Warning -->
        <div v-if="hasCatalogMatch(editingItem)" class="mb-4 p-3 bg-yellow-50 dark:bg-yellow-900/20 rounded-md border border-yellow-200 dark:border-yellow-800">
          <div class="flex justify-between items-start">
            <div>
              <p class="text-yellow-800 dark:text-yellow-300 text-sm font-medium">
                <strong>Similar item found in catalog ({{ getCatalogMatchScore(editingItem) }}% match)</strong>
              </p>
              <p class="text-yellow-700 dark:text-yellow-400 text-sm mt-1 font-medium">
                {{ getCatalogMatch(editingItem).name }}
              </p>
              <p v-if="getCatalogMatch(editingItem).description" class="text-yellow-600 dark:text-yellow-300 text-xs mt-1">
                {{ getCatalogMatch(editingItem).description }}
              </p>
              <div class="mt-2 flex items-center text-sm">
                <span class="text-yellow-700 dark:text-yellow-400 font-medium">Price:</span>
                <span class="ml-1 text-yellow-800 dark:text-yellow-300">{{ formatCurrency(getCatalogMatch(editingItem).price) }}</span>
                <span class="mx-2 text-yellow-500">|</span>
                <span class="text-yellow-700 dark:text-yellow-400 font-medium">Unit:</span>
                <span class="ml-1 text-yellow-800 dark:text-yellow-300">{{ getCatalogMatch(editingItem).unit }}</span>
              </div>
            </div>
            <button
              @click="useFromCatalog"
              class="px-2 py-1 bg-yellow-100 dark:bg-yellow-800 text-yellow-800 dark:text-yellow-200 text-xs font-medium rounded hover:bg-yellow-200 dark:hover:bg-yellow-700 transition-colors">
              Use Catalog Item
            </button>
          </div>
          <p class="text-yellow-700 dark:text-yellow-400 text-xs mt-3">
            Using catalog items ensures consistency across estimates.
          </p>
        </div>

        <div class="flex justify-end space-x-3 mt-4">
          <button
            @click="showEditModal = false"
            class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700"
          >
            Cancel
          </button>
          <button
            @click="saveItem"
            class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 dark:bg-indigo-700 dark:hover:bg-indigo-600"
          >
            Save
          </button>
        </div>
      </div>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import BaseModal from '../../../../components/base/BaseModal.vue';

const props = defineProps({
  items: {
    type: Array,
    default: () => []
  },
  catalogMatches: {
    type: Object,
    default: () => ({})
  }
});

const emit = defineEmits(['update:items', 'highlightSource', 'update:selectedIndices']);

// State for item selection
const selectedIndices = ref([]);

// State
const showEditModal = ref(false);
const editingIndex = ref(-1);
const editingItem = ref({
  description: '',
  quantity: 1,
  unit: 'sq ft',
  unit_price: 0,
  total: 0,
  sourceType: null,
  sourceId: null
});

// Computed
const subtotal = computed(() => {
  return props.items.reduce((sum, item) => {
    return sum + (parseFloat(item.total) || 0);
  }, 0);
});

// Methods
const formatCurrency = (value) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2
  }).format(value || 0);
};

const formatSourceType = (sourceType) => {
  switch (sourceType) {
    case 'assessment':
      return 'Assessment Data';
    case 'llm':
      return 'AI Generated';
    case 'manual':
      return 'Manually Added';
    default:
      return sourceType;
  }
};

const hasCatalogMatch = (item) => {
  return props.catalogMatches && props.catalogMatches[item.description];
};

const getCatalogMatch = (item) => {
  return props.catalogMatches[item.description] || {};
};

const getCatalogMatchScore = (item) => {
  const match = getCatalogMatch(item);
  // Get similarity score and convert to percentage
  return match.similarity ? Math.round(match.similarity * 100) : 0;
};

const addItem = () => {
  editingIndex.value = -1;
  editingItem.value = {
    description: '',
    quantity: 1,
    unit: 'sq ft',
    unit_price: 0,
    total: 0,
    sourceType: 'manual',
    sourceId: null
  };
  showEditModal.value = true;
};

const editItem = (index) => {
  editingIndex.value = index;
  editingItem.value = { ...props.items[index] };
  showEditModal.value = true;
};

const removeItem = (index) => {
  const updatedItems = [...props.items];
  updatedItems.splice(index, 1);
  emit('update:items', updatedItems);
};

const saveItem = () => {
  // Calculate total
  calculateTotal();

  const updatedItems = [...props.items];

  if (editingIndex.value === -1) {
    // Add new item
    updatedItems.push({ ...editingItem.value });
  } else {
    // Update existing item
    updatedItems[editingIndex.value] = { ...editingItem.value };
  }

  emit('update:items', updatedItems);
  showEditModal.value = false;
};

const calculateTotal = () => {
  const quantity = parseFloat(editingItem.value.quantity) || 0;
  const unitPrice = parseFloat(editingItem.value.unit_price) || 0;
  editingItem.value.total = quantity * unitPrice;
};

const useFromCatalog = () => {
  const catalogItem = getCatalogMatch(editingItem.value);

  if (!catalogItem || !catalogItem.id) {
    return; // No valid catalog item found
  }

  // Keep existing quantity but update other fields from catalog
  const quantity = parseFloat(editingItem.value.quantity) || 1;

  // Update the editing item with catalog values
  editingItem.value = {
    ...editingItem.value,
    description: catalogItem.name,
    unit: catalogItem.unit || 'each',
    unit_price: parseFloat(catalogItem.price) || 0,
    // Add reference to catalog item
    product_id: catalogItem.id,
    catalog_reference: true,
    original_description: editingItem.value.description // Keep track of original description
  };

  // Recalculate total
  calculateTotal();
};

const handleMouseEnter = (sourceId) => {
  if (sourceId) {
    emit('highlightSource', sourceId);
  }
};

const handleMouseLeave = () => {
  emit('highlightSource', null);
};

// Toggle selection of an item for batch operations
const toggleItemSelection = (index) => {
  const selectedIndex = selectedIndices.value.indexOf(index);

  if (selectedIndex === -1) {
    // Add to selection
    selectedIndices.value.push(index);
  } else {
    // Remove from selection
    selectedIndices.value.splice(selectedIndex, 1);
  }

  // Emit updated selection to parent
  emit('update:selectedIndices', selectedIndices.value);
};
</script>

<style scoped>
/* Component-specific styles */
</style>
