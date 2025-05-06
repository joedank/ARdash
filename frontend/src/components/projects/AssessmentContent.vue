<template>
  <div class="assessment-content">
    <!-- Assessment Checklist Sections -->
    <template v-if="!readonly && project.type === 'assessment'">
      <!-- Condition Assessment -->
      <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4 mb-4">
        <h3 class="font-medium mb-2">Condition</h3>
        <BaseTextarea
          v-model="condition.assessment"
          placeholder="Describe current condition..."
          rows="3"
          class="mb-2"
          :disabled="readonly"
        />

        <!-- Existing Work Type Suggestions -->
        <div v-if="suggestions.existing.length && !readonly" class="mt-2 flex flex-wrap gap-2">
          <div class="text-sm text-gray-500 dark:text-gray-400 mb-1 w-full">Suggested work types:</div>
          <SuggestedChip
            v-for="s in suggestions.existing"
            :key="s.workTypeId"
            :label="`${s.name} (${Math.round(s.score*100)}%)`"
            :selected="isWorkTypeSelected(s.workTypeId)"
            @click="toggleWorkType(s)"
          />
        </div>

        <!-- Unmatched Work Type Suggestions -->
        <div v-if="suggestions.unmatched.length" class="mt-2 flex flex-wrap gap-2">
          <div class="text-sm text-gray-500 dark:text-gray-400 mb-1 w-full">Unmatched fragments:</div>
          <SuggestedChip v-for="u in suggestions.unmatched" :key="u" color="yellow" :label="`${u} (new)`" @click="router.push(`/work-types/new?name=${encodeURIComponent(u)}`)" />
        </div>
        <PhotoUploadSection
          v-if="!readonly"
          :project-id="project.id"
          photo-type="condition"
          label="Add condition photos"
          @photo-added="$emit('refresh-project')"
        />
        <!-- Project inspection sync happens through v-model now -->
        <PhotoGrid
          v-if="conditionPhotos.length > 0"
          :photos="conditionPhotos"
          class="mt-4"
          @update:photos="updateConditionPhotos"
          @photo-deleted="handlePhotoDeleted"
        />
      </div>

      <!-- Measurements -->
      <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4 mb-4">
        <h3 class="font-medium mb-2">Measurements</h3>
        <div class="space-y-4 mb-4">
          <div
            v-for="(measurement, index) in measurements.items"
            :key="index"
            class="border-b border-gray-200 dark:border-gray-700 pb-4 last:border-0"
          >
            <div class="flex flex-col space-y-2 mb-2">
              <BaseInput
                v-model="measurement.description"
                label="What are you measuring?"
                placeholder="e.g., Roof, Room, Window, Trim"
                :disabled="readonly"
                required
              />
              <p v-if="!measurement.description && !readonly" class="text-xs text-red-500 mt-1">
                Description is required for measurements to be saved
              </p>

              <!-- Measurement Type Selector -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Measurement Type</label>
                <BaseSelect
                  v-model="measurement.measurementType"
                  :options="measurementTypeOptions"
                  :disabled="readonly"
                  @update:modelValue="updateMeasurementFields(measurement)"
                />
              </div>
            </div>

            <!-- Dynamic Measurement Fields Based on Type -->
            <div class="grid grid-cols-3 gap-3 mb-2">
              <!-- Area Measurement (Length × Width) -->
              <template v-if="measurement.measurementType === 'area'">
                <div class="col-span-1">
                  <BaseInput
                    v-model="measurement.dimensions.length"
                    label="Length (ft)"
                    type="number"
                    :disabled="readonly"
                    required
                  />
                  <p v-if="!measurement.dimensions.length && !readonly" class="text-xs text-red-500 mt-1">
                    Length is required
                  </p>
                </div>
                <div class="col-span-1">
                  <BaseInput
                    v-model="measurement.dimensions.width"
                    label="Width (ft)"
                    type="number"
                    :disabled="readonly"
                    required
                  />
                  <p v-if="!measurement.dimensions.width && !readonly" class="text-xs text-red-500 mt-1">
                    Width is required
                  </p>
                </div>
                <div class="col-span-1">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Square Footage</label>
                  <div class="px-4 py-2.5 border border-gray-200 dark:border-gray-700 rounded-lg bg-gray-50 dark:bg-gray-800 text-gray-700 dark:text-gray-300">
                    {{ calculateSquareFootage(measurement) }}
                  </div>
                </div>
              </template>

              <!-- Linear Measurement -->
              <template v-else-if="measurement.measurementType === 'linear'">
                <div class="col-span-2">
                  <BaseInput
                    v-model="measurement.dimensions.length"
                    label="Length (ft)"
                    type="number"
                    :disabled="readonly"
                    required
                  />
                  <p v-if="!measurement.dimensions.length && !readonly" class="text-xs text-red-500 mt-1">
                    Length is required
                  </p>
                </div>
                <div class="col-span-1">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Linear Feet</label>
                  <div class="px-4 py-2.5 border border-gray-200 dark:border-gray-700 rounded-lg bg-gray-50 dark:bg-gray-800 text-gray-700 dark:text-gray-300">
                    {{ formatLinearFeet(measurement) }}
                  </div>
                </div>
              </template>

              <!-- Quantity Measurement -->
              <template v-else-if="measurement.measurementType === 'quantity'">
                <div class="col-span-2">
                  <BaseInput
                    v-model="measurement.quantity"
                    label="Quantity"
                    type="number"
                    :disabled="readonly"
                    required
                  />
                  <p v-if="!measurement.quantity && !readonly" class="text-xs text-red-500 mt-1">
                    Quantity is required
                  </p>
                </div>
                <div class="col-span-1">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Unit</label>
                  <BaseSelect
                    v-model="measurement.quantityUnit"
                    :options="quantityUnitOptions"
                    :disabled="readonly"
                  />
                </div>
              </template>
            </div>
            <BaseButton
              v-if="!readonly && measurements.items.length > 1"
              variant="danger"
              size="sm"
              @click="removeMeasurement(index)"
              class="mt-2"
            >
              <BaseIcon name="trash" />
            </BaseButton>
          </div>
        </div>
        <BaseButton
          v-if="!readonly"
          variant="secondary"
          size="sm"
          @click="addMeasurement"
          class="w-full"
        >
          Add Measurement
        </BaseButton>
      </div>

      <!-- Materials -->
      <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4">
        <h3 class="font-medium mb-2">Materials Needed</h3>
        <div class="space-y-4 mb-4">
          <div
            v-for="(item, index) in materials.items"
            :key="index"
            class="border-b border-gray-200 dark:border-gray-700 pb-4 last:border-0"
          >
            <!-- Material name - full width on mobile -->
            <div class="mb-3">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Material</label>
              <BaseInput
                v-model="item.name"
                placeholder="Material name"
                :disabled="readonly"
              />
            </div>

            <!-- Quantity and unit - side by side on all screens -->
            <div class="flex items-start gap-2">
              <!-- Quantity field -->
              <div class="flex-1">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Qty</label>
                <BaseInput
                  v-model="item.quantity"
                  type="number"
                  placeholder="Qty"
                  :disabled="readonly"
                />
              </div>

              <!-- Unit field -->
              <div class="flex-1">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Unit</label>
                <BaseSelect
                  v-model="item.unit"
                  :options="unitOptions"
                  :disabled="readonly"
                />
              </div>

              <!-- Delete button -->
              <div class="pt-7">
                <BaseButton
                  v-if="!readonly"
                  variant="danger"
                  size="sm"
                  @click="removeMaterial(index)"
                  class="flex-shrink-0"
                >
                  <BaseIcon name="trash" />
                </BaseButton>
              </div>
            </div>
          </div>
        </div>
        <BaseButton
          v-if="!readonly"
          variant="secondary"
          size="sm"
          @click="addMaterial"
          class="w-full"
        >
          Add Material
        </BaseButton>
      </div>
    </template>

    <!-- Read-only version for viewing historical data -->
    <template v-else>
      <div v-if="normalizedProject" class="space-y-4"> {/* Use normalizedProject */}
        <!-- Basic Project Info -->
        <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4">
          <h3 class="font-medium mb-2">Assessment Information</h3>
          <div class="grid sm:grid-cols-2 gap-4">
            <div>
              <p class="text-sm text-gray-500 dark:text-gray-400">Status</p>
              <p>{{ normalizedProject.status }}</p> {/* Use normalizedProject */}
            </div>
            <div>
              <p class="text-sm text-gray-500 dark:text-gray-400">Scheduled Date</p>
              <p>{{ formatDate(normalizedProject.scheduledDate) }}</p> {/* Use normalized scheduledDate */}
            </div>
            <!-- Scope removed -->
          </div>
        </div>

        <!-- Inspection Data (if available) -->
        <div
          v-if="normalizedProject.inspections && normalizedProject.inspections.length > 0"
          class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4"
        >
          <h3 class="font-medium mb-2">Assessment Details</h3>

          <!-- Display inspection data in read-only format -->
          <div v-for="inspection in normalizedProject.inspections" :key="inspection.id" class="mb-4">
            <h4 class="font-medium mb-1 capitalize">{{ inspection.category }}</h4>

            <!-- Condition -->
            <template v-if="inspection.category === 'condition'">
              <p>{{ inspection.content.assessment }}</p>
            </template>

            <!-- Measurements -->
            <template v-else-if="inspection.category === 'measurements'">
              <div class="space-y-4">
                <template v-if="Array.isArray(inspection.content.items)">
                  <div v-for="(item, idx) in inspection.content.items" :key="idx" class="border-b border-gray-200 dark:border-gray-700 last:border-0 pb-4">
                    <p class="mb-1"><strong>Item Measured:</strong> {{ item.description || 'N/A' }}</p>
                    <div class="grid grid-cols-1 gap-2">
                      <div>
                        <p class="text-sm text-gray-500 dark:text-gray-400">{{ getMeasurementTypeLabel(item) }}</p>
                        <p v-if="getMeasurementType(item) === 'area'">
                          {{ getDisplayLength(item) }} ft × {{ getDisplayWidth(item) }} ft = {{ calculateSquareFootage(item) }}
                        </p>
                        <p v-else-if="getMeasurementType(item) === 'linear'">
                          {{ getDisplayLength(item) }} linear ft
                        </p>
                        <p v-else-if="getMeasurementType(item) === 'quantity'">
                          {{ item.quantity || 'N/A' }} {{ item.quantityUnit || 'units' }}
                        </p>
                      </div>
                    </div>
                  </div>
                </template>
                <template v-else>
                  <!-- Legacy format support -->
                  <p class="mb-1"><strong>Item Measured:</strong> {{ inspection.content.description || 'N/A' }}</p>
                  <div class="grid grid-cols-1 gap-2">
                    <div>
                      <p class="text-sm text-gray-500 dark:text-gray-400">Dimensions</p>
                      <p>{{ inspection.content.dimensions?.length || 'N/A' }} ft × {{ inspection.content.dimensions?.width || 'N/A' }} ft
                        = {{ calculateLegacySquareFootage(inspection.content.dimensions) }}</p>
                    </div>
                  </div>
                </template>
              </div>
            </template>

            <!-- Materials -->
            <template v-else-if="inspection.category === 'materials'">
              <div v-if="inspection.content.items && inspection.content.items.length > 0">
                <ul class="list-disc pl-5">
                  <li v-for="(item, idx) in inspection.content.items" :key="idx">
                    {{ item.name }} ({{ item.quantity }} {{ item.unit || 'each' }})
                  </li>
                </ul>
              </div>
              <p v-else>No materials specified</p>
            </template>

            <!-- Generic content display for other categories -->
            <template v-else>
              <pre class="whitespace-pre-wrap text-sm">{{ JSON.stringify(inspection.content, null, 2) }}</pre>
            </template>
          </div>
        </div>

        <!-- Photos -->
        <div v-if="conditionPhotos.length > 0" class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4">
          <h3 class="font-medium mb-2">Condition Photos</h3>
          <PhotoGrid
            :photos="conditionPhotos"
            @update:photos="updateConditionPhotos"
            @photo-deleted="handlePhotoDeleted"
          />
        </div>
        <!-- Removed general assessment photos section as photos should now be linked to condition inspections -->
        <!--
        <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4 mt-4">
          <h3 class="font-medium mb-2">Assessment Photos</h3>
          <PhotoUploadSection
            v-if="!readonly"
            :project-id="project.id"
            photo-type="assessment"
            label="Add assessment photos"
            @photo-added="$emit('refresh-project')"
          />
          <PhotoGrid
            v-if="otherAssessmentPhotos.length > 0"
            :photos="otherAssessmentPhotos"
            class="mt-4"
          />
        </div>
        -->
      </div>
    </template>
  </div>
