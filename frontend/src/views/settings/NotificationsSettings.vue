<template>
  <BaseCard variant="bordered">
    <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Notification Preferences</h3>
    
    <BaseAlert
      v-if="notificationsSuccess"
      variant="success"
      :message="notificationsSuccess"
      dismissible
      class="mb-4"
      @close="notificationsSuccess = ''"
    />
    
    <form @submit.prevent="saveNotificationSettings">
      <div class="space-y-6 mb-6">
        <div>
          <h4 class="font-medium text-gray-800 dark:text-white mb-3">Email Notifications</h4>
          <div class="space-y-3">
            <div class="flex items-center justify-between">
              <div>
                <span class="text-gray-700 dark:text-gray-300">Account updates</span>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  Receive emails for important account changes
                </p>
              </div>
              <BaseToggleSwitch v-model="notificationsForm.emailAccount" />
            </div>
            
            <div class="flex items-center justify-between">
              <div>
                <span class="text-gray-700 dark:text-gray-300">System notifications</span>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  Receive emails about system updates and maintenance
                </p>
              </div>
              <BaseToggleSwitch v-model="notificationsForm.emailSystem" />
            </div>
            
            <div class="flex items-center justify-between">
              <div>
                <span class="text-gray-700 dark:text-gray-300">Marketing communications</span>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  Receive emails about new features and updates
                </p>
              </div>
              <BaseToggleSwitch v-model="notificationsForm.emailMarketing" />
            </div>
          </div>
        </div>
        
        <div>
          <h4 class="font-medium text-gray-800 dark:text-white mb-3">In-App Notifications</h4>
          <div class="space-y-3">
            <div class="flex items-center justify-between">
              <div>
                <span class="text-gray-700 dark:text-gray-300">Task updates</span>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  Receive notifications when tasks are updated
                </p>
              </div>
              <BaseToggleSwitch v-model="notificationsForm.inAppTasks" />
            </div>
            
            <div class="flex items-center justify-between">
              <div>
                <span class="text-gray-700 dark:text-gray-300">System notifications</span>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  Receive notifications about system updates
                </p>
              </div>
              <BaseToggleSwitch v-model="notificationsForm.inAppSystem" />
            </div>
          </div>
        </div>
      </div>
      
      <div class="flex justify-end">
        <BaseButton
          type="submit"
          variant="primary"
          :loading="notificationsLoading"
        >
          Save Notification Settings
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
import BaseToggleSwitch from '../../components/form/BaseToggleSwitch.vue';

// Notification settings
const notificationsLoading = ref(false);
const notificationsSuccess = ref('');
const notificationsForm = reactive({
  emailAccount: true,
  emailSystem: true,
  emailMarketing: false,
  inAppTasks: true,
  inAppSystem: true
});

// Form submission handler
async function saveNotificationSettings() {
  notificationsLoading.value = true;
  
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // In a real app, you would call an API endpoint to update the settings
    // await updateNotificationSettings(notificationsForm);
    
    notificationsSuccess.value = 'Notification preferences updated successfully!';
  } catch (error) {
    console.error('Error updating notification settings:', error);
  } finally {
    notificationsLoading.value = false;
  }
}
</script>
