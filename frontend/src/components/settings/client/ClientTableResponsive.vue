<template>
  <div>
    <div class="flex justify-between items-center mb-4">
      <div class="flex items-center">
        <button 
          @click="$emit('view-change', 'grid')" 
          class="text-blue-600 dark:text-blue-400 flex items-center gap-1"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zm14 0a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zm14 0a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
          </svg>
          <span>Switch to Grid View</span>
        </button>
      </div>
      <div class="flex items-center space-x-4">
        <div class="sm:flex items-center space-x-2 hidden">
          <span class="text-sm text-gray-500 dark:text-gray-400">Columns:</span>
          <BaseSelect
            v-model="localColumnsDisplay"
            :options="columnDisplayOptions"
            size="sm"
            class="w-40"
          />
        </div>
        <div class="text-sm text-gray-500 dark:text-gray-400">
          {{ filteredClients.length }} clients
        </div>
      </div>
    </div>

    <div class="overflow-x-auto rounded-lg">
      <table class="w-full divide-y divide-gray-200 dark:divide-gray-700">
        <thead class="bg-gray-50 dark:bg-gray-800">
          <tr>
            <th
              v-for="column in visibleColumns"
              :key="column.key"
              scope="col"
              class="px-3 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider"
              :class="{ 'cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-700': column.sortable }"
              @click="column.sortable ? handleSort(column.key) : null"
              :style="column.width ? `width: ${column.width}` : ''"
            >
              <span class="flex items-center space-x-1">
                {{ column.label }}
                <span v-if="column.sortable" class="text-gray-400 dark:text-gray-500 flex-shrink-0">
                  <svg v-if="sortKey === column.key && sortOrder === 'asc'" class="h-3 w-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M14.707 10.293a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 111.414-1.414L10 13.586l3.293-3.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                  <svg v-else-if="sortKey === column.key && sortOrder === 'desc'" class="h-3 w-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M5.293 9.707a1 1 0 010-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 01-1.414 1.414L10 6.414l-3.293 3.293a1 1 0 01-1.414 0z" clip-rule="evenodd"/></svg>
                  <svg v-else class="h-3 w-3 opacity-50" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 3a1 1 0 011 1v10.586l3.293-3.293a1 1 0 111.414 1.414l-4.999 5a1 1 0 01-1.414 0l-5.001-5a1 1 0 111.414-1.414L9 14.586V4a1 1 0 011-1z" clip-rule="evenodd"/></svg>
                </span>
              </span>
            </th>
          </tr>
        </thead>
        <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
          
          <!-- Loading State -->
          <tr v-if="loading">
            <td :colspan="visibleColumns.length" class="px-3 py-4 text-center text-gray-500 dark:text-gray-400">
              <BaseSkeletonLoader type="table" :rows="5" :columns="4" />
            </td>
          </tr>

          <!-- Empty State -->
          <tr v-else-if="!filteredClients || filteredClients.length === 0">
            <td :colspan="visibleColumns.length" class="px-3 py-4 text-center text-gray-500 dark:text-gray-400">
              <div class="py-8">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto text-gray-400 dark:text-gray-600 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
                <p class="text-gray-500 dark:text-gray-400">No clients found matching your criteria.</p>
                <BaseButton variant="outline" size="sm" class="mt-3" @click="$emit('reset-filters')">
                  Reset Filters
                </BaseButton>
              </div>
            </td>
          </tr>

          <!-- Data Rows -->
          <tr
            v-else
            v-for="(client, index) in filteredClients"
            :key="client.id || index"
            class="hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors duration-150 cursor-pointer"
            @click="$emit('row-click', client)"
          >
            <td
              v-for="column in visibleColumns"
              :key="column.key"
              class="px-3 py-3 text-sm"
              :class="column.allowWrap ? 'break-words' : 'whitespace-nowrap'"
            >
              <!-- Client Type Column -->
              <template v-if="column.key === 'clientType'">
                <BaseBadge
                  :variant="getClientTypeBadgeVariant(client.clientType)"
                  size="sm"
                >
                  {{ formatClientType(client.clientType) }}
                </BaseBadge>
              </template>
              
              <!-- Status Column -->
              <template v-else-if="column.key === 'isActive'">
                <BaseToggleSwitch
                  :model-value="client.isActive"
                  @update:model-value="$emit('toggle-status', client)"
                  @click.stop
                >
                  <span class="ml-2 text-sm" :class="client.isActive ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'">
                    {{ client.isActive ? 'Active' : 'Inactive' }}
                  </span>
                </BaseToggleSwitch>
              </template>
              
              <!-- Actions Column -->
              <template v-else-if="column.key === 'actions'">
                <div class="flex space-x-2">
                  <button
                    @click.stop="$emit('edit', client)"
                    class="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300"
                    aria-label="Edit client"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 0L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                  </button>
                  <button
                    @click.stop="$emit('delete', client)"
                    class="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300"
                    aria-label="Delete client"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>
              </template>
              
              <!-- Default Column Display -->
              <template v-else>
                {{ client[column.key] }}
              </template>
            </td>
          </tr>
        </tbody>
        <tfoot v-if="$slots.footer">
          <tr>
            <td :colspan="visibleColumns.length" class="px-3 py-3">
              <slot name="footer"></slot>
            </td>
          </tr>
        </tfoot>
      </table>
    </div>

    <!-- Pagination -->
    <div class="mt-6">
      <BasePagination
        :current-page="currentPage"
        :total-pages="totalPages"
        :total-items="totalItems"
        :items-per-page="itemsPerPage"
        @update:current-page="$emit('page-change', $event)"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import BaseBadge from '@/components/data-display/BaseBadge.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseSelect from '@/components/form/BaseSelect.vue';
