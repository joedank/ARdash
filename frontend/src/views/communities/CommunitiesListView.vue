<template>
  <div class="space-y-8">
    <!-- Page Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold mb-2 text-gray-900 dark:text-white">Communities</h1>
      <p class="text-gray-600 dark:text-gray-400">Manage mobile home communities and their advertisements</p>
    </div>

    <!-- Search and Filters -->
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm p-4 mb-6">
      <div class="flex flex-col md:flex-row md:items-center space-y-4 md:space-y-0 md:space-x-4">
        <div class="flex-1">
          <BaseFormGroup label="Search Communities" input-id="search-communities" class="mb-0">
            <BaseInput
              id="search-communities"
              v-model="searchQuery"
              placeholder="Search by name, city, or address"
              @input="debouncedSearch"
            >
              <template #suffix>
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
              </template>
            </BaseInput>
          </BaseFormGroup>
        </div>
        <div class="w-full md:w-48">
          <BaseFormGroup label="Status" input-id="status-filter" class="mb-0">
            <BaseSelect
              id="status-filter"
              v-model="activeFilter"
              :options="statusOptions"
              @update:modelValue="handleFilter"
            />
          </BaseFormGroup>
        </div>
        <div class="w-full md:w-auto">
          <BaseButton
            variant="primary"
            @click="openCreateModal"
            class="w-full md:w-auto flex items-center justify-center md:justify-start space-x-2"
          >
            <span>Add Community</span>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 5a1 1 0 011 1v3h3a1 1 0 110 2h-3v3a1 1 0 01-2 0v-3H6a1 1 0 010-2h3V6a1 1 0 011-1z" clip-rule="evenodd" />
            </svg>
          </BaseButton>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="py-12 flex flex-col items-center justify-center">
      <BaseSkeletonLoader type="card" width="100%" height="100px" :count="3" class="mb-4" />
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="py-12 flex flex-col items-center justify-center text-center">
      <p class="text-red-500 dark:text-red-400 mb-4">{{ error }}</p>
      <BaseButton variant="secondary" @click="loadCommunities">Try Again</BaseButton>
    </div>

    <!-- Empty State -->
    <div v-else-if="filteredCommunities.length === 0" class="py-12 flex flex-col items-center justify-center text-center">
      <p class="text-gray-500 dark:text-gray-400 mb-4">
        <span v-if="searchQuery">No communities found matching "{{ searchQuery }}"</span>
        <span v-else>No communities found. Create your first community to get started.</span>
      </p>
      <BaseButton variant="primary" @click="openCreateModal">Add Community</BaseButton>
    </div>

    <!-- Communities Grid -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <transition-group name="fade" appear>
        <BaseCard
          v-for="community in filteredCommunities"
          :key="community.id"
          variant="bordered"
          hover
          clickable
          @click="viewCommunity(community.id)"
          :class="{ 'border-l-4 border-l-green-500': community.isActive }"
          class="card-hover-effect"
        >
        <!-- Community Header with Status -->
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white">{{ community.name }}</h3>
          <span
            class="px-2 py-1 text-xs rounded-full"
            :class="community.isActive ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' : 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200'"
          >
            {{ community.isActive ? 'Active' : 'Inactive' }}
          </span>
        </div>

        <!-- Community Details -->
        <div class="text-sm text-gray-600 dark:text-gray-400 mb-4">
          <p v-if="community.address" class="mb-1">{{ community.address }}</p>
          <p v-if="community.city" class="mb-1">{{ community.city }}</p>
          <p v-if="community.phone" class="mb-1">{{ formatPhone(community.phone) }}</p>
        </div>

        <!-- Ad Information -->
        <div
          class="p-3 rounded-lg bg-gray-50 dark:bg-gray-800 mb-4"
        >
          <h4 class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Advertisement</h4>
          <div v-if="community.selectedAdType" class="text-sm">
            <p class="font-medium text-gray-900 dark:text-white">{{ community.selectedAdType.name }}</p>
            <div class="flex justify-between mt-1">
              <span class="text-gray-600 dark:text-gray-400">{{ community.selectedAdType.width }} × {{ community.selectedAdType.height }}</span>
              <span class="font-medium text-gray-900 dark:text-white">${{ community.selectedAdType.cost }}</span>
            </div>
          </div>
          <p v-else class="text-sm text-gray-500 dark:text-gray-400 italic">No ad type selected</p>
        </div>

        <!-- Actions -->
        <div class="flex justify-between items-center">
          <BaseButton variant="text" @click.stop="viewCommunity(community.id)">
            View Details
          </BaseButton>
          <BaseButton
            variant="outline"
            :class="community.isActive ? 'text-red-600 border-red-600 hover:bg-red-50 dark:text-red-400 dark:border-red-400 dark:hover:bg-red-900/20' : 'text-green-600 border-green-600 hover:bg-green-50 dark:text-green-400 dark:border-green-400 dark:hover:bg-green-900/20'"
            @click.stop="toggleActiveStatus(community)"
          >
            {{ community.isActive ? 'Deactivate' : 'Activate' }}
          </BaseButton>
        </div>
        </BaseCard>
      </transition-group>
    </div>

    <!-- Create Community Modal -->
    <BaseModal
      v-model="showCreateModal"
      title="Create New Community"
      size="lg"
    >
      <form @submit.prevent="createCommunity" class="space-y-4">
        <!-- Community Information Section -->
        <div class="border-b border-gray-200 dark:border-gray-700 pb-4 mb-4">
          <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Community Information</h3>

          <BaseFormGroup label="Community Name" input-id="name" required>
            <BaseInput
              id="name"
              v-model="newCommunity.name"
              placeholder="Enter community name"
              required
            />
          </BaseFormGroup>

          <BaseFormGroup label="Address" input-id="address">
            <BaseInput
              id="address"
              v-model="newCommunity.address"
              placeholder="Enter address"
            />
          </BaseFormGroup>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <BaseFormGroup label="City" input-id="city">
              <BaseInput
                id="city"
                v-model="newCommunity.city"
                placeholder="Enter city"
              />
            </BaseFormGroup>

            <BaseFormGroup label="State" input-id="state">
              <BaseInput
                id="state"
                v-model="newCommunity.state"
                placeholder="Enter state"
              />
            </BaseFormGroup>
          </div>

          <BaseFormGroup label="Phone Number" input-id="phone">
            <BaseInput
              id="phone"
              v-model="newCommunity.phone"
              type="tel"
              placeholder="Enter phone number"
            />
          </BaseFormGroup>

          <BaseFormGroup label="Number of Spaces" input-id="spaces">
            <BaseInput
              id="spaces"
              v-model="newCommunity.spaces"
              type="number"
              placeholder="Enter number of spaces"
            />
          </BaseFormGroup>

          <BaseFormGroup label="Newsletter Link" input-id="newsletterLink">
            <BaseInput
              id="newsletterLink"
              v-model="newCommunity.newsletterLink"
              type="url"
              placeholder="Enter newsletter link"
            />
          </BaseFormGroup>

          <BaseFormGroup label="General Notes" input-id="generalNotes">
            <BaseTextarea
              id="generalNotes"
              v-model="newCommunity.generalNotes"
              rows="3"
              placeholder="Enter general notes"
            />
          </BaseFormGroup>
        </div>

        <!-- Ad Specialist Section -->
        <div class="border-b border-gray-200 dark:border-gray-700 pb-4 mb-4">
          <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Ad Specialist Contact</h3>

          <BaseFormGroup label="Specialist Name" input-id="adSpecialistName">
            <BaseInput
              id="adSpecialistName"
              v-model="newCommunity.adSpecialistName"
              placeholder="Enter specialist name"
            />
          </BaseFormGroup>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <BaseFormGroup label="Email" input-id="adSpecialistEmail">
              <BaseInput
                id="adSpecialistEmail"
                v-model="newCommunity.adSpecialistEmail"
                type="email"
                placeholder="Enter email address"
              />
            </BaseFormGroup>

            <BaseFormGroup label="Phone" input-id="adSpecialistPhone">
              <BaseInput
                id="adSpecialistPhone"
                v-model="newCommunity.adSpecialistPhone"
                type="tel"
                placeholder="Enter phone number"
              />
            </BaseFormGroup>
          </div>
        </div>

        <!-- Ad Types Section -->
        <div class="pb-4 mb-4">
          <div class="flex justify-between items-center mb-4">
            <h3 class="text-lg font-medium text-gray-900 dark:text-white">Advertisement Types</h3>
            <BaseButton
              variant="text"
              size="sm"
              @click="addNewAdType"
              type="button"
            >
              Add Ad Type
            </BaseButton>
          </div>

          <div v-if="newAdTypes.length === 0" class="text-center py-4 bg-gray-50 dark:bg-gray-800 rounded-lg mb-4">
            <p class="text-gray-500 dark:text-gray-400 mb-2">No ad types added yet</p>
            <p class="text-sm text-gray-500 dark:text-gray-400">A community must have at least one ad type to be active</p>
            <BaseButton
              variant="primary"
              size="sm"
              @click="addNewAdType"
              class="mt-2"
              type="button"
            >
              Add Ad Type
            </BaseButton>
          </div>

          <div v-for="(adType, index) in newAdTypes" :key="index" class="border border-gray-200 dark:border-gray-700 rounded-lg p-4 mb-4">
            <div class="flex justify-between items-center mb-3">
              <h4 class="font-medium text-gray-900 dark:text-white">Ad Type #{{ index + 1 }}</h4>
              <BaseButton
                variant="text"
                size="sm"
                class="text-red-600 dark:text-red-400"
                @click="removeAdType(index)"
                type="button"
              >
                Remove
              </BaseButton>
            </div>

            <BaseFormGroup label="Ad Type Name" :input-id="`adType-${index}-name`" required>
              <BaseInput
                :id="`adType-${index}-name`"
                v-model="adType.name"
                placeholder="Enter ad type name"
                required
              />
            </BaseFormGroup>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <BaseFormGroup label="Width" :input-id="`adType-${index}-width`">
                <BaseInput
                  :id="`adType-${index}-width`"
                  v-model="adType.width"
                  type="number"
                  step="0.01"
                  min="0"
                  placeholder="Enter width"
                />
              </BaseFormGroup>

              <BaseFormGroup label="Height" :input-id="`adType-${index}-height`">
                <BaseInput
                  :id="`adType-${index}-height`"
                  v-model="adType.height"
                  type="number"
                  step="0.01"
                  min="0"
                  placeholder="Enter height"
                />
              </BaseFormGroup>
            </div>

            <BaseFormGroup label="Cost ($)" :input-id="`adType-${index}-cost`">
              <BaseInput
                :id="`adType-${index}-cost`"
                v-model="adType.cost"
                type="number"
                step="0.1"
                min="0"
                placeholder="Enter cost"
              />
            </BaseFormGroup>

            <BaseFormGroup label="Term (months)" :input-id="`adType-${index}-termMonths`">
              <BaseInput
                :id="`adType-${index}-termMonths`"
                v-model="adType.termMonths"
                type="number"
                step="0.1"
                min="0"
                placeholder="Enter term in months"
              />
            </BaseFormGroup>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <BaseFormGroup label="Start Date" :input-id="`adType-${index}-startDate`">
                <BaseInput
                  :id="`adType-${index}-startDate`"
                  v-model="adType.startDate"
                  type="date"
                />
              </BaseFormGroup>

              <BaseFormGroup label="End Date" :input-id="`adType-${index}-endDate`">
                <BaseInput
                  :id="`adType-${index}-endDate`"
                  v-model="adType.endDate"
                  type="date"
                />
              </BaseFormGroup>

              <BaseFormGroup label="Deadline Date" :input-id="`adType-${index}-deadlineDate`">
                <BaseInput
                  :id="`adType-${index}-deadlineDate`"
                  v-model="adType.deadlineDate"
                  type="date"
                />
              </BaseFormGroup>
            </div>

            <div class="flex items-center space-x-2 mt-3">
              <input
                type="radio"
                :id="`adType-${index}-selected`"
                :name="'selectedAdType'"
                :value="index"
                v-model="selectedAdTypeIndex"
                class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300"
              />
              <label :for="`adType-${index}-selected`" class="text-sm font-medium text-gray-700 dark:text-gray-300">Set as selected ad type</label>
            </div>
          </div>
        </div>

        <!-- Active Status Section -->
        <div class="flex justify-end space-x-3 pt-4">
          <BaseButton
            type="button"
            variant="secondary"
            @click="showCreateModal = false"
          >
            Cancel
          </BaseButton>
          <BaseButton
            type="submit"
            variant="primary"
            :loading="createLoading"
            :disabled="createLoading"
          >
            Create Community
          </BaseButton>
        </div>
      </form>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { debounce } from 'lodash-es';
