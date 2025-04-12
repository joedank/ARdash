<!--
  BaseAlert component
  
  A customizable alert component for displaying feedback messages.
  Supports different variants (info, success, warning, error) and
  can be dismissible. Fully supports dark mode styling.
  
  @props {String} variant - Alert type (info, success, warning, error)
  @props {String} title - Alert title
  @props {String} message - Alert message
  @props {Boolean} dismissible - Whether the alert can be dismissed
  @props {Boolean} icon - Whether to show the variant icon
  @props {Number} autoClose - Auto close timer in milliseconds (0 to disable)
  
  @slots default - Alert content (overrides message prop)
  @slots title - Custom title
  @slots icon - Custom icon
  @slots actions - Additional actions, displayed after the content
  
  @events close - Emitted when the alert is closed
  
  @example
  <BaseAlert
    variant="success"
    title="Operation Successful"
    message="Your changes were saved successfully."
    dismissible
  />
  
  @example
  <BaseAlert variant="error" dismissible>
    <template #title>Error Encountered</template>
    <p>We couldn't process your request at this time.</p>
    <template #actions>
      <button class="underline text-sm">Retry</button>
    </template>
  </BaseAlert>
-->

<template>
  <transition
    enter-active-class="transition duration-300 ease-out"
    enter-from-class="transform -translate-y-2 opacity-0"
    enter-to-class="transform translate-y-0 opacity-100"
    leave-active-class="transition duration-200 ease-in"
    leave-from-class="transform translate-y-0 opacity-100"
    leave-to-class="transform -translate-y-2 opacity-0"
  >
    <div
      v-if="isVisible"
      :class="[
        // Base styles
        'rounded-lg px-4 py-3',
        
        // Variant styles
        variantClasses
      ]"
      role="alert"
    >
      <div class="flex">
        <!-- Icon -->
        <div v-if="showIcon" class="flex-shrink-0">
          <slot name="icon">
            <div 
              :class="[
                'flex items-center justify-center w-6 h-6 mr-3',
                variant === 'info' ? 'text-blue-500 dark:text-blue-400' :
                variant === 'success' ? 'text-green-500 dark:text-green-400' :
                variant === 'warning' ? 'text-yellow-500 dark:text-yellow-400' :
                variant === 'error' ? 'text-red-500 dark:text-red-400' : ''
              ]"
            >
              <!-- Info Icon -->
              <svg v-if="variant === 'info'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-5 h-5">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              
              <!-- Success Icon -->
              <svg v-else-if="variant === 'success'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-5 h-5">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              
              <!-- Warning Icon -->
              <svg v-else-if="variant === 'warning'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-5 h-5">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
              
              <!-- Error Icon -->
              <svg v-else-if="variant === 'error'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-5 h-5">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
          </slot>
        </div>
        
        <!-- Content -->
        <div class="flex-grow">
          <!-- Title -->
          <div v-if="hasTitle" class="font-medium mb-1">
            <slot name="title">{{ title }}</slot>
          </div>
          
          <!-- Message -->
          <div :class="hasTitle ? 'text-sm' : ''">
            <slot>{{ message }}</slot>
          </div>
          
          <!-- Actions -->
          <div v-if="slots.actions" class="mt-2">
            <slot name="actions"></slot>
          </div>
        </div>
        
        <!-- Close Button -->
        <div v-if="dismissible" class="flex-shrink-0 ml-2">
          <button
            type="button"
            class="inline-flex text-gray-500 dark:text-gray-400 focus:outline-none p-1 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700"
            @click="close"
            aria-label="Close"
          >
            <svg class="w-4 h-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { computed, ref, onMounted, onBeforeUnmount, useSlots } from 'vue';

const props = defineProps({
  variant: {
    type: String,
    default: 'info',
    validator: (value) => ['info', 'success', 'warning', 'error'].includes(value)
  },
  title: {
    type: String,
    default: ''
  },
  message: {
    type: String,
    default: ''
  },
  dismissible: {
    type: Boolean,
    default: false
  },
  icon: {
    type: Boolean,
    default: true
  },
  autoClose: {
    type: Number,
    default: 0 // 0 means don't auto-close
  }
});

const emit = defineEmits(['close']);

// State
const isVisible = ref(true);
let autoCloseTimeout = null;
const slots = useSlots();

// Computed Properties
const hasTitle = computed(() => {
  return props.title || (slots.title && !!slots.title);
});

const showIcon = computed(() => {
  return props.icon || (slots.icon && !!slots.icon);
});

const variantClasses = computed(() => {
  switch (props.variant) {
    case 'info':
      return 'bg-blue-50 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300';
    case 'success':
      return 'bg-green-50 dark:bg-green-900/30 text-green-800 dark:text-green-300';
    case 'warning':
      return 'bg-yellow-50 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300';
    case 'error':
      return 'bg-red-50 dark:bg-red-900/30 text-red-800 dark:text-red-300';
    default:
      return 'bg-blue-50 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300';
  }
});

// Methods
const close = () => {
  isVisible.value = false;
  emit('close');
  
  if (autoCloseTimeout) {
    clearTimeout(autoCloseTimeout);
    autoCloseTimeout = null;
  }
};

// Lifecycle Hooks
onMounted(() => {
  if (props.autoClose > 0) {
    autoCloseTimeout = setTimeout(() => {
      close();
    }, props.autoClose);
  }
});

onBeforeUnmount(() => {
  if (autoCloseTimeout) {
    clearTimeout(autoCloseTimeout);
    autoCloseTimeout = null;
  }
});
</script>
