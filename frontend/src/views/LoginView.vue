<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100 dark:bg-gray-900 py-12 px-4 sm:px-6 lg:px-8">
    <BaseCard class="max-w-md w-full" variant="elevated">
      <template #header>
        <div class="text-center">
          <!-- App logo/icon -->
          <div class="flex justify-center mb-4">
            <div class="h-20 w-20 rounded-full bg-indigo-600 dark:bg-indigo-500 flex items-center justify-center">
              <svg class="h-12 w-12 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 11c0 3.517-1.009 6.799-2.753 9.571m-3.44-2.04l.054-.09A13.916 13.916 0 008 11a4 4 0 118 0c0 1.017-.07 2.019-.203 3m-2.118 6.844A21.88 21.88 0 0012 21.35" />
              </svg>
            </div>
          </div>

          <h2 class="text-3xl font-extrabold text-gray-900 dark:text-white">
            Sign In
          </h2>
          <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
            Access your secure dashboard
          </p>
        </div>
      </template>
      
      <BaseAlert 
        v-if="error" 
        variant="error" 
        :message="error" 
        dismissible 
        class="mb-4"
        @close="error = ''"
      />
      
      <form class="space-y-6" @submit.prevent="handleLogin">
        <BaseFormGroup
          label="Username"
          input-id="username"
          required
        >
          <BaseInput
            id="username"
            v-model="form.username"
            type="text"
            placeholder="Enter your username"
            required
          />
        </BaseFormGroup>
        
        <BaseFormGroup
          label="Password"
          input-id="password"
          required
        >
          <BaseInput
            id="password"
            v-model="form.password"
            type="password"
            placeholder="Enter your password"
            required
          />
        </BaseFormGroup>

        <BaseButton
          type="submit"
          variant="primary"
          :loading="loading"
          block
        >
          {{ loading ? 'Signing in...' : 'Sign in' }}
        </BaseButton>
        
        <div class="flex items-center justify-center">
          <router-link to="/register" class="font-medium text-indigo-600 dark:text-indigo-400 hover:text-indigo-500 dark:hover:text-indigo-300">
            Need an account? Register now
          </router-link>
        </div>
      </form>
    </BaseCard>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../store/auth';
import BaseCard from '../components/data-display/BaseCard.vue';
import BaseInput from '../components/form/BaseInput.vue';
import BaseButton from '../components/base/BaseButton.vue';
import BaseAlert from '../components/feedback/BaseAlert.vue';
import BaseFormGroup from '../components/form/BaseFormGroup.vue';

const router = useRouter();
const authStore = useAuthStore();

const form = reactive({
  username: '',
  password: ''
});

const loading = ref(false);
const error = ref('');

async function handleLogin() {
  loading.value = true;
  error.value = '';
  
  try {
    await authStore.login(form);
    router.push('/');
  } catch (err) {
    error.value = err.message || 'Login failed. Please check your credentials.';
  } finally {
    loading.value = false;
  }
}
</script>
