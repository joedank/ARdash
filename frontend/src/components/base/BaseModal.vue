<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div v-if="modelValue" class="modal-backdrop" @click="closeOnBackdrop && close()">
        <div 
          class="modal-container" 
          :class="[sizeClass, { 'modal-persistent': persistent }]" 
          @click.stop
        >
          <div class="modal-header">
            <h3 class="modal-title">{{ title }}</h3>
            <button v-if="!persistent" class="modal-close" @click="close">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          <div class="modal-content">
            <slot></slot>
          </div>
          <div v-if="$slots.footer" class="modal-footer">
            <slot name="footer"></slot>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  title: {
    type: String,
    default: ''
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg', 'xl', 'full'].includes(value)
  },
  persistent: {
    type: Boolean,
    default: false
  },
  closeOnBackdrop: {
    type: Boolean,
    default: true
  }
});

const emit = defineEmits(['update:modelValue', 'close']);

const sizeClass = computed(() => {
  return {
    'sm': 'modal-sm',
    'md': 'modal-md',
    'lg': 'modal-lg',
    'xl': 'modal-xl',
    'full': 'modal-full'
  }[props.size] || 'modal-md';
});

const close = () => {
  if (props.persistent) return;
  emit('update:modelValue', false);
  emit('close');
};
</script>

<style scoped>
.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 50;
}

.modal-container {
  background-color: white;
  border-radius: 0.5rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  max-width: 90vw;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.modal-title {
  font-size: 1.125rem;
  font-weight: 600;
  color: #111827;
}

.modal-close {
  background: transparent;
  border: none;
  color: #6b7280;
  cursor: pointer;
}

.modal-close:hover {
  color: #111827;
}

.modal-content {
  flex: 1;
  overflow-y: auto;
}

.modal-footer {
  padding: 1rem;
  border-top: 1px solid #e5e7eb;
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}

.modal-sm {
  width: 24rem;
}

.modal-md {
  width: 32rem;
}

.modal-lg {
  width: 48rem;
}

.modal-xl {
  width: 64rem;
}

.modal-full {
  width: 90vw;
  height: 90vh;
}

/* Dark mode */
@media (prefers-color-scheme: dark) {
  .modal-container {
    background-color: #1f2937;
  }
  
  .modal-header {
    border-bottom-color: #374151;
  }
  
  .modal-title {
    color: #f9fafb;
  }
  
  .modal-close {
    color: #9ca3af;
  }
  
  .modal-close:hover {
    color: #f9fafb;
  }
  
  .modal-footer {
    border-top-color: #374151;
  }
}

/* Transitions */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}
</style>