</template>

<script setup>
import { toCamelCase } from '@/utils/casing';
import { ref, computed, watch, reactive } from 'vue';
import { useRouter } from 'vue-router';
import { debounce } from 'lodash-es';
import BaseTextarea from '@/components/form/BaseTextarea.vue';
import BaseInput from '@/components/form/BaseInput.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseIcon from '@/components/base/BaseIcon.vue';
import BaseSelect from '@/components/form/BaseSelect.vue';
import Badge from 'primevue/badge';
import Dialog from 'primevue/dialog';
import assessmentsService from '@/services/assessments.service.js';
import workTypesService from '@/services/work-types.service.js';
import PhotoUploadSection from '@/components/projects/PhotoUploadSection.vue';
import PhotoGrid from '@/components/projects/PhotoGrid.vue';
import SuggestedChip from '@/components/projects/SuggestedChip.vue';

// Initialize the router
const router = useRouter();

const emit = defineEmits(['refresh-project', 'update:condition', 'update:measurements', 'update:materials', 'photo-deleted', 'update:workTypes']);

const props = defineProps({
  project: {
    type: Object,
    required: true
  },
  workTypes: {
    type: Array,
    default: () => []
  },
  readonly: {
    type: Boolean,
    default: false
  },
  condition: {
    type: Object,
    default: () => ({ assessment: '' })
  },
  measurements: {
    type: Object,
    default: () => ({
      items: [{
        description: '',
        length: '',
        width: '',
        units: 'feet'
      }]
    })
  },
  materials: {
    type: Object,
    default: () => ({
      items: [{ name: '', quantity: '', unit: 'each' }]
    })
  }
});


