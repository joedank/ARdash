<!-- UserTableResponsive.vue -->
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
            @update:modelValue="$emit('update:columnsDisplay', $event)"
          />
        </div>
        <div class="text-sm text-gray-500 dark:text-gray-400">
          {{ filteredUsers.length }} users
        </div>
      </div>
    </div>

    <div class="overflow-x-auto border border-gray-200 dark:border-gray-700 rounded-lg">
      <table class="w-full divide-y divide-gray-200 dark:divide-gray-700">
        <thead class="bg-gray-50 dark:bg-gray-800">
          <tr>
            <th
              v-for="column in visibleColumns"
              :key="column.key"
              scope="col"
              class="px-3 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider"
              :class="{ 'cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-700': column.sortable }"
              @click="column.sortable ? $emit('sort-change', { key: column.key, order: sortKey === column.key && sortOrder === 'asc' ? 'desc' : 'asc' }) : null"
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
              Loading users...
            </td>
          </tr>

          <!-- Empty State -->
          <tr v-else-if="!filteredUsers || filteredUsers.length === 0">
            <td :colspan="visibleColumns.length" class="px-3 py-4 text-center text-gray-500 dark:text-gray-400">
              <div class="py-8">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto text-gray-400 dark:text-gray-600 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
                <p class="text-gray-500 dark:text-gray-400">No users found matching your criteria.</p>
                <BaseButton variant="outline" size="sm" class="mt-3" @click="$emit('reset-filters')">
                  Reset Filters
                </BaseButton>
              </div>
            </td>
          </tr>

          <!-- Data Rows -->
          <tr
            v-else
            v-for="(user, index) in filteredUsers"
            :key="user.id || index"
            class="hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors duration-150 cursor-pointer"
            @click="$emit('row-click', user)"
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
              <!-- Role Column -->
              <template v-if="column.key === 'role'">
                <BaseBadge
                  :variant="getRoleBadgeVariant(user.role)"
                  size="sm"
                >
                  {{ formatRole(user.role) }}
                </BaseBadge>
              </template>

              <!-- Status Column -->
              <template v-else-if="column.key === 'is_active'">
                <BaseToggleSwitch
                  :model-value="user.is_active"
                  @update:model-value="$emit('toggle-status', user)"
                  @click.stop
                  size="sm"
                >
                  <span class="ml-2 text-xs" :class="user.is_active ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'">
                    {{ user.is_active ? 'Active' : 'Inactive' }}
                  </span>
                </BaseToggleSwitch>
              </template>

              <!-- Actions Column -->
              <template v-else-if="column.key === 'actions'">
                <div class="flex space-x-2 justify-end">
                  <button
                    @click.stop="$emit('edit', user)"
                    class="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 p-1 rounded hover:bg-blue-100 dark:hover:bg-blue-900/50"
                    aria-label="Edit user"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 0L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                  </button>
                  <button
                    v-if="canDelete(user)"
                    @click.stop="$emit('delete', user)"
                    class="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300 p-1 rounded hover:bg-red-100 dark:hover:bg-red-900/50"
                    aria-label="Delete user"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>
              </template>

              <!-- Default Column -->
              <template v-else>
                <span :class="column.truncate ? 'truncate block' : ''">
                  {{ getUserValue(user, column.key) }}
                </span>
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
import BaseToggleSwitch from '@/components/form/BaseToggleSwitch.vue';

const props = defineProps({
  filteredUsers: { type: Array, required: true },
  loading: { type: Boolean, default: false },
  sortKey: { type: String, default: 'name' },
  sortOrder: { type: String, default: 'asc' },
  currentPage: { type: Number, default: 1 },
  totalPages: { type: Number, default: 1 },
  totalItems: { type: Number, default: 0 },
  itemsPerPage: { type: Number, default: 10 },
  formatRole: { type: Function, required: true },
  getRoleBadgeVariant: { type: Function, required: true },
  columnsDisplay: { type: String, default: 'default' }, // 'default', 'compact', 'full'
  currentUser: { type: Object, required: true } // For permission checks
});

const emit = defineEmits([
  'view-change',
  'sort-change',
  'page-change',
  'row-click',
  'edit',
  'delete',
  'toggle-status',
  'reset-filters',
  'update:columnsDisplay'
]);

// Local state for v-model binding
const localColumnsDisplay = ref(props.columnsDisplay);
watch(() => props.columnsDisplay, (newValue) => {
  localColumnsDisplay.value = newValue;
});

// Column definitions for different view modes
const columnDefinitions = {
  default: [
    { key: 'name', label: 'Name', sortable: true, allowWrap: false, truncate: true, width: '25%' },
    { key: 'role', label: 'Role', sortable: true, allowWrap: false, width: '15%' },
    { key: 'email', label: 'Email', sortable: true, allowWrap: false, truncate: true, width: '25%' },
    { key: 'is_active', label: 'Status', sortable: true, allowWrap: false, width: '15%', align: 'center' },
    { key: 'actions', label: 'Actions', sortable: false, allowWrap: false, width: '10%', align: 'right' }
  ],
  compact: [
    { key: 'name', label: 'Name', sortable: true, allowWrap: false, truncate: true, width: '40%' },
    { key: 'role', label: 'Role', sortable: true, allowWrap: false, width: '20%' },
    { key: 'is_active', label: 'Status', sortable: true, allowWrap: false, width: '20%', align: 'center' },
    { key: 'actions', label: 'Actions', sortable: false, allowWrap: false, width: '10%', align: 'right' }
  ],
  full: [
    { key: 'name', label: 'Name', sortable: true, allowWrap: false, truncate: true, width: '20%' },
    { key: 'role', label: 'Role', sortable: true, allowWrap: false, width: '15%' },
    { key: 'email', label: 'Email', sortable: true, allowWrap: false, truncate: true, width: '20%' },
    { key: 'department', label: 'Department', sortable: true, allowWrap: false, truncate: true, width: '15%' },
    { key: 'last_login', label: 'Last Login', sortable: true, allowWrap: false, width: '15%' },
    { key: 'is_active', label: 'Status', sortable: true, allowWrap: false, width: '5%', align: 'center' },
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
function getUserValue(user, key) {
  if (!key) return '';
  return user[key] ?? '';
}

// Permission check for delete action
function canDelete(user) {
  // Can't delete yourself
  if (user.id === props.currentUser.id) return false;
  
  // Only admins can delete users
  if (props.currentUser.role !== 'admin') return false;
  
  // Admins can't delete other admins
  if (user.role === 'admin') return false;
  
  return true;
}
</script>