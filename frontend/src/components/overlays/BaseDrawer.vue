/**
 * BaseDrawer
 * 
 * An off-canvas panel component that slides in from the side. 
 * Typically used for navigation menus, filters, or supplementary content.
 * 
 * @props {Boolean} modelValue - Controls the visibility of the drawer. Use with v-model.
 * @props {String} position - The side from which the drawer slides in ('left' or 'right'). Default: 'left'.
 * @props {String} widthClass - Tailwind CSS class for the drawer width. Default: 'w-80'.
 * @props {Boolean} showBackdrop - Whether to show a backdrop overlay. Default: true.
 * @props {Boolean} closeOnBackdropClick - Whether clicking the backdrop closes the drawer. Default: true.
 * @props {Boolean} closeOnEsc - Whether pressing the Escape key closes the drawer. Default: true.
 * 
 * @slots default - Content to be displayed inside the drawer.
 * @slots header - Optional header content for the drawer.
 * @slots footer - Optional footer content for the drawer.
 * 
 * @events update:modelValue(value: Boolean) - Emitted when the drawer's visibility state changes.
 * @events close - Emitted when the drawer requests to be closed (e.g., via backdrop click or Esc key).
 * @events opened - Emitted after the drawer finishes its opening transition.
 * @events closed - Emitted after the drawer finishes its closing transition.
 * 
 * @example
 * &lt;BaseDrawer v-model="isDrawerOpen" position="right"&gt;
 *   &lt;h2&gt;Drawer Content&lt;/h2&gt;
 *   &lt;p&gt;This is the content of the drawer.&lt;/p&gt;
 * &lt;/BaseDrawer&gt;
 */
<script setup>
import { ref, watch, computed, onMounted, onUnmounted } from 'vue';
import { TransitionRoot, TransitionChild, Dialog, DialogPanel, DialogOverlay, DialogTitle } from '@headlessui/vue';

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false,
  },
  position: {
    type: String,
    default: 'left',
    validator: (value) => ['left', 'right'].includes(value),
  },
  widthClass: {
    type: String,
    default: 'w-80', // Default width
  },
  showBackdrop: {
    type: Boolean,
    default: true,
  },
  closeOnBackdropClick: {
    type: Boolean,
    default: true,
  },
  closeOnEsc: {
      type: Boolean,
      default: true,
  },
});

const emit = defineEmits(['update:modelValue', 'close', 'opened', 'closed']);

const isOpen = ref(props.modelValue);

// Sync internal state with modelValue prop
watch(() => props.modelValue, (newValue) => {
  isOpen.value = newValue;
});

// Emit update:modelValue when internal state changes
watch(isOpen, (newValue) => {
  if (newValue !== props.modelValue) {
    emit('update:modelValue', newValue);
    if (!newValue) {
      emit('close'); // Also emit 'close' for consistency
    }
  }
});

const closeDrawer = () => {
  if (props.closeOnBackdropClick || props.closeOnEsc) {
      isOpen.value = false;
  }
};

const handleAfterEnter = () => {
  emit('opened');
};

const handleAfterLeave = () => {
  emit('closed');
};

// Handle Escape key press
const handleKeydown = (event) => {
  if (props.closeOnEsc && event.key === 'Escape' && isOpen.value) {
    closeDrawer();
  }
};

onMounted(() => {
  window.addEventListener('keydown', handleKeydown);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown);
});

// --- Computed classes ---

const backdropTransition = computed(() => ({
  enter: 'ease-out duration-300',
  enterFrom: 'opacity-0',
  enterTo: 'opacity-100',
  leave: 'ease-in duration-200',
  leaveFrom: 'opacity-100',
  leaveTo: 'opacity-0',
}));

const panelTransition = computed(() => ({
  enter: 'transform transition ease-in-out duration-300 sm:duration-500',
  leave: 'transform transition ease-in-out duration-300 sm:duration-500',
  enterFrom: props.position === 'left' ? '-translate-x-full' : 'translate-x-full',
  enterTo: 'translate-x-0',
  leaveFrom: 'translate-x-0',
  leaveTo: props.position === 'left' ? '-translate-x-full' : 'translate-x-full',
}));

const panelPositionClasses = computed(() => {
  return props.position === 'left' ? 'left-0' : 'right-0';
});

</script>

<template>
  <TransitionRoot appear :show="isOpen" as="template">
    <Dialog as="div" class="relative z-50" @close="closeDrawer">
      <!-- Backdrop -->
      <TransitionChild
        v-if="showBackdrop"
        as="template"
        :enter="backdropTransition.enter"
        :enter-from="backdropTransition.enterFrom"
        :enter-to="backdropTransition.enterTo"
        :leave="backdropTransition.leave"
        :leave-from="backdropTransition.leaveFrom"
        :leave-to="backdropTransition.leaveTo"
      >
        <div class="fixed inset-0 bg-black/30 dark:bg-black/50" aria-hidden="true" />
      </TransitionChild>

      <!-- Drawer Panel Container -->
      <div class="fixed inset-0 overflow-hidden">
        <div class="absolute inset-0 overflow-hidden">
          <div :class="['fixed inset-y-0 flex max-w-full', panelPositionClasses]">
            <TransitionChild
              as="template"
              :enter="panelTransition.enter"
              :enter-from="panelTransition.enterFrom"
              :enter-to="panelTransition.enterTo"
              :leave="panelTransition.leave"
              :leave-from="panelTransition.leaveFrom"
              :leave-to="panelTransition.leaveTo"
              @after-enter="handleAfterEnter"
              @after-leave="handleAfterLeave"
            >
              <DialogPanel 
                :class="[
                  'pointer-events-auto relative transform', 
                  widthClass,
                  'bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100',
                  'shadow-xl flex flex-col h-full' // Ensure panel takes full height and uses flex column
                ]"
              >
                <!-- Optional Header -->
                <div v-if="$slots.header" class="px-4 sm:px-6 py-4 border-b border-gray-200 dark:border-gray-700 flex-shrink-0">
                   <slot name="header"></slot>
                </div>
                
                <!-- Default Content -->
                <div class="relative flex-1 overflow-y-auto px-4 sm:px-6 py-6">
                  <slot></slot>
                </div>

                <!-- Optional Footer -->
                <div v-if="$slots.footer" class="px-4 sm:px-6 py-4 border-t border-gray-200 dark:border-gray-700 flex-shrink-0">
                  <slot name="footer"></slot>
                </div>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </div>
    </Dialog>
  </TransitionRoot>
</template>