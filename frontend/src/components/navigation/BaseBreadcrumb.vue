/**
 * BaseBreadcrumb
 * 
 * Displays a breadcrumb navigation trail, typically used to show the user's
 * location within a website or application hierarchy.
 * 
 * @props {Array} items - An array of breadcrumb item objects. Each object should have `text` and optionally `href` or `to`.
 *   Example: [{ text: 'Home', to: '/' }, { text: 'Category' }, { text: 'Current Page' }]
 * @props {String} separator - The character or symbol used to separate breadcrumb items. Defaults to '/'.
 * 
 * @slots separator - Allows customizing the separator between items.
 * @slots item - Allows customizing the rendering of each breadcrumb item. Receives `item` and `index` as props.
 */
<template>
  <nav aria-label="Breadcrumb" class="text-sm font-medium text-gray-500 dark:text-gray-400">
    <ol class="flex items-center space-x-2">
      <li v-for="(item, index) in items" :key="index" class="flex items-center">
        <component 
          :is="getItemComponent(item)" 
          :to="item.to" 
          :href="item.href"
          :class="[
            'transition-colors',
            isLastItem(index) 
              ? 'text-gray-700 dark:text-gray-200' 
              : 'hover:text-gray-700 dark:hover:text-gray-200'
          ]"
          :aria-current="isLastItem(index) ? 'page' : undefined"
        >
          {{ item.text }}
        </component>
        
        <span v-if="!isLastItem(index)" class="mx-2" aria-hidden="true">
          <slot name="separator">
            {{ separator }}
          </slot>
        </span>
      </li>
    </ol>
  </nav>
</template>

<script setup>
import { computed } from 'vue';
import { RouterLink } from 'vue-router';

const props = defineProps({
  items: {
    type: Array,
    required: true,
    validator: (items) => Array.isArray(items) && items.every(item => typeof item === 'object' && item !== null && typeof item.text === 'string')
  },
  separator: {
    type: String,
    default: '/'
  }
});

const isLastItem = (index) => {
  return index === props.items.length - 1;
};

const getItemComponent = (item) => {
  if (item.to) {
    return RouterLink;
  } else if (item.href) {
    return 'a';
  } else {
    // For non-link items (like the last item or intermediate non-links)
    return 'span';
  }
};
</script>