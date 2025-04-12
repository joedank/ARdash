<template>
  <div class="project-settings">
    <!-- Alert Messages -->
    <BaseAlert
      v-if="alertMessage"
      :variant="alertVariant"
      :message="alertMessage"
      dismissible
      class="mb-4"
      @close="alertMessage = ''"
    />

    <!-- Project Management Controls -->
    <div class="flex flex-col md:flex-row items-start md:items-center justify-between mb-6">
      <div class="flex flex-col mb-4 md:mb-0">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white">Projects</h3>
        <p class="text-sm text-gray-500 dark:text-gray-400">Manage your project assessments and active jobs</p>
      </div>
      
      <div class="flex items-center">
        <BaseSelect
          v-model="filterType"
          class="w-40 mr-2"
          :options="filterTypeOptions"
          @update:modelValue="loadProjects"
        />
        <BaseSelect
          v-model="filterStatus"
          class="w-40 mr-2"
          :options="filterStatusOptions"
          @update:modelValue="loadProjects"
        />
        <BaseButton
          variant="primary"
          @click="openCreateProjectModal"
        >
          <BaseIcon name="plus" class="w-4 h-4 mr-2" />
          New
        </BaseButton>
      </div>
    </div>

    <!-- Projects List -->
    <div class="bg-white dark:bg-gray-800 rounded-lg overflow-hidden shadow mb-6">
      <div v-if="loading" class="p-4 text-center">
        <BaseLoader />
      </div>
      
      <div v-else-if="projects.length === 0" class="p-8 text-center">
        <div class="text-gray-500 dark:text-gray-400">
          No projects found with the selected filters
        </div>
      </div>
      
      <table v-else class="min-w-full">
        <thead class="bg-gray-50 dark:bg-gray-700 text-left">
          <tr>
            <th scope="col" class="px-6 py-3 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              Client
            </th>
            <th scope="col" class="px-6 py-3 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              Type
            </th>
            <th scope="col" class="px-6 py-3 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              Status
            </th>
            <th scope="col" class="px-6 py-3 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              Scheduled Date
            </th>
            <th scope="col" class="px-6 py-3 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              Estimate
            </th>
            <th scope="col" class="px-6 py-3 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              Actions
            </th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
          <tr v-for="project in projects" :key="project.id" class="hover:bg-gray-50 dark:hover:bg-gray-700">
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm font-medium text-gray-900 dark:text-white">
                {{ getClientName(project.client) }}
              </div>
              <div v-if="project.client" class="text-xs text-gray-500 dark:text-gray-400">
                {{ project.client.email || 'No email' }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <BaseBadge :variant="project.type === 'assessment' ? 'red' : 'green'" size="sm">
                {{ formatProjectType(project.type) }}
              </BaseBadge>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <BaseBadge :variant="getStatusVariant(project.status)" size="sm">
                {{ formatStatus(project.status) }}
              </BaseBadge>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-900 dark:text-white">
                {{ formatDate(project.scheduled_date) }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div v-if="project.estimate" class="text-sm text-gray-900 dark:text-white">
                {{ project.estimate.number }}
                <span class="text-xs px-2 py-0.5 rounded-full ml-1"
                  :class="getEstimateStatusClasses(project.estimate.status)">
                  {{ formatEstimateStatus(project.estimate.status) }}
                </span>
              </div>
              <div v-else class="text-sm text-gray-500 dark:text-gray-400 italic">
                Not linked
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="flex items-center space-x-2">
                <button 
                  @click="viewProject(project.id)"
                  class="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300"
                  title="View Project"
                >
                  <BaseIcon name="eye" class="w-5 h-5" />
                </button>
                <button 
                  @click="editProject(project)"
                  class="text-indigo-600 hover:text-indigo-800 dark:text-indigo-400 dark:hover:text-indigo-300"
                  title="Edit Project"
                >
                  <BaseIcon name="pencil" class="w-5 h-5" />
                </button>
                <button 
                  @click="confirmDelete(project)"
                  class="text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300"
                  title="Delete Project"
                >
                  <BaseIcon name="trash" class="w-5 h-5" />
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination Controls -->
    <div class="flex justify-between items-center">
      <div class="text-sm text-gray-500 dark:text-gray-400">
        Showing {{ projects.length }} projects
      </div>
      
      <!-- Future pagination controls can be added here -->
    </div>

    <!-- Create Project Modal -->
    <BaseModal
      v-model="showCreateProjectModal"
      title="Create New Project"
      persistent
    >
      <form @submit.prevent="createProject">
        <div class="space-y-4">
          <!-- Client Selection -->
          <ClientSelector
            id="client"
            v-model="newProject.client_id"
            :required="true"
            label="Client"
          />
          
          <!-- Estimate Selection -->
          <EstimateSelector
            id="estimate"
            v-model="newProject.estimate"
            :clientId="getClientIdValue(newProject.client_id)"
            :label="getEstimateSelectorLabel"
            :placeholder-text="getEstimatePlaceholderText"
            :class="{'border-2 border-green-300 dark:border-green-700 rounded p-2': newProject.type === 'active'}"
          />
          
          <!-- Project Type -->
          <BaseFormGroup
            label="Project Type"
            input-id="project-type"
            helper-text="Select the type of project"
          >
            <BaseSelect
              id="project-type"
              v-model="newProject.type"
              :options="typeOptions"
              :required="true"
            />
          </BaseFormGroup>
          
          <!-- Project Status -->
          <BaseFormGroup
            label="Status"
            input-id="project-status"
            helper-text="Select the project status"
          >
            <BaseSelect
              id="project-status"
              v-model="newProject.status"
              :options="statusOptions"
              :required="true"
            />
          </BaseFormGroup>
          
          <!-- Scheduled Date -->
          <BaseFormGroup
            label="Scheduled Date"
            input-id="scheduled-date"
            helper-text="When is this project scheduled for?"
          >
            <BaseInput
              id="scheduled-date"
              v-model="newProject.scheduled_date"
              type="date"
              :required="true"
            />
          </BaseFormGroup>
          
          <!-- Project Scope Field Removed -->
        </div>
        
        <div class="flex justify-end space-x-2 mt-6">
          <BaseButton
            variant="outline"
            @click="showCreateProjectModal = false"
          >
            Cancel
          </BaseButton>
          <BaseButton
            type="submit"
            variant="primary"
            :loading="submitting"
          >
            Create Project
          </BaseButton>
        </div>
      </form>
    </BaseModal>

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
            v-model="editingProject.client_id"
            :required="true"
            label="Client"
          />
          
          <!-- Estimate Selection -->
          <EstimateSelector
            id="edit-estimate"
            v-model="editingProject.estimate"
            :clientId="getClientIdValue(editingProject.client_id)"
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
              v-model="editingProject.scheduled_date"
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
import projectsService from '@/services/projects.service';

// Import components
import BaseAlert from '@/components/feedback/BaseAlert.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseIcon from '@/components/base/BaseIcon.vue';
import BaseLoader from '@/components/feedback/BaseLoader.vue';
import BaseBadge from '@/components/data-display/BaseBadge.vue';
import BaseModal from '@/components/overlays/BaseModal.vue';
import BaseFormGroup from '@/components/form/BaseFormGroup.vue';
import BaseInput from '@/components/form/BaseInput.vue';
import BaseSelect from '@/components/form/BaseSelect.vue';
import BaseTextarea from '@/components/form/BaseTextarea.vue';
import ClientSelector from '@/components/invoicing/ClientSelector.vue';
import EstimateSelector from '@/components/invoicing/EstimateSelector.vue';

const router = useRouter();

// State variables
const loading = ref(false);
const submitting = ref(false);
const projects = ref([]);
const alertMessage = ref('');
const alertVariant = ref('success');
const filterType = ref('all');
const filterStatus = ref('all');

// Modal states
const showCreateProjectModal = ref(false);
const showEditProjectModal = ref(false);
const showDeleteModal = ref(false);
const projectHasRelationships = ref(false);

// Form data
const newProject = reactive({
  client_id: null,
  estimate: null,
  type: 'assessment',
  status: 'pending',
  scheduled_date: new Date().toISOString().split('T')[0] // Today's date in YYYY-MM-DD format
});

const editingProject = reactive({
  id: '',
  client_id: '',
  estimate: null,
  type: 'assessment',
  status: 'pending',
  scheduled_date: ''
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
  return date.toLocaleDateString('en-US', {
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

// Dynamic labels for estimate selector based on project type
const getEstimateSelectorLabel = computed(() => {
  return newProject.type === 'active' 
    ? 'Link Estimate (Recommended for Active Projects)' 
    : 'Link Estimate';
});

const getEstimatePlaceholderText = computed(() => {
  return newProject.type === 'active'
    ? 'Select an estimate for this active project'
    : 'Select an estimate for this project';
});

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

// Get client name with fallback
const getClientName = (client) => {
  if (!client) return 'Unknown Client';
  
  // Try different client name properties
  if (client.display_name) return client.display_name;
  if (client.displayName) return client.displayName;
  if (client.name) return client.name;
  
  // If no name property, check ID properties
  if (client.id) return `Client #${client.id}`;
  if (client.client_id) return `Client #${client.client_id}`;
  
  return 'Unknown Client';
};

// Format error message for better display
const formatErrorMessage = (error) => {
  // Extract the most relevant part of the error message
  if (error.message && typeof error.message === 'string') {
    // Look for specific patterns in error messages
    if (error.message.includes('foreign key constraint')) {
      return 'Cannot delete project because it has related records. Please try again.';
    }
    
    // Check if there's a more specific message in the response data
    if (error.data && error.data.message) {
      return error.data.message;
    }
    
    // Clean up generic error messages
    return error.message.replace(/Error:/g, '').trim();
  }
  
  return 'An unexpected error occurred. Please try again.';
};

// Load all projects with optional filters
const loadProjects = async () => {
  loading.value = true;
  
  try {
    const response = await projectsService.getAllProjects({
      type: filterType.value !== 'all' ? filterType.value : undefined,
      status: filterStatus.value !== 'all' ? filterStatus.value : undefined
    });
    
    projects.value = response.data || [];
  } catch (error) {
    console.error('Error loading projects:', error);
    alertMessage.value = 'Failed to load projects. Please try again.';
    alertVariant.value = 'danger';
  } finally {
    loading.value = false;
  }
};

// Helper function to extract client ID
const getClientIdValue = (clientObj) => {
  if (!clientObj) return null;
  
  // Handle different ways client ID can be stored
  if (typeof clientObj === 'string') return clientObj;
  if (clientObj.id) return clientObj.id;
  if (clientObj.client_id) return clientObj.client_id;
  
  return null;
};

// Create new project
const createProject = async () => {
  submitting.value = true;
  
  try {
    // Prepare data for API
    const projectData = {
      client_id: getClientIdValue(newProject.client_id),
      estimate_id: newProject.estimate ? newProject.estimate.id : null,
      type: newProject.type,
      status: newProject.status,
      scheduled_date: newProject.scheduled_date
    };
    
    await projectsService.createProject(projectData);
    
    // Reset form and close modal
    Object.assign(newProject, {
      client_id: null,
      estimate: null,
      type: 'assessment',
      status: 'pending',
      scheduled_date: new Date().toISOString().split('T')[0]
    });
    
    showCreateProjectModal.value = false;
    
    // Show success message and reload projects
    alertMessage.value = 'Project created successfully!';
    alertVariant.value = 'success';
    
    await loadProjects();
  } catch (error) {
    console.error('Error creating project:', error);
    alertMessage.value = formatErrorMessage(error);
    alertVariant.value = 'danger';
  } finally {
    submitting.value = false;
  }
};

// Open create project modal
const openCreateProjectModal = () => {
  console.log('Opening create project modal');
  // Reset form when opening modal
  Object.assign(newProject, {
    client_id: null,
    estimate: null,
    type: 'assessment',
    status: 'pending',
    scheduled_date: new Date().toISOString().split('T')[0]
  });
  showCreateProjectModal.value = true;
  console.log('showCreateProjectModal set to:', showCreateProjectModal.value);
};

// Open edit modal with project data
const editProject = (project) => {
  // Copy project data to editing form
  Object.assign(editingProject, {
    id: project.id,
    client_id: project.client_id || (project.client ? project.client.id : ''),
    estimate: project.estimate || null,
    type: project.type || 'assessment',
    status: project.status || 'pending',
    scheduled_date: project.scheduled_date ? new Date(project.scheduled_date).toISOString().split('T')[0] : ''
  });
  
  showEditProjectModal.value = true;
};

// Update project
const updateProject = async () => {
  submitting.value = true;
  
  try {
    // Prepare data for API
    const projectData = {
      client_id: getClientIdValue(editingProject.client_id),
      estimate_id: editingProject.estimate ? editingProject.estimate.id : null,
      type: editingProject.type,
      status: editingProject.status,
      scheduled_date: editingProject.scheduled_date
    };
    
    await projectsService.updateProject(editingProject.id, projectData);
    
    // Close modal
    showEditProjectModal.value = false;
    
    // Show success message and reload projects
    alertMessage.value = 'Project updated successfully!';
    alertVariant.value = 'success';
    
    await loadProjects();
  } catch (error) {
    console.error('Error updating project:', error);
    alertMessage.value = formatErrorMessage(error);
    alertVariant.value = 'danger';
  } finally {
    submitting.value = false;
  }
};

// Open delete confirmation modal
const confirmDelete = (project) => {
  projectToDelete.value = project;
  
  // Check if project has associated inspections or photos
  projectHasRelationships.value = 
    (project.inspections && project.inspections.length > 0) || 
    (project.photos && project.photos.length > 0);
  
  showDeleteModal.value = true;
};

// Delete project
const deleteProject = async () => {
  if (!projectToDelete.value) return;
  
  submitting.value = true;
  
  try {
    await projectsService.deleteProject(projectToDelete.value.id);
    
    // Close modal
    showDeleteModal.value = false;
    projectToDelete.value = null;
    
    // Show success message and reload projects
    alertMessage.value = 'Project deleted successfully!';
    alertVariant.value = 'success';
    
    await loadProjects();
  } catch (error) {
    console.error('Error deleting project:', error);
    showDeleteModal.value = false;
    alertMessage.value = 'Failed to delete project: ' + formatErrorMessage(error);
    alertVariant.value = 'danger';
  } finally {
    submitting.value = false;
  }
};

// Navigate to project detail view
const viewProject = (id) => {
  router.push(`/projects/${id}`);
};

// Watch for project type changes to enhance UX for estimate selection
watch(() => newProject.type, (newType) => {
  console.log('Project type changed to:', newType);
  // We don't need to do anything special here as the computed properties will handle the UI changes
});

watch(() => editingProject.type, (newType) => {
  console.log('Editing project type changed to:', newType);
  // We don't need to do anything special here as the computed properties will handle the UI changes
});

// Load projects on component mount
onMounted(() => {
  console.log('ProjectSettings component mounted');
  loadProjects();
});
</script>
