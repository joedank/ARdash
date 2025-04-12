<template>
  <div class="relative w-full">
    <!-- Select trigger button -->
    <button
      type="button"
      class="w-full px-4 py-2.5 text-left rounded-lg transition-colors focus:outline-none focus:ring-2
             bg-white dark:bg-gray-900
             border border-gray-200 dark:border-gray-700
             text-gray-900 dark:text-white
             hover:bg-gray-50 dark:hover:bg-gray-800
             focus:ring-blue-500 dark:focus:ring-blue-400
             disabled:bg-gray-100 dark:disabled:bg-gray-800
             disabled:cursor-not-allowed disabled:opacity-75"
      :disabled="disabled"
      @click="toggleDropdown"
      @blur="handleBlur"
      :aria-expanded="isOpen"
      :aria-controls="dropdownId"
      ref="triggerRef"
    >
      <div class="flex items-center justify-between">
        <span v-if="displayValue" class="block truncate">{{ displayValue }}</span>
        <span v-else class="block truncate text-gray-500 dark:text-gray-400">{{ placeholder }}</span>
        <span class="pointer-events-none ml-2">
          <svg
            class="h-5 w-5 text-gray-400"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 20 20"
            fill="currentColor"
            aria-hidden="true"
          >
            <path
              fill-rule="evenodd"
              d="M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z"
              clip-rule="evenodd"
            />
          </svg>
        </span>
      </div>
    </button>

    <!-- Dropdown -->
    <div
      v-show="isOpen"
      :id="dropdownId"
      class="absolute z-10 w-full mt-1 rounded-lg shadow-lg
             bg-white dark:bg-gray-800
             border border-gray-200 dark:border-gray-700"
      @mousedown.prevent
    >
      <!-- Search input -->
      <div v-if="searchable" class="p-2">
        <input
          type="text"
          class="w-full px-3 py-2 rounded-md text-sm transition-colors
                 bg-gray-100 dark:bg-gray-700
                 text-gray-900 dark:text-white
                 focus:outline-none focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400"
          v-model="searchQuery"
          @input="handleSearch"
          :placeholder="searchPlaceholder"
          ref="searchInputRef"
        />
      </div>

      <!-- Options list -->
      <div
        class="max-h-60 overflow-auto scrollbar-thin scrollbar-thumb-gray-300 dark:scrollbar-thumb-gray-600"
      >
        <template v-if="hasGroups">
          <div v-for="group in filteredGroups" :key="group.label">
            <!-- Group label -->
            <div
              class="px-3 py-2 text-sm font-medium sticky top-0
                     bg-gray-50 dark:bg-gray-900
                     text-gray-700 dark:text-gray-400"
            >
              {{ group.label }}
            </div>
            <!-- Group options -->
            <template v-for="option in group.options" :key="getOptionValue(option)">
              <button
                type="button"
                class="w-full px-4 py-2 text-left text-sm transition-colors
                       text-gray-900 dark:text-white
                       hover:bg-gray-100 dark:hover:bg-gray-700"
                :class="{
                  'bg-blue-50 dark:bg-blue-900/50': isSelected(option),
                  'font-semibold': isSelected(option)
                }"
                @click="selectOption(option)"
              >
                <slot name="option" :option="option">
                  {{ getOptionLabel(option) }}
                </slot>
              </button>
            </template>
          </div>
        </template>
        <template v-else>
          <button
            v-for="option in filteredOptions"
            :key="getOptionValue(option)"
            type="button"
            class="w-full px-4 py-2 text-left text-sm transition-colors
                   text-gray-900 dark:text-white
                   hover:bg-gray-100 dark:hover:bg-gray-700"
            :class="{
              'bg-blue-50 dark:bg-blue-900/50': isSelected(option),
              'font-semibold': isSelected(option)
            }"
            @click="selectOption(option)"
          >
            <slot name="option" :option="option">
              {{ getOptionLabel(option) }}
            </slot>
          </button>
        </template>
      </div>

      <!-- Empty state -->
      <div
        v-if="showEmptyState"
        class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400 text-center"
      >
        No options available
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue';
import { generateId } from '../../utils/id';

