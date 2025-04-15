<template>
  <div class="relative inline-block text-left">
    <!-- Main button with dropdown -->
    <button 
      @click="toggleDropdown"
      class="inline-flex items-center justify-between px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 dark:bg-blue-500 dark:hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 w-full sm:w-auto"
    >
      <span class="flex items-center">
        <span v-if="icon" class="-ml-1 mr-2 h-5 w-5">
          <slot name="icon"></slot>
        </span>
        {{ buttonText }}
      </span>
      <svg class="ml-2 -mr-1 h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
        <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
      </svg>
    </button>

    <!-- Dropdown menu -->
    <div 
      v-if="isOpen"
      class="origin-top-right absolute right-0 mt-2 w-56 rounded-md shadow-lg bg-white dark:bg-gray-800 ring-1 ring-black ring-opacity-5 focus:outline-none z-50"
    >
      <div class="py-1" role="menu" aria-orientation="vertical" aria-labelledby="options-menu">
        <!-- Menu items from actions array -->
        <template v-for="(action, index) in actions" :key="index">
          <!-- Divider line -->
          <div v-if="action.divider" class="border-t border-gray-200 dark:border-gray-700 my-1"></div>
          
          <!-- Internal router link -->
          <router-link 
            v-else-if="action.to" 
            :to="action.to" 
            class="flex items-center px-4 py-2 text-sm text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700"
            role="menuitem"
            @click="closeDropdown"
          >
            <span v-if="action.icon" class="mr-3 h-5 w-5 text-gray-400 dark:text-gray-500" v-html="action.icon"></span>
            {{ action.text }}
          </router-link>
          
          <!-- Button for actions -->
          <button 
            v-else 
            class="flex w-full items-center px-4 py-2 text-sm text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700"
            role="menuitem"
            @click="handleAction(action)"
          >
            <span v-if="action.icon" class="mr-3 h-5 w-5 text-gray-400 dark:text-gray-500" v-html="action.icon"></span>
            {{ action.text }}
          </button>
        </template>
      </div>
    </div>
    
    <!-- Background overlay to close dropdown when clicking outside -->
    <div 
      v-if="isOpen" 
      class="fixed inset-0 z-40" 
      @click="closeDropdown"
    ></div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

// Define props
const props = defineProps({
  buttonText: {
    type: String,
    default: 'Actions'
  },
  icon: {
    type: Boolean,
    default: false
  },
  actions: {
    type: Array,
    required: true,
    // Each action should have:
    // { text: 'Action text', to: '/route' } - For router link
    // { text: 'Action text', action: () => {} } - For action function
    // { divider: true } - For divider line
    // Optionally, each can have an icon (HTML string)
  }
});

// Define emits
const emit = defineEmits(['action']);

// State
const isOpen = ref(false);

// Methods
const toggleDropdown = () => {
  isOpen.value = !isOpen.value;
};

const closeDropdown = () => {
  isOpen.value = false;
};

const handleAction = (action) => {
  if (action.action && typeof action.action === 'function') {
    action.action();
  } else {
    emit('action', action);
  }
  closeDropdown();
};
</script>

<style scoped>
/* Add any component-specific styles here */
</style>