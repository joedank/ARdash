/**
 * BaseAccordion
 * 
 * A vertically stacked set of interactive headings that each reveal a section of content.
 * Supports single or multiple open sections, custom icons, and smooth animations.
 * 
 * @props {Array} items - Array of objects, each with 'title' and 'content'. Example: [{ title: 'Item 1', content: 'Content 1' }]
 * @props {Boolean} multiple - Allow multiple sections to be open simultaneously. Default: false
 * @props {Array|String|Number} defaultOpen - Index(es) or key(s) of items to be open by default.
 * @props {String} tag - The HTML tag to use for the root element. Default: 'div'
 * 
 * @slots header - Slot for customizing the header of an accordion item. Receives 'item' and 'isOpen' props.
 * @slots content - Slot for customizing the content of an accordion item. Receives 'item' props.
 * @slots icon - Slot for customizing the expand/collapse icon. Receives 'isOpen' prop.
 * 
 * @events update:modelValue - Emitted when the open state changes. Passes the array of open item indices/keys.
 * @events change - Emitted when an item is opened or closed. Passes the item index/key and its new open state (true/false).
 * 
 * @example
 * &lt;BaseAccordion :items="accordionItems" /&gt;
 * 
 * &lt;!-- Example with multiple open and slots --&gt;
 * &lt;BaseAccordion 
 *   :items="accordionItems" 
 *   multiple 
 *   :default-open="[0, 2]"
 * &gt;
 *   &lt;template #header="{ item, isOpen }"&gt;
 *     &lt;strong&gt;{{ item.title }}&lt;/strong&gt; 
 *     &lt;span class="ml-2 text-sm text-gray-500"&gt;
 *       ({{ isOpen ? 'Open' : 'Closed' }})
 *     &lt;/span&gt;
 *   &lt;/template&gt;
 *   &lt;template #content="{ item }"&gt;
 *     &lt;p class="text-sm"&gt;{{ item.content }}&lt;/p&gt;
 *   &lt;/template&gt;
 * &lt;/BaseAccordion&gt;
 */
<template>
  <component :is="tag" class="border border-gray-200 dark:border-gray-700 rounded-md divide-y divide-gray-200 dark:divide-gray-700">
    <div v-for="(item, index) in items" :key="index" class="overflow-hidden">
      <button
        @click="toggleItem(index)"
        :aria-expanded="isOpen(index)"
        :aria-controls="`accordion-content-${index}`"
        :id="`accordion-header-${index}`"
        class="w-full flex justify-between items-center p-4 text-left text-gray-800 dark:text-gray-200 bg-gray-50 dark:bg-gray-800 hover:bg-gray-100 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400 transition-colors"
      >
        <slot name="header" :item="item" :isOpen="isOpen(index)">
          <span class="font-medium">{{ item.title }}</span>
        </slot>
        <slot name="icon" :isOpen="isOpen(index)">
          <svg 
            class="w-5 h-5 transform transition-transform duration-200 ease-in-out" 
            :class="{ 'rotate-180': isOpen(index) }"
            fill="none" 
            stroke="currentColor" 
            viewBox="0 0 24 24" 
            xmlns="http://www.w3.org/2000/svg"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
          </svg>
        </slot>
      </button>
      
      <!-- Basic transition - can be enhanced later -->
      <transition 
        name="accordion"
        @enter="onEnter"
        @after-enter="onAfterEnter"
        @leave="onLeave"
        @after-leave="onAfterLeave"
      >
        <div 
          v-show="isOpen(index)" 
          :id="`accordion-content-${index}`" 
          role="region" 
          :aria-labelledby="`accordion-header-${index}`"
          class="bg-white dark:bg-gray-900 text-gray-700 dark:text-gray-300 overflow-hidden"
        >
          <div class="p-4">
            <slot name="content" :item="item">
              <p>{{ item.content }}</p>
            </slot>
          </div>
        </div>
      </transition>
    </div>
  </component>
</template>

<script setup>
import { ref, computed, watch } from 'vue';

const props = defineProps({
  items: {
    type: Array,
    required: true,
    validator: (items) => items.every(item => typeof item === 'object' && item !== null && 'title' in item && 'content' in item)
  },
  multiple: {
    type: Boolean,
    default: false
  },
  defaultOpen: {
    type: [Array, String, Number],
    default: () => []
  },
  tag: {
    type: String,
    default: 'div'
  }
});

const emit = defineEmits(['update:modelValue', 'change']);

// Use Set for efficient add/delete, especially with multiple open items
const openItems = ref(new Set());

// Initialize open items based on defaultOpen prop
const initializeOpenItems = () => {
  openItems.value.clear();
  const defaults = Array.isArray(props.defaultOpen) ? props.defaultOpen : [props.defaultOpen];
  defaults.forEach(index => {
    if (index >= 0 && index < props.items.length) {
      if (props.multiple || openItems.value.size === 0) {
         openItems.value.add(index);
      }
    }
  });
   // Emit initial state if needed, converting Set to Array
  emit('update:modelValue', Array.from(openItems.value));
};

// Initialize on mount and watch for changes in defaultOpen or items
watch(() => [props.defaultOpen, props.items], initializeOpenItems, { immediate: true, deep: true });

const isOpen = (index) => {
  return openItems.value.has(index);
};

const toggleItem = (index) => {
  const currentlyOpen = isOpen(index);
  
  if (props.multiple) {
    if (currentlyOpen) {
      openItems.value.delete(index);
    } else {
      openItems.value.add(index);
    }
  } else {
    // Single mode: close others if opening a new one
    if (currentlyOpen) {
      openItems.value.delete(index);
    } else {
      openItems.value.clear();
      openItems.value.add(index);
    }
  }
  
  // Emit events
  emit('update:modelValue', Array.from(openItems.value)); // Emit array representation
  emit('change', index, !currentlyOpen);
};

// --- Transition Hooks ---
// These provide a basic height transition. More complex animations might need JS calculations.
const onEnter = (el) => {
  el.style.height = 'auto';
  const height = getComputedStyle(el).height;
  el.style.height = '0';
  // Force repaint to make sure the transition starts correctly
  getComputedStyle(el).height; 
  requestAnimationFrame(() => {
    el.style.height = height;
  });
};

const onAfterEnter = (el) => {
  el.style.height = 'auto'; // Allow content to resize if needed
};

const onLeave = (el) => {
  el.style.height = getComputedStyle(el).height;
  // Force repaint
  getComputedStyle(el).height;
  requestAnimationFrame(() => {
    el.style.height = '0';
  });
};

const onAfterLeave = (el) => {
   // Clean up if needed, though v-show handles display: none
};
</script>

<style scoped>
/* Basic height transition */
.accordion-enter-active,
.accordion-leave-active {
  transition: height 0.3s ease-in-out;
  overflow: hidden;
}

.accordion-enter-from,
.accordion-leave-to {
  height: 0;
}
</style>