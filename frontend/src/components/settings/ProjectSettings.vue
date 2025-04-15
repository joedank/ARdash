<template>
  <div class="project-settings">
    <!-- Alert Messages Handled by useErrorHandler -->
    <!-- Project Management Controls -->
    <div class="flex justify-end mb-6">

      <BaseButton
        variant="primary"
        @click="navigateToCreateProject"
        class="flex items-center space-x-2"
      >
        <span>Add Project</span>
        <BaseIcon name="plus" class="w-4 h-4" />
      </BaseButton>
    </div>

    <!-- Search and Filters -->
    <div class="flex flex-col md:flex-row items-center justify-between mb-6 gap-4">
      <div class="relative w-full md:w-64">
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <BaseIcon name="search" class="h-5 w-5 text-gray-400" />
        </div>
        <input
          type="text"
          v-model="searchQuery"
          placeholder="Search projects..."
          class="pl-10 pr-4 py-2 w-full border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-600 focus:border-transparent"
          @input="handleSearch"
        />
      </div>

      <div class="flex items-center space-x-4 w-full md:w-auto">
        <div class="flex items-center space-x-2">
          <input
            type="checkbox"
            id="showConverted"
            v-model="showConvertedProjects"
            class="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500 dark:border-gray-600 dark:bg-gray-700 dark:ring-offset-gray-800 dark:focus:ring-blue-600"
          />
          <label for="showConverted" class="text-sm text-gray-700 dark:text-gray-300">
            Show converted assessments
          </label>
        </div>
      </div>

      <div class="flex items-center space-x-2 w-full md:w-auto">
        <BaseSelect
          v-model="filterType"
          class="w-full md:w-40"
          :options="filterTypeOptions"
          @update:modelValue="handleFilter"
        />
        <BaseSelect
          v-model="filterStatus"
          class="w-full md:w-40"
          :options="filterStatusOptions"
          @update:modelValue="handleFilter"
        />
        <BaseButton
          variant="outline"
          size="sm"
          @click="resetFilters"
          class="whitespace-nowrap"
        >
          <BaseIcon name="refresh-cw" class="w-4 h-4 mr-1" />
          Reset
        </BaseButton>
      </div>
    </div>

    <!-- Projects Table / Grid View -->
    <BaseCard variant="default" class="mb-6">
      <!-- Table View -->
      <ProjectTableResponsive
        v-if="viewMode === 'table'"
        :filtered-projects="paginatedProjects"
        :loading="loading"
        :sort-key="sortConfig.key"
        :sort-order="sortConfig.order"
        :current-page="currentPage"
        :total-pages="totalPages"
        :total-items="totalItems"
        :items-per-page="itemsPerPage"
        :format-project-type="formatProjectType"
        :format-project-status="formatStatus"
        :get-status-badge-variant="getStatusVariant"
        :get-client-name="getClientName"
        v-model:columns-display="columnsDisplay"
        @view-change="handleViewChange"
        @sort-change="handleSort"
        @page-change="handlePageChange"
        @row-click="handleRowClick"
        @edit="editProject"
        @delete="confirmDelete"
        @reset-filters="resetFilters"
      />

      <!-- Grid View -->
      <ProjectTableCompact
        v-else
        :filtered-projects="paginatedProjects"
        :current-page="currentPage"
        :total-pages="totalPages"
        :total-items="totalItems"
        :items-per-page="itemsPerPage"
        :format-project-type="formatProjectType"
        :format-project-status="formatStatus"
        :get-status-badge-variant="getStatusVariant"
        :get-client-name="getClientName"
        @view-change="handleViewChange"
        @page-change="handlePageChange"
        @row-click="handleRowClick"
        @edit="editProject"
        @delete="confirmDelete"
        @reset-filters="resetFilters"
      />
    </BaseCard>

    <!-- Create Project Modal Removed -->

    <!-- Edit Project Modal -->
    <BaseModal
      v-model="showEditProjectModal"
      title="Edit Project"
      persistent
    >
      <form @submit.prevent="updateProject">
        <div class="space-y-4">
          <!-- Client Selection -->
          <ClientSelector
            id="edit-client"
            v-model="editingProject.clientId"
            :required="true"
            label="Client"
          />

          <!-- Estimate Selection -->
          <EstimateSelector
            id="edit-estimate"
            v-model="editingProject.estimate"
            :clientId="getClientIdValue(editingProject.clientId)"
            :label="getEditEstimateSelectorLabel"
            :placeholder-text="getEditEstimatePlaceholderText"
            :class="{'border-2 border-green-300 dark:border-green-700 rounded p-2': editingProject.type === 'active'}"
          />

          <!-- Project Type -->
          <BaseFormGroup
            label="Project Type"
            input-id="edit-project-type"
            helper-text="Select the type of project"
          >
            <BaseSelect
              id="edit-project-type"
              v-model="editingProject.type"
              :options="typeOptions"
              :required="true"
            />
          </BaseFormGroup>

          <!-- Project Status -->
          <BaseFormGroup
            label="Status"
            input-id="edit-project-status"
            helper-text="Select the project status"
          >
            <BaseSelect
              id="edit-project-status"
              v-model="editingProject.status"
              :options="statusOptions"
              :required="true"
            />
          </BaseFormGroup>

          <!-- Scheduled Date -->
          <BaseFormGroup
            label="Scheduled Date"
            input-id="edit-scheduled-date"
            helper-text="When is this project scheduled for?"
          >
            <BaseInput
              id="edit-scheduled-date"
              v-model="editingProject.scheduledDate"
              type="date"
              :required="true"
            />
          </BaseFormGroup>

          <!-- Project Scope Field Removed -->
        </div>

        <div class="flex justify-end space-x-2 mt-6">
          <BaseButton
            variant="outline"
            @click="showEditProjectModal = false"
          >
            Cancel
          </BaseButton>
          <BaseButton
            type="submit"
            variant="primary"
            :loading="submitting"
          >
            Update Project
          </BaseButton>
        </div>
      </form>
    </BaseModal>

    <!-- Delete Confirmation Modal -->
    <BaseModal
      v-model="showDeleteModal"
      title="Confirm Delete"
      persistent
    >
      <div class="mb-6">
        <p class="text-gray-700 dark:text-gray-300">
          Are you sure you want to delete this project?
        </p>
        
        <!-- Detailed Dependencies Information -->
        <div v-if="projectDependencies && projectDependencies.hasDependencies" class="mt-4 p-3 bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 rounded-lg">
          <h4 class="font-medium text-amber-800 dark:text-amber-400 mb-2">Deletion Impact</h4>
          <div class="text-amber-700 dark:text-amber-300 whitespace-pre-line text-sm">
            {{ detailedDeleteMessage }}
          </div>
        </div>
        
        <!-- Deletion Options -->
        <div v-if="projectDependencies && projectDependencies.hasDependencies" class="mt-5 space-y-3">
          <h4 class="font-medium text-gray-800 dark:text-gray-200">Deletion Options</h4>
          
          <div class="flex items-start space-x-2">
            <input
              type="radio"
              id="option-break-references"
              v-model="deletionOption"
              value="break"
              class="mt-1"
            />
            <div>
              <label for="option-break-references" class="font-medium text-gray-700 dark:text-gray-300">
                Break references only
              </label>
              <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
                Disconnects this project from related data without deleting other records.
                Related assessments, jobs, and estimates will remain in the system.
              </p>
            </div>
          </div>
          
          <div class="flex items-start space-x-2">
            <input
              type="radio"
              id="option-delete-all"
              v-model="deletionOption"
              value="all"
              class="mt-1"
            />
            <div>
              <label for="option-delete-all" class="font-medium text-gray-700 dark:text-gray-300">
                Delete everything
              </label>
              <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
                <span class="text-red-600 dark:text-red-400 font-medium">Warning:</span> This will delete this project AND all related records,
                including linked assessments, jobs, estimates, photos, and inspections.
              </p>
            </div>
          </div>
        </div>
        
        <p class="text-sm text-red-600 dark:text-red-400 mt-4 font-medium">
          This action cannot be undone.
        </p>
      </div>

      <div class="flex justify-end space-x-2">
        <BaseButton
          variant="outline"
          @click="showDeleteModal = false"
        >
          Cancel
        </BaseButton>
        <BaseButton
          variant="danger"
          :loading="submitting"
          @click="deleteProject"
        >
          Delete Project
        </BaseButton>
      </div>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed, watch } from 'vue';
