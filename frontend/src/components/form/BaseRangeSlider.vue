/**
 * BaseRangeSlider
 * 
 * A customizable range slider component that supports both single value and range selection.
 * Features min/max values, step increments, and proper accessibility attributes.
 * 
 * @props {Number|String} modelValue - Current value(s) of the slider
 * @props {Number} min - Minimum allowed value
 * @props {Number} max - Maximum allowed value
 * @props {Number} step - Step increment value
 * @props {Boolean} range - Whether to enable range selection mode
 * @props {Boolean} disabled - Whether the slider is disabled
 * @props {String} label - Accessible label for the slider
 * 
 * @emits {update:modelValue} - Emitted when the value changes
 * @emits {change} - Emitted when interaction ends
 */

<template>
  <div class="relative">
    <!-- Label -->
    <label 
      v-if="label"
      :for="sliderId"
      class="block mb-2 text-sm font-medium text-gray-900 dark:text-gray-200"
    >
      {{ label }}
    </label>

    <!-- Value display -->
    <div class="flex justify-between mb-2 text-sm text-gray-600 dark:text-gray-400">
      <span>{{ displayValue }}</span>
      <span>{{ max }}</span>
    </div>

    <!-- Track and thumb -->
    <div
      ref="trackElementRef"
      class="relative h-2 mb-4"
      :class="[
        'rounded-full bg-gray-200 dark:bg-gray-700',
        disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'
      ]"
      @click="handleTrackClick"
    >
      <!-- Active track -->
      <div
        class="absolute h-full rounded-full bg-blue-600 dark:bg-blue-500"
        :style="trackStyle"
      ></div>

      <!-- Thumbs -->
      <template v-if="range">
        <button
          type="button"
          :id="`${sliderId}-start`"
          role="slider"
          :aria-label="`${label} start value`"
          :aria-valuemin="min"
          :aria-valuemax="max"
          :aria-valuenow="modelValue[0]"
          :aria-disabled="disabled"
          class="absolute top-1/2 -translate-x-1/2 -translate-y-1/2 w-4 h-4 rounded-full bg-white border-2 border-blue-600 dark:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400 focus:ring-offset-2"
          :class="[disabled ? 'cursor-not-allowed' : 'cursor-grab active:cursor-grabbing']"
          :style="{ left: `${getThumbPosition(modelValue[0])}%` }"
          @mousedown="startDrag($event, 'start')"
          @keydown="handleKeydown($event, 'start')"
          :disabled="disabled"
        ></button>
        <button
          type="button"
          :id="`${sliderId}-end`"
          role="slider"
          :aria-label="`${label} end value`"
          :aria-valuemin="min"
          :aria-valuemax="max"
          :aria-valuenow="modelValue[1]"
          :aria-disabled="disabled"
          class="absolute top-1/2 -translate-x-1/2 -translate-y-1/2 w-4 h-4 rounded-full bg-white border-2 border-blue-600 dark:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400 focus:ring-offset-2"
          :class="[disabled ? 'cursor-not-allowed' : 'cursor-grab active:cursor-grabbing']"
          :style="{ left: `${getThumbPosition(modelValue[1])}%` }"
          @mousedown="startDrag($event, 'end')"
          @keydown="handleKeydown($event, 'end')"
          :disabled="disabled"
        ></button>
      </template>
      <button
        v-else
        type="button"
        :id="sliderId"
        role="slider"
        :aria-label="label"
        :aria-valuemin="min"
        :aria-valuemax="max"
        :aria-valuenow="modelValue"
        :aria-disabled="disabled"
        class="absolute top-1/2 -translate-x-1/2 -translate-y-1/2 w-4 h-4 rounded-full bg-white border-2 border-blue-600 dark:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400 focus:ring-offset-2"
        :class="[disabled ? 'cursor-not-allowed' : 'cursor-grab active:cursor-grabbing']"
        :style="{ left: `${getThumbPosition(modelValue)}%` }"
        @mousedown="startDrag"
        @keydown="handleKeydown"
        :disabled="disabled"
      ></button>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue';

const props = defineProps({
  modelValue: {
    type: [Number, Array],
    required: true,
    validator: (value) => {
      if (Array.isArray(value)) {
        return value.length === 2 && value.every(v => typeof v === 'number');
      }
      return typeof value === 'number';
    }
  },
  min: {
    type: Number,
    default: 0
  },
  max: {
    type: Number,
    default: 100
  },
  step: {
    type: Number,
    default: 1
  },
  range: {
    type: Boolean,
    default: false
  },
  disabled: {
    type: Boolean,
    default: false
  },
  label: {
    type: String,
    default: ''
  }
});

