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
  if (assessment.value && assessment.value.formattedMarkdown) {
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
    // Use standardized service for better error handling and data conversion
    const response = await standardizedEstimatesService.getAssessmentData(props.assessmentId);

    if (response.success && response.data) {
      assessment.value = response.data;
      console.log('Assessment data loaded in component:', assessment.value);
      toast.success('Assessment data loaded successfully');
    } else {
      error.value = response.message || 'Failed to load assessment data';
      toast.error(error.value);
      emit('error', error.value);
    }
  } catch (err) {
    console.error('Error loading assessment data:', err);
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

    // Use standardized service for better error handling and data conversion
    const result = await standardizedEstimatesService.generateFromAssessment(assessment.value, {
      aggressiveness: llmSettings.value.aggressiveness,
      mode: llmSettings.value.mode,
      debug: false
    });

    if (result.success && result.data) {
      console.log('Generated estimate data:', result.data);

      // Format the response into the structure we need
      estimateItems.value = result.data.map(item => ({
        description: item.description,
        quantity: item.quantity,
        unit: item.unit,
        unitPrice: item.unitPrice || item.unit_price,
        total: item.total,
        sourceType: item.sourceType || item.source_type,
        sourceId: item.sourceId || item.source_id
      }));

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