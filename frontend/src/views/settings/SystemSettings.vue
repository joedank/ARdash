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

        <div>
          <h4 class="font-medium text-gray-800 dark:text-white mb-3">Development Settings</h4>
          <p class="text-sm text-gray-500 dark:text-gray-400 mb-3">These affect local development only. Changes require restarting the frontend dev server.</p>
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <div>
                <span class="text-gray-700 dark:text-gray-300">Enable Hot Module Reload (HMR)</span>
                <p class="text-sm text-gray-500 dark:text-gray-400">When disabled, the app uses full page reloads and avoids WebSocket issues.</p>
              </div>
              <BaseToggleSwitch v-model="devForm.enableHmr" />
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <BaseFormGroup label="HMR Host" input-id="hmrHost" helper-text="Usually 'localhost'">
                <BaseInput id="hmrHost" v-model="devForm.hmrHost" placeholder="localhost" />
              </BaseFormGroup>
              <BaseFormGroup label="HMR Port" input-id="hmrPort" helper-text="Default 5173">
                <BaseInput id="hmrPort" v-model.number="devForm.hmrPort" type="number" placeholder="5173" />
              </BaseFormGroup>
            </div>

            <BaseFormGroup label="Origin (optional)" input-id="devOrigin" helper-text="e.g., http://localhost:5173">
              <BaseInput id="devOrigin" v-model="devForm.devOrigin" placeholder="http://localhost:5173" />
            </BaseFormGroup>

            <div class="flex gap-3">
              <BaseButton type="button" variant="secondary" @click="copyEnvSnippet">Copy .env snippet</BaseButton>
              <BaseButton type="button" variant="secondary" @click="copyRestartCmd">Copy restart command</BaseButton>
            </div>

            <p class="text-xs text-gray-500 dark:text-gray-400">
              Paste the snippet into <code>.env.development</code> (or set environment variables) and then run the restart command.
            </p>
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
import { ref, reactive, onMounted, watch } from 'vue';
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

// Dev settings (local development only)
const devForm = reactive({
  enableHmr: true,
  hmrHost: 'localhost',
  hmrPort: 5173,
  devOrigin: 'http://localhost:5173'
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

// Helpers: copy env snippet and restart command to clipboard
function copyEnvSnippet() {
  const lines = [];
  lines.push(`VITE_HMR_ENABLED=${devForm.enableHmr ? 'true' : 'false'}`);
  if (devForm.hmrHost) lines.push(`VITE_HMR_HOST=${devForm.hmrHost}`);
  if (devForm.hmrPort) lines.push(`VITE_HMR_PORT=${devForm.hmrPort}`);
  if (devForm.devOrigin) lines.push(`VITE_DEV_ORIGIN=${devForm.devOrigin}`);
  const text = lines.join('\n') + '\n';
  navigator.clipboard.writeText(text);
}

function copyRestartCmd() {
  const cmd = 'docker compose restart frontend';
  navigator.clipboard.writeText(cmd);
}

// Persist dev settings locally for convenience (does not auto-apply to Vite)
onMounted(() => {
  try {
    const saved = JSON.parse(localStorage.getItem('devSettings') || '{}');
    Object.assign(devForm, saved);
  } catch {}
});

watch(devForm, (val) => {
  localStorage.setItem('devSettings', JSON.stringify(val));
}, { deep: true });
</script>
