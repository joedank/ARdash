<template>
  <div class="project-settings">
    <!-- Alert Messages Handled by useErrorHandler -->
    <!-- Project Management Controls -->
    <div class="flex flex-col md:flex-row items-start md:items-center justify-between mb-6">
      <div class="flex flex-col mb-4 md:mb-0">
        <h2 class="text-lg font-medium text-gray-900 dark:text-white">Project Management</h2>
        <p class="text-sm text-gray-500 dark:text-gray-400">Manage your project assessments and active jobs</p>
      </div>

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
          <ClientSelector>
            id="edit-client"
            v-model="editingProject.clientId" <!-- camelCase -->
            :required="true"
            label="Client"
          </ClientSelector>

          <!-- Estimate Selection -->
          <EstimateSelector>
            id="edit-estimate"
            v-model="editingProject.estimate"
            :clientId="getClientIdValue(editingProject.clientId)" <!-- camelCase -->
            :label="getEditEstimateSelectorLabel"
            :placeholder-text="getEditEstimatePlaceholderText"
            :class="{'border-2 border-green-300 dark:border-green-700 rounded p-2': editingProject.type === 'active'}"
          </EstimateSelector>

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
          <BaseFormGroup>
            label="Scheduled Date"
            input-id="edit-scheduled-date"
            helper-text="When is this project scheduled for?"
          </BaseFormGroup>
            <BaseInput>
              id="edit-scheduled-date"
              v-model="editingProject.scheduledDate" <!-- camelCase -->
              type="date"
              :required="true"
            </BaseInput>

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
        <p v-if="projectHasRelationships" class="mt-2 text-amber-600 dark:text-amber-400">
          <strong>Note:</strong> This project has associated inspections or photos. Deleting it will also remove all related inspections and photos.
        </p>
        <p class="text-sm text-red-600 dark:text-red-400 mt-2">
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
const projectHasRelationships = ref(false);

// Form data (using camelCase)
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

const projectToDelete = ref(null);

// Options for selects
const typeOptions = [
  { value: 'assessment', label: 'Assessment' },
  { value: 'active', label: 'Active Project' }
];

const statusOptions = [
  { value: 'pending', label: 'Pending' },
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
  { value: 'in_progress', label: 'In Progress' },
  { value: 'completed', label: 'Completed' }
];

// Format status for display
const formatStatus = (status) => {
  switch (status) {
    case 'pending': return 'Pending';
    case 'in_progress': return 'In Progress';
    case 'completed': return 'Completed';
    default: return status;
  }
};

// Get status variant for badge color
const getStatusVariant = (status) => {
  switch (status) {
    case 'pending': return 'warning';
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
    const params = {};
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
  Object.assign(editingProject, {
    id: project.id,
    clientId: project.clientId || (project.client ? project.client.id : ''), // Handle client object or just ID
    estimate: project.estimate || null, // Assume estimate object is passed or null
    type: project.type || 'assessment',
    status: project.status || 'pending',
    scheduledDate: project.scheduledDate ? new Date(project.scheduledDate).toISOString().split('T')[0] : ''
  });
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
const confirmDelete = (project) => {
  projectToDelete.value = project;
  // Check if project has associated inspections or photos (assuming camelCase)
  projectHasRelationships.value =
    (project.inspections && project.inspections.length > 0) || // Corrected operator
    (project.photos && project.photos.length > 0); // Corrected operator
  showDeleteModal.value = true;
};

// Delete project
const deleteProject = async () => {
  if (!projectToDelete.value) return;
  submitting.value = true;
  try {
    const response = await projectsService.delete(projectToDelete.value.id); // Use BaseService delete

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

// Watch for filtered projects changes to update pagination
watch(filteredProjects, (newProjects) => {
  totalItems.value = newProjects.length;
  const maxPossiblePage = Math.max(1, Math.ceil(newProjects.length / itemsPerPage.value));
  if (currentPage.value > maxPossiblePage) {
    currentPage.value = maxPossiblePage;
  }
});
</script>
