<template>
  <div :class="avatarClasses">
    <img 
      v-if="src && !imgError" 
      :src="src" 
      :alt="altText" 
      :class="imgClasses"
      @error="handleImageError" 
    />
    <span v-else-if="initials" :class="initialsClasses">
      {{ initials }}
    </span>
    <slot v-else></slot>
    <span v-if="status" :class="statusClasses"></span>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';

/**
 * BaseAvatar
 * 
 * Displays a user avatar, supporting image URLs or initials as fallback.
 * Includes options for size variations, status indicators, and grouping.
 * 
 * @props {String} src - URL for the avatar image.
 * @props {String} name - User's name, used for initials fallback if src is not provided or fails to load.
 * @props {String} size - Size of the avatar ('xs', 'sm', 'md', 'lg', 'xl'). Defaults to 'md'.
 * @props {String} status - Status indicator ('online', 'offline', 'away', 'busy'). No indicator if omitted.
 * @props {String} shape - Shape of the avatar ('circle', 'rounded'). Defaults to 'circle'.
 * 
 * @slots default - Optional slot for custom content, like an icon, overriding image/initials.
 * 
 * @events error - Emitted when the image specified by 'src' fails to load.
 */

const props = defineProps({
  src: {
    type: String,
    default: null
  },
  name: {
    type: String,
    default: ''
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['xs', 'sm', 'md', 'lg', 'xl'].includes(value)
  },
  status: {
    type: String,
    default: null,
    validator: (value) => ['online', 'offline', 'away', 'busy'].includes(value)
  },
  shape: {
    type: String,
    default: 'circle',
    validator: (value) => ['circle', 'rounded'].includes(value)
  }
});

const emit = defineEmits(['error']);

const imgError = ref(false);

const handleImageError = () => {
  imgError.value = true;
  emit('error');
};

const initials = computed(() => {
  if (!props.name || (props.src && !imgError.value)) return '';
  const names = props.name.trim().split(' ');
  if (names.length === 1) {
    return names[0].charAt(0).toUpperCase();
  }
  return (names[0].charAt(0) + names[names.length - 1].charAt(0)).toUpperCase();
});

const altText = computed(() => props.name || 'User Avatar');

// Base classes
const baseClasses = 'relative inline-flex items-center justify-center overflow-hidden bg-gray-200 dark:bg-gray-700';
const baseImgClasses = 'object-cover w-full h-full';
const baseInitialsClasses = 'font-medium text-gray-600 dark:text-gray-300';
const baseStatusClasses = 'absolute bottom-0 right-0 block rounded-full ring-2 ring-white dark:ring-gray-900';

// Size classes
const sizeClasses = computed(() => {
  switch (props.size) {
    case 'xs': return 'w-6 h-6';
    case 'sm': return 'w-8 h-8';
    case 'lg': return 'w-12 h-12';
    case 'xl': return 'w-16 h-16';
    default: return 'w-10 h-10'; // md
  }
});

const initialsSizeClasses = computed(() => {
   switch (props.size) {
    case 'xs': return 'text-xs';
    case 'sm': return 'text-sm';
    case 'lg': return 'text-xl';
    case 'xl': return 'text-2xl';
    default: return 'text-base'; // md
  }
});

const statusSizeClasses = computed(() => {
  switch (props.size) {
    case 'xs': return 'h-1.5 w-1.5';
    case 'sm': return 'h-2 w-2';
    case 'lg': return 'h-3 w-3';
    case 'xl': return 'h-3.5 w-3.5';
    default: return 'h-2.5 w-2.5'; // md
  }
});

// Shape classes
const shapeClasses = computed(() => {
  return props.shape === 'circle' ? 'rounded-full' : 'rounded-md';
});

// Status color classes
const statusColorClasses = computed(() => {
  if (!props.status) return '';
  switch (props.status) {
    case 'online': return 'bg-green-500';
    case 'offline': return 'bg-gray-400';
    case 'away': return 'bg-yellow-400';
    case 'busy': return 'bg-red-500';
    default: return '';
  }
});

// Combined classes
const avatarClasses = computed(() => [
  baseClasses,
  sizeClasses.value,
  shapeClasses.value
]);

const imgClasses = computed(() => [
  baseImgClasses,
  shapeClasses.value // Ensure image also respects shape
]);

const initialsClasses = computed(() => [
  baseInitialsClasses,
  initialsSizeClasses.value
]);

const statusClasses = computed(() => [
  baseStatusClasses,
  statusSizeClasses.value,
  statusColorClasses.value
]);

</script>

<style scoped>
/* Add any component-specific styles here if needed */
</style>