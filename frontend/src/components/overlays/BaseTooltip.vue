/**
 * BaseTooltip
 * 
 * Displays a small informational box when hovering over or focusing on an element.
 * Supports multiple positions, custom delays, and rich content.
 * 
 * @props {String} content - Text content for the tooltip (alternative to content slot).
 * @props {String} position - Position of the tooltip relative to the trigger element ('top', 'bottom', 'left', 'right'). Default: 'top'.
 * @props {Number} delay - Delay in milliseconds before showing the tooltip on hover. Default: 0.
 * @props {String} maxWidth - Maximum width of the tooltip (e.g., '200px', 'auto'). Default: 'auto'.
 * @props {Boolean} disabled - If true, the tooltip will not be shown. Default: false.
 * 
 * @slots default - The trigger element for the tooltip.
 * @slots content - Rich content for the tooltip (overrides content prop).
 * 
 * @example
 * &lt;!-- Basic Usage --&gt;
 * &lt;BaseTooltip content="This is a tooltip"&gt;
 *   &lt;BaseButton&gt;Hover Me&lt;/BaseButton&gt;
 * &lt;/BaseTooltip&gt;
 * 
 * &lt;!-- With Custom Position and Delay --&gt;
 * &lt;BaseTooltip position="bottom" :delay="500"&gt;
 *   &lt;template #content&gt;
 *     &lt;div class="p-2"&gt;
 *       &lt;strong&gt;Rich Content&lt;/strong&gt;&lt;br /&gt;
 *       Supports &lt;em&gt;HTML&lt;/em&gt;.
 *     &lt;/div&gt;
 *   &lt;/template&gt;
 *   &lt;span&gt;Hover for rich tooltip&lt;/span&gt;
 * &lt;/BaseTooltip&gt;
 */

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';
import { generateId } from '@/utils/id'; // Assuming a utility for unique IDs

const props = defineProps({
  content: {
    type: String,
    default: ''
  },
  position: {
    type: String,
    default: 'top',
    validator: (value) => ['top', 'bottom', 'left', 'right'].includes(value)
  },
  delay: {
    type: Number,
    default: 0
  },
  maxWidth: {
    type: String,
    default: 'auto'
  },
  disabled: {
    type: Boolean,
    default: false
  }
});

const slots = defineSlots();

const tooltipId = generateId('tooltip');
const triggerRef = ref(null);
const tooltipRef = ref(null);
const isVisible = ref(false);
let showTimeout = null;
let hideTimeout = null;

const hasContentSlot = computed(() => !!slots.content);

const showTooltip = () => {
  clearTimeout(hideTimeout);
  hideTimeout = null;
  if (props.disabled || isVisible.value) return;

  if (props.delay > 0) {
    showTimeout = setTimeout(() => {
      isVisible.value = true;
    }, props.delay);
  } else {
    isVisible.value = true;
  }
};

const hideTooltip = () => {
  clearTimeout(showTimeout);
  showTimeout = null;
  // Add a small delay before hiding to allow moving mouse between trigger and tooltip
  hideTimeout = setTimeout(() => {
    isVisible.value = false;
  }, 100); 
};

// Basic positioning classes (can be enhanced with Floating UI later)
const positionClasses = computed(() => {
  switch (props.position) {
    case 'bottom':
      return 'top-full left-1/2 -translate-x-1/2 mt-2';
    case 'left':
      return 'top-1/2 right-full -translate-y-1/2 mr-2';
    case 'right':
      return 'top-1/2 left-full -translate-y-1/2 ml-2';
    case 'top':
    default:
      return 'bottom-full left-1/2 -translate-x-1/2 mb-2';
  }
});

const tooltipStyles = computed(() => ({
  maxWidth: props.maxWidth
}));

// Add/Remove listeners
onMounted(() => {
  const triggerEl = triggerRef.value?.children[0]; // Get the actual trigger element inside the slot wrapper
  if (triggerEl) {
    triggerEl.addEventListener('mouseenter', showTooltip);
    triggerEl.addEventListener('mouseleave', hideTooltip);
    triggerEl.addEventListener('focus', showTooltip);
    triggerEl.addEventListener('blur', hideTooltip);
    triggerEl.setAttribute('aria-describedby', tooltipId);
  }
});

onUnmounted(() => {
  const triggerEl = triggerRef.value?.children[0];
  if (triggerEl) {
    triggerEl.removeEventListener('mouseenter', showTooltip);
    triggerEl.removeEventListener('mouseleave', hideTooltip);
    triggerEl.removeEventListener('focus', showTooltip);
    triggerEl.removeEventListener('blur', hideTooltip);
    triggerEl.removeAttribute('aria-describedby');
  }
  clearTimeout(showTimeout);
  clearTimeout(hideTimeout);
});

// Watch for disabled prop changes
watch(() => props.disabled, (isDisabled) => {
  if (isDisabled && isVisible.value) {
    isVisible.value = false;
  }
});
</script>

<template>
  <div class="inline-block relative" ref="triggerRef">
    <slot></slot> <!-- Trigger Element -->

    <transition
      enter-active-class="transition ease-out duration-100"
      enter-from-class="transform opacity-0 scale-95"
      enter-to-class="transform opacity-100 scale-100"
      leave-active-class="transition ease-in duration-75"
      leave-from-class="transform opacity-100 scale-100"
      leave-to-class="transform opacity-0 scale-95"
    >
      <div
        v-if="isVisible && (content || hasContentSlot)"
        ref="tooltipRef"
        :id="tooltipId"
        role="tooltip"
        :style="tooltipStyles"
        :class="[
          'absolute z-50 px-3 py-2 rounded-md shadow-lg text-sm',
          'bg-gray-800 text-white', // Light mode (using dark bg for contrast)
          'dark:bg-gray-700 dark:text-gray-100', // Dark mode
          positionClasses
        ]"
        @mouseenter="showTooltip" 
        @mouseleave="hideTooltip" 
      >
        <slot v-if="hasContentSlot" name="content"></slot>
        <span v-else>{{ content }}</span>
        <!-- Basic Arrow (can be improved) -->
        <div 
          :class="[
            'absolute w-2 h-2 bg-inherit transform rotate-45',
            props.position === 'top' ? 'bottom-[-4px] left-1/2 -translate-x-1/2' : '',
            props.position === 'bottom' ? 'top-[-4px] left-1/2 -translate-x-1/2' : '',
            props.position === 'left' ? 'right-[-4px] top-1/2 -translate-y-1/2' : '',
            props.position === 'right' ? 'left-[-4px] top-1/2 -translate-y-1/2' : ''
          ]"
        ></div>
      </div>
    </transition>
  </div>
</template>
