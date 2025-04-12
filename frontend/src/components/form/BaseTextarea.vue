<!--
  BaseTextarea component
  
  A customizable textarea component with support for different states,
  validation states, and helper text. Fully supports dark mode styling.
  
  @props {String} label - Textarea label
  @props {String} placeholder - Textarea placeholder
  @props {String} modelValue - v-model value
  @props {String} id - Textarea id attribute
  @props {String} name - Textarea name attribute
  @props {Number} rows - Number of rows to display
  @props {Boolean} required - Makes textarea required
  @props {Boolean} disabled - Disables the textarea
  @props {String} state - Validation state (success, error, warning)
  @props {String} helperText - Helper text to display below textarea
  @props {Boolean} block - Makes the textarea full width
  
  @events update:modelValue - Emitted when textarea value changes
  @events focus - Emitted when textarea is focused
  @events blur - Emitted when textarea loses focus
  
  @example
  <BaseTextarea
    v-model="description"
    label="Description"
    placeholder="Enter a description"
    rows="4"
    required
  />
  
  @example
  <BaseTextarea
    v-model="feedback"
    label="Feedback"
    state="error"
    helperText="Feedback is required"
    rows="3"
  />
-->

<template>
  <div :class="[block ? 'w-full' : '']">
    <!-- Label -->
    <label 
      v-if="label" 
      :for="textareaId" 
      class="block mb-2 text-sm font-medium text-gray-700 dark:text-gray-300"
    >
      {{ label }}
      <span v-if="required" class="text-red-500 dark:text-red-400">*</span>
    </label>
    
    <!-- Textarea Container -->
    <div class="relative">
      <!-- Textarea Field -->
      <textarea
        :id="textareaId"
        :name="name"
        :value="modelValue"
        :placeholder="placeholder"
        :rows="rows"
        :required="required"
        :disabled="disabled"
        :class="[
          // Base styles
          'block rounded-lg border transition-colors focus:outline-none focus:ring-2 w-full',
          
          // Padding
          'px-4 py-2',
          
          // Width
          block ? 'w-full' : '',
          
          // State-specific styling
          stateClasses,
          
          // Disabled styling
          disabled ? 'opacity-60 cursor-not-allowed bg-gray-100 dark:bg-gray-800' : 'bg-white dark:bg-gray-900'
        ]"
        @input="$emit('update:modelValue', $event.target.value)"
        @focus="$emit('focus', $event)"
        @blur="$emit('blur', $event)"
      ></textarea>
    </div>
    
    <!-- Helper Text / Error Message -->
    <p 
      v-if="helperText" 
      :class="[
        'mt-1 text-sm',
        state === 'error' ? 'text-red-600 dark:text-red-400' : 
        state === 'success' ? 'text-green-600 dark:text-green-400' : 
        state === 'warning' ? 'text-yellow-600 dark:text-yellow-400' : 
        'text-gray-500 dark:text-gray-400'
      ]"
    >
      {{ helperText }}
    </p>
  </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  label: {
    type: String,
    default: ''
  },
  placeholder: {
    type: String,
    default: ''
  },
  modelValue: {
    type: String,
    default: ''
  },
  id: {
    type: String,
    default: ''
  },
  name: {
    type: String,
    default: ''
  },
  rows: {
    type: [Number, String],
    default: 3
  },
  required: {
    type: Boolean,
    default: false
  },
  disabled: {
    type: Boolean,
    default: false
  },
  state: {
    type: String,
    default: '',
    validator: (value) => ['', 'success', 'error', 'warning'].includes(value)
  },
  helperText: {
    type: String,
    default: ''
  },
  block: {
    type: Boolean,
    default: true
  }
});

defineEmits(['update:modelValue', 'focus', 'blur']);

// Generate a unique ID if none is provided
const textareaId = computed(() => props.id || `textarea-${Math.random().toString(36).substr(2, 9)}`);

// Compute state-specific classes
const stateClasses = computed(() => {
  switch (props.state) {
    case 'success':
      return [
        'border-green-500 dark:border-green-500',
        'focus:border-green-500 focus:ring-green-500',
        'dark:focus:border-green-500 dark:focus:ring-green-400'
      ].join(' ');
    case 'error':
      return [
        'border-red-500 dark:border-red-500',
        'focus:border-red-500 focus:ring-red-500',
        'dark:focus:border-red-500 dark:focus:ring-red-400'
      ].join(' ');
    case 'warning':
      return [
        'border-yellow-500 dark:border-yellow-500',
        'focus:border-yellow-500 focus:ring-yellow-500',
        'dark:focus:border-yellow-500 dark:focus:ring-yellow-400'
      ].join(' ');
    default:
      return [
        'border-gray-300 dark:border-gray-700',
        'focus:border-blue-500 focus:ring-blue-500',
        'dark:focus:border-blue-500 dark:focus:ring-blue-400'
      ].join(' ');
  }
});
</script>
