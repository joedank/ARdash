/**
 * BaseStepperWizard
 *
 * Guides users through a multi-step process, indicating current progress
 * and allowing navigation between steps. Useful for forms, onboarding, etc.
 *
 * @props {Array} steps - An array of step objects, e.g., [{ id: 'step1', name: 'Step 1', status: 'current' | 'complete' | 'upcoming' }]
 * @props {String|Number} currentStepId - The ID of the currently active step.
 * @props {Boolean} linear - If true, users must complete steps sequentially.
 * @props {Boolean} vertical - If true, displays steps vertically instead of horizontally.
 *
 * @slots step-{id} - Slot for custom content within a specific step's display area.
 * @slots default - Default slot for the main content area of the current step.
 *
 * @events update:currentStepId - Emitted when the current step changes.
 * @events step-change - Emitted when navigating to a different step, payload: { oldStepId, newStepId }.
 * @events complete - Emitted when the final step is completed or submitted.
 *
 * @example
 * &lt;BaseStepperWizard
 *   :steps="mySteps"
 *   v-model:currentStepId="activeStep"
 *   @complete="handleCompletion"
 * &gt;
 *   &lt;template #default&gt;
 *     &lt;div v-if="activeStep === 'step1'"&gt;Step 1 Content&lt;/div&gt;
 *     &lt;div v-if="activeStep === 'step2'"&gt;Step 2 Content&lt;/div&gt;
 *   &lt;/template&gt;
 * &lt;/BaseStepperWizard&gt;
 */
<template>
  <div :class="['base-stepper-wizard', { 'flex': !vertical }]">
    <!-- Step Navigation -->
    <nav 
      :class="[
        'border-gray-200 dark:border-gray-700', 
        vertical ? 'border-l pr-4 mr-4' : 'border-b pb-4 mb-4 flex space-x-4'
      ]" 
      aria-label="Progress"
    >
      <ol 
        role="list" 
        :class="[
          'flex', 
          vertical ? 'flex-col space-y-4' : 'items-center space-x-4'
        ]"
      >
        <li v-for="(step, stepIdx) in steps" :key="step.id" :class="[vertical ? '' : 'relative flex-1']">
          <template v-if="step.status === 'complete'">
            <button @click="navigateToStep(step.id)" :disabled="linear && stepIdx > currentStepIndex" class="group flex items-center w-full">
              <span class="flex items-center px-2 py-1 text-xs font-medium">
                <span class="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full bg-blue-600 dark:bg-blue-500 group-hover:bg-blue-800 dark:group-hover:bg-blue-400">
                  <svg class="h-5 w-5 text-white" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                    <path fill-rule="evenodd" d="M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z" clip-rule="evenodd" />
                  </svg>
                </span>
                <span class="ml-4 text-sm font-medium text-gray-900 dark:text-white">{{ step.name }}</span>
              </span>
              <!-- Arrow separator for horizontal -->
              <div v-if="!vertical && stepIdx !== steps.length - 1" class="absolute right-0 top-0 h-full w-5" aria-hidden="true">
                <svg class="h-full w-full text-gray-300 dark:text-gray-600" viewBox="0 0 22 80" fill="none" preserveAspectRatio="none">
                  <path d="M0 -2L20 40L0 82" vector-effect="non-scaling-stroke" stroke="currentcolor" stroke-linejoin="round" />
                </svg>
              </div>
            </button>
          </template>
          <template v-else-if="step.status === 'current'">
            <div class="flex items-center px-2 py-1 text-xs font-medium" aria-current="step">
              <span class="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full border-2 border-blue-600 dark:border-blue-500">
                <span class="text-blue-600 dark:text-blue-500">{{ stepIdx + 1 }}</span>
              </span>
              <span class="ml-4 text-sm font-medium text-blue-600 dark:text-blue-500">{{ step.name }}</span>
            </div>
             <!-- Arrow separator for horizontal -->
             <div v-if="!vertical && stepIdx !== steps.length - 1" class="absolute right-0 top-0 h-full w-5" aria-hidden="true">
                <svg class="h-full w-full text-gray-300 dark:text-gray-600" viewBox="0 0 22 80" fill="none" preserveAspectRatio="none">
                  <path d="M0 -2L20 40L0 82" vector-effect="non-scaling-stroke" stroke="currentcolor" stroke-linejoin="round" />
                </svg>
              </div>
          </template>
          <template v-else> <!-- upcoming -->
            <button @click="navigateToStep(step.id)" :disabled="linear" class="group flex items-center w-full">
              <span class="flex items-center px-2 py-1 text-xs font-medium">
                <span class="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full border-2 border-gray-300 dark:border-gray-600 group-hover:border-gray-400 dark:group-hover:border-gray-500">
                  <span class="text-gray-500 dark:text-gray-400">{{ stepIdx + 1 }}</span>
                </span>
                <span class="ml-4 text-sm font-medium text-gray-500 dark:text-gray-400 group-hover:text-gray-700 dark:group-hover:text-gray-200">{{ step.name }}</span>
              </span>
               <!-- Arrow separator for horizontal -->
               <div v-if="!vertical && stepIdx !== steps.length - 1" class="absolute right-0 top-0 h-full w-5" aria-hidden="true">
                <svg class="h-full w-full text-gray-300 dark:text-gray-600" viewBox="0 0 22 80" fill="none" preserveAspectRatio="none">
                  <path d="M0 -2L20 40L0 82" vector-effect="non-scaling-stroke" stroke="currentcolor" stroke-linejoin="round" />
                </svg>
              </div>
            </button>
          </template>
          
          <!-- Vertical line connector -->
          <div v-if="vertical && stepIdx !== steps.length - 1" class="absolute left-4 top-8 h-full w-px bg-gray-300 dark:bg-gray-600" />

          <!-- Slot for custom step display -->
          <slot :name="`step-${step.id}`" :step="step" :index="stepIdx"></slot>
        </li>
      </ol>
    </nav>

    <!-- Step Content Area -->
    <div class="step-content flex-1">
      <slot :currentStep="currentStep">
        <!-- Default content area, consumers will typically use v-if based on currentStepId -->
      </slot>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  steps: {
    type: Array,
    required: true,
    validator: (steps) => steps.every(step => step.id && step.name && ['current', 'complete', 'upcoming'].includes(step.status))
  },
  currentStepId: {
    type: [String, Number],
    required: true
  },
  linear: {
    type: Boolean,
    default: false
  },
  vertical: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['update:currentStepId', 'step-change', 'complete']);