// Normalize the project prop for consistent access - Convert once to avoid reactivity issues
const normalizedProject = computed(() => {
  // Use a non-reactive conversion to avoid reactivity loops
  if (!props.project) return {};
  // Use a non-reactive approach to normalize
  const projectCopy = JSON.parse(JSON.stringify(props.project));
  return toCamelCase(projectCopy);
});

// Form data initialized from props
const condition = ref(props.condition);
const measurements = ref(props.measurements);
const materials = ref(props.materials);
const suggestions = reactive({
  existing: [],
  unmatched: []
});
const workTypes = ref(props.workTypes || []);
const selectedDraft = ref(null);
const showDraftModal = ref(false);
const isSavingDraft = ref(false);
const draftSaveError = ref('');

// Watch for changes and emit updates
watch(condition, (newValue) => {
  emit('update:condition', newValue);
}, { deep: true });

watch(measurements, (newValue) => {
  emit('update:measurements', newValue);
}, { deep: true });

watch(materials, (newValue) => {
  emit('update:materials', newValue);
}, { deep: true });

watch(workTypes, (newValue) => {
  emit('update:workTypes', newValue);
}, { deep: true });

// Function to run detection with proper logging
async function runDetect(text) {
  if (!text || text.length < 15) return; // Skip short text

  console.log('Detecting work types for:', text.substring(0, 30) + '...');
  try {
    const result = await assessmentsService.detectWorkTypes(text);
    console.log('API response for work types:', result);
    
    // Update suggestions
    suggestions.existing = result.existing || [];
    suggestions.unmatched = result.unmatched || [];
    
    console.log('Existing work types:', suggestions.existing);
    console.log('Unmatched fragments:', suggestions.unmatched);
  } catch (error) {
    console.error('Error detecting work types:', error);
  }
}

