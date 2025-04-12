/**
 * BasePopover
 *
 * Displays rich content in a portal, triggered by hovering or clicking an element.
 * Useful for displaying additional information without cluttering the main interface.
 *
 * @props {String} position - Position of the popover relative to the trigger ('top', 'bottom', 'left', 'right'). Default: 'bottom'.
 * @props {String} trigger - How the popover is triggered ('hover', 'click'). Default: 'hover'.
 * @props {Number} delay - Delay in milliseconds before showing/hiding on hover. Default: 200.
 * @props {Boolean} disabled - Disables the popover functionality. Default: false.
 * @props {Boolean} showArrow - Whether to display an arrow pointing to the trigger element. Default: true.
 * @props {String} contentClass - Custom classes for the popover content container.
 *
 * @slots trigger - The element that triggers the popover.
 * @slots default - The content to display inside the popover.
 *
 * @events show - Emitted when the popover starts to show.
 * @events shown - Emitted when the popover is fully shown.
 * @events hide - Emitted when the popover starts to hide.
 * @events hidden - Emitted when the popover is fully hidden.
 *
 * @example
 * <!-- Example usage -->
 * &lt;BasePopover position="top" trigger="click"&gt;
 *   &lt;template #trigger&gt;
 *     &lt;BaseButton&gt;Click Me&lt;/BaseButton&gt;
 *   &lt;/template&gt;
 *   &lt;div&gt;Popover Content Here&lt;/div&gt;
 * &lt;/BasePopover&gt;
 */
<template>
  <div class="relative inline-block">
    <!-- Trigger Slot -->
    <div ref="triggerRef" @mouseenter="handleMouseEnter" @mouseleave="handleMouseLeave" @click="handleClick">
      <slot name="trigger"></slot>
    </div>

    <!-- Popover Content (using Teleport for better positioning) -->
    <Teleport to="body">
      <transition
        enter-active-class="transition ease-out duration-100"
        enter-from-class="transform opacity-0 scale-95"
        enter-to-class="transform opacity-100 scale-100"
        leave-active-class="transition ease-in duration-75"
        leave-from-class="transform opacity-100 scale-100"
        leave-to-class="transform opacity-0 scale-95"
        @after-enter="onShown"
        @after-leave="onHidden"
      >
        <div
          v-if="isVisible"
          ref="popoverRef"
          :class="[
            'absolute z-50',
            'rounded-md shadow-lg',
            'border',
            // Light mode
            'bg-white border-gray-200 text-gray-900',
            // Dark mode
            'dark:bg-gray-800 dark:border-gray-700 dark:text-white',
            contentClass
          ]"
          :style="popoverStyle"
          @mouseenter="handlePopoverMouseEnter"
          @mouseleave="handlePopoverMouseLeave"
        >
          <!-- Arrow -->
          <div
            v-if="showArrow"
            ref="arrowRef"
            :class="[
              'absolute w-2 h-2 transform rotate-45',
              // Light mode
              'bg-white border-gray-200',
              // Dark mode
              'dark:bg-gray-800 dark:border-gray-700',
              arrowPositionClass
            ]"
            :style="arrowStyle"
          ></div>
          <!-- Content Slot -->
          <div class="relative p-3 rounded-md">
             <slot></slot>
          </div>
        </div>
      </transition>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, computed, watch, nextTick } from 'vue';
import { useFloating, offset, flip, shift, arrow } from '@floating-ui/vue';

const props = defineProps({
  position: {
    type: String,
    default: 'bottom',
    validator: (value) => ['top', 'bottom', 'left', 'right'].includes(value),
  },
  trigger: {
    type: String,
    default: 'hover',
    validator: (value) => ['hover', 'click'].includes(value),
  },
  delay: {
    type: Number,
    default: 200,
  },
  disabled: {
    type: Boolean,
    default: false,
  },
  showArrow: {
    type: Boolean,
    default: true,
  },
  contentClass: {
    type: String,
    default: '',
  },
});

const emit = defineEmits(['show', 'shown', 'hide', 'hidden']);

const isVisible = ref(false);
const triggerRef = ref(null);
const popoverRef = ref(null);
const arrowRef = ref(null);
let showTimeout = null;
let hideTimeout = null;
const isHoveringPopover = ref(false);

const middleware = computed(() => {
  const middlewareArray = [
    offset(props.showArrow ? 8 : 4), // Adjust offset based on arrow presence
    flip(),
    shift({ padding: 8 }),
  ];
  if (props.showArrow && arrowRef.value) {
    middlewareArray.push(arrow({ element: arrowRef }));
  }
  return middlewareArray;
});

