/**
 * BaseSplitPanel
 * 
 * A layout component that divides its container into two resizable panes,
 * arranged either horizontally or vertically. Uses flexbox for layout.
 * 
 * @props {String} orientation - The split direction ('horizontal' or 'vertical'). Default: 'horizontal'.
 * @props {Boolean} resizable - Whether the divider is resizable. Default: true.
 * @props {Number} initialSplit - The initial position of the divider (percentage 0-100). Default: 50.
 * @props {Number} minPaneSize - The minimum size (in pixels) for each pane. Default: 50.
 * @props {Number} maxPaneSize - The maximum size (in pixels) for each pane. Default: Infinity.
 * @props {String} dividerClass - Optional classes for the divider element.
 * @props {String} dividerHandleClass - Optional classes for the divider handle (visible part).
 * 
 * @slots pane1 - Content for the first pane (left/top).
 * @slots pane2 - Content for the second pane (right/bottom).
 * @slots divider - Optional custom content/styling for the divider handle. Replaces default handle.
 * 
 * @events resize(percentage: number) - Emitted when the divider position changes, includes the new split percentage.
 * @events resize-start - Emitted when dragging the divider starts.
 * @events resize-end(percentage: number) - Emitted when dragging the divider ends, includes the final split percentage.
 */
<template>
  <div 
    ref="splitPanelRef" 
    class="base-split-panel relative overflow-hidden w-full h-full flex"
    :class="[
      isVertical ? 'flex-col' : 'flex-row',
      isDragging ? 'select-none cursor-ew-resize' : '', // Improve UX during drag
      isVertical && isDragging ? 'cursor-ns-resize' : ''
    ]"
    @mousemove="handleMouseMove"
    @mouseup="handleMouseUp"
    @mouseleave="handleMouseLeave" 
  >
    <!-- Pane 1 -->
    <div 
      ref="pane1Ref" 
      class="pane pane1 overflow-auto" 
      :style="pane1Style"
    >
      <slot name="pane1"></slot>
    </div>

    <!-- Divider -->
    <div
      v-if="props.resizable"
      ref="dividerRef"
      class="divider shrink-0 bg-transparent flex items-center justify-center"
      :class="[
        isVertical ? 'h-2 w-full cursor-ns-resize' : 'w-2 h-full cursor-ew-resize',
        props.dividerClass
      ]"
      @mousedown.prevent="handleMouseDown"
    >
      <slot name="divider">
        <!-- Default Handle -->
        <div 
          class="handle w-1 h-8 rounded-full bg-gray-300 dark:bg-gray-600 group-hover:bg-blue-500 dark:group-hover:bg-blue-400 transition-colors"
          :class="[
            isVertical ? 'h-1 w-8' : 'w-1 h-8',
            isDragging ? 'bg-blue-600 dark:bg-blue-500' : 'hover:bg-gray-400 dark:hover:bg-gray-500',
            props.dividerHandleClass
          ]"
        ></div>
      </slot>
    </div>
    <!-- Non-resizable Divider Placeholder (maintains structure) -->
    <div v-else class="shrink-0" :class="[isVertical ? 'h-px w-full bg-gray-200 dark:bg-gray-700' : 'w-px h-full bg-gray-200 dark:bg-gray-700']"></div>


    <!-- Pane 2 -->
    <div 
      ref="pane2Ref" 
      class="pane pane2 overflow-auto flex-1" 
      :style="pane2Style"
    >
      <slot name="pane2"></slot>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue';

const props = defineProps({
  orientation: {
    type: String,
    default: 'horizontal',
    validator: (value) => ['horizontal', 'vertical'].includes(value)
  },
  resizable: {
    type: Boolean,
    default: true
  },
  initialSplit: {
    type: Number,
    default: 50,
    validator: (value) => value >= 0 && value <= 100
  },
  minPaneSize: {
    type: Number,
    default: 50 // Minimum size in pixels
  },
  maxPaneSize: {
    type: Number,
    default: Infinity // Maximum size in pixels
  },
  dividerClass: {
    type: String,
    default: ''
  },
  dividerHandleClass: {
    type: String,
    default: ''
  }
});

const emit = defineEmits(['resize', 'resize-start', 'resize-end']);

const splitPanelRef = ref(null);
const pane1Ref = ref(null);
const pane2Ref = ref(null); // Added ref for pane2
const dividerRef = ref(null);
const isDragging = ref(false);
const splitPercentage = ref(props.initialSplit);

const isVertical = computed(() => props.orientation === 'vertical');

// --- Computed Styles ---

const pane1Style = computed(() => {
  const sizeProp = isVertical.value ? 'height' : 'width';
  // Use flex-basis for initial sizing and allow shrinking/growing
  // Use calc to subtract half the divider width for more accurate positioning
  const dividerSize = props.resizable ? (isVertical.value ? 8 : 8) : (isVertical.value ? 1 : 1); // Divider height/width in px (adjust if divider size changes)
  return {
    flexBasis: `calc(${splitPercentage.value}% - ${dividerSize / 2}px)`,
    flexGrow: 0,
    flexShrink: 0,
    // Apply min/max constraints directly if not using flex-basis effectively
    // [sizeProp]: `${splitPercentage.value}%`, 
    // minWidth/minHeight and maxWidth/maxHeight might be needed if flex-basis isn't enough
  };
});

