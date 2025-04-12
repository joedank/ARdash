<!--
  BaseButton component
  
  A customizable button component with support for different variants,
  sizes, loading states, and icons. Fully supports dark mode styling.
  
  @props {String} variant - Button style variant (primary, secondary, outline, text)
  @props {String} size - Button size (sm, md, lg)
  @props {Boolean} loading - Shows loading spinner when true
  @props {Boolean} disabled - Disables the button when true
  @props {String} type - HTML button type attribute (button, submit, reset)
  @props {Boolean} block - Makes the button full width
  @props {String} leftIcon - Icon to display on the left (optional)
  @props {String} rightIcon - Icon to display on the right (optional)
  @slots default - Button content
  @slots leftIcon - Custom left icon content
  @slots rightIcon - Custom right icon content
  
  @example
  <BaseButton variant="primary" size="md">
    Click Me
  </BaseButton>
  
  @example
  <BaseButton variant="outline" size="lg" :loading="isLoading" @click="handleClick">
    Save Changes
  </BaseButton>
-->

<template>
  <button
    :type="type"
    :disabled="disabled || loading"
    :class="[
      // Base styles
      'inline-flex items-center justify-center font-medium rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2',
      
      // Size variations
      sizeClasses,
      
      // Variant styles
      variantClasses,
      
      // Block style (full width)
      block ? 'w-full' : '',
      
      // Cursor style for loading/disabled
      (loading || disabled) ? 'cursor-not-allowed' : 'cursor-pointer'
    ]"
    @click="$emit('click', $event)"
  >
    <!-- Loading spinner -->
    <div v-if="loading" class="mr-2 animate-spin">
      <svg class="w-4 h-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
    </div>
    
    <!-- Left icon (slot or prop) -->
    <span v-if="!loading && (leftIcon || $slots.leftIcon)" class="mr-2">
      <slot name="leftIcon">
        <!-- This would be replaced with your icon system, for example: -->
        <span class="material-icons text-sm">{{ leftIcon }}</span>
      </slot>
    </span>
    
    <!-- Default slot for button content -->
    <slot></slot>
    
    <!-- Right icon (slot or prop) -->
    <span v-if="!loading && (rightIcon || $slots.rightIcon)" class="ml-2">
      <slot name="rightIcon">
        <!-- This would be replaced with your icon system, for example: -->
        <span class="material-icons text-sm">{{ rightIcon }}</span>
      </slot>
    </span>
  </button>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  variant: {
    type: String,
    default: 'primary',
    validator: (value) => ['primary', 'secondary', 'outline', 'text', 'danger'].includes(value)
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  },
  loading: {
    type: Boolean,
    default: false
  },
  disabled: {
    type: Boolean,
    default: false
  },
  type: {
    type: String,
    default: 'button',
    validator: (value) => ['button', 'submit', 'reset'].includes(value)
  },
  block: {
    type: Boolean,
    default: false
  },
  leftIcon: {
    type: String,
    default: ''
  },
  rightIcon: {
    type: String,
    default: ''
  }
});

defineEmits(['click']);

// Compute size classes based on size prop
const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'px-3 py-1.5 text-xs';
    case 'lg':
      return 'px-5 py-3 text-base';
    case 'md':
    default:
      return 'px-4 py-2 text-sm';
  }
});

// Compute variant classes based on variant prop
const variantClasses = computed(() => {
  // Base styles for each variant
  switch (props.variant) {
    case 'primary':
      return [
        // Light mode styles
        'bg-blue-600 hover:bg-blue-700 text-white',
        // Dark mode styles
        'dark:bg-blue-500 dark:hover:bg-blue-600',
        // Focus styles
        'focus:ring-blue-500 focus:ring-offset-2',
        // Disabled styles
        (props.disabled || props.loading) ? 'opacity-70 hover:bg-blue-600 dark:hover:bg-blue-500' : ''
      ].join(' ');
    
    case 'secondary':
      return [
        // Light mode styles
        'bg-gray-200 hover:bg-gray-300 text-gray-800',
        // Dark mode styles
        'dark:bg-gray-700 dark:hover:bg-gray-600 dark:text-gray-200',
        // Focus styles
        'focus:ring-gray-500 focus:ring-offset-2',
        // Disabled styles
        (props.disabled || props.loading) ? 'opacity-70 hover:bg-gray-200 dark:hover:bg-gray-700' : ''
      ].join(' ');
    
    case 'outline':
      return [
        // Light mode styles
        'bg-transparent border border-gray-300 hover:bg-gray-100 text-gray-700',
        // Dark mode styles
        'dark:border-gray-600 dark:hover:bg-gray-700 dark:text-gray-200 dark:hover:text-white',
        // Focus styles
        'focus:ring-gray-500 focus:ring-offset-2',
        // Disabled styles
        (props.disabled || props.loading) ? 'opacity-70 hover:bg-transparent dark:hover:bg-transparent' : ''
      ].join(' ');
    
    case 'text':
      return [
        // Light mode styles
        'bg-transparent hover:bg-gray-100 text-gray-700',
        // Dark mode styles
        'dark:hover:bg-gray-800 dark:text-gray-200',
        // Focus styles
        'focus:ring-gray-500 focus:ring-offset-0',
        // Disabled styles
        (props.disabled || props.loading) ? 'opacity-70 hover:bg-transparent dark:hover:bg-transparent' : ''
      ].join(' ');
    
    case 'danger':
      return [
        // Light mode styles
        'bg-red-600 hover:bg-red-700 text-white',
        // Dark mode styles
        'dark:bg-red-500 dark:hover:bg-red-600',
        // Focus styles
        'focus:ring-red-500 focus:ring-offset-2',
        // Disabled styles
        (props.disabled || props.loading) ? 'opacity-70 hover:bg-red-600 dark:hover:bg-red-500' : ''
      ].join(' ');
  }
});
</script>
