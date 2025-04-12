<template>
  <div class="photo-upload-section">
    <form @submit.prevent="uploadPhoto">
      <!-- Upload Button -->
      <label
        :for="inputId"
        class="block"
      >
        <div
          class="flex items-center justify-center p-4 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg cursor-pointer hover:border-primary-500 dark:hover:border-primary-500 transition-colors"
          :class="{ 'opacity-50': uploading }"
        >
          <div class="text-center">
            <BaseIcon
              name="camera"
              class="w-8 h-8 mx-auto mb-2 text-gray-400 dark:text-gray-500"
            />
            <span class="text-sm text-gray-600 dark:text-gray-400">
              {{ label || 'Add Photo' }}
            </span>
            <input
              :id="inputId"
              ref="fileInput"
              type="file"
              accept="image/jpeg,image/png,image/gif,image/webp,.jpg,.jpeg,.png,.gif,.webp"
              class="hidden"
              @change="handleFileSelect"
            >
          </div>
        </div>
      </label>

      <!-- Image Preview (shows after photo selection) -->
      <div v-if="selectedFile && previewUrl" class="mt-4 flex flex-col gap-2">
        <div class="rounded-lg overflow-hidden border border-gray-200 dark:border-gray-700 max-w-xs">
          <img :src="previewUrl" class="w-full h-auto object-cover" :alt="selectedFile.name">
        </div>
        
        <!-- Notes Input (shows after photo selection) -->
        <BaseTextarea
          v-model="notes"
          placeholder="Add notes about this photo (optional)"
          rows="2"
        />
      </div>

      <!-- Upload Controls -->
      <div
        v-if="selectedFile"
        class="flex justify-end items-center gap-2 mt-2"
      >
        <BaseButton
          type="button"
          variant="outline"
          size="sm"
          @click.prevent="cancelUpload"
        >
          Cancel
        </BaseButton>
        <BaseButton
          type="submit"
          variant="primary"
          size="sm"
          :loading="uploading"
        >
          Upload Photo
        </BaseButton>
      </div>

      <!-- Progress Bar -->
      <div
        v-if="uploading"
        class="mt-4 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden"
      >
        <div
          class="h-2 bg-primary-500 transition-all duration-300"
          :style="{ width: `${uploadProgress}%` }"
        />
      </div>

      <!-- Error Message -->
      <div
        v-if="error"
        class="mt-2 text-sm text-red-600 dark:text-red-400"
      >
        {{ error }}
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, computed, onBeforeUnmount } from 'vue';
import projectsService from '@/services/projects.service';
import BaseIcon from '@/components/base/BaseIcon.vue';
import BaseTextarea from '@/components/form/BaseTextarea.vue';
import BaseButton from '@/components/base/BaseButton.vue';

const props = defineProps({
  projectId: {
    type: String,
    required: true
  },
  photoType: {
    type: String,
    required: true,
    validator: value => ['before', 'after', 'receipt', 'assessment', 'condition'].includes(value) // Added 'condition'
  },
  label: {
    type: String,
    default: ''
  }
});

const emit = defineEmits(['photo-added']);

// Unique ID for file input
const inputId = computed(() => `photo-upload-${props.photoType}-${Date.now()}`);

const fileInput = ref(null);
const selectedFile = ref(null);
const previewUrl = ref(null);
const notes = ref('');
const uploading = ref(false);
const uploadProgress = ref(0);
const error = ref('');
const abortController = ref(null);

// Cleanup on unmount
onBeforeUnmount(() => {
  if (abortController.value) {
    abortController.value.abort();
  }
  
  // Clean up any preview URL
  if (previewUrl.value) {
    URL.revokeObjectURL(previewUrl.value);
    previewUrl.value = null;
  }
});