// Create debounced version with longer delay for LLM processing
const detectDebounced = debounce(runDetect, 800);

// Watch for changes and trigger debounced detection
watch(() => condition.value.assessment, value => detectDebounced(value));

// Helper functions for measurement field handling
const getMeasurementValue = (measurement, property) => {
  // First check direct property
  if (measurement[property] !== undefined && measurement[property] !== '') {
    return measurement[property];
  }
  // Then check in dimensions object
  if (measurement.dimensions && measurement.dimensions[property] !== undefined) {
    return measurement.dimensions[property];
  }
  // Default to empty string if not found
  return '';
};

const setMeasurementValue = (measurement, property, value) => {
  // For quantity measurements, always set directly on the measurement object
  if (measurement.measurementType === 'quantity' && (property === 'quantity' || property === 'quantityUnit')) {
    measurement[property] = value;
    return;
  }

  // For area and linear measurements, use the dimensions object if it exists
  if (measurement.measurementType === 'area' || measurement.measurementType === 'linear') {
    // Create dimensions object if it doesn't exist
    if (!measurement.dimensions) {
      measurement.dimensions = { units: 'feet' };
    }
    measurement.dimensions[property] = value;
    return;
  }

  // Fallback: set directly on the measurement object
  measurement[property] = value;
};

