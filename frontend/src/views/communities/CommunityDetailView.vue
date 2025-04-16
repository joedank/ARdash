<template>
  <div class="space-y-8">
    <!-- Loading State -->
    <div v-if="loading" class="py-12 flex flex-col items-center justify-center">
      <BaseSkeletonLoader type="card" width="100%" height="100px" :count="3" class="mb-4" />
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="py-12 flex flex-col items-center justify-center text-center">
      <p class="text-red-500 dark:text-red-400 mb-4">{{ error }}</p>
      <div class="flex gap-4">
        <BaseButton variant="secondary" @click="loadCommunity">Try Again</BaseButton>
        <BaseButton variant="text" @click="goBack">Back to Communities</BaseButton>
      </div>
    </div>

    <div v-else class="space-y-8">
      <!-- Page Header -->
      <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div class="space-y-2">
          <div class="flex items-center gap-2">
            <BaseButton variant="text" @click="goBack" class="flex items-center gap-1">
              <span class="text-lg">←</span> Back to Communities
            </BaseButton>
          </div>
          <h1 class="text-3xl font-bold text-gray-900 dark:text-white">{{ community?.name || 'Community Details' }}</h1>
          <div class="flex items-center gap-2">
            <span
              class="px-2 py-1 text-xs rounded-full"
              :class="community?.isActive ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' : 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200'"
            >
              {{ community?.isActive ? 'Active' : 'Inactive' }}
            </span>
          </div>
        </div>
        <div class="flex gap-3">
          <BaseButton
            variant="outline"
            :class="community.isActive ? 'text-red-600 border-red-600 hover:bg-red-50 dark:text-red-400 dark:border-red-400 dark:hover:bg-red-900/20' : 'text-green-600 border-green-600 hover:bg-green-50 dark:text-green-400 dark:border-green-400 dark:hover:bg-green-900/20'"
            @click="toggleActiveStatus"
          >
            {{ community.isActive ? 'Deactivate' : 'Activate' }}
          </BaseButton>
          <BaseButton variant="primary" @click="prepareEditCommunity()">Edit Community</BaseButton>
        </div>
      </div>

      <!-- Community Information Section -->
      <transition name="fade" appear>
        <BaseCard variant="bordered" class="overflow-hidden card-hover-effect">
          <template #header>
            <h2 class="text-xl font-semibold text-gray-900 dark:text-white">Community Information</h2>
          </template>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div class="space-y-1">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Address</p>
            <p class="text-gray-900 dark:text-white">{{ community?.address || 'Not specified' }}</p>
          </div>
          <div class="space-y-1">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">City</p>
            <p class="text-gray-900 dark:text-white">{{ community?.city || 'Not specified' }}</p>
          </div>
          <div class="space-y-1">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">State</p>
            <p class="text-gray-900 dark:text-white">{{ community?.state || 'Not specified' }}</p>
          </div>
          <div class="space-y-1">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Phone</p>
            <p class="text-gray-900 dark:text-white">{{ formatPhone(community?.phone) || 'Not specified' }}</p>
          </div>
          <div class="space-y-1">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Spaces</p>
            <p class="text-gray-900 dark:text-white">{{ community?.spaces || 'Not specified' }}</p>
          </div>
        </div>

        <div v-if="community?.newsletterLink" class="mt-6 pt-6 border-t border-gray-200 dark:border-gray-700">
          <p class="text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Newsletter Link</p>
          <a :href="community?.newsletterLink" target="_blank" class="text-blue-600 dark:text-blue-400 hover:underline break-all">
            {{ community?.newsletterLink }}
          </a>
        </div>

        <div v-if="community?.generalNotes" class="mt-6 pt-6 border-t border-gray-200 dark:border-gray-700">
          <p class="text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">General Notes</p>
          <p class="text-gray-900 dark:text-white whitespace-pre-line">{{ community?.generalNotes }}</p>
        </div>
      </BaseCard>
      </transition>

      <!-- Ad Specialist Section -->
      <transition name="fade" appear>
        <BaseCard variant="bordered" class="overflow-hidden card-hover-effect">
          <template #header>
            <div class="flex justify-between items-center">
              <h2 class="text-xl font-semibold text-gray-900 dark:text-white">Ad Specialist Contact</h2>
              <BaseButton variant="text" @click="prepareEditAdSpecialist()" size="sm">
                Edit Contact
              </BaseButton>
            </div>
          </template>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div class="space-y-1">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Name</p>
            <p class="text-gray-900 dark:text-white">{{ community?.adSpecialistName || 'Not specified' }}</p>
          </div>
          <div class="space-y-1">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Email</p>
            <a
              v-if="community?.adSpecialistEmail"
              :href="`mailto:${community?.adSpecialistEmail}`"
              class="text-blue-600 dark:text-blue-400 hover:underline"
            >
              {{ community?.adSpecialistEmail }}
            </a>
            <p v-else class="text-gray-900 dark:text-white">Not specified</p>
          </div>
          <div class="space-y-1">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Phone</p>
            <a
              v-if="community?.adSpecialistPhone"
              :href="`tel:${community?.adSpecialistPhone}`"
              class="text-blue-600 dark:text-blue-400 hover:underline"
            >
              {{ formatPhone(community?.adSpecialistPhone) }}
            </a>
            <p v-else class="text-gray-900 dark:text-white">Not specified</p>
          </div>
        </div>
      </BaseCard>
      </transition>

      <!-- Ad Types Section -->
      <transition name="fade" appear>
        <BaseCard variant="bordered" class="overflow-hidden card-hover-effect">
          <template #header>
            <div class="flex justify-between items-center">
              <h2 class="text-xl font-semibold text-gray-900 dark:text-white">Advertisement Types</h2>
              <BaseButton variant="text" @click="showCreateAdTypeModal = true" size="sm">
                Add Ad Type
              </BaseButton>
            </div>
          </template>

        <!-- Loading State -->
        <div v-if="adTypesLoading" class="py-8 flex flex-col items-center justify-center">
          <BaseSkeletonLoader type="table" width="100%" height="150px" class="mb-2" />
        </div>

        <!-- Empty State -->
        <div v-else-if="adTypes.length === 0" class="py-8 flex flex-col items-center justify-center text-center">
          <p class="text-gray-500 dark:text-gray-400 mb-4">No ad types defined for this community.</p>
          <BaseButton variant="primary" @click="showCreateAdTypeModal = true">
            Add Ad Type
          </BaseButton>
        </div>

        <!-- Ad Types Table -->
        <div v-else class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-800">
              <tr>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Name</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Dimensions</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Cost</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Term</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Dates</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Status</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <transition-group name="row" tag="tbody" class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
                <tr
                  v-for="adType in adTypes"
                  :key="adType.id"
                  :class="{ 'bg-blue-50 dark:bg-blue-900/20': community?.selectedAdTypeId === adType?.id }"
                  class="hover:bg-gray-50 dark:hover:bg-gray-800 transition-all duration-200"
                >
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-200">{{ adType.name }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-200">{{ adType.width }} × {{ adType.height }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-200">${{ adType.cost }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-200">{{ adType.termMonths ? `${adType.termMonths} months` : 'Not set' }}</td>
                <td class="px-6 py-4 text-sm text-gray-900 dark:text-gray-200">
                  <div v-if="adType.startDate || adType.endDate" class="space-y-1">
                    <div v-if="adType.startDate" class="text-sm">
                      <span class="text-gray-500 dark:text-gray-400">Start:</span> {{ formatDate(adType.startDate) }}
                    </div>
                    <div v-if="adType.endDate" class="text-sm">
                      <span class="text-gray-500 dark:text-gray-400">End:</span> {{ formatDate(adType.endDate) }}
                    </div>
                    <div v-if="adType.deadlineDate" class="text-sm">
                      <span class="text-gray-500 dark:text-gray-400">Deadline:</span> {{ formatDate(adType.deadlineDate) }}
                    </div>
                  </div>
                  <span v-else class="text-gray-500 dark:text-gray-400">Not set</span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-200">
                  <span
                    v-if="community?.selectedAdTypeId === adType?.id"
                    class="px-2 py-1 text-xs rounded-full bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200"
                  >
                    Selected
                  </span>
                  <span v-else class="text-gray-500 dark:text-gray-400">-</span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-200">
                  <div class="flex space-x-2">
                    <BaseButton
                      variant="text"
                      size="sm"
                      @click="selectAdType(adType?.id)"
                      :disabled="community?.selectedAdTypeId === adType?.id"
                    >
                      Select
                    </BaseButton>
                    <BaseButton variant="text" size="sm" @click="editAdType(adType)">
                      Edit
                    </BaseButton>
                    <BaseButton
                      variant="text"
                      size="sm"
                      class="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300"
                      @click="confirmDeleteAdType(adType)"
                    >
                      Delete
                    </BaseButton>
                  </div>
                </td>
                </tr>
            </transition-group>
          </table>
        </div>
      </BaseCard>
      </transition>
    </div>

    <!-- Edit Community Modal -->
    <BaseModal
      v-model="showEditModal"
      title="Edit Community"
      size="lg"
    >
      <form @submit.prevent="updateCommunity" class="space-y-4">
        <BaseFormGroup label="Community Name" input-id="edit-name" required>
          <BaseInput
            id="edit-name"
            v-model="editedCommunity.name"
            placeholder="Enter community name"
            required
          />
        </BaseFormGroup>

        <BaseFormGroup label="Address" input-id="edit-address">
          <BaseInput
            id="edit-address"
            v-model="editedCommunity.address"
            placeholder="Enter address"
          />
        </BaseFormGroup>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <BaseFormGroup label="City" input-id="edit-city">
            <BaseInput
              id="edit-city"
              v-model="editedCommunity.city"
              placeholder="Enter city"
            />
          </BaseFormGroup>

          <BaseFormGroup label="State" input-id="edit-state">
            <BaseInput
              id="edit-state"
              v-model="editedCommunity.state"
              placeholder="Enter state"
            />
          </BaseFormGroup>
        </div>

        <BaseFormGroup label="Phone Number" input-id="edit-phone">
          <BaseInput
            id="edit-phone"
            v-model="editedCommunity.phone"
            type="tel"
            placeholder="Enter phone number"
          />
        </BaseFormGroup>

        <BaseFormGroup label="Number of Spaces" input-id="edit-spaces">
          <BaseInput
            id="edit-spaces"
            v-model="editedCommunity.spaces"
            type="number"
            placeholder="Enter number of spaces"
          />
        </BaseFormGroup>

        <BaseFormGroup label="Newsletter Link" input-id="edit-newsletterLink">
          <BaseInput
            id="edit-newsletterLink"
            v-model="editedCommunity.newsletterLink"
            type="url"
            placeholder="Enter newsletter link"
          />
        </BaseFormGroup>

        <BaseFormGroup label="General Notes" input-id="edit-generalNotes">
          <BaseTextarea
            id="edit-generalNotes"
            v-model="editedCommunity.generalNotes"
            rows="3"
            placeholder="Enter general notes"
          />
        </BaseFormGroup>

        <div class="flex justify-end space-x-3 pt-4">
          <BaseButton
            type="button"
            variant="secondary"
            @click="showEditModal = false"
          >
            Cancel
          </BaseButton>
          <BaseButton
            type="submit"
            variant="primary"
            :loading="updateLoading"
            :disabled="updateLoading"
          >
            Update Community
          </BaseButton>
        </div>
      </form>
    </BaseModal>

    <!-- Ad Specialist Modal -->
    <BaseModal
      v-model="showAdSpecialistModal"
      title="Edit Ad Specialist Contact"
      size="md"
    >
      <form @submit.prevent="updateAdSpecialist" class="space-y-4">
        <BaseFormGroup label="Specialist Name" input-id="specialist-name">
          <BaseInput
            id="specialist-name"
            v-model="editedAdSpecialist.name"
            placeholder="Enter specialist name"
          />
        </BaseFormGroup>

        <BaseFormGroup label="Email" input-id="specialist-email">
          <BaseInput
            id="specialist-email"
            v-model="editedAdSpecialist.email"
            type="email"
            placeholder="Enter email address"
          />
        </BaseFormGroup>

        <BaseFormGroup label="Phone" input-id="specialist-phone">
          <BaseInput
            id="specialist-phone"
            v-model="editedAdSpecialist.phone"
            type="tel"
            placeholder="Enter phone number"
          />
        </BaseFormGroup>

        <div class="flex justify-end space-x-3 pt-4">
          <BaseButton
            type="button"
            variant="secondary"
            @click="showAdSpecialistModal = false"
          >
            Cancel
          </BaseButton>
          <BaseButton
            type="submit"
            variant="primary"
            :loading="updateLoading"
            :disabled="updateLoading"
          >
            Update Contact
          </BaseButton>
        </div>
      </form>
    </BaseModal>
  </div>

  <!-- Create Ad Type Modal -->
  <BaseModal
    v-model="showCreateAdTypeModal"
    title="Create New Ad Type"
    size="lg"
  >
    <form @submit.prevent="createAdType" class="space-y-4">
      <BaseFormGroup label="Ad Type Name" input-id="adtype-name" required>
        <BaseInput
          id="adtype-name"
          v-model="editedAdType.name"
          placeholder="Enter ad type name"
          required
        />
      </BaseFormGroup>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <BaseFormGroup label="Width" input-id="adtype-width">
          <BaseInput
            id="adtype-width"
            v-model="editedAdType.width"
            type="number"
            step="0.01"
            min="0"
            placeholder="Enter width"
          />
        </BaseFormGroup>

        <BaseFormGroup label="Height" input-id="adtype-height">
          <BaseInput
            id="adtype-height"
            v-model="editedAdType.height"
            type="number"
            step="0.01"
            min="0"
            placeholder="Enter height"
          />
        </BaseFormGroup>
      </div>

      <BaseFormGroup label="Cost ($)" input-id="adtype-cost">
        <BaseInput
          id="adtype-cost"
          v-model="editedAdType.cost"
          type="number"
          step="0.1"
          min="0"
          placeholder="Enter cost"
        />
      </BaseFormGroup>

      <BaseFormGroup label="Term (months)" input-id="adtype-term-months">
        <BaseInput
          id="adtype-term-months"
          v-model="editedAdType.termMonths"
          type="number"
          step="0.1"
          min="0"
          placeholder="Enter term in months"
        />
      </BaseFormGroup>

      <BaseFormGroup label="Start Date" input-id="adtype-start-date">
        <BaseInput
          id="adtype-start-date"
          v-model="editedAdType.startDate"
          type="date"
        />
      </BaseFormGroup>

      <BaseFormGroup label="End Date" input-id="adtype-end-date">
        <BaseInput
          id="adtype-end-date"
          v-model="editedAdType.endDate"
          type="date"
        />
      </BaseFormGroup>

      <BaseFormGroup label="Deadline Date" input-id="adtype-deadline-date">
        <BaseInput
          id="adtype-deadline-date"
          v-model="editedAdType.deadlineDate"
          type="date"
        />
      </BaseFormGroup>

      <div class="flex justify-end space-x-3 pt-4">
        <BaseButton
          type="button"
          variant="secondary"
          @click="showCreateAdTypeModal = false"
        >
          Cancel
        </BaseButton>
        <BaseButton
          type="submit"
          variant="primary"
          :loading="updateLoading"
          :disabled="updateLoading"
        >
          Create Ad Type
        </BaseButton>
      </div>
    </form>
  </BaseModal>

  <!-- Edit Ad Type Modal -->
  <BaseModal
    v-model="showEditAdTypeModal"
    title="Edit Ad Type"
    size="lg"
  >
    <form @submit.prevent="updateAdType" class="space-y-4">
      <BaseFormGroup label="Ad Type Name" input-id="edit-adtype-name" required>
        <BaseInput
          id="edit-adtype-name"
          v-model="editedAdType.name"
          placeholder="Enter ad type name"
          required
        />
      </BaseFormGroup>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <BaseFormGroup label="Width" input-id="edit-adtype-width">
          <BaseInput
            id="edit-adtype-width"
            v-model="editedAdType.width"
            type="number"
            step="0.01"
            min="0"
            placeholder="Enter width"
          />
        </BaseFormGroup>

        <BaseFormGroup label="Height" input-id="edit-adtype-height">
          <BaseInput
            id="edit-adtype-height"
            v-model="editedAdType.height"
            type="number"
            step="0.01"
            min="0"
            placeholder="Enter height"
          />
        </BaseFormGroup>
      </div>

      <BaseFormGroup label="Cost ($)" input-id="edit-adtype-cost">
        <BaseInput
          id="edit-adtype-cost"
          v-model="editedAdType.cost"
          type="number"
          step="0.1"
          min="0"
          placeholder="Enter cost"
        />
      </BaseFormGroup>

      <BaseFormGroup label="Term (months)" input-id="edit-adtype-term-months">
        <BaseInput
          id="edit-adtype-term-months"
          v-model="editedAdType.termMonths"
          type="number"
          step="0.1"
          min="0"
          placeholder="Enter term in months"
        />
      </BaseFormGroup>

      <BaseFormGroup label="Start Date" input-id="edit-adtype-start-date">
        <BaseInput
          id="edit-adtype-start-date"
          v-model="editedAdType.startDate"
          type="date"
        />
      </BaseFormGroup>

      <BaseFormGroup label="End Date" input-id="edit-adtype-end-date">
        <BaseInput
          id="edit-adtype-end-date"
          v-model="editedAdType.endDate"
          type="date"
        />
      </BaseFormGroup>

      <BaseFormGroup label="Deadline Date" input-id="edit-adtype-deadline-date">
        <BaseInput
          id="edit-adtype-deadline-date"
          v-model="editedAdType.deadlineDate"
          type="date"
        />
      </BaseFormGroup>

      <div class="flex justify-end space-x-3 pt-4">
        <BaseButton
          type="button"
          variant="secondary"
          @click="showEditAdTypeModal = false"
        >
          Cancel
        </BaseButton>
        <BaseButton
          type="submit"
          variant="primary"
          :loading="updateLoading"
          :disabled="updateLoading"
        >
          Update Ad Type
        </BaseButton>
      </div>
    </form>
  </BaseModal>

  <!-- Delete Confirmation Modal -->
  <BaseModal
    v-model="showDeleteConfirmModal"
    title="Confirm Delete"
    size="sm"
  >
    <div class="space-y-4">
      <p class="text-gray-700 dark:text-gray-300">Are you sure you want to delete the ad type "{{ adTypeToDelete?.name }}"?</p>

      <div v-if="community?.selectedAdTypeId === adTypeToDelete?.id" class="p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-md">
        <p class="text-red-600 dark:text-red-400 text-sm font-medium">
          <strong>Warning:</strong> This is currently the selected ad type for this community.
        </p>
      </div>

      <div class="flex justify-end space-x-3 pt-4">
        <BaseButton
          type="button"
          variant="secondary"
          @click="showDeleteConfirmModal = false"
        >
          Cancel
        </BaseButton>
        <BaseButton
          variant="danger"
          @click="deleteAdType"
          :loading="updateLoading"
          :disabled="updateLoading"
        >
          Delete Ad Type
        </BaseButton>
      </div>
    </div>
  </BaseModal>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import communityService from '@/services/community.service';
import { format, parseISO } from 'date-fns';

// UI Components
import BaseCard from '@/components/data-display/BaseCard.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseSkeletonLoader from '@/components/data-display/BaseSkeletonLoader.vue';
import BaseModal from '@/components/overlays/BaseModal.vue';

// Form Components
import BaseInput from '@/components/form/BaseInput.vue';
import BaseTextarea from '@/components/form/BaseTextarea.vue';
import BaseFormGroup from '@/components/form/BaseFormGroup.vue';

const router = useRouter();
const route = useRoute();

// State with default values to prevent "undefined" errors
const community = ref({
      name: '',
      address: '',
      city: '',
      state: '',
      phone: '',
      spaces: '',
      adSpecialistName: '',
      adSpecialistEmail: '',
      adSpecialistPhone: '',
      newsletterLink: '',
      generalNotes: '',
      isActive: false,
      selectedAdTypeId: null
    });
    const adTypes = ref([]);
    const loading = ref(true);
    const adTypesLoading = ref(true);
    const error = ref(null);
    const updateLoading = ref(false);

    // Modal states
    const showEditModal = ref(false);
    const showAdSpecialistModal = ref(false);
    const showCreateAdTypeModal = ref(false);
    const showEditAdTypeModal = ref(false);
    const showDeleteConfirmModal = ref(false);

    // Edit objects
    const editedCommunity = reactive({});
    const editedAdSpecialist = reactive({});
    const editedAdType = reactive({});
    const adTypeToDelete = ref(null);

    // Get community ID from route
    const communityId = computed(() => route.params.id);

    // Methods
    const loadCommunity = async () => {
      loading.value = true;
      error.value = null;

      try {
        console.log('Fetching community ID:', communityId.value);
        const data = await communityService.getCommunityById(communityId.value);
        console.log('Response from API:', data);

        // Handle empty response more gracefully
        if (!data) {
          console.warn('Community data is empty or null, using default values');
          community.value = {
            name: 'Community Not Found',
            address: '',
            city: '',
            state: '',
            phone: '',
            spaces: '',
            adSpecialistName: '',
            adSpecialistEmail: '',
            adSpecialistPhone: '',
            newsletterLink: '',
            generalNotes: '',
            isActive: false,
            selectedAdTypeId: null
          };
          error.value = 'Community not found. It may have been deleted or is not accessible.';
        } else {
          // Merge data with default values to ensure all properties exist
          community.value = {
            name: '',
            address: '',
            city: '',
            state: '',
            phone: '',
            spaces: '',
            adSpecialistName: '',
            adSpecialistEmail: '',
            adSpecialistPhone: '',
            newsletterLink: '',
            generalNotes: '',
            isActive: false,
            selectedAdTypeId: null,
            ...data // Spread the API data over defaults
          };

          // Load ad types only if community data was successfully loaded
          loadAdTypes();
        }
      } catch (err) {
        console.error('Failed to load community:', err);
        error.value = 'Failed to load community. Please try again.';

        // Reset community to default values on error to prevent undefined errors
        community.value = {
          name: '',
          address: '',
          city: '',
          state: '',
          phone: '',
          spaces: '',
          adSpecialistName: '',
          adSpecialistEmail: '',
          adSpecialistPhone: '',
          newsletterLink: '',
          generalNotes: '',
          isActive: false,
          selectedAdTypeId: null
        };
      } finally {
        loading.value = false;
      }
    };

    const loadAdTypes = async () => {
      adTypesLoading.value = true;

      try {
        const data = await communityService.getAdTypes(communityId.value);
        // Ensure adTypes is always an array, even if API returns null/undefined
        adTypes.value = data || [];
      } catch (err) {
        console.error('Failed to load ad types:', err);
        // Reset to empty array on error to prevent undefined errors
        adTypes.value = [];
      } finally {
        adTypesLoading.value = false;
      }
    };

    const goBack = () => {
      router.push({ name: 'communities-list' });
    };

    const toggleActiveStatus = async () => {
      updateLoading.value = true;
      try {
        // Safely access isActive with a default value
        const currentStatus = community.value?.isActive || false;
        const newStatus = !currentStatus;

        // If trying to activate, check if the community has ad types and a selected ad type
        if (newStatus) {
          // Check if the community has ad types
          if (!adTypes.value || adTypes.value.length === 0) {
            alert('Cannot activate a community without ad types. Please add at least one ad type first.');
            updateLoading.value = false;
            return;
          }

          // Check if the community has a selected ad type
          if (!community.value?.selectedAdTypeId) {
            alert('Cannot activate a community without a selected ad type. Please select an ad type first.');
            updateLoading.value = false;
            return;
          }
        }

        const updated = await communityService.setActiveStatus(communityId.value, newStatus);

        if (updated) {
          // Merge with existing data to preserve defaults for any missing properties
          community.value = {
            ...community.value,
            ...updated
          };
        }
      } catch (err) {
        console.error('Failed to update community status:', err);
        alert('Failed to update community status: ' + (err.response?.data?.message || err.message));
      } finally {
        updateLoading.value = false;
      }
    };

    const updateCommunity = async () => {
      updateLoading.value = true;

      try {
        console.log('Updating community with data:', editedCommunity);
        const updated = await communityService.updateCommunity(communityId.value, editedCommunity);

        if (updated) {
          console.log('Community updated successfully:', updated);
          // Merge with existing data to preserve defaults for any missing properties
          community.value = {
            ...community.value,
            ...updated
          };
          showEditModal.value = false;
        } else {
          console.error('No data returned from update operation');
          throw new Error('Failed to update community: No data returned');
        }
      } catch (err) {
        console.error('Failed to update community:', err);
        // Provide more detailed error message
        let errorMessage = 'Failed to update community';
        if (err.response?.data?.message) {
          errorMessage += ': ' + err.response.data.message;
        } else if (err.message) {
          errorMessage += ': ' + err.message;
        }
        alert(errorMessage);
      } finally {
        updateLoading.value = false;
      }
    };

    const updateAdSpecialist = async () => {
      updateLoading.value = true;

      try {
        // Prepare the update data with just the specialist fields
        const updateData = {
          adSpecialistName: editedAdSpecialist.name || '',
          adSpecialistEmail: editedAdSpecialist.email || '',
          adSpecialistPhone: editedAdSpecialist.phone || ''
        };

        console.log('Updating ad specialist with data:', updateData);
        const updated = await communityService.updateCommunity(communityId.value, updateData);

        if (updated) {
          console.log('Ad specialist updated successfully:', updated);
          // Merge with existing data to preserve defaults for any missing properties
          community.value = {
            ...community.value,
            ...updated
          };
          showAdSpecialistModal.value = false;
        } else {
          console.error('No data returned from update ad specialist operation');
          throw new Error('Failed to update ad specialist: No data returned');
        }
      } catch (err) {
        console.error('Failed to update ad specialist:', err);
        // Provide more detailed error message
        let errorMessage = 'Failed to update ad specialist';
        if (err.response?.data?.message) {
          errorMessage += ': ' + err.response.data.message;
        } else if (err.message) {
          errorMessage += ': ' + err.message;
        }
        alert(errorMessage);
      } finally {
        updateLoading.value = false;
      }
    };

    const selectAdType = async (adTypeId) => {
      updateLoading.value = true;
      try {
        if (!adTypeId) {
          throw new Error('Ad Type ID is required');
        }

        console.log(`Selecting ad type ${adTypeId} for community ${communityId.value}`);
        const updated = await communityService.selectAdType(communityId.value, adTypeId);

        if (updated) {
          console.log('Ad type selected successfully:', updated);
          // Merge with existing data to preserve defaults for any missing properties
          community.value = {
            ...community.value,
            ...updated
          };

          // Reload to get the updated relationship
          loadCommunity();
        } else {
          console.error('No data returned from select ad type operation');
          throw new Error('Failed to select ad type: No data returned');
        }
      } catch (err) {
        console.error('Failed to select ad type:', err);
        // Provide more detailed error message
        let errorMessage = 'Failed to select ad type';
        if (err.response?.data?.message) {
          errorMessage += ': ' + err.response.data.message;
        } else if (err.message) {
          errorMessage += ': ' + err.message;
        }
        alert(errorMessage);
      } finally {
        updateLoading.value = false;
      }
    };

    const editAdType = (adType) => {
      if (!adType) {
        console.error('Cannot edit undefined ad type');
        return;
      }

      // Reset the edited ad type first to clear any previous values
      Object.assign(editedAdType, {
        id: '',
        name: '',
        width: '',
        height: '',
        cost: '',
        startDate: '',
        endDate: '',
        deadlineDate: '',
        termMonths: ''
      });

      // Clone the ad type to avoid modifying the original
      // Use optional chaining and default values to prevent undefined errors
      editedAdType.id = adType?.id || '';
      editedAdType.name = adType?.name || '';
      editedAdType.width = adType?.width || '';
      editedAdType.height = adType?.height || '';
      editedAdType.cost = adType?.cost || '';
      editedAdType.startDate = adType?.startDate || '';
      editedAdType.endDate = adType?.endDate || '';
      editedAdType.deadlineDate = adType?.deadlineDate || '';
      editedAdType.termMonths = adType?.termMonths || '';

      showEditAdTypeModal.value = true;
    };

    const createAdType = async () => {
      updateLoading.value = true;

      try {
        // Validate required fields
        if (!editedAdType.name) {
          throw new Error('Ad type name is required');
        }

        console.log('Creating ad type with data:', editedAdType);
        const result = await communityService.createAdType(communityId.value, editedAdType);

        if (result) {
          console.log('Ad type created successfully:', result);
          showCreateAdTypeModal.value = false;
          // Reset the form after successful creation
          Object.assign(editedAdType, {
            id: '',
            name: '',
            width: '',
            height: '',
            cost: '',
            startDate: '',
            endDate: '',
            deadlineDate: '',
            termMonths: ''
          });
          // Reload ad types to show the new one
          loadAdTypes();
        } else {
          console.error('No data returned from create ad type operation');
          throw new Error('Failed to create ad type: No data returned');
        }
      } catch (err) {
        console.error('Failed to create ad type:', err);
        // Provide more detailed error message
        let errorMessage = 'Failed to create ad type';
        if (err.response?.data?.message) {
          errorMessage += ': ' + err.response.data.message;
        } else if (err.message) {
          errorMessage += ': ' + err.message;
        }
        alert(errorMessage);
      } finally {
        updateLoading.value = false;
      }
    };

    const updateAdType = async () => {
      updateLoading.value = true;

      try {
        // Validate required fields
        if (!editedAdType.id) {
          throw new Error('Ad type ID is missing');
        }

        if (!editedAdType.name) {
          throw new Error('Ad type name is required');
        }

        console.log('Updating ad type with data:', editedAdType);
        const result = await communityService.updateAdType(editedAdType.id, editedAdType);

        if (result) {
          console.log('Ad type updated successfully:', result);
          showEditAdTypeModal.value = false;
          // Reload ad types to show the updated one
          loadAdTypes();
        } else {
          console.error('No data returned from update ad type operation');
          throw new Error('Failed to update ad type: No data returned');
        }
      } catch (err) {
        console.error('Failed to update ad type:', err);
        // Provide more detailed error message
        let errorMessage = 'Failed to update ad type';
        if (err.response?.data?.message) {
          errorMessage += ': ' + err.response.data.message;
        } else if (err.message) {
          errorMessage += ': ' + err.message;
        }
        alert(errorMessage);
      } finally {
        updateLoading.value = false;
      }
    };

    const confirmDeleteAdType = (adType) => {
      if (!adType) {
        console.error('Cannot delete undefined ad type');
        return;
      }
      adTypeToDelete.value = adType;
      showDeleteConfirmModal.value = true;
    };

    const deleteAdType = async () => {
      updateLoading.value = true;

      try {
        // Validate that we have an ad type to delete
        if (!adTypeToDelete.value || !adTypeToDelete.value.id) {
          throw new Error('No ad type selected for deletion');
        }

        // Store the ID before deletion for comparison later
        const deletedAdTypeId = adTypeToDelete.value.id;

        const result = await communityService.deleteAdType(deletedAdTypeId);

        if (result) {
          showDeleteConfirmModal.value = false;
          adTypeToDelete.value = null;
          loadAdTypes();

          // If this was the selected ad type, reload the community to update the UI
          if (community.value?.selectedAdTypeId === deletedAdTypeId) {
            loadCommunity();
          }
        } else {
          throw new Error('Failed to delete ad type: No confirmation received');
        }
      } catch (err) {
        console.error('Failed to delete ad type:', err);
        alert('Failed to delete ad type: ' + (err.response?.data?.message || err.message));
      } finally {
        updateLoading.value = false;
      }
    };

    // Format date for display
    const formatDate = (dateString) => {
      if (!dateString) return 'Not set';
      try {
        // Parse the date string to a Date object
        const date = typeof dateString === 'string' ? parseISO(dateString) : new Date(dateString);

        // Check if the date is valid before formatting
        if (isNaN(date.getTime())) {
          console.warn('Invalid date:', dateString);
          return 'Invalid date';
        }

        // Format the date as 'MMM d, yyyy' (e.g., 'Jan 1, 2023')
        return format(date, 'MMM d, yyyy');
      } catch (err) {
        console.error('Error formatting date:', err);
        return 'Invalid date'; // Return a user-friendly message if parsing fails
      }
    };

    // Format phone number for display
    const formatPhone = (phone) => {
      if (!phone) return '';

      try {
        // Convert to string in case a number is passed
        const phoneStr = String(phone);

        // Basic US phone number formatting
        const cleaned = phoneStr.replace(/\D/g, '');

        // Check if we have enough digits for a US phone number
        if (cleaned.length < 10) {
          return phoneStr; // Return original if not enough digits
        }

        const match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);

        if (match) {
          return '(' + match[1] + ') ' + match[2] + '-' + match[3];
        }

        return phoneStr; // Return original if format doesn't match
      } catch (err) {
        console.error('Error formatting phone number:', err);
        return String(phone); // Return original as string if any error occurs
      }
    };

    // Initialize component
    onMounted(() => {
      loadCommunity();
    });

    // Method to prepare the community edit form
    const prepareEditCommunity = () => {
      // Reset the form first
      Object.assign(editedCommunity, {
        name: '',
        address: '',
        city: '',
        state: '',
        phone: '',
        spaces: '',
        newsletterLink: '',
        generalNotes: '',
        isActive: false
      });

      // Copy values from the community object with fallbacks
      if (community.value) {
        Object.assign(editedCommunity, {
          name: community.value.name || '',
          address: community.value.address || '',
          city: community.value.city || '',
          state: community.value.state || '',
          phone: community.value.phone || '',
          spaces: community.value.spaces || '',
          newsletterLink: community.value.newsletterLink || '',
          generalNotes: community.value.generalNotes || '',
          isActive: community.value.isActive || false
        });
      }

      showEditModal.value = true;
    };

    // Method to prepare the ad specialist edit form
    const prepareEditAdSpecialist = () => {
      // Reset the form first
      Object.assign(editedAdSpecialist, {
        name: '',
        email: '',
        phone: ''
      });

      // Copy values from the community object with fallbacks
      if (community.value) {
        Object.assign(editedAdSpecialist, {
          name: community.value.adSpecialistName || '',
          email: community.value.adSpecialistEmail || '',
          phone: community.value.adSpecialistPhone || ''
        });
      }

      showAdSpecialistModal.value = true;
    };


</script>

<style scoped>
/* Animation for card transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

/* Animation for table rows */
.row-enter-active,
.row-leave-active {
  transition: all 0.3s ease;
}

.row-enter-from,
.row-leave-to {
  opacity: 0;
  transform: translateX(-10px);
}

/* Hover effects for cards */
.card-hover-effect {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.card-hover-effect:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}
</style>