<template>
  <BaseCard variant="bordered">
    <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Account Settings</h3>
    
    <BaseAlert
      v-if="accountSuccess"
      variant="success"
      :message="accountSuccess"
      dismissible
      class="mb-4"
      @close="accountSuccess = ''"
    />
    
    <form @submit.prevent="saveAccountSettings">
      <div class="space-y-4 mb-6">
        <BaseFormGroup
          label="Username"
          input-id="username"
          helper-text="Your unique username for logging in"
        >
          <BaseInput
            id="username"
            v-model="accountForm.username"
            disabled
          />
        </BaseFormGroup>
        
        <BaseFormGroup
          label="Email Address"
          input-id="email"
          helper-text="We'll send important notifications to this address"
        >
          <BaseInput
            id="email"
            v-model="accountForm.email"
            type="email"
          />
        </BaseFormGroup>
        
        <BaseFormGroup
          label="Language"
          input-id="language"
          helper-text="Your preferred language for the interface"
        >
          <BaseSelect
            id="language"
            v-model="accountForm.language"
            :options="languageOptions"
          />
        </BaseFormGroup>
        
        <BaseFormGroup
          label="Time Zone"
          input-id="timezone"
          helper-text="Used for displaying dates and times"
        >
          <BaseSelect
            id="timezone"
            v-model="accountForm.timezone"
            :options="timezoneOptions"
          />
        </BaseFormGroup>
      </div>
      
      <div class="flex justify-end">
        <BaseButton
          type="submit"
          variant="primary"
          :loading="accountLoading"
        >
          Save Account Settings
        </BaseButton>
      </div>
    </form>
  </BaseCard>
</template>

<script setup>
import { ref, reactive } from 'vue';
import { useAuthStore } from '../../store/auth';
import BaseCard from '../../components/data-display/BaseCard.vue';
import BaseInput from '../../components/form/BaseInput.vue';
import BaseButton from '../../components/base/BaseButton.vue';
import BaseAlert from '../../components/feedback/BaseAlert.vue';
import BaseSelect from '../../components/form/BaseSelect.vue';
import BaseFormGroup from '../../components/form/BaseFormGroup.vue';

const authStore = useAuthStore();

// Account settings
const accountLoading = ref(false);
const accountSuccess = ref('');
const accountForm = reactive({
  username: authStore.user?.username || 'johndoe',
  email: authStore.user?.email || 'johndoe@example.com',
  language: authStore.user?.language || 'en',
  timezone: authStore.user?.timezone || 'America/New_York'
});

// Language options
const languageOptions = [
  { value: 'en', label: 'English' },
  { value: 'es', label: 'Spanish' },
  { value: 'fr', label: 'French' },
  { value: 'de', label: 'German' },
  { value: 'ja', label: 'Japanese' }
];

// Timezone options
const timezoneOptions = [
  { value: 'America/New_York', label: 'Eastern Time (US & Canada)' },
  { value: 'America/Chicago', label: 'Central Time (US & Canada)' },
  { value: 'America/Denver', label: 'Mountain Time (US & Canada)' },
  { value: 'America/Los_Angeles', label: 'Pacific Time (US & Canada)' },
  { value: 'Europe/London', label: 'London' },
  { value: 'Europe/Paris', label: 'Paris' },
  { value: 'Asia/Tokyo', label: 'Tokyo' }
];

// Form submission handler
async function saveAccountSettings() {
  accountLoading.value = true;
  
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // In a real app, you would call an API endpoint to update the settings
    // await updateAccountSettings(accountForm);
    
    accountSuccess.value = 'Account settings updated successfully!';
  } catch (error) {
    console.error('Error updating account settings:', error);
  } finally {
    accountLoading.value = false;
  }
}
</script>
