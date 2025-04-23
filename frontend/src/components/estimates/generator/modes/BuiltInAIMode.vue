<template>
  <div class="built-in-ai-mode">
    <!-- Loading State -->
    <div v-if="loading" class="text-center py-8">
      <svg class="animate-spin h-8 w-8 text-indigo-600 mx-auto" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      <p class="mt-4 text-gray-600 dark:text-gray-400">{{ loadingMessage }} ({{ loadingTime }}s)</p>
    </div>

    <!-- Error Message -->
    <div v-else-if="error" class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-md p-4 mb-4">
      <h4 class="text-red-800 dark:text-red-300 font-medium mb-1">Error</h4>
      <p class="text-red-700 dark:text-red-400 text-sm">{{ error }}</p>
      <div v-if="rawErrorContent" class="mt-2 p-2 bg-red-100 dark:bg-red-900/40 rounded text-xs font-mono overflow-auto max-h-32">
        {{ rawErrorContent }}
      </div>
    </div>

    <!-- Initial Input Form -->
    <div v-else-if="currentStep === 'input'">
      <div class="mb-4">
        <label for="description" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Project Description
        </label>
        <textarea
          id="description"
          v-model="description"
          rows="4"
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
          placeholder="e.g., Replace 2000 sq ft roof with architectural shingles, repair minor decking damage..."
          required
          :disabled="loading"
        ></textarea>
      </div>

      <div>
        <label for="targetPrice" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Target Estimate Price (Optional)
        </label>
        <input
          type="number"
          id="targetPrice"
          v-model.number="targetPrice"
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
          placeholder="e.g., 15000"
          min="0"
          step="any"
          :disabled="loading"
        />
      </div>

      <!-- Assessment Data Toggle -->
      <div v-if="props.assessmentData" class="mt-4 flex items-center">
        <input
          type="checkbox"
          id="useAssessmentData"
          v-model="useAssessmentData"
          class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
        />
        <label for="useAssessmentData" class="ml-2 block text-sm text-gray-700 dark:text-gray-300">
          Use assessment data for more accurate estimates
        </label>
      </div>

      <!-- Advanced Options (only shown when using assessment data) -->
      <div v-if="useAssessmentData && props.assessmentData" class="mt-4 p-3 bg-gray-50 dark:bg-gray-700 rounded-md">
        <h4 class="text-sm font-medium mb-2 text-gray-700 dark:text-gray-300">Advanced Options</h4>

        <div class="mb-4">
          <label class="block text-xs font-medium mb-1 text-gray-600 dark:text-gray-400">Aggressiveness</label>
          <div class="flex items-center">
            <span class="text-xs text-gray-500 dark:text-gray-400 mr-2">Conservative</span>
            <input
              type="range"
              v-model.number="aggressiveness"
              min="0"
              max="1"
              step="0.1"
              class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"
            />
            <span class="text-xs text-gray-500 dark:text-gray-400 ml-2">Aggressive</span>
          </div>
          <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
            {{ getAggressivenessDescription() }}
          </p>
        </div>

        <div class="mb-4">
          <label class="block text-xs font-medium mb-1 text-gray-600 dark:text-gray-400">Estimation Mode</label>
          <select
            v-model="estimationMode"
            class="w-full px-3 py-1 text-sm border rounded-md bg-white dark:bg-gray-700 dark:border-gray-600 dark:text-gray-200"
          >
            <option value="replace-focused">Replace-Focused (prioritize replacements)</option>
            <option value="repair-focused">Repair-Focused (prioritize repairs)</option>
            <option value="maintenance-focused">Maintenance-Focused (preventative care)</option>
            <option value="comprehensive">Comprehensive (complete solution)</option>
          </select>
          <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">{{ getModeDescription() }}</p>
        </div>
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
          @click="analyzeScope"
          class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 dark:bg-indigo-700 dark:hover:bg-indigo-600"
          :disabled="loading || !description.trim()"
        >
          Analyze Project
        </button>
      </div>
    </div>

    <!-- Analysis Results and Clarification Form -->
    <div v-else-if="currentStep === 'clarification' && analysisResult">
      <h4 class="font-medium text-lg mb-4 text-gray-800 dark:text-gray-200">Project Analysis Results</h4>

      <div class="mb-6 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-md border border-blue-200 dark:border-blue-800">
        <p class="text-blue-800 dark:text-blue-300 text-sm">
          <strong>Project Type:</strong> {{ analysisResult.repair_type || '' }}
        </p>
        <p class="text-blue-800 dark:text-blue-300 text-sm mt-1">
          <strong>Services Needed:</strong> {{ (analysisResult.required_services || []).join(', ') }}
        </p>
      </div>

      <!-- Existing measurements from assessment data -->
      <div v-if="existingMeasurements.length > 0" class="mb-6 p-3 bg-green-50 dark:bg-green-900/20 rounded-md border border-green-200 dark:border-green-800">
        <h5 class="font-medium mb-2 text-green-800 dark:text-green-300">Using existing measurements from assessment:</h5>
        <ul class="list-disc pl-5">
          <li v-for="measurement in existingMeasurements" :key="measurement.name" class="text-green-700 dark:text-green-400">
            {{ formatKey(measurement.name) }}: {{ measurement.value }} {{ measurement.unit }}
          </li>
        </ul>
      </div>

      <!-- Only show inputs for missing measurements -->
      <div v-if="missingMeasurements.length > 0">
        <strong class="block mb-2 text-base text-gray-800 dark:text-gray-200">Please provide the following measurements:</strong>
        <div v-for="measurement in missingMeasurements" :key="measurement" class="mb-3">
          <label :for="`measurement-${measurement}`" class="block text-sm font-medium mb-1 text-gray-700 dark:text-gray-300">
            {{ formatKey(measurement) }}
          </label>
          <input
            :id="`measurement-${measurement}`"
            type="number"
            v-model.number="measurementInputs[measurement]"
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
            :placeholder="`Enter ${formatKey(measurement)}`"
            min="0"
            step="any"
          />
        </div>
      </div>

      <!-- Only show questions that haven't been answered -->
      <div v-if="missingQuestions.length > 0" class="mt-4">
        <strong class="block mb-2 text-base text-gray-800 dark:text-gray-200">Please answer these questions:</strong>
        <div v-for="(question, index) in missingQuestions" :key="index" class="mb-3">
          <label :for="`question-${index}`" class="block text-sm font-medium mb-1 text-gray-700 dark:text-gray-300">
            {{ question }}
          </label>
          <input
            :id="`question-${index}`"
            type="text"
            v-model="questionAnswers[index]"
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
            :placeholder="'Your answer...'"
          />
        </div>
      </div>
      
      <!-- Show message when all questions are answered -->
      <div v-if="missingMeasurements.length === 0 && missingQuestions.length === 0" class="mt-4 p-3 bg-green-50 dark:bg-green-900/20 rounded-md">
        <p class="text-green-700 dark:text-green-400 text-sm">
          <strong>All required information available from assessment data!</strong> You can proceed to generate the estimate.
        </p>
      </div>

      <!-- Action Buttons -->
      <div class="mt-6 flex justify-between">
        <button
          @click="currentStep = 'input'"
          class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700"
        >
          Back
        </button>
        <button
          @click="submitDetails"
          class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 dark:bg-indigo-700 dark:hover:bg-indigo-600"
          :disabled="loading || (!allRequiredInfoAvailable && !isFormValid)"
        >
          Generate Estimate
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
const loadingMessage = ref('Analyzing project...');
const loadingTime = ref(0);
const loadingTimer = ref(null);
const error = ref(null);
const rawErrorContent = ref(null);

