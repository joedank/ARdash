/**
 * BaseGridLayout
 * 
 * Provides a flexible grid and layout system using Tailwind CSS utilities.
 * Can function as a responsive container, a flex row, or a grid column.
 * 
 * @props {String} tag - The HTML tag to use for the element (default: 'div').
 * @props {Boolean} container - If true, applies container styles (max-width, padding).
 * @props {Boolean} row - If true, applies row styles (flex container for wrapping items). Typically used inside a container or another grid layout.
 * @props {Boolean} grid - If true, applies grid display styles. Often used as a parent for columns.
 * @props {String|Number|Object} cols - Defines column spans when used inside a `grid`. Accepts a number (e.g., 12), a string (e.g., 'span-6'), or an object for responsive spans (e.g., { default: 'span-12', sm: 'span-6', md: 'span-4' }). Uses Tailwind's `col-span-*` utilities.
 * @props {String|Number|Object} gridCols - Defines the number of columns in a `grid` container. Accepts a number (e.g., 12) or an object for responsive column counts (e.g., { default: 1, sm: 2, md: 3 }). Uses Tailwind's `grid-cols-*` utilities.
 * @props {String|Number|Object} gap - Defines gap between grid or flex items. Accepts a number (Tailwind spacing unit, e.g., 4) or an object for responsive gaps (e.g., { default: 4, md: 6 }). Uses Tailwind's `gap-*` utilities.
 * @props {String|Number|Object} order - Defines the order of a flex or grid item. Accepts a number (e.g., 1) or an object for responsive order (e.g., { default: 2, md: 1 }). Uses Tailwind's `order-*` utilities.
 * 
 * @slots default - Content to be placed within the grid component.
 * 
 * @example
 * &lt;!-- Responsive Container --&gt;
 * &lt;BaseGridLayout container&gt;
 *   Content within a centered, max-width container with padding.
 * &lt;/BaseGridLayout&gt;
 *
 * &lt;!-- Simple Row (for flexbox layout) --&gt;
 * &lt;BaseGridLayout row gap="4"&gt;
 *   &lt;div&gt;Item 1&lt;/div&gt;
 *   &lt;div&gt;Item 2&lt;/div&gt;
 * &lt;/BaseGridLayout&gt;
 *
 * &lt;!-- Grid with Columns --&gt;
 * &lt;BaseGridLayout grid :gridCols="{ default: 1, md: 3 }" gap="6"&gt;
 *   &lt;BaseGridLayout :cols="{ default: 'span-1', md: 'span-1' }"&gt;Column 1&lt;/BaseGridLayout&gt;
 *   &lt;BaseGridLayout :cols="{ default: 'span-1', md: 'span-1' }"&gt;Column 2&lt;/BaseGridLayout&gt;
 *   &lt;BaseGridLayout :cols="{ default: 'span-1', md: 'span-1' }"&gt;Column 3&lt;/BaseGridLayout&gt;
 * &lt;/BaseGridLayout&gt;
 *
 * &lt;!-- Column within a Grid --&gt;
 * &lt;BaseGridLayout :cols="6" :order="{ default: 2, md: 1 }"&gt;
 *   This is a column taking half width on larger screens, ordered differently on mobile.
 * &lt;/BaseGridLayout&gt;
 */

<template>
  <component :is="props.tag" :class="componentClasses">
    <slot />
  </component>
</template>

<script>
// Validator function needs to be in a separate <script> block
// because defineProps in <script setup> cannot reference local variables.
function validateResponsiveProp(value) {
  if (value === null || typeof value === 'string' || typeof value === 'number') {
    return true;
  }
  if (typeof value === 'object') {
    // Allow standard Tailwind breakpoint keys plus 'default'
    const validKeys = ['default', 'sm', 'md', 'lg', 'xl', '2xl'];
    return Object.keys(value).every(key => validKeys.includes(key));
  }
  return false;
}
</script>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  tag: {
    type: String,
    default: 'div',
  },
  container: {
    type: Boolean,
    default: false,
  },
  row: {
    type: Boolean,
    default: false,
  },
  grid: {
    type: Boolean,
    default: false,
  },
  cols: {
    type: [String, Number, Object],
    default: null,
    validator: validateResponsiveProp, // Now references the function in the other script block
  },
  gridCols: {
    type: [String, Number, Object],
    default: null,
    validator: validateResponsiveProp,
  },
  gap: {
    type: [String, Number, Object],
    default: null,
    validator: validateResponsiveProp,
  },
  order: {
    type: [String, Number, Object],
    default: null,
    validator: validateResponsiveProp,
  },
});

// Helper to generate responsive Tailwind classes (remains in setup)
const generateResponsiveClasses = (propValue, prefix) => {
  if (propValue === null || propValue === undefined) return [];
  
  const classes = [];
  if (typeof propValue === 'object') {
    for (const bp in propValue) {
      const value = propValue[bp];
      if (value !== null && value !== undefined) {
        const className = `${prefix}${value}`;
        classes.push(bp === 'default' ? className : `${bp}:${className}`);
      }
    }
  } else {
     const value = propValue;
     if (value !== null && value !== undefined) {
        classes.push(`${prefix}${value}`);
     }
  }
  return classes;
};

const componentClasses = computed(() => {
  return [
    props.container ? 'max-w-7xl mx-auto px-4 sm:px-6 lg:px-8' : '',
    props.row ? 'flex flex-wrap' : '',
    props.grid ? 'grid' : '',
    ...generateResponsiveClasses(props.gridCols, 'grid-cols-'),
    ...generateResponsiveClasses(props.cols, 'col-span-'),
    ...generateResponsiveClasses(props.gap, 'gap-'),
    ...generateResponsiveClasses(props.order, 'order-'),
  ].filter(Boolean);
});
</script>