<template>
  <div class="project-detail min-h-screen">
    <!-- Alert Message -->
    <BaseAlert
      v-if="showAlert"
      :variant="alertVariant"
      :message="alertMessage"
      class="fixed top-4 left-1/2 transform -translate-x-1/2 z-50 shadow-lg"
      dismissible
      @close="showAlert = false"
    />

    <!-- Header -->
    <header class="static top-0 bg-white dark:bg-gray-800 z-10 border-b border-gray-200 dark:border-gray-700">
      <div class="p-4">
        <div class="flex justify-between items-center">
          <div>
            <h1 class="text-xl font-semibold">{{ project?.client?.displayName || project?.client?.name || 'Unknown Client' }}</h1>
            <p class="text-sm text-gray-600 dark:text-gray-400">
              {{ project?.client?.company }}
            </p>
            <p v-if="project?.client?.phone" class="text-sm text-gray-600 dark:text-gray-400 mt-1">
              <a
                :href="getPhoneUrl(project.client.phone)"
                class="flex items-center hover:text-blue-600 dark:hover:text-blue-400 transition-colors"
              >
                <BaseIcon name="phone" class="mr-1 h-4 w-4" />
                {{ formatPhoneNumber(project.client.phone) }}
              </a>
            </p>
          </div>
          <BaseBadge
            :variant="statusVariant"
            size="lg"
          >
            {{ project?.status }}
          </BaseBadge>
        </div>
        <div class="mt-2 text-sm text-gray-600 dark:text-gray-400">
          <a
            :href="getMapUrl(formatProjectAddress())"
            target="_blank"
            rel="noopener noreferrer"
            class="flex items-center hover:text-blue-600 dark:hover:text-blue-400 transition-colors"
          >
            <BaseIcon name="map-pin" class="mr-1 h-4 w-4" />
            {{ formatProjectAddress() }}
          </a>
        </div>
      </div>
    </header>

    <!-- SelectButton for state navigation - Only show for completed projects -->
    <div v-if="!loading && project?.status === 'completed'" class="p-4 flex justify-center">
      <SelectButton
        v-model="selectedStateView"
        :options="selectButtonOptions"
        optionLabel="label"
        optionValue="value"
        optionDisabled="disabled"
        dataKey="value"
        aria-labelledby="project-state-selector"
        class="w-full md:w-fit min-w-[300px]"
      >
        <template #option="slotProps">
          <div class="flex items-center px-3 py-2">
            <BaseIcon :name="slotProps.option.icon" class="mr-2" />
            <span>{{ slotProps.option.label }}</span>
          </div>
        </template>
      </SelectButton>
    </div>

    <!-- Conditionally Rendered Content Sections -->
    <div v-if="!loading" class="p-4 space-y-6">

      <!-- Assessment Content (Visible when 'assessment' is selected) -->
      <template v-if="selectedStateView === 'assessment'">
        <!-- Original Assessment Details (if viewing assessment state of an active job) -->
        <PreviousStateCard
          v-if="project.type === 'active' && assessmentData"
          :assessment-data="assessmentData"
          class="mb-6"
        />
        <!-- Assessment Checklist (if project is currently an assessment) -->
        <section v-if="project.type === 'assessment'" class="space-y-4">
          <h2 class="text-lg font-semibold">Assessment Checklist</h2>
          <AssessmentContent
            :project="project"
            v-model:condition="condition"
            v-model:measurements="measurements"
            v-model:materials="materials"
            v-model:workTypes="workTypes"
            @refresh-project="refreshProject"
            @photo-deleted="handlePhotoDeleted"
          />
        </section>
        
        <!-- Work Types Panel (if project has work types) -->
        <section v-if="project.type === 'assessment' && workTypes && workTypes.length > 0" class="space-y-4 mt-4">
          <WorkTypeSummary :ids="workTypes" />
        </section>
      </template>

      <!-- Estimate Content (Visible when 'estimate' is selected) -->
      <template v-if="selectedStateView === 'estimate' && project?.estimate">
        <section class="space-y-2">
          <div class="flex justify-between items-center">
            <h2 class="text-lg font-semibold">Linked Estimate</h2>
          <span
            class="px-2 py-0.5 text-xs rounded-full"
            :class="getEstimateStatusClass(project.estimate.status)"
          >
            {{ formatEstimateStatus(project.estimate.status) }}
          </span>
        </div>

        <!-- Estimate Items Table -->
        <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4">
          <h3 class="font-medium mb-2">Estimate #{{ getEstimateNumber() }}</h3>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
              <thead class="bg-gray-50 dark:bg-gray-700">
                <tr>
                  <th scope="col" class="px-3 py-2 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Item</th>
                  <th scope="col" class="px-3 py-2 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Qty</th>
                </tr>
              </thead>
              <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
                <tr v-for="(item, index) in getEstimateItems()" :key="index">
                  <td class="px-3 py-2 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                    <div>
                      {{ item.description }}
                      <p v-if="item.details" class="text-xs text-gray-500 dark:text-gray-400">{{ item.details }}</p>
                    </div>
                  </td>
                  <td class="px-3 py-2 whitespace-nowrap text-sm text-gray-900 dark:text-white text-right">{{ item.quantity }}</td>
                </tr>
              </tbody>

            </table>
          </div>
        </div>

        <!-- Additional Work Section -->
        <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4 mt-4">
          <h3 class="font-medium mb-2">Additional Work</h3>
          <BaseTextarea
            v-model="additionalWork"
            placeholder="Document any work performed outside the original estimate..."
            rows="4"
            class="mb-2"
          />
          <BaseButton
            variant="primary"
            size="sm"
            @click="saveAdditionalWork"
            :loading="savingAdditionalWork"
          >
            Save Notes
          </BaseButton>
        </div>
      </section>
      </template> <!-- End estimate view -->

      <!-- Active Job Content (Visible when 'active' is selected) -->
      <template v-if="selectedStateView === 'active'">
        <!-- Scope Section - Removed -->

        <!-- Project Scope Section (Line Item Photos) -->
        <section class="space-y-4">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-lg font-semibold">Project Scope</h2>
            <!-- Receipt Upload Button in place of the yellow box -->
            <div class="flex items-center">
              <BaseButton
                variant="secondary"
                size="sm"
                @click="showReceiptUpload = true"
              >
                <BaseIcon name="receipt" class="mr-1" />
                Add Receipt
              </BaseButton>
            </div>
          </div>

          <!-- Work Types Panel (if job has work types) -->
          <div v-if="project.assessment?.workTypes && project.assessment.workTypes.length > 0" class="mt-4">
            <WorkTypeSummary :ids="project.assessment.workTypes" />
          </div>

          <!-- Line Item Photos Component -->
          <EstimateItemPhotos
            v-if="!loading && project.id && project.estimate?.id"
            :projectId="project.id"
            :estimateId="project.estimate.id"
          />

          <!-- No estimate message -->
          <div
            v-else-if="!loading && !project.estimate"
            class="p-8 text-center bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700"
          >
            <i class="pi pi-exclamation-circle text-yellow-500 text-4xl mb-4"></i>
            <h3 class="text-xl font-medium mb-2">No Estimate Found</h3>
            <p class="text-gray-500 mb-4">This project doesn't have an associated estimate.</p>
          </div>

          <!-- Receipt Upload Modal -->
          <div v-if="showReceiptUpload" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black bg-opacity-75">
            <div class="bg-white dark:bg-gray-800 rounded-lg overflow-hidden max-w-md w-full">
              <!-- Modal Header -->
              <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center">
                <h3 class="text-lg font-medium">Upload Receipt</h3>
                <button @click="showReceiptUpload = false" class="text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300">
                  <i class="pi pi-times"></i>
                </button>
              </div>

              <!-- Modal Body -->
              <div class="p-4">
                <PhotoUploadSection
                  :project-id="project.id"
                  photo-type="receipt"
                  label="Upload receipt photos"
                  @photo-added="handleReceiptAdded"
                />

                <!-- Existing Receipts -->
                <div class="mt-4">
                  <h4 class="font-medium mb-2">Existing Receipts</h4>
                  <PhotoGrid
                    :photos="getPhotosByType('receipt')"
                    @update:photos="updatePhotosAfterDeletion"
                    @photo-deleted="handlePhotoDeleted"
                  />
                </div>
              </div>

              <!-- Modal Footer -->
              <div class="p-4 border-t border-gray-200 dark:border-gray-700 flex justify-end">
                <BaseButton @click="showReceiptUpload = false" variant="secondary" size="sm">
                  Close
                </BaseButton>
              </div>
            </div>
          </div>
        </section>
      </template> <!-- End active view -->
    </div> <!-- End conditional content wrapper -->

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center h-64">
      <BaseLoader />
    </div>

    <!-- Reject Assessment Modal - Only show when project data is loaded -->
    <RejectAssessmentModal
      v-if="project && project.id"
      :show="showRejectModal"
      :project-id="project.id"
      @close="showRejectModal = false"
      @rejected="handleRejection"
    />

    <!-- Action Bar -->
    <div
    class="static bottom-0 left-0 right-0 bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 p-4 flex justify-between z-10 mt-6"
    >
    <BaseButton
      v-if="project?.type === 'assessment'"
      variant="secondary"
      size="sm"
      @click="saveAssessment"
      :loading="saving"
    >
      Save Assessment
    </BaseButton>
    <div class="flex-1"></div>

    <!-- Assessment action buttons -->
    <div v-if="project?.type === 'assessment' && project?.status !== 'completed' && project?.status !== 'rejected'" class="flex space-x-2 mr-2">
      <!-- Reject Assessment button -->
      <BaseButton
        variant="danger"
        size="sm"
        @click="showRejectModal = true"
      >
        Reject
      </BaseButton>

      <!-- Convert to Job button -->
      <ConvertToJobButton
        :project="project"
        @conversion-complete="handleConversionComplete"
      />
    </div>

    <BaseButton
      v-if="project?.type === 'active' && project?.status !== 'completed'"
      variant="primary"
      size="sm"
      @click="updateStatus('completed')"
      :disabled="project?.status === 'completed'"
    >
      Mark Complete
    </BaseButton>
    </div>
  </div>
