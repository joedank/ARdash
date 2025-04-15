<template>
  <div class="p-4 border rounded-lg shadow-lg bg-white dark:bg-gray-800 relative z-50 mt-16">
    <h3 class="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">External LLM Input</h3>

    <!-- Loading State -->
    <div v-if="loading" class="text-center py-8">
      <svg class="animate-spin h-8 w-8 text-indigo-600 mx-auto" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      <p class="mt-4 text-gray-600 dark:text-gray-400">{{ loadingMessage }}</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="text-red-600 dark:text-red-400 p-4">
      <p><strong>Error:</strong> {{ error }}</p>
      <button @click="resetForm" class="mt-4 px-3 py-1 border border-gray-300 rounded-md text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600">
        Start Over
      </button>
    </div>

    <!-- Main Content - Input form -->
    <div v-else-if="currentStep === 'input'" class="space-y-4">
      <!-- Prompt Guidelines -->
      <div class="mb-4 bg-gray-50 dark:bg-gray-700 p-4 rounded-md">
        <div class="flex items-center justify-between mb-2">
          <h4 class="text-md font-semibold text-gray-800 dark:text-gray-200">LLM Prompt Guidelines</h4>
          <button
            @click="copyPromptToClipboard"
            class="text-sm text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300"
          >
            Copy Prompt
          </button>
        </div>
        <div class="text-sm text-gray-700 dark:text-gray-300 overflow-y-auto max-h-48 bg-white dark:bg-gray-800 p-3 rounded border border-gray-200 dark:border-gray-600">
          <pre class="whitespace-pre-wrap">{{ promptGuidelines }}</pre>
        </div>
      </div>

      <!-- Assessment Data Display (if available) -->
      <div v-if="useAssessmentData" class="p-3 bg-indigo-50 dark:bg-indigo-900/20 rounded-md border border-indigo-200 dark:border-indigo-800">
        <div class="flex items-center justify-between mb-2">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-600 dark:text-green-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
              </svg>
            </div>
            <h4 class="ml-2 text-sm font-medium text-green-700 dark:text-green-300">Assessment Data Available</h4>
          </div>
          <button
            @click="clearAssessmentData"
            class="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300"
            title="Remove assessment data"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <p v-if="props.assessmentData?.project" class="text-xs text-green-700 dark:text-green-300 mb-2">
          {{ props.assessmentData.project?.client?.displayName || 'Unknown Client' }} -
          {{ formatDate(props.assessmentData.project?.scheduledDate) }}
        </p>

        <!-- Assessment data summary -->
        <ul class="mt-1 list-disc list-inside pl-1 text-sm text-green-600 dark:text-green-400">
          <li v-if="props.assessmentData?.measurements?.length">{{ props.assessmentData.measurements.length }} measurement(s)</li>
          <li v-if="props.assessmentData?.conditions?.length">{{ props.assessmentData.conditions.length }} condition(s)</li>
          <li v-if="props.assessmentData?.materials?.length">{{ props.assessmentData.materials.length }} material(s)</li>
          <li v-if="props.assessmentData?.scope">Project scope available</li>
        </ul>

        <div class="mt-3 mb-2">
          <button
            @click="copyAssessmentData"
            class="inline-flex items-center px-2 py-1 text-xs font-medium rounded-md text-green-700 bg-green-100 hover:bg-green-200 dark:bg-green-900 dark:text-green-200 dark:hover:bg-green-800"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3 mr-1" viewBox="0 0 20 20" fill="currentColor">
              <path d="M8 3a1 1 0 011-1h2a1 1 0 110 2H9a1 1 0 01-1-1z" />
              <path d="M6 3a2 2 0 00-2 2v11a2 2 0 002 2h8a2 2 0 002-2V5a2 2 0 00-2-2 3 3 0 01-3 3H9a3 3 0 01-3-3z" />
            </svg>
            Copy Assessment Data for Prompt
          </button>
        </div>

        <div class="mt-1 mb-3 bg-white dark:bg-gray-800 p-2 rounded border border-gray-200 dark:border-gray-600 text-xs text-gray-700 dark:text-gray-300 max-h-32 overflow-y-auto">
          <pre class="whitespace-pre-wrap">{{ formattedAssessmentData }}</pre>
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
      <div class="flex justify-end">
        <button
          @click="$emit('close')"
          class="mr-3 px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 dark:text-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700"
        >
          Cancel
        </button>
        <button
          @click="processResponse"
          :disabled="loading || !llmResponse.trim()"
          class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <span v-if="loading">Processing...</span>
          <span v-else>Process Response</span>
        </button>
      </div>
    </div>

    <!-- Product Matching Review Component -->
    <div v-if="currentStep === 'service-matching' && generatedLineItems && generatedLineItems.length > 0">
      <ProductMatchReview
        :lineItems="generatedLineItems"
        @back="currentStep = 'input'"
        @finished="handleMatchingFinished"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import { useRouter } from 'vue-router';
import estimateService from '@/services/estimates.service.js';
import projectsService from '@/services/projects.service.js';
import { useToast } from 'vue-toastification';
import ProductMatchReview from './ProductMatchReview.vue';

const props = defineProps({
  assessmentData: {
    type: Object,
    default: null
  }
});

const router = useRouter();
const toast = useToast();
const emit = defineEmits(['close', 'clearAssessment']);

