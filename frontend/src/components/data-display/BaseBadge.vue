<template>
  <span :class="badgeClasses">
    <slot name="icon" />
    <slot>{{ text }}</slot>
    <span v-if="count !== null" :class="countClasses">{{ count }}</span>
  </span>
</template>

<script setup>
import { computed } from 'vue';

/**
 * BaseBadge
 * 
 * A component to display small status descriptors or counts.
 * Supports different colors, sizes, and optional icons/counts.
 * 
 * @props {String} color - The color variant (e.g., 'gray', 'red', 'yellow', 'green', 'blue', 'indigo', 'purple', 'pink'). Default: 'gray'.
 * @props {String} size - The size variant ('sm', 'md', 'lg'). Default: 'md'.
 * @props {String} text - Optional text content if default slot is not used.
 * @props {Number|null} count - Optional count to display. Default: null.
 * @props {Boolean} dot - Display as a small dot (ignores size, text, count, icon). Default: false.
 * 
 * @slots default - The main content of the badge (overrides text prop).
 * @slots icon - Slot for an optional icon, typically placed before the text.
 */

const props = defineProps({
  color: {
    type: String,
    default: 'gray',
    validator: (value) => ['gray', 'red', 'yellow', 'green', 'blue', 'indigo', 'purple', 'pink'].includes(value)
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  },
  text: {
    type: String,
    default: ''
  },
  count: {
    type: Number,
    default: null
  },
  dot: {
    type: Boolean,
    default: false
  }
});

const colorClasses = computed(() => {
  // Using full class names for Tailwind JIT
  const colors = {
    gray: 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300',
    red: 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300',
    yellow: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300',
    green: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300',
    blue: 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300',
    indigo: 'bg-indigo-100 text-indigo-800 dark:bg-indigo-900 dark:text-indigo-300',
    purple: 'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-300',
    pink: 'bg-pink-100 text-pink-800 dark:bg-pink-900 dark:text-pink-300',
  };
  return colors[props.color] || colors.gray;
});

const sizeClasses = computed(() => {
  if (props.dot) return 'w-2 h-2 rounded-full'; // Fixed size for dot

  const sizes = {
    sm: 'px-2 py-0.5 text-xs',
    md: 'px-2.5 py-0.5 text-sm',
    lg: 'px-3 py-0.5 text-base'
  };
  return sizes[props.size] || sizes.md;
});

const badgeClasses = computed(() => [
  'inline-flex items-center font-medium rounded-full gap-x-1.5',
  colorClasses.value,
  sizeClasses.value,
  { 'p-0': props.dot } // Remove padding for dot
]);

const countClasses = computed(() => {
  // Slightly darker background for the count part
  const countColors = {
    gray: 'bg-gray-200 dark:bg-gray-600',
    red: 'bg-red-200 dark:bg-red-700',
    yellow: 'bg-yellow-200 dark:bg-yellow-700',
    green: 'bg-green-200 dark:bg-green-700',
    blue: 'bg-blue-200 dark:bg-blue-700',
    indigo: 'bg-indigo-200 dark:bg-indigo-700',
    purple: 'bg-purple-200 dark:bg-purple-700',
    pink: 'bg-pink-200 dark:bg-pink-700',
  };
  // Adjust padding and text size based on badge size
  const countSizes = {
    sm: 'px-1.5 py-0.5 text-xs',
    md: 'px-1.5 py-0.5 text-xs', // Count text usually smaller
    lg: 'px-2 py-0.5 text-sm'
  };
  return [
    'inline-flex items-center justify-center rounded-full',
    countColors[props.color] || countColors.gray,
    countSizes[props.size] || countSizes.md,
    '-mr-1' // Negative margin to slightly overlap
  ];
});

</script>