// Input state
const description = ref('');
const targetPrice = ref(null);
const useAssessmentData = ref(props.assessmentData ? true : false);
const aggressiveness = ref(0.6);
const estimationMode = ref('replace-focused');

// Analysis state
const analysisResult = ref(null);
const measurementInputs = ref({});
const questionAnswers = ref({});

// Watch for assessment data changes
watch(() => props.assessmentData, (newVal) => {
  useAssessmentData.value = !!newVal;
});

// Helper functions for measurements and questions

// Function to check if a measurement already exists in assessment data
const measurementExists = (measurementName) => {
  if (!props.assessmentData || !props.assessmentData.measurements) return false;
  
  // Normalize the search - convert to lowercase and handle underscore/space variations
  const normalizedName = measurementName.toLowerCase().replace(/_/g, ' ');
  
  return props.assessmentData.measurements.some(m => {
    const label = (m.label || '').toLowerCase();
    const description = (m.description || '').toLowerCase();
    return label.includes(normalizedName) || 
           description.includes(normalizedName) ||
           // Check for semantic matches (e.g., "subfloor area" matches "subfloor_area_sq_ft")
           label.includes('subfloor') && normalizedName.includes('subfloor') ||
           label.includes('cabinet') && normalizedName.includes('cabinet');
  });
};

