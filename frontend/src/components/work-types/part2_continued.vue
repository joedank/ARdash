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