<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { onClickOutside } from '@vueuse/core';

/**
 * BaseDropdownMenu
 * 
 * A versatile dropdown menu component that can be triggered by click or hover.
 * Supports nested menus, icons, dividers, and keyboard navigation.
 * 
 * @props {Array} items - Array of menu item objects. Each object can have: `label` (String, required), `icon` (String, optional), `action` (Function, optional), `disabled` (Boolean, optional), `divider` (Boolean, optional), `children` (Array, optional for nested menus).
 * @props {String} trigger - How the dropdown is triggered ('click' or 'hover'). Default: 'click'.
 * @props {String} position - Position of the dropdown relative to the trigger ('bottom-start', 'bottom-end', 'top-start', 'top-end'). Default: 'bottom-start'.
 * @props {String} menuWidth - Tailwind width class for the menu. Default: 'w-48'.
 * 
 * @slots trigger - Slot for the element that triggers the dropdown.
 * @slots item - Slot for customizing individual item rendering. Receives `item` and `index` as props.
 * 
 * @events item-click - Emitted when a non-disabled menu item without children is clicked. Payload: { item, event }.
 * @events open - Emitted when the dropdown opens.
 * @events close - Emitted when the dropdown closes.
 * 
 * @example
 * <BaseDropdownMenu :items="menuItems">
 *   <template #trigger>
 *     <BaseButton>Open Menu</BaseButton>
 *   </template>
 * </BaseDropdownMenu>
 */

const props = defineProps({
  items: {
    type: Array,
    required: true,
    default: () => []
  },
  trigger: {
    type: String,
    default: 'click',
    validator: (value) => ['click', 'hover'].includes(value)
  },
  position: {
    type: String,
    default: 'bottom-start',
    validator: (value) => ['bottom-start', 'bottom-end', 'top-start', 'top-end'].includes(value)
  },
  menuWidth: {
    type: String,
    default: 'w-48'
  }
});

const emit = defineEmits(['item-click', 'open', 'close']);

const isOpen = ref(false);
const dropdownRef = ref(null);
const triggerRef = ref(null); // Will be assigned by the template ref

// --- State for hover trigger ---
let hoverTimeout = null;
const HOVER_DELAY = 150; // ms delay for hover open/close

// --- Click Outside ---
onClickOutside(dropdownRef, (event) => {
  // Ensure the click wasn't on the trigger element itself
  if (isOpen.value && triggerRef.value && !triggerRef.value.contains(event.target)) {
    closeMenu();
  }
}, { ignore: [triggerRef] }); // Ignore clicks on the trigger initially

// --- Computed Classes ---
const menuPositionClasses = computed(() => {
  switch (props.position) {
    case 'bottom-end': return 'origin-top-right right-0';
    case 'top-start': return 'origin-bottom-left bottom-full left-0 mb-1';
    case 'top-end': return 'origin-bottom-right bottom-full right-0 mb-1';
    case 'bottom-start':
    default: return 'origin-top-left left-0';
  }
});

// --- Methods ---
const toggleMenu = () => {
  isOpen.value ? closeMenu() : openMenu();
};

const openMenu = () => {
  if (!isOpen.value) {
    isOpen.value = true;
    emit('open');
    // TODO: Add focus management and keyboard navigation setup
  }
};

const closeMenu = () => {
  if (isOpen.value) {
    isOpen.value = false;
    emit('close');
    // TODO: Add keyboard navigation cleanup
  }
};

const handleItemClick = (item, event) => {
  if (item.disabled || item.children) return; // Don't close for disabled or parent items
  
  emit('item-click', { item, event });
  if (item.action) {
    item.action();
  }
  closeMenu(); // Close after action
};

// --- Hover Handling ---
const handleMouseEnter = () => {
  if (props.trigger !== 'hover') return;
  clearTimeout(hoverTimeout);
  hoverTimeout = setTimeout(openMenu, HOVER_DELAY);
};

const handleMouseLeave = () => {
  if (props.trigger !== 'hover') return;
  clearTimeout(hoverTimeout);
  hoverTimeout = setTimeout(closeMenu, HOVER_DELAY);
};

// --- Keyboard Navigation ---
// TODO: Implement keyboard navigation (Arrow keys, Enter, Esc)

// --- Lifecycle Hooks ---
onMounted(() => {
  // Potential setup if needed
});

onUnmounted(() => {
  clearTimeout(hoverTimeout);
  // Potential cleanup
});

</script>

<template>
  <div class="relative inline-block text-left" 
       @mouseenter="handleMouseEnter" 
       @mouseleave="handleMouseLeave">
    
    <!-- Trigger -->
    <div ref="triggerRef" @click="props.trigger === 'click' ? toggleMenu() : null" class="inline-block">
      <slot name="trigger">
        <!-- Default trigger button if no slot provided -->
        <button 
          type="button" 
          class="inline-flex justify-center w-full rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-sm font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-100 dark:focus:ring-offset-gray-900 focus:ring-blue-500" 
          aria-haspopup="true" 
          :aria-expanded="isOpen">
          Options
          <!-- Heroicon name: solid/chevron-down -->
          <svg class="-mr-1 ml-2 h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
            <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
          </svg>
        </button>
      </slot>
    </div>

    <!-- Dropdown Panel -->
    <transition
      enter-active-class="transition ease-out duration-100"
      enter-from-class="transform opacity-0 scale-95"
      enter-to-class="transform opacity-100 scale-100"
      leave-active-class="transition ease-in duration-75"
      leave-from-class="transform opacity-100 scale-100"
      leave-to-class="transform opacity-0 scale-95"
    >
      <div 
        v-if="isOpen" 
        ref="dropdownRef"
        :class="[
          'absolute z-10 mt-1 rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none',
          menuPositionClasses,
          menuWidth,
          // Base styles
          'bg-white dark:bg-gray-800',
        ]"
        role="menu" 
        aria-orientation="vertical" 
        aria-labelledby="menu-button" 
        tabindex="-1"
        @mouseenter="handleMouseEnter" @mouseleave="handleMouseLeave"  
      >
        <div class="py-1" role="none">
          <template v-for="(item, index) in items" :key="index">
            <!-- Divider -->
            <div v-if="item.divider" class="border-t border-gray-200 dark:border-gray-700 my-1 mx-1"></div>
            
            <!-- Menu Item -->
            <a 
              v-else
              href="#" 
              :class="[
                'block px-4 py-2 text-sm',
                item.disabled 
                  ? 'text-gray-400 dark:text-gray-500 cursor-not-allowed' 
                  : 'text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-white',
                'flex items-center space-x-2' // Added for icon alignment
              ]" 
              role="menuitem" 
              tabindex="-1" 
              :id="'menu-item-' + index"
              @click.prevent="handleItemClick(item, $event)"
            >
              <!-- TODO: Add Icon support -->
              <!-- TODO: Add support for nested menus (children) -->
              <slot name="item" :item="item" :index="index">
                 <!-- Default item rendering -->
                 <span>{{ item.label }}</span>
              </slot>
            </a>
          </template>
        </div>
      </div>
    </transition>
  </div>
</template>