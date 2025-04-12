<template>
  <div class="photo-grid">
    <!-- Photo Grid -->
    <div
      v-if="photos.length > 0"
      class="grid grid-cols-2 sm:grid-cols-3 gap-4"
    >
      <div
        v-for="photo in photos"
        :key="photo.id"
        class="relative aspect-square rounded-lg overflow-hidden cursor-pointer"
        @click="openPreview(photo)"
      >
        <!-- Photo Thumbnail -->
        <img
          :src="getPhotoUrl(photo)"
          :alt="'Photo ' + photo.id"
          class="w-full h-full object-cover transition-opacity duration-300"
          loading="lazy"
          :class="{
            // Temporarily removed opacity toggle for debugging
            // 'opacity-0': !loadedImages.has(photo.id),
            // 'opacity-100': loadedImages.has(photo.id),
            'border-2 border-red-500': imageErrors.has(photo.id)
          }"
          @load="(event) => onImageLoad(event, photo.id)"
          @error="() => onImageError(photo.id)"
        >
        <div v-if="imageErrors.has(photo.id)" class="absolute inset-0 flex items-center justify-center bg-gray-100 dark:bg-gray-800">
          <span class="text-xs text-red-500">Failed to load image</span>
        </div>

        <!-- Photo Notes Badge -->
        <div
          v-if="photo.notes"
          class="absolute bottom-2 right-2"
        >
          <BaseIcon
            name="message-circle"
            class="w-5 h-5 text-white drop-shadow-lg"
          />
        </div>

        <!-- Photo Actions -->
        <div class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity z-20">
          <button
            class="p-1 bg-black/50 hover:bg-black/70 rounded-full text-white"
            @click.stop="openPhotoMenu(photo)"
          >
            <BaseIcon name="more-vertical" class="w-5 h-5" />
          </button>
        </div>

        <!-- Photo Menu -->
        <div
          v-if="activePhotoMenu === photo.id"
          class="absolute top-12 right-2 z-30 bg-white dark:bg-gray-800 rounded-lg shadow-lg py-1 min-w-[160px]"
          @click.stop
        >
          <button
            class="w-full px-4 py-2 text-left text-sm hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center"
            @click="openPreview(photo)"
          >
            <BaseIcon name="maximize-2" class="w-4 h-4 mr-2" />
            View Full Size
          </button>
          <button
            class="w-full px-4 py-2 text-left text-sm hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center text-red-600 dark:text-red-400"
            @click="confirmDeletePhoto(photo)"
          >
            <BaseIcon name="trash-2" class="w-4 h-4 mr-2" />
            Delete Photo
          </button>
        </div>

        <!-- Timestamp -->
        <div class="absolute bottom-0 left-0 right-0 bg-black/50 text-white text-xs px-2 py-1">
          {{ formatDate(photo.created_at) }}
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div
      v-else
      class="text-center py-4 text-sm text-gray-500 dark:text-gray-400"
    >
      No photos uploaded yet
    </div>

    <!-- Photo Preview Modal -->
    <BaseModal
      v-model="isPreviewOpen"
      class="photo-preview-modal"
      @close="closePreview"
      size="xl"
    >
      <template #header>
        <div class="flex items-center justify-between w-full">
          <h3 class="text-lg font-medium">Photo Details</h3>
          <div class="flex items-center space-x-2">
            <button
              v-if="selectedPhoto"
              class="p-2 text-red-600 hover:text-red-700 dark:text-red-400 dark:hover:text-red-300 rounded-full"
              @click="confirmDeletePhoto(selectedPhoto)"
              title="Delete Photo"
            >
              <BaseIcon name="trash-2" class="w-5 h-5" />
            </button>
          </div>
        </div>
      </template>

      <div class="max-w-4xl mx-auto">
        <!-- Photo Container with Aspect Ratio -->
        <div class="relative bg-gray-900 rounded-lg overflow-hidden">
          <img
            v-if="selectedPhoto"
            :src="getPhotoUrl(selectedPhoto)"
            :alt="'Photo ' + selectedPhoto.id"
            class="w-full h-auto max-h-[70vh] object-contain mx-auto"
          >
        </div>

        <!-- Photo Info -->
        <div class="mt-4 space-y-3 px-4">
          <!-- Timestamp -->
          <div class="flex items-center text-sm text-gray-500 dark:text-gray-400">
            <BaseIcon name="calendar" class="w-4 h-4 mr-2" />
            {{ formatDate(selectedPhoto?.created_at, true) }}
          </div>

          <!-- Notes -->
          <div
            v-if="selectedPhoto?.notes"
            class="bg-gray-50 dark:bg-gray-800/50 rounded-lg p-4"
          >
            <div class="flex items-center text-sm font-medium mb-2">
              <BaseIcon name="message-circle" class="w-4 h-4 mr-2" />
              Notes
            </div>
            <p class="text-sm whitespace-pre-wrap text-gray-600 dark:text-gray-300">
              {{ selectedPhoto.notes }}
            </p>
          </div>
        </div>

        <!-- Navigation Buttons -->
        <div class="absolute top-1/2 -translate-y-1/2 w-full px-4 flex justify-between pointer-events-none">
          <button
            v-if="previousPhoto"
            class="p-2 rounded-full bg-black/50 hover:bg-black/70 text-white transform transition-transform hover:scale-110 pointer-events-auto"
            @click="navigatePhotos('previous')"
            title="Previous photo"
          >
            <BaseIcon name="chevron-left" class="w-6 h-6" />
          </button>

          <button
            v-if="nextPhoto"
            class="p-2 rounded-full bg-black/50 hover:bg-black/70 text-white transform transition-transform hover:scale-110 pointer-events-auto"
            @click="navigatePhotos('next')"
            title="Next photo"
          >
            <BaseIcon name="chevron-right" class="w-6 h-6" />
          </button>
        </div>

        <!-- Keyboard Navigation Helper -->
        <div class="absolute bottom-4 left-1/2 -translate-x-1/2 flex items-center space-x-4 text-white/70 text-sm">
          <span v-if="previousPhoto" class="flex items-center">
            <kbd class="px-2 py-1 bg-black/30 rounded">←</kbd>
            <span class="ml-1">Previous</span>
          </span>
          <span v-if="nextPhoto" class="flex items-center">
            <kbd class="px-2 py-1 bg-black/30 rounded">→</kbd>
            <span class="ml-1">Next</span>
          </span>
        </div>
      </div>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount } from 'vue';
