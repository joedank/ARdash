<!-- ProjectTableResponsive.vue -->
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
        <BaseSelect
          v-model="localColumnsDisplay"
          :options="columnDisplayOptions"
          class="w-40"
        />
      </div>
    </div>

    <div class="overflow-x-auto rounded-lg border border-gray-200 dark:border-gray-700">
      <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
        <thead class="bg-gray-50 dark:bg-gray-800">
          <tr>
            <th
              v-for="column in visibleColumns"
              :key="column.key"
              scope="col"
              class="px-3 py-3 text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider"
              :class="[
                column.align === 'right' ? 'text-right' : 'text-left',
                column.align === 'center' ? 'text-center' : '',
                column.width ? `w-[${column.width}]` : ''
              ]"
              @click="column.sortable ? handleSort(column.key) : null"
            >
              <span class="flex items-center space-x-1 cursor-pointer">
                <span>{{ column.label }}</span>
                <span v-if="column.sortable" class="inline-flex flex-col">
                  <svg v-if="sortKey === column.key && sortOrder === 'asc'" class="h-3 w-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 17a1 1 0 01-1-1V4.414l-3.293 3.293a1 1 0 11-1.414-1.414l5-5a1 1 0 011.414 0l5 5a1 1 0 11-1.414 1.414L11 4.414V16a1 1 0 01-1 1z" clip-rule="evenodd"/></svg>
                  <svg v-else-if="sortKey === column.key && sortOrder === 'desc'" class="h-3 w-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 3a1 1 0 011 1v10.586l3.293-3.293a1 1 0 111.414 1.414l-5 5a1 1 0 01-1.414 0l-5-5a1 1 0 111.414-1.414L9 14.586V4a1 1 0 011-1z" clip-rule="evenodd"/></svg>
                  <svg v-else class="h-3 w-3 opacity-50" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 3a1 1 0 011 1v10.586l3.293-3.293a1 1 0 111.414 1.414l-5 5a1 1 0 01-1.414 0l-5-5a1 1 0 111.414-1.414L9 14.586V4a1 1 0 011-1z" clip-rule="evenodd"/></svg>
                </span>
              </span>
            </th>
          </tr>
        </thead>
        <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">

          <!-- Loading State -->
          <tr v-if="loading">
            <td :colspan="visibleColumns.length" class="px-3 py-4 text-center text-gray-500 dark:text-gray-400">
              <BaseLoader />
            </td>
          </tr>

          <!-- Empty State -->
          <tr v-else-if="!filteredProjects || filteredProjects.length === 0">
            <td :colspan="visibleColumns.length" class="px-3 py-4 text-center text-gray-500 dark:text-gray-400">
              <div class="py-8 bg-white dark:bg-gray-900">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto text-gray-400 dark:text-gray-600 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                </svg>
                <p class="text-gray-500 dark:text-gray-400">No projects found matching your criteria.</p>
                <BaseButton variant="outline" size="sm" class="mt-3" @click="$emit('reset-filters')">
                  Reset Filters
                </BaseButton>
              </div>
            </td>
          </tr>

          <!-- Data Rows -->
          <tr
            v-else
            v-for="(project, index) in filteredProjects"
            :key="project.id || index"
            class="hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors duration-150 cursor-pointer bg-white dark:bg-gray-900"
            @click="$emit('row-click', project)"
          >
            <td
              v-for="column in visibleColumns"
              :key="column.key"
              class="px-3 py-3 text-sm"
              :class="[
                column.allowWrap ? 'break-words' : 'whitespace-nowrap',
                column.align === 'right' ? 'text-right' : 'text-left',
                column.align === 'center' ? 'text-center' : '',
                column.cellClass || ''
              ]"
            >
              <!-- Client Column -->
              <template v-if="column.key === 'client'">
                <div class="text-sm font-medium text-gray-900 dark:text-white">
                  {{ getClientName(project.client) }}
                </div>
                <div v-if="project.client" class="text-xs text-gray-500 dark:text-gray-400">
                  {{ project.client.email || 'No email' }}
                </div>
              </template>

              <!-- Project Type Column -->
              <template v-else-if="column.key === 'type'">
                <div class="flex items-center">
                  <BaseBadge
                    :variant="project.type === 'assessment' ? 'red' : 'green'"
                    size="sm"
                  >
                    {{ formatProjectType(project.type) }}
                  </BaseBadge>
                  
                  <!-- Conversion Indicator -->
                  <span 
                    v-if="project.convertedJob || project.assessment" 
                    class="ml-1 inline-flex items-center" 
                    title="This project has been converted"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 text-blue-500">
                      <path fill-rule="evenodd" d="M2 10a.75.75 0 01.75-.75h12.59l-2.1-1.95a.75.75 0 111.02-1.1l3.5 3.25a.75.75 0 010 1.1l-3.5 3.25a.75.75 0 11-1.02-1.1l2.1-1.95H2.75A.75.75 0 012 10z" clip-rule="evenodd" />
                    </svg>
                  </span>
                </div>
              </template>

              <!-- Status Column -->
              <template v-else-if="column.key === 'status'">
                <BaseBadge
                  :variant="getStatusBadgeVariant(project.status)"
                  size="sm"
                >
                  {{ formatProjectStatus(project.status) }}
                </BaseBadge>
              </template>

              <!-- Scheduled Date Column -->
              <template v-else-if="column.key === 'scheduledDate'">
                {{ formatDate(project.scheduledDate) }}
              </template>

              <!-- Created Date Column -->
              <template v-else-if="column.key === 'createdAt'">
                {{ formatDate(project.createdAt) }}
              </template>

              <!-- Actions Column -->
              <template v-else-if="column.key === 'actions'">
                <div class="flex space-x-2 justify-end">
                  <button
                    @click.stop="$emit('edit', project)"
                    class="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 p-1 rounded hover:bg-blue-100 dark:hover:bg-blue-900/50"
                    aria-label="Edit project"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 0L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                  </button>
                  <button
                    @click.stop="$emit('delete', project)"
                    class="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300 p-1 rounded hover:bg-red-100 dark:hover:bg-red-900/50"
                    aria-label="Delete project"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>
              </template>

              <!-- Default Column -->
              <template v-else>
                {{ getProjectValue(project, column.key) }}
              </template>
            </td>
          </tr>
        </tbody>
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
import { ref, computed, watch } from 'vue';
import BaseBadge from '@/components/data-display/BaseBadge.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import BasePagination from '@/components/navigation/BasePagination.vue';
import BaseSelect from '@/components/form/BaseSelect.vue';
import BaseLoader from '@/components/feedback/BaseLoader.vue';