import communityService from '@/services/community.service';
import useErrorHandler from '@/composables/useErrorHandler.js';
import { useToast } from '@/composables/useToast.js';

// UI Components
import BaseCard from '@/components/data-display/BaseCard.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseSkeletonLoader from '@/components/data-display/BaseSkeletonLoader.vue';
import BaseModal from '@/components/overlays/BaseModal.vue';
import BaseTooltip from '@/components/overlays/BaseTooltip.vue';
import BaseBadge from '@/components/data-display/BaseBadge.vue';

// Form Components
import BaseInput from '@/components/form/BaseInput.vue';
import BaseTextarea from '@/components/form/BaseTextarea.vue';
import BaseFormGroup from '@/components/form/BaseFormGroup.vue';
import BaseSelect from '@/components/form/BaseSelect.vue';.vue';

const router = useRouter();
const { handleError, successToast } = useErrorHandler();
const toast = useToast();

// State
const communities = ref([]);
const loading = ref(true);
const error = ref(null);
const searchQuery = ref('');
const activeFilter = ref('all');
const showCreateModal = ref(false);
const createLoading = ref(false);
const newAdTypes = ref([]);
const selectedAdTypeIndex = ref(null);

// Pagination
const currentPage = ref(1);
const itemsPerPage = ref(10);
const totalItems = ref(0);