import { useRouter } from 'vue-router';
// Use standardized service
import projectsService from '@/services/standardized-projects.service.js';
import useErrorHandler from '@/composables/useErrorHandler.js'; // Import error handler

// Import components
// BaseAlert removed as errors are handled by useErrorHandler
import BaseButton from '@/components/base/BaseButton.vue';
import BaseIcon from '@/components/base/BaseIcon.vue';
import BaseLoader from '@/components/feedback/BaseLoader.vue';
import BaseBadge from '@/components/data-display/BaseBadge.vue';
import BaseModal from '@/components/overlays/BaseModal.vue';
import BaseFormGroup from '@/components/form/BaseFormGroup.vue';
import BaseInput from '@/components/form/BaseInput.vue';
import BaseSelect from '@/components/form/BaseSelect.vue';
import BaseCard from '@/components/data-display/BaseCard.vue';
// BaseTextarea removed as scope field is removed
import ClientSelector from '@/components/invoicing/ClientSelector.vue';
import EstimateSelector from '@/components/invoicing/EstimateSelector.vue';

// Import Custom Components
import ProjectTableResponsive from './project-tables/ProjectTableResponsive.vue';
import ProjectTableCompact from './project-tables/ProjectTableCompact.vue';

const router = useRouter();
const { handleError } = useErrorHandler(); // Instantiate error handler

