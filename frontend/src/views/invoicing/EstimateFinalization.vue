<template>
  <div class="container mx-auto px-4 py-6">
    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center h-64">
      <LoadingSpinner />
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 border border-red-200 rounded-md p-4">
      <div class="flex">
        <div class="flex-shrink-0">
          <ExclamationCircleIcon class="h-5 w-5 text-red-400" />
        </div>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-red-800">Error Loading Estimate</h3>
          <p class="mt-2 text-sm text-red-700">{{ error }}</p>
          <button @click="loadEstimate" class="mt-3 text-sm font-medium text-red-600 hover:text-red-500">
            Retry
          </button>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div v-else class="space-y-6">
      <div class="flex justify-between items-center">
        <h1 class="text-2xl font-bold text-gray-900">Finalize Estimate</h1>
        <div class="flex space-x-4">
          <button
            @click="saveEstimate"
            :disabled="saving"
            class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
          >
            {{ saving ? 'Saving...' : 'Save Estimate' }}
          </button>
        </div>
      </div>

      <!-- Assessment Data -->
      <div v-if="assessmentData" class="bg-white shadow rounded-lg p-6">
        <EstimateFromAssessment
          :assessment-data="assessmentData"
          @update:estimate="updateEstimate"
          :initial-estimate="estimate"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { toCamelCase, toSnakeCase } from '@/utils/casing';
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { LoadingSpinner, ExclamationCircleIcon } from '@heroicons/vue/outline'
import EstimateFromAssessment from '@/components/estimates/EstimateFromAssessment.vue'
import { estimateService } from '@/services/estimate.service'
import { assessmentService } from '@/services/assessment.service'

const route = useRoute()
const router = useRouter()
const loading = ref(true)
const saving = ref(false)
const error = ref(null)
const estimate = ref(null)
const assessmentData = ref(null)

const loadEstimate = async () => {
  loading.value = true
  error.value = null
  
  try {
    const estimateId = route.params.id
    const [estimateData, assessmentResult] = await Promise.all([
      estimateService.getEstimate(estimateId),
      assessmentService.getAssessmentForEstimate(estimateId)
    ])
    
    // Convert fetched data to camelCase
    estimate.value = toCamelCase(estimateData);
    assessmentData.value = toCamelCase(assessmentResult);
  } catch (err) {
    error.value = err.message || 'Failed to load estimate data'
  } finally {
    loading.value = false
  }
}

const updateEstimate = (updates) => {
  estimate.value = { ...estimate.value, ...updates }
}

const saveEstimate = async () => {
  saving.value = true
  try {
    // Convert estimate data to snake_case before sending
    const snakeCaseEstimate = toSnakeCase(estimate.value);
    await estimateService.updateEstimate(route.params.id, snakeCaseEstimate)
    router.push({ name: 'EstimatesList' })
  } catch (err) {
    error.value = err.message || 'Failed to save estimate'
  } finally {
    saving.value = false
  }
}

onMounted(loadEstimate)
</script>