<template>
  <div class="previous-state-card mb-6">
    <div 
      @click="isExpanded = !isExpanded"
      class="card-header flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-800 rounded-t border cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-700"
    >
      <div class="flex items-center">
        <BaseIcon name="history" class="mr-2" />
        <h3 class="text-lg font-medium">Assessment History</h3>
      </div>
      <BaseIcon :name="isExpanded ? 'chevron-up' : 'chevron-down'" />
    </div>
    
    <div 
      v-show="isExpanded"
      class="card-content p-4 border border-t-0 rounded-b bg-white dark:bg-gray-900"
    >
      <AssessmentContent :project="assessmentData" readonly />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import BaseIcon from '@/components/base/BaseIcon.vue';
import AssessmentContent from '@/components/projects/AssessmentContent.vue';

defineProps({
  assessmentData: {
    type: Object,
    required: true
  }
});

const isExpanded = ref(false);
</script>
