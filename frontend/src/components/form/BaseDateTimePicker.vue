<template>
  <BaseFormGroup 
    :label="label"
    :input-id="pickerInputId" 
    :helper-text="helperText"
    :error="error"
    :required="required"
  >
    <DatePicker
      v-model="selectedDate" 
      :masks="masks"
      :min-date="minDate"
      :max-date="maxDate"
      :mode="calendarMode" 
      :is24hr="true"
      :popover="{ visibility: 'click', placement: 'bottom-start' }" 
      :disabled="disabled"
      :select-attribute="selectAttribute"
      :drag-attribute="dragAttribute"
      @dayclick="handleDayClick" 
      @drag="handleDrag" 
      :class="['base-date-picker', { 'dark': isDarkMode }]">  
      <template #default="{ inputValue, inputEvents }">
        <div class="relative">
          <input
            :id="pickerInputId"
            :value="singleInputValue"
            v-on="inputEvents"
            :placeholder="placeholder"
            :disabled="disabled"
            readonly
            :class="[
              // Base styles mimicking BaseInput
              'block w-full rounded-lg border transition-colors focus:outline-none focus:ring-2',
              'pl-4 pr-10 py-2', // Padding for text and icon
              // Default state styling
              'border-gray-300 dark:border-gray-700',
              'focus:border-blue-500 focus:ring-blue-500',
              'dark:focus:border-blue-500 dark:focus:ring-blue-400',
              // Disabled styling
              disabled 
                ? 'opacity-60 cursor-not-allowed bg-gray-100 dark:bg-gray-800' 
                : 'bg-white dark:bg-gray-900 text-gray-900 dark:text-white',
              'cursor-pointer' 
            ]"
            :aria-required="required"
            :aria-invalid="!!error"
            :aria-describedby="error ? errorId : undefined"
          />
          <!-- Suffix Icon -->
          <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
             <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400 dark:text-gray-500" viewBox="0 0 20 20" fill="currentColor">
               <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd" />
             </svg>
          </div>
        </div>
      </template>
    </DatePicker>

    <!-- Separate Time Input (only for single date + time mode) -->
    <div v-if="enableTime && !range && selectedDate instanceof Date" class="mt-2">
       <label :for="timeInputId" class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Time</label>
       <input 
         :id="timeInputId"
         type="time"
         v-model="timeValue"
         :disabled="disabled"
         class="form-input block w-full rounded-md border-gray-300 dark:border-gray-600
                bg-white dark:bg-gray-800 text-gray-900 dark:text-white
                focus:border-blue-500 dark:focus:border-blue-400
                focus:ring-1 focus:ring-blue-500 dark:focus:ring-blue-400 text-sm"
         @change="handleTimeChange"
       />
     </div>
  </BaseFormGroup>
</template>

<script setup>
import { ref, computed, watch } from 'vue';
import { DatePicker } from 'v-calendar';
import BaseFormGroup from './BaseFormGroup.vue';
import { generateId } from '@/utils/id';
import { format as formatDateFns } from 'date-fns'; 

// Props definition remains the same...
const props = defineProps({
  modelValue: { type: [Date, Object], default: null }, 
  label: { type: String, default: '' },
  helperText: { type: String, default: '' },
  error: { type: String, default: '' },
  required: { type: Boolean, default: false },
  minDate: { type: Date, default: null },
  maxDate: { type: Date, default: null },
  enableTime: { type: Boolean, default: false },
  range: { type: Boolean, default: false },
  disabled: { type: Boolean, default: false },
  placeholder: { type: String, default: 'Select Date' }
});

const emit = defineEmits(['update:modelValue', 'change']);

const pickerInputId = generateId();
const timeInputId = generateId();
const errorId = computed(() => props.error ? `error-${pickerInputId}` : undefined);

// --- v-calendar Configuration ---

const calendarMode = computed(() => {
  if (props.range) return 'range';
  if (props.enableTime) return 'dateTime';
  return 'date';
});

const DATE_FORMAT = 'yyyy-MM-dd';
const DATETIME_FORMAT = 'yyyy-MM-dd HH:mm';

