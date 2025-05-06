<template>
  <div
    @click="$emit('click')"
    class="badge cursor-pointer px-2 py-1 text-xs rounded-full flex items-center gap-1"
    :class="chipClasses"
  >
    <span>{{ label }}</span>
    <BaseIcon v-if="icon && color !== 'yellow'" :name="icon" class="w-3 h-3" />
  </div>
</template>

<script setup>
import { computed } from 'vue';
import BaseIcon from '@/components/base/BaseIcon.vue';

const props = defineProps({
  label: {
    type: String,
    required: true
  },
  color: {
    type: String,
    default: 'default',
    validator: (value) => ['default', 'blue', 'yellow', 'green', 'red', 'gray'].includes(value)
  },
  icon: {
    type: String,
    default: ''
  },
  selected: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['click']);

const chipClasses = computed(() => {
  if (props.selected) {
    return 'bg-blue-600 text-white';
  }
  
  switch (props.color) {
    case 'blue':
      return 'bg-blue-200 text-blue-800 dark:bg-blue-900 dark:text-blue-200';
    case 'yellow':
      return 'bg-yellow-100 text-yellow-800 border border-yellow-300 dark:bg-yellow-800/50 dark:text-yellow-200 dark:border-yellow-600';
    case 'green':
      return 'bg-green-200 text-green-800 dark:bg-green-900 dark:text-green-200';
    case 'red':
      return 'bg-red-200 text-red-800 dark:bg-red-900 dark:text-red-200';
    case 'gray':
      return 'bg-gray-200 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
    default:
      return 'bg-gray-200 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
  }
});
</script>
