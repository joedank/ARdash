<!--
  ModernNavigation
  
  A modernized navigation component for the application that maintains the core functionality
  of the original MainNavigation.vue but with an updated design for Tailwind CSS v4.
  
  Features:
  - Role-based navigation items
  - Active route highlighting
  - Dropdown menu for related sections (Invoicing)
  - Dark mode compatible with Tailwind v4
  - Responsive design with mobile menu overlay
  - Improved visual styling and transitions
-->
<template>
  <nav class="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 shadow-sm sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between h-16">
        <!-- Left side: Logo and main navigation -->
        <div class="flex">
          <!-- Logo/Brand -->
          <div class="flex-shrink-0 flex items-center">
            <router-link to="/" class="flex items-center gap-2">
              <!-- You can add a logo SVG here -->
              <span class="text-xl font-bold bg-gradient-to-r from-blue-600 to-indigo-600 dark:from-blue-500 dark:to-indigo-400 text-transparent bg-clip-text">ARdash</span>
            </router-link>
          </div>

          <!-- Desktop Navigation Links -->
          <div class="hidden sm:ml-8 sm:flex sm:space-x-4 items-center">
            <router-link
              to="/"
              class="nav-link-modern"
              :class="{ 'active-nav-link-modern': $route.path === '/' }"
              exact
            >
              Home
            </router-link>


              
            <router-link
              to="/projects"
              class="nav-link-modern"
              :class="{ 'active-nav-link-modern': $route.path.startsWith('/projects') }"
            >
              Projects
            </router-link>

            <!-- Invoicing Dropdown Menu -->
            <div 
              class="relative inline-block" 
              v-click-outside="closeInvoicingMenu"
            >
              <button 
                @click="toggleInvoicingMenu"
                class="nav-link-modern group"
                :class="{ 'active-nav-link-modern': isInvoicingRoute }"
                aria-haspopup="true"
                :aria-expanded="invoicingMenuOpen"
              >
                <span>Invoicing</span>
                <svg 
                  class="ml-1 h-4 w-4 transition-transform duration-200 ease-in-out" 
                  :class="{ 'rotate-180': invoicingMenuOpen }"
                  xmlns="http://www.w3.org/2000/svg" 
                  viewBox="0 0 20 20" 
                  fill="currentColor"
                >
                  <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
                </svg>
              </button>
              
              <!-- Dropdown Menu Content -->
              <transition
                enter-active-class="transition ease-out duration-200"
                enter-from-class="opacity-0 translate-y-1"
                enter-to-class="opacity-100 translate-y-0"
                leave-active-class="transition ease-in duration-150"
                leave-from-class="opacity-100 translate-y-0"
                leave-to-class="opacity-0 translate-y-1"
              >
                <div 
                  v-show="invoicingMenuOpen"
                  class="absolute left-0 mt-2 w-48 rounded-md shadow-lg bg-white dark:bg-gray-800 ring-1 ring-black ring-opacity-5 focus:outline-none divide-y divide-gray-100 dark:divide-gray-700 py-1 z-60"
                >
                  <router-link
                    to="/invoicing/invoices"
                    class="dropdown-item-modern"
                    @click="closeInvoicingMenu"
                  >
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                    </svg>
                    Invoices
                  </router-link>
                  <router-link
                    to="/invoicing/estimates"
                    class="dropdown-item-modern"
                    @click="closeInvoicingMenu"
                  >
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
                    </svg>
                    Estimates
                  </router-link>
                </div>
              </transition>
            </div>
          </div>
        </div>

        <!-- Right Side Navigation -->
        <div class="flex items-center gap-4">

          <!-- Mobile menu button -->
          <div class="flex sm:hidden">
            <button
              type="button"
              class="inline-flex items-center justify-center p-2 rounded-md text-gray-500 hover:text-gray-700 hover:bg-gray-100 dark:text-gray-400 dark:hover:text-gray-300 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-blue-500 transition-colors"
              aria-controls="mobile-menu"
              :aria-expanded="mobileMenuOpen"
              @click="toggleMobileMenu"
            >
              <span class="sr-only">Open main menu</span>
              <!-- Heroicon name: menu (shown when closed) -->
              <svg 
                class="h-6 w-6" 
                :class="{ 'hidden': mobileMenuOpen, 'block': !mobileMenuOpen }" 
                xmlns="http://www.w3.org/2000/svg" 
                fill="none" 
                viewBox="0 0 24 24" 
                stroke="currentColor" 
                aria-hidden="true"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
              </svg>
              <!-- Heroicon name: x (shown when open) -->
              <svg 
                class="h-6 w-6" 
                :class="{ 'block': mobileMenuOpen, 'hidden': !mobileMenuOpen }" 
                xmlns="http://www.w3.org/2000/svg" 
                fill="none" 
                viewBox="0 0 24 24" 
                stroke="currentColor" 
                aria-hidden="true"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Mobile menu overlay structure -->
    <div class="relative sm:hidden">
      <!-- Semi-transparent backdrop -->
      <transition
        enter-active-class="transition duration-200 ease-out"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="transition duration-100 ease-in"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div 
          v-if="mobileMenuOpen"
          class="fixed inset-0 bg-black bg-opacity-25 z-40"
          @click="mobileMenuOpen = false"
        ></div>
      </transition>

      <!-- Mobile menu dropdown -->
      <transition
        enter-active-class="transition duration-200 ease-out"
        enter-from-class="opacity-0 scale-95"
        enter-to-class="opacity-100 scale-100"
        leave-active-class="transition duration-100 ease-in"
        leave-from-class="opacity-100 scale-100"
        leave-to-class="opacity-0 scale-95"
      >
        <div 
          v-show="mobileMenuOpen" 
          class="fixed top-16 inset-x-4 sm:hidden bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-lg z-60 mobile-menu-dropdown overflow-hidden" 
          id="mobile-menu"
        >
          <div class="px-2 py-3 max-h-[calc(100vh-5rem)] overflow-y-auto">
            <router-link
              to="/"
              class="mobile-nav-link"
              :class="{ 'mobile-nav-active': $route.path === '/' }"
              @click="mobileMenuOpen = false"
            >
              Home
            </router-link>
            

            
            <router-link
              to="/projects"
              class="mobile-nav-link"
              :class="{ 'mobile-nav-active': $route.path.startsWith('/projects') }"
              @click="mobileMenuOpen = false"
            >
              Projects
            </router-link>
            
            <!-- Mobile Invoicing Section -->
            <div class="space-y-1 pl-3 border-l-2 border-gray-200 dark:border-gray-700 ml-2 mt-2">
              <div class="mobile-nav-section">Invoicing</div>
              
              <router-link
                to="/invoicing/invoices"
                class="mobile-nav-link pl-4"
                :class="{ 'mobile-nav-active': $route.path === '/invoicing/invoices' }"
                @click="mobileMenuOpen = false"
              >
                Invoices
              </router-link>
              
              <router-link
                to="/invoicing/estimates"
                class="mobile-nav-link pl-4"
                :class="{ 'mobile-nav-active': $route.path === '/invoicing/estimates' }"
                @click="mobileMenuOpen = false"
              >
                Estimates
              </router-link>
            </div>
          </div>
        </div>
      </transition>
    </div>
  </nav>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '@/store/auth';
