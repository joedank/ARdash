<template>
  <BaseCard variant="bordered">
    <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Security Settings</h3>
    
    <BaseAlert
      v-if="securitySuccess"
      variant="success"
      :message="securitySuccess"
      dismissible
      class="mb-4"
      @close="securitySuccess = ''"
    />
    
    <form @submit.prevent="saveSecuritySettings">
      <div class="space-y-4 mb-6">
        <BaseFormGroup
          label="Two-Factor Authentication"
          input-id="twoFactorAuth"
          helper-text="Enable two-factor authentication for added security"
        >
          <BaseToggleSwitch
            id="twoFactorAuth"
            v-model="securityForm.twoFactorEnabled"
          />
        </BaseFormGroup>
        
        <BaseFormGroup
          label="Session Timeout"
          input-id="sessionTimeout"
          helper-text="Time of inactivity before you're automatically logged out"
        >
          <BaseSelect
            id="sessionTimeout"
            v-model="securityForm.sessionTimeout"
            :options="timeoutOptions"
          />
        </BaseFormGroup>
        
        <div class="pt-4 border-t border-gray-200 dark:border-gray-700">
          <h4 class="font-medium text-gray-800 dark:text-white mb-2">
            Activity Log
          </h4>
          <p class="text-sm text-gray-500 dark:text-gray-400 mb-4">
            Recent login activity for your account
          </p>
          
          <div class="bg-gray-50 dark:bg-gray-800 rounded-lg overflow-hidden">
            <div class="divide-y divide-gray-200 dark:divide-gray-700">
              <div 
                v-for="(activity, index) in securityActivities" 
                :key="index" 
                class="p-4"
              >
                <div class="flex items-center justify-between">
                  <div>
                    <p class="text-sm font-medium text-gray-900 dark:text-white">
                      {{ activity.device }}
                    </p>
                    <p class="text-xs text-gray-500 dark:text-gray-400">
                      {{ activity.location }} • {{ activity.ip }}
                    </p>
                  </div>
                  <p class="text-xs text-gray-500 dark:text-gray-400">
                    {{ activity.time }}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div class="flex justify-end">
        <BaseButton
          type="submit"
          variant="primary"
          :loading="securityLoading"
        >
          Save Security Settings
        </BaseButton>
      </div>
    </form>
  </BaseCard>
</template>

<script setup>
import { ref, reactive } from 'vue';
import BaseCard from '../../components/data-display/BaseCard.vue';
import BaseButton from '../../components/base/BaseButton.vue';
import BaseAlert from '../../components/feedback/BaseAlert.vue';
import BaseSelect from '../../components/form/BaseSelect.vue';
import BaseFormGroup from '../../components/form/BaseFormGroup.vue';
import BaseToggleSwitch from '../../components/form/BaseToggleSwitch.vue';

// Security settings
const securityLoading = ref(false);
const securitySuccess = ref('');
const securityForm = reactive({
  twoFactorEnabled: false,
  sessionTimeout: '60'
});

// Timeout options
const timeoutOptions = [
  { value: '15', label: '15 minutes' },
  { value: '30', label: '30 minutes' },
  { value: '60', label: '1 hour' },
  { value: '120', label: '2 hours' },
  { value: '240', label: '4 hours' },
  { value: '720', label: '12 hours' },
  { value: '1440', label: '24 hours' }
];

// Security activity log
const securityActivities = [
  {
    device: 'MacBook Pro - Chrome',
    location: 'San Francisco, CA',
    ip: '192.168.1.1',
    time: 'Today, 3:24 PM'
  },
  {
    device: 'iPhone 13 - Safari',
    location: 'San Francisco, CA',
    ip: '192.168.1.100',
    time: 'Yesterday, 10:17 AM'
  },
  {
    device: 'Windows PC - Firefox',
    location: 'Seattle, WA',
    ip: '198.51.100.42',
    time: 'Mar 27, 2025, 4:30 PM'
  }
];

// Form submission handler
async function saveSecuritySettings() {
  securityLoading.value = true;
  
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // In a real app, you would call an API endpoint to update the settings
    // await updateSecuritySettings(securityForm);
    
    securitySuccess.value = 'Security settings updated successfully!';
  } catch (error) {
    console.error('Error updating security settings:', error);
  } finally {
    securityLoading.value = false;
  }
}
</script>
