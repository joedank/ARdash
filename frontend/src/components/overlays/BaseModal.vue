<!--
  BaseModal component
  
  A customizable modal dialog component with header, body, and footer sections.
  Includes backdrop and focus trapping for accessibility. Fully supports dark mode.
  
  @props {Boolean} modelValue - v-model for controlling modal visibility
  @props {String} title - Modal title
  @props {String} size - Modal size (sm, md, lg, xl, full)
  @props {Boolean} closeOnBackdrop - Whether clicking the backdrop closes the modal
  @props {Boolean} closeOnEsc - Whether pressing the Escape key closes the modal
  @props {Boolean} hideCloseButton - Whether to hide the close button in the header
  @props {Boolean} persistent - If true, clicking backdrop won't close modal
  @props {String} overlayClass - Additional class for the backdrop overlay
  
  @slots default - Modal body content
  @slots header - Custom header content (overrides title prop)
  @slots footer - Custom footer content
  
  @events update:modelValue - Emitted when modal visibility changes
  @events close - Emitted when modal closes
  @events open - Emitted when modal opens
  
  @example
  <BaseModal v-model="showModal" title="Confirm Action">
    <p>Are you sure you want to proceed?</p>
    <template #footer>
      <div class="flex justify-end space-x-2">
        <button @click="showModal = false">Cancel</button>
        <button @click="confirmAction">Confirm</button>
      </div>
    </template>
  </BaseModal>
  
  @example
  <BaseModal v-model="showModal" size="lg" persistent>
    <template #header>
      <div class="flex justify-between items-center">
        <h3>Custom Header</h3>
        <button @click="showModal = false">×</button>
      </div>
    </template>
    <div>Modal content goes here</div>
  </BaseModal>
-->

<template>
  <Teleport to="body">
    <transition
      enter-active-class="transition duration-300 ease-out"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition duration-200 ease-in"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <!-- Backdrop -->
      <div 
        v-if="modelValue"
        :class="[
          'fixed inset-0 bg-black/50 dark:bg-black/70 z-50 flex items-center justify-center overflow-y-auto',
          overlayClass
        ]"
        @click="onBackdropClick"
        role="dialog"
        aria-modal="true"
      >
        <!-- Modal Container -->
        <transition
          enter-active-class="transition duration-300 ease-out"
          enter-from-class="transform scale-95 opacity-0"
          enter-to-class="transform scale-100 opacity-100"
          leave-active-class="transition duration-200 ease-in"
          leave-from-class="transform scale-100 opacity-100"
          leave-to-class="transform scale-95 opacity-0"
        >
          <div 
            v-if="modelValue"
            ref="modalRef"
            :class="[
              'bg-white dark:bg-gray-900 rounded-lg shadow-xl overflow-hidden m-4 z-50',
              sizeClass,
              props.class
            ]"
            @click.stop
            tabindex="-1"
          >
            <!-- Modal Header -->
            <div 
              v-if="hasHeader"
              class="px-4 py-3 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between"
            >
              <slot name="header">
                <h3 class="font-medium text-gray-900 dark:text-white">{{ title }}</h3>
              </slot>
              
              <button 
                v-if="!hideCloseButton"
                class="text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 focus:outline-none ml-auto"
                @click="close"
                aria-label="Close"
              >
                <svg class="w-5 h-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            
            <!-- Modal Body -->
            <div class="p-4">
              <slot></slot>
            </div>
            
            <!-- Modal Footer -->
            <div 
              v-if="$slots.footer"
              class="px-4 py-3 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800"
            >
              <slot name="footer"></slot>
            </div>
          </div>
        </transition>
      </div>
    </transition>
  </Teleport>
</template>

<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount, nextTick, useSlots } from 'vue';

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  class: {
    type: String,
    default: ''
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
  closeOnBackdrop: {
    type: Boolean,
    default: true
  },
  closeOnEsc: {
    type: Boolean,
    default: true
  },
  hideCloseButton: {
    type: Boolean,
    default: false
  },
  persistent: {
    type: Boolean,
    default: false
  },
  overlayClass: {
    type: String,
    default: ''
  }
});

const emit = defineEmits(['update:modelValue', 'close', 'open']);
const slots = useSlots();
const modalRef = ref(null);
const previouslyFocusedElement = ref(null);
const focusableElements = ref([]);

// Computed Properties
const hasHeader = computed(() => {
  return props.title || slots.header;
});

const sizeClass = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'max-w-sm w-full';
    case 'lg':
      return 'max-w-2xl w-full';
    case 'xl':
      return 'max-w-4xl w-full';
    case 'full':
      return 'max-w-full w-full h-full m-0 rounded-none';
    case 'md':
    default:
      return 'max-w-lg w-full';
  }
});

// Methods
const close = () => {
  emit('update:modelValue', false);
  emit('close');
};

const onBackdropClick = () => {
  if (props.closeOnBackdrop && !props.persistent) {
    close();
  } else if (props.persistent) {
    // Add a little shake animation to indicate the modal is persistent
    const modalElement = modalRef.value;
    if (modalElement) {
      modalElement.classList.add('shake');
      setTimeout(() => {
        modalElement.classList.remove('shake');
      }, 300);
    }
  }
};

const onEsc = (event) => {
  if (event.key === 'Escape' && props.closeOnEsc && !props.persistent && props.modelValue) {
    close();
  }
};

const getFocusableElements = () => {
  if (!modalRef.value) return [];
  
  return Array.from(
    modalRef.value.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )
  ).filter(el => !el.hasAttribute('disabled') && el.getAttribute('tabindex') !== '-1');
};

const trapFocus = (event) => {
  if (!props.modelValue || !modalRef.value) return;
  
  const focusables = focusableElements.value;
  if (focusables.length === 0) return;
  
  const firstFocusable = focusables[0];
  const lastFocusable = focusables[focusables.length - 1];
  
  if (event.key === 'Tab') {
    if (event.shiftKey && document.activeElement === firstFocusable) {
      event.preventDefault();
      lastFocusable.focus();
    } else if (!event.shiftKey && document.activeElement === lastFocusable) {
      event.preventDefault();
      firstFocusable.focus();
    }
  }
};

// Setup focus trap and keyboard handlers
watch(() => props.modelValue, async (isOpen) => {
  if (isOpen) {
    emit('open');
    // Save previously focused element
    previouslyFocusedElement.value = document.activeElement;
    
    // Wait for the DOM to update
    await nextTick();
    
    // Get focusable elements
    focusableElements.value = getFocusableElements();
    
    // Focus the first focusable element in the modal
    if (focusableElements.value.length > 0) {
      focusableElements.value[0].focus();
    } else {
      // If no focusable element, focus the modal itself
      modalRef.value?.focus();
    }
    
    // Add event listeners
    document.addEventListener('keydown', onEsc);
    document.addEventListener('keydown', trapFocus);
  } else {
    // Remove event listeners
    document.removeEventListener('keydown', onEsc);
    document.removeEventListener('keydown', trapFocus);
    
    // Restore focus to the previously focused element
    if (previouslyFocusedElement.value) {
      previouslyFocusedElement.value.focus();
    }
  }
});

// Clean up event listeners
onBeforeUnmount(() => {
  document.removeEventListener('keydown', onEsc);
  document.removeEventListener('keydown', trapFocus);
});
</script>

<style scoped>
.shake {
  animation: shake 0.3s cubic-bezier(.36,.07,.19,.97) both;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-5px); }
  50% { transform: translateX(5px); }
  75% { transform: translateX(-5px); }
}
</style>
