/**
 * BaseTagChip
 * 
 * Displays a small piece of information, often used for categorization or labeling.
 * Supports different colors, sizes, optional icons, and a removable state.
 * 
 * @props {String} text - The text content of the tag/chip. Required.
 * @props {String} color - The color variant ('gray', 'blue', 'green', 'yellow', 'red', 'purple'). Default: 'gray'.
 * @props {String} size - The size variant ('sm', 'md'). Default: 'md'.
 * @props {Boolean} removable - If true, shows a close button to emit a 'remove' event. Default: false.
 * @props {String} icon - Optional icon component name or SVG path to display before the text.
 * 
 * @slots default - Allows replacing the text content with custom markup.
 * 
 * @events remove - Emitted when the close button is clicked (only if removable is true).
 * 
 * @example
 * <!-- Basic Usage -->
 * <BaseTagChip text="Default" />
 * 
 * <!-- With Color -->
 * <BaseTagChip text="Success" color="green" />
 * 
 * <!-- Small Size -->
 * <BaseTagChip text="Small" size="sm" />
 * 
 * <!-- Removable -->
 * <BaseTagChip text="Removable" removable @remove="handleRemove" />
 * 
 * <!-- With Icon -->
 * <BaseTagChip text="Icon Tag" icon="CheckIcon" color="blue" /> 
 */
<template>
  <div :class="tagClasses">
    <!-- Icon Slot/Component (Optional) -->
    <span v-if="icon" class="mr-1">
      <!-- Placeholder for icon component or SVG -->
      <!-- <component :is="icon" class="h-3 w-3" v-if="typeof icon === 'string'" /> -->
      <!-- Or handle SVG path directly -->
    </span>

    <!-- Text Content -->
    <span class="leading-none">
      <slot>{{ text }}</slot>
    </span>

    <!-- Remove Button (Optional) -->
    <button 
      v-if="removable" 
      @click.stop="handleRemove" 
      :class="removeButtonClasses"
      aria-label="Remove tag"
    >
      &times; <!-- Simple 'x' for now -->
    </button>
  </div>
</template>

<script setup>
import { computed } from 'vue';

// --- Props ---

const props = defineProps({
  text: {
    type: String,
    default: '',
  },
  color: {
    type: String,
    default: 'gray',
    validator: (value) => ['gray', 'blue', 'green', 'yellow', 'red', 'purple'].includes(value),
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md'].includes(value),
  },
  removable: {
    type: Boolean,
    default: false,
  },
  icon: {
    type: [String, Object], // Allow string name or component object
    default: null,
  },
});

// --- Emits ---

const emit = defineEmits(['remove']);

// --- Computed Properties ---

const tagClasses = computed(() => [
  'inline-flex items-center font-medium rounded-full',
  // Size
  props.size === 'sm' ? 'px-2 py-0.5 text-xs' : 'px-2.5 py-0.5 text-sm',
  // Base Colors (Light)
  colorStyles.value.light.bg,
  colorStyles.value.light.text,
  // Dark Mode Colors
  `dark:${colorStyles.value.dark.bg}`,
  `dark:${colorStyles.value.dark.text}`,
]);

const removeButtonClasses = computed(() => [
  'ml-1.5 -mr-0.5 flex-shrink-0 rounded-full inline-flex items-center justify-center',
  props.size === 'sm' ? 'h-3.5 w-3.5' : 'h-4 w-4',
  // Base Colors (Light)
  colorStyles.value.light.removeButton.bgHover,
  colorStyles.value.light.removeButton.text,
  colorStyles.value.light.removeButton.textHover,
   // Dark Mode Colors
  `dark:${colorStyles.value.dark.removeButton.bgHover}`,
  `dark:${colorStyles.value.dark.removeButton.text}`,
  `dark:${colorStyles.value.dark.removeButton.textHover}`,
  'focus:outline-none focus:ring-2 focus:ring-offset-1', // Focus styles need refinement based on color
  `focus:${colorStyles.value.light.focusRing}`,
  `dark:focus:${colorStyles.value.dark.focusRing}`,
]);