import BaseToggleSwitch from '@/components/form/BaseToggleSwitch.vue';
import BasePagination from '@/components/navigation/BasePagination.vue';
import BaseSkeletonLoader from '@/components/data-display/BaseSkeletonLoader.vue';

const props = defineProps({
  filteredClients: {
    type: Array,
    required: true
  },
  currentPage: {
    type: Number,
    required: true
  },
  totalPages: {
    type: Number,
    required: true
  },
  totalItems: {
    type: Number,
    required: true
  },
  itemsPerPage: {
    type: Number,
    required: true
  },
  formatClientType: {
    type: Function,
    required: true
  },
  getClientTypeBadgeVariant: {
    type: Function,
    required: true
  },
  loading: {
    type: Boolean,
    default: false
  },
  sortKey: {
    type: String,
    default: 'displayName' // Use camelCase default
  },
  sortOrder: {
    type: String,
    default: 'asc'
  },
  columnsDisplay: {
    type: String,
    default: 'default'
  }
});

const emit = defineEmits([
  'view-change', 
  'edit', 
  'delete', 
  'reset-filters', 
  'page-change', 
  'row-click',
  'toggle-status',
  'sort-change',
  'update:columnsDisplay'
]);

// Configure available display options
const columnDisplayOptions = [
  { value: 'compact', label: 'Compact' },
  { value: 'default', label: 'Default' },
  { value: 'expanded', label: 'Expanded' }
];

// Available columns (using camelCase keys)
const allColumns = [
  { key: 'displayName', label: 'Name', sortable: true, width: '25%', allowWrap: true, priority: 1 },
  { key: 'company', label: 'Company', sortable: true, width: '20%', allowWrap: true, priority: 2 },
  { key: 'email', label: 'Email', sortable: true, width: '20%', allowWrap: true, priority: 3 },
  { key: 'phone', label: 'Phone', sortable: true, width: '15%', allowWrap: false, priority: 4 },
  { key: 'clientType', label: 'Type', sortable: false, width: '10%', allowWrap: false, priority: 2 },
  { key: 'isActive', label: 'Status', sortable: false, width: '10%', allowWrap: false, priority: 1 },
  { key: 'actions', label: 'Actions', sortable: false, width: '10%', allowWrap: false, priority: 1 }
];

// Sync columnsDisplay prop with local state
const localColumnsDisplay = ref(props.columnsDisplay);

watch(localColumnsDisplay, (newValue) => {
  emit('update:columnsDisplay', newValue);
});

watch(() => props.columnsDisplay, (newValue) => {
  localColumnsDisplay.value = newValue;
});

// Compute visible columns based on display option
const visibleColumns = computed(() => {
  if (localColumnsDisplay.value === 'compact') {
    // Only show high-priority columns (priority 1-2)
    return allColumns.filter(col => col.priority <= 2);
  } else if (localColumnsDisplay.value === 'expanded') {
    // Show all columns
    return allColumns;
  } else {
    // Default - show all except lowest priority
    return allColumns.filter(col => col.priority <= 3);
  }
});

// Handle sort
const handleSort = (key) => {
  const newOrder = props.sortKey === key && props.sortOrder === 'asc' ? 'desc' : 'asc';
  emit('sort-change', { key, order: newOrder });
};

// Save column preference to localStorage
onMounted(() => {
  const savedDisplay = localStorage.getItem('clientTableColumnsDisplay');
  if (savedDisplay) {
    localColumnsDisplay.value = savedDisplay;
    emit('update:columnsDisplay', savedDisplay);
  }
});

watch(localColumnsDisplay, (newValue) => {
  localStorage.setItem('clientTableColumnsDisplay', newValue);
});
</script>
