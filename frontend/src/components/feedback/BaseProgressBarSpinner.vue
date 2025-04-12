<template>
  <!-- Main component root -->
  <div :role="role" :aria-valuenow="determinateValue" aria-valuemin="0" :aria-valuemax="max">
    <!-- Structure for Determinate Bar (with optional percentage) -->
    <div v-if="!indeterminate" :class="outerDeterminateClasses">
      <!-- Progress Bar Track -->
      <div :class="trackClasses">
         <!-- Filling Bar -->
        <div :class="progressBarClasses" :style="{ width: `${percentage}%` }"></div>
      </div>
      <!-- Percentage Text (sibling to track) -->
      <span v-if="showPercentage" class="ml-2 shrink-0" :class="percentageTextClasses">
        {{ percentage.toFixed(0) }}%
      </span>
    </div>

    <!-- Structure for Indeterminate Spinner -->
    <div v-else class="flex items-center">
      <svg :class="spinnerClasses" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      <span v-if="$slots.default" class="ml-2" :class="spinnerTextClasses">
        <slot></slot>
      </span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';

/**
 * BaseProgressBarSpinner
 *
 * Displays progress indication, either as a determinate progress bar
 * or an indeterminate spinner. Supports different sizes, colors,
 * and optional percentage display for the progress bar.
 *
 * @props {Number} value - Current value for determinate progress (0 to max).
 * @props {Number} max - Maximum value for determinate progress (default: 100).
 * @props {Boolean} indeterminate - If true, displays a spinner instead of a bar.
 * @props {String} size - Size of the component ('sm', 'md', 'lg'). Default: 'md'.
 * @props {String} color - Color theme ('primary', 'success', 'warning', 'error'). Default: 'primary'.
 * @props {Boolean} showPercentage - If true, displays the percentage text next to the determinate bar.
 *
 * @slots default - Optional text to display next to the spinner.
 *
 * @example
 * <!-- Determinate -->
 * <BaseProgressBarSpinner :value="50" />
 * <BaseProgressBarSpinner :value="75" color="success" size="lg" show-percentage />
 *
 * <!-- Indeterminate -->
 * <BaseProgressBarSpinner indeterminate />
 * <BaseProgressBarSpinner indeterminate size="sm" color="warning">Loading...</BaseProgressBarSpinner>
 */

const props = defineProps({
  value: {
    type: Number,
    default: 0,
    validator: (val) => val >= 0,
  },
  max: {
    type: Number,
    default: 100,
    validator: (val) => val > 0,
  },
  indeterminate: {
    type: Boolean,
    default: false,
  },
  size: {
    type: String,
    default: 'md',
    validator: (val) => ['sm', 'md', 'lg'].includes(val),
  },
  color: {
    type: String,
    default: 'primary',
    validator: (val) => ['primary', 'success', 'warning', 'error'].includes(val),
  },
  showPercentage: {
    type: Boolean,
    default: false,
  },
});

const role = computed(() => (props.indeterminate ? 'status' : 'progressbar'));

const determinateValue = computed(() => (props.indeterminate ? undefined : percentage.value));

const percentage = computed(() => {
  if (props.indeterminate || props.max <= 0) return 0;
  const clampedValue = Math.max(0, Math.min(props.value, props.max));
  return (clampedValue / props.max) * 100;
});

// --- Styling ---

const sizeClasses = computed(() => {
  // Note: 'wrapper' here refers to the height of the track
  switch (props.size) {
    case 'sm': return { wrapper: 'h-1', spinner: 'h-4 w-4', text: 'text-xs' };
    case 'lg': return { wrapper: 'h-3', spinner: 'h-6 w-6', text: 'text-sm' };
    case 'md':
    default:   return { wrapper: 'h-2', spinner: 'h-5 w-5', text: 'text-sm' };
  }
});

const colorClasses = computed(() => {
  switch (props.color) {
    case 'success': return {
      bar: 'bg-green-600 dark:bg-green-500',
      spinner: 'text-green-600 dark:text-green-500',
      text: 'text-green-700 dark:text-green-400'
    };
    case 'warning': return {
      bar: 'bg-yellow-500 dark:bg-yellow-400',
      spinner: 'text-yellow-500 dark:text-yellow-400',
      text: 'text-yellow-700 dark:text-yellow-300'
    };
    case 'error': return {
      bar: 'bg-red-600 dark:bg-red-500',
      spinner: 'text-red-600 dark:text-red-500',
      text: 'text-red-700 dark:text-red-400'
    };
    case 'primary':
    default: return {
      bar: 'bg-blue-600 dark:bg-blue-500',
      spinner: 'text-blue-600 dark:text-blue-500',
      text: 'text-blue-700 dark:text-blue-400'
    };
  }
});

// Classes for the outer container when showing determinate bar + percentage
const outerDeterminateClasses = computed(() => [
  'flex items-center w-full',
]);

// Classes for the progress bar track (the background)
const trackClasses = computed(() => [
  'overflow-hidden rounded-full bg-gray-200 dark:bg-gray-700 flex-grow', // Use flex-grow
  sizeClasses.value.wrapper, // Apply height
]);

// Classes for the filling part of the progress bar
const progressBarClasses = computed(() => [
  'h-full rounded-full transition-all duration-300 ease-out',
  colorClasses.value.bar,
]);

// Classes for the percentage text
const percentageTextClasses = computed(() => [
  sizeClasses.value.text,
  colorClasses.value.text,
]);

// Classes for the spinner SVG
const spinnerClasses = computed(() => [
  'animate-spin',
  sizeClasses.value.spinner,
  colorClasses.value.spinner,
]);

// Classes for the text next to the spinner
const spinnerTextClasses = computed(() => [
  sizeClasses.value.text,
  'text-gray-700 dark:text-gray-300',
]);

</script>