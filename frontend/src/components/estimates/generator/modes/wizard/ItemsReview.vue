<template>
  <div class="space-y-4">
    <h3 class="text-lg font-semibold text-gray-900 dark:text-gray-100">Generated Estimate Items</h3>

    <div class="text-sm text-gray-700 dark:text-gray-300">
      <p>Review the generated items below. Items are automatically matched with your product catalog when possible.</p>
    </div>

    <!-- Summary Stats -->
    <div class="flex gap-6 bg-gray-50 dark:bg-gray-800/50 rounded-md p-4 mb-4">
      <div class="flex flex-col gap-1">
        <span class="text-xs text-gray-500 dark:text-gray-400">Total Items:</span>
        <span class="text-xl font-semibold text-gray-900 dark:text-gray-100">{{ items.length }}</span>
      </div>
      <div class="flex flex-col gap-1">
        <span class="text-xs text-gray-500 dark:text-gray-400">Matched:</span>
        <span class="text-xl font-semibold text-green-600 dark:text-green-400">{{ matchedCount }}</span>
      </div>
      <div class="flex flex-col gap-1">
        <span class="text-xs text-gray-500 dark:text-gray-400">Needs Review:</span>
        <span class="text-xl font-semibold text-yellow-600 dark:text-yellow-400">{{ reviewCount }}</span>
      </div>
      <div class="flex flex-col gap-1">
        <span class="text-xs text-gray-500 dark:text-gray-400">New:</span>
        <span class="text-xl font-semibold text-blue-600 dark:text-blue-400">{{ createdCount }}</span>
      </div>
    </div>

    <!-- Items Table -->
    <div class="overflow-x-auto rounded-md border border-gray-200 dark:border-gray-700">
      <table class="w-full border-collapse text-sm">
        <thead>
          <tr class="bg-gray-50 dark:bg-gray-800">
            <th class="text-left py-3 px-4 font-medium text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700">Item</th>
            <th class="text-left py-3 px-4 font-medium text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700">Qty</th>
            <th class="text-left py-3 px-4 font-medium text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700">Type</th>
            <th class="text-left py-3 px-4 font-medium text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700">Unit Price</th>
            <th class="text-left py-3 px-4 font-medium text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700">Status</th>
            <th class="text-left py-3 px-4 font-medium text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr 
            v-for="(item, index) in items" 
            :key="index"
            :class="{
              'bg-green-50 dark:bg-green-900/10': item.catalogStatus === 'match',
              'bg-yellow-50 dark:bg-yellow-900/10': item.catalogStatus === 'review'
            }"
          >
            <td class="py-3 px-4 border-b border-gray-200 dark:border-gray-700">{{ item.name }}</td>
            <td class="py-3 px-4 border-b border-gray-200 dark:border-gray-700">{{ item.quantity }}</td>
            <td class="py-3 px-4 border-b border-gray-200 dark:border-gray-700">{{ formatMeasurementType(item.measurementType) }}</td>
            <td class="py-3 px-4 border-b border-gray-200 dark:border-gray-700">${{ item.unitPrice.toFixed(2) }}</td>
            <td class="py-3 px-4 border-b border-gray-200 dark:border-gray-700">
              <span 
                class="inline-flex px-2 py-1 rounded-full text-xs font-medium"
                :class="{
                  'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300': item.catalogStatus === 'match',
                  'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300': item.catalogStatus === 'review',
                  'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300': item.catalogStatus === 'created'
                }"
              >
                <span v-if="item.catalogStatus === 'match'">
                  Matched ({{ (item.score * 100).toFixed(0) }}%)
                </span>
                <span v-else-if="item.catalogStatus === 'review'">
                  Needs Review
                </span>
                <span v-else-if="item.catalogStatus === 'created'">
                  New Item
                </span>
                <span v-else>
                  {{ item.catalogStatus }}
                </span>
              </span>
            </td>
            <td class="py-3 px-4 border-b border-gray-200 dark:border-gray-700">
              <div class="flex gap-2">
                <BaseButton
                  v-if="item.catalogStatus === 'review'"
                  variant="secondary"
                  size="sm"
                  @click="toggleReviewPanel(index)"
                >
                  Review Matches
                </BaseButton>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Match Review Panel -->
    <div v-if="activeReviewPanel !== null" class="bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-700 shadow-md mb-4">
      <div class="flex items-center justify-between p-4 border-b border-gray-200 dark:border-gray-700">
        <h4 class="text-base font-medium text-gray-900 dark:text-gray-100">Select Best Match for: {{ items[activeReviewPanel].name }}</h4>
        <button 
          class="text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200 text-xl leading-none"
          @click="closeReviewPanel"
        >
          &times;
        </button>
      </div>

      <div class="max-h-80 overflow-y-auto p-4">
        <div
          v-for="match in items[activeReviewPanel].matches"
          :key="match.id"
          class="flex justify-between items-center p-3 bg-gray-50 dark:bg-gray-800/50 rounded-md mb-2 last:mb-0"
        >
          <div class="flex flex-col gap-1">
            <div class="font-medium text-gray-900 dark:text-gray-100">{{ match.name }}</div>
            <div class="text-xs text-gray-500 dark:text-gray-400">
              {{ (match.score * 100).toFixed(0) }}% similarity
            </div>
          </div>
          <BaseButton
            variant="primary"
            size="sm"
            @click="selectMatch(activeReviewPanel, match.id)"
          >
            Use This
          </BaseButton>
        </div>
      </div>

      <div class="flex justify-end gap-2 p-4 bg-gray-50 dark:bg-gray-800/50 border-t border-gray-200 dark:border-gray-700">
        <BaseButton
          variant="secondary"
          size="sm"
          @click="closeReviewPanel"
        >
          Cancel
        </BaseButton>
        <BaseButton
          variant="outline"
          size="sm"
          @click="keepAsNew(activeReviewPanel)"
        >
          Keep as New Item
        </BaseButton>
      </div>
    </div>

    <!-- Form Actions -->
    <div class="flex justify-between items-center mt-6 pt-4 border-t border-gray-200 dark:border-gray-700">
      <div class="flex flex-col gap-1">
        <span class="text-xs text-gray-500 dark:text-gray-400">Total Estimate:</span>
        <span class="text-2xl font-semibold text-gray-900 dark:text-gray-100">${{ totalEstimate.toFixed(2) }}</span>
      </div>
      <BaseButton
        variant="primary"
        size="md"
        :loading="loading"
        :disabled="reviewCount > 0"
        @click="createEstimate"
      >
        {{ loading ? 'Processing...' : 'Create Estimate' }}
      </BaseButton>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import BaseButton from '@/components/base/BaseButton.vue';