// Handle file selection
const handleFileSelect = async (event) => {
  event.preventDefault();
  const file = event.target.files[0];
  
  // Clear any previous errors and selections
  error.value = '';
  selectedFile.value = null;
  
  // Clean up any previous preview URL
  if (previewUrl.value) {
    URL.revokeObjectURL(previewUrl.value);
    previewUrl.value = null;
  }
  
  if (!file) {
    error.value = 'No file selected';
    return;
  }

  try {
    // Validate file type
    const supportedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (!supportedTypes.includes(file.type)) {
      error.value = 'Please use JPEG, PNG, GIF, or WebP image formats.';
      if (fileInput.value) {
        fileInput.value.value = '';
      }
      return;
    }

    // Validate file size
    if (file.size > 10 * 1024 * 1024) {
      error.value = 'Image size should be less than 10MB';
      if (fileInput.value) {
        fileInput.value.value = '';
      }
      return;
    }

    console.log('File selected:', {
      name: file.name,
      type: file.type,
      size: `${(file.size / 1024 / 1024).toFixed(2)}MB`
    });

    selectedFile.value = file;
  } catch (err) {
    console.error('File validation error:', err);
    error.value = 'Error validating image. Please try another format.';
    if (fileInput.value) {
      fileInput.value.value = '';
    }
  }

  console.log('File selected:', {
    name: file.name,
    type: file.type,
    size: `${(file.size / 1024 / 1024).toFixed(2)}MB`
  });

  selectedFile.value = file;
  
  // Create thumbnail preview
  previewUrl.value = URL.createObjectURL(file);
};

// Upload photo
const uploadPhoto = async (event) => {
  event.preventDefault();
  if (!selectedFile.value) {
    error.value = 'Please select a photo to upload';
    return;
  }

  if (uploading.value) {
    return; // Prevent multiple uploads
  }

  uploading.value = true;
  uploadProgress.value = 0;
  error.value = '';

  try {
    // Create new AbortController for this upload
    abortController.value = new AbortController();

    console.log('Starting photo upload:', {
      projectId: props.projectId,
      photoType: props.photoType,
      fileName: selectedFile.value.name
    });

    await projectsService.addPhoto(
      props.projectId,
      selectedFile.value,
      {
        photo_type: props.photoType,
        notes: notes.value
      },
      (progress) => {
        uploadProgress.value = progress;
      },
      abortController.value.signal
    );
    
    // Clear the abort controller after successful upload
    abortController.value = null;

    console.log('Photo upload successful');
    
    // Clear form
    selectedFile.value = null;
    notes.value = '';
    if (fileInput.value) {
      fileInput.value.value = '';
    }
    
    // Clean up preview URL
    if (previewUrl.value) {
      URL.revokeObjectURL(previewUrl.value);
      previewUrl.value = null;
    }

    console.log('Photo upload completed successfully');
    // Wait a moment for the server to process the image
    await new Promise(resolve => setTimeout(resolve, 500));
    // Notify parent
    emit('photo-added');
  } catch (err) {
    console.error('Photo upload error:', err);
    error.value = err.message || 'Failed to upload photo. Please try again.';
    if (err.name === 'AbortError') {
      error.value = 'Upload cancelled';
    }
  } finally {
    uploading.value = false;
    uploadProgress.value = 0;
    abortController.value = null;
  }
};

// Cancel upload
const cancelUpload = () => {
  // Abort ongoing upload if exists
  if (abortController.value && uploading.value) {
    abortController.value.abort();
    abortController.value = null;
    error.value = 'Upload cancelled';
    uploading.value = false;
  }

  // Reset form state
  selectedFile.value = null;
  notes.value = '';
  uploadProgress.value = 0;
  if (fileInput.value) {
    fileInput.value.value = '';
  }
  
  // Clean up preview URL
  if (previewUrl.value) {
    URL.revokeObjectURL(previewUrl.value);
    previewUrl.value = null;
  }
};
</script>

<style scoped>
/* iOS-style tap highlight removal */
.photo-upload-section {
  -webkit-tap-highlight-color: transparent;
}
</style>