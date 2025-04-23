<template>
  <div 
    class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium" 
    :class="tagClasses"
  >
    {{ tag }}
    <button 
      v-if="removable" 
      @click="$emit('remove', tag)" 
      type="button"
      class="ml-1.5 focus:outline-none"
      :class="removeButtonClasses"
    >
      <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
      </svg>
    </button>
  </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  tag: {
    type: String,
    required: true
  },
  removable: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['remove']);

// Determine color based on tag content
const tagClasses = computed(() => {
  const lowerTag = props.tag.toLowerCase();
  
  if (lowerTag.includes('hazard') || lowerTag.includes('danger') || lowerTag.includes('asbestos') || lowerTag.includes('lead')) {
    return 'bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200';
  }
  
  if (lowerTag.includes('permit') || lowerTag.includes('license') || lowerTag.includes('code')) {
    return 'bg-amber-100 dark:bg-amber-900 text-amber-800 dark:text-amber-200';
  }
  
  if (lowerTag.includes('safety') || lowerTag.includes('caution') || lowerTag.includes('warning')) {
    return 'bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-200';
  }
  
  if (lowerTag.includes('electrical') || lowerTag.includes('plumbing') || lowerTag.includes('mechanical')) {
    return 'bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200';
  }
  
  return 'bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200';
});

// Button classes matching tag color
const removeButtonClasses = computed(() => {
  const lowerTag = props.tag.toLowerCase();
  
  if (lowerTag.includes('hazard') || lowerTag.includes('danger') || lowerTag.includes('asbestos') || lowerTag.includes('lead')) {
    return 'text-red-600 dark:text-red-400 hover:text-red-900 dark:hover:text-red-300';
  }
  
  if (lowerTag.includes('permit') || lowerTag.includes('license') || lowerTag.includes('code')) {
    return 'text-amber-600 dark:text-amber-400 hover:text-amber-900 dark:hover:text-amber-300';
  }
  
  if (lowerTag.includes('safety') || lowerTag.includes('caution') || lowerTag.includes('warning')) {
    return 'text-yellow-600 dark:text-yellow-400 hover:text-yellow-900 dark:hover:text-yellow-300';
  }
  
  if (lowerTag.includes('electrical') || lowerTag.includes('plumbing') || lowerTag.includes('mechanical')) {
    return 'text-blue-600 dark:text-blue-400 hover:text-blue-900 dark:hover:text-blue-300';
  }
  
  return 'text-green-600 dark:text-green-400 hover:text-green-900 dark:hover:text-green-300';
});
</script>