<template>
  <BaseCard variant="bordered">
    <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">System Settings</h3>
    <p class="text-gray-600 dark:text-gray-400 mb-6">Configure system-wide settings and defaults</p>
    
    <form @submit.prevent="saveSystemSettings">
      <div class="space-y-6 mb-6">
        <div>
          <h4 class="font-medium text-gray-800 dark:text-white mb-3">General Settings</h4>
          <div class="space-y-4">
            <BaseFormGroup
              label="Site Name"
              input-id="siteName"
              helper-text="Name displayed in browser title and emails"
            >
              <BaseInput
                id="siteName"
                v-model="systemForm.siteName"
                placeholder="My Application"
              />
            </BaseFormGroup>
            
            <BaseFormGroup
              label="Default Language"
              input-id="defaultLanguage"
              helper-text="Default language for new users"
            >
              <BaseSelect
                id="defaultLanguage"
                v-model="systemForm.defaultLanguage"
                :options="languageOptions"
              />
            </BaseFormGroup>
          </div>
        </div>
        
        <div>
          <h4 class="font-medium text-gray-800 dark:text-white mb-3">Security Defaults</h4>
          <div class="space-y-4">
            <BaseFormGroup
              label="Password Complexity"
              input-id="passwordComplexity"
              helper-text="Minimum requirements for user passwords"
            >
              <BaseSelect
                id="passwordComplexity"
                v-model="systemForm.passwordComplexity"
                :options="passwordComplexityOptions"
              />
            </BaseFormGroup>
            
            <div class="flex items-center justify-between">
              <div>
                <span class="text-gray-700 dark:text-gray-300">Require 2FA for all users</span>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  Force two-factor authentication for all accounts
                </p>
              </div>
              <BaseToggleSwitch v-model="systemForm.requireTwoFactor" />
            </div>
            
            <div class="flex items-center justify-between">
              <div>
                <span class="text-gray-700 dark:text-gray-300">Auto-logout inactive users</span>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  Automatically logout users after period of inactivity
                </p>
              </div>
              <BaseToggleSwitch v-model="systemForm.autoLogout" />
            </div>
          </div>
        </div>
      </div>
      
      <div class="flex justify-end">
        <BaseButton
          type="submit"
          variant="primary"
          :loading="systemLoading"
        >
          Save System Settings
        </BaseButton>
      </div>
    </form>
  </BaseCard>
</template>

<script setup>
import { ref, reactive } from 'vue';
import BaseCard from '../../components/data-display/BaseCard.vue';
import BaseInput from '../../components/form/BaseInput.vue';
import BaseButton from '../../components/base/BaseButton.vue';
import BaseSelect from '../../components/form/BaseSelect.vue';
import BaseFormGroup from '../../components/form/BaseFormGroup.vue';
import BaseToggleSwitch from '../../components/form/BaseToggleSwitch.vue';

// System settings
const systemLoading = ref(false);
const systemSuccess = ref('');
const systemForm = reactive({
  siteName: 'Management App',
  defaultLanguage: 'en',
  passwordComplexity: 'medium',
  requireTwoFactor: false,
  autoLogout: true
});

// Language options
const languageOptions = [
  { value: 'en', label: 'English' },
  { value: 'es', label: 'Spanish' },
  { value: 'fr', label: 'French' },
  { value: 'de', label: 'German' },
  { value: 'ja', label: 'Japanese' }
];

// Password complexity options
const passwordComplexityOptions = [
  { value: 'low', label: 'Low - 6+ characters' },
  { value: 'medium', label: 'Medium - 8+ chars with numbers' },
  { value: 'high', label: 'High - 10+ chars with numbers and symbols' }
];

// Form submission handler
async function saveSystemSettings() {
  systemLoading.value = true;
  
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // In a real app, you would call an API endpoint to update the settings
    // await updateSystemSettings(systemForm);
    
    systemSuccess.value = 'System settings updated successfully!';
  } catch (error) {
    console.error('Error updating system settings:', error);
  } finally {
    systemLoading.value = false;
  }
}
</script>