// State variables
const loading = ref(false);
const submitting = ref(false);
const projects = ref([]);
// alertMessage and alertVariant removed - handled by useErrorHandler
const searchQuery = ref('');
const filterType = ref('all');
const filterStatus = ref('all');
const viewMode = ref('table'); // 'table' or 'grid'
const columnsDisplay = ref('default'); // 'default', 'compact', 'full'
const showConvertedProjects = ref(false); // Toggle for showing converted assessments

// Pagination
const currentPage = ref(1);
const itemsPerPage = ref(10);
const totalItems = ref(0);

// Sorting
const sortConfig = ref({ key: 'client', order: 'asc' });

// Modal states
// const showCreateProjectModal = ref(false); // Removed
const showEditProjectModal = ref(false);
const showDeleteModal = ref(false);
const projectToDelete = ref(null);
const projectDependencies = ref(null);
const detailedDeleteMessage = ref('');
const deletionOption = ref('break'); // Default to just breaking references
// const newProject = reactive({ // Removed
//   clientId: null,
//   estimate: null, // Store the whole estimate object if needed, or just estimateId
//   type: 'assessment',
//   status: 'pending',
//   scheduledDate: new Date().toISOString().split('T')[0] // Today's date in YYYY-MM-DD format
// });

const editingProject = reactive({
  id: '',
  clientId: '',
  estimate: null, // Store the whole estimate object if needed, or just estimateId
  type: 'assessment',
  status: 'pending',
  scheduledDate: ''
});

// Options for selects
const typeOptions = [
  { value: 'assessment', label: 'Assessment' },
  { value: 'active', label: 'Active Project' }
];

const statusOptions = [
  { value: 'pending', label: 'Pending' },
  { value: 'upcoming', label: 'Upcoming' },
  { value: 'in_progress', label: 'In Progress' },
  { value: 'completed', label: 'Completed' }
];

// For filters
const filterTypeOptions = [
  { value: 'all', label: 'All Types' },
  { value: 'assessment', label: 'Assessment' },
  { value: 'active', label: 'Active Project' }
];