// Length field handling
const getLengthField = (measurement) => {
  // Log the measurement object to debug
  console.log('Getting length for measurement:', measurement);

  // First check dimensions object
  if (measurement.dimensions && measurement.dimensions.length !== undefined) {
    console.log('Found length in dimensions:', measurement.dimensions.length);
    return measurement.dimensions.length;
  }

  // Then check direct property
  if (measurement.length !== undefined) {
    console.log('Found length directly:', measurement.length);
    return measurement.length;
  }

  // Default to empty string if not found
  console.log('No length found, returning empty string');
  return '';
};

const setLengthField = (measurement, value) => {
  console.log('Setting length for measurement to:', value);

  // For area and linear measurements, use the dimensions object
  if (measurement.measurementType === 'area' || measurement.measurementType === 'linear') {
    // Create dimensions object if it doesn't exist
    if (!measurement.dimensions) {
      measurement.dimensions = { units: 'feet' };
    }
    measurement.dimensions.length = value;
    console.log('Set length in dimensions:', measurement.dimensions);
  } else {
    // Fallback: set directly on the measurement object
    measurement.length = value;
    console.log('Set length directly:', measurement);
  }
};

// Width field handling
const getWidthField = (measurement) => {
  // Log the measurement object to debug
  console.log('Getting width for measurement:', measurement);

  // First check dimensions object
  if (measurement.dimensions && measurement.dimensions.width !== undefined) {
    console.log('Found width in dimensions:', measurement.dimensions.width);
    return measurement.dimensions.width;
  }

  // Then check direct property
  if (measurement.width !== undefined) {
    console.log('Found width directly:', measurement.width);
    return measurement.width;
  }

  // Default to empty string if not found
  console.log('No width found, returning empty string');
  return '';
};

const setWidthField = (measurement, value) => {
  console.log('Setting width for measurement to:', value);

  // For area measurements, use the dimensions object
  if (measurement.measurementType === 'area') {
    // Create dimensions object if it doesn't exist
    if (!measurement.dimensions) {
      measurement.dimensions = { units: 'feet' };
    }
    measurement.dimensions.width = value;
    console.log('Set width in dimensions:', measurement.dimensions);
  } else {
    // Fallback: set directly on the measurement object
    measurement.width = value;
    console.log('Set width directly:', measurement);
  }
};

// Measurement type options
const measurementTypeOptions = [
  { value: 'area', label: 'Area (sq ft)' },
  { value: 'linear', label: 'Linear (ln ft)' },
  { value: 'quantity', label: 'Quantity' }
];

// Quantity unit options
const quantityUnitOptions = [
  { value: 'each', label: 'Each' },
  { value: 'pieces', label: 'Pieces' },
  { value: 'boxes', label: 'Boxes' },
  { value: 'sheets', label: 'Sheets' },
  { value: 'gallons', label: 'Gallons' },
  { value: 'hours', label: 'Hours' }
];

