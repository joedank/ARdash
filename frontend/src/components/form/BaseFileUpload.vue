/**
 * BaseFileUpload
 *
 * A file upload component with drag & drop support, file previews,
 * upload progress, and file validation.
 *
 * @props {Array} allowedTypes - Array of allowed MIME types (e.g. ['image/*', '.pdf'])
 * @props {Number} maxSize - Maximum file size in bytes
 * @props {Boolean} multiple - Allow multiple file selection
 * @props {String} accept - HTML input accept attribute value
 * @props {Boolean} disabled - Disable the upload input
 * @props {Number} maxFiles - Maximum number of files allowed (when multiple)
 * 
 * @events update:files - Emitted when files are added/removed
 * @events error - Emitted when validation fails with error message
 * @events progress - Emitted during file upload with progress percentage
 * 
 * @slots default - Content for the dropzone area
 * @slots file-preview - Custom file preview template
 */

<template>
  <div class="relative">
    <!-- Hidden file input -->
    <input
      ref="fileInput"
      type="file"
      :accept="accept"
      :multiple="multiple"
      class="hidden"
      @change="handleFileSelect"
    />

    <!-- Dropzone area -->
    <div
      :class="[
        'border-2 border-dashed rounded-lg p-6 text-center transition-colors',
        'hover:border-blue-500 hover:bg-blue-50 dark:hover:bg-blue-900/10',
        isDragging ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/10' : 'border-gray-300 dark:border-gray-700',
        disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'
      ]"
      @click="!disabled && $refs.fileInput.click()"
      @dragover.prevent="handleDragOver"
      @dragleave.prevent="handleDragLeave"
      @drop.prevent="handleDrop"
    >
      <!-- Default slot or fallback content -->
      <slot>
        <div class="space-y-2 text-gray-600 dark:text-gray-400">
          <div class="flex justify-center">
            <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
            </svg>
          </div>
          <p class="text-sm">
            <span class="font-medium text-blue-600 dark:text-blue-400">Click to upload</span>
            or drag and drop
          </p>
          <p v-if="acceptedFormats" class="text-xs">
            {{ acceptedFormats }}
          </p>
        </div>
      </slot>
    </div>

    <!-- File preview section -->
    <div v-if="files.length > 0" class="mt-4 space-y-2">
      <TransitionGroup name="file-list">
        <div
          v-for="(file, index) in files"
          :key="file.name"
          class="flex items-center justify-between p-2 bg-gray-50 dark:bg-gray-800 rounded"
        >
          <slot name="file-preview" :file="file">
            <div class="flex items-center space-x-2">
              <div class="flex-shrink-0">
                <!-- Preview for images -->
                <img
                  v-if="file.type.startsWith('image/')"
                  :src="file.preview"
                  class="w-10 h-10 object-cover rounded"
                  alt=""
                />
                <!-- Icon for other file types -->
                <div
                  v-else
                  class="w-10 h-10 bg-gray-100 dark:bg-gray-700 rounded flex items-center justify-center"
                >
                  <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
                  </svg>
                </div>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium text-gray-900 dark:text-gray-100 truncate">
                  {{ file.name }}
                </p>
                <p class="text-xs text-gray-500 dark:text-gray-400">
                  {{ formatFileSize(file.size) }}
                </p>
              </div>
            </div>
          </slot>

          <!-- Progress bar -->
          <div v-if="file.progress !== undefined" class="flex items-center space-x-2">
            <div class="w-24 h-1 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
              <div
                class="h-full bg-blue-500 transition-all duration-300"
                :style="{ width: `${file.progress}%` }"
              ></div>
            </div>
            <span class="text-xs text-gray-500 dark:text-gray-400">{{ file.progress }}%</span>
          </div>

          <!-- Remove button -->
          <button
            type="button"
            class="ml-2 text-gray-400 hover:text-gray-500 dark:hover:text-gray-300"
            @click="removeFile(index)"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </TransitionGroup>
    </div>

    <!-- Error message -->
    <p v-if="error" class="mt-2 text-sm text-red-600 dark:text-red-400">
      {{ error }}
    </p>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue';

