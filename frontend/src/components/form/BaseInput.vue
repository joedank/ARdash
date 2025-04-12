<!--
  BaseInput component
  
  A customizable input field component with support for different types,
  validation states, icons, and helper text. Fully supports dark mode styling.
  
  @props {String} type - Input type (text, email, password, number, etc.)
  @props {String} label - Input label
  @props {String} placeholder - Input placeholder
  @props {String|Number} modelValue - v-model value
  @props {String} id - Input id attribute
  @props {String} name - Input name attribute
  @props {Boolean} required - Makes input required
  @props {Boolean} disabled - Disables the input
  @props {String} state - Validation state (success, error, warning)
  @props {String} helperText - Helper text to display below input
  @props {String} leftIcon - Icon to display on the left
  @props {String} rightIcon - Icon to display on the right
  @props {Boolean} block - Makes the input full width
  
  @slots leftIcon - Custom left icon content
  @slots rightIcon - Custom right icon content
  
  @events update:modelValue - Emitted when input value changes
  @events focus - Emitted when input is focused
  @events blur - Emitted when input loses focus
  
  @example
  <BaseInput
    v-model="email"
    type="email"
    label="Email Address"
    placeholder="Enter your email"
    required
  />
  
  @example
  <BaseInput
    v-model="password"
    type="password"
    label="Password"
    state="error"
    helperText="Password must be at least 8 characters"
    leftIcon="lock"
  />
-->

<template>
  <div :class="[block ? 'w-full' : '']">
    <!-- Label -->
    <label 
      v-if="label" 
      :for="inputId" 
      class="block mb-2 text-sm font-medium text-gray-700 dark:text-gray-300"
    >
      {{ label }}
      <span v-if="required" class="text-red-500 dark:text-red-400">*</span>
    </label>
    
    <!-- Input Container -->
    <div class="relative">
      <!-- Left Icon -->
      <div 
        v-if="leftIcon || $slots.leftIcon" 
        class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none"
      >
        <slot name="leftIcon">
          <!-- This would be replaced with your icon system, for example: -->
          <span class="material-icons text-gray-500 dark:text-gray-400 text-sm">{{ leftIcon }}</span>
        </slot>
      </div>
      
      <!-- Input Field -->
      <input
        :id="inputId"
        :name="name"
        :type="type"
        :value="modelValue"
        :placeholder="placeholder"
        :required="required"
        :disabled="disabled"
        :class="[
          // Base styles
          'block rounded-lg border transition-colors focus:outline-none focus:ring-2',
          
          // Padding adjustment for icons
          leftIcon || $slots.leftIcon ? 'pl-10' : 'pl-4',
          rightIcon || $slots.rightIcon ? 'pr-10' : 'pr-4',
          
          // Height
          'py-2',
          
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
      />
      
      <!-- Right Icon -->
      <div 
        v-if="rightIcon || $slots.rightIcon" 
        class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none"
      >
        <slot name="rightIcon">
          <!-- This would be replaced with your icon system, for example: -->
          <span class="material-icons text-gray-500 dark:text-gray-400 text-sm">{{ rightIcon }}</span>
        </slot>
      </div>
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
  type: {
    type: String,
    default: 'text'
  },
  label: {
    type: String,
    default: ''
  },
  placeholder: {
    type: String,
    default: ''
  },
  modelValue: {
    type: [String, Number],
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
  leftIcon: {
    type: String,
    default: ''
  },
  rightIcon: {
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
const inputId = computed(() => props.id || `input-${Math.random().toString(36).substr(2, 9)}`);

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