const masks = computed(() => ({
  input: props.enableTime ? DATETIME_FORMAT : DATE_FORMAT,
}));

const isDarkMode = computed(() => {
  if (typeof window === 'undefined') return false;
  // Check for the class on the <html> element
  return document.documentElement.classList.contains('dark');
});

// --- Internal State ---

const initializeSelectedDate = () => {
    if (props.range) {
        return props.modelValue && typeof props.modelValue === 'object' 
               ? { start: props.modelValue.start || null, end: props.modelValue.end || null } 
               : { start: null, end: null };
    }
    return props.modelValue instanceof Date ? props.modelValue : null;
};

const selectedDate = ref(initializeSelectedDate());
const timeValue = ref(''); 

// --- Computed Values for Display ---

// Computed for single date or dateTime display
const singleInputValue = computed(() => {
    if (props.range || !(selectedDate.value instanceof Date)) return '';
    const formatString = props.enableTime ? DATETIME_FORMAT : DATE_FORMAT;
    return formatDateFns(selectedDate.value, formatString);
});

// Computed for range display
const rangeInputValue = computed(() => {
    if (!props.range || !selectedDate.value || typeof selectedDate.value !== 'object') return '';
    const { start, end } = selectedDate.value;
    if (!start) return ''; 
    const startFormatted = formatDateFns(start, DATE_FORMAT);
    if (!end) return startFormatted + ' -'; 
    const endFormatted = formatDateFns(end, DATE_FORMAT);
    return `${startFormatted} - ${endFormatted}`;
});


// --- Synchronization ---

const updateTimeValueFromDate = (date) => {
  if (props.enableTime && !props.range && date instanceof Date) {
    timeValue.value = formatDateFns(date, 'HH:mm');
  } else {
    timeValue.value = ''; 
  }
};

watch(() => props.modelValue, (newVal) => {
  const internalVal = initializeSelectedDate(); 
  if (JSON.stringify(newVal) !== JSON.stringify(internalVal)) {
      selectedDate.value = internalVal; 
  }
  updateTimeValueFromDate(newVal instanceof Date ? newVal : null); 
}, { deep: true }); 

watch(selectedDate, (newDateVal) => {
  if (calendarMode.value === 'dateTime' && newDateVal instanceof Date) {
     updateTimeValueFromDate(newDateVal);
  }
  if (JSON.stringify(newDateVal) !== JSON.stringify(props.modelValue)) {
      emit('update:modelValue', newDateVal);
  }
}, { deep: true });


// --- Event Handlers ---

const handleTimeChange = () => {
  if (calendarMode.value !== 'dateTime' || !(selectedDate.value instanceof Date) || !timeValue.value) {
      return; 
  }
  const [hours, minutes] = timeValue.value.split(':');
  const newDate = new Date(selectedDate.value); 
  newDate.setHours(parseInt(hours), parseInt(minutes), 0, 0); 
  selectedDate.value = newDate; 
};

const handleDayClick = (day) => {
    if (!props.range && day.date instanceof Date) {
        let finalDate = new Date(day.date);
         if (props.enableTime && timeValue.value) {
            const [hours, minutes] = timeValue.value.split(':');
            finalDate.setHours(parseInt(hours), parseInt(minutes), 0, 0);
         }
         if (selectedDate.value?.getTime() !== finalDate.getTime()) {
             selectedDate.value = finalDate; 
         }
        emit('change', finalDate); 
    }
};

// Range drag handler - v-model updates automatically, but let's emit too
const handleDrag = (range) => {
    if (props.range && range) {
        // Update internal ref (already done by v-model)
        // selectedDate.value = range;
        // Explicitly emit update during drag
        emit('update:modelValue', range);
    }
};


// --- Styling ---

const highlightDefaults = {
  color: isDarkMode.value ? 'blue' : 'blue', 
  fillMode: 'solid',
};

const selectAttribute = computed(() => ({
  highlight: {
    ...highlightDefaults,
    contentClass: isDarkMode.value ? 'text-gray-900' : 'text-white', 
  },
}));

