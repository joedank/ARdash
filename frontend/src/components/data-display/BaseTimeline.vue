/**
 * BaseTimeline
 * 
 * A timeline component for displaying a sequence of events or milestones.
 * Supports both vertical and horizontal layouts with customizable markers and descriptions.
 * 
 * @props {Array} items - Array of timeline items
 * @props {String} orientation - Timeline orientation ('vertical' or 'horizontal')
 * @props {String} markerVariant - Style of markers ('dot', 'number', 'icon')
 * @props {Boolean} alternating - Whether to alternate content position in vertical layout
 * @slots item-content - Slot for customizing the content of each timeline item
 * @slots marker - Slot for customizing the marker
 * @slots connector - Slot for customizing the connector line
 */

<template>
  <div 
    :class="[
      'timeline',
      orientation === 'horizontal' ? 'flex' : 'flex-col',
      'relative'
    ]"
  >
    <div 
      v-for="(item, index) in items" 
      :key="index"
      :class="[
        'timeline-item',
        // Horizontal layout classes
        orientation === 'horizontal' ? [
          'flex-1',
          'px-4',
          'first:pl-0 last:pr-0'
        ] : [
          // Vertical layout classes
          'flex',
          alternating && index % 2 === 1 ? 'flex-row-reverse' : 'flex-row',
          'gap-4',
          'pb-8',
          'last:pb-0'
        ],
        'relative'
      ]"
    >
      <!-- Marker -->
      <div 
        :class="[
          'timeline-marker',
          'relative',
          // Marker positioning and styling
          orientation === 'horizontal' ? [
            'mb-4'
          ] : [
            'flex-shrink-0',
            'w-12',
            'flex justify-center'
          ]
        ]"
      >
        <!-- Default marker -->
        <slot 
          name="marker" 
          :item="item" 
          :index="index"
        >
          <div 
            :class="[
              'h-4 w-4 rounded-full',
              'bg-blue-500 dark:bg-blue-400',
              'border-2 border-white dark:border-gray-900',
              'z-10 relative'
            ]"
          />
        </slot>

        <!-- Connector line -->
        <slot 
          name="connector" 
          :index="index" 
          :isLast="index === items.length - 1"
        >
          <div 
            v-if="index !== items.length - 1"
            :class="[
              'absolute',
              // Connector positioning
              orientation === 'horizontal' ? [
                'left-0 right-0',
                'top-2',
                'h-px'
              ] : [
                'top-4 bottom-0',
                'left-1/2',
                'w-px',
                '-translate-x-1/2'
              ],
              'bg-gray-200 dark:bg-gray-700'
            ]"
          />
        </slot>
      </div>

      <!-- Content -->
      <div 
        :class="[
          'timeline-content',
          'flex-1',
          orientation === 'horizontal' ? 'pt-2' : ''
        ]"
      >
        <slot 
          name="item-content" 
          :item="item"
        >
          <div class="space-y-1">
            <h3 class="font-medium text-gray-900 dark:text-white">
              {{ item.title }}
            </h3>
            <p 
              v-if="item.description"
              class="text-sm text-gray-600 dark:text-gray-400"
            >
              {{ item.description }}
            </p>
            <time 
              v-if="item.date"
              class="text-xs text-gray-500 dark:text-gray-500"
            >
              {{ item.date }}
            </time>
          </div>
        </slot>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  items: {
    type: Array,
    required: true,
    default: () => []
  },
  orientation: {
    type: String,
    default: 'vertical',
    validator: (value) => ['vertical', 'horizontal'].includes(value)
  },
  markerVariant: {
    type: String,
    default: 'dot',
    validator: (value) => ['dot', 'number', 'icon'].includes(value)
  },
  alternating: {
    type: Boolean,
    default: false
  }
});
</script>