// Helper function to get the appropriate unit options based on measurement type
const getSuggestedUnitOptions = (measurementType) => {
  switch (measurementType) {
    case 'area':
      return [
        { value: 'sq ft', label: 'Square Feet (sq ft)' },
        { value: 'sq yd', label: 'Square Yards (sq yd)' },
        { value: 'sq m', label: 'Square Meters (sq m)' }
      ];
    case 'linear':
      return [
        { value: 'ft', label: 'Feet (ft)' },
        { value: 'in', label: 'Inches (in)' },
        { value: 'yd', label: 'Yards (yd)' },
        { value: 'm', label: 'Meters (m)' }
      ];
    case 'quantity':
      return [
        { value: 'each', label: 'Each' },
        { value: 'job', label: 'Job' },
        { value: 'set', label: 'Set' }
      ];
    default:
      return [];
  }
};

// Update suggested units when measurement type changes
const updateSuggestedUnits = () => {
  if (!selectedDraft.value) return;
  
  // Get the appropriate unit options for the selected measurement type
  const unitOptions = getSuggestedUnitOptions(selectedDraft.value.measurementType);
  
  // Check if the current unit is valid for the selected measurement type
  const isUnitValid = unitOptions.some(option => option.value === selectedDraft.value.suggestedUnits);
  
  // If the current unit is not valid, set it to the first option
  if (!isUnitValid && unitOptions.length > 0) {
    selectedDraft.value.suggestedUnits = unitOptions[0].value;
  }
};

// Measurements management
const addMeasurement = () => {
  measurements.value.items.push({
    description: '',
    measurementType: 'area', // Default to area measurement
    dimensions: {
      length: '',
      width: '',
      units: 'feet'
    },
    quantity: '1',
    quantityUnit: 'each'
  });
  
  // Scroll to the newly added measurement for better UX
  setTimeout(() => {
    const measurementsContainer = document.querySelector('.assessment-content');
    if (measurementsContainer) {
      measurementsContainer.scrollTop = measurementsContainer.scrollHeight;
    }
  }, 100);
};

// Update measurement fields based on type selection
const updateMeasurementFields = (measurement) => {
  // Ensure all required fields exist based on measurement type
  if (measurement.measurementType === 'area') {
    // For area measurements, ensure dimensions object exists with length and width
    if (!measurement.dimensions) {
      measurement.dimensions = { units: 'feet', length: '', width: '' };
    } else {
      if (!measurement.dimensions.length) measurement.dimensions.length = '';
      if (!measurement.dimensions.width) measurement.dimensions.width = '';
      if (!measurement.dimensions.units) measurement.dimensions.units = 'feet';
    }

    // Clean up any direct properties that might exist from previous formats
    delete measurement.length;
    delete measurement.width;
    delete measurement.units;
  } else if (measurement.measurementType === 'linear') {
    // For linear measurements, ensure dimensions object exists with length
    if (!measurement.dimensions) {
      measurement.dimensions = { units: 'feet', length: '' };
    } else {
      if (!measurement.dimensions.length) measurement.dimensions.length = '';
      if (!measurement.dimensions.units) measurement.dimensions.units = 'feet';
      // Reset width as it's not needed for linear measurements
      measurement.dimensions.width = '';
    }

    // Clean up any direct properties that might exist from previous formats
    delete measurement.length;
    delete measurement.width;
    delete measurement.units;
  } else if (measurement.measurementType === 'quantity') {
    // For quantity measurements, ensure quantity and unit properties exist
    if (!measurement.quantity) measurement.quantity = '1';
    if (!measurement.quantityUnit) measurement.quantityUnit = 'each';

    // Clean up dimensions object if it exists (not needed for quantity)
    delete measurement.dimensions;

    // Clean up any direct properties that might exist from previous formats
    delete measurement.length;
    delete measurement.width;
    delete measurement.units;
  }

  console.log('Updated measurement fields:', measurement);
};

// Helper to determine measurement type from item data
const getMeasurementType = (item) => {
  // If the item has an explicit measurement type, use it
  if (item.measurementType) return item.measurementType;

  // Otherwise infer from the data structure
  if (item.quantity !== undefined) return 'quantity';

  // Check dimensions object if it exists
  if (item.dimensions) {
    if (item.dimensions.width && item.dimensions.length) return 'area';
    if (item.dimensions.length) return 'linear';
  }

  // Check direct properties (legacy format)
  if (item.width && item.length) return 'area';
  if (item.length) return 'linear';

  // Default to area if we can't determine
  return 'area';
};

