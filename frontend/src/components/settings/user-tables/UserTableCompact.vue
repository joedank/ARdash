<!-- UserTableCompact.vue -->
<template>
  <div>
    <div class="flex justify-between items-center mb-4">
      <div class="flex items-center">
        <button
          @click="$emit('view-change', 'table')"
          class="text-blue-600 dark:text-blue-400 flex items-center gap-1"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M3 14h18M3 18h18M3 6h18" />
          </svg>
          <span>Switch to Table View</span>
        </button>
      </div>
      <div class="text-sm text-gray-500 dark:text-gray-400">
        {{ filteredUsers.length }} users
      </div>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
      <div
        v-for="user in filteredUsers"
        :key="user.id"
        class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 shadow-sm hover:shadow transition-shadow duration-200 cursor-pointer"
        @click="handleCardClick(user)"
      >
        <div class="p-4">
          <div class="flex justify-between items-start mb-2">
            <div class="flex items-center space-x-3">
              <BaseAvatar
                :name="user.name"
                :image="user.avatar_url"
                size="md"
                class="flex-shrink-0"
              />
              <div>
                <h4 class="font-medium text-gray-900 dark:text-white truncate">{{ user.name }}</h4>
                <p class="text-sm text-gray-500 dark:text-gray-400 truncate">{{ user.email }}</p>
              </div>
            </div>
            <BaseBadge
              :variant="getRoleBadgeVariant(user.role)"
              size="sm"
            >
              {{ formatRole(user.role) }}
            </BaseBadge>
          </div>

          <div class="text-sm text-gray-600 dark:text-gray-400 mb-3">
            <div v-if="user.department" class="mb-1 truncate">{{ user.department }}</div>
            <div v-if="user.last_login" class="truncate text-xs">
              Last login: {{ formatDate(user.last_login) }}
            </div>
          </div>

          <div class="flex justify-between items-center pt-2 border-t border-gray-100 dark:border-gray-700">
            <div>
              <span class="text-xs inline-block" :class="user.is_active ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'">
                {{ user.is_active ? 'Active' : 'Inactive' }}
              </span>
            </div>
            <div class="flex space-x-2">
              <button
                @click.stop="$emit('edit', user)"
                class="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300"
                aria-label="Edit user"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 0L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
              </button>
              <button
                v-if="canDelete(user)"
                @click.stop="$emit('delete', user)"
                class="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300"
                aria-label="Delete user"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty state -->
    <div v-if="filteredUsers.length === 0" class="py-8 text-center">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto text-gray-400 dark:text-gray-600 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
      </svg>
      <p class="text-gray-500 dark:text-gray-400">No users found matching your criteria.</p>
      <BaseButton variant="outline" size="sm" class="mt-3" @click="$emit('reset-filters')">
        Reset Filters
      </BaseButton>
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
// No need to import defineProps and defineEmits as they are auto-injected in <script setup>
import BaseBadge from '@/components/data-display/BaseBadge.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseAvatar from '@/components/data-display/BaseAvatar.vue';
import BasePagination from '@/components/navigation/BasePagination.vue';

const props = defineProps({
  filteredUsers: {
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
  formatRole: {
    type: Function,
    required: true
  },
  getRoleBadgeVariant: {
    type: Function,
    required: true
  },
  currentUser: {
    type: Object,
    required: true
  }
});

const emit = defineEmits(['view-change', 'edit', 'delete', 'reset-filters', 'page-change', 'row-click']);

function handleCardClick(user) {
  emit('row-click', user);
}

function formatDate(dateString) {
  if (!dateString) return 'Never';
  return new Date(dateString).toLocaleDateString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
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