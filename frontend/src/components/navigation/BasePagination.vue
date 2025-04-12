<template>
  <nav aria-label="Pagination" class="flex items-center justify-between text-sm">
    <!-- Optional: Display total items -->
    <div v-if="totalItems > 0" class="text-gray-600 dark:text-gray-400">
      Showing {{ (currentPage - 1) * itemsPerPage + 1 }} - {{ Math.min(currentPage * itemsPerPage, totalItems) }} of {{ totalItems }} results
    </div>
    <div v-else class="text-gray-600 dark:text-gray-400">
      No results to display
    </div> <!-- Improved placeholder for alignment if totalItems is not shown -->

    <ul class="inline-flex items-center -space-x-px">
      <!-- First Page Button -->
      <li>
        <button
          @click="goToPage(1)"
          :disabled="!canGoPrevious"
          :class="[
            'px-3 h-8 leading-tight rounded-l-lg border border-gray-300 dark:border-gray-700',
            'text-gray-500 bg-white hover:bg-gray-100 hover:text-gray-700',
            'dark:bg-gray-800 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white',
            { 'opacity-50 cursor-not-allowed': !canGoPrevious }
          ]"
          aria-label="Go to first page"
        >
          &laquo;
        </button>
      </li>
      <!-- Previous Page Button -->
      <li>
        <button
          @click="goToPrevious"
          :disabled="!canGoPrevious"
          :class="[
            'px-3 h-8 leading-tight border border-gray-300 dark:border-gray-700',
            'text-gray-500 bg-white hover:bg-gray-100 hover:text-gray-700',
            'dark:bg-gray-800 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white',
            { 'opacity-50 cursor-not-allowed': !canGoPrevious }
          ]"
          aria-label="Go to previous page"
        >
          &lsaquo;
        </button>
      </li>

      <!-- Page Number Buttons -->
      <li v-for="page in displayedPages" :key="page.number || `ellipsis-${page.id}`">
        <span
          v-if="page.isEllipsis"
          class="px-3 h-8 leading-tight text-gray-500 bg-white border border-gray-300 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400"
        >
          ...
        </span>
        <button
          v-else
          @click="goToPage(page.number)"
          :class="[
            'px-3 h-8 leading-tight border border-gray-300 dark:border-gray-700',
            page.isCurrent
              ? 'text-blue-600 bg-blue-50 border-blue-300 hover:bg-blue-100 hover:text-blue-700 dark:bg-gray-700 dark:text-white dark:border-gray-700'
              : 'text-gray-500 bg-white hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white'
          ]"
          :aria-current="page.isCurrent ? 'page' : undefined"
          :aria-label="`Go to page ${page.number}`"
        >
          {{ page.number }}
        </button>
      </li>

      <!-- Next Page Button -->
      <li>
        <button
          @click="goToNext"
          :disabled="!canGoNext"
          :class="[
            'px-3 h-8 leading-tight border border-gray-300 dark:border-gray-700',
            'text-gray-500 bg-white hover:bg-gray-100 hover:text-gray-700',
            'dark:bg-gray-800 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white',
            { 'opacity-50 cursor-not-allowed': !canGoNext }
          ]"
          aria-label="Go to next page"
        >
          &rsaquo;
        </button>
      </li>
      <!-- Last Page Button -->
      <li>
        <button
          @click="goToPage(totalPages)"
          :disabled="!canGoNext"
          :class="[
            'px-3 h-8 leading-tight rounded-r-lg border border-gray-300 dark:border-gray-700',
            'text-gray-500 bg-white hover:bg-gray-100 hover:text-gray-700',
            'dark:bg-gray-800 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white',
            { 'opacity-50 cursor-not-allowed': !canGoNext }
          ]"
          aria-label="Go to last page"
        >
          &raquo;
        </button>
      </li>
    </ul>

    <!-- Optional: Page size selector (Placeholder) -->
    <!-- <div> -->
      <!-- Dropdown for itemsPerPage -->
    <!-- </div> -->
  </nav>
</template>

<script setup>
/**
 * BasePagination
 *
 * A component for navigating through paginated content.
 * Displays page numbers and controls for previous/next pages.
 * Includes first/last page jumps and optional item count display.
 *
 * @props {Number} currentPage - The currently active page number (1-based). Required.
 * @props {Number} totalPages - The total number of pages available. Required.
 * @props {Number} totalItems - The total number of items being paginated. Optional. If provided, shows item range.
 * @props {Number} itemsPerPage - The number of items displayed per page. Default: 10. Used for item range display.
 * @props {Number} pageRange - The number of page links to display around the current page (excluding first/last). Default: 2.
 *
 * @events update:currentPage - Emitted when the current page changes, payload is the new page number.
 */

import { computed } from 'vue';

const props = defineProps({
  currentPage: {
    type: Number,
    required: true,
    default: 1,
    validator: (value) => value >= 1,
  },
  totalPages: {
    type: Number,
    required: true,
    default: 1,
    validator: (value) => value >= 1,
  },
  totalItems: {
    type: Number,
    default: 0,
  },
  itemsPerPage: {
    type: Number,
    default: 10,
  },
  pageRange: {
    type: Number,
    default: 2, // Number of pages to show before AND after current page
    validator: (value) => value >= 0,
  }
});

const emit = defineEmits(['update:currentPage']);

// --- Computed Properties ---

const canGoPrevious = computed(() => props.currentPage > 1);
const canGoNext = computed(() => props.currentPage < props.totalPages);

/**
 * Generates the array of page numbers and ellipsis markers to display.
 */
const displayedPages = computed(() => {
  const current = props.currentPage;
  const total = props.totalPages;
  const range = props.pageRange;
  const pages = [];
  let ellipsisId = 0; // Unique key for ellipsis spans

  // Always show the first page
  pages.push({ number: 1, isCurrent: current === 1 });

  // Calculate the range of pages to display around the current page
  const rangeStart = Math.max(2, current - range);
  const rangeEnd = Math.min(total - 1, current + range);

  // Show ellipsis if there's a gap after the first page
  if (rangeStart > 2) {
    pages.push({ isEllipsis: true, id: ellipsisId++ });
  }

  // Add pages within the calculated range
  for (let i = rangeStart; i <= rangeEnd; i++) {
    pages.push({ number: i, isCurrent: current === i });
  }

  // Show ellipsis if there's a gap before the last page
  if (rangeEnd < total - 1) {
    pages.push({ isEllipsis: true, id: ellipsisId++ });
  }

  // Always show the last page if total pages > 1
  if (total > 1) {
    pages.push({ number: total, isCurrent: current === total });
  }

  return pages;
});


// --- Methods ---

const goToPage = (page) => {
  if (page >= 1 && page <= props.totalPages && page !== props.currentPage) {
    emit('update:currentPage', page);
  }
};

const goToPrevious = () => {
  if (canGoPrevious.value) {
    goToPage(props.currentPage - 1);
  }
};

const goToNext = () => {
  if (canGoNext.value) {
    goToPage(props.currentPage + 1);
  }
};

// TODO: Add dynamic page size options (potentially via a separate dropdown)

</script>

<style scoped>
/* No additional scoped styles needed as Tailwind is used directly */
</style>