const emit = defineEmits(['update:modelValue', 'change']);

// Generate unique ID for the slider
const sliderId = ref(`range-slider-${Math.random().toString(36).substr(2, 9)}`);

// Dragging state
const isDragging = ref(false);
const activeThumb = ref(null);
const trackElementRef = ref(null); // Ref for the track element

// Computed properties
const displayValue = computed(() => {
  if (props.range) {
    return `${props.modelValue[0]} - ${props.modelValue[1]}`;
  }
  return props.modelValue;
});

const trackStyle = computed(() => {
  if (props.range) {
    const start = getThumbPosition(props.modelValue[0]);
    const end = getThumbPosition(props.modelValue[1]);
    return {
      left: `${start}%`,
      width: `${end - start}%`
    };
  }
  return {
    width: `${getThumbPosition(props.modelValue)}%`
  };
});

// Methods
function getThumbPosition(value) {
  return ((value - props.min) / (props.max - props.min)) * 100;
}

function normalizeValue(value) {
  // Clamp value between min and max
  value = Math.min(Math.max(value, props.min), props.max);
  // Round to nearest step
  return Math.round(value / props.step) * props.step;
}

function calculateValueFromPosition(clientX, element) {
  const rect = element.getBoundingClientRect();
  const percentage = (clientX - rect.left) / rect.width;
  const rawValue = percentage * (props.max - props.min) + props.min;
  return normalizeValue(rawValue);
}

function startDrag(event, thumb = 'single') {
  if (props.disabled) return;
  
  isDragging.value = true;
  activeThumb.value = thumb;
  
  document.addEventListener('mousemove', handleDrag);
  document.addEventListener('mouseup', stopDrag);
}

function handleDrag(event) {
  if (!isDragging.value || !trackElementRef.value) return;

  const trackElement = trackElementRef.value; // Use the ref
  const newValue = calculateValueFromPosition(event.clientX, trackElement);
  updateValue(newValue);
}

function stopDrag() {
  if (isDragging.value) {
    isDragging.value = false;
    activeThumb.value = null;
    emit('change', props.modelValue);
    
    document.removeEventListener('mousemove', handleDrag);
    document.removeEventListener('mouseup', stopDrag);
  }
}

function handleTrackClick(event) {
  if (props.disabled) return;
  
  const trackElement = event.currentTarget; // The track div itself
  const newValue = calculateValueFromPosition(event.clientX, trackElement);
  
  if (props.range) {
    // Find closest thumb and update its value
    const distanceToStart = Math.abs(newValue - props.modelValue[0]);
    const distanceToEnd = Math.abs(newValue - props.modelValue[1]);
    activeThumb.value = distanceToStart < distanceToEnd ? 'start' : 'end';
  }
  
  updateValue(newValue);
  emit('change', props.modelValue);
}

function handleKeydown(event, thumb = 'single') {
  if (props.disabled) return;

  const step = event.shiftKey ? props.step * 10 : props.step;
  let newValue;

  switch (event.key) {
    case 'ArrowLeft':
    case 'ArrowDown':
      event.preventDefault();
      newValue = getCurrentValue(thumb) - step;
      break;
    case 'ArrowRight':
    case 'ArrowUp':
      event.preventDefault();
      newValue = getCurrentValue(thumb) + step;
      break;
    case 'Home':
      event.preventDefault();
      newValue = props.min;
      break;
    case 'End':
      event.preventDefault();
      newValue = props.max;
      break;
    default:
      return;
  }

  updateValue(normalizeValue(newValue), thumb);
  emit('change', props.modelValue);
}

function getCurrentValue(thumb) {
  if (!props.range) return props.modelValue;
  return thumb === 'start' ? props.modelValue[0] : props.modelValue[1];
}

function updateValue(newValue, thumb = activeThumb.value) {
  if (props.range) {
    const values = [...(Array.isArray(props.modelValue) ? props.modelValue : [props.min, props.max])];
    if (thumb === 'start') {
      values[0] = Math.min(newValue, values[1]);
    } else {
      values[1] = Math.max(newValue, values[0]);
    }
    emit('update:modelValue', values);
  } else {
    emit('update:modelValue', newValue);
  }
}
</script>