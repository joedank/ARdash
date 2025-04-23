          <div class="bg-gray-50 dark:bg-gray-800 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
            <button
              @click="deleteWorkType"
              class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-red-600 text-base font-medium text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:ml-3 sm:w-auto sm:text-sm"
              :disabled="loading"
            >
              Delete
            </button>
            <button
              @click="showDeleteModal = false"
              type="button"
              class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-700 shadow-sm px-4 py-2 bg-white dark:bg-gray-900 text-base font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue';
import workTypesService from '@/services/work-types.service';

export default {
  name: 'WorkTypesList',
  
  setup() {
    // State
    const workTypes = ref([]);
    const loading = ref(false);
    const error = ref(null);
    const showFilters = ref(false);
    const showModal = ref(false);
    const showDeleteModal = ref(false);
    const isEditing = ref(false);
    const workTypeToDelete = ref(null);
    const searchQuery = ref('');
    const searchTimeout = ref(null);
    
    // Form data
    const formData = reactive({
      id: '',
      name: '',
      parentBucket: '',
      measurementType: '',
      suggestedUnits: ''
    });
    
    // Validation errors
    const validationErrors = reactive({
      name: '',
      parentBucket: '',
      measurementType: '',
      suggestedUnits: ''
    });
    
    // Filters
    const filters = reactive({
      parentBucket: '',
      measurementType: ''
    });
    
    // Parent buckets
    const parentBuckets = [
      'Interior-Structural',
      'Interior-Finish',
      'Exterior-Structural',
      'Exterior-Finish',
      'Mechanical'
    ];
    
    // Load work types
    const loadWorkTypes = async () => {
      loading.value = true;
      error.value = null;
      
      try {
        const response = await workTypesService.getAllWorkTypes(filters);
        
        if (response.success) {
          // Apply search filter if searchQuery is not empty
          if (searchQuery.value) {
            const query = searchQuery.value.toLowerCase();
            workTypes.value = response.data.filter(
              workType => workType.name.toLowerCase().includes(query)
            );
          } else {
            workTypes.value = response.data;
          }
        } else {
          error.value = response.message || 'Failed to load work types';
          workTypes.value = [];
        }
      } catch (err) {
        console.error('Error loading work types:', err);
        error.value = 'Failed to load work types';
        workTypes.value = [];
      } finally {
        loading.value = false;
      }
    };
    
    // Search with debounce
    const debounceSearch = () => {
      if (searchTimeout.value) {
        clearTimeout(searchTimeout.value);
      }
      
      searchTimeout.value = setTimeout(() => {
        loadWorkTypes();
      }, 300);
    };
    
    // Open create modal
    const openCreateModal = () => {
      isEditing.value = false;
      
      // Reset form data
      Object.assign(formData, {
        id: '',
        name: '',
        parentBucket: '',
        measurementType: '',
        suggestedUnits: ''
      });
      
      // Reset validation errors
      Object.keys(validationErrors).forEach(key => {
        validationErrors[key] = '';
      });
      
      showModal.value = true;
    };
    
    // Open edit modal
    const openEditModal = (workType) => {
      isEditing.value = true;
      
      // Reset form data first
      Object.assign(formData, {
        id: '',
        name: '',
        parentBucket: '',
        measurementType: '',
        suggestedUnits: ''
      });
      
      // Then populate with work type data
      Object.assign(formData, {
        id: workType.id,
        name: workType.name,
        parentBucket: workType.parentBucket,
        measurementType: workType.measurementType,
        suggestedUnits: workType.suggestedUnits
      });
      
      // Reset validation errors
      Object.keys(validationErrors).forEach(key => {
        validationErrors[key] = '';
      });
      
      showModal.value = true;
    };
    
    // Validate form
    const validateForm = () => {
      let isValid = true;
      
      // Reset validation errors
      Object.keys(validationErrors).forEach(key => {
        validationErrors[key] = '';
      });
      
      // Validate name
      if (!formData.name.trim()) {
        validationErrors.name = 'Name is required';
        isValid = false;
      }
      
      // Validate parent bucket
      if (!formData.parentBucket) {
        validationErrors.parentBucket = 'Parent bucket is required';
        isValid = false;
      }
      
      // Validate measurement type
      if (!formData.measurementType) {
        validationErrors.measurementType = 'Measurement type is required';
        isValid = false;
      }
      
      // Validate suggested units
      if (!formData.suggestedUnits.trim()) {
        validationErrors.suggestedUnits = 'Suggested units are required';
        isValid = false;
      }
      
      return isValid;
    };
    
    // Save work type (create or update)
    const saveWorkType = async () => {
      if (!validateForm()) {
        return;
      }
      
      loading.value = true;
      error.value = null;
      
      try {
        let response;
        
        if (isEditing.value) {
          // Update
          response = await workTypesService.updateWorkType(formData.id, formData);
        } else {
          // Create
          response = await workTypesService.createWorkType(formData);
        }
        
        if (response.success) {
          // Close modal and reload work types
          showModal.value = false;
          await loadWorkTypes();
        } else {
          error.value = response.message || 'Failed to save work type';
        }
      } catch (err) {
        console.error('Error saving work type:', err);
        error.value = 'Failed to save work type';
      } finally {
        loading.value = false;
      }
    };
    
    // Confirm delete
    const confirmDelete = (workType) => {
      workTypeToDelete.value = workType;
      showDeleteModal.value = true;
    };
    
    // Delete work type
    const deleteWorkType = async () => {
      if (!workTypeToDelete.value) {
        return;
      }
      
      loading.value = true;
      error.value = null;
      
      try {
        const response = await workTypesService.deleteWorkType(workTypeToDelete.value.id);
        
        if (response.success) {
          // Close modal and reload work types
          showDeleteModal.value = false;
          workTypeToDelete.value = null;
          await loadWorkTypes();
        } else {
          error.value = response.message || 'Failed to delete work type';
        }
      } catch (err) {
        console.error('Error deleting work type:', err);
        error.value = 'Failed to delete work type';
      } finally {
        loading.value = false;
      }
    };
    
    // Format measurement type for display
    const formatMeasurementType = (type) => {
      if (type === 'area') return 'Area';
      if (type === 'linear') return 'Linear';
      if (type === 'quantity') return 'Quantity';
      return type;
    };
    
    // Get CSS classes for parent bucket badges
    const getBucketClasses = (bucket) => {
      const baseClasses = 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium';
      
      switch (bucket) {
        case 'Interior-Structural':
          return `${baseClasses} bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-300`;
        case 'Interior-Finish':
          return `${baseClasses} bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-300`;
        case 'Exterior-Structural':
          return `${baseClasses} bg-purple-100 dark:bg-purple-900 text-purple-800 dark:text-purple-300`;
        case 'Exterior-Finish':
          return `${baseClasses} bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-300`;
        case 'Mechanical':
          return `${baseClasses} bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-300`;
        default:
          return `${baseClasses} bg-gray-100 dark:bg-gray-800 text-gray-800 dark:text-gray-300`;
      }
    };
    
    // Load work types on component mount
    onMounted(() => {
      loadWorkTypes();
    });
    
    return {
      workTypes,
      loading,
      error,
      showFilters,
      filters,
      parentBuckets,
      searchQuery,
      showModal,
      showDeleteModal,
      isEditing,
      formData,
      validationErrors,
      workTypeToDelete,
      loadWorkTypes,
      debounceSearch,
      openCreateModal,
      openEditModal,
      saveWorkType,
      confirmDelete,
      deleteWorkType,
      formatMeasurementType,
      getBucketClasses
    };
  }
};
</script>