const loadedImages = ref(new Set());
const imageErrors = ref(new Set());

const onImageLoad = (event, photoId) => { // Correct parameter name
  if (!photoId) { // Check if photoId is valid
    console.warn('onImageLoad called with invalid photoId:', photoId);
    return;
  }
  const photo = props.photos.find(p => p.id === photoId); // Find the photo using the ID
  if (!photo) {
    console.warn(`onImageLoad: Photo with ID ${photoId} not found in props.photos.`);
    return;
  }
  event.target.classList.add('loaded');
  loadedImages.value.add(photoId);
  imageErrors.value.delete(photoId);
  
  console.log('Image loaded successfully:', {
    photoId: photo.id, // Use found photo object
    type: photo.photo_type,
    path: photo.file_path
  });
};

const onImageError = (photoId) => { // Correct parameter name
  if (!photoId) { // Check if photoId is valid
    console.error('onImageError called with invalid photoId:', photoId);
    return;
  }
  const photo = props.photos.find(p => p.id === photoId); // Find the photo using the ID
  if (!photo) {
    console.error(`onImageError: Photo with ID ${photoId} not found in props.photos.`);
    // Still add the ID to errors if we received an error event for it,
    // even if the photo disappeared from props.
    imageErrors.value.add(photoId);
    return;
  }
  console.error('Failed to load image:', {
    photoId: photo.id, // Use found photo object
    type: photo.photo_type,
    path: photo.file_path
  });
  imageErrors.value.add(photoId);
};
import BaseModal from '@/components/overlays/BaseModal.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseIcon from '@/components/base/BaseIcon.vue';

const props = defineProps({
  photos: {
    type: Array,
    required: true
  }
});

// Reset states when photos change
watch(() => props.photos, (newPhotos) => {
  console.log('Photos updated:', newPhotos?.map(p => ({
    id: p.id,
    type: p.photo_type,
    path: p.file_path
  })));
  
  // Clear old states
  loadedImages.value.clear();
  imageErrors.value.clear();
}, { immediate: true });

import projectsService from '@/services/projects.service';
import { useToast } from 'vue-toastification';

const toast = useToast();
const emit = defineEmits(['photo-deleted', 'update:photos']);
const selectedPhoto = ref(null);
const isPreviewOpen = ref(false);
const activePhotoMenu = ref(null);
const photoToDelete = ref(null);

// Photo menu methods
const openPhotoMenu = (photo) => {
  activePhotoMenu.value = photo.id;
  // Close menu when clicking outside
  const closeMenu = (e) => {
    if (!e.target.closest('.photo-menu')) {
      activePhotoMenu.value = null;
      document.removeEventListener('click', closeMenu);
    }
  };
  document.addEventListener('click', closeMenu);
};

// Photo deletion methods
const confirmDeletePhoto = (photo) => {
  photoToDelete.value = photo;
  if (confirm('Are you sure you want to delete this photo? This action cannot be undone.')) {
    deletePhoto();
  }
};

