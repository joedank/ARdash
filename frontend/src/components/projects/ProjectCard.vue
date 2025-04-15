<template>
  <div 
    :class="[
      'project-card rounded-lg shadow-sm border p-4 cursor-pointer transition-all duration-200',
      'hover:shadow-md active:scale-[0.99]',
      statusColorClass
    ]"
    @click="$emit('click')"
  >
    <!-- Header: Client Info and Status -->
    <div class="flex justify-between items-start mb-3">
      <div>
        <h3 class="font-semibold text-gray-900 dark:text-gray-100">
          {{ getClientName(project.client) }}
        </h3>
        <p class="text-sm text-gray-600 dark:text-gray-400">
          {{ project.client?.company }}
        </p>
      </div>
      <BaseBadge
        :variant="statusVariant"
        size="sm"
      >
        {{ project.status }}
      </BaseBadge>
    </div>

    <!-- Project Type and Scope -->
    <div class="mb-3">
      <div class="flex items-center text-sm text-gray-600 dark:text-gray-400 mb-1">
        <BaseIcon
          :name="typeIcon"
          class="mr-2"
        />
        {{ typeLabel }}
      </div>
      <p 
        v-if="project.scope"
        class="text-sm text-gray-700 dark:text-gray-300 line-clamp-2"
      >
        {{ project.scope }}
      </p>
    </div>

    <!-- Address -->
    <div class="flex items-start text-sm text-gray-600 dark:text-gray-400">
      <BaseIcon
        name="map-pin"
        class="mr-2 mt-1 flex-shrink-0"
      />
      <p class="line-clamp-2">
        {{ formatAddress() }}
      </p>
    </div>

    <!-- Estimate Reference -->
    <div 
      v-if="project.estimate"
      class="mt-3 pt-3 border-t border-gray-200 dark:border-gray-700"
    >
      <div class="text-sm text-gray-600 dark:text-gray-400">
        Estimate: {{ project.estimate.estimateNumber }}
      </div>
    </div>

    <!-- Color Overlay -->
    <div 
      class="absolute top-0 left-0 right-0 bottom-0 bg-current opacity-5 pointer-events-none"
      aria-hidden="true"
    ></div>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import BaseBadge from '@/components/data-display/BaseBadge.vue';
import BaseIcon from '@/components/base/BaseIcon.vue';

const props = defineProps({
  project: {
    type: Object,
    required: true
  }
});

// Emit click event
defineEmits(['click']);

// Status color mapping
const statusColorClass = computed(() => {
  switch (props.project.type) {
    case 'assessment':
      return 'bg-red-50 dark:bg-red-900/10 border-red-100 dark:border-red-800/20';
    case 'active':
      return props.project.status === 'completed'
        ? 'bg-green-50 dark:bg-green-900/10 border-green-100 dark:border-green-800/20'
        : 'bg-yellow-50 dark:bg-yellow-900/10 border-yellow-100 dark:border-yellow-800/20';
    default:
      return 'bg-gray-50 dark:bg-gray-900/10 border-gray-100 dark:border-gray-800/20';
  }
});

// Status badge variant
const statusVariant = computed(() => {
  switch (props.project.status) {
    case 'pending': return 'warning';
    case 'in_progress': return 'info';
    case 'completed': return 'success';
    case 'rejected': return 'danger';
    case 'upcoming': return 'primary';
    case 'on_hold': return 'error';
    default: return 'default';
  }
});

// Project type icon and label
const typeIcon = computed(() => 
  props.project.type === 'assessment' ? 'clipboard-check' : 'tool'
);

const typeLabel = computed(() => 
  props.project.type === 'assessment' ? 'Assessment' : 'Active Job'
);

// Format address for display
const formatAddress = (address) => {
  // First try: Directly provided address object
  if (address) {
    return formatAddressParts(address);
  }
  
  // Second try: Project's address object (through direct association)
  if (props.project.address) {
    return formatAddressParts(props.project.address);
  }
  
  // Third try: Look up address by ID in client addresses array (use camelCase addressId)
  if (props.project.addressId && props.project.client?.addresses && props.project.client.addresses.length > 0) {
    const selectedAddress = props.project.client.addresses.find(addr => addr.id === props.project.addressId);
    if (selectedAddress) {
      return formatAddressParts(selectedAddress);
    }
  }
  
  // Fourth try: Use first client address if available (use camelCase isPrimary)
  if (props.project.client?.addresses && props.project.client.addresses.length > 0) {
    const primaryAddress = props.project.client.addresses.find(addr => addr.isPrimary) || props.project.client.addresses[0];
    return formatAddressParts(primaryAddress);
  }
  
  // Fallback
  return 'No address provided';
};

// Helper to format address parts (use camelCase)
const formatAddressParts = (address) => {
  const parts = [
    address.streetAddress || address.street, // Use streetAddress, fallback to street if needed
    address.city,
    address.state,
    address.postalCode || address.zipCode // Use postalCode, fallback to zipCode if needed
  ].filter(Boolean);
  
  return parts.length > 0 ? parts.join(', ') : 'Address details incomplete';
};

// Get client name with fallback options
const getClientName = (client) => {
  if (!client) return 'Unknown Client';
  
  return client.displayName || client.name || 'Unknown Client'; // Use camelCase displayName
};
</script>

<style scoped>
.project-card {
  position: relative;
  isolation: isolate;
}
</style>