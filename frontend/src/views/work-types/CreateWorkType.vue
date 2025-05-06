<template>
  <div class="container mx-auto px-4 py-8">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold">Create Work Type</h1>
      <BaseButton variant="secondary" @click="$router.push('/work-types')">
        Cancel
      </BaseButton>
    </div>

    <div v-if="error" class="mb-4 p-4 bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200 rounded-lg">
      {{ error }}
    </div>

    <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
      <form @submit.prevent="saveWorkType">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <BaseFormGroup
            label="Name"
            input-id="work-type-name"
            helper-text="Enter a descriptive name for this work type"
          >
            <input
              id="work-type-name"
              v-model="form.name"
              type="text"
              class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-gray-200 dark:ring-gray-600"
              placeholder="e.g., Roof Shingle Replacement"
              required
            />
          </BaseFormGroup>

          <BaseFormGroup
            label="Parent Bucket"
            input-id="work-type-parent-bucket"
            helper-text="Select the category this work type belongs to"
          >
            <BaseSelect
              id="work-type-parent-bucket"
              v-model="form.parentBucket"
              :options="parentBucketOptions"
              placeholder="Select parent bucket"
              required
            />
          </BaseFormGroup>

          <BaseFormGroup
            label="Measurement Type"
            input-id="work-type-measurement-type"
            helper-text="How is this work type measured?"
          >
            <BaseSelect
              id="work-type-measurement-type"
              v-model="form.measurementType"
              :options="measurementTypeOptions"
              placeholder="Select measurement type"
              required
              @update:model-value="updateSuggestedUnits"
            />
          </BaseFormGroup>

          <BaseFormGroup
            label="Suggested Units"
            input-id="work-type-suggested-units"
            helper-text="Units used for measurement"
          >
            <BaseSelect
              id="work-type-suggested-units"
              v-model="form.suggestedUnits"
              :options="suggestedUnitsOptions"
              placeholder="Select suggested units"
              required
            />
          </BaseFormGroup>
        </div>

        <div class="mt-6 border-t border-gray-200 dark:border-gray-700 pt-6">
          <h3 class="text-lg font-medium mb-3">Cost Information (Optional)</h3>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <BaseFormGroup
              label="Material Cost (per unit)"
              input-id="work-type-material-cost"
              helper-text="Cost of materials per unit"
            >
              <div class="flex relative">
                <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                  <span class="text-gray-500 sm:text-sm">$</span>
                </div>
                <input
                  id="work-type-material-cost"
                  v-model.number="form.unitCostMaterial"
                  type="number"
                  step="0.01"
                  min="0"
                  class="pl-7 block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-gray-200 dark:ring-gray-600"
                  placeholder="0.00"
                />
              </div>
            </BaseFormGroup>

            <BaseFormGroup
              label="Labor Cost (per unit)"
              input-id="work-type-labor-cost"
              helper-text="Cost of labor per unit"
            >
              <div class="flex relative">
                <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                  <span class="text-gray-500 sm:text-sm">$</span>
                </div>
                <input
                  id="work-type-labor-cost"
                  v-model.number="form.unitCostLabor"
                  type="number"
                  step="0.01"
                  min="0"
                  class="pl-7 block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-gray-200 dark:ring-gray-600"
                  placeholder="0.00"
                />
              </div>
            </BaseFormGroup>

            <BaseFormGroup
              label="Productivity (units/hour)"
              input-id="work-type-productivity"
              helper-text="Units that can be completed per hour"
            >
              <input
                id="work-type-productivity"
                v-model.number="form.productivityUnitPerHr"
                type="number"
                step="0.1"
                min="0"
                class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-gray-200 dark:ring-gray-600"
                placeholder="0.0"
              />
            </BaseFormGroup>
          </div>
        </div>

        <div class="mt-6 flex justify-end">
          <BaseButton
            type="submit"
            variant="primary"
            :disabled="loading"
          >
            {{ loading ? 'Creating...' : 'Create Work Type' }}
          </BaseButton>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useToast } from '@/composables/useToast';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseFormGroup from '@/components/form/BaseFormGroup.vue';
import BaseSelect from '@/components/form/BaseSelect.vue';
import workTypesService from '@/services/work-types.service';

const router = useRouter();
const route = useRoute();
const toast = useToast();

// Form state
const form = ref({
  name: '',
  parentBucket: '',
  measurementType: '',
  suggestedUnits: '',
  unitCostMaterial: null,
  unitCostLabor: null,
  productivityUnitPerHr: null
});

const loading = ref(false);
const error = ref(null);

// Check for name parameter in URL and populate the form
onMounted(() => {
  if (route.query.name) {
    console.log('Found name in URL:', route.query.name);
    form.value.name = route.query.name;
  }
});

// Options for select fields
const parentBucketOptions = [
  { value: 'Interior-Structural', label: 'Interior Structural' },
  { value: 'Interior-Finish', label: 'Interior Finish' },
  { value: 'Exterior-Structural', label: 'Exterior Structural' },
  { value: 'Exterior-Finish', label: 'Exterior Finish' },
  { value: 'Mechanical', label: 'Mechanical' }
];

const measurementTypeOptions = [
  { value: 'area', label: 'Area' },
  { value: 'linear', label: 'Linear' },
  { value: 'quantity', label: 'Quantity' }
];

// Suggested units options based on measurement type
const suggestedUnitsOptions = computed(() => {
  switch (form.value.measurementType) {
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
});

// Update suggested units when measurement type changes
function updateSuggestedUnits() {
  // Reset suggested units
  form.value.suggestedUnits = '';
}

// Save the work type
async function saveWorkType() {
  if (loading.value) return;

  loading.value = true;
  error.value = null;

  try {
    // Prepare form data
    const workTypeData = {
      name: form.value.name,
      parentBucket: form.value.parentBucket,
      measurementType: form.value.measurementType,
      suggestedUnits: form.value.suggestedUnits
    };

    // Add cost data if provided
    if (form.value.unitCostMaterial !== null) {
      workTypeData.unitCostMaterial = form.value.unitCostMaterial;
    }
    
    if (form.value.unitCostLabor !== null) {
      workTypeData.unitCostLabor = form.value.unitCostLabor;
    }
    
    if (form.value.productivityUnitPerHr !== null) {
      workTypeData.productivityUnitPerHr = form.value.productivityUnitPerHr;
    }

    const response = await workTypesService.createWorkType(workTypeData);

    if (response.success) {
      toast.success('Work type created successfully', {
        timeout: 3000
      });

      router.push(`/work-types/${response.data.id}`);
    } else {
      error.value = response.message || 'Failed to create work type';
    }
  } catch (err) {
    error.value = err.message || 'An error occurred while creating the work type';
  } finally {
    loading.value = false;
  }
}
</script>