const props = defineProps({
  items: {
    type: Array,
    default: () => []
  },
  loading: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['accept-match', 'create-estimate']);

const activeReviewPanel = ref(null);

// Calculate stats
const matchedCount = computed(() => {
  return props.items.filter(item => item.catalogStatus === 'match').length;
});

const reviewCount = computed(() => {
  return props.items.filter(item => item.catalogStatus === 'review').length;
});

const createdCount = computed(() => {
  return props.items.filter(item => item.catalogStatus === 'created').length;
});

// Calculate total estimate
const totalEstimate = computed(() => {
  return props.items.reduce((sum, item) => {
    return sum + (item.quantity * item.unitPrice);
  }, 0);
});

// Format measurement type for display
const formatMeasurementType = (type) => {
  switch (type) {
    case 'AREA': return 'Area';
    case 'LINEAR': return 'Linear';
    case 'QUANTITY': return 'Quantity';
    default: return type;
  }
};

// Review panel functions
const toggleReviewPanel = (index) => {
  if (activeReviewPanel.value === index) {
    activeReviewPanel.value = null;
  } else {
    activeReviewPanel.value = index;
  }
};

const closeReviewPanel = () => {
  activeReviewPanel.value = null;
};

// Match selection
const selectMatch = (index, productId) => {
  emit('accept-match', { index, productId });
  closeReviewPanel();
};

// Keep as new item
const keepAsNew = (index) => {
  // Update the item status to created
  const item = props.items[index];
  emit('accept-match', {
    index,
    productId: item.productId || null,
    keepAsNew: true
  });
  closeReviewPanel();
};

// Create final estimate
const createEstimate = () => {
  emit('create-estimate', props.items);
};
</script>

<style scoped>
/* All styling now uses Tailwind classes */
</style>
