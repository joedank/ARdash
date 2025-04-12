/**
 * BaseSidebar
 * 
 * A responsive sidebar component that can be collapsed on desktop
 * and functions as a drawer on mobile devices (below the specified breakpoint).
 * Uses fixed positioning for the mobile drawer and relative/absolute for desktop layout integration.
 * 
 * @props {Boolean} modelValue - Controls the visibility of the sidebar drawer on mobile (v-model). True for open, false for closed.
 * @props {Boolean} collapsed - Controls the collapsed state on desktop (independent of modelValue). True for collapsed, false for expanded.
 * @props {String} mobileBreakpoint - Tailwind breakpoint below which the sidebar switches to drawer mode (default: 'lg'). E.g., 'lg' means drawer mode on screens smaller than 'lg'.
 * @props {String} width - Tailwind class for the width of the expanded sidebar (default: 'w-64').
 * @props {String} collapsedWidth - Tailwind class for the width of the collapsed sidebar (default: 'w-16').
 * @props {String} transitionDuration - CSS transition duration class (default: 'duration-300').
 * @props {Boolean} overlay - Show a backdrop overlay when the mobile drawer is open (default: true).
 * 
 * @slots default - Content for the main sidebar area (e.g., navigation links).
 * @slots header - Optional content for the top of the sidebar.
 * @slots footer - Optional content for the bottom of the sidebar.
 * 
 * @events update:modelValue (value: Boolean) - Emitted when the mobile drawer's open/closed state changes.
 * @events update:collapsed (value: Boolean) - Emitted when the desktop collapsed state changes.
 * 
 * @example
 * &lt;!-- Basic Usage with v-model for mobile and :collapsed for desktop --&gt;
 * &lt;BaseSidebar v-model="isMobileOpen" :collapsed="isDesktopCollapsed"&gt;
 *   &lt;template #header&gt;Logo&lt;/template&gt;
 *   Navigation Links...
 *   &lt;template #footer&gt;User Profile&lt;/template&gt;
 * &lt;/BaseSidebar&gt;
 */

<template>
  <div>
    <!-- Overlay for mobile drawer -->
    <transition name="fade">
      <div
        v-if="isMobile && modelValue && overlay"
        @click="closeMobileDrawer"
        :class="[
          'fixed inset-0 z-30 bg-black/50',
          `${mobileBreakpoint}:hidden` // Hide overlay on desktop+
        ]"
        aria-hidden="true"
      ></div>
    </transition>

    <!-- Sidebar -->
    <aside
      :class="[
        'flex flex-col h-screen overflow-y-auto bg-white dark:bg-gray-900 border-r border-gray-200 dark:border-gray-700 transition-all ease-in-out',
        props.transitionDuration,
        sidebarPositionClass, // Fixed for mobile, relative/absolute for desktop
        sidebarWidthClass,    // Dynamic width based on state and breakpoint
        sidebarTransformClass // Translate for mobile drawer
      ]"
      :aria-hidden="!modelValue && isMobile"
    >
      <!-- Header Slot -->
      <div v-if="$slots.header" class="p-4 border-b border-gray-200 dark:border-gray-700 flex-shrink-0">
        <slot name="header" :collapsed="isEffectivelyCollapsed" :isMobile="isMobile"></slot>
      </div>

      <!-- Default Slot (Main Content) -->
      <div class="flex-grow p-4 overflow-y-auto">
        <slot :collapsed="isEffectivelyCollapsed" :isMobile="isMobile"></slot>
      </div>

      <!-- Footer Slot -->
      <div v-if="$slots.footer" class="p-4 border-t border-gray-200 dark:border-gray-700 flex-shrink-0">
        <slot name="footer" :collapsed="isEffectivelyCollapsed" :isMobile="isMobile"></slot>
      </div>
    </aside>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';

const props = defineProps({
  modelValue: { // For mobile drawer visibility
    type: Boolean,
    default: false,
  },
  collapsed: { // For desktop collapsed state
    type: Boolean,
    default: false,
  },
  mobileBreakpoint: {
    type: String,
    default: 'lg', // Corresponds to Tailwind's lg: prefix (1024px)
  },
  width: {
    type: String,
    default: 'w-64', // e.g., 'w-64'
  },
  collapsedWidth: {
    type: String,
    default: 'w-16', // e.g., 'w-16'
  },
  transitionDuration: {
    type: String,
    default: 'duration-300',
  },
  overlay: {
    type: Boolean,
    default: true,
  },
});

const emit = defineEmits(['update:modelValue', 'update:collapsed']);

const isMobile = ref(false);

// --- Responsive Handling ---
const checkScreenSize = () => {
  // Map Tailwind breakpoints to pixel values (adjust if using custom theme)
  const breakpoints = {
    sm: 640,
    md: 768,
    lg: 1024,
    xl: 1280,
    '2xl': 1536,
  };
  const breakpointPx = breakpoints[props.mobileBreakpoint] || 1024; // Default to lg if invalid
  isMobile.value = window.innerWidth < breakpointPx;
};

onMounted(() => {
  checkScreenSize();
  window.addEventListener('resize', checkScreenSize);
});

onUnmounted(() => {
  window.removeEventListener('resize', checkScreenSize);
});

// --- Computed Classes ---

// Determines if the sidebar should visually appear collapsed (either mobile closed or desktop collapsed)
const isEffectivelyCollapsed = computed(() => {
  return isMobile.value ? !props.modelValue : props.collapsed;
});

// Dynamic width based on state and screen size
const sidebarWidthClass = computed(() => {
  if (isMobile.value) {
    return props.width; // Mobile drawer always uses the full width prop
  } else {
    return props.collapsed ? props.collapsedWidth : props.width; // Desktop uses collapsed or full width
  }
});

// Positioning: fixed for mobile drawer, typically relative/absolute for desktop integration
// Note: Desktop positioning might need adjustment based on the parent layout structure.
// This component assumes it's placed correctly within a flex/grid layout on desktop.
const sidebarPositionClass = computed(() => {
  // Fixed position for mobile drawer, hidden off-screen until opened
  // On desktop (>= mobileBreakpoint), it becomes relative to fit into the layout flow
  return `fixed inset-y-0 left-0 z-40 ${props.mobileBreakpoint}:relative ${props.mobileBreakpoint}:inset-auto ${props.mobileBreakpoint}:z-auto`;
});

// Transform for mobile drawer slide-in/out
const sidebarTransformClass = computed(() => {
  if (isMobile.value) {
    return props.modelValue ? 'translate-x-0' : '-translate-x-full';
  }
  return 'translate-x-0'; // No transform needed on desktop
});

// --- Event Handling ---

const closeMobileDrawer = () => {
  if (isMobile.value) {
    emit('update:modelValue', false);
  }
};

// Watch for external changes to modelValue (e.g., parent closing drawer)
watch(() => props.modelValue, (newValue) => {
  // Optional: Add body scroll lock logic here if needed for mobile drawer
});

// Watch for external changes to collapsed prop
watch(() => props.collapsed, (newValue) => {
  // This prop primarily controls desktop state, no direct action needed here
  // unless specific side effects are required on collapse/expand.
});

</script>

<style scoped>
/* Fade transition for the overlay */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>