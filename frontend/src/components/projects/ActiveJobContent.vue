<template>
  <div class="active-job-content">
    <!-- Project Info -->
    <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4 mb-4">
      <h3 class="font-medium mb-2">Job Information</h3>
      <div class="grid sm:grid-cols-2 gap-4">
        <div>
          <p class="text-sm text-gray-500 dark:text-gray-400">Status</p>
          <p>{{ project.status }}</p>
        </div>
        <div>
          <p class="text-sm text-gray-500 dark:text-gray-400">Scheduled Date</p>
          <p>{{ formatDate(project.scheduled_date) }}</p>
        </div>
        <div class="sm:col-span-2">
          <p class="text-sm text-gray-500 dark:text-gray-400">Scope</p>
          <p>{{ project.scope || 'No scope provided' }}</p>
        </div>
      </div>
    </div>

    <!-- Before Photos -->
    <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4 mb-4">
      <h3 class="font-medium mb-2">Before Photos</h3>
      <PhotoUploadSection
        :project-id="project.id"
        photo-type="before"
        label="Add before photos"
      />
      <PhotoGrid
        :photos="getPhotosByType('before')"
        class="mt-4"
      />
    </div>

    <!-- After Photos -->
    <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4 mb-4">
      <h3 class="font-medium mb-2">After Photos</h3>
      <PhotoUploadSection
        :project-id="project.id"
        photo-type="after"
        label="Add after photos"
      />
      <PhotoGrid
        :photos="getPhotosByType('after')"
        class="mt-4"
      />
    </div>

    <!-- Receipts -->
    <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4 mb-4">
      <h3 class="font-medium mb-2">Receipts</h3>
      <PhotoUploadSection
        :project-id="project.id"
        photo-type="receipt"
        label="Upload receipts"
      />
      <PhotoGrid
        :photos="getPhotosByType('receipt')"
        class="mt-4"
      />
    </div>
    
    <!-- Additional Work Section (if applicable) -->
    <div v-if="project.estimate" class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4">
      <h3 class="font-medium mb-2">Additional Work</h3>
      <BaseTextarea
        v-model="additionalWork"
        placeholder="Document any work performed outside the original estimate..."
        rows="4"
        class="mb-2"
      />
      <BaseButton
        variant="primary"
        size="sm"
        @click="saveAdditionalWork"
        :loading="saving"
      >
        Save Notes
      </BaseButton>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import BaseTextarea from '@/components/form/BaseTextarea.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import PhotoUploadSection from '@/components/projects/PhotoUploadSection.vue';
import PhotoGrid from '@/components/projects/PhotoGrid.vue';
import projectsService from '@/services/projects.service';

const props = defineProps({
  project: {
    type: Object,
    required: true
  }
});

const additionalWork = ref(props.project?.additional_work || '');
const saving = ref(false);

// Get photos by type
const getPhotosByType = (type) => {
  return props.project?.photos?.filter(p => p.photo_type === type) || [];
};

// Helper to format dates
const formatDate = (dateString) => {
  if (!dateString) return 'Not scheduled';
  const date = new Date(dateString);
  return date.toLocaleDateString();
};

// Save additional work notes
const saveAdditionalWork = async () => {
  saving.value = true;
  try {
    await projectsService.updateAdditionalWork(props.project.id, additionalWork.value);
    // Could emit an event to notify parent or show a success message
  } catch (error) {
    console.error('Error saving additional work:', error);
    // Handle error (show error message)
  } finally {
    saving.value = false;
  }
};
</script>
