<template>
  <div class="px-4 py-5 sm:p-6">
    <div v-if="error" class="mb-4 p-3 bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200 rounded-lg">
      {{ error }}
    </div>

    <!-- Materials Table -->
    <div class="mb-6">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100">Default Materials</h3>
        <BaseButton
          v-if="canManageWorkTypes"
          variant="primary"
          size="sm"
          @click="openAddMaterialModal"
        >
          Add Material
        </BaseButton>
      </div>

      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-800">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Material
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Quantity Per Unit
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Unit
              </th>
              <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-if="loading">
              <td colspan="4" class="px-6 py-4 whitespace-nowrap text-center text-sm">
                <div class="flex justify-center items-center space-x-2">
                  <svg class="animate-spin h-5 w-5 text-indigo-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  <span>Loading materials...</span>
                </div>
              </td>
            </tr>
            <tr v-else-if="materials.length === 0">
              <td colspan="4" class="px-6 py-4 whitespace-nowrap text-center text-sm text-gray-500 dark:text-gray-400">
                No materials defined. Click "Add Material" to add some.
              </td>
            </tr>
            <tr v-for="material in materials" :key="material.id" class="hover:bg-gray-50 dark:hover:bg-gray-800">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-gray-100">
                {{ material.product?.name || 'Unknown Product' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ material.qtyPerUnit }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ material.unit }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <button
                  v-if="canManageWorkTypes"
                  @click="editMaterial(material)"
                  class="text-indigo-600 dark:text-indigo-400 hover:text-indigo-900 dark:hover:text-indigo-300 mr-3"
                >
                  Edit
                </button>
                <button
                  v-if="canManageWorkTypes"
                  @click="confirmRemoveMaterial(material)"
                  class="text-red-600 dark:text-red-400 hover:text-red-900 dark:hover:text-red-300"
                >
                  Remove
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Safety Tags Section -->
    <div>
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100">Safety & Permit Tags</h3>
        <BaseButton
          v-if="canManageWorkTypes"
          variant="secondary"
          size="sm"
          @click="openAddTagModal"
        >
          Add Tag
        </BaseButton>
      </div>

      <div class="flex flex-wrap gap-2 mb-4">
        <div v-if="loadingTags" class="flex items-center space-x-2 text-sm text-gray-500 dark:text-gray-400">
          <svg class="animate-spin h-4 w-4 text-indigo-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <span>Loading tags...</span>
        </div>
        <div v-else-if="tags.length === 0" class="text-sm text-gray-500 dark:text-gray-400">
          No safety or permit tags defined. Click "Add Tag" to add some.
        </div>
        <div
          v-for="tag in tags"
          :key="tag.tag"
          class="inline-flex items-center bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 text-sm font-medium px-3 py-1.5 rounded-full"
        >
          {{ tag.tag }}
          <button
            v-if="canManageWorkTypes"
            type="button"
            @click="removeTag(tag.tag)"
            class="ml-1.5 text-blue-600 dark:text-blue-400 hover:text-blue-900 dark:hover:text-blue-300 focus:outline-none"
          >
            <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
            </svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Add/Edit Material Modal -->
    <BaseModal
      :model-value="showMaterialModal"
      @update:model-value="showMaterialModal = false"
      size="md"
      :title="editingMaterial ? 'Edit Material' : 'Add Material'"
    >
      <div class="p-4">
        <div v-if="materialError" class="mb-4 p-3 bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200 rounded-lg">
          {{ materialError }}
        </div>

        <div class="grid grid-cols-1 gap-4">
          <BaseFormGroup
            label="Material"
            input-id="material-product"
            helper-text="Select a material from the catalog"
          >
            <BaseSelect
              id="material-product"
              v-model="materialForm.productId"
              :options="productOptions"
              placeholder="Select a material"
              :required="true"
            />
          </BaseFormGroup>

          <BaseFormGroup
            label="Quantity Per Unit"
            input-id="material-qty"
            helper-text="How much material is needed per unit of work"
          >
            <input
              id="material-qty"
              v-model.number="materialForm.qtyPerUnit"
              type="number"
              step="0.01"
              min="0.01"
              class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-gray-200 dark:ring-gray-600"
              placeholder="0.00"
              required
            />
          </BaseFormGroup>

          <BaseFormGroup
            label="Unit"
            input-id="material-unit"
            helper-text="Unit of measurement for this material"
          >
            <BaseSelect
              id="material-unit"
              v-model="materialForm.unit"
              :options="unitOptions"
              placeholder="Select a unit"
              :required="true"
            />
          </BaseFormGroup>
        </div>
      </div>

      <template #footer>
        <div class="flex items-center justify-end gap-3 px-4 py-3 bg-gray-50 dark:bg-gray-800">
          <BaseButton
            variant="secondary"
            @click="showMaterialModal = false"
          >
            Cancel
          </BaseButton>
          <BaseButton
            variant="primary"
            @click="saveMaterial"
            :disabled="materialSaving"
          >
            {{ materialSaving ? 'Saving...' : (editingMaterial ? 'Update' : 'Add') }}
          </BaseButton>
        </div>
      </template>
    </BaseModal>

    <!-- Add Tag Modal -->
    <BaseModal
      :model-value="showTagModal"
      @update:model-value="showTagModal = false"
      size="sm"
      title="Add Safety/Permit Tag"
    >
      <div class="p-4">
        <div v-if="tagError" class="mb-4 p-3 bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200 rounded-lg">
          {{ tagError }}
        </div>

        <BaseFormGroup
          label="Tag Name"
          input-id="tag-name"
          helper-text="Safety requirements or permit needs"
        >
          <input
            id="tag-name"
            v-model="tagForm.tag"
            type="text"
            class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-gray-200 dark:ring-gray-600"
            placeholder="e.g., asbestos, electrical, plumbing"
            required
          />
        </BaseFormGroup>

        <div class="mt-4">
          <h4 class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Common Tags</h4>
          <div class="flex flex-wrap gap-2">
            <button
              v-for="tag in commonTags"
              :key="tag"
              @click="tagForm.tag = tag"
              class="inline-flex items-center bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-gray-200 text-xs px-2 py-1 rounded"
            >
              {{ tag }}
            </button>
          </div>
        </div>
      </div>

      <template #footer>
        <div class="flex items-center justify-end gap-3 px-4 py-3 bg-gray-50 dark:bg-gray-800">
          <BaseButton
            variant="secondary"
            @click="showTagModal = false"
          >
            Cancel
          </BaseButton>
          <BaseButton
            variant="primary"
            @click="saveTag"
            :disabled="tagSaving"
          >
            {{ tagSaving ? 'Saving...' : 'Add Tag' }}
          </BaseButton>
        </div>
      </template>
    </BaseModal>

    <!-- Confirm Remove Modal -->
    <BaseModal
      :model-value="showConfirmModal"
      @update:model-value="showConfirmModal = false"
      size="sm"
      title="Confirm Removal"
    >
      <div class="p-4">
        <p class="text-sm text-gray-700 dark:text-gray-300">
          Are you sure you want to remove this {{ confirmType === 'material' ? 'material' : 'tag' }}?
        </p>
      </div>

      <template #footer>
        <div class="flex items-center justify-end gap-3 px-4 py-3 bg-gray-50 dark:bg-gray-800">
          <BaseButton
            variant="secondary"
            @click="showConfirmModal = false"
          >
            Cancel
          </BaseButton>
          <BaseButton
            variant="danger"
            @click="confirmRemove"
            :disabled="removeSaving"
          >
            {{ removeSaving ? 'Removing...' : 'Remove' }}
          </BaseButton>
        </div>
      </template>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useAuthStore } from '@/store/auth';
