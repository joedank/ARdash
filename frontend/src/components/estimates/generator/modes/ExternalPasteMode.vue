<template>
  <div class="external-paste-mode">
    <!-- Loading State -->
    <div v-if="loading" class="text-center py-8">
      <svg class="animate-spin h-8 w-8 text-indigo-600 mx-auto" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      <p class="mt-4 text-gray-600 dark:text-gray-400">{{ loadingMessage }}</p>
    </div>

    <!-- Error Message -->
    <div v-else-if="error" class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-md p-4 mb-4">
      <h4 class="text-red-800 dark:text-red-300 font-medium mb-1">Error</h4>
      <p class="text-red-700 dark:text-red-400 text-sm">{{ error }}</p>
    </div>

    <!-- Input Form -->
    <div v-else-if="currentStep === 'input'">
      <!-- Prompt Guidelines -->
      <div class="mb-4">
        <div class="flex justify-between items-center mb-2">
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            Prompt Guidelines
          </label>
          <button
            @click="copyPromptToClipboard"
            class="text-xs text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300"
          >
            Copy to Clipboard
          </button>
        </div>
        <div class="bg-gray-50 dark:bg-gray-700 p-3 rounded-md border border-gray-200 dark:border-gray-600 text-sm text-gray-700 dark:text-gray-300 max-h-48 overflow-y-auto">
          <pre class="whitespace-pre-wrap font-mono text-xs">{{ promptGuidelines }}</pre>
        </div>
      </div>

      <!-- LLM Response Input -->
      <div class="mt-4">
        <div class="flex justify-between items-center mb-2">
          <label for="llm-response" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            Paste External LLM Response
          </label>
          <div class="flex space-x-2">
            <button
              v-if="llmResponse"
              @click="llmResponse = ''"
              class="text-xs text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300"
            >
              Clear
            </button>
            <button
              v-if="llmResponse"
              @click="tryParseAsJson"
              class="text-xs text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300"
            >
              Check Format
            </button>
          </div>
        </div>
        <p class="text-xs text-gray-500 dark:text-gray-400 mb-2">
          Use an external LLM to generate a response according to the prompt guidelines, then paste it here.
        </p>
        <textarea
          id="llm-response"
          v-model="llmResponse"
          rows="10"
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
          placeholder="Paste the response from your external LLM here..."
          :disabled="loading"
        ></textarea>
      </div>

      <!-- Format Validation Messages -->
      <div v-if="validationMessage" :class="validationSuccess ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'" class="p-2 rounded-md text-sm">
        {{ validationMessage }}
      </div>

      <!-- Action Buttons -->
      <div class="mt-6 flex justify-between">
        <button
          @click="$emit('close')"
          class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700"
        >
          Cancel
        </button>
        <button
          @click="processResponse"
          class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 dark:bg-indigo-700 dark:hover:bg-indigo-600"
          :disabled="loading || !llmResponse.trim()"
        >
          Process Response
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, inject, watch } from 'vue';
import { useToast } from 'vue-toastification';
import estimateService from '../../../../services/estimates.service.js';

const props = defineProps({
  assessmentData: {
    type: Object,
    default: null
  }
});

const emit = defineEmits(['close', 'generated-items']);

const toast = useToast();

// Shared state from parent
const { generatedItems } = inject('generatorState', {
  generatedItems: ref([])
});

// Local state
const currentStep = ref('input');
const loading = ref(false);
const loadingMessage = ref('Processing...');
const error = ref(null);
const llmResponse = ref('');
const validationMessage = ref('');
const validationSuccess = ref(false);

// Prompt guidelines for external LLM
const promptGuidelines = computed(() => {
  let assessmentSection = '';
  if (props.assessmentData) {
    const formatted = formatAssessmentDataForDisplay(props.assessmentData);
    if (formatted && formatted.length > 0) {
      assessmentSection = `\n## Assessment Data\n${formatted}`;
    }
  }
  return `Please create a detailed construction service estimate based on the following requirements.
Format your response as a JSON array of service items. Each item should have these fields:
- name: The name of the service item
- description: Detailed description of the service
- quantity: Numeric quantity
- unit: Unit type (e.g., "sq ft", "ln ft", "each")
- price: Estimated price per unit (numeric only)

## Project Requirements
[Add your project description here]${assessmentSection}

## Response Example:
\`\`\`json
[
  {
    "name": "Window Replacement",
    "description": "Remove and replace existing window with new vinyl window",
    "quantity": 2,
    "unit": "each",
    "price": 450
  },
  {
    "name": "Wall Repair",
    "description": "Repair damaged drywall including patching, taping, and painting",
    "quantity": 120,
    "unit": "sq ft",
    "price": 8.50
  }
]
\`\`\`

Focus on repair services only, not physical products. Be specific with quantities and units.`;
});

