<template>
  <div class="project-timeline mb-4 flex items-center justify-center">
    <Timeline :value="timelineEvents" layout="horizontal" align="top" class="min-w-[200px]">
      <template #content></template>
      <template #marker="slotProps">
        <span :class="['flex h-5 w-5 items-center justify-center rounded-full border cursor-pointer transition-colors',
                    slotProps.item.isComplete ? 'bg-primary-500 text-white border-primary-500 hover:bg-primary-600' : 
                    'bg-gray-100 text-gray-500 border-gray-300 dark:bg-gray-800 dark:border-gray-600 hover:bg-gray-200 dark:hover:bg-gray-700']"
              @click="navigateToStep(slotProps.item.step)"
              :title="`${slotProps.item.label} ${slotProps.item.timestamp !== 'Pending' ? '- ' + slotProps.item.timestamp : ''}`">
          <i :class="slotProps.item.icon" class="text-sm"></i>
        </span>
      </template>
      <template #connector>
        <div :class="['h-px', 'flex-1', 'transition-colors mt-2.5',
                    timelineEvents[0].isComplete ? 'bg-primary-500' : 'bg-gray-300 dark:bg-gray-600']"></div>
      </template>
    </Timeline>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const props = defineProps({
  project: {
    type: Object,
    required: true
  },
  assessmentData: {
    type: Object,
    default: null
  }
});

// Simplified timeline states
const isActive = computed(() => props.project.type === 'active');
const isCompleted = computed(() => props.project.status === 'completed');


const projectCreatedAt = computed(() => props.project.createdAt); // Rely on normalized createdAt
const projectUpdatedAt = computed(() => props.project.updatedAt); // Rely on normalized updatedAt
const projectAssessmentId = computed(() => props.project.assessmentId); // Rely on normalized assessmentId

const timelineEvents = computed(() => {
  return [
    {
      label: 'Assessment',
      timestamp: formatDate(projectCreatedAt.value), // Use computed prop
      isComplete: true,
      icon: 'pi pi-file',
      step: 'assessment'
    },
    {
      label: 'Active',
      timestamp: isActive.value ? formatDate(projectUpdatedAt.value) : 'Pending', // Use computed prop
      isComplete: isActive.value || isCompleted.value,
      icon: 'pi pi-cog',
      step: 'active'
    },
    {
      label: 'Completed',
      timestamp: isCompleted.value ? formatDate(projectUpdatedAt.value) : 'Pending', // Use computed prop
      isComplete: isCompleted.value,
      icon: 'pi pi-check',
      step: 'completed'
    }
  ];
});

const navigateToStep = (step) => {
  if (step === 'assessment' && isActive.value && projectAssessmentId.value) { // Use computed prop
    router.push(`/projects/${projectAssessmentId.value}`); // Use computed prop
  }
};

// Helper to format dates
const formatDate = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleDateString();
};
</script>

<style>
.p-timeline-event-opposite {
  flex: 0;
}
</style>