import BaseButton from '@/components/shared/BaseButton.vue';
import BaseModal from '@/components/shared/BaseModal.vue';
import BaseFormGroup from '@/components/shared/BaseFormGroup.vue';
import BaseSelect from '@/components/shared/BaseSelect.vue';
import workTypesService from '@/services/work-types.service';
import materialsService from '@/services/materials.service';
import productsService from '@/services/products.service';
import { useToast } from '@/composables/useToast';

// Props
const props = defineProps({
  workTypeId: {
    type: String,
    required: true
  },
  workTypeName: {
    type: String,
    default: 'Work Type'
  }
});

// Get toast composable
const { showToast } = useToast();

// Get auth store
const authStore = useAuthStore();

// Check if user can manage work types (admin or estimator_manager)
const canManageWorkTypes = computed(() => authStore.canManageWorkTypes);

// Emits
const emit = defineEmits(['updated']);

// Data for materials table
const materials = ref([]);
const loading = ref(true);
const error = ref(null);

// Data for tags section
const tags = ref([]);
const loadingTags = ref(true);

// Modal states
const showMaterialModal = ref(false);
const showTagModal = ref(false);
const showConfirmModal = ref(false);

// Form states
const materialForm = ref({
  productId: '',
  qtyPerUnit: 1,
  unit: 'each'
});
const materialError = ref(null);
const materialSaving = ref(false);
const editingMaterial = ref(null);

