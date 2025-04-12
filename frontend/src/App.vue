<template>
  <!-- Loading indicator while checking authentication -->
  <div v-if="!authStore.authChecked" class="flex items-center justify-center min-h-screen bg-gray-100 dark:bg-gray-900 text-gray-900 dark:text-white">
    <div class="text-center">
      <svg class="animate-spin h-8 w-8 mx-auto mb-4 text-indigo-600 dark:text-indigo-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      <p>Loading...</p>
    </div>
  </div>

  <!-- Authentication-specific content -->
  <div v-else>
    <!-- Only show header and navigation when authenticated -->
    <header v-if="isAuthenticated" class="bg-white dark:bg-gray-800 text-gray-900 dark:text-white py-4 border-b border-gray-200 dark:border-gray-700">
      <div class="container mx-auto px-4">
        <div class="flex flex-wrap items-center justify-between">
          <!-- Logo/Brand -->
          <div class="flex items-center flex-shrink-0 mr-6">
            <span class="font-semibold text-xl tracking-tight hidden">ARdash</span>
          </div>
          
          <!-- Main Navigation Component -->
          <MainNavigation />
          
          <!-- Profile dropdown -->
            <div class="relative profile-dropdown">
              <button @click="toggleProfileMenu" type="button" class="flex items-center gap-x-1 text-sm font-medium text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white rounded-full focus:outline-none">
                <div class="relative inline-block">
                  <div class="h-10 w-10 rounded-full bg-indigo-600 dark:bg-indigo-500 flex items-center justify-center overflow-hidden">
                    <!-- Display user avatar if available -->
                    <img
                      v-if="user?.avatar"
                      :src="user.avatar"
                      alt="User avatar"
                      class="h-full w-full object-cover"
                    />
                    <!-- Fallback to default icon -->
                    <svg
                      v-else
                      class="h-6 w-6 text-white"
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                    </svg>
                  </div>
                  <!-- Admin badge -->
                  <BaseBadge v-if="user?.role === 'admin'" variant="success" size="sm" class="absolute -top-1 -right-1" />
                </div>
              </button>
              
              <!-- Dropdown menu -->
              <BaseCard 
                v-if="isProfileOpen" 
                class="absolute right-0 z-60 mt-2 w-56 origin-top-right"
                variant="elevated"
              >
                <div class="px-4 py-3 border-b border-gray-200 dark:border-gray-700">
                  <p class="text-sm font-medium text-gray-900 dark:text-white">{{ user?.username }}</p>
                  <p class="text-xs text-gray-500 dark:text-gray-400">{{ user?.email }}</p>
                  <BaseBadge 
                    v-if="user?.role === 'admin'" 
                    variant="primary" 
                    size="sm" 
                    class="mt-1"
                  >
                    Admin
                  </BaseBadge>
                </div>
                
                <div class="py-1">
                  <router-link 
                    to="/settings" 
                    class="block px-4 py-2 text-sm text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700" 
                    @click="isProfileOpen = false"
                  >
                    Settings
                  </router-link>
                </div>
                
                <div class="border-t border-gray-200 dark:border-gray-700 py-1">
                  <BaseButton
                    variant="text"
                    class="block w-full text-left px-4 py-2 text-sm text-red-600 dark:text-red-400 hover:bg-gray-100 dark:hover:bg-gray-700"
                    :loading="loading"
                    @click="handleLogout"
                  >
                    Sign out
                  </BaseButton>
                </div>
              </BaseCard>
            </div>
        </div>
      </div>
    </header>
    
    <!-- Main content - only if authenticated or on login/register pages -->
    <main class="container mx-auto py-8 px-4">
      <router-view />
    </main>

    <!-- Footer - only if authenticated -->
    <footer v-if="isAuthenticated" class="bg-gray-100 dark:bg-gray-800 py-6 mt-12 border-t border-gray-200 dark:border-gray-700">
      <div class="container mx-auto px-4 text-center text-gray-500 dark:text-gray-400">
        <p>Vue.js and Node.js Core Project © 2025</p>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from './store/auth';
import ThemeService from './services/theme.service';
import BaseButton from './components/base/BaseButton.vue';
import BaseCard from './components/data-display/BaseCard.vue';
import BaseBadge from './components/data-display/BaseBadge.vue';
import MainNavigation from './components/navigation/MainNavigation.vue';

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();


const isProfileOpen = ref(false);
const loading = ref(false);

// User information from auth store
const user = computed(() => authStore.user);
const isAuthenticated = computed(() => authStore.isAuthenticated);
const isAuthRoute = computed(() => {
  return route.path === '/login' || route.path === '/register';
});

// Toggle profile dropdown
function toggleProfileMenu(e) {
  e.stopPropagation(); // Prevent event from bubbling to document
  isProfileOpen.value = !isProfileOpen.value;
}

// Close profile dropdown when clicking elsewhere
function closeProfileDropdown(event) {
  // Only close if dropdown is open and click is outside profile-dropdown
  if (isProfileOpen.value && !event.target.closest('.profile-dropdown')) {
    isProfileOpen.value = false;
  }
}

// Watch for authentication state changes to redirect accordingly
watch(
  () => authStore.isAuthenticated,
  (newIsAuthenticated) => {
    // If user is authenticated and on an auth route (login/register), redirect to home
    if (newIsAuthenticated && isAuthRoute.value) {
      router.push('/');
    }
    // If user is not authenticated and not on an auth route, redirect to login
    else if (!newIsAuthenticated && !isAuthRoute.value && authStore.authChecked) {
      router.push('/login');
    }
  }
);

onMounted(async () => {
  // Initialize theme from localStorage (before auth check for a smoother experience)
  ThemeService.loadTheme();
  
  // Check authentication status when app loads
  if (!authStore.authChecked) {
    await authStore.checkAuth();
    
    // After authentication check, apply user's theme preference if available
    if (authStore.isAuthenticated && authStore.user?.theme_preference) {
      console.log('Applying user theme preference:', authStore.user.theme_preference);
      ThemeService.applyTheme(authStore.user.theme_preference);
    } else {
      console.log('No user theme preference found, using localStorage default');
    }
    
    // Ensure proper routing
    if (!authStore.isAuthenticated && !isAuthRoute.value) {
      router.push('/login');
    } else if (authStore.isAuthenticated && isAuthRoute.value) {
      router.push('/');
    }
  }
  
  // Add event listener for clicks outside dropdown
  document.addEventListener('click', closeProfileDropdown);
});

// Clean up event listener
onBeforeUnmount(() => {
  document.removeEventListener('click', closeProfileDropdown);
});

async function handleLogout() {
  loading.value = true;
  isProfileOpen.value = false;
  
  try {
    await authStore.logout();
    router.push('/login');
  } catch (error) {
    console.error('Logout error:', error);
  } finally {
    loading.value = false;
  }
}
</script>