const deletePhoto = async () => {
  if (!photoToDelete.value?.id) return;
  
  try {
    console.log('Attempting to delete photo with ID:', photoToDelete.value.id);
    const response = await projectsService.deletePhoto(photoToDelete.value.project_id, photoToDelete.value.id);
    toast.success('Photo deleted successfully');
    
    // Make a copy of the updated photos array to avoid reference issues
    const updatedPhotos = [...props.photos.filter(p => p.id !== photoToDelete.value.id)];
    console.log('Filtered photos array after deletion, remaining:', updatedPhotos.length);
    
    // Emit the update photos event with the filtered array
    emit('update:photos', updatedPhotos);
    
    // Also emit the photo-deleted event for components that listen for it
    emit('photo-deleted', photoToDelete.value.id);
    
    if (selectedPhoto.value?.id === photoToDelete.value.id) {
      closePreview();
    }
  } catch (error) {
    console.error('Failed to delete photo:', error);
    toast.error('Failed to delete photo');
  } finally {
    photoToDelete.value = null;
    activePhotoMenu.value = null;
  }
};

// Get photo URL based on file path with enhanced error handling
const getPhotoUrl = (photo) => {
  if (!photo?.file_path) {
    console.warn('Missing file path for photo:', photo);
    return ''; // Return empty string for missing paths
  }

  // Normalize slashes and remove any leading slash
  let normalizedPath = photo.file_path.replace(/\\/g, '/');
  if (normalizedPath.startsWith('/')) {
    normalizedPath = normalizedPath.substring(1);
  }

  // Ensure the path starts correctly relative to the domain root for the proxy
  // The proxy handles '/uploads', so the path should start with 'uploads/...'
  if (!normalizedPath.startsWith('uploads/')) {
     console.warn('Photo path does not start with uploads/ :', normalizedPath);
     // Attempt to fix if it's just missing the prefix
     if (normalizedPath.includes('project-photos')) {
       normalizedPath = 'uploads/' + normalizedPath.substring(normalizedPath.indexOf('project-photos'));
     } else {
        // If path is unexpected, return empty to avoid broken image requests
       console.error('Unexpected photo path format:', normalizedPath);
       return '';
     }
  }
  
  // Prepend '/' to make it absolute from the domain root
  const finalUrl = '/' + normalizedPath;

  console.log('Resolved photo URL:', {
    originalPath: photo.file_path,
    finalUrl,
    photoId: photo.id,
    photoType: photo.photo_type
  });

  return finalUrl;
};

// Format date
const formatDate = (dateString, detailed = false) => {
  if (!dateString) return '';
  
  const date = new Date(dateString);
  if (detailed) {
    return date.toLocaleString('en-US', {
      month: 'long',
      day: 'numeric',
      year: 'numeric',
      hour: 'numeric',
      minute: '2-digit'
    });
  }
  
  return date.toLocaleString('en-US', {
    month: 'short',
    day: 'numeric'
  });
};

// Navigation between photos
const currentPhotoIndex = computed(() => {
  if (!selectedPhoto.value) return -1;
  return props.photos.findIndex(p => p.id === selectedPhoto.value.id);
});

const previousPhoto = computed(() => {
  if (currentPhotoIndex.value <= 0) return null;
  return props.photos[currentPhotoIndex.value - 1];
});

const nextPhoto = computed(() => {
  if (currentPhotoIndex.value >= props.photos.length - 1) return null;
  return props.photos[currentPhotoIndex.value + 1];
});

// Open photo preview
const openPreview = (photo) => {
  selectedPhoto.value = photo;
  isPreviewOpen.value = true;
  activePhotoMenu.value = null; // Close menu if open
};

// Close photo preview
const closePreview = () => {
  selectedPhoto.value = null;
  isPreviewOpen.value = false;
};

// Navigate between photos
const navigatePhotos = (direction) => {
  if (direction === 'previous' && previousPhoto.value) {
    selectedPhoto.value = previousPhoto.value;
  } else if (direction === 'next' && nextPhoto.value) {
    selectedPhoto.value = nextPhoto.value;
  }
};

// Handle keyboard navigation
const handleKeyboard = (event) => {
  if (!isPreviewOpen.value) return;
  
  switch (event.key) {
    case 'ArrowLeft':
      if (previousPhoto.value) navigatePhotos('previous');
      break;
    case 'ArrowRight':
      if (nextPhoto.value) navigatePhotos('next');
      break;
    case 'Escape':
      closePreview();
      break;
  }
};

// Setup and cleanup keyboard listeners
onMounted(() => {
  document.addEventListener('keydown', handleKeyboard);
});

onBeforeUnmount(() => {
  document.removeEventListener('keydown', handleKeyboard);
});

// Handle window click for menu closing
const handleWindowClick = (event) => {
  if (!event.target.closest('.photo-menu') && !event.target.closest('.photo-actions')) {
    activePhotoMenu.value = null;
  }
};

onMounted(() => {
  window.addEventListener('click', handleWindowClick);
});

onBeforeUnmount(() => {
  window.removeEventListener('click', handleWindowClick);
});
</script>

<style>
.photo-preview-modal :deep(.modal-content) {
  height: 100vh;
}

@media (min-width: 640px) {
  .photo-preview-modal :deep(.modal-content) {
    height: 90vh;
  }
}

/* Smooth image loading transition */
img {
  transition: opacity 300ms;
}

img[loading] {
  opacity: 0;
}

img.loaded {
  opacity: 1;
}
</style>