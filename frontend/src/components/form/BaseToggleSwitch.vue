<template>
  <label :for="inputId" class="flex items-center cursor-pointer group" :class="{ 'opacity-50 cursor-not-allowed': disabled }">
    <!-- The switch -->
    <div class="relative">
      <input 
        :id="inputId"
        type="checkbox" 
        class="sr-only" 
        :checked="modelValue"
        :disabled="disabled"
        @change="handleChange"
      >
      <!-- Line -->
      <div 
        class="block w-10 h-6 rounded-full transition-colors duration-200 ease-in-out"
        :class="[
          modelValue ? 'bg-blue-600 dark:bg-blue-500' : 'bg-gray-300 dark:bg-gray-600',
          disabled ? '' : 'group-hover:bg-opacity-80 dark:group-hover:bg-opacity-80'
        ]"
      ></div>
      <!-- Dot -->
      <div 
        class="absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition-transform duration-200 ease-in-out"
        :class="{ 'translate-x-4': modelValue }"
      ></div>
    </div>
    <!-- Label -->
    <div v-if="label || $slots.default" class="ml-3 text-sm font-medium text-gray-700 dark:text-gray-300">
      <slot>{{ label }}</slot>
    </div>
  </label>
</template>

<script setup>
import { computed } from 'vue';
import { generateId } from '@/utils/id';

/**
 * BaseToggleSwitch
 * 
 * A customizable toggle switch component for boolean inputs.
 * Supports v-model for easy two-way binding.
 * 
 * @props {Boolean} modelValue - The current state of the switch (v-model).
 * @props {String} label - Optional text label displayed next to the switch.
 * @props {String} id - Optional unique ID for the input element. Defaults to a generated ID.
 * @props {Boolean} disabled - Whether the switch is disabled.
 * 
 * @slots default - Used for the label content if the `label` prop is not provided.
 * 
 * @events update:modelValue - Emitted when the switch state changes. Payload: (Boolean) newState
 * 
 * @example
 * <!-- Basic Usage -->
 * <BaseToggleSwitch v-model="isActive" label="Enable Feature" />
 * 
 * <!-- Disabled State -->
 * <BaseToggleSwitch v-model="isOff" label="Disabled Option" :disabled="true" />
 * 
 * <!-- Using Slot for Label -->
 * <BaseToggleSwitch v-model="agreed">
 *   I agree to the <a href="#" class="text-blue-600 dark:text-blue-400">terms</a>
 * </BaseToggleSwitch>
 */

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  label: {
    type: String,
    default: ''
  },
  id: {
    type: String,
    default: null
  },
  disabled: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['update:modelValue']);

const inputId = computed(() => props.id || generateId('toggle-switch'));

const handleChange = (event) => {
  if (!props.disabled) {
    emit('update:modelValue', event.target.checked);
  }
};
</script>