<template>
  <div class="estimate-item-photos">
    <!-- Loading indicator -->
    <div v-if="loading" class="flex justify-center items-center py-8">
      <div class="spinner-border text-primary" role="status">
        <span class="sr-only">Loading...</span>
      </div>
    </div>

    <!-- No line items message -->
    <div v-else-if="!estimateItems || estimateItems.length === 0" class="p-4 text-center">
      <p class="text-gray-500">No estimate items found for this project.</p>
    </div>

    <!-- Line items with photo galleries -->
    <div v-else class="estimate-items-list">
      <!-- Item list header -->
      <div class="sticky top-0 z-10 bg-gray-100 dark:bg-gray-800 p-4 shadow-sm">
        <h2 class="text-xl font-semibold">Line Items</h2>
        <p class="text-sm text-gray-500">Select an item to view or add photos</p>
      </div>

      <!-- Accordion of line items -->
      <div class="accordion">
        <div
          v-for="item in estimateItems"
          :key="item.id"
          class="border-b border dark:border-gray-700"
        >
          <!-- Item header -->
          <div
            class="flex justify-between items-center p-4 cursor-pointer"
            @click="toggleItem(item.id)"
          >
            <div>
              <h3 class="text-base sm:text-lg font-medium">{{ item.description }}</h3>
              <div class="flex items-center text-sm text-gray-500">
                <span>{{ item.quantity }} {{ item.unit }}</span>
              </div>
            </div>
            <div class="flex items-center">
              <span
                class="mr-2 py-1 px-2 text-xs text-white rounded-lg"
                :class="getPhotoCountBadgeClass(item.id)"
              >
                {{ getPhotoCount(item.id) }} photos
              </span>
              <!-- Additional work indicator -->
              <span
                v-if="hasAdditionalWork(item.id)"
                class="mr-2 py-1 px-2 text-xs bg-yellow-500 text-white rounded-lg"
              >
                Extra work
              </span>
              <i
                class="text-lg"
                :class="activeItem === item.id ? 'pi pi-chevron-up' : 'pi pi-chevron-down'"
              ></i>
            </div>
          </div>

          <!-- Item content (photos) -->
          <div
            v-if="activeItem === item.id"
            class="p-4 bg-gray-50 dark:bg-gray-900"
          >
            <!-- Photo gallery -->
            <div v-if="getPhotoCount(item.id) > 0" class="mb-4">
              <h4 class="text-md font-medium mb-2">Photos</h4>

              <!-- Photo grid -->
              <div class="grid grid-cols-2 md:grid-cols-3 gap-2">
                <div
                  v-for="photo in getItemPhotos(item.id)"
                  :key="photo.id"
                  class="relative pb-[100%] bg-gray-200 dark:bg-gray-800 rounded overflow-hidden"
                >
                  <!-- Photo with overlay for actions -->
                  <img
                    :src="getPhotoUrl(photo.filePath)"
                    :alt="photo.originalName || 'Item photo'"
                    class="absolute inset-0 w-full h-full object-cover"
                    @click="showPhotoDetail(photo)"
                  />

                  <div class="absolute bottom-0 left-0 right-0 p-1 bg-black bg-opacity-50 flex justify-between items-center">
                    <span class="text-xs text-white">{{ formatDate(photo.createdAt) }}</span>
                    <button
                      @click.stop="confirmDeletePhoto(photo.id, item.id)"
                      class="text-white p-1 rounded-full hover:bg-red-500"
                    >
                      <i class="pi pi-trash text-sm"></i>
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Upload actions -->
            <div class="flex flex-col mt-4">
              <!-- Camera capture button -->
              <button
              @click="capturePhoto(item.id)"
              class="py-2 px-4 rounded-lg font-medium transition-all bg-white text-blue-600 flex items-center justify-center mb-2"
              >
                <i class="pi pi-camera mr-2"></i>
                Take Photo
              </button>

              <!-- Upload from gallery button -->
              <button
              @click="triggerFileInput(item.id)"
              class="py-2 px-4 rounded-lg font-medium transition-all border text-gray-700 flex items-center justify-center"
              >
                <i class="pi pi-image mr-2"></i>
                Upload from Gallery
              </button>

              <!-- Hidden file input -->
              <input
                :ref="`fileInput-${item.id}`"
                type="file"
                accept="image/*"
                class="hidden"
                @change="handleFileUpload($event, item.id)"
              />
            </div>

            <!-- Additional Work Section -->
            <div class="border-t border-gray-200 dark:border-gray-700 mt-4 pt-4">
              <div class="flex items-center mb-2">
                <input
                  type="checkbox"
                  :id="`additional-work-${item.id}`"
                  v-model="additionalWorkChecked[item.id]"
                  class="mr-2 h-4 w-4"
                />
                <label :for="`additional-work-${item.id}`" class="text-md font-medium">
                  Additional work performed
                </label>
              </div>

              <div v-if="additionalWorkChecked[item.id]" class="mt-2">
                <textarea
                  v-model="additionalWorkText[item.id]"
                  class="w-full rounded-lg border p-2 text-gray-800 dark:bg-gray-800 dark:text-white dark:border-gray-700"
                  rows="3"
                  placeholder="Describe what additional work was performed..."
                ></textarea>

                <div class="mt-2 flex justify-end">
                  <button
                    @click="saveAdditionalWork(item.id)"
                    class="py-1 px-3 rounded-lg font-medium bg-blue-600 text-white text-sm"
                    :disabled="!additionalWorkText[item.id]"
                  >
                    Save
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Photo detail modal -->
    <div v-if="selectedPhoto" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black bg-opacity-75">
      <div class="bg-white dark:bg-gray-800 rounded-lg overflow-hidden max-w-3xl w-full max-h-[90vh] flex flex-col">
        <!-- Modal header -->
        <div class="p-4 border-b border dark:border-gray-700 flex justify-between items-center">
          <h3 class="text-lg font-medium">Photo Details</h3>
          <button @click="selectedPhoto = null" class="text-gray-500 hover:text-gray-700">
            <i class="pi pi-times"></i>
          </button>
        </div>

        <!-- Modal body -->
        <div class="flex-1 overflow-auto">
          <!-- Photo -->
          <div class="relative h-64 md:h-96 bg-gray-200 dark:bg-gray-900">
            <img
              :src="getPhotoUrl(selectedPhoto.filePath)"
              :alt="selectedPhoto.originalName || 'Item photo'"
              class="w-full h-full object-contain"
            />
          </div>

          <!-- Details form -->
          <div class="p-4">
            <div class="mb-4">
              <label class="block text-sm font-medium mb-1">Photo Type</label>
              <select
                v-model="selectedPhoto.photoType"
                class="w-full rounded-lg border bg-white text-gray-800 p-3 dark:border-gray-700"
                @change="updatePhotoDetails()"
              >
                <option value="progress">In Progress</option>
                <option value="completed">Completed</option>
                <option value="issue">Issue/Problem</option>
                <option value="material">Materials</option>
                <option value="other">Other</option>
              </select>
            </div>

            <div class="mb-4">
              <label class="block text-sm font-medium mb-1">Notes</label>
              <textarea
                v-model="selectedPhoto.notes"
                class="w-full rounded-lg border bg-white text-gray-800 p-3 dark:border-gray-700"
                rows="3"
                @blur="updatePhotoDetails()"
              ></textarea>
            </div>

            <div class="text-sm text-gray-500">
              <p>Uploaded: {{ formatDateTime(selectedPhoto.createdAt) }}</p>
              <p>Original filename: {{ selectedPhoto.originalName }}</p>
            </div>
          </div>
        </div>

        <!-- Modal footer -->
        <div class="p-4 border-t border dark:border-gray-700 flex justify-end">
          <button
            @click="confirmDeletePhoto(selectedPhoto.id, selectedPhoto.estimateItemId)"
            class="py-2 px-4 rounded-lg font-medium transition-all bg-white text-red-600 mr-2"
          >
            Delete Photo
          </button>
          <button @click="selectedPhoto = null" class="py-2 px-4 rounded-lg font-medium transition-all bg-white text-gray-500">
            Close
          </button>
        </div>
      </div>
    </div>

    <!-- Delete confirmation modal -->
    <div v-if="showDeleteConfirm" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black bg-opacity-75">
      <div class="bg-white dark:bg-gray-800 rounded-lg overflow-hidden max-w-md w-full">
        <div class="p-4">
          <h3 class="text-lg font-medium mb-2">Confirm Delete</h3>
          <p>Are you sure you want to delete this photo? This action cannot be undone.</p>
        </div>
        <div class="p-4 border-t border dark:border-gray-700 flex justify-end">
          <button @click="showDeleteConfirm = false" class="py-2 px-4 rounded-lg font-medium transition-all bg-white text-gray-500 mr-2">
            Cancel
          </button>
          <button @click="deletePhoto()" class="py-2 px-4 rounded-lg font-medium transition-all bg-white text-red-600">
            Delete
          </button>
        </div>
      </div>
    </div>

    <!-- Camera capture modal for mobile -->
    <div v-if="showCamera" class="fixed inset-0 z-50 flex flex-col bg-black">
      <!-- Camera header -->
      <div class="p-4 flex justify-between items-center bg-gray-900">
        <h3 class="text-white text-lg font-medium">Take Photo</h3>
        <button @click="closeCamera()" class="text-white">
          <i class="pi pi-times"></i>
        </button>
      </div>

      <!-- Camera view -->
      <div class="flex-1 relative">
        <video ref="videoElement" autoplay class="w-full h-full object-cover"></video>

        <!-- Capture button -->
        <div class="absolute bottom-0 left-0 right-0 p-4 flex justify-center">
          <button
            @click="takePicture()"
            class="w-16 h-16 rounded-full bg-white flex items-center justify-center shadow-lg"
          >
            <div class="w-14 h-14 rounded-full border-2 border-gray-300"></div>
          </button>
        </div>
      </div>

      <!-- Hidden canvas for capturing -->
      <canvas ref="canvasElement" class="hidden"></canvas>
    </div>

    <!-- Photo preview after capture -->
    <div v-if="capturedImage" class="fixed inset-0 z-50 flex flex-col bg-black">
      <!-- Preview header -->
      <div class="p-4 flex justify-between items-center bg-gray-900">
        <h3 class="text-white text-lg font-medium">Review Photo</h3>
        <button @click="capturedImage = null" class="text-white">
          <i class="pi pi-times"></i>
        </button>
      </div>

      <!-- Image preview -->
      <div class="flex-1 relative">
        <img :src="capturedImage" class="w-full h-full object-contain"/>
      </div>

      <!-- Action buttons -->
      <div class="p-4 bg-gray-900 flex justify-between">
        <button @click="retakePhoto()" class="py-2 px-4 rounded-lg font-medium transition-all bg-white text-gray-500">
          Retake
        </button>
        <button @click="savePhoto()" class="py-2 px-4 rounded-lg font-medium transition-all bg-white text-blue-600">
          Use Photo
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue';
import { useToast } from 'primevue/usetoast';
import estimateItemPhotosService from '../../services/standardized-estimate-item-photos.service';
import estimatesService from '../../services/standardized-estimates.service';
import estimateItemAdditionalWorkService from '../../services/estimate-item-additional-work.service';

