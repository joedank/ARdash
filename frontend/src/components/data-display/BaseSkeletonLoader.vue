<template>
  <div v-if="type === 'text' &amp;&amp; lines > 1" class="space-y-2">
    <div 
      v-for="n in lines" 
      :key="n" 
      :class="skeletonClasses" 
      :style="{ width: n === lines ? '80%' : props.width, height: finalHeight }"
      class="skeleton-line"
    ></div>
  </div>
  <div v-else :class="skeletonClasses" :style="{ width: props.width, height: finalHeight }">
    <!-- Basic skeleton element -->
    <!-- More complex structures for card/table types could go here -->
  </div>
</template>

<script setup>
import { computed } from 'vue';

/**
 * BaseSkeletonLoader
 * 
 * Displays a placeholder preview of content before it finishes loading.
 * Supports various shapes and sizes with a pulsing animation.
 * 
 * @props {String} type - The type of skeleton shape ('text', 'image', 'card', 'table', 'avatar', 'button'). Default: 'text'.
 * @props {String} width - Custom width for the skeleton element (e.g., '100px', '50%'). Default: '100%'.
 * @props {String} height - Custom height for the skeleton element (e.g., '20px', '10rem'). Default: '1rem' for text, varies for others.
 * @props {String} shape - Shape modifier ('circle', 'rounded', 'square'). Default: 'rounded'.
 * @props {Boolean} animated - Whether to apply the pulsing animation. Default: true.
 * @props {String|Number} count - For 'text' type, number of lines to generate. Default: 1.
 * 
 * @example
 * <!-- Basic text skeleton -->
 * <BaseSkeletonLoader type="text" width="80%" />
 * 
 * <!-- Multi-line text skeleton -->
 * <BaseSkeletonLoader type="text" :count="3" />
 * 
 * <!-- Image skeleton -->
 * <BaseSkeletonLoader type="image" height="150px" />
 * 
 * <!-- Avatar skeleton -->
 * <BaseSkeletonLoader type="avatar" shape="circle" width="40px" height="40px" />
 * 
 * <!-- Card skeleton (basic representation) -->
 * <BaseSkeletonLoader type="card" height="200px" /> 
 * 
 * <!-- Button skeleton -->
 * <BaseSkeletonLoader type="button" width="100px" />
 */

const props = defineProps({
  type: {
    type: String,
    default: 'text',
    validator: (value) => ['text', 'image', 'card', 'table', 'avatar', 'button'].includes(value)
  },
  width: {
    type: String,
    default: '100%'
  },
  height: {
    type: String,
    default: null // Default height depends on type
  },
  shape: {
    type: String,
    default: 'rounded',
    validator: (value) => ['circle', 'rounded', 'square'].includes(value)
  },
  animated: {
    type: Boolean,
    default: true
  },
  count: {
    type: [Number, String],
    default: 1,
    validator: (value) => parseInt(value, 10) > 0
  }
});

const defaultHeights = {
  text: '1rem',
  image: '10rem', // Example default
  card: '12rem',  // Example default
  table: '15rem', // Example default
  avatar: '2.5rem', // Example default (matches common avatar size, e.g., h-10)
  button: '2.5rem' // Example default (matches common button height, e.g., h-10)
};

const skeletonClasses = computed(() => {
  const base = [
    'block',
    'bg-gray-200', // Light mode base
    'dark:bg-gray-700' // Dark mode base
  ];

  if (props.animated) {
    base.push('animate-pulse');
  }

  // Shape
  if (props.shape === 'circle') {
    base.push('rounded-full');
  } else if (props.shape === 'rounded') {
     // Use a common rounded size like rounded-md
     base.push('rounded-md'); 
  } else if (props.shape === 'square') {
    base.push('rounded-none'); // Explicitly remove rounding if square
  }
  // Default is slightly rounded if no shape prop is specified or if 'rounded'

  // Add specific type classes if needed (e.g., for complex types like card/table)
  // For now, width/height props handle most cases.

  return base;
});

// Calculate the final height, using prop override or type default
const finalHeight = computed(() => props.height || defaultHeights[props.type] || defaultHeights.text);
// Parse the count prop to an integer
const lines = computed(() => Math.max(1, parseInt(props.count, 10) || 1)); // Ensure at least 1 line

// Note: The template handles the multi-line text case.
// More complex types like 'card' or 'table' might require internal slots or more structured templates
// within this component in a future iteration if simple blocks aren't sufficient.

</script>

<style scoped>
/* Using Tailwind utilities is preferred, but scoped styles can be used if necessary */

/* Example for multi-line text spacing handled by space-y utility in template */
/* .skeleton-line + .skeleton-line {
  margin-top: 0.5rem; 
} */
</style>