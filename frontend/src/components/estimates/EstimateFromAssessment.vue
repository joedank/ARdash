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
          <EstimateItemEditor
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
      @regenerate="regenerateEstimate"
      @settingsChange="handleSettingsChange"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useToast } from 'vue-toastification';
import BaseSplitPanel from '@/components/layout/BaseSplitPanel.vue';
import AssessmentMarkdownPanel from './AssessmentMarkdownPanel.vue';
import EstimateItemEditor from './EstimateItemEditor.vue';
import EstimateControls from './EstimateControls.vue';
import estimateService from '@/services/estimates.service';
import standardizedEstimatesService from '@/services/standardized-estimates.service';

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

/**
 * Generate estimate from assessment data
 */
const generateEstimate = async () => {
  if (!assessment.value) {
    toast.error('No assessment data available');
    return;
  }

  isLoading.value = true;
  error.value = null;

  try {
    toast.info('Generating estimate from assessment data...');

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
      projectId: props.assessmentId,
      assessment: assessmentWithProjectId,
      options: {
        aggressiveness: llmSettings.value.aggressiveness,
        mode: llmSettings.value.mode,
        debug: false
      }
    };

    console.log('Complete payload for estimate generation:', JSON.stringify(payload, null, 2));

    // Log the assessment data being sent
    console.log('Sending assessment data for estimate generation:', JSON.stringify(assessmentWithProjectId, null, 2));

    // Use standardized service for better error handling and data conversion
    // Send the complete payload
    console.log('Calling standardizedEstimatesService.generateFromAssessment with payload');
    const result = await standardizedEstimatesService.generateFromAssessment(payload);

    // Log the full result for debugging
    console.log('Result from generateFromAssessment:', JSON.stringify(result, null, 2));

    if (result.success && result.data) {
      console.log('Generated estimate data:', result.data);

      // Check if result.data is an array
      if (!Array.isArray(result.data)) {
        console.warn('Expected result.data to be an array, got:', typeof result.data);
        // Try to handle non-array data
        const dataArray = Array.isArray(result.data) ? result.data :
                         (result.data.items ? result.data.items :
                         (result.data.data && Array.isArray(result.data.data) ? result.data.data : []));

        console.log('Converted data to array:', dataArray);

        // Format the response into the structure we need
        estimateItems.value = dataArray.map(item => ({
          description: item.description || item.item || '',
          quantity: item.quantity,
          unit: item.unit,
          unitPrice: Number(item.unitPrice || item.unit_price || item.rate || item.unitCost || 0),
          total: Number(item.total || item.cost || item.totalCost || 0),
          sourceType: item.sourceType || item.source_type,
          sourceId: item.sourceId || item.source_id
        }));
      } else {
        // Format the response into the structure we need
        estimateItems.value = result.data.map(item => ({
          description: item.description || item.item || '',
          quantity: item.quantity,
          unit: item.unit,
          unitPrice: Number(item.unitPrice || item.unit_price || item.rate || item.unitCost || 0),
          total: Number(item.total || item.cost || item.totalCost || 0),
          sourceType: item.sourceType || item.source_type,
          sourceId: item.sourceId || item.source_id
        }));
      }

      // Build source map from the results
      if (result.sourceMap) {
        sourceMap.value = result.sourceMap;
      } else {
        // Generate simple source map if not provided by API
        sourceMap.value = generateSourceMapFromItems(estimateItems.value);
      }

      console.log('Estimate items:', estimateItems.value);
      console.log('Source map:', sourceMap.value);

      toast.success(`Generated ${estimateItems.value.length} estimate items`);
      emit('update', { estimateItems: estimateItems.value, sourceMap: sourceMap.value });
    } else {
      error.value = result.message || 'Failed to generate estimate from assessment data';
      console.error('Failed to generate estimate:', error.value);
      toast.error(error.value);
      emit('error', error.value);
    }
  } catch (err) {
    console.error('Error generating estimate:', err);
    error.value = err.response?.data?.message || err.message || 'An unexpected error occurred';
    toast.error(error.value);
    emit('error', error.value);
  } finally {
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