const currentStepIndex = computed(() => props.steps.findIndex(step => step.id === props.currentStepId));
const currentStep = computed(() => props.steps[currentStepIndex.value]);

const navigateToStep = (targetStepId) => {
  const targetStepIndex = props.steps.findIndex(step => step.id === targetStepId);
  const targetStep = props.steps[targetStepIndex];

  // Prevent navigation if linear and target step is not completed or the next upcoming one
  if (props.linear && targetStep.status === 'upcoming' && targetStepIndex > currentStepIndex.value + 1) {
    return;
  }
  // Prevent navigation to future steps in linear mode if current step isn't complete (logic might need refinement based on exact UX)
  // if (props.linear && targetStepIndex > currentStepIndex.value && currentStep.value.status !== 'complete') {
  //   return; 
  // }
   // Allow navigation back to completed steps even in linear mode
  if (targetStep.status === 'complete' || !props.linear) {
      if (props.currentStepId !== targetStepId) {
        emit('update:currentStepId', targetStepId);
        emit('step-change', { oldStepId: props.currentStepId, newStepId: targetStepId });
      }
  } else if (props.linear && targetStepIndex === currentStepIndex.value + 1) {
      // Allow navigation to the very next step in linear mode
       if (props.currentStepId !== targetStepId) {
        emit('update:currentStepId', targetStepId);
        emit('step-change', { oldStepId: props.currentStepId, newStepId: targetStepId });
      }
  }

  // Consider emitting 'complete' if navigating away from the last step? Or should that be explicit?
  // Let's assume 'complete' is triggered externally for now.
};

// Function to potentially call when the final step is submitted/finished
// const finalizeSteps = () => {
//   emit('complete');
// };

</script>

<style scoped>
/* Add any component-specific styles here if needed, beyond Tailwind utilities */
.base-stepper-wizard nav ol li:last-child .absolute.right-0 {
  display: none; /* Hide arrow on the last step for horizontal layout */
}
</style>