// Function to get existing measurement value from assessment data
const getExistingMeasurementValue = (measurementName) => {
  if (!props.assessmentData || !props.assessmentData.measurements) return null;
  
  const normalizedName = measurementName.toLowerCase().replace(/_/g, ' ');
  
  const measurement = props.assessmentData.measurements.find(m => {
    const label = (m.label || '').toLowerCase();
    const description = (m.description || '').toLowerCase();
    return label.includes(normalizedName) || 
           description.includes(normalizedName) ||
           label.includes('subfloor') && normalizedName.includes('subfloor') ||
           label.includes('cabinet') && normalizedName.includes('cabinet');
  });
  
  return measurement ? measurement.value : null;
};

// Get unit for a measurement from assessment data
const getExistingMeasurementUnit = (measurementName) => {
  if (!props.assessmentData || !props.assessmentData.measurements) return 'sq ft';
  
  const normalizedName = measurementName.toLowerCase().replace(/_/g, ' ');
  
  const measurement = props.assessmentData.measurements.find(m => {
    const label = (m.label || '').toLowerCase();
    const description = (m.description || '').toLowerCase();
    return label.includes(normalizedName) || 
           description.includes(normalizedName) ||
           label.includes('subfloor') && normalizedName.includes('subfloor') ||
           label.includes('cabinet') && normalizedName.includes('cabinet');
  });
  
  return measurement ? measurement.unit : 'sq ft';
};

// Similar helper for clarifying questions
const questionAlreadyAnswered = (question) => {
  if (!props.assessmentData || !props.assessmentData.conditions) return false;
  
  // Normalize the question
  const normalizedQuestion = question.toLowerCase();
  
  // Look for answers in condition notes and assessment data
  return props.assessmentData.conditions.some(c => {
    const notes = (c.notes || '').toLowerCase();
    const issue = (c.issue || '').toLowerCase();
    
    // Check if the condition notes or issue description answers the question
    return (notes.includes('subfloor') && normalizedQuestion.includes('subfloor')) ||
           (notes.includes('cabinet') && normalizedQuestion.includes('cabinet')) ||
           (issue.includes('subfloor') && normalizedQuestion.includes('subfloor')) ||
           (issue.includes('cabinet') && normalizedQuestion.includes('cabinet'));
  });
};

// Computed properties for measurements and questions
const missingMeasurements = computed(() => {
  if (!analysisResult.value || !analysisResult.value.required_measurements) return [];
  
  return analysisResult.value.required_measurements.filter(m => !measurementExists(m));
});

const existingMeasurements = computed(() => {
  if (!analysisResult.value || !analysisResult.value.required_measurements) return [];
  
  return analysisResult.value.required_measurements
    .filter(m => measurementExists(m))
    .map(m => ({
      name: m,
      value: getExistingMeasurementValue(m),
      unit: getExistingMeasurementUnit(m)
    }));
});

const missingQuestions = computed(() => {
  if (!analysisResult.value || !analysisResult.value.clarifying_questions) return [];
  
  return analysisResult.value.clarifying_questions.filter(q => !questionAlreadyAnswered(q));
});

// Computed property to check if all required info is available
const allRequiredInfoAvailable = computed(() => {
  return missingMeasurements.value.length === 0 && missingQuestions.value.length === 0;
});

// Form validation computed property
const isFormValid = computed(() => {
  // If all required information is available from assessment, form is automatically valid
  if (allRequiredInfoAvailable.value) return true;
  
  // Otherwise, check if all required measurements are filled
  const measurementsValid = !missingMeasurements.value.length ||
    missingMeasurements.value.every(m =>
      measurementInputs.value[m] !== undefined && 
      measurementInputs.value[m] !== null && 
      measurementInputs.value[m] !== '');

  // Check if all questions are answered
  const questionsValid = !missingQuestions.value.length ||
    missingQuestions.value.every((q, index) =>
      questionAnswers.value[index] !== undefined && 
      questionAnswers.value[index] !== null && 
      questionAnswers.value[index] !== '');

  return measurementsValid && questionsValid;
});

