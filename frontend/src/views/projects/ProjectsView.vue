<template>
  <div class="projects-dashboard">
    <!-- Date Header -->
    <header class="mb-6">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold">Projects</h1>
        <div class="text-sm text-gray-500 dark:text-gray-400">
          {{ formatDate(new Date()) }}
        </div>
      </div>
    </header>

    <!-- Current Active Job Section -->
    <section class="mb-8">
      <div class="mb-4">
        <h2 class="text-xl font-semibold">Current Active Job</h2>
        <p class="text-sm text-gray-500 dark:text-gray-400">
          Your company's main focus right now
        </p>
      </div>

      <!-- Current Active Job Card -->
      <div v-if="!currentJobLoading && currentActiveJob" 
           class="border-2 border-blue-400 dark:border-blue-600 rounded-lg overflow-hidden shadow-md">
        <ProjectCard
          :project="currentActiveJob"
          @click="navigateToProject(currentActiveJob.id)"
          class="cursor-pointer"
        />
      </div>

      <!-- Loading State -->
      <div v-else-if="currentJobLoading" class="py-6">
        <BaseLoader />
      </div>

      <!-- Empty State -->
      <div
        v-else
        class="p-6 border border-dashed border-gray-300 dark:border-gray-600 rounded-lg text-center"
      >
        <BaseIcon name="tool" class="w-10 h-10 mx-auto mb-3 text-gray-400 dark:text-gray-500" />
        <h3 class="text-lg font-medium mb-2">No Active Job</h3>
        <p class="text-gray-500 dark:text-gray-400 mb-4">
          You don't have any active job in progress right now
        </p>
        <BaseButton
          variant="primary"
          @click="createNewProject"
        >
          <BaseIcon name="plus" class="mr-2" />
          Create New Project
        </BaseButton>
      </div>
    </section>

    <!-- Assessment Projects Section -->
    <section class="mb-6">
      <div class="flex items-center justify-between mb-4">
        <div>
          <h2 class="text-lg font-semibold">In Assessment Phase</h2>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            Projects being evaluated before becoming active jobs
          </p>
        </div>
        <BaseButton
          variant="outline"
          size="sm"
          @click="navigateToProjects('assessments')"
          v-if="assessmentProjects.length > 3"
        >
          View All
        </BaseButton>
      </div>

      <!-- Assessment Project Cards -->
      <div v-if="!assessmentLoading" class="grid grid-cols-1 gap-4">
        <ProjectCard
          v-for="project in assessmentProjects.slice(0, 3)"
          :key="project.id"
          :project="project"
          @click="navigateToProject(project.id)"
        />
      </div>

      <!-- Loading State -->
      <div v-else class="py-4">
        <BaseLoader />
      </div>

      <!-- Empty State -->
      <div
        v-if="!assessmentLoading && assessmentProjects.length === 0"
        class="text-center py-6 bg-gray-50 dark:bg-gray-800/50 rounded-lg"
      >
        <div class="text-gray-500 dark:text-gray-400">
          No assessment projects found
        </div>
      </div>
    </section>

    <!-- Upcoming Jobs Section -->
    <section class="mb-6">
      <div class="flex items-center justify-between mb-4">
        <div>
          <h2 class="text-lg font-semibold">Upcoming Jobs</h2>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            Jobs scheduled for future dates
          </p>
        </div>
        <BaseButton
          variant="outline"
          size="sm"
          @click="navigateToProjects('upcoming')"
          v-if="upcomingProjects.length > 3"
        >
          View All
        </BaseButton>
      </div>

      <!-- Upcoming Project Cards -->
      <div v-if="!upcomingLoading" class="grid grid-cols-1 gap-4">
        <ProjectCard
          v-for="project in upcomingProjects.slice(0, 3)"
          :key="project.id"
          :project="project"
          @click="navigateToProject(project.id)"
        />
      </div>

      <!-- Loading State -->
      <div v-else class="py-4">
        <BaseLoader />
      </div>

      <!-- Empty State -->
      <div
        v-if="!upcomingLoading && upcomingProjects.length === 0"
        class="text-center py-6 bg-gray-50 dark:bg-gray-800/50 rounded-lg"
      >
        <div class="text-gray-500 dark:text-gray-400">
          No upcoming jobs scheduled
        </div>
      </div>
    </section>

    <!-- Recently Completed Section -->
    <section class="mb-6">
      <div class="flex items-center justify-between mb-4">
        <div>
          <h2 class="text-lg font-semibold">Recently Completed</h2>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            Jobs you've finished recently
          </p>
        </div>
        <BaseButton
          variant="outline"
          size="sm"
          @click="navigateToProjects('completed')"
          v-if="completedProjects.length > 3"
        >
          View All
        </BaseButton>
      </div>

      <!-- Completed Project Cards -->
      <div v-if="!completedLoading" class="grid grid-cols-1 gap-4">
        <ProjectCard
          v-for="project in completedProjects.slice(0, 3)"
          :key="project.id"
          :project="project"
          @click="navigateToProject(project.id)"
        />
      </div>

      <!-- Loading State -->
      <div v-else class="py-4">
        <BaseLoader />
      </div>

      <!-- Empty State -->
      <div
        v-if="!completedLoading && completedProjects.length === 0"
        class="text-center py-6 bg-gray-50 dark:bg-gray-800/50 rounded-lg"
      >
        <div class="text-gray-500 dark:text-gray-400">
          No recently completed jobs
        </div>
      </div>
    </section>
    
    <!-- Rejected Assessments Section -->
    <section class="mb-20">
      <div class="flex items-center justify-between mb-4">
        <div>
          <h2 class="text-lg font-semibold">Rejected Assessments</h2>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            Assessments that were rejected or cancelled
          </p>
        </div>
        <BaseButton
          variant="outline"
          size="sm"
          @click="navigateToProjects('rejected')"
          v-if="rejectedProjects.length > 3"
        >
          View All
        </BaseButton>
      </div>

      <!-- Rejected Project Cards -->
      <div v-if="!rejectedLoading" class="grid grid-cols-1 gap-4">
        <ProjectCard
          v-for="project in rejectedProjects.slice(0, 3)"
          :key="project.id"
          :project="project"
          @click="navigateToProject(project.id)"
        />
      </div>

      <!-- Loading State -->
      <div v-else class="py-4">
        <BaseLoader />
      </div>

      <!-- Empty State -->
      <div
        v-if="!rejectedLoading && rejectedProjects.length === 0"
        class="text-center py-6 bg-gray-50 dark:bg-gray-800/50 rounded-lg"
      >
        <div class="text-gray-500 dark:text-gray-400">
          No rejected assessments
        </div>
      </div>
    </section>

    <!-- Quick Actions -->
    <section 
      class="fixed bottom-0 left-0 right-0 bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 p-4 pb-safe z-10"
    >
      <div class="flex justify-between items-center max-w-lg mx-auto">
        <BaseButton
          variant="outline"
          class="flex-1 mr-2"
          @click="refreshAllProjects"
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
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import ProjectCard from '@/components/projects/ProjectCard.vue';
import projectsService from '@/services/standardized-projects.service.js';
import useErrorHandler from '@/composables/useErrorHandler.js';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseIcon from '@/components/base/BaseIcon.vue';
import BaseLoader from '@/components/feedback/BaseLoader.vue';