// Log the detected measurement type for debugging
const logMeasurementType = (item) => {
  const type = getMeasurementType(item);
  console.log('Detected measurement type:', type, 'for item:', item);
  return type;
};

// Get display label for measurement type
const getMeasurementTypeLabel = (item) => {
  const type = getMeasurementType(item);
  switch (type) {
    case 'area': return 'Dimensions';
    case 'linear': return 'Linear Measurement';
    case 'quantity': return 'Quantity';
    default: return 'Measurement';
  }
};

// Helper for read-only view to display values correctly
const getDisplayLength = (item) => {
  return getMeasurementValue(item, 'length') || 'N/A';
};

// Helper for read-only view to display values correctly
const getDisplayWidth = (item) => {
  return getMeasurementValue(item, 'width') || 'N/A';
};

// Format linear feet display
const formatLinearFeet = (measurement) => {
  const lengthValue = getMeasurementValue(measurement, 'length');
  if (!lengthValue) return '0 ln ft';
  const length = parseFloat(lengthValue) || 0;
  return `${length.toFixed(2)} ln ft`;
};

// This duplicate declaration has been removed as it's already defined at line 417

// Calculate square footage
const calculateSquareFootage = (measurement) => {
  // Use helper function to get values from either location
  const length = parseFloat(getMeasurementValue(measurement, 'length')) || 0;
  const width = parseFloat(getMeasurementValue(measurement, 'width')) || 0;

  if (length === 0 || width === 0) return '0 sq ft';

  const area = length * width;

  console.log('Calculated square footage:', area, 'from length:', length, 'width:', width);
  return `${area.toFixed(2)} sq ft`;
};

// Calculate square footage for legacy format
const calculateLegacySquareFootage = (dimensions) => {
  if (!dimensions || !dimensions.length || !dimensions.width) return '0 sq ft';

  const length = parseFloat(dimensions.length) || 0;
  const width = parseFloat(dimensions.width) || 0;
  const area = length * width;

  return `${area.toFixed(2)} sq ft`;
};


const removeMeasurement = (index) => {
  measurements.value.items.splice(index, 1);
};

// Initialize form data from project inspections - use onMounted to avoid reactivity issues
import { onMounted } from 'vue';

// Initialize inspection data once on component mount, not on every prop change
onMounted(() => {
  // Only initialize if values aren't already set via props
  const normProject = normalizedProject.value;
  if (normProject && normProject.inspections && normProject.inspections.length > 0) {
    let hasUpdatedCondition = false;
    let hasUpdatedMeasurements = false;
    let hasUpdatedMaterials = false;

    normProject.inspections.forEach(inspection => {
      switch (inspection.category) {
        case 'condition':
          if (!hasUpdatedCondition && (!condition.value || !condition.value.assessment)) {
            condition.value = JSON.parse(JSON.stringify(inspection.content || { assessment: '' }));
            hasUpdatedCondition = true;
          }
          break;
        case 'measurements':
          if (!hasUpdatedMeasurements && (!measurements.value || !measurements.value.items || measurements.value.items.length === 0)) {
            console.log('Processing measurements inspection:', inspection.content);

            if (inspection.content && Array.isArray(inspection.content.items)) {
              // Transform items using normalized properties
              const updatedItems = inspection.content.items.map(item => {
                // Determine measurement type
                const measurementType = item.measurementType ||
                  (item.quantity !== undefined ? 'quantity' :
                   (item.dimensions?.width !== undefined ? 'area' : 'linear'));

                console.log('Processing measurement item:', item, 'Detected type:', measurementType);

                // Create base item with common properties
                const transformedItem = {
                  description: item.description || '',
                  measurementType: measurementType
                };

                // Add type-specific properties
                if (measurementType === 'area' || measurementType === 'linear') {
                  // Create dimensions object for area and linear measurements
                  transformedItem.dimensions = {
                    units: item.dimensions?.units || item.units || 'feet',
                    length: item.dimensions?.length || item.length || ''
                  };

                  // Add width for area measurements
                  if (measurementType === 'area') {
                    transformedItem.dimensions.width = item.dimensions?.width || item.width || '';
                  }
                } else if (measurementType === 'quantity') {
                  // Add quantity properties directly to the item
                  transformedItem.quantity = item.quantity || '1';
                  transformedItem.quantityUnit = item.quantityUnit || 'each';
                }

                console.log('Transformed item:', transformedItem);
                return transformedItem;
              });

              measurements.value = { items: updatedItems };
              console.log('Updated measurements:', measurements.value);
            } else if (inspection.content) {
              // Handle legacy format
              measurements.value = {
                items: [{
                  description: inspection.content.description || '',
                  measurementType: 'area',
                  dimensions: {
                    length: inspection.content.dimensions?.length || inspection.content.length || '',
                    width: inspection.content.dimensions?.width || inspection.content.width || '',
                    units: inspection.content.dimensions?.units || inspection.content.units || 'feet'
                  }
                }]
              };
              console.log('Updated measurements from legacy format:', measurements.value);
            }
            hasUpdatedMeasurements = true;
          }
          break;
        case 'materials':
          if (!hasUpdatedMaterials && (!materials.value || !materials.value.items || materials.value.items.length === 0)) {
            materials.value = JSON.parse(JSON.stringify(inspection.content || { items: [{ name: '', quantity: '', unit: 'each' }] }));
            hasUpdatedMaterials = true;
          }
          break;
      }
    });

    // After initializing, emit updates
    if (hasUpdatedCondition) emit('update:condition', condition.value);
    if (hasUpdatedMeasurements) emit('update:measurements', measurements.value);
    if (hasUpdatedMaterials) emit('update:materials', materials.value);
  }
});

