/**
 * BaseDivider
 * 
 * A component to visually separate content, supporting horizontal and vertical orientations,
 * and optional text integration within the divider line.
 * 
 * @props {String} orientation - The orientation of the divider ('horizontal' or 'vertical'). Default: 'horizontal'.
 * @props {String} textPosition - Position of the text within the horizontal divider ('left', 'center', 'right'). Default: 'center'.
 * @props {String} type - Style of the divider line ('solid', 'dashed', 'dotted'). Default: 'solid'.
 * @props {String} thickness - Thickness of the divider line ('thin', 'normal', 'thick'). Default: 'normal'.
 * 
 * @slots default - Optional text content to display within the divider.
 * 
 * @example
 * <!-- Horizontal Divider -->
 * <BaseDivider />
 * 
 * <!-- Vertical Divider -->
 * <BaseDivider orientation="vertical" class="h-16" /> 
 * 
 * &lt;!-- Horizontal Divider with Text (using default slot) --&gt;
 * &lt;BaseDivider text-position="center"&gt;Centered Text&lt;/BaseDivider&gt;
 * 
 * <!-- Dashed Horizontal Divider -->
 * <BaseDivider type="dashed" />
 * 
 * <!-- Thick Vertical Divider -->
 * <BaseDivider orientation="vertical" thickness="thick" class="h-16" />
 */
<template>
  <div :class="wrapperClasses" role="separator" :aria-orientation="orientation">
    <template v-if="orientation === 'horizontal' && hasSlotContent">
      <span :class="lineClasses"></span>
      <span :class="textClasses">
        <slot></slot>
      </span>
      <span :class="lineClasses"></span>
    </template>
    <template v-else-if="orientation === 'horizontal'">
      <span :class="['w-full', lineClasses]"></span>
    </template>
    <!-- Vertical divider doesn't support text directly -->
    <template v-else-if="orientation === 'vertical'">
       <span :class="['h-full', lineClasses]"></span>
    </template>
  </div>
</template>

<script setup>
import { computed, useSlots } from 'vue';

const props = defineProps({
  orientation: {
    type: String,
    default: 'horizontal',
    validator: (value) => ['horizontal', 'vertical'].includes(value)
  },
  textPosition: {
    type: String,
    default: 'center',
    validator: (value) => ['left', 'center', 'right'].includes(value)
  },
  type: {
    type: String,
    default: 'solid',
    validator: (value) => ['solid', 'dashed', 'dotted'].includes(value)
  },
  thickness: {
    type: String,
    default: 'normal', // Corresponds to border-t/border-l
    validator: (value) => ['thin', 'normal', 'thick'].includes(value)
  }
});

const slots = useSlots();
const hasSlotContent = computed(() => !!slots.default);

const thicknessClasses = computed(() => {
  const base = props.orientation === 'horizontal' ? 'border-t' : 'border-l';
  switch (props.thickness) {
    case 'thin': return `${base}-1`; // Tailwind v3 might not have border-1, default is 1px. Let's use border-t/border-l directly.
    case 'thick': return `${base}-2`; // Use border-t-2 / border-l-2
    default: return base; // 'normal' uses default border width (1px)
  }
});

const typeClasses = computed(() => {
  switch (props.type) {
    case 'dashed': return 'border-dashed';
    case 'dotted': return 'border-dotted';
    default: return 'border-solid'; // 'solid'
  }
});

const wrapperClasses = computed(() => [
  'flex items-center',
  props.orientation === 'horizontal' ? 'w-full my-4' : 'h-full mx-4', // Add default margin/padding
  props.orientation === 'vertical' ? 'inline-flex' : '', // Vertical needs inline-flex to respect height
]);

const lineClasses = computed(() => [
  'block',
  'border-gray-200 dark:border-gray-700', // Base border color
  thicknessClasses.value,
  typeClasses.value,
   props.orientation === 'horizontal' ? 'flex-grow' : 'flex-grow-0 h-full', // Horizontal lines grow, vertical takes full height
]);

const textClasses = computed(() => [
  'px-3', // Padding around the text
  'text-sm text-gray-500 dark:text-gray-400', // Text color
  'whitespace-nowrap', // Prevent text wrapping
  props.textPosition === 'left' ? 'mr-auto' : '',
  props.textPosition === 'right' ? 'ml-auto' : '',
  // Center is default flex behavior
]);

</script>