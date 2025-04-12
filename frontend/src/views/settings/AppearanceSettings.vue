<template>
  <BaseCard variant="bordered">
    <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Appearance Settings</h3>
    
    <BaseAlert
      v-if="appearanceSuccess"
      variant="success"
      :message="appearanceSuccess"
      dismissible
      class="mb-4"
      @close="appearanceSuccess = ''"
    />
    
    <form @submit.prevent="saveAppearanceSettings">
      <div class="space-y-4 mb-6">
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Theme
          </label>
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div
              class="relative border rounded-lg p-4 cursor-pointer"
              :class="[
                appearanceForm.theme === 'dark' ? 
                  'border-indigo-500 dark:border-indigo-400 bg-indigo-50 dark:bg-indigo-900/30' : 
                  'border-gray-300 dark:border-gray-700'
              ]"
              @click="selectTheme('dark')"
            >
              <div class="h-16 bg-gray-900 rounded mb-2"></div>
              <div class="text-sm font-medium text-center text-gray-700 dark:text-gray-300">
                Dark Mode
              </div>
              <div v-if="appearanceForm.theme === 'dark'" class="absolute top-2 right-2 text-indigo-600 dark:text-indigo-400">
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                </svg>
              </div>
            </div>
            
            <div
              class="relative border rounded-lg p-4 cursor-pointer"
              :class="[
                appearanceForm.theme === 'light' ? 
                  'border-indigo-500 dark:border-indigo-400 bg-indigo-50 dark:bg-indigo-900/30' : 
                  'border-gray-300 dark:border-gray-700'
              ]"
              @click="selectTheme('light')"
            >
              <div class="h-16 bg-white border border-gray-200 rounded mb-2"></div>
              <div class="text-sm font-medium text-center text-gray-700 dark:text-gray-300">
                Light Mode
              </div>
              <div v-if="appearanceForm.theme === 'light'" class="absolute top-2 right-2 text-indigo-600 dark:text-indigo-400">
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                </svg>
              </div>
            </div>
            
            <div
              class="relative border rounded-lg p-4 cursor-pointer"
              :class="[
                appearanceForm.theme === 'system' ? 
                  'border-indigo-500 dark:border-indigo-400 bg-indigo-50 dark:bg-indigo-900/30' : 
                  'border-gray-300 dark:border-gray-700'
              ]"
              @click="selectTheme('system')"
            >
              <div class="h-16 bg-gradient-to-r from-gray-100 to-gray-900 rounded mb-2"></div>
              <div class="text-sm font-medium text-center text-gray-700 dark:text-gray-300">
                System Default
              </div>
              <div v-if="appearanceForm.theme === 'system'" class="absolute top-2 right-2 text-indigo-600 dark:text-indigo-400">
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                </svg>
              </div>
            </div>
          </div>
        </div>
        
        <BaseFormGroup
          label="Font Size"
          input-id="fontSize"
          helper-text="Adjust the base font size for the application"
        >
          <BaseRangeSlider
            id="fontSize"
            v-model="appearanceForm.fontSize"
            :min="12"
            :max="20"
            :step="1"
          >
            <template #suffix>{{ appearanceForm.fontSize }}px</template>
          </BaseRangeSlider>
        </BaseFormGroup>
        
        <BaseFormGroup
          label="Animation Speed"
          input-id="animationSpeed"
          helper-text="Control the speed of UI animations"
        >
          <BaseSelect
            id="animationSpeed"
            v-model="appearanceForm.animationSpeed"
            :options="animationOptions"
          />
        </BaseFormGroup>
      </div>
      
      <div class="flex justify-end">
        <BaseButton
          type="submit"
          variant="primary"
          :loading="appearanceLoading"
        >
          Save Appearance Settings
        </BaseButton>
      </div>
    </form>
  </BaseCard>
</template>

<script setup>
import { ref, reactive, watch } from 'vue';
import { useAuthStore } from '../../store/auth';
import ThemeService from '../../services/theme.service';
import BaseCard from '../../components/data-display/BaseCard.vue';
import BaseButton from '../../components/base/BaseButton.vue';
import BaseAlert from '../../components/feedback/BaseAlert.vue';
import BaseSelect from '../../components/form/BaseSelect.vue';
import BaseFormGroup from '../../components/form/BaseFormGroup.vue';
import BaseRangeSlider from '../../components/form/BaseRangeSlider.vue';

const authStore = useAuthStore();

// Appearance settings
const appearanceLoading = ref(false);
const appearanceSuccess = ref('');
const appearanceForm = reactive({
  theme: authStore.user?.theme_preference || 'dark',
  fontSize: 16,
  animationSpeed: 'normal'
});

// Animation options
const animationOptions = [
  { value: 'none', label: 'No Animation' },
  { value: 'slow', label: 'Slow' },
  { value: 'normal', label: 'Normal' },
  { value: 'fast', label: 'Fast' }
];

// Function to select theme
function selectTheme(theme) {
  appearanceForm.theme = theme;
  // Apply theme immediately for better UX
  ThemeService.applyTheme(theme);
}

// Form submission handler
async function saveAppearanceSettings() {
  appearanceLoading.value = true;
  
  try {
    console.log('Saving appearance settings with theme:', appearanceForm.theme);
    
    // Apply theme immediately for better UX
    ThemeService.applyTheme(appearanceForm.theme);
    
    // Save theme preference to backend
    const response = await authStore.updateThemePreference(appearanceForm.theme);
    console.log('Backend response:', response);
    
    // In a real app, you would also update other appearance settings
    // await updateOtherAppearanceSettings(appearanceForm);
    
    appearanceSuccess.value = 'Appearance settings updated successfully!';
  } catch (error) {
    console.error('Error updating appearance settings:', error);
  } finally {
    appearanceLoading.value = false;
  }
}

// Watch for theme changes in the form and apply immediately for preview
watch(() => appearanceForm.theme, (newTheme) => {
  ThemeService.applyTheme(newTheme);
});
</script>