const dragAttribute = computed(() => ({
    highlight: { 
        ...highlightDefaults,
        contentClass: isDarkMode.value ? 'text-gray-900' : 'text-white',
    },
}));

</script>

<style>
/* Define CSS variables using actual color values */
:root {
  --vc-font-family: inherit; 
  
  /* Light Mode Colors */
  --vc-color-white: #ffffff;
  --vc-color-black: #000000;
  --vc-color-gray-50: #f9fafb;
  --vc-color-gray-100: #f3f4f6;
  --vc-color-gray-200: #e5e7eb;
  --vc-color-gray-300: #d1d5db;
  --vc-color-gray-400: #9ca3af;
  --vc-color-gray-500: #6b7280;
  --vc-color-gray-600: #4b5563;
  --vc-color-gray-700: #374151;
  --vc-color-gray-800: #1f2937;
  --vc-color-gray-900: #111827;
  --vc-color-blue-100: #dbeafe;
  --vc-color-blue-500: #3b82f6; /* Primary Blue */
  --vc-color-blue-600: #2563eb;
  --vc-color-blue-700: #1d4ed8;

  /* Tailwind Specific Variables */
  --vc-rounded-lg: 0.5rem; 
  --vc-rounded-md: 0.375rem; 
  --vc-text-sm: 0.875rem; 
  --vc-font-medium: 500;
  --vc-font-semibold: 600;
  --vc-font-bold: 700;
}

/* Define Dark Mode Variables - These will be applied when .dark is on the component */
.dark.base-date-picker, 
.dark .base-date-picker { /* Target both scenarios */
  --vc-color-white: #000000; 
  --vc-color-black: #ffffff;
  --vc-color-gray-50: #111827; 
  --vc-color-gray-100: #1f2937;
  --vc-color-gray-200: #374151;
  --vc-color-gray-300: #4b5563;
  --vc-color-gray-400: #6b7280;
  --vc-color-gray-500: #9ca3af;
  --vc-color-gray-600: #d1d5db;
  --vc-color-gray-700: #e5e7eb;
  --vc-color-gray-800: #f3f4f6;
  --vc-color-gray-900: #f9fafb;
  --vc-color-blue-100: #1e3a8a; 
  --vc-color-blue-500: #60a5fa; 
  --vc-color-blue-600: #3b82f6;
  --vc-color-blue-700: #2563eb;
}

/* Apply variables to v-calendar elements */
.base-date-picker.vc-container {
  --vc-bg: var(--vc-color-white);
  --vc-border: var(--vc-color-gray-300);
  --vc-focus-ring-width: 0px; 
  
  border-radius: var(--vc-rounded-lg);
  border: 1px solid var(--vc-border);
  font-family: var(--vc-font-family);
  background-color: var(--vc-bg);
}
/* Apply dark mode overrides directly */
.dark.base-date-picker.vc-container,
.dark .base-date-picker.vc-container {
   --vc-bg: var(--vc-color-gray-900); 
   --vc-border: var(--vc-color-gray-700);
}

/* Header */
.base-date-picker .vc-header { padding: 10px 16px; }
.base-date-picker .vc-title {
  font-size: var(--vc-text-sm);
  font-weight: var(--vc-font-semibold);
  color: var(--vc-color-gray-900);
}
.dark.base-date-picker .vc-title,
.dark .base-date-picker .vc-title {
   color: var(--vc-color-gray-100);
}
.base-date-picker .vc-arrow {
  color: var(--vc-color-gray-600);
  border-radius: var(--vc-rounded-md);
}
.dark.base-date-picker .vc-arrow,
.dark .base-date-picker .vc-arrow {
   color: var(--vc-color-gray-400);
}
.base-date-picker .vc-arrow:hover { background-color: var(--vc-color-gray-100); }
.dark.base-date-picker .vc-arrow:hover,
.dark .base-date-picker .vc-arrow:hover {
   background-color: var(--vc-color-gray-700);
}

