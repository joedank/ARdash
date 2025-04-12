<template>
  <div class="convert-button-container text-right">
    <BaseButton 
      @click="showConvertModal = true"
      variant="secondary"
      size="sm"
      icon="exchange"
    >
      Convert to Active Job
    </BaseButton>
    
    <BaseModal v-model="showConvertModal" title="Convert to Active Job">
      <p>This will create a new active job based on this assessment.</p>
      
      <div v-if="!hasEstimate" class="mt-4 bg-amber-50 dark:bg-amber-900 p-4 rounded">
        <p class="text-amber-800 dark:text-amber-200">
          <strong>Note:</strong> An estimate is required before conversion.
        </p>
        <BaseButton 
          @click="navigateToCreateEstimate"
          variant="secondary"
          class="mt-2"
        >
          Create Estimate First
        </BaseButton>
      </div>
      
      <div class="mt-4" v-else>
        <BaseButton 
          @click="convertToJob" 
          variant="primary"
          :loading="isConverting"
        >
          Create Job
        </BaseButton>
        <BaseButton 
          @click="showConvertModal = false" 
          variant="secondary"
          :disabled="isConverting"
        >
          Cancel
        </BaseButton>
      </div>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import projectsService from '@/services/projects.service';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseModal from '@/components/overlays/BaseModal.vue';

const props = defineProps({
  project: {
    type: Object,
    required: true
  }
});

const emit = defineEmits(['conversion-complete']);
const router = useRouter();
const showConvertModal = ref(false);
const isConverting = ref(false);

// Check if project has an estimate
const hasEstimate = computed(() => {
  return !!props.project.estimate_id;
});

// Navigation helper
const navigateToCreateEstimate = () => {
  router.push(`/invoicing/create-estimate?clientId=${props.project.client_id}&projectId=${props.project.id}`);
};

// Conversion action
const convertToJob = async () => {
  if (!hasEstimate.value) {
    return; // Require estimate
  }
  
  isConverting.value = true;
  
  try {
    const response = await projectsService.convertToJob(
      props.project.id,
      props.project.estimate_id
    );
    
    showConvertModal.value = false;
    
    // Important: The API now returns the new job project
    if (response.success && response.data) {
      // Navigate to the newly created job project
      emit('conversion-complete', response.data.id);
    }
  } catch (error) {
    console.error('Failed to convert to job:', error);
    // Show error message
  } finally {
    isConverting.value = false;
  }
};
</script>
