<!--
  BaseCard component
  
  A customizable card component with header, body, and footer sections.
  Supports various styling options and is fully compatible with dark mode.
  
  @props {String} title - Card title (displayed in header)
  @props {Boolean} withHeader - Whether to show the header
  @props {Boolean} withFooter - Whether to show the footer
  @props {String} variant - Card style variant (default, bordered, elevated)
  @props {Boolean} hover - Whether to apply hover effect
  @props {Boolean} clickable - Makes the entire card clickable (adds pointer cursor)
  
  @slots header - Custom header content (overrides title prop)
  @slots default - Main card content (body)
  @slots footer - Custom footer content
  
  @events click - Emitted when the card is clicked (if clickable)
  
  @example
  <BaseCard title="Card Title">
    <p>This is the card content.</p>
  </BaseCard>
  
  @example
  <BaseCard variant="elevated" hover clickable @click="handleCardClick">
    <template #header>
      <div class="flex justify-between items-center">
        <h3>Custom Header</h3>
        <button>⋮</button>
      </div>
    </template>
    <p>Card content goes here.</p>
    <template #footer>
      <div class="flex justify-end">
        <button class="text-blue-500">View More</button>
      </div>
    </template>
  </BaseCard>
-->

<template>
  <div 
    :class="[
      // Base styles
      'overflow-hidden rounded-lg transition-all',
      
      // Variant styles
      variantClasses,
      
      // Hover effect
      hover ? 'hover:shadow-lg dark:hover:shadow-gray-800/50 transition-shadow duration-200' : '',
      
      // Clickable style
      clickable ? 'cursor-pointer' : ''
    ]"
    @click="clickable ? $emit('click', $event) : null"
  >
    <!-- Card Header -->
    <div 
      v-if="withHeader || $slots.header || title" 
      class="px-4 py-3 border-b dark:border-gray-700"
    >
      <slot name="header">
        <h3 class="font-medium text-gray-800 dark:text-white">{{ title }}</h3>
      </slot>
    </div>
    
    <!-- Card Body -->
    <div class="p-4">
      <slot></slot>
    </div>
    
    <!-- Card Footer -->
    <div 
      v-if="withFooter || $slots.footer" 
      class="px-4 py-3 border-t dark:border-gray-700 bg-gray-50 dark:bg-gray-800"
    >
      <slot name="footer"></slot>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  title: {
    type: String,
    default: ''
  },
  withHeader: {
    type: Boolean,
    default: false
  },
  withFooter: {
    type: Boolean,
    default: false
  },
  variant: {
    type: String,
    default: 'default',
    validator: (value) => ['default', 'bordered', 'elevated'].includes(value)
  },
  hover: {
    type: Boolean,
    default: false
  },
  clickable: {
    type: Boolean,
    default: false
  }
});

defineEmits(['click']);

// Compute variant classes
const variantClasses = computed(() => {
switch (props.variant) {
case 'bordered':
return 'border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 shadow-sm';
case 'elevated':
return 'border border-gray-100 dark:border-gray-800 bg-white dark:bg-gray-900 shadow-md dark:shadow-gray-900/30';
case 'default':
default:
return 'bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-700';
}
});
</script>
