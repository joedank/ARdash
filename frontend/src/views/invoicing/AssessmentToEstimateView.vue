<template>
  <div class="assessment-to-estimate pt-4">
    <div class="mb-6 flex justify-between items-center">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Assessment to Estimate</h1>
        <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
          Convert assessment data into detailed estimates with interactive editing
        </p>
      </div>
      <div class="flex gap-3">
        <button
          @click="loadAssessment"
          :disabled="isLoading"
          class="inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="-ml-1 mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12" />
          </svg>
          Load Assessment
        </button>
        <router-link
          to="/invoicing/estimates"
          class="inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="-ml-1 mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
          </svg>
          View All Estimates
        </router-link>
        <button
          @click="createEstimate"
          :disabled="!estimateItems.length || isLoading"
          class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 dark:bg-green-500 dark:hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="-ml-1 mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          Create Estimate
        </button>
      </div>
    </div>

    <!-- Project Selection Modal -->
    <teleport to="body">
      <div v-if="showProjectModal" class="fixed inset-0 z-50 overflow-y-auto">
        <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
          <div class="fixed inset-0 bg-gray-500 bg-opacity-75 dark:bg-gray-900 dark:bg-opacity-75 transition-opacity" @click="showProjectModal = false"></div>
          <span class="hidden sm:inline-block sm:align-middle sm:h-screen">&#8203;</span>
          <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full sm:p-6">
            <div>
              <div class="mt-3 text-center sm:mt-5">
                <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white">
                  Select Assessment Project
                </h3>
                <div class="mt-4">
                  <div v-if="isLoadingProjects" class="text-center py-4">
                    <svg class="animate-spin h-6 w-6 text-blue-500 mx-auto" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">Loading assessment projects...</p>
                  </div>
                  <div v-else-if="availableProjects.length === 0" class="text-center py-4">
                    <p class="text-gray-500 dark:text-gray-400">No assessment projects found.</p>
                  </div>
                  <div v-else class="max-h-60 overflow-y-auto">
                    <div 
                      v-for="project in availableProjects" 
                      :key="project.id"
                      @click="selectProject(project)"
                      class="mb-2 p-3 border border-gray-200 dark:border-gray-700 rounded-md cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700"
                    >
                      <div class="flex justify-between items-start">
                        <div>
                          <h4 class="font-medium text-gray-900 dark:text-white">
                            {{ project.client?.displayName || 'Unknown Client' }}
                          </h4>
                          <p class="text-sm text-gray-600 dark:text-gray-400">
                            Scheduled: {{ formatDate(project.scheduledDate) }}
                          </p>
                          <p v-if="project.scope" class="text-xs text-gray-500 dark:text-gray-500 mt-1">
                            {{ truncateText(project.scope, 100) }}
                          </p>
                        </div>
                        <div>
                          <span 
                            class="px-2 py-1 text-xs rounded-full"
                            :class="project.status === 'completed' ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' : 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200'"
                          >
                            {{ formatStatus(project.status) }}
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="mt-5 sm:mt-6 sm:grid sm:grid-cols-2 sm:gap-3 sm:grid-flow-row-dense">
              <button
                type="button"
                @click="refreshProjects"
                class="w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-base font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:col-start-1 sm:text-sm"
              >
                Refresh List
              </button>
              <button
                type="button"
                @click="showProjectModal = false"
                class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-base font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:col-start-2 sm:text-sm"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      </div>
    </teleport>

    <!-- Loading state -->
    <div v-if="isLoading && !assessment.formattedMarkdown" class="flex items-center justify-center h-64">
      <svg class="animate-spin h-10 w-10 text-blue-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      <span class="ml-3 text-lg text-gray-700 dark:text-gray-300">{{ loadingMessage }}</span>
    </div>
    
    <!-- Empty state -->
    <div v-else-if="!assessment.formattedMarkdown" class="flex flex-col items-center justify-center h-64 border-2 border-dashed border-gray-300 dark:border-gray-700 rounded-lg">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 text-gray-400 dark:text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 13h6m-3-3v6m5 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
      </svg>
      <p class="mt-2 text-lg text-gray-600 dark:text-gray-400">No assessment data loaded</p>
      <p class="mt-1 text-sm text-gray-500 dark:text-gray-500">Select an assessment project to generate an estimate</p>
      <button
        @click="loadAssessment"
        class="mt-4 px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
      >
        Load Assessment
      </button>
    </div>
    
    <!-- Main content when assessment is loaded -->
    <div v-else class="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
      <EstimateFromAssessment
        :assessmentId="assessmentId"
        :assessmentData="assessment"
        @update="handleEstimateUpdate"
        @error="handleError"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useToast } from 'vue-toastification';
import EstimateFromAssessment from '@/components/estimates/EstimateFromAssessment.vue';
import estimateService from '@/services/estimates.service';
import projectsService from '@/services/projects.service';

const router = useRouter();
const toast = useToast();

// State
const assessment = ref({});
const assessmentId = ref('');
const isLoading = ref(false);
const loadingMessage = ref('Loading...');
const error = ref(null);
const estimateItems = ref([]);
const sourceMap = ref({});
const showProjectModal = ref(false);
const availableProjects = ref([]);
const isLoadingProjects = ref(false);

