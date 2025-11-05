/**
 * BaseAdvancedTable
 *
 * An advanced table component for displaying and manipulating structured data.
 * Supports column freezing, row grouping, excel-like editing, and export functionality.
 *
 * @props {Array} columns - Array of column definitions (e.g., { key: 'id', label: 'ID', sortable: true }).
 * @props {Array} data - Array of data objects to display in the table.
 * @props {Boolean} selectable - Whether rows can be selected.
 * @props {Boolean} loading - Indicates if the table data is currently loading.
 * @props {String} emptyMessage - Message to display when there is no data.
 * @props {String} sortKey - The key of the currently sorted column.
 * @props {String} sortOrder - The current sort order ('asc' or 'desc').
 * @props {Number} frozenColumns - Number of columns to freeze.
 * @props {String} groupBy - The key to group rows by.
 * @props {Boolean} editable - Whether the table cells are editable.
 * @props {Boolean} showExportButtons - Whether to show export buttons.
 *
 * @slots header(column) - Custom content for a specific column header.
 * @slots cell(item, column, value, editing) - Custom content for a specific cell.
 * @slots empty - Custom content for the empty state.
 * @slots loading - Custom content for the loading state.
 * @slots footer - Custom content for the table footer (e.g., pagination).
 *
 * @events sort-change({ key: String, order: String }) - Emitted when the sort column or order changes.
 * @events row-click(item) - Emitted when a row is clicked.
 * @events row-click(item) - Emitted when a row is clicked.
 * @events selection-change(selectedItems) - Emitted when the row selection changes (if selectable).
 * @events cell-edit({ item, column, value }) - Emitted when a cell is edited.
 */

<template>
  <div class="overflow-x-auto">
    <div class="flex justify-end mb-2" v-if="props.showExportButtons">
      <button @click="downloadCSV" class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded">
        Export CSV
      </button>
      <button @click="downloadExcel" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded ml-2">
        Export Excel
      </button>
    </div>
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
          class="hover:bg-gray-50 dark:hover:bg-gray-800"
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
            <slot :name="`cell(${column.key})`" :item="item" :column="column" :value="item[column.key]" :editing="editingCell === `${item.id}-${column.key}`">
              <div v-if="props.editable && editingCell === `${item.id}-${column.key}`">
                <input
                  type="text"
                  class="shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block w-full sm:text-sm border-gray-300 rounded-md"
                  :value="item[column.key]"
                  @input="updateCellValue(item, column, $event.target.value)"
                  @blur="stopEditing()"
                  @keydown.tab="handleTab($event, item, column)"
                  @keydown.shift.tab="handleShiftTab($event, item, column)"
                  @keydown.enter="stopEditing()"
                />
              </div>
              <div v-else @dblclick="startEditing(item, column)" class="cursor-pointer" @keydown="handleKeyDown($event, item, column)">
                {{ item[column.key] }}
              </div>
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
import { Workbook } from 'exceljs';
import { unparse } from 'papaparse';

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
  },
  frozenColumns: {
    type: Number,
    default: 0
  },
  groupBy: {
    type: String,
    default: null
  },
  editable: {
    type: Boolean,
    default: false
  },
  showExportButtons: {
    type: Boolean,
    default: false
  }
});
const emit = defineEmits(['sort-change', 'row-click', 'selection-change', 'cell-edit']);

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

// Excel-like Editing
const editingCell = ref(null);

const startEditing = (item, column) => {
  if (props.editable) {
    editingCell.value = `${item.id}-${column.key}`;
  }
};

const stopEditing = () => {
  editingCell.value = null;
};

const updateCellValue = (item, column, value) => {
  emit('cell-edit', { item, column, value });
};

const handleTab = (event, item, column) => {
  event.preventDefault();
  stopEditing();

  const currentRowIndex = props.data.findIndex(i => i.id === item.id);
  const currentColumnIndex = props.columns.findIndex(c => c.key === column.key);

  let nextRowIndex = currentRowIndex;
  let nextColumnIndex = currentColumnIndex;
  let foundEditable = false;

  for (let i = 0; i < props.columns.length * props.data.length; i++) {
    nextColumnIndex = (nextColumnIndex + 1) % props.columns.length;
    if (nextColumnIndex === 0) {
      nextRowIndex = (nextRowIndex + 1) % props.data.length;
    }

    const nextItem = props.data[nextRowIndex];
    const nextColumn = props.columns[nextColumnIndex];

    if (props.editable) {
      foundEditable = true;
      startEditing(nextItem, nextColumn);
      break;
    }
  }

  if (!foundEditable) {
    // No editable cell found, do nothing or handle as needed
    console.warn("No editable cells found in the table.");
  }
};

const handleShiftTab = (event, item, column) => {
  event.preventDefault();
  stopEditing();

  const currentRowIndex = props.data.findIndex(i => i.id === item.id);
  const currentColumnIndex = props.columns.findIndex(c => c.key === column.key);

  let nextRowIndex = currentRowIndex;
  let nextColumnIndex = currentColumnIndex;
  let foundEditable = false;

  for (let i = 0; i < props.columns.length * props.data.length; i++) {
    nextColumnIndex = (nextColumnIndex - 1 + props.columns.length) % props.columns.length;
    if (nextColumnIndex === props.columns.length - 1) {
      nextRowIndex = (nextRowIndex - 1 + props.data.length) % props.data.length;
    }

    const nextItem = props.data[nextRowIndex];
    const nextColumn = props.columns[nextColumnIndex];

    if (props.editable) {
      foundEditable = true;
      startEditing(nextItem, nextColumn);
      break;
    }
  }

  if (!foundEditable) {
    // No editable cell found, do nothing or handle as needed
    console.warn("No editable cells found in the table.");
  }
};

const handleKeyDown = (event, item, column) => {
    if (event.ctrlKey && event.key === 'c') {
      // Copy functionality
      event.preventDefault();
      navigator.clipboard.writeText(item[column.key]);
    } else if (event.key === 'ArrowUp') {
      event.preventDefault();
      stopEditing();
      const currentRowIndex = props.data.findIndex(i => i.id === item.id);
      const nextRowIndex = (currentRowIndex - 1 + props.data.length) % props.data.length;
      const nextItem = props.data[nextRowIndex];
      startEditing(nextItem, column);
    } else if (event.key === 'ArrowDown') {
      event.preventDefault();
      stopEditing();
      const currentRowIndex = props.data.findIndex(i => i.id === item.id);
      const nextRowIndex = (currentRowIndex + 1) % props.data.length;
      const nextItem = props.data[nextRowIndex];
      startEditing(nextItem, column);
    }
  };

// Export Functionality
const downloadCSV = () => {
  const csv = unparse(props.data, {
    columns: props.columns.map(col => col.key)
  });

  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement("a");
  const url = URL.createObjectURL(blob);
  link.setAttribute("href", url);
  link.setAttribute("download", "data.csv");
  link.style.visibility = 'hidden';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

const downloadExcel = async () => {
  const workbook = new Workbook();
  const worksheet = workbook.addWorksheet('Data');

  // Add headers
  worksheet.columns = props.columns.map(col => ({
    header: col.label,
    key: col.key,
    width: 15
  }));

  // Add data rows
  props.data.forEach(row => {
    worksheet.addRow(row);
  });

  // Generate buffer and download
  const buffer = await workbook.xlsx.writeBuffer();
  const blob = new Blob([buffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);
  link.setAttribute('href', url);
  link.setAttribute('download', 'data.xlsx');
  link.style.visibility = 'hidden';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};
</script>
