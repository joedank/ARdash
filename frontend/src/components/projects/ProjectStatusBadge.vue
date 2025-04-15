<template>
  <span :class="badgeClasses">
    {{ formattedStatus }}
  </span>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  status: {
    type: String,
    required: true
  },
  type: {
    type: String,
    default: ''
  }
});

const badgeClasses = computed(() => {
  const baseClasses = 'px-2 py-1 text-xs font-medium rounded-full';
  
  // Different color schemes based on status
  switch(props.status) {
    case 'pending':
      return `${baseClasses} bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300`;
    case 'in_progress':
      return `${baseClasses} bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300`;
    case 'active':
      return `${baseClasses} bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300`;
    case 'upcoming':
      return `${baseClasses} bg-indigo-100 text-indigo-800 dark:bg-indigo-900 dark:text-indigo-300`;
    case 'completed':
      return `${baseClasses} bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300`;
    case 'rejected':
      return `${baseClasses} bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300`;
    default:
      return `${baseClasses} bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300`;
  }
});

const formattedStatus = computed(() => {
  // Display different text based on type and status combination
  if (props.type === 'assessment') {
    switch(props.status) {
      case 'pending':
      case 'in_progress':
        return 'In Assessment';
      case 'completed':
        return 'Assessment Complete';
      case 'rejected':
        return 'Rejected';
      default:
        return capitalizeFirstLetter(props.status);
    }
  } else {
    // Active projects
    switch(props.status) {
      case 'upcoming':
        return 'Upcoming';
      case 'in_progress':
        return 'Active';
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      default:
        return capitalizeFirstLetter(props.status);
    }
  }
});

// Helper function to capitalize the first letter
const capitalizeFirstLetter = (string) => {
  if (!string) return '';
  return string.charAt(0).toUpperCase() + string.slice(1).replace(/_/g, ' ');
};
</script>