// Materials list management
const addMaterial = () => {
  materials.value.items.push({ name: '', quantity: '', unit: 'each' });
};

// Unit options for materials
const unitOptions = [
  { value: 'each', label: 'Each' },
  { value: 'sq_ft', label: 'Sq Ft' },
  { value: 'ln_ft', label: 'Ln Ft' },
  { value: 'sheets', label: 'Sheets' },
  { value: 'gallons', label: 'Gallons' },
  { value: 'yards', label: 'Yards' }
];

const removeMaterial = (index) => {
  materials.value.items.splice(index, 1);
};

// Local references for photos to ensure proper deletion
const localConditionPhotos = ref([]);

// Update photos once and when project changes explicitly, avoiding reactive loops
watch(() => props.project?.id, () => {
  const normProject = normalizedProject.value;
  if (normProject?.photos) {
    localConditionPhotos.value = normProject.photos
      .filter(p => p.photoType === 'condition' || p.photo_type === 'condition')
      .map(p => ({ ...p })); // Create a copy to avoid reactivity issues
  } else {
    localConditionPhotos.value = [];
  }
}, { immediate: true });

// Get condition photos with debug logging
const conditionPhotos = computed(() => {
  return localConditionPhotos.value;
});

// Update local condition photos when they change
const updateConditionPhotos = (updatedPhotos) => {
  console.log('Updating condition photos:', updatedPhotos.length);
  localConditionPhotos.value = [...updatedPhotos];
};

// Handle photo deletion
const handlePhotoDeleted = (photoId) => {
  console.log('Condition photo deleted:', photoId);
  localConditionPhotos.value = localConditionPhotos.value.filter(p => p.id !== photoId);
  emit('photo-deleted', photoId);
  emit('refresh-project'); // Request a refresh from parent
};

// Work types management
const toggleWorkType = (workType) => {
  const updated = assessmentsService.toggleWorkType(workTypes.value, workType);
  workTypes.value = [...updated]; // Create a new array to trigger reactivity
  console.log('Updated work types:', workTypes.value);
};

const isWorkTypeSelected = (workTypeId) => {
  return workTypes.value.includes(workTypeId);
};

// Removed otherAssessmentPhotos computed property as general assessment photos are no longer used separately
/*
const otherAssessmentPhotos = computed(() => {
  if (!props.project?.photos) return [];
  const photos = props.project.photos.filter(p => p.photo_type === 'assessment');
  console.log('Assessment photos:', photos.map(p => ({ id: p.id, path: p.file_path })));
  return photos;
});
*/

// Helper to format dates
const formatDate = (dateString) => {
  if (!dateString) return 'Not scheduled';
  const date = new Date(dateString);
  return date.toLocaleDateString();
};
</script>