/* Weekdays */
.base-date-picker .vc-weekdays { padding: 5px 16px 10px; border-bottom: 1px solid var(--vc-border); }
.base-date-picker .vc-weekday {
  font-size: 11px; 
  font-weight: var(--vc-font-medium);
  color: var(--vc-color-gray-500);
  text-transform: uppercase;
}
.dark.base-date-picker .vc-weekday,
.dark .base-date-picker .vc-weekday {
  color: var(--vc-color-gray-400);
}

/* Weeks/Days */
.base-date-picker .vc-weeks { padding: 10px 16px 16px; }
.base-date-picker .vc-day { height: 36px; padding: 0; }
.base-date-picker .vc-day-content {
  width: 32px; height: 32px;
  font-size: var(--vc-text-sm);
  font-weight: var(--vc-font-medium);
  border-radius: var(--vc-rounded-md); 
  color: var(--vc-color-gray-800);
  line-height: 32px; 
}
.dark.base-date-picker .vc-day-content,
.dark .base-date-picker .vc-day-content {
  color: var(--vc-color-gray-200);
}
.base-date-picker .vc-day-content:hover:not(.is-disabled) { background-color: var(--vc-color-gray-100); }
.dark.base-date-picker .vc-day-content:hover:not(.is-disabled),
.dark .base-date-picker .vc-day-content:hover:not(.is-disabled) {
  background-color: var(--vc-color-gray-700);
}
.base-date-picker .vc-day-content:focus { outline: none; }

/* Highlight/Selection Styles */
.base-date-picker .vc-highlight {
  background-color: var(--vc-color-blue-500) !important; 
  border-radius: var(--vc-rounded-md) !important;
  width: 32px !important; height: 32px !important;
}
.dark.base-date-picker .vc-highlight,
.dark .base-date-picker .vc-highlight {
  background-color: var(--vc-color-blue-500) !important; 
}
.base-date-picker .vc-day-content.vc-highlight-content-solid { color: var(--vc-color-white) !important; }
.dark.base-date-picker .vc-day-content.vc-highlight-content-solid,
.dark .base-date-picker .vc-day-content.vc-highlight-content-solid {
  color: var(--vc-color-white) !important; 
}

/* Today's Date */
.base-date-picker .vc-day.is-today .vc-day-content { font-weight: var(--vc-font-bold); }

/* Disabled Dates */
.base-date-picker .vc-day.is-disabled .vc-day-content {
  color: var(--vc-color-gray-400); opacity: 0.6; pointer-events: none;
}
.dark.base-date-picker .vc-day.is-disabled .vc-day-content,
.dark .base-date-picker .vc-day.is-disabled .vc-day-content {
  color: var(--vc-color-gray-600);
}

/* Range Selection Background */
.base-date-picker .vc-highlight.vc-highlight-base-start,
.base-date-picker .vc-highlight.vc-highlight-base-end {
    background-color: var(--vc-color-blue-500); 
}
.base-date-picker .vc-highlight.vc-highlight-base-middle {
    background-color: var(--vc-color-blue-100); 
    border-radius: 0;
}
.dark.base-date-picker .vc-highlight.vc-highlight-base-middle,
.dark .base-date-picker .vc-highlight.vc-highlight-base-middle {
    background-color: rgba(96, 165, 250, 0.2); 
}

/* Range Selection Text Color */
.base-date-picker .vc-day.in-range:not(.is-start):not(.is-end) .vc-day-content { color: var(--vc-color-blue-700); }
.dark.base-date-picker .vc-day.in-range:not(.is-start):not(.is-end) .vc-day-content,
.dark .base-date-picker .vc-day.in-range:not(.is-start):not(.is-end) .vc-day-content {
    color: var(--vc-color-blue-100); 
}
.base-date-picker .vc-day.is-start .vc-day-content,
.base-date-picker .vc-day.is-end .vc-day-content { color: var(--vc-color-white); }
.dark.base-date-picker .vc-day.is-start .vc-day-content,
.dark .base-date-picker .vc-day.is-end .vc-day-content,
.dark .base-date-picker .vc-day.is-start .vc-day-content,
.dark .base-date-picker .vc-day.is-end .vc-day-content {
    color: var(--vc-color-white); 
}

</style>