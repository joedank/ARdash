<template>
  <BaseCard title="Work Types Knowledge Base" :loading="loading">
    <div v-if="error" class="text-red-600 dark:text-red-400">{{ error }}</div>
    <div v-else class="grid grid-cols-2 gap-4">
      <div class="flex flex-col items-center justify-center p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
        <span class="text-2xl font-bold text-blue-600 dark:text-blue-400">{{ stats.totalCount }}</span>
        <span class="text-sm text-gray-600 dark:text-gray-400">Total Work Types</span>
      </div>
      <div class="flex flex-col items-center justify-center p-4 bg-green-50 dark:bg-green-900/20 rounded-lg">
        <span class="text-2xl font-bold text-green-600 dark:text-green-400">{{ stats.withCostsCount }}</span>
        <span class="text-sm text-gray-600 dark:text-gray-400">With Cost Data</span>
      </div>
    </div>
    <div class="mt-4 flex justify-between">
      <BaseButton variant="secondary" size="sm" @click="$router.push('/work-types')">
        View All
      </BaseButton>
      <BaseButton v-if="canManageWorkTypes" variant="primary" size="sm" @click="$router.push('/work-types/new')">
        Add New
      </BaseButton>
    </div>
  </BaseCard>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/store/auth';
import BaseCard from '@/components/data-display/BaseCard.vue';
import BaseButton from '@/components/base/BaseButton.vue';
import workTypesService from '@/services/work-types.service';

const router = useRouter();
const authStore = useAuthStore();

// Check if user can manage work types (admin or estimator_manager)
const canManageWorkTypes = computed(() => authStore.canManageWorkTypes);

// Data
const loading = ref(true);
const error = ref(null);
const stats = ref({
  totalCount: 0,
  withCostsCount: 0
});

// Fetch statistics
onMounted(async () => {
  try {
    const response = await workTypesService.getAllWorkTypes();
    if (response.success) {
      stats.value.totalCount = response.data.length;
      stats.value.withCostsCount = response.data.filter(wt => 
        wt.unitCostMaterial !== null || wt.unitCostLabor !== null
      ).length;
    } else {
      error.value = response.message;
    }
  } catch (err) {
    error.value = 'Failed to load work types data';
  } finally {
    loading.value = false;
  }
});
</script>