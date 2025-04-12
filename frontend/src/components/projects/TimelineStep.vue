<template>
  <div class="timeline-step flex flex-row items-center space-x-4">
    <div 
      class="step-circle w-6 h-6 md:w-8 md:h-8 rounded-full flex items-center justify-center"
      :class="{
        'bg-primary-500 text-white cursor-pointer hover:bg-primary-600': isComplete && navigateTo,
        'bg-primary-500 text-white': isComplete && !navigateTo,
        'bg-gray-300 dark:bg-gray-700 text-gray-500 dark:text-gray-400': !isComplete
      }"
      @click="handleClick"
    >
      <BaseIcon :name="icon" size="sm" />
    </div>
    <span 
      class="step-label text-sm md:text-base font-medium"
      :class="{ 'cursor-pointer hover:text-primary-600': isComplete && navigateTo }"
      @click="handleClick"
    >{{ label }}</span>
    <span class="step-timestamp text-[10px] md:text-xs text-gray-500 dark:text-gray-400">
      {{ timestamp }}
    </span>
  </div>
</template>

<script setup>
import BaseIcon from '@/components/base/BaseIcon.vue';
import { useRouter } from 'vue-router';

const props = defineProps({
  label: {
    type: String,
    required: true
  },
  icon: {
    type: String,
    required: true
  },
  isComplete: {
    type: Boolean,
    default: false
  },
  timestamp: {
    type: String,
    default: ''
  },
  navigateTo: {
    type: String,
    default: ''
  }
});

const router = useRouter();

const handleClick = () => {
  if (props.isComplete && props.navigateTo) {
    router.push(props.navigateTo);
  }
};
</script>
