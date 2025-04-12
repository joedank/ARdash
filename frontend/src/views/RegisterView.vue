<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100 dark:bg-gray-900 py-12 px-4 sm:px-6 lg:px-8">
    <BaseCard class="max-w-md w-full" variant="elevated">
      <template #header>
        <div class="text-center">
          <!-- App logo/icon -->
          <div class="flex justify-center mb-4">
            <div class="h-20 w-20 rounded-full bg-indigo-600 dark:bg-indigo-500 flex items-center justify-center">
              <svg class="h-12 w-12 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
              </svg>
            </div>
          </div>

          <h2 class="text-3xl font-extrabold text-gray-900 dark:text-white">
            Create Account
          </h2>
          <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
            Join our secure platform
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
      
      <form class="space-y-4" @submit.prevent="handleRegister">
        <BaseFormGroup
          label="Username"
          input-id="username"
          required
        >
          <BaseInput
            id="username"
            v-model="form.username"
            type="text"
            placeholder="Choose a username"
            required
          />
        </BaseFormGroup>
        
        <BaseFormGroup
          label="Email"
          input-id="email"
          required
        >
          <BaseInput
            id="email"
            v-model="form.email"
            type="email"
            placeholder="Your email address"
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
            placeholder="Create a secure password"
            required
          />
        </BaseFormGroup>
        
        <div class="grid grid-cols-2 gap-4">
          <BaseFormGroup
            label="First Name"
            input-id="firstName"
          >
            <BaseInput
              id="firstName"
              v-model="form.firstName"
              type="text"
              placeholder="Optional"
            />
          </BaseFormGroup>
          
          <BaseFormGroup
            label="Last Name"
            input-id="lastName"
          >
            <BaseInput
              id="lastName"
              v-model="form.lastName"
              type="text"
              placeholder="Optional"
            />
          </BaseFormGroup>
        </div>

        <BaseButton
          type="submit"
          variant="primary"
          :loading="loading"
          block
        >
          {{ loading ? 'Creating account...' : 'Create account' }}
        </BaseButton>
        
        <div class="flex items-center justify-center">
          <router-link to="/login" class="font-medium text-indigo-600 dark:text-indigo-400 hover:text-indigo-500 dark:hover:text-indigo-300">
            Already have an account? Sign in
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
  email: '',
  password: '',
  firstName: '',
  lastName: ''
});

const loading = ref(false);
const error = ref('');

async function handleRegister() {
  loading.value = true;
  error.value = '';
  
  try {
    await authStore.register(form);
    router.push('/');
  } catch (err) {
    error.value = err.message || 'Registration failed. Please try again.';
  } finally {
    loading.value = false;
  }
}
</script>