// Options
const statusOptions = [
  { value: 'all', label: 'All Communities' },
  { value: 'active', label: 'Active Only' },
  { value: 'inactive', label: 'Inactive Only' }
];

const newCommunity = reactive({
  name: '',
  address: '',
  city: '',
  state: '',
  phone: '',
  spaces: null,
  newsletterLink: '',
  generalNotes: '',
  adSpecialistName: '',
  adSpecialistEmail: '',
  adSpecialistPhone: '',
  isActive: false
});

// Computed Properties
const filteredCommunities = computed(() => {
  let filtered = [...communities.value];

  // Apply search filter
  if (searchQuery.value) {
    const lowerQuery = searchQuery.value.toLowerCase();
    filtered = filtered.filter(community =>
      community.name?.toLowerCase().includes(lowerQuery) ||
      community.city?.toLowerCase().includes(lowerQuery) ||
      community.address?.toLowerCase().includes(lowerQuery)
    );
  }

  // Apply status filter 
  if (activeFilter.value === 'active') {
    filtered = filtered.filter(community => community.isActive);
  } else if (activeFilter.value === 'inactive') {
    filtered = filtered.filter(community => !community.isActive);
  }

  totalItems.value = filtered.length;
  return filtered;
});

const totalPages = computed(() => {
  return Math.max(1, Math.ceil(totalItems.value / itemsPerPage.value));
});