const tagForm = ref({
  tag: ''
});
const tagError = ref(null);
const tagSaving = ref(false);

// Confirm remove
const confirmType = ref(''); // 'material' or 'tag'
const itemToRemove = ref(null);
const removeSaving = ref(false);

// Products for dropdown
const products = ref([]);
const productOptions = computed(() => {
  return products.value.map(product => ({
    value: product.id,
    label: product.name
  }));
});

// Unit options
const unitOptions = ref([
  { value: 'each', label: 'Each' },
  { value: 'sheet', label: 'Sheet' },
  { value: 'roll', label: 'Roll' },
  { value: 'box', label: 'Box' },
  { value: 'gallon', label: 'Gallon' },
  { value: 'quart', label: 'Quart' },
  { value: 'lb', label: 'Pound' },
  { value: 'set', label: 'Set' },
  { value: 'tube', label: 'Tube' },
  { value: 'piece', label: 'Piece' },
  { value: 'bag', label: 'Bag' },
  { value: 'pair', label: 'Pair' },
  { value: 'bundle', label: 'Bundle' }
]);

// Common tags
const commonTags = ref([
  'asbestos',
  'electrical',
  'plumbing',
  'structural',
  'lead',
  'fire-rated',
  'hazardous',
  'permit-required',
  'code-compliance',
  'safety-equipment'
]);

// Load data
onMounted(async () => {
  if (props.workTypeId) {
    await Promise.all([
      loadWorkType(),
      loadProducts()
    ]);
  }
});

watch(() => props.workTypeId, async (newId) => {
  if (newId) {
    await loadWorkType();
  }
});

async function loadWorkType() {
  loading.value = true;
  loadingTags.value = true;
  error.value = null;

  try {
    const response = await workTypesService.getById(props.workTypeId, {
      include_materials: true,
      include_tags: true
    });

    if (response.success && response.data) {
      materials.value = response.data.materials || [];
      tags.value = response.data.tags || [];
    } else {
      error.value = response.message || 'Failed to load work type details';
    }
  } catch (err) {
    error.value = err.message || 'An error occurred while loading work type details';
  } finally {
    loading.value = false;
    loadingTags.value = false;
  }
}

async function loadProducts() {
  try {
    const response = await productsService.getAll({ type: 'material' });

    if (response.success && response.data) {
      products.value = response.data;
    }
  } catch (err) {
    console.error('Failed to load products:', err);
  }
}

// Material Methods
function openAddMaterialModal() {
  materialForm.value = {
    productId: '',
    qtyPerUnit: 1,
    unit: 'each'
  };
  editingMaterial.value = null;
  materialError.value = null;
  showMaterialModal.value = true;
}

function editMaterial(material) {
  materialForm.value = {
    productId: material.productId,
    qtyPerUnit: material.qtyPerUnit,
    unit: material.unit
  };
  editingMaterial.value = material;
  materialError.value = null;
  showMaterialModal.value = true;
}

