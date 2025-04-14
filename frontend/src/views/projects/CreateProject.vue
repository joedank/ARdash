<template>
  <div class="container mx-auto p-4">
    <h1 class="text-2xl font-bold mb-4">Create New Project</h1>

    <!-- Loading Indicator -->
    <div v-if="loading" class="text-center py-8">
      <BaseLoader />
    </div>

    <!-- Error Display -->
    <div v-if="error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
      <strong class="font-bold">Error!</strong>
      <span class="block sm:inline"> {{ error }}</span>
    </div>

    <form v-if="!loading" @submit.prevent="createProject" class="space-y-4">
      <!-- Client Selector -->
      <div>
        <label for="client" class="block text-sm font-medium text-gray-700">Client</label>
        <select
          id="client"
          v-model="selectedClientId"
          required
          class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md"
        >
          <option value="" disabled>Select a client</option>
          <option v-for="client in clients" :key="client.id" :value="client.id">
            {{ client.displayName }}
          </option>
        </select>
      </div>

      <!-- Estimate Selector (Use the EstimateSelector component) -->
      <EstimateSelector
        v-model="selectedEstimate"
        :clientId="selectedClientId"
        label="Estimate (Optional)"
        placeholderText="Select an estimate for this project"
      />

      <!-- Submit Button -->
      <div>
        <button
          type="submit"
          :disabled="!selectedClientId || submitting"
          class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
        >
          {{ submitting ? 'Creating...' : 'Create Project' }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import clientsService from '@/services/clients.service';
import projectService from '@/services/standardized-projects.service';
import EstimateSelector from '@/components/invoicing/EstimateSelector.vue';
import BaseLoader from '@/components/feedback/BaseLoader.vue';

const router = useRouter();
const error = ref(null);
const loading = ref(true);
const submitting = ref(false);

const clients = ref([]);
const selectedClientId = ref('');
const selectedEstimate = ref(null);

// Fetch Clients on Mount
onMounted(async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await clientsService.getAllClients();
    if (response.success) {
      clients.value = response.data;
    } else {
      throw new Error(response.message || 'Failed to fetch clients');
    }
  } catch (err) {
    console.error('Error fetching clients:', err);
    error.value = err.message || 'An unexpected error occurred while fetching clients.';
  } finally {
    loading.value = false;
  }
});

// Create Project Logic
const createProject = async () => {
  if (!selectedClientId.value) {
    error.value = 'Please select a client.';
    return;
  }

  submitting.value = true;
  error.value = null;

  try {
    const projectData = {
      clientId: selectedClientId.value,
      // Add estimateId only if an estimate is selected
      ...(selectedEstimate.value ? { estimateId: selectedEstimate.value.id } : {})
    };

    // standardized-projects.service handles the request standardization (camelCase -> snake_case)
    const response = await projectService.createProject(projectData);

    if (response.success && response.data?.id) {
      // Success - navigate to the new project's detail page
      router.push({ name: 'project-detail', params: { id: response.data.id } });
    } else {
      throw new Error(response.message || 'Failed to create project');
    }
  } catch (err) {
    console.error('Error creating project:', err);
    error.value = err.message || 'An unexpected error occurred while creating the project.';
  } finally {
    submitting.value = false;
  }
};
</script>

<style scoped>
/* Add component-specific styles here if needed */
</style>
