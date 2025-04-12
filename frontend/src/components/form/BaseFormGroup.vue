<template>
  <div class="mb-4">
    <label
      v-if="label"
      :for="inputId"
      :class="[
        'block text-sm font-medium mb-1',
        'text-gray-700 dark:text-gray-300',
        { 'after:content-[\'*\'] after:ml-0.5 after:text-red-500 dark:after:text-red-400': required }
      ]"
    >
      {{ label }}
    </label>
    <slot></slot>
    <p
      v-if="helperText &amp;&amp; !errorMessage"
      class="mt-1 text-xs text-gray-500 dark:text-gray-400"
    >
      {{ helperText }}
    </p>
    <p
      v-if="errorMessage"
      class="mt-1 text-xs text-red-600 dark:text-red-400"
      :id="errorId"
      aria-live="assertive"
    >
      {{ errorMessage }}
    </p>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { generateId } from '@/utils/id';

/**
 * BaseFormGroup
 *
 * A wrapper component to consistently structure form elements with labels,
 * helper text, and error messages. It provides standardized spacing and styling.
 *
 * @props {String} label - The text for the form group label.
 * @props {String} inputId - The ID of the input element this label is associated with. Used for the `for` attribute.
 * @props {String} helperText - Optional helper text displayed below the input.
 * @props {String} errorMessage - Optional error message displayed below the input. Replaces helper text if present.
 * @props {Boolean} required - If true, adds a visual indicator (*) to the label.
 *
 * @slots default - Place the form input component (e.g., BaseInput, BaseSelect) here.
 *
 * @example
 * &amp;lt;BaseFormGroup
 *   label="Email Address"
 *   input-id="email-input"
 *   helper-text="We'll never share your email."
 *   :error-message="emailError"
 *   required
 * &amp;gt;
 *   &amp;lt;BaseInput id="email-input" v-model="email" type="email" /&amp;gt;
 * &amp;lt;/BaseFormGroup&amp;gt;
 */

const props = defineProps({
  label: {
    type: String,
    default: ''
  },
  inputId: {
    type: String,
    required: true
  },
  helperText: {
    type: String,
    default: ''
  },
  errorMessage: {
    type: String,
    default: ''
  },
  required: {
    type: Boolean,
    default: false
  }
});

const errorId = computed(() => props.errorMessage ? `error-${props.inputId || generateId()}` : undefined);

// Note: The input component placed in the default slot should handle
// its own aria-describedby connection to the error message if needed,
// potentially using the `errorId` computed property.
</script>