const paginatedCommunities = computed(() => {
  if (!filteredCommunities.value.length) {
    return [];
  }
  const start = (currentPage.value - 1) * itemsPerPage.value;
  const end = start + itemsPerPage.value;
  return filteredCommunities.value.slice(start, end);
});

const visiblePages = computed(() => {
  const pages = [];
  const total = totalPages.value;
  const current = currentPage.value;
  
  // Always show first page
  pages.push(1);
  
  // Show pages around current
  for (let i = Math.max(2, current - 1); i <= Math.min(total - 1, current + 1); i++) {
    pages.push(i);
  }
  
  // Always show last page if more than 1 page
  if (total > 1) {
    pages.push(total);
  }
  
  // Remove duplicates and sort
  return [...new Set(pages)].sort((a, b) => a - b);
});

// Methods
const loadCommunities = async () => {
  loading.value = true;
  error.value = null;

  try {
    const result = await communityService.getAllCommunities();
    communities.value = result || [];
    totalItems.value = communities.value.length;
  } catch (err) {
    handleError(err, 'Failed to load communities.');
    error.value = 'Failed to load communities. Please try again.';
    communities.value = [];
    totalItems.value = 0;
  } finally {
    loading.value = false;
  }
};

// Create debounced search function 
const searchCommunities = async () => {
  if (!searchQuery.value.trim()) {
    loadCommunities();
    return;
  }
  
  loading.value = true;
  error.value = null;

  try {
    const result = await communityService.searchCommunities(searchQuery.value);
    communities.value = result || [];
    totalItems.value = communities.value.length;
  } catch (err) {
    handleError(err, 'Failed to search communities.');
    error.value = 'Failed to search communities. Please try again.';
    communities.value = [];
    totalItems.value = 0;
  } finally {
    loading.value = false;
  }
};

const debouncedSearch = debounce(searchCommunities, 300);

const handleFilter = () => {
  currentPage.value = 1;
  loadCommunities();
};

const handlePageChange = (newPage) => {
  currentPage.value = newPage;
};

const addNewAdType = () => {
  newAdTypes.value.push({
    name: '',
    width: '',
    height: '',
    cost: '',
    termMonths: '',
    startDate: '',
    endDate: '',
    deadlineDate: ''
  });

  // If this is the first ad type, automatically select it
  if (newAdTypes.value.length === 1) {
    selectedAdTypeIndex.value = 0;
  }
};

