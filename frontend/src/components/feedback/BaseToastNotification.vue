<template>
  <transition
    enter-active-class="transition ease-out duration-300"
    enter-from-class="transform opacity-0 scale-95"
    enter-to-class="transform opacity-100 scale-100"
    leave-active-class="transition ease-in duration-200"
    leave-from-class="transform opacity-100 scale-100"
    leave-to-class="transform opacity-0 scale-95"
  >
    <div
      v-if="isVisible"
      :class="[
        'fixed bottom-4 right-4 z-50 max-w-sm w-full p-4 rounded-lg shadow-lg',
        'border',
        // Base styles
        'text-sm',
        // Type specific styles
        typeClasses,
        // Light mode
        'bg-white border-gray-200 text-gray-900',
        // Dark mode
        'dark:bg-gray-800 dark:border-gray-700 dark:text-white'
      ]"
      role="alert"
      aria-live="assertive"
      aria-atomic="true"
    >
      <div class="flex items-start">
        <div class="flex-shrink-0">
          <component :is="iconComponent" :class="['h-5 w-5', iconColorClass]" aria-hidden="true" />
        </div>
        <div class="ml-3 flex-1 pt-0.5">
          <p class="font-medium">{{ title }}</p>
          <p class="mt-1 text-gray-700 dark:text-gray-300">{{ message }}</p>
        </div>
        <div class="ml-4 flex-shrink-0 flex">
          <button
            v-if="dismissible"
            @click="dismiss"
            :class="[
              'inline-flex rounded-md p-1.5',
              'focus:outline-none focus:ring-2 focus:ring-offset-2',
               // Light mode
              'text-gray-400 hover:text-gray-500 focus:ring-blue-500 focus:ring-offset-white',
               // Dark mode
              'dark:text-gray-500 dark:hover:text-gray-400 dark:focus:ring-blue-600 dark:focus:ring-offset-gray-800',
              typeFocusRingClass
            ]"
          >
            <span class="sr-only">Dismiss</span>
            <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import {
  CheckCircleIcon,
  XCircleIcon,
  ExclamationTriangleIcon,
  InformationCircleIcon
} from '@heroicons/vue/24/outline';

/**
 * BaseToastNotification
 *
 * Displays temporary messages (toasts) to provide feedback to the user.
 * Supports different types (success, error, warning, info), automatic dismissal,
 * and manual dismissal via a close button.
 *
 * @props {String} id - Unique identifier for the toast. Required for managing multiple toasts.
 * @props {String} type - Type of toast ('success', 'error', 'warning', 'info'). Default: 'info'.
 * @props {String} title - The main title/heading for the toast.
 * @props {String} message - The detailed message content of the toast. Required.
 * @props {Number} duration - Duration in milliseconds before auto-dismissal. 0 means no auto-dismiss. Default: 5000.
 * @props {Boolean} dismissible - Whether the toast can be manually dismissed. Default: true.
 *
 * @emits close - Emitted when the toast is dismissed, passing the toast id.
 */

const props = defineProps({
  id: {
    type: [String, Number],
    required: true,
  },
  type: {
    type: String,
    default: 'info',
    validator: (value) => ['success', 'error', 'warning', 'info'].includes(value),
  },
  title: {
    type: String,
    default: '',
  },
  message: {
    type: String,
    required: true,
  },
  duration: {
    type: Number,
    default: 5000, // 5 seconds, 0 for persistent
  },
  dismissible: {
    type: Boolean,
    default: true,
  },
});

const emit = defineEmits(['close']);

const isVisible = ref(false);
let timer = null;

const typeStyles = {
  success: {
    icon: CheckCircleIcon,
    iconColor: 'text-green-500 dark:text-green-400',
    focusRing: 'focus:ring-green-500 dark:focus:ring-green-600',
  },
  error: {
    icon: XCircleIcon,
    iconColor: 'text-red-500 dark:text-red-400',
    focusRing: 'focus:ring-red-500 dark:focus:ring-red-600',
  },
  warning: {
    icon: ExclamationTriangleIcon,
    iconColor: 'text-yellow-500 dark:text-yellow-400',
    focusRing: 'focus:ring-yellow-500 dark:focus:ring-yellow-600',
  },
  info: {
    icon: InformationCircleIcon,
    iconColor: 'text-blue-500 dark:text-blue-400',
    focusRing: 'focus:ring-blue-500 dark:focus:ring-blue-600',
  },
};

const iconComponent = computed(() => typeStyles[props.type]?.icon || InformationCircleIcon);
const iconColorClass = computed(() => typeStyles[props.type]?.iconColor || typeStyles.info.iconColor);
const typeFocusRingClass = computed(() => typeStyles[props.type]?.focusRing || typeStyles.info.focusRing);

// Placeholder for potential type-specific background/border classes if needed later
const typeClasses = computed(() => {
  return '';
});

const dismiss = () => {
  clearTimeout(timer);
  isVisible.value = false;
  // Delay emit to allow leave transition
  setTimeout(() => {
    emit('close', props.id);
  }, 300); // Match transition duration
};

const startTimer = () => {
  if (props.duration > 0) {
    clearTimeout(timer); // Clear existing timer if props change
    timer = setTimeout(dismiss, props.duration);
  }
};

onMounted(() => {
  isVisible.value = true;
  startTimer();
});

// Restart timer if duration changes while visible
watch(() => props.duration, (newDuration) => {
  if (isVisible.value && newDuration > 0) {
    startTimer();
  } else if (isVisible.value && newDuration <= 0) {
    clearTimeout(timer); // Stop timer if duration becomes 0 or less
  }
});

// Expose dismiss function if needed externally (though usually handled by duration/button)
defineExpose({ dismiss });
</script>