<template>
  <div class="space-y-4">
    <h3 class="text-lg font-semibold text-gray-900 dark:text-gray-100">Additional Information Needed</h3>
    
    <div class="text-sm text-gray-700 dark:text-gray-300">
      <p>The AI needs some additional information to generate an accurate estimate. Please provide the following:</p>
    </div>
    
    <!-- Required Measurements Section -->
    <div v-if="requiredMeasurements && requiredMeasurements.length > 0" class="bg-gray-50 dark:bg-gray-800/50 p-4 rounded-md border border-gray-200 dark:border-gray-700 mb-4">
      <h4 class="text-base font-medium text-gray-800 dark:text-gray-200 mb-3">Required Measurements</h4>
      
      <div v-for="(measurement, index) in requiredMeasurements" :key="`measurement-${index}`" class="mb-3 last:mb-0">
        <label :for="`measurement-${index}`" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">{{ measurement }}</label>
        <div class="flex items-center gap-2">
          <input
            :id="`measurement-${index}`"
            v-model="measurements[measurement]"
            type="text"
            class="w-full px-3 py-2 text-gray-700 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-300"
            placeholder="Enter value"
            :disabled="loading"
          />
        </div>
      </div>
    </div>
    
    <!-- Questions Section -->
    <div v-if="questions && questions.length > 0" class="bg-gray-50 dark:bg-gray-800/50 p-4 rounded-md border border-gray-200 dark:border-gray-700 mb-4">
      <h4 class="text-base font-medium text-gray-800 dark:text-gray-200 mb-3">Required Information</h4>
      
      <div v-for="(question, index) in questions" :key="`question-${index}`" class="mb-3 last:mb-0">
        <label :for="`question-${index}`" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">{{ question }}</label>
        <textarea
          :id="`question-${index}`"
          v-model="questionAnswers[question]"
          class="w-full px-3 py-2 text-gray-700 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-300"
          rows="2"
          placeholder="Enter your answer"
          :disabled="loading"
        ></textarea>
      </div>
    </div>
    
    <!-- Form Actions -->
    <div class="flex justify-end mt-4">
      <BaseButton
        variant="primary"
        size="md"
        :loading="loading"
        :disabled="!isValid"
        @click="submitForm"
      >
        {{ loading ? 'Processing...' : 'Continue' }}
      </BaseButton>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue';
import BaseButton from '@/components/base/BaseButton.vue';

const props = defineProps({
  requiredMeasurements: {
    type: Array,
    default: () => []
  },
  questions: {
    type: Array,
    default: () => []
  },
  loading: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['submit']);

const measurements = ref({});
const questionAnswers = ref({});

// Initialize measurements and questions when props change
watch(() => props.requiredMeasurements, (newMeasurements) => {
  // Keep existing values and add new ones
  const newMeasurementsObj = { ...measurements.value };
  newMeasurements.forEach(measurement => {
    if (!newMeasurementsObj[measurement]) {
      newMeasurementsObj[measurement] = '';
    }
  });
  measurements.value = newMeasurementsObj;
}, { immediate: true });

watch(() => props.questions, (newQuestions) => {
  // Keep existing values and add new ones
  const newAnswersObj = { ...questionAnswers.value };
  newQuestions.forEach(question => {
    if (!newAnswersObj[question]) {
      newAnswersObj[question] = '';
    }
  });
  questionAnswers.value = newAnswersObj;
}, { immediate: true });

// Validation
const isValid = computed(() => {
  // Check if all measurements have values
  const allMeasurementsProvided = props.requiredMeasurements.every(
    measurement => measurements.value[measurement]?.trim()
  );
  
  // Check if all questions have answers
  const allQuestionsAnswered = props.questions.every(
    question => questionAnswers.value[question]?.trim()
  );
  
  return allMeasurementsProvided && allQuestionsAnswered;
});

// Form submission
const submitForm = () => {
  if (!isValid.value) return;
  
  emit('submit', {
    measurements: measurements.value,
    questionAnswers: questionAnswers.value
  });
};
</script>

<style scoped>
/* All styling now uses Tailwind classes */
</style>