const filterStatusOptions = [
  { value: 'all', label: 'All Statuses' },
  { value: 'pending', label: 'Pending' },
  { value: 'upcoming', label: 'Upcoming' },
  { value: 'in_progress', label: 'In Progress' },
  { value: 'completed', label: 'Completed' }
];

// Format status for display
const formatStatus = (status) => {
  switch (status) {
    case 'pending': return 'Pending';
    case 'upcoming': return 'Upcoming';
    case 'in_progress': return 'In Progress';
    case 'completed': return 'Completed';
    default: return status;
  }
};

// Get status variant for badge color
const getStatusVariant = (status) => {
  switch (status) {
    case 'pending': return 'warning';
    case 'upcoming': return 'primary';
    case 'in_progress': return 'info';
    case 'completed': return 'success';
    default: return 'default';
  }
};

// Format project type for display
const formatProjectType = (type) => {
  switch (type) {
    case 'assessment': return 'Assessment';
    case 'active': return 'Active Project';
    default: return type;
  }
};

// Format date as "Apr 2, 2025"
const formatDate = (dateString) => {
  if (!dateString) return 'N/A';

  const date = new Date(dateString);
  // Add timezone offset to interpret date as local
  const offset = date.getTimezoneOffset() * 60000;
  const localDate = new Date(date.getTime() + offset);

  return localDate.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  });
};


// Format estimate status
const formatEstimateStatus = (status) => {
  if (!status) return '';

  switch (status) {
    case 'draft': return 'Draft';
    case 'sent': return 'Sent';
    case 'accepted': return 'Accepted';
    case 'rejected': return 'Rejected';
    default: return status.charAt(0).toUpperCase() + status.slice(1);
  }
};

// Get estimate status badge classes
const getEstimateStatusClasses = (status) => {
  switch (status) {
    case 'draft':
      return 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
    case 'sent':
      return 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300';
    case 'accepted':
      return 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300';
    case 'rejected':
      return 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300';
    default:
      return 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
  }
};

// Dynamic labels for estimate selector based on project type - Removed for Create Project
// const getEstimateSelectorLabel = computed(() => {
//   return newProject.type === 'active'
//     ? 'Link Estimate (Recommended for Active Projects)'
//     : 'Link Estimate';
// });

// const getEstimatePlaceholderText = computed(() => {
//   return newProject.type === 'active'
//     ? 'Select an estimate for this active project'
//     : 'Select an estimate for this project';
// });

const getEditEstimateSelectorLabel = computed(() => {
  return editingProject.type === 'active'
    ? 'Link Estimate (Recommended for Active Projects)'
    : 'Link Estimate';
});

const getEditEstimatePlaceholderText = computed(() => {
  return editingProject.type === 'active'
    ? 'Select an estimate for this active project'
    : 'Select an estimate for this project';
});

// Get client name with fallback (assuming client object is camelCase)
const getClientName = (client) => {
  if (!client) return 'Unknown Client';
  return client.displayName || `Client #${client.id}` || 'Unknown Client';
};

// Load all projects with optional filters
const loadProjects = async () => {
  loading.value = true;
  try {
    const params = {
      includeConverted: showConvertedProjects.value
    };
    
    if (filterType.value !== 'all') params.type = filterType.value;
    if (filterStatus.value !== 'all') params.status = filterStatus.value;

    const response = await projectsService.getAll(params); // Use BaseService getAll

    if (response.success) {
      projects.value = response.data || [];
      totalItems.value = projects.value.length;
    } else {
      handleError(new Error(response.message || 'Failed to load projects'), 'Failed to load projects.');
      projects.value = [];
      totalItems.value = 0;
    }
  } catch (err) {
    handleError(err, 'Error loading projects.');
    projects.value = [];
    totalItems.value = 0;
  } finally {
    loading.value = false;
  }
};