import { vClickOutside } from '@/directives/click-outside';

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();

const isAdmin = computed(() => authStore.isAdmin);

// Invoicing dropdown state
const invoicingMenuOpen = ref(false);
const mobileMenuOpen = ref(false);

// Check if current route is under invoicing
const isInvoicingRoute = computed(() => {
  return route.path.startsWith('/invoicing');
});

// Toggle invoicing dropdown
const toggleInvoicingMenu = () => {
  invoicingMenuOpen.value = !invoicingMenuOpen.value;
};

// Close invoicing dropdown
const closeInvoicingMenu = () => {
  invoicingMenuOpen.value = false;
};

// Toggle mobile menu
const toggleMobileMenu = () => {
  mobileMenuOpen.value = !mobileMenuOpen.value;
};

// Close mobile menu when clicking outside
const handleClickOutside = (event) => {
  const mobileMenuElement = document.getElementById('mobile-menu');
  const mobileMenuButton = document.querySelector('[aria-controls="mobile-menu"]');
  
  if (mobileMenuOpen.value && 
      mobileMenuElement && 
      !mobileMenuElement.contains(event.target) && 
      mobileMenuButton && 
      !mobileMenuButton.contains(event.target)) {
    mobileMenuOpen.value = false;
  }
};

// Event listeners for closing mobile menu
onMounted(() => {
  document.addEventListener('click', handleClickOutside);
});

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside);
});

const logout = async () => {
  await authStore.logout();
  router.push('/login');
};
</script>

<style scoped>
@reference "../../style.css";

/* Navigation links - desktop */
.nav-link-modern {
  @apply inline-flex items-center px-3 py-2 text-sm font-medium text-gray-600 dark:text-gray-300 rounded-md transition-colors duration-150;
  @apply hover:bg-gray-100 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-white;
  @apply relative;
}

.active-nav-link-modern {
  @apply text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/20;
  @apply hover:bg-blue-50 dark:hover:bg-blue-900/30;
}

.active-nav-link-modern::after {
  content: '';
  @apply absolute bottom-0 left-0 w-full h-0.5 bg-blue-500 dark:bg-blue-400 rounded-t;
}

/* Dropdown menu items */
.dropdown-item-modern {
  @apply flex items-center w-full px-4 py-2 text-sm text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700;
  @apply transition-colors duration-150;
}

/* Mobile navigation */
.mobile-nav-link {
  @apply block px-3 py-2 my-1 rounded-md text-base font-medium text-gray-700 dark:text-gray-200;
  @apply hover:bg-gray-100 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-white;
  @apply transition-colors duration-150;
}

.mobile-nav-active {
  @apply bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-400;
}

.mobile-nav-section {
  @apply px-3 py-2 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider;
}

/* Mobile menu dropdown card styling */
.mobile-menu-dropdown {
  @apply backdrop-blur-sm bg-white/95 dark:bg-gray-800/95;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}
</style>