const router = useRouter();
const { handleError } = useErrorHandler();

// State variables for each section
const currentJobLoading = ref(false);
const assessmentLoading = ref(false);
const upcomingLoading = ref(false);
const completedLoading = ref(false);
const rejectedLoading = ref(false);

// Data for each section
const currentActiveJob = ref(null);
const assessmentProjects = ref([]);
const upcomingProjects = ref([]);
const completedProjects = ref([]);
const rejectedProjects = ref([]);

// Format date as "Wednesday, April 2"
const formatDate = (date) => {
  return date.toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric'
  });
};

// Load current active job
const loadCurrentActiveJob = async () => {
  currentJobLoading.value = true;
  try {
    const response = await projectsService.getCurrentActiveJob();
    if (response.success) {
      currentActiveJob.value = response.data;
    } else {
      handleError(new Error(response.message || 'Failed to load current active job'), 'Failed to load current active job.');
      currentActiveJob.value = null;
    }
  } catch (err) {
    handleError(err, 'Error loading current active job.');
    currentActiveJob.value = null;
  } finally {
    currentJobLoading.value = false;
  }
};

// Load assessment projects
const loadAssessmentProjects = async () => {
  assessmentLoading.value = true;
  try {
    const response = await projectsService.getAssessmentProjects();
    if (response.success) {
      assessmentProjects.value = response.data;
    } else {
      handleError(new Error(response.message || 'Failed to load assessment projects'), 'Failed to load assessment projects.');
      assessmentProjects.value = [];
    }
  } catch (err) {
    handleError(err, 'Error loading assessment projects.');
    assessmentProjects.value = [];
  } finally {
    assessmentLoading.value = false;
  }
};

