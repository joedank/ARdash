/**
 * BaseTable
 * 
 * A versatile table component for displaying structured data.
 * Supports sorting, selection, pagination, and responsive adaptation.
 * 
 * @props {Array} columns - Array of column definitions (e.g., { key: 'id', label: 'ID', sortable: true }).
 * @props {Array} data - Array of data objects to display in the table.
 * @props {Boolean} selectable - Whether rows can be selected.
 * @props {Boolean} loading - Indicates if the table data is currently loading.
 * @props {String} emptyMessage - Message to display when there is no data.
 * @props {String} sortKey - The key of the currently sorted column.
 * @props {String} sortOrder - The current sort order ('asc' or 'desc').
 * 
 * @slots header(column) - Custom content for a specific column header.
 * @slots cell(item, column, value) - Custom content for a specific cell.
 * @slots empty - Custom content for the empty state.
 * @slots loading - Custom content for the loading state.
 * @slots footer - Custom content for the table footer (e.g., pagination).
 * 
 * @events sort-change({ key: String, order: String }) - Emitted when the sort column or order changes.
 * @events row-click(item) - Emitted when a row is clicked.
 * @events selection-change(selectedItems) - Emitted when the row selection changes (if selectable).
 */

<template>
  <div class="overflow-x-auto">
    <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
      <thead class="bg-gray-50 dark:bg-gray-800">
        <tr>
          <th
            v-for="column in props.columns"
            :key="column.key"
            scope="col"
            class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider"
            :class="{ 'cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-700': column.sortable }"
            @click="column.sortable ? handleSort(column.key) : null"
            :aria-sort="getAriaSort(column.key)"
          >
            <slot :name="`header(${column.key})`" :column="column">
              <span class="flex items-center space-x-1">
                {{ column.label }}
                <span v-if="column.sortable" class="text-gray-400 dark:text-gray-500 flex-shrink-0">
                  <svg v-if="props.sortKey === column.key && props.sortOrder === 'asc'" class="h-3 w-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M14.707 10.293a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 111.414-1.414L10 13.586l3.293-3.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                  <svg v-else-if="props.sortKey === column.key && props.sortOrder === 'desc'" class="h-3 w-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M5.293 9.707a1 1 0 010-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 01-1.414 1.414L10 6.414l-3.293 3.293a1 1 0 01-1.414 0z" clip-rule="evenodd"/></svg>
                  <svg v-else class="h-3 w-3 opacity-50" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 3a1 1 0 011 1v10.586l3.293-3.293a1 1 0 111.414 1.414l-4.999 5a1 1 0 01-1.414 0l-5.001-5a1 1 0 111.414-1.414L9 14.586V4a1 1 0 011-1z" clip-rule="evenodd"/></svg>
                </span>
              </span>
            </slot>
          </th>
        </tr>
      </thead>
      <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
        
        <!-- Loading State -->
        <tr v-if="props.loading">
          <td :colspan="props.columns.length" class="px-6 py-4 text-center text-gray-500 dark:text-gray-400">
            <slot name="loading">
              Loading...
            </slot>
          </td>
        </tr>

        <!-- Empty State -->
        <tr v-else-if="!props.data || props.data.length === 0">
          <td :colspan="props.columns.length" class="px-6 py-4 text-center text-gray-500 dark:text-gray-400">
            <slot name="empty">
              {{ props.emptyMessage }}
            </slot>
          </td>
        </tr>

        <!-- Data Rows -->
        <tr
          v-else
          v-for="(item, index) in props.data"
          :key="item.id || index"
          class="hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors duration-150"
          :class="{
            'cursor-pointer': props.selectable || $attrs['onRow-click'],
            'bg-blue-50 dark:bg-blue-900/30': props.selectable && selectedRows.has(item)
          }"
          @click="handleRowClick(item)"
        >
          <td
            v-for="column in props.columns"
            :key="column.key"
            class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-200"
          >
            <slot :name="`cell(${column.key})`" :item="item" :column="column" :value="item[column.key]">
              {{ item[column.key] }}
            </slot>
          </td>
        </tr>
        
      </tbody>
      <tfoot v-if="$slots.footer">
        <tr>
          <td :colspan="props.columns.length" class="px-6 py-4">
            <slot name="footer"></slot>
          </td>
        </tr>
      </tfoot>
    </table>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue';

const props = defineProps({
  columns: {
    type: Array,
    required: true,
    validator: (cols) => Array.isArray(cols) && cols.every(col => col.key && col.label)
  },
  data: {
    type: Array,
    required: true,
    default: () => []
  },
  selectable: {
    type: Boolean,
    default: false
  },
  loading: {
    type: Boolean,
    default: false
  },
  emptyMessage: {
    type: String,
    default: 'No data available.'
  },
  sortKey: {
    type: String,
    default: null
  },
  sortOrder: {
    type: String,
    default: 'asc',
    validator: (value) => ['asc', 'desc'].includes(value)
  }
});
const emit = defineEmits(['sort-change', 'row-click', 'selection-change']);

// Computed properties and methods for sorting
const getAriaSort = (columnKey) => {
  if (props.sortKey !== columnKey) return 'none';
  return props.sortOrder === 'asc' ? 'ascending' : 'descending';
};

const handleSort = (columnKey) => {
  const newOrder = props.sortKey === columnKey && props.sortOrder === 'asc' ? 'desc' : 'asc';
  emit('sort-change', { key: columnKey, order: newOrder });
};

// Row selection handling
const selectedRows = ref(new Set());

const toggleRowSelection = (item) => {
  const newSelection = new Set(selectedRows.value);
  if (newSelection.has(item)) {
    newSelection.delete(item);
  } else {
    newSelection.add(item);
  }
  selectedRows.value = newSelection;
  emit('selection-change', Array.from(newSelection));
};

const handleRowClick = (item) => {
  if (props.selectable) {
    toggleRowSelection(item);
  }
  // Always emit row-click, regardless of selectability
  emit('row-click', item);
};


</script>