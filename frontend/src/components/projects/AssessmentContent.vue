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
              />

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
                    v-model="measurement.length"
                    label="Length (ft)"
                    type="number"
                    :disabled="readonly"
                  />
                </div>
                <div class="col-span-1">
                  <BaseInput
                    v-model="measurement.width"
                    label="Width (ft)"
                    type="number"
                    :disabled="readonly"
                  />
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
                    v-model="measurement.length"
                    label="Length (ft)"
                    type="number"
                    :disabled="readonly"
                  />
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
                  />
                </div>
                <div class="col-span-1">
                  <BaseSelect
                    v-model="measurement.quantityUnit"
                    :options="quantityUnitOptions"
                    label="Unit"
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
      <div v-if="project" class="space-y-4">
        <!-- Basic Project Info -->
        <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4">
          <h3 class="font-medium mb-2">Assessment Information</h3>
          <div class="grid sm:grid-cols-2 gap-4">
            <div>
              <p class="text-sm text-gray-500 dark:text-gray-400">Status</p>
              <p>{{ project.status }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-500 dark:text-gray-400">Scheduled Date</p>
              <p>{{ formatDate(project.scheduled_date) }}</p>
            </div>
            <!-- Scope removed -->
          </div>
        </div>

        <!-- Inspection Data (if available) -->
        <div
          v-if="project.inspections && project.inspections.length > 0"
          class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4"
        >
          <h3 class="font-medium mb-2">Assessment Details</h3>

          <!-- Display inspection data in read-only format -->
          <div v-for="inspection in project.inspections" :key="inspection.id" class="mb-4">
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
                          {{ item.dimensions?.length || item.length || 'N/A' }} ft × {{ item.dimensions?.width || item.width || 'N/A' }} ft = {{ calculateSquareFootage(item) }}
                        </p>
                        <p v-else-if="getMeasurementType(item) === 'linear'">
                          {{ item.dimensions?.length || item.length || 'N/A' }} linear ft
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
import { ref, computed, watch } from 'vue';
import BaseTextarea from '@/components/form/BaseTextarea.vue';
import BaseInput from '@/components/form/BaseInput.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseIcon from '@/components/base/BaseIcon.vue';
import BaseSelect from '@/components/form/BaseSelect.vue';
import PhotoUploadSection from '@/components/projects/PhotoUploadSection.vue';
import PhotoGrid from '@/components/projects/PhotoGrid.vue';

const emit = defineEmits(['refresh-project', 'update:condition', 'update:measurements', 'update:materials', 'photo-deleted']);

const props = defineProps({
  project: {
    type: Object,
    required: true
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

// Form data initialized from props
const condition = ref(props.condition);
const measurements = ref(props.measurements);
const materials = ref(props.materials);

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

// Measurements management
const addMeasurement = () => {
  measurements.value.items.push({
    description: '',
    measurementType: 'area', // Default to area measurement
    length: '',
    width: '',
    quantity: '1',
    quantityUnit: 'each',
    units: 'feet'
  });
};

// Update measurement fields based on type selection
const updateMeasurementFields = (measurement) => {
  // Ensure all required fields exist based on measurement type
  if (measurement.measurementType === 'area') {
    // Make sure length and width are initialized
    if (!measurement.length) measurement.length = '';
    if (!measurement.width) measurement.width = '';
  } else if (measurement.measurementType === 'linear') {
    // For linear, we only need length
    if (!measurement.length) measurement.length = '';
    // Reset width as it's not needed
    measurement.width = '';
  } else if (measurement.measurementType === 'quantity') {
    // For quantity, we need quantity and unit
    if (!measurement.quantity) measurement.quantity = '1';
    if (!measurement.quantityUnit) measurement.quantityUnit = 'each';
  }
};

// Helper to determine measurement type from item data
const getMeasurementType = (item) => {
  // If the item has an explicit measurement type, use it
  if (item.measurementType) return item.measurementType;

  // Otherwise infer from the data structure
  if (item.quantity && item.quantityUnit) return 'quantity';
  if ((item.dimensions?.width || item.width) && (item.dimensions?.length || item.length)) return 'area';
  if (item.dimensions?.length || item.length) return 'linear';

  // Default to area if we can't determine
  return 'area';
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

// Format linear feet display
const formatLinearFeet = (measurement) => {
  if (!measurement.length) return '0 ln ft';
  const length = parseFloat(measurement.length) || 0;
  return `${length.toFixed(2)} ln ft`;
};

// Calculate square footage
const calculateSquareFootage = (measurement) => {
  // Handle both direct properties and nested dimensions
  const length = parseFloat(measurement.dimensions?.length || measurement.length) || 0;
  const width = parseFloat(measurement.dimensions?.width || measurement.width) || 0;

  if (length === 0 || width === 0) return '0 sq ft';

  const area = length * width;

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

// Initialize form data from project inspections
watch(() => props.project, (newProject) => {
  if (newProject && newProject.inspections) {
    newProject.inspections.forEach(inspection => {
      switch (inspection.category) {
        case 'condition':
          condition.value = inspection.content;
          break;
        case 'measurements':
          if (inspection.content && Array.isArray(inspection.content.items)) {
            // Transform items to ensure dimensions are properly extracted
            measurements.value.items = inspection.content.items.map(item => {
              // Determine measurement type
              const measurementType = item.measurementType ||
                (item.quantity ? 'quantity' :
                 (item.dimensions?.width || item.width ? 'area' : 'linear'));

              // Create base item with common properties
              const transformedItem = {
                description: item.description || '',
                measurementType: measurementType,
                units: item.dimensions?.units || item.units || 'feet',
              };

              // Add type-specific properties
              if (measurementType === 'area' || measurementType === 'linear') {
                transformedItem.length = item.dimensions?.length || item.length || '';
                if (measurementType === 'area') {
                  transformedItem.width = item.dimensions?.width || item.width || '';
                }
              } else if (measurementType === 'quantity') {
                transformedItem.quantity = item.quantity || '1';
                transformedItem.quantityUnit = item.quantityUnit || 'each';
              }

              return transformedItem;
            });
          } else if (inspection.content) {
            // Handle legacy format
            measurements.value.items = [{
              description: inspection.content.description || '',
              measurementType: 'area', // Default to area for legacy format
              length: inspection.content.dimensions?.length || '',
              width: inspection.content.dimensions?.width || '',
              units: inspection.content.dimensions?.units || 'feet'
            }];
          }
          break;
        case 'materials':
          materials.value = inspection.content;
          break;
      }
    });
  }
}, { immediate: true });

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

// Watch for changes in project photos and update local references
watch(() => props.project?.photos, (newPhotos) => {
  if (newPhotos) {
    localConditionPhotos.value = newPhotos.filter(p => p.photo_type === 'condition');
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
