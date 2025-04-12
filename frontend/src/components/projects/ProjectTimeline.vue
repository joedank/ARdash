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

const timelineEvents = computed(() => {
  return [
    {
      label: 'Assessment',
      timestamp: formatDate(props.project.created_at),
      isComplete: true,
      icon: 'pi pi-file',
      step: 'assessment'
    },
    {
      label: 'Active',
      timestamp: isActive.value ? formatDate(props.project.updated_at) : 'Pending',
      isComplete: isActive.value || isCompleted.value,
      icon: 'pi pi-cog',
      step: 'active'
    },
    {
      label: 'Completed',
      timestamp: isCompleted.value ? formatDate(props.project.updated_at) : 'Pending',
      isComplete: isCompleted.value,
      icon: 'pi pi-check',
      step: 'completed'
    }
  ];
});

const navigateToStep = (step) => {
  if (step === 'assessment' && isActive.value && props.project.assessment_id) {
    router.push(`/projects/${props.project.assessment_id}`);
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
