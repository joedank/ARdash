<template>
  <div class="estimate-from-assessment w-full h-full">
    <BaseSplitPanel
      orientation="horizontal"
      :initialSplit="40"
      :minPaneSize="300"
    >
      <!-- Assessment Markdown Panel - Left Side -->
      <template #pane1>
        <AssessmentMarkdownPanel
          :assessment="assessment"
          :activeSourceId="activeSourceId"
          @highlightSource="handleSourceHighlight"
        />
      </template>

      <!-- Estimate Items Editor - Right Side -->
      <template #pane2>
        <div class="h-full flex flex-col">
          <!-- Loading indicator while generating estimate -->
          <div v-if="isLoading" class="flex items-center justify-center h-full">
            <div class="text-center">
              <div class="inline-block animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-blue-500 mb-2"></div>
              <p class="text-gray-600 dark:text-gray-400">Generating estimate...</p>
            </div>
          </div>

          <!-- Estimate items editor when data is available -->
          <EstimateItemEditor
            v-else
            :items="estimateItems"
            :sourceMap="sourceMap"
            :activeSourceId="activeSourceId"
            @updateItem="handleItemUpdate"
            @highlightSource="handleSourceHighlight"
          />
        </div>
      </template>
    </BaseSplitPanel>

    <!-- Controls for LLM settings and regeneration -->
    <EstimateControls
      :aggressiveness="llmSettings.aggressiveness"
      :mode="llmSettings.mode"
      :isLoading="isLoading"
      @regenerate="regenerateEstimate"
      @settingsChange="handleSettingsChange"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, onUnmounted } from 'vue';
import { useToast } from 'vue-toastification';
import BaseSplitPanel from '@/components/layout/BaseSplitPanel.vue';
import AssessmentMarkdownPanel from './AssessmentMarkdownPanel.vue';
import EstimateItemEditor from './EstimateItemEditor.vue';
import EstimateControls from './EstimateControls.vue';
import estimateService from '@/services/estimates.service';
import standardizedEstimatesService from '@/services/standardized-estimates.service';
import estimatesV2Service from '@/services/estimatesV2.service';

const props = defineProps({
  assessmentId: {
    type: String,
    required: true
  },
  assessmentData: {
    type: Object,
    default: () => ({})
  }
});

const emit = defineEmits(['update', 'error']);

// State
const toast = useToast();
const assessment = ref(props.assessmentData || {});
const estimateItems = ref([]);
const sourceMap = ref({});
const activeSourceId = ref(null);
const isLoading = ref(false);
const error = ref(null);
const pollInterval = ref(null);
const activeToastId = ref(null);
const llmSettings = ref({
  aggressiveness: 0.6, // Default to 60%
  mode: 'replace-focused' // Default mode
});

// Load assessment data if assessmentId is provided but no assessmentData
onMounted(async () => {
  if (props.assessmentId && (!props.assessmentData || Object.keys(props.assessmentData).length === 0)) {
    await loadAssessmentData();
  }

  // If assessment data is available, generate initial estimate
  if (assessment.value && (assessment.value.formattedMarkdown || assessment.value.formattedData)) {
    await generateEstimate();
  }
});

// Watch for changes in assessment data from props
watch(() => props.assessmentData, (newData) => {
  if (newData && Object.keys(newData).length > 0) {
    assessment.value = newData;
  }
}, { deep: true });

// Clean up polling interval and toast when component is unmounted
onUnmounted(() => {
  // Clear polling interval
  if (pollInterval.value) {
    clearTimeout(pollInterval.value);
    console.log('Cleared polling interval on component unmount');
  }

  // Dismiss any active toast
  if (activeToastId.value) {
    toast.dismiss(activeToastId.value);
    console.log('Dismissed active toast on component unmount');
    activeToastId.value = null;
  }
});

// --- Methods ---

/**
 * Load assessment data from the backend
 */
const loadAssessmentData = async () => {
  isLoading.value = true;
  error.value = null;

  try {
    // Log the assessment ID we're using
    console.log(`EstimateFromAssessment: Loading assessment data for ID: ${props.assessmentId}`);

    // Use standardized service for better error handling and data conversion
    const response = await standardizedEstimatesService.getAssessmentData(props.assessmentId);

    // Log the full response for debugging
    console.log('EstimateFromAssessment: Assessment data response:', response);

    if (response.success && response.data) {
      assessment.value = response.data;
      console.log('EstimateFromAssessment: Assessment data loaded in component:', assessment.value);
      toast.success('Assessment data loaded successfully');
    } else {
      error.value = response.message || 'Failed to load assessment data';
      console.error('EstimateFromAssessment: Failed to load assessment data:', error.value);
      toast.error(error.value);
      emit('error', error.value);
    }
  } catch (err) {
    console.error('EstimateFromAssessment: Error loading assessment data:', err);
    error.value = err.response?.data?.message || err.message || 'Failed to load assessment data';
    toast.error(error.value);
    emit('error', error.value);
  } finally {
    isLoading.value = false;
  }
};