const colorStyles = computed(() => {
  // Define color mappings for light and dark modes
  const mappings = {
    gray: {
      light: { bg: 'bg-gray-100', text: 'text-gray-800', removeBgHover: 'hover:bg-gray-200', removeText: 'text-gray-400', removeTextHover: 'hover:text-gray-500', focusRing: 'ring-gray-500' },
      dark: { bg: 'bg-gray-700', text: 'text-white', removeBgHover: 'hover:bg-gray-600', removeText: 'text-gray-400', removeTextHover: 'hover:text-gray-300', focusRing: 'ring-gray-400' },
    },
    blue: {
      light: { bg: 'bg-blue-100', text: 'text-blue-800', removeBgHover: 'hover:bg-blue-200', removeText: 'text-blue-400', removeTextHover: 'hover:text-blue-500', focusRing: 'ring-blue-500' },
      dark: { bg: 'bg-blue-900', text: 'text-white', removeBgHover: 'hover:bg-blue-800', removeText: 'text-blue-400', removeTextHover: 'hover:text-blue-300', focusRing: 'ring-blue-400' },
    },
    green: {
      light: { bg: 'bg-green-100', text: 'text-green-800', removeBgHover: 'hover:bg-green-200', removeText: 'text-green-400', removeTextHover: 'hover:text-green-500', focusRing: 'ring-green-500' },
      dark: { bg: 'bg-green-900', text: 'text-white', removeBgHover: 'hover:bg-green-800', removeText: 'text-green-400', removeTextHover: 'hover:text-green-300', focusRing: 'ring-green-400' },
    },
    yellow: {
      light: { bg: 'bg-yellow-100', text: 'text-yellow-800', removeBgHover: 'hover:bg-yellow-200', removeText: 'text-yellow-400', removeTextHover: 'hover:text-yellow-500', focusRing: 'ring-yellow-500' },
      dark: { bg: 'bg-yellow-900', text: 'text-white', removeBgHover: 'hover:bg-yellow-800', removeText: 'text-yellow-400', removeTextHover: 'hover:text-yellow-300', focusRing: 'ring-yellow-400' },
    },
    red: {
      light: { bg: 'bg-red-100', text: 'text-red-800', removeBgHover: 'hover:bg-red-200', removeText: 'text-red-400', removeTextHover: 'hover:text-red-500', focusRing: 'ring-red-500' },
      dark: { bg: 'bg-red-900', text: 'text-white', removeBgHover: 'hover:bg-red-800', removeText: 'text-red-400', removeTextHover: 'hover:text-red-300', focusRing: 'ring-red-400' },
    },
    purple: {
      light: { bg: 'bg-purple-100', text: 'text-purple-800', removeBgHover: 'hover:bg-purple-200', removeText: 'text-purple-400', removeTextHover: 'hover:text-purple-500', focusRing: 'ring-purple-500' },
      dark: { bg: 'bg-purple-900', text: 'text-white', removeBgHover: 'hover:bg-purple-800', removeText: 'text-purple-400', removeTextHover: 'hover:text-purple-300', focusRing: 'ring-purple-400' },
    },
  };
  
  const selected = mappings[props.color] || mappings.gray;

  return {
    light: {
      bg: selected.light.bg,
      text: selected.light.text,
      focusRing: selected.light.focusRing,
      removeButton: {
        bgHover: selected.light.removeBgHover,
        text: selected.light.removeText,
        textHover: selected.light.removeTextHover,
      }
    },
    dark: {
      bg: selected.dark.bg,
      text: selected.dark.text,
      focusRing: selected.dark.focusRing,
      removeButton: {
        bgHover: selected.dark.removeBgHover,
        text: selected.dark.removeText,
        textHover: selected.dark.removeTextHover,
      }
    }
  };
});

// --- Methods ---

const handleRemove = () => {
  emit('remove');
};
</script>

<style scoped>
/* Add any component-specific styles here if needed */
</style>