// --- Methods ---

/**
 * Load assessment data selection modal
 */
const loadAssessment = async () => {
  showProjectModal.value = true;
  await refreshProjects();
};

/**
 * Refresh the list of available assessment projects
 */
const refreshProjects = async () => {
  isLoadingProjects.value = true;
  
  try {
    const response = await projectsService.getAllProjects({ type: 'assessment' });
    
    if (response.success && response.data) {
      // Convert projects to camelCase, filter, and sort
      const rawProjects = Array.isArray(response.data) ? response.data : [];
      availableProjects.value = rawProjects
        .map(p => toCamelCase(p)) // Convert to camelCase
        .filter(p => p.type === 'assessment')
        .sort((a, b) => new Date(b.scheduledDate) - new Date(a.scheduledDate)); // Sort using camelCase
    } else {
      toast.error(response.message || 'Failed to load assessment projects');
    }
  } catch (err) {
    console.error('Error loading projects:', err);
    toast.error('Failed to load assessment projects');
  } finally {
    isLoadingProjects.value = false;
  }
};

/**
 * Select a project from the modal
 */
const selectProject = async (project) => {
  assessmentId.value = project.id;
  showProjectModal.value = false;
  
  // Load assessment data
  isLoading.value = true;
  loadingMessage.value = 'Loading assessment data...';
  
  try {
    const response = await estimateService.getAssessmentData(project.id);
    
    if (response.success && response.data) {
      // Convert assessment data to camelCase
      assessment.value = toCamelCase(response.data);
      // Store the selected project (already camelCased from refreshProjects)
      assessment.value.project = project;
      toast.success('Assessment data loaded successfully');
    } else {
      error.value = response.message || 'Failed to load assessment data';
      toast.error(error.value);
    }
  } catch (err) {
    console.error('Error loading assessment data:', err);
    error.value = err.response?.data?.message || err.message || 'Failed to load assessment data';
    toast.error(error.value);
  } finally {
    isLoading.value = false;
  }
};

/**
 * Handle estimate update from EstimateFromAssessment component
 */
const handleEstimateUpdate = (data) => {
  estimateItems.value = data.estimateItems;
  sourceMap.value = data.sourceMap;
};

/**
 * Handle error from EstimateFromAssessment component
 */
const handleError = (errorMessage) => {
  error.value = errorMessage;
  toast.error(errorMessage);
};

/**
 * Create a new estimate from generated items
 */
const createEstimate = async () => {
  if (estimateItems.value.length === 0) {
    toast.error('No estimate items generated');
    return;
  }
  
  isLoading.value = true;
  loadingMessage.value = 'Creating estimate...';
  
  try {
    // Find the client from the assessment
    let clientId = null;
    
    // Check for different possible client ID fields in the project data
    if (assessment.value && assessment.value.project) {
      // Try client_id first (matches database column)
      if (assessment.value.project.client_id) {
        clientId = assessment.value.project.client_id;
      }
      // Fall back to client_fk_id if available
      else if (assessment.value.project.client_fk_id) {
        clientId = assessment.value.project.client_fk_id;
      }
    }
    
    // Debug the client ID
    console.log('Using client ID:', clientId);
    console.log('Project data:', assessment.value.project);
    
    if (!clientId) {
      toast.error('No client ID found in the project data. Cannot create estimate.');
      isLoading.value = false;
      return;
    }
    
    // Format data for the create estimate API
    const estimateData = {
      items: estimateItems.value.map(item => ({
        description: item.description,
        quantity: parseFloat(item.quantity),
        unit: item.unit,
        unitPrice: parseFloat(item.unitPrice),
        total: parseFloat(item.total),
        sourceType: item.sourceType,
        sourceId: item.sourceId
      })),
      sourceMap: sourceMap.value,
      clientId: clientId,
      sourceProjectId: assessmentId.value
    };
    
    // Convert payload to snake_case before sending
    const snakeCaseEstimateData = toSnakeCase(estimateData);
    
    // Save the estimate
    const response = await estimateService.saveEstimateWithSourceMap(snakeCaseEstimateData);
    
    if (response.success && response.data) {
      toast.success('Estimate created successfully');
      
      // Navigate to the edit estimate page
      router.push({
        path: `/invoicing/estimate/${response.data.id}/edit`
      });
    } else {
      error.value = response.message || 'Failed to create estimate';
      toast.error(error.value);
    }
  } catch (err) {
    console.error('Error creating estimate:', err);
    error.value = err.response?.data?.message || err.message || 'Failed to create estimate';
    toast.error(error.value);
  } finally {
    isLoading.value = false;
  }
};

// Helper functions
const formatDate = (dateString) => {
  if (!dateString) return 'Unknown Date';
  
  const date = new Date(dateString);
  return date.toLocaleDateString();
};

const formatStatus = (status) => {
  if (!status) return 'Unknown';
  
  // Convert snake_case to Title Case
  return status
    .split('_')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
};

const truncateText = (text, maxLength) => {
  if (!text) return '';
  if (text.length <= maxLength) return text;
  return text.substring(0, maxLength) + '...';
};
</script>

<style scoped>
/* Add any component-specific styles here */
</style>