// Load upcoming projects
const loadUpcomingProjects = async () => {
  upcomingLoading.value = true;
  try {
    const response = await projectsService.getUpcomingProjects();
    if (response.success) {
      upcomingProjects.value = response.data;
    } else {
      handleError(new Error(response.message || 'Failed to load upcoming projects'), 'Failed to load upcoming projects.');
      upcomingProjects.value = [];
    }
  } catch (err) {
    handleError(err, 'Error loading upcoming projects.');
    upcomingProjects.value = [];
  } finally {
    upcomingLoading.value = false;
  }
};

// Load recently completed projects
const loadCompletedProjects = async () => {
  completedLoading.value = true;
  try {
    const response = await projectsService.getRecentlyCompletedProjects();
    if (response.success) {
      completedProjects.value = response.data;
    } else {
      handleError(new Error(response.message || 'Failed to load completed projects'), 'Failed to load completed projects.');
      completedProjects.value = [];
    }
  } catch (err) {
    handleError(err, 'Error loading completed projects.');
    completedProjects.value = [];
  } finally {
    completedLoading.value = false;
  }
};

// Load rejected assessment projects
const loadRejectedProjects = async () => {
  rejectedLoading.value = true;
  try {
    const response = await projectsService.getRejectedProjects();
    if (response.success) {
      rejectedProjects.value = response.data;
    } else {
      handleError(new Error(response.message || 'Failed to load rejected assessments'), 'Failed to load rejected assessments.');
      rejectedProjects.value = [];
    }
  } catch (err) {
    handleError(err, 'Error loading rejected assessments.');
    rejectedProjects.value = [];
  } finally {
    rejectedLoading.value = false;
  }
};

// Navigate to project details
const navigateToProject = (id) => {
  router.push(`/projects/${id}`);
};

// Navigate to filtered projects view
const navigateToProjects = (filter) => {
  router.push({
    path: '/projects',
    query: { filter }
  });
};

// Navigate to create project page
const createNewProject = () => {
  router.push('/projects/create');
};

// Refresh all project lists
const refreshAllProjects = () => {
  loadCurrentActiveJob();
  loadAssessmentProjects();
  loadUpcomingProjects();
  loadCompletedProjects();
  loadRejectedProjects();
};

// Load all projects on mount
onMounted(() => {
  loadCurrentActiveJob();
  loadAssessmentProjects();
  loadUpcomingProjects();
  loadCompletedProjects();
  loadRejectedProjects();
});
</script>

<style scoped>
/* Safe area padding for mobile devices */
.pb-safe {
  padding-bottom: env(safe-area-inset-bottom, 1rem);
}
</style>
