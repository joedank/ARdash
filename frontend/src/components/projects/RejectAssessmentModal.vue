<template>
  <BaseModal
    :show="show"
    @close="onClose"
    size="md"
    :title="'Reject Assessment'"
  >
    <div class="p-4">
      <div class="mb-4 text-gray-700 dark:text-gray-300">
        <p>Are you sure you want to reject this assessment?</p>
        <p class="mt-2 text-sm">
          This will mark the assessment as rejected and it will no longer appear in the active assessments list.
        </p>
      </div>

      <div class="mb-4">
        <BaseFormGroup
          label="Reason for Rejection (Optional)"
          input-id="rejectionReason"
          :helper-text="'This will be recorded with the assessment'"
        >
          <textarea
            id="rejectionReason"
            v-model="rejectionReason"
            class="w-full px-3 py-2 border rounded-md dark:bg-gray-800 dark:border-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
            rows="3"
            placeholder="Enter reason for rejection (optional)"
          ></textarea>
        </BaseFormGroup>
      </div>

      <div class="flex justify-end space-x-2">
        <BaseButton
          variant="outline"
          @click="onClose"
          :disabled="loading"
        >
          Cancel
        </BaseButton>
        <BaseButton
          variant="danger"
          @click="confirmReject"
          :loading="loading"
        >
          Reject Assessment
        </BaseButton>
      </div>
    </div>
  </BaseModal>
</template>

<script setup>
import { ref } from 'vue';
import BaseModal from '@/components/base/BaseModal.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseFormGroup from '@/components/form/BaseFormGroup.vue';
import projectsService from '@/services/standardized-projects.service';
import useErrorHandler from '@/composables/useErrorHandler.js';

// Props
const props = defineProps({
  show: {
    type: Boolean,
    required: true
  },
  projectId: {
    type: String,
    required: true
  }
});

// Emits
const emit = defineEmits(['close', 'rejected']);

// State
const rejectionReason = ref('');
const loading = ref(false);
const { handleError } = useErrorHandler();

// Methods
const onClose = () => {
  rejectionReason.value = '';
  emit('close');
};

const confirmReject = async () => {
  loading.value = true;
  try {
    const response = await projectsService.rejectAssessment(
      props.projectId,
      rejectionReason.value || null
    );
    
    if (response.success) {
      emit('rejected', response.data);
      onClose();
    } else {
      handleError(new Error(response.message || 'Failed to reject assessment'));
    }
  } catch (error) {
    handleError(error, 'Error rejecting assessment');
  } finally {
    loading.value = false;
  }
};
</script>
