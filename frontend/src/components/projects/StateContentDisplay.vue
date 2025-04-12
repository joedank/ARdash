<template>
  <div class="state-content-display bg-white dark:bg-gray-800 rounded shadow p-4 mb-6">
    <h2 class="text-xl font-semibold mb-4 flex items-center">
      <BaseIcon :name="isJob ? 'hammer' : 'clipboard-check'" class="mr-2" />
      {{ isJob ? 'Active Job Details' : 'Assessment Details' }}
    </h2>
    
    <ActiveJobContent v-if="isJob" :project="project" />
    <AssessmentContent v-else :project="project" />
  </div>
</template>

<script setup>
import BaseIcon from '@/components/base/BaseIcon.vue';
import ActiveJobContent from '@/components/projects/ActiveJobContent.vue';
import AssessmentContent from '@/components/projects/AssessmentContent.vue';

defineProps({
  project: {
    type: Object,
    required: true
  },
  isJob: {
    type: Boolean,
    default: false
  }
});
</script>
