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
        {{ filteredClients.length }} clients
      </div>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
      <div 
        v-for="client in filteredClients" 
        :key="client.id"
        class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 shadow-sm hover:shadow transition-shadow duration-200 cursor-pointer"
        @click="handleCardClick(client)"
      >
        <div class="p-4">
          <div class="flex justify-between items-start mb-2">
            <h4 class="font-medium text-gray-900 dark:text-white truncate">{{ client.displayName }}</h4>
            <BaseBadge
              :variant="getClientTypeBadgeVariant(client.clientType)"
              size="sm"
            >
              {{ formatClientType(client.clientType) }}
            </BaseBadge>
          </div>
          
          <div class="text-sm text-gray-600 dark:text-gray-400 mb-3">
            <div v-if="client.company" class="mb-1 truncate">{{ client.company }}</div>
            <div v-if="client.email" class="mb-1 truncate">{{ client.email }}</div>
            <div v-if="client.phone" class="truncate">{{ client.phone }}</div>
          </div>
          
          <div class="flex justify-between items-center pt-2 border-t border-gray-100 dark:border-gray-700">
            <div>
              <span class="text-xs inline-block" :class="client.isActive ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'">
                {{ client.isActive ? 'Active' : 'Inactive' }}
              </span>
            </div>
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
          </div>
        </div>
      </div>
    </div>

    <!-- Empty state -->
    <div v-if="filteredClients.length === 0" class="py-8 text-center">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto text-gray-400 dark:text-gray-600 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
      </svg>
      <p class="text-gray-500 dark:text-gray-400">No clients found matching your criteria.</p>
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
import { defineProps, defineEmits } from 'vue';
import BaseBadge from '@/components/data-display/BaseBadge.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import BasePagination from '@/components/navigation/BasePagination.vue';

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
  }
});

const emit = defineEmits(['view-change', 'edit', 'delete', 'reset-filters', 'page-change', 'row-click']);

const handleCardClick = (client) => {
  emit('row-click', client);
};
</script>
