<!--
  BaseLoader component
  
  A spinner/loader component for indicating loading states.
  Supports different sizes and colors. Fully compatible with dark mode.
  
  @props {String} size - Size of the loader (sm, md, lg)
  @props {String} color - Color of the loader (default, primary, secondary)
  
  @example
  <BaseLoader size="md" color="primary" />
-->

<template>
  <div 
    class="inline-flex items-center justify-center"
    :class="[sizeClass]"
  >
    <svg 
      class="animate-spin"
      :class="[sizeClass, colorClass]"
      xmlns="http://www.w3.org/2000/svg" 
      fill="none" 
      viewBox="0 0 24 24"
    >
      <circle 
        class="opacity-25" 
        cx="12" 
        cy="12" 
        r="10" 
        stroke="currentColor" 
        stroke-width="4"
      ></circle>
      <path 
        class="opacity-75" 
        fill="currentColor" 
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      ></path>
    </svg>
    <span v-if="$slots.default" class="ml-3">
      <slot></slot>
    </span>
  </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  },
  color: {
    type: String,
    default: 'primary',
    validator: (value) => ['default', 'primary', 'secondary'].includes(value)
  }
});

const sizeClass = computed(() => {
  switch (props.size) {
    case 'sm': return 'h-4 w-4';
    case 'lg': return 'h-8 w-8';
    case 'md':
    default: return 'h-6 w-6';
  }
});

const colorClass = computed(() => {
  switch (props.color) {
    case 'primary': return 'text-blue-600 dark:text-blue-400';
    case 'secondary': return 'text-gray-600 dark:text-gray-400';
    case 'default':
    default: return 'text-gray-800 dark:text-gray-200';
  }
});
</script>