// Constants for polling configuration
const MAX_POLL_ATTEMPTS = 60; // 60 attempts at 2s intervals = 2 minutes
const POLL_INTERVAL_BASE = 2000; // 2 seconds
const MAX_CONSECUTIVE_ERRORS = 3; // Stop after 3 consecutive errors

/**
 * Start polling for job status
 * @param {string} jobId - The job ID to poll for
 */
const startPolling = async (jobId) => {
  // Clear any existing polling interval first
  if (pollInterval.value) {
    clearInterval(pollInterval.value);
    console.log('Cleared existing polling interval');
  }

  let attempts = 0;
  let consecutiveErrors = 0;
  const toastId = toast.info('Generating estimate...', { timeout: false });

  // Store the toast ID for cleanup
  activeToastId.value = toastId;

  // Function to check job status
  const checkJobStatus = async () => {
    attempts++;

    // Calculate polling interval with exponential backoff after 5 attempts
    const currentInterval = attempts > 5
      ? Math.min(POLL_INTERVAL_BASE * (1 + (attempts - 5) * 0.5), 10000) // Cap at 10 seconds
      : POLL_INTERVAL_BASE;

    try {
      const response = await estimatesV2Service.getJobStatus(jobId);
      console.log(`Poll attempt ${attempts}, interval: ${currentInterval}ms, status:`, response);

      // Reset consecutive errors counter on success
      consecutiveErrors = 0;

      if (!response || !response.data) {
        console.error('Invalid response from job status endpoint:', response);
        return; // Continue polling
      }

      const status = response.data;

      if (status.status === 'completed') {
        clearTimeout(pollInterval.value);
        pollInterval.value = null;
        console.log('Job completed successfully:', status);

        // Update the toast
        toast.update(toastId, {
          content: 'Estimate generated successfully!',
          type: 'success',
          timeout: 3000
        });
        activeToastId.value = null;

        // Process the completed items
        if (Array.isArray(status.items)) {
          // Format the response into the structure we need
          estimateItems.value = status.items.map(item => ({
            description: item.description || item.item || '',
            quantity: item.quantity,
            unit: item.unit,
            unitPrice: Number(item.unitPrice || item.unit_price || item.rate || item.unitCost || 0),
            total: Number(item.total || item.cost || item.totalCost || 0),
            sourceType: item.sourceType || item.source_type,
            sourceId: item.sourceId || item.source_id
          }));

          // Generate source map if not provided
          sourceMap.value = status.sourceMap || generateSourceMapFromItems(estimateItems.value);

          console.log('Estimate items:', estimateItems.value);
          console.log('Source map:', sourceMap.value);

          emit('update', { estimateItems: estimateItems.value, sourceMap: sourceMap.value });
        } else {
          const errorMsg = 'Completed job did not return an array of items';
          console.error(errorMsg);
          toast.error(errorMsg);
          emit('error', errorMsg);
        }

        isLoading.value = false;
      } else if (status.status === 'failed') {
        clearTimeout(pollInterval.value);
        pollInterval.value = null;
        const errorMessage = status.message || 'Estimate generation failed';
        console.error('Job failed:', errorMessage);

        // Update the toast
        toast.update(toastId, {
          content: errorMessage,
          type: 'error',
          timeout: 5000
        });
        activeToastId.value = null;

        emit('error', errorMessage);
        isLoading.value = false;
      } else if (attempts > MAX_POLL_ATTEMPTS) {
        clearTimeout(pollInterval.value);
        pollInterval.value = null;
        const timeoutMessage = `Timed out waiting for estimate after ${MAX_POLL_ATTEMPTS} attempts`;
        console.error(timeoutMessage);

        // Update the toast
        toast.update(toastId, {
          content: timeoutMessage,
          type: 'error',
          timeout: 5000
        });
        activeToastId.value = null;

        emit('error', timeoutMessage);
        isLoading.value = false;
      }
    } catch (pollError) {
      console.error(`Error polling job status (attempt ${attempts}):`, pollError);

      // Increment consecutive errors counter
      consecutiveErrors++;

      // Check for specific error types
      if (pollError.response?.status === 401 || pollError.response?.status === 403) {
        // Auth error - stop polling immediately
        clearTimeout(pollInterval.value);
        pollInterval.value = null;
        const authError = 'Authentication error. Please log in again.';
        console.error(authError, pollError);

        // Update the toast
        toast.update(toastId, {
          content: authError,
          type: 'error',
          timeout: 5000
        });
        activeToastId.value = null;

        isLoading.value = false;
      } else if (consecutiveErrors >= MAX_CONSECUTIVE_ERRORS) {
        // Too many consecutive errors - stop polling
        clearTimeout(pollInterval.value);
        pollInterval.value = null;
        const networkError = `Network error: Failed to check job status after ${MAX_CONSECUTIVE_ERRORS} consecutive attempts`;
        console.error(networkError, pollError);

        // Update the toast
        toast.update(toastId, {
          content: networkError,
          type: 'error',
          timeout: 5000
        });
        activeToastId.value = null;

        isLoading.value = false;
        emit('error', networkError);
      }
      // For other errors with fewer than MAX_CONSECUTIVE_ERRORS, continue polling
    }

    // Schedule next check with dynamic interval
    pollInterval.value = setTimeout(() => {
      checkJobStatus();
    }, currentInterval);
  };

  // Start the first check
  checkJobStatus();
};