const props = defineProps({
  allowedTypes: {
    type: Array,
    default: () => []
  },
  maxSize: {
    type: Number,
    default: 5 * 1024 * 1024 // 5MB
  },
  multiple: {
    type: Boolean,
    default: false
  },
  accept: {
    type: String,
    default: ''
  },
  disabled: {
    type: Boolean,
    default: false
  },
  maxFiles: {
    type: Number,
    default: 10
  }
});

const emit = defineEmits(['update:files', 'error', 'progress']);

const fileInput = ref(null);
const files = ref([]);
const isDragging = ref(false);
const error = ref('');

const acceptedFormats = computed(() => {
  if (props.accept) {
    const formats = props.accept.split(',').map(f => f.trim());
    return `Accepted formats: ${formats.join(', ')}`;
  }
  return '';
});

// File validation
const validateFile = (file) => {
  // Check file type
  if (props.allowedTypes.length > 0) {
    const isValidType = props.allowedTypes.some(type => {
      if (type.includes('*')) {
        return file.type.startsWith(type.split('*')[0]);
      }
      return file.type === type;
    });
    if (!isValidType) {
      error.value = 'File type not allowed';
      return false;
    }
  }

  // Check file size
  if (file.size > props.maxSize) {
    error.value = `File size exceeds ${formatFileSize(props.maxSize)}`;
    return false;
  }

  return true;
};

// Handle file selection
const handleFileSelect = (event) => {
  const newFiles = Array.from(event.target.files);
  processFiles(newFiles);
  event.target.value = ''; // Reset input
};

// Handle drag and drop
const handleDragOver = (event) => {
  if (!props.disabled) {
    isDragging.value = true;
  }
};

const handleDragLeave = () => {
  isDragging.value = false;
};

const handleDrop = (event) => {
  if (!props.disabled) {
    isDragging.value = false;
    const newFiles = Array.from(event.dataTransfer.files);
    processFiles(newFiles);
  }
};

// Process files
const processFiles = (newFiles) => {
  error.value = '';

  // Check max files limit
  if (!props.multiple && newFiles.length > 1) {
    error.value = 'Only one file can be uploaded';
    return;
  }

  if (props.multiple && files.value.length + newFiles.length > props.maxFiles) {
    error.value = `Maximum ${props.maxFiles} files allowed`;
    return;
  }

  // Validate and process each file
  newFiles.forEach(file => {
    if (validateFile(file)) {
      // Create file preview for images
      if (file.type.startsWith('image/')) {
        file.preview = URL.createObjectURL(file);
      }
      
      // Add progress property
      file.progress = 0;
      
      // Simulate upload progress
      simulateUpload(file);
      
      if (props.multiple) {
        files.value.push(file);
      } else {
        files.value = [file];
      }
    }
  });

  emit('update:files', files.value);
};

// Remove file
const removeFile = (index) => {
  if (files.value[index].preview) {
    URL.revokeObjectURL(files.value[index].preview);
  }
  files.value.splice(index, 1);
  emit('update:files', files.value);
};

// Format file size
const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i]}`;
};

// Simulate upload progress
const simulateUpload = (file) => {
  let progress = 0;
  const interval = setInterval(() => {
    progress += Math.random() * 10;
    if (progress > 100) {
      progress = 100;
      clearInterval(interval);
    }
    file.progress = Math.round(progress);
    emit('progress', { file, progress: file.progress });
  }, 200);
};

// Clean up previews when component is unmounted
watch(files, (newFiles, oldFiles) => {
  oldFiles?.forEach(file => {
    if (file.preview) {
      URL.revokeObjectURL(file.preview);
    }
  });
}, { deep: true });
</script>

<style scoped>
.file-list-enter-active,
.file-list-leave-active {
  transition: all 0.3s ease;
}

.file-list-enter-from,
.file-list-leave-to {
  opacity: 0;
  transform: translateX(-30px);
}
</style>