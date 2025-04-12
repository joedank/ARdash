/**
 * BaseCheckboxRadio
 * 
 * A versatile component for rendering single checkboxes, groups of checkboxes, 
 * or radio button groups. Supports custom styling, indeterminate state for checkboxes, 
 * and disabled states. Integrates with v-model for easy form handling.
 * 
 * @props {String} type - The type of input ('checkbox' or 'radio'). Default: 'checkbox'.
 * @props {String|Number|Boolean|Array} modelValue - The bound value using v-model. For checkbox groups, this should be an array.
 * @props {String|Number|Boolean} value - The value associated with this specific checkbox or radio button. Required.
 * @props {String} [label] - The text label displayed next to the input.
 * @props {String} [name] - The name attribute, primarily used for grouping radio buttons.
 * @props {Boolean} [disabled=false] - Whether the input is disabled.
 * @props {Boolean} [indeterminate=false] - (Checkbox only) Whether the checkbox is in an indeterminate state.
 * 
 * @slots label - Allows custom content for the label instead of the `label` prop.
 * 
 * @events update:modelValue - Emitted when the state changes, used for v-model.
 * 
 * @example
 * <!-- Single Checkbox -->
 * <BaseCheckboxRadio v-model="isChecked" value="agreed" label="I agree" />
 * 
 * <!-- Checkbox Group -->
 * <BaseCheckboxRadio type="checkbox" v-model="selectedOptions" value="option1" label="Option 1" />
 * <BaseCheckboxRadio type="checkbox" v-model="selectedOptions" value="option2" label="Option 2" />
 * 
 * <!-- Radio Group -->
 * <BaseCheckboxRadio type="radio" v-model="selectedChoice" value="choiceA" name="choices" label="Choice A" />
 * <BaseCheckboxRadio type="radio" v-model="selectedChoice" value="choiceB" name="choices" label="Choice B" />
 * 
 * <!-- Indeterminate Checkbox -->
 * <BaseCheckboxRadio :indeterminate="isIndeterminate" v-model="parentCheck" label="Select All" />
 * 
 * <!-- Disabled -->
 * <BaseCheckboxRadio v-model="someValue" value="val" label="Cannot change" disabled />
 */
<template>
  <label 
    class="inline-flex items-center cursor-pointer"
    :class="{ 'opacity-50 cursor-not-allowed': disabled }"
  >
    <input
      :type="type"
      :value="value"
      :checked="isChecked"
      :name="name"
      :disabled="disabled"
      ref="inputRef"
      @change="handleChange"
      class="form-checkboxradio" 
      :class="[
        'rounded transition duration-150 ease-in-out',
        // Base styles
        'border-gray-300 dark:border-gray-600',
        'focus:ring-blue-500 dark:focus:ring-blue-400 focus:ring-offset-0 focus:ring-2',
        // Checked state colors
        type === 'checkbox' 
          ? 'text-blue-600 dark:text-blue-500' 
          : 'text-blue-600 dark:text-blue-500', // Radio buttons often use the same color
        // Background colors (browser handles checked state background, but we might need overrides)
        'bg-white dark:bg-gray-700 dark:checked:bg-blue-500',
        // Disabled state
        disabled ? 'bg-gray-100 dark:bg-gray-800 cursor-not-allowed' : 'cursor-pointer'
      ]"
    />
    <span 
      v-if="label || $slots.label" 
      class="ml-2 text-gray-700 dark:text-gray-300"
    >
      <slot name="label">{{ label }}</slot>
    </span>
  </label>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue';

const props = defineProps({
  type: {
    type: String,
    default: 'checkbox',
    validator: (value) => ['checkbox', 'radio'].includes(value)
  },
  modelValue: {
    type: [String, Number, Boolean, Array],
    default: null
  },
  value: {
    type: [String, Number, Boolean],
    required: true
  },
  label: {
    type: String,
    default: ''
  },
  name: {
    type: String,
    default: null
  },
  disabled: {
    type: Boolean,
    default: false
  },
  indeterminate: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['update:modelValue']);
const inputRef = ref(null);

const isChecked = computed(() => {
  if (props.type === 'checkbox') {
    if (Array.isArray(props.modelValue)) {
      return props.modelValue.includes(props.value);
    }
    // Handle single checkbox boolean case
    return Boolean(props.modelValue); 
  } else { // radio
    return props.modelValue === props.value;
  }
});

const handleChange = (event) => {
  if (props.disabled) return;

  let newValue;
  if (props.type === 'checkbox') {
    if (Array.isArray(props.modelValue)) {
      const currentValues = [...props.modelValue];
      if (event.target.checked) {
        currentValues.push(props.value);
      } else {
        const index = currentValues.indexOf(props.value);
        if (index > -1) {
          currentValues.splice(index, 1);
        }
      }
      newValue = currentValues;
    } else {
      // Handle single checkbox boolean toggle
      newValue = event.target.checked;
    }
  } else { // radio
    newValue = props.value;
  }
  emit('update:modelValue', newValue);
};

// Handle indeterminate state for checkboxes
watch(() => props.indeterminate, (newVal) => {
  if (props.type === 'checkbox' && inputRef.value) {
    inputRef.value.indeterminate = newVal;
  }
});

onMounted(() => {
  if (props.type === 'checkbox' && inputRef.value) {
    inputRef.value.indeterminate = props.indeterminate;
  }
});
</script>

<style scoped>
/* Add any component-specific styles here if needed */
/* Using Tailwind utilities directly is preferred */
.form-checkboxradio {
  /* Potential custom base styles if Tailwind classes aren't enough */
  /* Example: Adjust size */
  /* width: 1.125rem; */
  /* height: 1.125rem; */
}
</style>