/**
 * Generate estimate from assessment data
 */
const generateEstimate = async () => {
  if (!assessment.value) {
    toast.error('No assessment data available');
    return;
  }

  // Validate project ID
  if (!props.assessmentId) {
    toast.error('Project ID is required');
    return;
  }

  isLoading.value = true;
  error.value = null;

  try {
    // Create a new object with all required properties to ensure proper data structure
    const assessmentWithProjectId = { ...assessment.value };

    // Explicitly set projectId at the root level
    if (props.assessmentId) {
      assessmentWithProjectId.projectId = props.assessmentId;
      console.log('Set explicit projectId at root level:', props.assessmentId);
    }

    // Ensure project object exists with the correct ID
    if (props.assessmentId) {
      assessmentWithProjectId.project = assessmentWithProjectId.project || {};
      assessmentWithProjectId.project.id = props.assessmentId;
      // Also include project_id property for backward compatibility
      assessmentWithProjectId.project.project_id = props.assessmentId;
      console.log('Set project object with both id and project_id:', props.assessmentId);
    }

    // Include standalone projectId parameter in the payload
    const payload = {
      assessmentId: props.assessmentId,
      assessment: assessmentWithProjectId,
      options: {
        aggressiveness: llmSettings.value.aggressiveness,
        mode: llmSettings.value.mode,
        debug: false
      }
    };

    console.log('Complete payload for estimate generation:', JSON.stringify(payload, null, 2));

    const response = await estimatesV2Service.generate(payload);
    console.log('Response from generate:', response);

    // Check if we got a direct array response (legacy mode)
    if (response.data && Array.isArray(response.data)) {
      console.log('Received direct array response (legacy mode)');

      // Format the response into the structure we need
      estimateItems.value = response.data.map(item => ({
        description: item.description || item.item || '',
        quantity: item.quantity,
        unit: item.unit,
        unitPrice: Number(item.unitPrice || item.unit_price || item.rate || item.unitCost || 0),
        total: Number(item.total || item.cost || item.totalCost || 0),
        sourceType: item.sourceType || item.source_type,
        sourceId: item.sourceId || item.source_id
      }));

      // Generate source map if not provided
      sourceMap.value = generateSourceMapFromItems(estimateItems.value);

      console.log('Estimate items:', estimateItems.value);
      console.log('Source map:', sourceMap.value);

      toast.success(`Generated ${estimateItems.value.length} estimate items`);
      emit('update', { estimateItems: estimateItems.value, sourceMap: sourceMap.value });
      isLoading.value = false;
      return;
    }

    // New job-based API mode
    if (response.data && response.data.jobId) {
      console.log('Received job ID:', response.data.jobId);
      await startPolling(response.data.jobId);
    } else {
      throw new Error('Invalid response format from generate endpoint');
    }
  } catch (err) {
    console.error('Error generating estimate:', err);
    error.value = err.response?.data?.message || err.message || 'An unexpected error occurred';
    toast.error(error.value);

    // Log raw AI text for debugging if available (422 error)
    if (err.response?.status === 422 && err.response.data?.data?.raw) {
      console.error('Raw AI text that could not be parsed:', err.response.data.data.raw);
    }
    emit('error', error.value);
    isLoading.value = false;
  }
};

/**
 * Generate source map from estimate items if not provided by API
 */
const generateSourceMapFromItems = (items) => {
  const map = {};

  items.forEach(item => {
    if (item.sourceId && !map[item.sourceId]) {
      map[item.sourceId] = {
        label: item.sourceType === 'measurement' ? 'Measurement' :
               item.sourceType === 'condition' ? 'Condition' :
               item.sourceType === 'material' ? 'Material' : 'Unknown',
        value: item.quantity,
        unit: item.unit,
        type: item.sourceType
      };
    }
  });

  return map;
};

/**
 * Regenerate estimate with current settings
 */
const regenerateEstimate = async () => {
  await generateEstimate();
};

/**
 * Handle LLM settings change
 */
const handleSettingsChange = (newSettings) => {
  llmSettings.value = { ...llmSettings.value, ...newSettings };
};

/**
 * Handle item update from EstimateItemEditor
 */
const handleItemUpdate = (updatedItems) => {
  estimateItems.value = updatedItems;
  emit('update', { estimateItems: estimateItems.value, sourceMap: sourceMap.value });
};

/**
 * Handle source highlighting
 */
const handleSourceHighlight = (sourceId) => {
  activeSourceId.value = sourceId;
};
</script>

<style scoped>
.estimate-from-assessment {
  height: calc(100vh - 200px);
  min-height: 500px;
}
</style>