const props = defineProps({
  filteredProjects: { type: Array, required: true },
  loading: { type: Boolean, default: false },
  sortKey: { type: String, default: 'client' },
  sortOrder: { type: String, default: 'asc' },
  currentPage: { type: Number, default: 1 },
  totalPages: { type: Number, default: 1 },
  totalItems: { type: Number, default: 0 },
  itemsPerPage: { type: Number, default: 10 },
  formatProjectType: { type: Function, required: true },
  formatProjectStatus: { type: Function, required: true },
  getStatusBadgeVariant: { type: Function, required: true },
  getClientName: { type: Function, required: true },
  columnsDisplay: { type: String, default: 'default' } // 'default', 'compact', 'full'
});

const emit = defineEmits([
  'view-change',
  'sort-change',
  'page-change',
  'row-click',
  'edit',
  'delete',
  'reset-filters',
  'update:columnsDisplay'
]);

// Local state for v-model binding
const localColumnsDisplay = ref(props.columnsDisplay);
watch(() => props.columnsDisplay, (newValue) => {
  localColumnsDisplay.value = newValue;
});

watch(localColumnsDisplay, (newValue) => {
  emit('update:columnsDisplay', newValue);
});

// Column definitions for different display modes
const columnDefinitions = {
  default: [
    { key: 'client', label: 'Client', sortable: true, allowWrap: false, truncate: true, width: '25%' },
    { key: 'type', label: 'Type', sortable: true, allowWrap: false, width: '15%' },
    { key: 'status', label: 'Status', sortable: true, allowWrap: false, width: '15%' },
    { key: 'scheduledDate', label: 'Scheduled Date', sortable: true, allowWrap: false, width: '20%' },
    { key: 'actions', label: 'Actions', sortable: false, allowWrap: false, width: '15%', align: 'right' }
  ],
  compact: [
    { key: 'client', label: 'Client', sortable: true, allowWrap: false, truncate: true, width: '40%' },
    { key: 'type', label: 'Type', sortable: true, allowWrap: false, width: '20%' },
    { key: 'status', label: 'Status', sortable: true, allowWrap: false, width: '20%' },
    { key: 'actions', label: 'Actions', sortable: false, allowWrap: false, width: '10%', align: 'right' }
  ],
  full: [
    { key: 'client', label: 'Client', sortable: true, allowWrap: false, truncate: true, width: '20%' },
    { key: 'type', label: 'Type', sortable: true, allowWrap: false, width: '10%' },
    { key: 'status', label: 'Status', sortable: true, allowWrap: false, width: '10%' },
    { key: 'scheduledDate', label: 'Scheduled Date', sortable: true, allowWrap: false, width: '15%' },
    { key: 'createdAt', label: 'Created Date', sortable: true, allowWrap: false, width: '15%' },
    { key: 'estimate', label: 'Estimate', sortable: false, allowWrap: false, width: '15%' },
    { key: 'actions', label: 'Actions', sortable: false, allowWrap: false, width: '10%', align: 'right' }
  ]
};

const columnDisplayOptions = [
  { value: 'default', label: 'Default View' },
  { value: 'compact', label: 'Compact View' },
  { value: 'full', label: 'Full View' }
];

const visibleColumns = computed(() => {
  return columnDefinitions[props.columnsDisplay] || columnDefinitions.default;
});

// Helper to get nested values if needed
function getProjectValue(project, key) {
  if (!key) return '';

  // Handle nested properties
  if (key.includes('.')) {
    const parts = key.split('.');
    let value = project;
    for (const part of parts) {
      if (value === null || value === undefined) return '';
      value = value[part];
    }
    return value ?? '';
  }

  return project[key] ?? '';
}

// Handle sorting
function handleSort(key) {
  const newOrder = props.sortKey === key && props.sortOrder === 'asc' ? 'desc' : 'asc';
  emit('sort-change', { key, order: newOrder });
}

// Format date
function formatDate(dateString) {
  if (!dateString) return 'Not scheduled';
  return new Date(dateString).toLocaleDateString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });
}
</script>