// Pane 2 takes remaining space automatically due to flex: 1
const pane2Style = computed(() => {
    // We might need min/max size constraints here too, applied via style
    const sizeProp = isVertical.value ? 'minHeight' : 'minWidth';
    const maxSizeProp = isVertical.value ? 'maxHeight' : 'maxWidth';
    return {
        [sizeProp]: `${props.minPaneSize}px`,
        // [maxSizeProp]: props.maxPaneSize === Infinity ? 'none' : `${props.maxPaneSize}px` // Max size handled by pane1's max
    };
});


// --- Drag Handling ---

let startPos = 0;
let initialPane1Size = 0;
let totalSize = 0;

const handleMouseDown = (event) => {
  if (!props.resizable) return;
  
  isDragging.value = true;
  startPos = isVertical.value ? event.clientY : event.clientX;
  
  const pane1Rect = pane1Ref.value.getBoundingClientRect();
  initialPane1Size = isVertical.value ? pane1Rect.height : pane1Rect.width;

  const panelRect = splitPanelRef.value.getBoundingClientRect();
  totalSize = isVertical.value ? panelRect.height : panelRect.width;
  
  // Add global listeners
  // window.addEventListener('mousemove', handleMouseMove); // Use Vue's @mousemove on root instead
  // window.addEventListener('mouseup', handleMouseUp); // Use Vue's @mouseup on root instead
  
  emit('resize-start');
  
  // Prevent text selection during drag
  document.body.style.userSelect = 'none'; 
};

const handleMouseMove = (event) => {
  if (!isDragging.value || !props.resizable) return;

  const currentPos = isVertical.value ? event.clientY : event.clientX;
  const delta = currentPos - startPos;
  
  let newPane1Size = initialPane1Size + delta;

  // Calculate min/max sizes based on total size and pixel constraints
  const dividerSize = props.resizable ? (isVertical.value ? 8 : 8) : (isVertical.value ? 1 : 1); // Approx divider size
  const availableSize = totalSize - dividerSize;
  
  const minAllowedSize1 = Math.max(props.minPaneSize, 0);
  const maxAllowedSize1 = props.maxPaneSize === Infinity 
      ? availableSize - props.minPaneSize 
      : Math.min(props.maxPaneSize, availableSize - props.minPaneSize);

  // Clamp the new size
  newPane1Size = Math.max(minAllowedSize1, Math.min(newPane1Size, maxAllowedSize1));

  // Calculate new percentage
  const newPercentage = (newPane1Size / availableSize) * 100;

  // Update only if percentage actually changes (within tolerance)
  if (Math.abs(newPercentage - splitPercentage.value) > 0.01) {
      splitPercentage.value = newPercentage;
      emit('resize', newPercentage);
  }
};

const handleMouseUp = () => {
  if (!isDragging.value) return;
  
  isDragging.value = false;
  // window.removeEventListener('mousemove', handleMouseMove); // Handled by Vue
  // window.removeEventListener('mouseup', handleMouseUp); // Handled by Vue
  emit('resize-end', splitPercentage.value);
  
  // Restore text selection
  document.body.style.userSelect = ''; 
};

// Handle case where mouse leaves the panel while dragging
const handleMouseLeave = (event) => {
    // Check if the mouse button is still pressed (dragging) when leaving
    if (isDragging.value && (event.buttons & 1)) { 
        // Continue tracking via window listeners might be complex with Vue's setup.
        // For simplicity, we can just end the drag if the mouse leaves the container.
        // A more robust solution might involve temporary global listeners added on mousedown.
        // handleMouseUp(); // Option 1: End drag on leave
        
        // Option 2: Rely on the root @mousemove and @mouseup which should still fire
        // if the drag started within the component. Let's test this first.
    }
};


// --- Lifecycle ---
onMounted(() => {
  // Initial setup if needed, e.g., getting initial dimensions
});

onBeforeUnmount(() => {
  // Cleanup global listeners if they were used (though Vue handles root listeners)
  // window.removeEventListener('mousemove', handleMouseMove);
  // window.removeEventListener('mouseup', handleMouseUp);
  // Ensure userSelect is reset if component is destroyed mid-drag
  if (isDragging.value) {
      document.body.style.userSelect = '';
  }
});

</script>

<style scoped>
/* Add any additional scoped styles if necessary */
.pane {
  /* Ensure panes don't shrink beyond their basis or min-size */
}

.divider {
  /* Add transition for hover effect */
  transition: background-color 0.2s ease-in-out;
}

/* Improve hit area for the divider */
.base-split-panel[class*="cursor-ew-resize"] .divider {
  padding-left: 4px;
  padding-right: 4px;
  margin-left: -4px;
  margin-right: -4px;
}
.base-split-panel[class*="cursor-ns-resize"] .divider {
  padding-top: 4px;
  padding-bottom: 4px;
  margin-top: -4px;
  margin-bottom: -4px;
}

/* Ensure the default handle is centered */
.divider > :deep(div:not([class*="handle"])) { /* Target slotted content */
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
}
.divider .handle {
    /* Default handle styles are applied via classes */
}

</style>