// Helper function to extract client ID (handles object or string)
const getClientIdValue = (clientInput) => {
  if (!clientInput) return null;
  return typeof clientInput === 'string' ? clientInput : clientInput.id;
};

// Create new project function removed

// Open create project modal function removed

// Open edit modal with project data (assume project data is camelCase)
const editProject = (project) => {
  console.log('Editing project:', project); // Debug log
  
  // Reset the form before populating with new data
  Object.assign(editingProject, {
    id: '',
    clientId: null,
    estimate: null,
    type: 'assessment',
    status: 'pending',
    scheduledDate: ''
  });
  
  // Now populate with project data
  Object.assign(editingProject, {
    id: project.id,
    // For the clientId field, we need to pass the complete client object
    // The ClientSelector component expects a full client object, not just an ID
    clientId: project.client || null,
    estimate: project.estimate || null,
    type: project.type || 'assessment',
    status: project.status || 'pending',
    scheduledDate: project.scheduledDate ? new Date(project.scheduledDate).toISOString().split('T')[0] : ''
  });
  
  console.log('Editing project form data:', editingProject); // Debug log
  showEditProjectModal.value = true;
};

// Update project
const updateProject = async () => {
  submitting.value = true;
  try {
    // Prepare data for API (already camelCase)
    const projectData = {
      clientId: getClientIdValue(editingProject.clientId),
      estimateId: editingProject.estimate ? editingProject.estimate.id : null, // Send only ID
      type: editingProject.type,
      status: editingProject.status,
      scheduledDate: editingProject.scheduledDate
    };

    const response = await projectsService.update(editingProject.id, projectData); // Use BaseService update

    if (response.success) {
      showEditProjectModal.value = false;
      handleError({ message: 'Project updated successfully!' }, 'Project updated successfully!'); // Use handleError for success toast
      await loadProjects();
    } else {
       handleError(new Error(response.message || 'Failed to update project'), 'Failed to update project.');
    }
  } catch (err) {
    handleError(err, 'Error updating project.');
  } finally {
    submitting.value = false;
  }
};

// Open delete confirmation modal
const confirmDelete = async (project) => {
  projectToDelete.value = project;
  showDeleteModal.value = true;
  deletionOption.value = 'break'; // Reset to default option
  
  try {
    // Check for dependencies before showing confirmation
    const dependencyResponse = await projectsService.checkDependencies(project.id);
    
    if (dependencyResponse.success && dependencyResponse.data) {
      const deps = dependencyResponse.data;
      projectDependencies.value = deps;
      
      // Build detailed confirmation message
      if (deps.hasDependencies) {
        let message = 'Warning: This project has related data that will be affected by deletion:\n\n';
        
        if (deps.hasRelatedJob) {
          message += `• This assessment is linked to an active job${deps.relatedJob?.client?.displayName ? ' for ' + deps.relatedJob.client.displayName : ''}.\n`;
        }
        
        if (deps.hasRelatedAssessment) {
          message += `• This job is linked to an assessment${deps.relatedAssessment?.client?.displayName ? ' for ' + deps.relatedAssessment.client.displayName : ''}.\n`;
        }
        
        if (deps.inspectionsCount > 0) {
          message += `• ${deps.inspectionsCount} inspection${deps.inspectionsCount > 1 ? 's' : ''} will be permanently deleted.\n`;
        }
        
        if (deps.photosCount > 0) {
          message += `• ${deps.photosCount} photo${deps.photosCount > 1 ? 's' : ''} will be permanently deleted.\n`;
        }
        
        if (deps.estimatesCount > 0) {
          message += `• ${deps.estimatesCount} estimate${deps.estimatesCount > 1 ? 's' : ''} will remain but lose their connection to this project.\n`;
        }
        
        detailedDeleteMessage.value = message;
      } else {
        detailedDeleteMessage.value = '';
      }
    }
  } catch (err) {
    handleError(err, 'Error checking project dependencies.');
    detailedDeleteMessage.value = 'Could not check dependencies. Use caution when deleting.';
  }
};

