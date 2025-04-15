<template>
  <div class="projects-dashboard">
    <!-- Today's Jobs Section -->
    <section class="mb-6">
      <div class="flex items-center justify-between mb-4">
        <h1 class="text-xl font-semibold">Today's Jobs</h1>
        <div class="text-sm text-gray-500 dark:text-gray-400">
          {{ formatDate(new Date()) }}
        </div>
      </div>

      <!-- Today's Project Cards -->
      <div v-if="!todayLoading" class="grid grid-cols-1 gap-4">
        <ProjectCard
          v-for="project in todayProjects"
          :key="project.id"
          :project="project"
          @click="navigateToProject(project.id)"
        />
      </div>

      <!-- Loading State -->
      <div v-else class="py-8">
        <BaseLoader />
      </div>

      <!-- Empty State -->
      <div
        v-if="!todayLoading && todayProjects.length === 0"
        class="text-center py-8 bg-gray-50 dark:bg-gray-800/50 rounded-lg"
      >
        <div class="text-gray-500 dark:text-gray-400">
          No jobs scheduled for today
        </div>
      </div>
    </section>

    <!-- All Projects Section -->
    <section class="mb-20">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-xl font-semibold">All Projects</h2>
        <div class="flex gap-2">
          <BaseButton
            v-for="filter in statusFilters"
            :key="filter.value"
            :variant="selectedStatus === filter.value ? 'primary' : 'outline'"
            size="sm"
            @click="selectedStatus = filter.value"
          >
            {{ filter.label }}
          </BaseButton>
        </div>
      </div>

      <!-- All Project Cards -->
      <div v-if="!allProjectsLoading" class="grid grid-cols-1 gap-4">
        <ProjectCard
          v-for="project in filteredProjects"
          :key="project.id"
          :project="project"
          @click="navigateToProject(project.id)"
        />
      </div>

      <!-- Loading State -->
      <div v-else class="py-8">
        <BaseLoader />
      </div>

      <!-- Empty State -->
      <div
        v-if="!allProjectsLoading && filteredProjects.length === 0"
        class="text-center py-8 bg-gray-50 dark:bg-gray-800/50 rounded-lg"
      >
        <div class="text-gray-500 dark:text-gray-400">
          No projects found
        </div>
      </div>
    </section>

    <!-- Quick Actions -->
    <section 
      class="fixed bottom-0 left-0 right-0 bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 p-4 pb-safe"
    >
      <div class="flex justify-between items-center max-w-lg mx-auto">
        <BaseButton
          variant="outline"
          class="flex-1 mr-2"
          @click="refreshProjects"
        >
          <BaseIcon name="refresh" class="mr-2" />
          Refresh
        </BaseButton>
        <BaseButton
          variant="primary"
          class="flex-1"
          @click="createNewProject"
        >
          <BaseIcon name="plus" class="mr-2" />
          New Project
        </BaseButton>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import ProjectCard from '@/components/projects/ProjectCard.vue';
// Use standardized service
import projectsService from '@/services/standardized-projects.service.js';
import useErrorHandler from '@/composables/useErrorHandler.js'; // Import error handler
import BaseButton from '@/components/base/BaseButton.vue';
import BaseIcon from '@/components/base/BaseIcon.vue';
import BaseLoader from '@/components/feedback/BaseLoader.vue';

const router = useRouter();
const { handleError } = useErrorHandler(); // Instantiate error handler
const todayLoading = ref(false);
const allProjectsLoading = ref(false);
const todayProjects = ref([]);
const allProjects = ref([]);
const selectedStatus = ref('all');

// Status filter options
const statusFilters = [
  { label: 'All', value: 'all' },
  { label: 'In Progress', value: 'in_progress' },
  { label: 'Completed', value: 'completed' }
];

// Filtered projects based on selected status
const filteredProjects = computed(() => {
  if (selectedStatus.value === 'all') {
    return allProjects.value;
  }
  return allProjects.value.filter(project => project.status === selectedStatus.value);
});

// Format date as "Wednesday, April 2"
const formatDate = (date) => {
  return date.toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric'
  });
};

// Load today's projects
const loadTodayProjects = async () => {
  todayLoading.value = true;
  try {
    // Changed from getAll to getTodayProjects
    const response = await projectsService.getTodayProjects();
    if (response.success) {
      todayProjects.value = response.data;
    } else {
      handleError(new Error(response.message || 'Failed to load today\'s projects'), 'Failed to load today\'s projects.');
      todayProjects.value = [];
    }
  } catch (err) {
    handleError(err, 'Error loading today\'s projects.');
    todayProjects.value = [];
  } finally {
    todayLoading.value = false;
  }
};

// Load all projects
const loadAllProjects = async () => {
  allProjectsLoading.value = true;
  try {
    // Changed from getAll to getAllProjects
    const response = await projectsService.getAllProjects();
    if (response.success) {
      allProjects.value = response.data;
    } else {
      handleError(new Error(response.message || 'Failed to load all projects'), 'Failed to load all projects.');
      allProjects.value = [];
    }
  } catch (err) {
    handleError(err, 'Error loading all projects.');
    allProjects.value = [];
  } finally {
    allProjectsLoading.value = false;
  }
};

// Navigate to project details
const navigateToProject = (id) => {
  router.push(`/projects/${id}`);
};

// Navigate to create project page
const createNewProject = () => {
  router.push('/projects/create');
};

// Refresh all project lists
const refreshProjects = () => {
  loadTodayProjects();
  loadAllProjects();
};

// Load projects on mount
onMounted(() => {
  loadTodayProjects();
  loadAllProjects();
});
</script>

<style scoped>
/* Safe area padding for mobile devices */
.pb-safe {
  padding-bottom: env(safe-area-inset-bottom, 1rem);
}
</style>