// Methods
const getAggressivenessDescription = () => {
  if (aggressiveness.value <= 0.3) {
    return 'Conservative: Focus on essential repairs with minimal additional work';
  } else if (aggressiveness.value <= 0.6) {
    return 'Balanced: Include necessary repairs with some preventative maintenance';
  } else {
    return 'Aggressive: Comprehensive approach with preventative replacements';
  }
};

const getModeDescription = () => {
  switch (estimationMode.value) {
    case 'replace-focused':
      return 'Prioritize replacing components over repairing them';
    case 'repair-focused':
      return 'Prioritize repairing components over replacing them';
    case 'maintenance-focused':
      return 'Focus on preventative maintenance to avoid future issues';
    case 'comprehensive':
      return 'Provide a complete solution addressing all issues';
    default:
      return '';
  }
};

// Frontend fix: Generate default services based on repair type
const getDefaultServices = (repairType) => {
  const type = repairType.toLowerCase();
  
  if (type.includes('roof')) {
    return 'Roof inspection, Roof repair, Underlayment replacement';
  } else if (type.includes('window')) {
    return 'Window inspection, Window repair, Window replacement';
  } else if (type.includes('door')) {
    return 'Door inspection, Door repair, Door replacement';
  } else if (type.includes('paint') || type.includes('painting')) {
    return 'Surface preparation, Painting, Finish coating';
  } else if (type.includes('floor')) {
    return 'Floor repair, Subfloor inspection, Floor installation';
  } else if (type.includes('plumb')) {
    return 'Plumbing inspection, Pipe repair, Fixture installation';
  } else if (type.includes('electric')) {
    return 'Electrical inspection, Wiring repair, Fixture installation';
  } else {
    return 'General repair, Inspection, Material preparation';
  }
};

const formatKey = (key) => {
  return key
    .replace(/_/g, ' ')
    .replace(/\b\w/g, l => l.toUpperCase());
};

const initializeInputObjects = () => {
  // Initialize measurement inputs
  if (analysisResult.value?.required_measurements?.length) {
    analysisResult.value.required_measurements.forEach(measurement => {
      if (!measurementInputs.value[measurement]) {
        measurementInputs.value[measurement] = null;
      }
    });
  }

  // Initialize question answers
  if (analysisResult.value?.clarifying_questions?.length) {
    analysisResult.value.clarifying_questions.forEach((_, index) => {
      if (!questionAnswers.value[index]) {
        questionAnswers.value[index] = '';
      }
    });
  }
};

