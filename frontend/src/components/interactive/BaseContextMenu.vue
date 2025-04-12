/**
 * BaseContextMenu
 * 
 * A component that displays a context menu, typically triggered by a right-click event.
 * It allows users to perform actions related to the element it's attached to.
 * 
 * @props {Array} items - An array of objects representing the menu items. Each object should have properties like `label`, `icon`, `action`, `disabled`.
 * @props {Object} position - An object with `x` and `y` coordinates to position the menu.
 * @props {Boolean} visible - Controls the visibility of the context menu.
 * 
 * @slots trigger - The element that triggers the context menu (e.g., via right-click).
 * @slots item - Allows custom rendering for each menu item. Receives `item` and `index` as props.
 * 
 * @events select - Emitted when a menu item is selected. Passes the selected item object.
 * @events close - Emitted when the context menu should be closed (e.g., click outside).
 * 
 * @example
 * &lt;BaseContextMenu :items="menuItems" :position="menuPosition" :visible="isMenuVisible" @select="handleSelect" @close="isMenuVisible = false"&gt;
 *   &lt;template #trigger&gt;
 *     &lt;div @contextmenu.prevent="showMenu"&gt;Right-click me&lt;/div&gt;
 *   &lt;/template&gt;
 * &lt;/BaseContextMenu&gt;
 */
<template>
  <!-- Context menu structure will go here -->
  <div v-if="visible" 
       class="absolute z-50 min-w-[150px] rounded-md shadow-lg 
              bg-white dark:bg-gray-800 
              border border-gray-200 dark:border-gray-700
              py-1"
       :style="{ top: `${position.y}px`, left: `${position.x}px` }"
       @click.stop>
    <ul>
      <li v-for="(item, index) in items" :key="index">
        <button 
          @click="handleItemClick(item)"
          :disabled="item.disabled"
          class="w-full text-left px-4 py-2 text-sm flex items-center space-x-2
                 text-gray-700 dark:text-gray-200 
                 hover:bg-gray-100 dark:hover:bg-gray-700
                 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <!-- Basic item rendering, can be customized via slot -->
          <span v-if="item.icon" class="w-4 h-4" :class="item.icon"></span> <!-- Placeholder for icon -->
          <span>{{ item.label }}</span>
        </button>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue';

const props = defineProps({
  items: {
    type: Array,
    required: true,
    default: () => [],
    validator: (items) => Array.isArray(items) && items.every(item => typeof item === 'object' && item !== null && 'label' in item)
  },
  position: {
    type: Object,
    required: true,
    default: () => ({ x: 0, y: 0 }),
    validator: (pos) => typeof pos === 'object' && pos !== null && 'x' in pos && 'y' in pos
  },
  visible: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['select', 'close']);

const handleItemClick = (item) => {
  if (!item.disabled) {
    emit('select', item);
    emit('close'); // Typically close after selection
  }
};

// Close menu when clicking outside
const handleClickOutside = (event) => {
  // This logic needs refinement to check if the click was truly outside the menu and its trigger
  if (props.visible) {
     // A more robust check would involve getting the menu element ref and checking event.target containment
     // For now, any click outside will close it if visible.
     // We might need the trigger element ref passed in or handled externally.
     emit('close');
  }
};

onMounted(() => {
  document.addEventListener('click', handleClickOutside);
  document.addEventListener('contextmenu', handleClickOutside); // Close on another context menu attempt
});

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside);
  document.removeEventListener('contextmenu', handleClickOutside);
});

// Potential improvements:
// - More robust click outside detection (using element refs)
// - Keyboard navigation (Arrow keys, Enter, Escape)
// - Positioning adjustments if menu goes off-screen
// - Handling nested menus
// - Custom item slot implementation
</script>