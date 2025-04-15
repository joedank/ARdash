<!-- ProjectTableCompact.vue -->
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
        {{ filteredProjects.length }} projects
      </div>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 p-4 bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-700">
      <div
        v-for="project in filteredProjects"
        :key="project.id"
        class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 shadow-sm hover:shadow-md transition-shadow duration-200 cursor-pointer"
        @click="handleCardClick(project)"
      >
        <div class="p-4">
          <div class="flex justify-between items-start mb-2">
            <h4 class="font-medium text-gray-900 dark:text-white truncate">{{ getClientName(project.client) }}</h4>
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
          </div>

          <div class="text-sm text-gray-600 dark:text-gray-400 mb-3">
            <div v-if="project.client?.email" class="mb-1 truncate">{{ project.client.email }}</div>
            <div v-if="project.scheduledDate" class="truncate text-xs">
              Scheduled: {{ formatDate(project.scheduledDate) }}
            </div>
          </div>

          <div class="flex justify-between items-center pt-2 border-t border-gray-100 dark:border-gray-700">
            <div>
              <BaseBadge
                :variant="getStatusBadgeVariant(project.status)"
                size="sm"
              >
                {{ formatProjectStatus(project.status) }}
              </BaseBadge>
            </div>
            <div class="flex space-x-2">
              <button
                @click.stop="$emit('edit', project)"
                class="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300"
                aria-label="Edit project"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 0L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
              </button>
              <button
                @click.stop="$emit('delete', project)"
                class="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300"
                aria-label="Delete project"
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
    <div v-if="filteredProjects.length === 0" class="py-8 text-center bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-700">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto text-gray-400 dark:text-gray-600 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
      </svg>
      <p class="text-gray-500 dark:text-gray-400">No projects found matching your criteria.</p>
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
  filteredProjects: {
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
  formatProjectType: {
    type: Function,
    required: true
  },
  formatProjectStatus: {
    type: Function,
    required: true
  },
  getStatusBadgeVariant: {
    type: Function,
    required: true
  },
  getClientName: {
    type: Function,
    required: true
  }
});

const emit = defineEmits(['view-change', 'edit', 'delete', 'reset-filters', 'page-change', 'row-click']);

function handleCardClick(project) {
  emit('row-click', project);
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