// State
const loading = ref(false);
const loadingMessage = ref('Processing...');
const error = ref(null);
const currentStep = ref('input');
const llmResponse = ref('');
const validationMessage = ref('');
const validationSuccess = ref(false);
const generatedLineItems = ref([]);

// Assessment Import State
const assessmentProjectId = ref('');
const useAssessmentData = ref(false);
const availableProjects = ref([]);
const loadingProjects = ref(false);
const formattedAssessmentData = ref('');

/**
 * Format a date for display
 */
const formatDate = (dateString) => {
  if (!dateString) return 'Unknown Date';

  const date = new Date(dateString);
  return date.toLocaleDateString();
};

/**
 * Format assessment data for display
 */
const formatAssessmentDataForDisplay = (data) => {
  let formatted = '';

  if (data.scope) {
    formatted += `Project Scope: ${data.scope}\n\n`;
  }

  if (data.measurements && data.measurements.length > 0) {
    formatted += 'Measurements:\n';
    data.measurements.forEach((m, i) => {
      formatted += `${i+1}. ${m.label || m.description || 'Measurement'}: `;
      if (m.unit === 'sq ft') {
        formatted += `${m.value || 0} sq ft\n`;
      } else if (m.unit === 'ln ft') {
        formatted += `${m.value || 0} ln ft\n`;
      } else {
        formatted += `${m.value || 0} ${m.unit || 'each'}\n`;
      }
    });
    formatted += '\n';
  }

  if (data.conditions && data.conditions.length > 0) {
    formatted += 'Conditions:\n';
    data.conditions.forEach((c, i) => {
      formatted += `${i+1}. ${c.location || 'Area'}: ${c.issue || 'Not specified'} (${c.severity || 'Unknown severity'})\n`;
    });
    formatted += '\n';
  }

  if (data.materials && data.materials.length > 0) {
    formatted += 'Materials:\n';
    data.materials.forEach((m, i) => {
      formatted += `${i+1}. ${m.name || 'Material'}: ${m.quantity || 0} ${m.unit || 'units'}\n`;
    });
  }

  if (data.formattedMarkdown) {
    return data.formattedMarkdown;
  }

  return formatted.trim();
};

// Watch for changes to the assessment data prop
watch(() => props.assessmentData, (newData) => {
  if (newData) {
    useAssessmentData.value = true;
    formattedAssessmentData.value = formatAssessmentDataForDisplay(newData);
  } else {
    useAssessmentData.value = false;
    formattedAssessmentData.value = '';
  }
}, { immediate: true });

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

// --- Methods ---

/**
 * Copy the prompt template to clipboard
 */
const copyPromptToClipboard = () => {
  navigator.clipboard.writeText(promptGuidelines.value);
  toast.success('Prompt copied to clipboard');
};

// These functions have been moved above the watcher to avoid TDZ errors

/**
 * Copy assessment data to clipboard
 */
const copyAssessmentData = () => {
  navigator.clipboard.writeText(formattedAssessmentData.value);
  toast.success('Assessment data copied to clipboard');
};

/**
 * Clear the imported assessment data
 */
const clearAssessmentData = () => {
  emit('clearAssessment');
  toast.info('Assessment data removed');
};

/**
 * Try to parse the pasted content as JSON for validation
 */
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

    // Validate the structure
    if (parsed.length === 0) {
      validationMessage.value = 'The JSON array is empty. Please provide at least one service item.';
      validationSuccess.value = false;
      return;
    }

    // Check each item for required fields
    const missingFields = [];
    parsed.forEach((item, index) => {
      const requiredFields = ['name', 'description', 'quantity', 'unit', 'price'];
      requiredFields.forEach(field => {
        if (item[field] === undefined) {
          missingFields.push(`Item #${index + 1} is missing the "${field}" field`);
        }
      });
    });

    if (missingFields.length > 0) {
      validationMessage.value = `Format validation failed: ${missingFields.join(', ')}`;
      validationSuccess.value = false;
      return;
    }

    // Success!
    validationMessage.value = `Format validation successful. Found ${parsed.length} service item(s).`;
    validationSuccess.value = true;
  } catch (error) {
    validationMessage.value = `Format validation failed: ${error.message}`;
    validationSuccess.value = false;
  }
};

/**
 * Process the pasted LLM response
 */
const processResponse = async () => {
  if (!llmResponse.value.trim()) {
    toast.error('Please paste an LLM response first');
    return;
  }

  loading.value = true;
  loadingMessage.value = 'Processing LLM response...';
  error.value = null;

  try {
    const response = await estimateService.processExternalLlmResponse({
      responseText: llmResponse.value,
      assessmentData: useAssessmentData.value ? props.assessmentData : null
    });

    if (response.success && response.data) {
      generatedLineItems.value = response.data;
      currentStep.value = 'service-matching';
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

/**
 * Reset the form to initial state
 */
const resetForm = () => {
  llmResponse.value = '';
  error.value = null;
  validationMessage.value = '';
  validationSuccess.value = false;
  currentStep.value = 'input';
};

/**
 * Handle matching finished event from ProductMatchReview component
 */
const handleMatchingFinished = async (data) => {
  toast.success('Product matching completed. Creating estimate...');

  await router.push({
    path: '/invoicing/create-estimate',
    query: {
      prefill: 'true',
      items: encodeURIComponent(JSON.stringify(data.lineItems))
    }
  });

  emit('close');
};
</script>

<style scoped>
/* Add any component-specific styles here */
</style>