export default {
  name: 'EstimateItemPhotos',
  props: {
    projectId: {
      type: String,
      required: true
    },
    estimateId: {
      type: String,
      required: true
    }
  },

  setup(props) {
    // State
    const loading = ref(true);
    const estimateItems = ref([]);
    const itemPhotos = ref({});
    const activeItem = ref(null);
    const selectedPhoto = ref(null);
    const showDeleteConfirm = ref(false);
    const photoToDelete = ref({});
    const showCamera = ref(false);
    const capturedImage = ref(null);
    const currentItemId = ref(null);

    // Additional Work state
    const additionalWorkChecked = ref({});
    const additionalWorkText = ref({});
    const additionalWorkData = ref({});

    // Refs for camera access
    const videoElement = ref(null);
    const canvasElement = ref(null);
    const stream = ref(null);

    // Toast for notifications
    const toast = useToast();

    // Load estimate items and their photos
    const loadData = async () => {
      loading.value = true;

      try {
        // Get estimate details with items
        const estimateResponse = await estimatesService.getById(props.estimateId);

        if (estimateResponse.success && estimateResponse.data) {
          // Store estimate items (using 'items' key from standardized service)
          if (Array.isArray(estimateResponse.data.items)) {
            estimateItems.value = estimateResponse.data.items;
          } else {
            // Handle case where items array might be missing in the data
            estimateItems.value = [];
            console.warn('Estimate items array not found in response data:', estimateResponse.data);
          }

          // Get photos for all estimate items now that estimate details are loaded
          const photosResponse = await estimateItemPhotosService.getPhotosByEstimate(props.estimateId);

          if (photosResponse.success && photosResponse.data) {
            itemPhotos.value = photosResponse.data;
          } else {
            // Optionally handle photo fetch failure more gracefully
            console.warn('Failed to load estimate item photos:', photosResponse);
            itemPhotos.value = {};
          }

          // Load additional work data for all estimate items
          const additionalWorkResponse = await estimateItemAdditionalWorkService.getAdditionalWorkByEstimate(props.estimateId);

          if (additionalWorkResponse.success && additionalWorkResponse.data) {
            additionalWorkData.value = additionalWorkResponse.data;

            // Initialize checkbox and text values
            Object.keys(additionalWorkData.value).forEach(itemId => {
              additionalWorkChecked.value[itemId] = true;
              additionalWorkText.value[itemId] = additionalWorkData.value[itemId].description;
            });
          }

        } else {
          toast.add({
            severity: 'error',
            summary: 'Error',
            detail: 'Failed to load estimate details',
            life: 3000
          });
          estimateItems.value = [];
          itemPhotos.value = {};
        }
      } catch (error) {
        console.error('Error loading data:', error);
        toast.add({
          severity: 'error',
          summary: 'Error',
          detail: 'An unexpected error occurred',
          life: 3000
        });
      } finally {
        loading.value = false;
      }
    };

    // Toggle accordion item
    const toggleItem = (itemId) => {
      if (activeItem.value === itemId) {
        activeItem.value = null;
      } else {
        activeItem.value = itemId;
      }
    };

    // Get photos for a specific line item
    const getItemPhotos = (itemId) => {
      if (itemPhotos.value && itemPhotos.value[itemId]) {
        return itemPhotos.value[itemId].photos || [];
      }
      return [];
    };

    // Get photo count for a line item
    const getPhotoCount = (itemId) => {
      return getItemPhotos(itemId).length;
    };

    // Get badge class based on photo count
    const getPhotoCountBadgeClass = (itemId) => {
      const count = getPhotoCount(itemId);
      if (count === 0) return 'bg-gray-500';
      if (count >= 5) return 'bg-green-500';
      return 'bg-blue-500';
    };

    // Check if an item has additional work recorded
    const hasAdditionalWork = (itemId) => {
      return additionalWorkData.value && additionalWorkData.value[itemId];
    };

    // Save additional work for an item
    const saveAdditionalWork = async (itemId) => {
      if (!additionalWorkText.value[itemId]) {
        toast.add({
          severity: 'warn',
          summary: 'Warning',
          detail: 'Please enter a description for the additional work',
          life: 3000
        });
        return;
      }

      try {
        const response = await estimateItemAdditionalWorkService.saveAdditionalWork(
          itemId,
          additionalWorkText.value[itemId]
        );

        if (response.success) {
          toast.add({
            severity: 'success',
            summary: 'Success',
            detail: 'Additional work saved successfully',
            life: 3000
          });

          // Update local state
          if (!additionalWorkData.value) {
            additionalWorkData.value = {};
          }

          additionalWorkData.value[itemId] = {
            id: response.data.id,
            description: additionalWorkText.value[itemId],
            createdAt: response.data.created_at,
            updatedAt: response.data.updated_at
          };
        } else {
          toast.add({
            severity: 'error',
            summary: 'Error',
            detail: response.message || 'Failed to save additional work',
            life: 3000
          });
        }
      } catch (error) {
        console.error('Error saving additional work:', error);
        toast.add({
          severity: 'error',
          summary: 'Error',
          detail: 'An unexpected error occurred',
          life: 3000
        });
      }
    };

    // Format currency
    const formatCurrency = (value) => {
      if (!value) return '$0.00';
      return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
      }).format(value);
    };

    // Format date
    const formatDate = (dateString) => {
      if (!dateString) return '';
      const date = new Date(dateString);
      return new Intl.DateTimeFormat('en-US', {
        month: 'short',
        day: 'numeric'
      }).format(date);
    };

    // Format date and time
    const formatDateTime = (dateString) => {
      if (!dateString) return '';
      const date = new Date(dateString);
      return new Intl.DateTimeFormat('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric',
        hour: 'numeric',
        minute: 'numeric'
      }).format(date);
    };

    // Get photo URL
    const getPhotoUrl = (filePath) => {
      if (!filePath) return '';
      return `/uploads/${filePath}`;
    };

    // Show photo detail modal
    const showPhotoDetail = (photo) => {
      selectedPhoto.value = { ...photo };
    };

    // Update photo details
    const updatePhotoDetails = async () => {
      if (!selectedPhoto.value) return;

      try {
        const response = await estimateItemPhotosService.updatePhoto(
          selectedPhoto.value.estimateItemId,
          selectedPhoto.value.id,
          {
            photoType: selectedPhoto.value.photoType,
            notes: selectedPhoto.value.notes
          }
        );

        if (response.success) {
          toast.add({
            severity: 'success',
            summary: 'Success',
            detail: 'Photo details updated',
            life: 3000
          });

          // Update in local state
          const itemId = selectedPhoto.value.estimateItemId;
          if (itemPhotos.value[itemId]) {
            const photoIndex = itemPhotos.value[itemId].photos.findIndex(p => p.id === selectedPhoto.value.id);
            if (photoIndex >= 0) {
              itemPhotos.value[itemId].photos[photoIndex] = {
                ...itemPhotos.value[itemId].photos[photoIndex],
                photoType: selectedPhoto.value.photoType,
                notes: selectedPhoto.value.notes
              };
            }
          }
        } else {
          toast.add({
            severity: 'error',
            summary: 'Error',
            detail: response.message || 'Failed to update photo details',
            life: 3000
          });
        }
      } catch (error) {
        console.error('Error updating photo:', error);
        toast.add({
          severity: 'error',
          summary: 'Error',
          detail: 'An unexpected error occurred',
          life: 3000
        });
      }
    };

    // Confirm photo deletion
    const confirmDeletePhoto = (photoId, itemId) => {
      photoToDelete.value = { photoId, itemId };
      showDeleteConfirm.value = true;

      // Close detail modal if open
      if (selectedPhoto.value && selectedPhoto.value.id === photoId) {
        selectedPhoto.value = null;
      }
    };

    // Delete photo
    const deletePhoto = async () => {
      if (!photoToDelete.value.photoId || !photoToDelete.value.itemId) {
        showDeleteConfirm.value = false;
        return;
      }

      try {
        const response = await estimateItemPhotosService.deletePhoto(
          photoToDelete.value.itemId,
          photoToDelete.value.photoId
        );

        if (response.success) {
          toast.add({
            severity: 'success',
            summary: 'Success',
            detail: 'Photo deleted successfully',
            life: 3000
          });

          // Remove from local state
          const itemId = photoToDelete.value.itemId;
          if (itemPhotos.value[itemId]) {
            itemPhotos.value[itemId].photos = itemPhotos.value[itemId].photos.filter(
              p => p.id !== photoToDelete.value.photoId
            );
          }
        } else {
          toast.add({
            severity: 'error',
            summary: 'Error',
            detail: response.message || 'Failed to delete photo',
            life: 3000
          });
        }
      } catch (error) {
        console.error('Error deleting photo:', error);
        toast.add({
          severity: 'error',
          summary: 'Error',
          detail: 'An unexpected error occurred',
          life: 3000
        });
      } finally {
        showDeleteConfirm.value = false;
        photoToDelete.value = {};
      }
    };

    // Trigger file input for upload
    const triggerFileInput = (itemId) => {
      const fileInput = document.querySelector(`input[type="file"][ref="fileInput-${itemId}"]`);
      if (fileInput) {
        fileInput.click();
      }
    };

    // Handle file upload
    const handleFileUpload = async (event, itemId) => {
      const file = event.target.files[0];
      if (!file) return;

      try {
        const response = await estimateItemPhotosService.uploadPhoto(
          itemId,
          file,
          { photoType: 'progress' }
        );

        if (response.success) {
          toast.add({
            severity: 'success',
            summary: 'Success',
            detail: 'Photo uploaded successfully',
            life: 3000
          });

          // Add to local state
          if (!itemPhotos.value[itemId]) {
            itemPhotos.value[itemId] = {
              itemId,
              description: estimateItems.value.find(i => i.id === itemId)?.description || '',
              photos: []
            };
          }

          itemPhotos.value[itemId].photos.unshift(response.data);

          // Reset file input
          event.target.value = '';
        } else {
          toast.add({
            severity: 'error',
            summary: 'Error',
            detail: response.message || 'Failed to upload photo',
            life: 3000
          });
        }
      } catch (error) {
        console.error('Error uploading photo:', error);
        toast.add({
          severity: 'error',
          summary: 'Error',
          detail: 'An unexpected error occurred',
          life: 3000
        });
      }
    };

    // Camera functions
    const capturePhoto = async (itemId) => {
      currentItemId.value = itemId;

      try {
        // Request camera access
        stream.value = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: 'environment' }
        });

        // Show camera UI
        showCamera.value = true;

        // Once UI is rendered, attach stream to video element
        setTimeout(() => {
          if (videoElement.value) {
            videoElement.value.srcObject = stream.value;
          }
        }, 100);
      } catch (error) {
        console.error('Error accessing camera:', error);
        toast.add({
          severity: 'error',
          summary: 'Camera Error',
          detail: 'Could not access device camera',
          life: 3000
        });
      }
    };

    // Take picture from camera
    const takePicture = () => {
      const video = videoElement.value;
      const canvas = canvasElement.value;

      if (!video || !canvas) return;

      // Set canvas dimensions to match video
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;

      // Draw current video frame to canvas
      const context = canvas.getContext('2d');
      context.drawImage(video, 0, 0, canvas.width, canvas.height);

      // Convert canvas to image data URL
      capturedImage.value = canvas.toDataURL('image/jpeg');

      // Hide camera view
      showCamera.value = false;
    };

    // Retake photo
    const retakePhoto = () => {
      capturedImage.value = null;
      showCamera.value = true;
    };

    // Save captured photo
    const savePhoto = async () => {
      if (!capturedImage.value || !currentItemId.value) return;

      try {
        // Convert data URL to file
        const response = await fetch(capturedImage.value);
        const blob = await response.blob();
        const file = new File([blob], `photo-${Date.now()}.jpg`, { type: 'image/jpeg' });

        // Upload photo
        const uploadResponse = await estimateItemPhotosService.uploadPhoto(
          currentItemId.value,
          file,
          { photoType: 'progress' }
        );

        if (uploadResponse.success) {
          toast.add({
            severity: 'success',
            summary: 'Success',
            detail: 'Photo saved successfully',
            life: 3000
          });

          // Add to local state
          if (!itemPhotos.value[currentItemId.value]) {
            itemPhotos.value[currentItemId.value] = {
              itemId: currentItemId.value,
              description: estimateItems.value.find(i => i.id === currentItemId.value)?.description || '',
              photos: []
            };
          }

          itemPhotos.value[currentItemId.value].photos.unshift(uploadResponse.data);
        } else {
          toast.add({
            severity: 'error',
            summary: 'Error',
            detail: uploadResponse.message || 'Failed to save photo',
            life: 3000
          });
        }
      } catch (error) {
        console.error('Error saving photo:', error);
        toast.add({
          severity: 'error',
          summary: 'Error',
          detail: 'An unexpected error occurred',
          life: 3000
        });
      } finally {
        // Clean up
        closeCamera();
      }
    };

    // Close camera and clean up
    const closeCamera = () => {
      // Stop stream if it exists
      if (stream.value) {
        stream.value.getTracks().forEach(track => track.stop());
        stream.value = null;
      }

      // Reset state
      showCamera.value = false;
      capturedImage.value = null;
      currentItemId.value = null;
    };

    // Load data on component mount
    onMounted(() => {
      loadData();
    });

    return {
      loading,
      estimateItems,
      itemPhotos,
      activeItem,
      selectedPhoto,
      showDeleteConfirm,
      showCamera,
      capturedImage,
      videoElement,
      canvasElement,
      additionalWorkChecked,
      additionalWorkText,
      hasAdditionalWork,
      saveAdditionalWork,

      toggleItem,
      getItemPhotos,
      getPhotoCount,
      getPhotoCountBadgeClass,
      formatCurrency,
      formatDate,
      formatDateTime,
      getPhotoUrl,
      showPhotoDetail,
      updatePhotoDetails,
      confirmDeletePhoto,
      deletePhoto,
      triggerFileInput,
      handleFileUpload,
      capturePhoto,
      takePicture,
      retakePhoto,
      savePhoto,
      closeCamera
    };
  }
};
</script>

<style scoped>
/* Mobile optimizations */
</style>
