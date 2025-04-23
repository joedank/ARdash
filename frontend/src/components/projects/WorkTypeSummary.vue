<template>
  <div class="work-type-summary bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4 mb-4">
    <h3 class="font-medium mb-2">Work Types</h3>
    
    <div v-if="loading" class="flex justify-center py-4">
      <div class="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-blue-500"></div>
    </div>
    
    <div v-else-if="error" class="text-red-500 py-2">
      {{ error }}
    </div>
    
    <div v-else-if="workTypes.length === 0" class="text-gray-500 dark:text-gray-400 text-sm py-2">
      No work types associated with this assessment. Add work types in the assessment section.
    </div>
    
    <div v-else class="space-y-3">
      <div 
        v-for="workType in workTypes" 
        :key="workType.id"
        class="p-3 border border-gray-200 dark:border-gray-700 rounded-lg"
      >
        <div class="flex justify-between items-start mb-2">
          <div>
            <h4 class="font-medium">{{ workType.name }}</h4>
            <p class="text-xs text-gray-500 dark:text-gray-400 capitalize">{{ formatWorkTypeCategory(workType.measurement_type) }}</p>
          </div>
          <div class="text-right">
            <div class="text-xs text-gray-500 dark:text-gray-400">Suggested Units</div>
            <div class="font-medium">{{ workType.suggested_units }}</div>
          </div>
        </div>
        
        <div v-if="workType.unit_cost_material || workType.unit_cost_labor" class="mt-3 border-t border-gray-200 dark:border-gray-700 pt-3">
          <h5 class="text-sm font-medium mb-1">Reference Costs</h5>
          <div class="grid grid-cols-2 gap-2">
            <div v-if="workType.unit_cost_material">
              <div class="text-xs text-gray-500 dark:text-gray-400">Materials</div>
              <div>${{ formatCost(workType.unit_cost_material) }}/{{ workType.suggested_units }}</div>
            </div>
            <div v-if="workType.unit_cost_labor">
              <div class="text-xs text-gray-500 dark:text-gray-400">Labor</div>
              <div>${{ formatCost(workType.unit_cost_labor) }}/{{ workType.suggested_units }}</div>
            </div>
            <div v-if="workType.unit_cost_material && workType.unit_cost_labor" class="col-span-2 mt-1 pt-1 border-t border-gray-200 dark:border-gray-700">
              <div class="text-xs text-gray-500 dark:text-gray-400">Total</div>
              <div class="font-medium">${{ formatCost(getTotalCost(workType)) }}/{{ workType.suggested_units }}</div>
            </div>
          </div>
        </div>
        
        <div v-if="workType.tags && workType.tags.length > 0" class="mt-3 border-t border-gray-200 dark:border-gray-700 pt-3">
          <h5 class="text-sm font-medium mb-1">Tags</h5>
          <div class="flex flex-wrap gap-1">
            <span 
              v-for="tag in workType.tags" 
              :key="tag.tag || tag"
              class="text-xs px-2 py-1 rounded-full bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200"
            >
              {{ tag.tag || tag }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import workTypesService from '@/services/work-types.service';

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  }
});

const workTypes = ref([]);
const loading = ref(false);
const error = ref(null);

// Load work types when ids change
watch(() => props.ids, async (newIds) => {
  if (newIds && newIds.length > 0) {
    await loadWorkTypes();
  } else {
    workTypes.value = [];
  }
}, { immediate: true });

// Format work type category for display
const formatWorkTypeCategory = (category) => {
  if (!category) return 'Unknown';
  
  switch (category.toLowerCase()) {
    case 'area':
      return 'Area-based';
    case 'linear':
      return 'Linear measurement';
    case 'quantity':
      return 'Quantity-based';
    default:
      return category;
  }
};

// Format cost for display
const formatCost = (cost) => {
  if (cost === null || cost === undefined) return '0.00';
  return parseFloat(cost).toFixed(2);
};

// Get total cost (material + labor)
const getTotalCost = (workType) => {
  const materialCost = workType.unit_cost_material ? parseFloat(workType.unit_cost_material) : 0;
  const laborCost = workType.unit_cost_labor ? parseFloat(workType.unit_cost_labor) : 0;
  return materialCost + laborCost;
};

// Load work types from backend
const loadWorkTypes = async () => {
  if (!props.ids || props.ids.length === 0) {
    workTypes.value = [];
    return;
  }
  
  loading.value = true;
  error.value = null;
  
  try {
    // Load work types by ID
    const results = [];
    for (const id of props.ids) {
      try {
        const workType = await workTypesService.getWorkTypeById(id, true, true);
        if (workType) {
          results.push(workType);
        }
      } catch (err) {
        console.error(`Error loading work type ${id}:`, err);
        // Continue to next ID even if one fails
      }
    }
    
    workTypes.value = results;
  } catch (err) {
    console.error('Error loading work types:', err);
    error.value = 'Failed to load work types. Please try again.';
  } finally {
    loading.value = false;
  }
};

// Initial load
onMounted(() => {
  if (props.ids && props.ids.length > 0) {
    loadWorkTypes();
  }
});
</script>