const analyzeScope = async () => {
  if (!description.value.trim()) {
    toast.error('Please enter a project description');
    return;
  }

  currentStep.value = 'input'; // Ensure we're on the input step
  loading.value = true;
  loadingMessage.value = 'Analyzing project...';
  error.value = null;
  rawErrorContent.value = null;

  // Start loading timer
  loadingTime.value = 0;
  clearInterval(loadingTimer.value);
  loadingTimer.value = setInterval(() => {
    loadingTime.value++;
  }, 1000);

  try {
    const payload = {
      description: description.value.trim(),
      targetPrice: targetPrice.value && targetPrice.value > 0 ? targetPrice.value : undefined,
    };

    // Include assessment data with projectId if available
    if (useAssessmentData.value && props.assessmentData) {
      // Ensure projectId is included and consistent
      payload.assessmentData = {
        ...props.assessmentData,
        projectId: props.assessmentData.projectId || props.assessmentId
      };
      
      // Add enhanced parameters as before
      payload.assessmentOptions = {
        aggressiveness: aggressiveness.value,
        mode: estimationMode.value,
        debug: true
      };
    }

    // Add temporary logging for debugging
    console.log('*****************************');
    console.log('SENDING API REQUEST:', JSON.stringify(payload, null, 2));

    const response = await estimateService.analyzeScope(payload);
    
    // Log the complete response
    console.log('RECEIVED API RESPONSE:', JSON.stringify(response, null, 2));
    console.log('*****************************');

    if (response.success && response.data) {
      console.log('API Response Structure:', {
        fullResponse: response,
        dataType: typeof response.data,
        isArray: Array.isArray(response.data),
        keys: response.data ? Object.keys(response.data) : 'N/A',
        requiredServices: response.data.required_services
      });
      
      // If data is in a different format than expected, normalize it
      if (Array.isArray(response.data)) {
        // Handle case where API returns an array of line items directly
        analysisResult.value = {
          repair_type: 'Generated Repair',
          required_services: response.data.map(item => item.description || item.name).filter(Boolean),
          required_measurements: [],
          clarifying_questions: []
        };
      } else {
        // Use the data as-is
        analysisResult.value = response.data;
      }
      
      // Debug the data structure after normalization
      console.log('ANALYSIS RESULT:', JSON.stringify(analysisResult.value, null, 2));
      console.log('Has required_services:', !!analysisResult.value.required_services);
      console.log('Required services type:', Array.isArray(analysisResult.value.required_services) ? 'array' : typeof analysisResult.value.required_services);
      if (Array.isArray(analysisResult.value.required_services)) {
        console.log('Required services length:', analysisResult.value.required_services.length);
        console.log('Required services content:', analysisResult.value.required_services);
      }

      // Pre-fill input objects based on analysis results
      initializeInputObjects();
      currentStep.value = 'clarification';
      toast.success('Analysis complete. Please provide the required details.');
    } else {
      error.value = response.message || 'Analysis failed.';
      rawErrorContent.value = response.rawContent;
      toast.error(error.value);
    }
  } catch (err) {
    console.error('Error calling analysis API:', err);
    error.value = err.response?.data?.message || err.message || 'An unexpected error occurred during analysis.';
    rawErrorContent.value = err.response?.data?.rawContent;
    toast.error(error.value);
  } finally {
    loading.value = false;
    clearInterval(loadingTimer.value);
  }
};

const submitDetails = async () => {
  loading.value = true;
  error.value = null;
  rawErrorContent.value = null;
  loadingMessage.value = 'Generating estimate...';

  // Start loading timer
  loadingTime.value = 0;
  clearInterval(loadingTimer.value);
  loadingTimer.value = setInterval(() => {
    loadingTime.value++;
  }, 1000);

  try {
    // Add existing measurements from assessment data
    const combinedMeasurements = { ...measurementInputs.value };
    
    // Add values from existing measurements in assessment data
    existingMeasurements.value.forEach(m => {
      if (m.name && m.value) {
        combinedMeasurements[m.name] = m.value;
      }
    });
    
    // Construct the payload
    const payload = {
      measurements: combinedMeasurements,
      answers: questionAnswers.value,
      originalDescription: description.value,
      analysisResult: analysisResult.value
    };

    // Include assessment data if available
    if (useAssessmentData.value && props.assessmentData) {
      payload.assessmentData = props.assessmentData;
      // Add enhanced parameters when using assessment data
      payload.assessmentOptions = {
        aggressiveness: aggressiveness.value,
        mode: estimationMode.value,
        debug: true
      };
    }

    // Include target price if specified
    if (targetPrice.value && targetPrice.value > 0) {
      payload.targetPrice = targetPrice.value;
    }

    const response = await estimateService.generateEstimate(payload);

    if (response.success && response.data) {
      // Convert to line item format expected by the product matching component
      const lineItems = response.data.map(item => ({
        description: item.description,
        product_name: item.description,
        quantity: item.quantity,
        unit: item.unit,
        unit_price: item.unitPrice,
        total: item.total,
        sourceType: item.sourceType,
        sourceId: item.sourceId
      }));

      generatedItems.value = lineItems;
      emit('generated-items', lineItems);
      toast.success(`Generated ${lineItems.length} line items`);
    } else {
      error.value = response.message || 'Failed to generate estimate.';
      rawErrorContent.value = response.rawContent;
      toast.error(error.value);
    }
  } catch (err) {
    console.error('Error generating estimate:', err);
    error.value = err.response?.data?.message || err.message || 'An unexpected error occurred during estimate generation.';
    rawErrorContent.value = err.response?.data?.rawContent;
    toast.error(error.value);
  } finally {
    loading.value = false;
    clearInterval(loadingTimer.value);
  }
};
</script>

<style scoped>
/* Component-specific styles */
</style>