const props = defineProps({
  modelValue: {
    type: [String, Number, Array],
    default: null
  },
  options: {
    type: Array,
    default: () => []
  },
  groups: {
    type: Array,
    default: () => []
  },
  placeholder: {
    type: String,
    default: 'Select an option'
  },
  searchPlaceholder: {
    type: String,
    default: 'Search...'
  },
  disabled: {
    type: Boolean,
    default: false
  },
  searchable: {
    type: Boolean,
    default: false
  },
  multiple: {
    type: Boolean,
    default: false
  },
  labelKey: {
    type: String,
    default: 'label'
  },
  valueKey: {
    type: String,
    default: 'value'
  }
});

const emit = defineEmits(['update:modelValue', 'search', 'focus', 'blur']);

// Refs
const triggerRef = ref(null);
const searchInputRef = ref(null);
const isOpen = ref(false);
const searchQuery = ref('');
const dropdownId = `select-${generateId()}`;

// Computed
const hasGroups = computed(() => props.groups && props.groups.length > 0);

const filteredGroups = computed(() => {
  if (!hasGroups.value) return [];
  
  return props.groups.map(group => ({
    ...group,
    options: filterOptions(group.options)
  })).filter(group => group.options.length > 0);
});

const filteredOptions = computed(() => {
  if (hasGroups.value) return [];
  return filterOptions(props.options);
});

const showEmptyState = computed(() => {
  if (hasGroups.value) {
    return filteredGroups.value.length === 0;
  }
  return filteredOptions.value.length === 0;
});

const displayValue = computed(() => {
  if (props.multiple && Array.isArray(props.modelValue)) {
    if (props.modelValue.length === 0) return '';
    if (props.modelValue.length === 1) {
      return getOptionLabel(findOption(props.modelValue[0]));
    }
    return `${props.modelValue.length} items selected`;
  }
  
  const selectedOption = findOption(props.modelValue);
  return selectedOption ? getOptionLabel(selectedOption) : '';
});

// Methods
function filterOptions(options) {
  if (!searchQuery.value) return options;
  
  return options.filter(option => 
    getOptionLabel(option)
      .toLowerCase()
      .includes(searchQuery.value.toLowerCase())
  );
}

function findOption(value) {
  const searchInOptions = (options) => {
    return options.find(option => getOptionValue(option) === value);
  };

  if (hasGroups.value) {
    for (const group of props.groups) {
      const found = searchInOptions(group.options);
      if (found) return found;
    }
    return null;
  }

  return searchInOptions(props.options);
}

function getOptionLabel(option) {
  return typeof option === 'object' ? option[props.labelKey] : option;
}

function getOptionValue(option) {
  return typeof option === 'object' ? option[props.valueKey] : option;
}

function isSelected(option) {
  const value = getOptionValue(option);
  if (props.multiple && Array.isArray(props.modelValue)) {
    return props.modelValue.includes(value);
  }
  return props.modelValue === value;
}

function selectOption(option) {
  const value = getOptionValue(option);
  
  if (props.multiple) {
    const newValue = Array.isArray(props.modelValue) ? [...props.modelValue] : [];
    const index = newValue.indexOf(value);
    
    if (index === -1) {
      newValue.push(value);
    } else {
      newValue.splice(index, 1);
    }
    
    emit('update:modelValue', newValue);
  } else {
    emit('update:modelValue', value);
    closeDropdown();
  }
}

function toggleDropdown() {
  if (props.disabled) return;
  
  if (!isOpen.value) {
    openDropdown();
  } else {
    closeDropdown();
  }
}

async function openDropdown() {
  isOpen.value = true;
  await nextTick();
  
  if (props.searchable && searchInputRef.value) {
    searchInputRef.value.focus();
  }
}

function closeDropdown() {
  isOpen.value = false;
  searchQuery.value = '';
}

function handleBlur(event) {
  // Check if the related target is within the component
  if (!event.relatedTarget || !event.currentTarget.contains(event.relatedTarget)) {
    closeDropdown();
    emit('blur', event);
  }
}

function handleSearch() {
  emit('search', searchQuery.value);
}

function handleClickOutside(event) {
  const el = triggerRef.value;
  if (el && !el.contains(event.target)) {
    closeDropdown();
  }
}

// Lifecycle
onMounted(() => {
  document.addEventListener('click', handleClickOutside);
});

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside);
});
</script>