// Delete project
const deleteProject = async () => {
  if (!projectToDelete.value) return;
  submitting.value = true;
  try {
    // Use appropriate deletion option based on user selection
    const deleteReferences = deletionOption.value === 'all';
    
    const response = await projectsService.deleteProject(projectToDelete.value.id, deleteReferences);

    if (response.success) {
      showDeleteModal.value = false;
      projectToDelete.value = null;
      handleError({ message: 'Project deleted successfully!' }, 'Project deleted successfully!'); // Use handleError for success toast
      await loadProjects();
    } else {
       showDeleteModal.value = false; // Close modal even on failure
       handleError(new Error(response.message || 'Failed to delete project'), 'Failed to delete project.');
    }
  } catch (err) {
    showDeleteModal.value = false; // Close modal on exception
    handleError(err, 'Error deleting project.');
  } finally {
    submitting.value = false;
  }
};

// Navigate to project detail view
const viewProject = (id) => {
  router.push(`/projects/${id}`);
};

// Navigate to create project page
const navigateToCreateProject = () => {
  router.push('/projects/create');
};

// Watch for project type changes to enhance UX for estimate selection - Removed for Create Project
// watch(() => newProject.type, (newType) => {
//   // console.log('Project type changed to:', newType);
//   // Logic removed as computed properties handle UI changes
// });

watch(() => editingProject.type, (newType) => {
  // console.log('Editing project type changed to:', newType);
   // Logic removed as computed properties handle UI changes
});

// Computed properties for pagination
const totalPages = computed(() => {
  return Math.ceil(filteredProjects.value.length / itemsPerPage.value) || 1;
});

const filteredProjects = computed(() => {
  if (!searchQuery.value.trim() && filterType.value === 'all' && filterStatus.value === 'all') {
    return projects.value;
  }

  return projects.value.filter(project => {
    // Search query filter
    const query = searchQuery.value.toLowerCase().trim();
    const matchesSearch = !query ||
      (project.client && project.client.displayName && project.client.displayName.toLowerCase().includes(query)) ||
      (project.client && project.client.email && project.client.email.toLowerCase().includes(query));

    // Type filter
    const matchesType = filterType.value === 'all' || project.type === filterType.value;

    // Status filter
    const matchesStatus = filterStatus.value === 'all' || project.status === filterStatus.value;

    return matchesSearch && matchesType && matchesStatus;
  });
});

const paginatedProjects = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value;
  const end = start + itemsPerPage.value;
  return filteredProjects.value.slice(start, end);
});

// Handle search input
function handleSearch() {
  currentPage.value = 1; // Reset to first page on search
}

// Handle filter changes
function handleFilter() {
  currentPage.value = 1; // Reset to first page on filter change
}

// Handle view mode change
function handleViewChange(newMode) {
  viewMode.value = newMode;
}

// Handle sort change
function handleSort(newSortConfig) {
  sortConfig.value = newSortConfig;
  currentPage.value = 1; // Reset to first page on sort
}

// Handle page change
function handlePageChange(newPage) {
  currentPage.value = newPage;
}

// Handle row click
function handleRowClick(project) {
  viewProject(project.id);
}

// Reset filters
function resetFilters() {
  searchQuery.value = '';
  filterType.value = 'all';
  filterStatus.value = 'all';
  currentPage.value = 1;
}

// Load projects on component mount
onMounted(() => {
  // Set initial value for totalItems to prevent undefined during initial render
  totalItems.value = 0;
  loadProjects();
});

// Watch for showConvertedProjects changes to reload projects
watch(showConvertedProjects, () => {
  loadProjects();
});

// Watch for filtered projects changes to update pagination
watch(filteredProjects, (newProjects) => {
  totalItems.value = newProjects.length;
  const maxPossiblePage = Math.max(1, Math.ceil(newProjects.length / itemsPerPage.value));
  if (currentPage.value > maxPossiblePage) {
    currentPage.value = maxPossiblePage;
  }
});
</script>