// Methods
const formatAssessmentDataForDisplay = (assessmentData) => {
  if (!assessmentData) return '';

  // Use formattedMarkdown or formattedData if available
  if (assessmentData.formattedMarkdown) {
    return assessmentData.formattedMarkdown;
  }

  if (assessmentData.formattedData) {
    return assessmentData.formattedData;
  }

  // If no formatted data, try to create a simple representation
  let result = '';

  if (assessmentData.projectName) {
    result += `Project: ${assessmentData.projectName}\n\n`;
  }

  if (assessmentData.inspections && assessmentData.inspections.length > 0) {
    for (const inspection of assessmentData.inspections) {
      if (inspection.category) {
        result += `### ${inspection.category.toUpperCase()}\n`;

        if (inspection.content) {
          if (inspection.category === 'measurements' && Array.isArray(inspection.content.items)) {
            for (const item of inspection.content.items) {
              result += `- ${item.name || 'Item'}: ${item.value || ''} ${item.unit || ''}\n`;
            }
          } else if (inspection.category === 'condition' && inspection.content.assessment) {
            result += `${inspection.content.assessment}\n`;
          }
        }

        result += '\n';
      }
    }
  }

  return result;
};

const copyPromptToClipboard = () => {
  navigator.clipboard.writeText(promptGuidelines.value);
  toast.success('Prompt copied to clipboard');
};

const tryParseAsJson = () => {
  if (!llmResponse.value.trim()) {
    validationMessage.value = 'Please paste an LLM response first';
    validationSuccess.value = false;
    return;
  }

  try {
    // Try to extract JSON if it's embedded in a markdown code block
    let jsonContent = llmResponse.value.trim();

    // Extract JSON from markdown code blocks if present
    const jsonBlockMatch = jsonContent.match(/```(?:json)?\s*([\s\S]*?)```/);
    if (jsonBlockMatch && jsonBlockMatch[1]) {
      jsonContent = jsonBlockMatch[1].trim();
    }

    // Parse the JSON
    const parsed = JSON.parse(jsonContent);

    // Check if it's an array
    if (!Array.isArray(parsed)) {
      validationMessage.value = 'The content must be a JSON array of service items, but a different format was detected.';
      validationSuccess.value = false;
      return;
    }

    // Check if each item has the required fields
    for (let i = 0; i < parsed.length; i++) {
      const item = parsed[i];
      if (!item.name || !item.description || item.quantity === undefined || !item.unit || item.price === undefined) {
        validationMessage.value = `Item at index ${i} is missing required fields. Each item must have name, description, quantity, unit, and price.`;
        validationSuccess.value = false;
        return;
      }
    }

    // Success!
    validationMessage.value = `Format validation successful. Found ${parsed.length} service item(s).`;
    validationSuccess.value = true;
  } catch (error) {
    validationMessage.value = `Format validation failed: ${error.message}`;
    validationSuccess.value = false;
  }
};

const processResponse = async () => {
  // Ensure we have non-empty content to process
  const trimmedResponse = llmResponse.value.trim();
  if (!trimmedResponse) {
    toast.error('Please paste an LLM response first');
    return;
  }

  loading.value = true;
  loadingMessage.value = 'Processing LLM response...';
  error.value = null;

  try {
    const payload = { text: trimmedResponse };
    const response = await estimateService.processExternalLlmResponse(payload);

    if (response.success && response.data) {
      generatedItems.value = response.data;
      emit('generated-items', response.data);
      toast.success('LLM response processed successfully');
    } else {
      error.value = response.message || 'Failed to process LLM response.';
      toast.error(error.value);
    }
  } catch (err) {
    console.error('Error processing LLM response:', err);
    error.value = err.response?.data?.message || err.message || 'An unexpected error occurred during processing.';
    toast.error(error.value);
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
/* Component-specific styles */
</style>