async function saveMaterial() {
  if (materialSaving.value) return;

  materialError.value = null;

  // Validate form
  if (!materialForm.value.productId) {
    materialError.value = 'Please select a material from the catalog';
    return;
  }

  if (!materialForm.value.qtyPerUnit || materialForm.value.qtyPerUnit <= 0) {
    materialError.value = 'Quantity per unit must be greater than 0';
    return;
  }

  if (!materialForm.value.unit) {
    materialError.value = 'Please select a unit';
    return;
  }

  materialSaving.value = true;

  try {
    // Prepare the data for API
    const materialData = {
      product_id: materialForm.value.productId,
      qty_per_unit: materialForm.value.qtyPerUnit,
      unit: materialForm.value.unit
    };

    // Call the appropriate API endpoint
    let response;

    if (editingMaterial.value) {
      // Update existing material - not implemented in this version, would need a PATCH endpoint
      // For now, we'll remove the old one and add the new one
      await workTypesService.removeMaterial(props.workTypeId, editingMaterial.value.id);
      response = await workTypesService.addMaterials(props.workTypeId, [materialData]);
    } else {
      // Add new material
      response = await workTypesService.addMaterials(props.workTypeId, [materialData]);
    }

    if (response.success) {
      // Show success toast
      showToast({
        message: `${editingMaterial.value ? 'Updated' : 'Added'} material for ${props.workTypeName}`,
        type: 'success',
        duration: 3000
      });

      await loadWorkType(); // Reload work type details
      showMaterialModal.value = false;
      emit('updated');
    } else {
      materialError.value = response.message || 'Failed to save material';
    }
  } catch (err) {
    materialError.value = err.message || 'An error occurred while saving material';
  } finally {
    materialSaving.value = false;
  }
}

function confirmRemoveMaterial(material) {
  confirmType.value = 'material';
  itemToRemove.value = material;
  showConfirmModal.value = true;
}

// Tag Methods
function openAddTagModal() {
  tagForm.value = { tag: '' };
  tagError.value = null;
  showTagModal.value = true;
}

function removeTag(tag) {
  confirmType.value = 'tag';
  itemToRemove.value = tag;
  showConfirmModal.value = true;
}

async function saveTag() {
  if (tagSaving.value) return;

  tagError.value = null;

  // Validate form
  if (!tagForm.value.tag) {
    tagError.value = 'Please enter a tag name';
    return;
  }

  tagSaving.value = true;

  try {
    const response = await workTypesService.addTags(props.workTypeId, [tagForm.value.tag]);

    if (response.success) {
      // Show success toast
      showToast({
        message: `Added tag "${tagForm.value.tag}" to ${props.workTypeName}`,
        type: 'success',
        duration: 3000
      });

      await loadWorkType(); // Reload work type details
      showTagModal.value = false;
      emit('updated');
    } else {
      tagError.value = response.message || 'Failed to add tag';
    }
  } catch (err) {
    tagError.value = err.message || 'An error occurred while adding tag';
  } finally {
    tagSaving.value = false;
  }
}

// Confirm Remove
async function confirmRemove() {
  if (removeSaving.value) return;

  removeSaving.value = true;

  try {
    let response;

    if (confirmType.value === 'material') {
      response = await workTypesService.removeMaterial(props.workTypeId, itemToRemove.value.id);
    } else if (confirmType.value === 'tag') {
      response = await workTypesService.removeTag(props.workTypeId, itemToRemove.value);
    }

    if (response.success) {
      // Show success toast
      const itemName = confirmType.value === 'material'
        ? itemToRemove.value.product?.name || 'Material'
        : `tag "${itemToRemove.value}"`;

      showToast({
        message: `Removed ${itemName} from ${props.workTypeName}`,
        type: 'success',
        duration: 3000
      });

      await loadWorkType(); // Reload work type details
      showConfirmModal.value = false;
      emit('updated');
    } else {
      error.value = response.message || `Failed to remove ${confirmType.value}`;
    }
  } catch (err) {
    error.value = err.message || `An error occurred while removing ${confirmType.value}`;
  } finally {
    removeSaving.value = false;
  }
}
</script>