</template>

<script setup>
import { toCamelCase, toSnakeCase } from '@/utils/casing';
import { ref, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import PhotoUploadSection from '@/components/projects/PhotoUploadSection.vue';
import PhotoGrid from '@/components/projects/PhotoGrid.vue';
import AssessmentContent from '@/components/projects/AssessmentContent.vue';
import SelectButton from 'primevue/selectbutton';
import PreviousStateCard from '@/components/projects/PreviousStateCard.vue';
import ConvertToJobButton from '@/components/projects/ConvertToJobButton.vue';
import EstimateItemPhotos from '@/components/projects/EstimateItemPhotos.vue';
import projectsService from '@/services/projects.service';
import standardizedProjectsService from '@/services/standardized-projects.service';
import BaseBadge from '@/components/data-display/BaseBadge.vue';
import BaseTextarea from '@/components/form/BaseTextarea.vue';
import BaseIcon from '@/components/base/BaseIcon.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import BaseLoader from '@/components/feedback/BaseLoader.vue';
import BaseAlert from '@/components/feedback/BaseAlert.vue';
import RejectAssessmentModal from '@/components/projects/RejectAssessmentModal.vue';
import WorkTypeSummary from '@/components/projects/WorkTypeSummary.vue';

const route = useRoute();
const router = useRouter();
const loading = ref(true);
const saving = ref(false);
const project = ref(null);
const assessmentData = ref(null);
const selectedStateView = ref('active'); // Default to active view for active projects
const showReceiptUpload = ref(false); // Control receipt upload modal
const showRejectModal = ref(false); // Control reject assessment modal
const localPhotos = ref([]); // Added local photos reference

// Form data for assessment
const condition = ref({});
const measurements = ref({
  items: [{
    description: '',
    length: '',
    width: '',
    units: 'feet'
  }]
});
const materials = ref({
  items: [{ name: '', quantity: '' }]
});
const workTypes = ref([]); // Store work types for the assessment

// Status badge variant
const statusVariant = computed(() => {
  switch (project.value?.status) {
    case 'pending': return 'warning';
    case 'in_progress': return 'info';
    case 'completed': return 'success';
    case 'on_hold': return 'error';
    default: return 'default';
  }
});

// Determine the current stage of the project
const currentProjectStage = computed(() => {
  if (!project.value) return 'assessment';
  if (project.value.type === 'active') return 'active';
  if (project.value.estimate) return 'estimate'; // If estimate exists but not active, stage is estimate
  return 'assessment'; // Default to assessment
});

// Define options for the SelectButton, computed based on project state
const selectButtonOptions = computed(() => {
  const options = [
    { value: 'assessment', label: 'Assessment', icon: 'pi pi-search', disabled: false },
    { value: 'estimate', label: 'Estimate', icon: 'pi pi-file', disabled: !project.value?.estimate },
    { value: 'active', label: 'Active Job', icon: 'pi pi-briefcase', disabled: project.value?.type !== 'active' }
  ];
  // Ensure the current actual stage is never disabled
  const currentStage = currentProjectStage.value;
  const currentOption = options.find(opt => opt.value === currentStage);
  if (currentOption) {
    currentOption.disabled = false;
  }
  // If estimate exists, enable estimate button even if current stage is active
  if (project.value?.estimate && currentStage === 'active') {
      const estimateOption = options.find(opt => opt.value === 'estimate');
      if (estimateOption) estimateOption.disabled = false;
  }
  // If the project is an assessment that has been converted, disable assessment view?
  // Maybe keep assessment view enabled to see original details? Let's keep it enabled for now.

  return options;
});


// Missing variable declarations for alert functionality
const showAlert = ref(false);
const alertMessage = ref('');
const alertVariant = ref('info');
const savingAdditionalWork = ref(false);
const additionalWork = ref('');

// Format address parts for display
const formatAddressParts = (address) => {
  if (!address) return 'No address provided';

  const parts = [
    address.streetAddress || address.street,
    address.city,
    address.state,
    address.postalCode || address.zipCode
  ].filter(Boolean);

  return parts.length > 0 ? parts.join(', ') : 'Address details incomplete';
};

// Format address for display with fallback chain
const formatAddress = (address) => {
  return formatAddressParts(address);
};

// Multi-step fallback approach for project address resolution
const formatProjectAddress = () => {
  // First try: Direct project-address association
  if (project.value?.address) {
    return formatAddressParts(project.value.address);
  }

  // Second try: Look up by ID in client addresses array
  if (project.value?.address_id && project.value?.client?.addresses?.length > 0) {
    const selectedAddress = project.value.client.addresses.find(
      addr => addr.id === project.value.address_id
    );
    if (selectedAddress) {
      return formatAddressParts(selectedAddress);
    }
  }

  // Third try: Fall back to primary or first address
  if (project.value?.client?.addresses?.length > 0) {
    const primaryAddress = project.value.client.addresses.find(
      addr => addr.is_primary
    ) || project.value.client.addresses[0];
    return formatAddressParts(primaryAddress);
  }

  // Fallback message
  return 'No address provided';
};

// Generate a map URL from an address string
const getMapUrl = (address) => {
  if (!address || address === 'No address provided' || address === 'Address details incomplete') {
    return '#'; // Return non-functional link for empty addresses
  }

  // Create a properly formatted address string for the map URL
  const addressQuery = encodeURIComponent(address);

  // Universal maps URL that works on most platforms
  return `https://maps.google.com/maps?q=${addressQuery}`;
};

// Generate a phone URL for click-to-call functionality
const getPhoneUrl = (phoneNumber) => {
  if (!phoneNumber) return '#';

  // Remove any non-digit characters
  const cleanNumber = phoneNumber.replace(/\D/g, '');

  // Return tel: URL for click-to-call
  return `tel:${cleanNumber}`;
};

// Format phone number for display
const formatPhoneNumber = (phoneNumber) => {
  if (!phoneNumber) return '';

  // Remove any non-digit characters
  const cleaned = phoneNumber.replace(/\D/g, '');

  // Check if it's a US phone number (10 digits)
  if (cleaned.length === 10) {
    return `(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}`;
  }

  // If not a standard US number, return as is
  return phoneNumber;
};

// Format estimate status
const formatEstimateStatus = (status) => {
  if (!status) return 'Unknown';
  return status.charAt(0).toUpperCase() + status.slice(1).replace('_', ' ');
};

// Get estimate status CSS class
const getEstimateStatusClass = (status) => {
  switch (status) {
    case 'draft': return 'bg-gray-200 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
    case 'sent': return 'bg-blue-200 text-blue-800 dark:bg-blue-700 dark:text-blue-300';
    case 'accepted': return 'bg-green-200 text-green-800 dark:bg-green-700 dark:text-green-300';
    case 'declined': return 'bg-red-200 text-red-800 dark:bg-red-700 dark:text-red-300';
    case 'expired': return 'bg-yellow-200 text-yellow-800 dark:bg-yellow-700 dark:text-yellow-300';
    default: return 'bg-gray-200 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
  }
};

// Format number for currency display
const formatNumber = (value) => {
  if (value === undefined || value === null) return '0.00';
  return parseFloat(value).toFixed(2);
};

// Create a cached mapping of photos by type to prevent flicker
const photosByType = computed(() => {
  const mapping = {};

  if (localPhotos.value && localPhotos.value.length > 0) {
    // Group photos by type
    localPhotos.value.forEach(photo => {
      const type = photo.photo_type || 'other';
      if (!mapping[type]) mapping[type] = [];
      mapping[type].push(photo);
    });
  }

  return mapping;
});

// Get photos by type using the cached mapping
const getPhotosByType = (type) => {
  return photosByType.value[type] || [];
};
// Filter photos for specific assessment sections
const assessmentPhotos = computed(() => getPhotosByType('assessment'));



// Get all estimate items with proper fallbacks
const getEstimateItems = () => {
  if (!project.value?.estimate) return [];

  // Check for different possible item property names
  if (Array.isArray(project.value.estimate.items)) {
    return project.value.estimate.items;
  }

  // Check for alternative property name
  if (Array.isArray(project.value.estimate.estimateItems)) {
    return project.value.estimate.estimateItems;
  }

  console.log('Estimate structure:', project.value.estimate);
  return [];
};

// Get estimate number with fallbacks
const getEstimateNumber = () => {
  if (!project.value?.estimate) return 'No Estimate';

  // Log all properties of the estimate object to help diagnose issues
  console.log('Estimate properties:', Object.keys(project.value.estimate));

  // Try all possible property names for the estimate number
  const possibleProps = [
    'number',              // Standard property
    'estimate_number',     // Snake case version
    'estimateNumber',      // Camel case version
    'id',                  // Sometimes used as fallback
    'estimate_id',         // Another possible variant
    'estimateId'           // Another camel case variant
  ];

  // Try each property name
  for (const prop of possibleProps) {
    if (project.value.estimate[prop]) {
      console.log(`Found estimate number in property: ${prop}`);
      return project.value.estimate[prop];
    }
  }

  // If we have the estimate object but can't find the number, dump the entire object
  console.log('Complete estimate object:', project.value.estimate);

  // Last resort fallback
  return 'EST-' + (project.value.estimate.id || '?????');
};

// Calculate estimate subtotal with proper fallbacks
const getEstimateSubtotal = () => {
  if (!project.value?.estimate) return 0;

  // If subtotal is already available, use it
  if (project.value.estimate.subtotal) {
    return parseFloat(project.value.estimate.subtotal);
  }

  // Calculate from items
  const items = getEstimateItems();
  return items.reduce((sum, item) => {
    const amount = item.amount || (item.quantity * (item.rate || item.price));
    return sum + parseFloat(amount || 0);
  }, 0);
};

// Calculate tax total with proper fallbacks
const getEstimateTaxTotal = () => {
  if (!project.value?.estimate) return 0;

  // If tax_total is already available, use it
  if (project.value.estimate.tax_total) {
    return parseFloat(project.value.estimate.tax_total);
  }

  // Calculate tax based on subtotal and tax rate
  const subtotal = getEstimateSubtotal();
  const taxRate = parseFloat(project.value.estimate.tax_rate || 0) / 100;
  return subtotal * taxRate;
};

// Calculate total with proper fallbacks
const getEstimateTotal = () => {
  if (!project.value?.estimate) return 0;

  // If total is already available, use it
  if (project.value.estimate.total) {
    return parseFloat(project.value.estimate.total);
  }

  // Calculate from subtotal and tax
  const subtotal = getEstimateSubtotal();
  const taxTotal = getEstimateTaxTotal();
  return subtotal + taxTotal;
};

// Load project data
const loadProject = async () => {
  loading.value = true;
  try {
    console.log('Loading project data...');
    const response = await projectsService.getProject(route.params.id);

    if (!response.data) {
      console.error('No project data returned');
      return;
    }

    // Create a deep copy of the response data before converting to camelCase
    // This prevents Vue from tracking the conversion and creating reactivity issues
    const responseDataCopy = JSON.parse(JSON.stringify(response.data));
    const camelCaseProject = toCamelCase(responseDataCopy);

    console.log('Project data loaded (camelCase):', {
      id: camelCaseProject.id,
      type: camelCaseProject.type,
      status: camelCaseProject.status,
      photoCount: camelCaseProject.photos?.length || 0,
      photos: camelCaseProject.photos?.map(p => ({ // Log camelCase properties
        id: p.id,
        type: p.photoType,
        path: p.filePath
      }))
    });

    // Set the project value all at once to minimize reactivity triggers
    project.value = camelCaseProject;

    // Set local photos as a new array to avoid reactivity issues
    localPhotos.value = project.value.photos ? [...project.value.photos] : [];

    // Initialize inspection data from existing inspections
    if (project.value.inspections && project.value.inspections.length > 0) {
      // Process inspections to find the latest of each category
      const latestInspections = {};
      project.value.inspections.forEach(inspection => {
        if (!latestInspections[inspection.category] ||
            new Date(inspection.createdAt) > new Date(latestInspections[inspection.category].createdAt)) {
          latestInspections[inspection.category] = inspection;
        }
      });

      // Create deep copies of inspection data to avoid reactivity issues
      // and only set once to avoid triggering watches repeatedly
      const conditionData = latestInspections.condition?.content;
      const measurementsData = latestInspections.measurements?.content;
      const materialsData = latestInspections.materials?.content;

      // Only update if data exists and is different
      if (conditionData) {
      condition.value = JSON.parse(JSON.stringify(conditionData));
      }

      if (measurementsData) {
      measurements.value = JSON.parse(JSON.stringify(measurementsData));
      }

      if (materialsData) {
      materials.value = JSON.parse(JSON.stringify(materialsData));
      }
    
    // Load work types if available
    if (project.value.workTypes) {
      workTypes.value = Array.isArray(project.value.workTypes) 
        ? [...project.value.workTypes] 
        : [];
      console.log('Loaded work types:', workTypes.value);
    }
    }

    // If this is a job created from an assessment, fetch the assessment data and convert it
    if (project.value.assessmentId) { // Use assessmentId
      try {
        const assessmentResponse = await projectsService.getProject(project.value.assessmentId); // Use assessmentId
        assessmentData.value = toCamelCase(assessmentResponse.data); // Convert fetched assessment data
      } catch (error) {
        console.error('Failed to load assessment data:', error);
      }
    }

    // If this is an assessment that's been converted to a job, fetch the job data
    if (project.value.convertedToJobId) { // Use convertedToJobId
      console.log('This assessment has been converted to job:', project.value.convertedToJobId); // Use convertedToJobId
    }

    // Debug output for estimate structure (already camelCased)
    if (project.value.estimate) {
      console.log('Loaded estimate (camelCase):', project.value.estimate);
      console.log('Estimate items (camelCase):', project.value.estimate.items); // Should be items now
    }

    // Set additional work notes if they exist (use additionalWork)
    if (project.value.additionalWork) {
      additionalWork.value = project.value.additionalWork;
    }

    // Set the initial view based on the current stage
    selectedStateView.value = currentProjectStage.value;

    // Default to active view for active projects
    if (project.value?.type === 'active') {
      selectedStateView.value = 'active';
    }

  } catch (error) {
    console.error('Error loading project:', error);
  } finally {
    loading.value = false;
  }
};

// Save assessment data
const saveAssessment = async () => {
  saving.value = true;
  try {
    // Save condition
    await projectsService.addInspection(project.value.id,
      projectsService.formatInspectionData('condition', condition.value)
    );

    // Save measurements
    await projectsService.addInspection(project.value.id,
      projectsService.formatInspectionData('measurements', measurements.value)
    );

    // Save materials
    await projectsService.addInspection(project.value.id,
      projectsService.formatInspectionData('materials', materials.value)
    );
    
    // Save work types
    if (workTypes.value.length > 0 || (project.value.workTypes && project.value.workTypes.length > 0)) {
      await projectsService.updateWorkTypes(project.value.id, workTypes.value);
    }

    alertMessage.value = 'Assessment saved successfully';
    alertVariant.value = 'success';
    showAlert.value = true;

    await refreshProject();
  } catch (error) {
    console.error('Error saving assessment:', error);
    alertMessage.value = 'Error saving assessment';
    alertVariant.value = 'error';
    showAlert.value = true;
  } finally {
    saving.value = false;
  }
};

// Update project status
const updateStatus = async (status) => {
  try {
    await projectsService.updateStatus(project.value.id, status);

    // Show success message
    alertMessage.value = status === 'completed'
      ? 'Project marked as completed'
      : `Project status updated to ${status}`;
    alertVariant.value = 'success';
    showAlert.value = true;

    // Auto-hide alert after 3 seconds
    setTimeout(() => {
      showAlert.value = false;
    }, 3000);

    await refreshProject();
  } catch (error) {
    console.error('Error updating status:', error);

    // Show error message
    alertMessage.value = status === 'completed'
      ? 'Failed to mark project as completed'
      : 'Failed to update project status';
    alertVariant.value = 'danger';
    showAlert.value = true;
  }
};

// Save additional work notes
const saveAdditionalWork = async () => {
  savingAdditionalWork.value = true;
  try {
    await projectsService.updateAdditionalWork(project.value.id, additionalWork.value);

    // Show success message
    alertMessage.value = 'Additional work notes saved successfully';
    alertVariant.value = 'success';
    showAlert.value = true;

    // Auto-hide alert after 3 seconds
    setTimeout(() => {
      showAlert.value = false;
    }, 3000);

    // Refresh project data
    await refreshProject();
  } catch (error) {
    console.error('Error saving additional work:', error);

    // Show error message
    alertMessage.value = 'Failed to save additional work notes';
    alertVariant.value = 'danger';
    showAlert.value = true;
  } finally {
    savingAdditionalWork.value = false;
  }
};

// This section has been removed to fix the duplicate function declaration

// This section has been removed to fix the duplicate function declaration

const refreshProject = async () => {
  await loadProject();
};

// Update local photos when one is deleted
const updatePhotosAfterDeletion = (updatedPhotos) => {
  console.log('Updating local photos after deletion, new count:', updatedPhotos.length);
  localPhotos.value = [...updatedPhotos];
};

// Handle photo added
const handlePhotoAdded = async () => {
  console.log('Photo added, refreshing data...');
  await refreshProject();
};

// Handle photo deletion
const handlePhotoDeleted = async (photoId) => {
  try {
    console.log('Photo deleted with ID:', photoId);

    // Filter out the deleted photo locally
    localPhotos.value = localPhotos.value.filter(p => p.id !== photoId);

    // Show success message
    alertMessage.value = 'Photo deleted successfully';
    alertVariant.value = 'success';
    showAlert.value = true;

    // Auto-hide alert after 3 seconds
    setTimeout(() => {
      showAlert.value = false;
    }, 3000);
  } catch (error) {
    console.error('Error handling photo deletion:', error);

    // Show error message
    alertMessage.value = 'Failed to update project after photo deletion';
    alertVariant.value = 'danger';
    showAlert.value = true;
  }
};

// Handle conversion to job
const handleConversionComplete = (newJobId) => {
  // Redirect to the new job
  router.push(`/projects/${newJobId}`);
};

// Handle assessment rejection
const handleRejection = async (rejectedProject) => {
  // Show success message
  alertMessage.value = 'Assessment has been rejected';
  alertVariant.value = 'success';
  showAlert.value = true;

  // Auto-hide alert after 3 seconds
  setTimeout(() => {
    showAlert.value = false;
  }, 3000);

  // Update local project data with the rejected project
  if (rejectedProject) {
    project.value = rejectedProject;
  } else {
    // If rejected project wasn't returned, refresh the data
    await refreshProject();
  }
};

// Handle receipt upload
const handleReceiptAdded = async () => {
  await handlePhotoAdded();
  showReceiptUpload.value = false;
};

// Load project on mount
onMounted(() => {
  loadProject();
});
</script>

<style scoped>
.pb-safe-area {
  padding-bottom: calc(env(safe-area-inset-bottom, 0px) + 5rem);
}
</style>
