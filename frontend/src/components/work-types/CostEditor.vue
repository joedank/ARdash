<template>
  <BaseModal
    :model-value="show"
    @update:model-value="$emit('close')"
    size="md"
    :title="'Edit Costs for ' + (workType ? workType.name : 'Work Type')"
  >
    <div class="p-4">
      <div v-if="error" class="mb-4 p-3 bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200 rounded-lg">
        {{ error }}
      </div>

      <div class="grid grid-cols-1 gap-4 mb-6">
        <BaseFormGroup
          label="Material Cost (per unit)"
          input-id="unit-cost-material"
          helper-text="The cost of materials to complete one unit of work"
        >
          <div class="flex relative">
            <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
              <span class="text-gray-500 sm:text-sm">$</span>
            </div>
            <input
              id="unit-cost-material"
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
          input-id="unit-cost-labor"
          helper-text="The cost of labor to complete one unit of work"
        >
          <div class="flex relative">
            <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
              <span class="text-gray-500 sm:text-sm">$</span>
            </div>
            <input
              id="unit-cost-labor"
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
          label="Productivity (units per hour)"
          input-id="productivity-unit-per-hr"
          helper-text="How many units can be completed per labor hour"
        >
          <input
            id="productivity-unit-per-hr"
            v-model.number="form.productivityUnitPerHr"
            type="number"
            step="0.1"
            min="0"
            class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-gray-200 dark:ring-gray-600"
            placeholder="0.0"
          />
        </BaseFormGroup>

        <div v-if="workType && workType.updatedBy && workType.revision > 1" class="text-sm text-gray-600 dark:text-gray-400 mt-2">
          <div class="flex items-center">
            <span class="inline-block bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 text-xs font-medium py-0.5 px-2 rounded-full mr-2">
              Revision {{ workType.revision }}
            </span>
            <span>Last updated {{ formatDate(workType.updatedAt) }}</span>
          </div>
        </div>
      </div>

      <div class="mt-4 bg-gray-50 dark:bg-gray-800 p-4 rounded-lg">
        <h3 class="font-medium text-gray-900 dark:text-gray-200 mb-2">Cost Analysis</h3>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <div class="text-sm text-gray-600 dark:text-gray-400">Per Unit Total</div>
            <div class="text-lg font-medium text-gray-900 dark:text-gray-200">
              {{ formatCurrency(getTotalCostPerUnit()) }}
            </div>
          </div>

          <div>
            <div class="text-sm text-gray-600 dark:text-gray-400">Labor Per Unit</div>
            <div class="text-lg font-medium text-gray-900 dark:text-gray-200">
              {{ formatCurrency(form.unitCostLabor || 0) }}
              ({{ Math.round(getLaborPercentage()) }}%)
            </div>
          </div>

          <div>
            <div class="text-sm text-gray-600 dark:text-gray-400">Estimate Per Hour</div>
            <div class="text-lg font-medium text-gray-900 dark:text-gray-200">
              {{ formatCurrency(getTotalCostPerHour()) }}
            </div>
          </div>

          <div>
            <div class="text-sm text-gray-600 dark:text-gray-400">Unit Type</div>
            <div class="text-lg font-medium text-gray-900 dark:text-gray-200">
              {{ workType ? workType.suggestedUnits : '' }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <template #footer>
      <div class="flex items-center justify-end gap-3 px-4 py-3 bg-gray-50 dark:bg-gray-800">
        <BaseButton
          variant="secondary"
          @click="$emit('close')"
        >
          Cancel
        </BaseButton>
        <BaseButton
          variant="primary"
          @click="saveCosts"
          :disabled="loading"
        >
          {{ loading ? 'Saving...' : 'Save' }}
        </BaseButton>
      </div>
    </template>
  </BaseModal>
</template>

<script setup>
import { ref, computed, watch } from 'vue';
import BaseModal from '@/components/base/BaseModal.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseFormGroup from '@/components/form/BaseFormGroup.vue';
import workTypesService from '@/services/work-types.service';
import { useToast } from '@/composables/useToast';

// Props
const props = defineProps({
  show: {
    type: Boolean,
    required: true
  },
  workType: {
    type: Object,
    required: true
  }
});

// Emits
const emit = defineEmits(['close', 'updated']);

// Form state
const form = ref({
  unitCostMaterial: 0,
  unitCostLabor: 0,
  productivityUnitPerHr: 0
});

// Other state
const loading = ref(false);
const error = ref(null);

// Initialize form with work type data when it changes
watch(() => props.workType, (newWorkType) => {
  if (newWorkType) {
    form.value = {
      unitCostMaterial: newWorkType.unitCostMaterial || 0,
      unitCostLabor: newWorkType.unitCostLabor || 0,
      productivityUnitPerHr: newWorkType.productivityUnitPerHr || 0
    };
  }
}, { immediate: true });

// Computed properties
const getTotalCostPerUnit = () => {
  return (form.value.unitCostMaterial || 0) + (form.value.unitCostLabor || 0);
};

const getLaborPercentage = () => {
  const total = getTotalCostPerUnit();
  if (total === 0) return 0;
  return ((form.value.unitCostLabor || 0) / total) * 100;
};

const getTotalCostPerHour = () => {
  if (!form.value.productivityUnitPerHr || form.value.productivityUnitPerHr === 0) {
    return 0;
  }
  return getTotalCostPerUnit() * form.value.productivityUnitPerHr;
};

// Methods
const formatCurrency = (value) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2
  }).format(value);
};

const formatDate = (dateString) => {
  if (!dateString) return '';

  const date = new Date(dateString);
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date);
};

// Get toast composable
const { showToast } = useToast();

const saveCosts = async () => {
  if (loading.value) return;

  loading.value = true;
  error.value = null;

  try {
    // Convert form data to API format
    const costData = {
      unit_cost_material: form.value.unitCostMaterial,
      unit_cost_labor: form.value.unitCostLabor,
      productivity_unit_per_hr: form.value.productivityUnitPerHr
    };

    const response = await workTypesService.updateCosts(props.workType.id, costData);

    if (response.success) {
      // Show success toast
      showToast({
        message: `Costs updated for ${props.workType.name}`,
        type: 'success',
        duration: 3000
      });

      emit('updated', response.data.workType);
      emit('close');
    } else {
      error.value = response.message || 'Failed to save costs';
    }
  } catch (err) {
    error.value = err.message || 'An error occurred while saving costs';
  } finally {
    loading.value = false;
  }
};
</script>