const { floatingStyles, middlewareData, update } = useFloating(triggerRef, popoverRef, {
  placement: props.position,
  middleware: middleware,
  whileElementsMounted: (reference, floating, updateFn) => {
    const cleanup = autoUpdate(reference, floating, updateFn, {
      animationFrame: true, // Use animationFrame for smoother updates
    });
    return cleanup;
  },
});

// --- Positioning Styles ---
const popoverStyle = computed(() => floatingStyles.value);

const arrowStyle = computed(() => {
  if (!props.showArrow || !middlewareData.value.arrow) return {};
  const { x, y } = middlewareData.value.arrow;
  return {
    left: x != null ? `${x}px` : '',
    top: y != null ? `${y}px` : '',
  };
});

const arrowPositionClass = computed(() => {
  if (!props.showArrow || !middlewareData.value.arrow) return '';
  
  // Determine the side the arrow is on based on the final placement
  const placement = middlewareData.value.placement || props.position;
  
  if (placement.startsWith('top')) return '-bottom-1 border-t-0 border-l-0';
  if (placement.startsWith('bottom')) return '-top-1 border-b-0 border-r-0';
  if (placement.startsWith('left')) return '-right-1 border-t-0 border-r-0';
  if (placement.startsWith('right')) return '-left-1 border-b-0 border-l-0';
  
  return ''; // Default case
});


// --- Visibility Logic ---
const showPopover = () => {
  if (props.disabled || isVisible.value) return;
  clearTimeout(hideTimeout);
  showTimeout = setTimeout(() => {
    emit('show');
    isVisible.value = true;
    nextTick(update); // Ensure floating-ui updates position after render
  }, props.trigger === 'hover' ? props.delay : 0);
};

const hidePopover = (immediate = false) => {
  if (props.disabled || !isVisible.value) return;
  clearTimeout(showTimeout);
  const delay = immediate ? 0 : (props.trigger === 'hover' ? props.delay : 0);
  hideTimeout = setTimeout(() => {
    // Don't hide if hovering over the popover itself in hover mode
    if (props.trigger === 'hover' && isHoveringPopover.value) {
      return;
    }
    emit('hide');
    isVisible.value = false;
  }, delay);
};

const togglePopover = () => {
  if (isVisible.value) {
    hidePopover(true); // Hide immediately on click toggle
  } else {
    showPopover();
  }
};

// --- Event Handlers ---
const handleMouseEnter = () => {
  if (props.trigger === 'hover') {
    isHoveringPopover.value = false; // Reset popover hover state
    showPopover();
  }
};

const handleMouseLeave = () => {
  if (props.trigger === 'hover') {
    // Delay hiding to allow moving mouse to popover
    hidePopover();
  }
};

const handleClick = () => {
  if (props.trigger === 'click') {
    togglePopover();
  }
};

const handlePopoverMouseEnter = () => {
  if (props.trigger === 'hover') {
    isHoveringPopover.value = true;
    clearTimeout(hideTimeout); // Prevent hiding if mouse enters popover
  }
};

const handlePopoverMouseLeave = () => {
  if (props.trigger === 'hover') {
    isHoveringPopover.value = false;
    hidePopover(); // Hide when mouse leaves popover
  }
};

// --- Click Outside ---
const handleClickOutside = (event) => {
  if (
    props.trigger === 'click' &&
    isVisible.value &&
    triggerRef.value &&
    popoverRef.value &&
    !triggerRef.value.contains(event.target) &&
    !popoverRef.value.contains(event.target)
  ) {
    hidePopover(true); // Hide immediately on click outside
  }
};

// --- Lifecycle and Watchers ---
watch(isVisible, (newValue) => {
  if (newValue && props.trigger === 'click') {
    document.addEventListener('mousedown', handleClickOutside);
  } else {
    document.removeEventListener('mousedown', handleClickOutside);
  }
});

// Cleanup listener on unmount
import { onUnmounted, onMounted } from 'vue';
import { autoUpdate } from '@floating-ui/dom'; // Import autoUpdate

onMounted(() => {
  // Initial update if needed, though autoUpdate should handle it
});

onUnmounted(() => {
  document.removeEventListener('mousedown', handleClickOutside);
  clearTimeout(showTimeout);
  clearTimeout(hideTimeout);
});

// --- Transition Callbacks ---
const onShown = () => {
  emit('shown');
};

const onHidden = () => {
  emit('hidden');
};

</script>

<style scoped>
/* Add any component-specific styles here if needed */
/* Ensure arrow border colors match popover border */
[class*="-bottom-1"] {
  border-color: inherit;
}
[class*="-top-1"] {
  border-color: inherit;
}
[class*="-right-1"] {
  border-color: inherit;
}
[class*="-left-1"] {
  border-color: inherit;
}
</style>