const removeAdType = (index) => {
  newAdTypes.value.splice(index, 1);

  // If we removed the selected ad type, reset the selection
  if (selectedAdTypeIndex.value === index) {
    selectedAdTypeIndex.value = newAdTypes.value.length > 0 ? 0 : null;
  } else if (selectedAdTypeIndex.value > index) {
    // If we removed an ad type before the selected one, adjust the index
    selectedAdTypeIndex.value--;
  }

  // If we removed all ad types, disable isActive
  if (newAdTypes.value.length === 0 || selectedAdTypeIndex.value === null) {
    newCommunity.isActive = false;
  }
};

const toggleNewCommunityActiveStatus = () => {
  // Only allow toggling if there's at least one ad type and one is selected
  if (newAdTypes.value.length > 0 && selectedAdTypeIndex.value !== null) {
    newCommunity.isActive = !newCommunity.isActive;
  }
};

const openCreateModal = () => {
  // Reset form fields
  Object.keys(newCommunity).forEach(key => {
    if (key === 'isActive') {
      newCommunity[key] = false;
    } else if (key === 'spaces') {
      newCommunity[key] = null;
    } else {
      newCommunity[key] = '';
    }
  });

  // Reset ad types
  newAdTypes.value = [];
  selectedAdTypeIndex.value = null;

  showCreateModal.value = true;
};

const createCommunity = async () => {
  createLoading.value = true;

  try {
    // Validate that we have at least one ad type if isActive is true
    if (newCommunity.isActive && newAdTypes.value.length === 0) {
      throw new Error('A community must have at least one ad type to be active');
    }

    // If trying to set as active, ensure there's a selected ad type
    if (newCommunity.isActive && selectedAdTypeIndex.value === null && newAdTypes.value.length > 0) {
      throw new Error('Please select an ad type to set the community as active');
    }

    // Create the community first
    const created = await communityService.createCommunity(newCommunity);

    // If we have ad types, create them
    if (newAdTypes.value.length > 0) {
      const adTypePromises = newAdTypes.value.map(adType => {
        return communityService.createAdType(created.id, adType);
      });

      const createdAdTypes = await Promise.all(adTypePromises);

      // If we have a selected ad type, set it
      if (selectedAdTypeIndex.value !== null && createdAdTypes[selectedAdTypeIndex.value]) {
        const selectedAdType = createdAdTypes[selectedAdTypeIndex.value];
        await communityService.selectAdType(created.id, selectedAdType.id);
      }
    }

    successToast('Community created successfully');
    showCreateModal.value = false;
    loadCommunities();
  } catch (err) {
    handleError(err, 'Failed to create community.');
  } finally {
    createLoading.value = false;
  }
};

const viewCommunity = (id) => {
  router.push({ name: 'community-detail', params: { id } });
};

const toggleActiveStatus = async (community) => {
  try {
    const newStatus = !community.isActive;

    // If trying to activate, check if the community has ad types
    if (newStatus) {
      // Fetch the community details to check for ad types
      const communityDetails = await communityService.getCommunityById(community.id);

      // Check if the community has ad types
      if (!communityDetails.adTypes || communityDetails.adTypes.length === 0) {
        handleError(new Error('Cannot activate a community without ad types'), 'Cannot activate a community without ad types. Please add at least one ad type first.');
        return;
      }

      // Check if the community has a selected ad type
      if (!communityDetails.selectedAdTypeId) {
        handleError(new Error('Cannot activate a community without a selected ad type'), 'Cannot activate a community without a selected ad type. Please select an ad type first.');
        return;
      }
    }

    const updated = await communityService.setActiveStatus(community.id, newStatus);

    // Update the community in the list
    const index = communities.value.findIndex(c => c.id === community.id);
    if (index !== -1) {
      communities.value[index] = updated;
    }

    successToast(`Community ${newStatus ? 'activated' : 'deactivated'} successfully`);
  } catch (err) {
    handleError(err, 'Failed to update community status.');
  }
};

const formatPhone = (phone) => {
  if (!phone) return '';

  // Basic US phone number formatting
  const cleaned = ('' + phone).replace(/\D/g, '');
  const match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);

  if (match) {
    return '(' + match[1] + ') ' + match[2] + '-' + match[3];
  }

  return phone;
};

// Lifecycle hooks
onMounted(() => {
  loadCommunities();
});
</script>

<style scoped>
/* Table hover effects */
tr {
  transition: background-color 0.15s ease;
}

/* Remove old styles that aren't needed anymore */
</style>