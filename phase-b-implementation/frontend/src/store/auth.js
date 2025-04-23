import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import AuthService from '../services/auth.service';
import UserService from '../services/user.service';

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref(null);
  const loading = ref(false);
  const error = ref(null);
  const authChecked = ref(false);

  // Getters
  const isAuthenticated = computed(() => !!user.value);
  const isAdmin = computed(() => user.value?.role === 'admin');
  const isEstimatorManager = computed(() => user.value?.role === 'estimator_manager');
  const canManageWorkTypes = computed(() => isAdmin.value || isEstimatorManager.value);

  // Actions
  /**
   * Register a new user
   * @param {Object} userData - User registration data
   */
  async function register(userData) {
    loading.value = true;
    error.value = null;

    try {
      const response = await AuthService.register(userData);
      user.value = response.data.user || response.user;
      authChecked.value = true;
      return response;
    } catch (err) {
      error.value = err.message || 'Registration failed';
      throw err;
    } finally {
      loading.value = false;
    }
  }

  /**
   * Login a user
   * @param {Object} credentials - User login credentials
   */
  async function login(credentials) {
    loading.value = true;
    error.value = null;

    try {
      const response = await AuthService.login(credentials);
      user.value = response.data.user || response.user;
      authChecked.value = true;
      return response;
    } catch (err) {
      error.value = err.message || 'Login failed';
      throw err;
    } finally {
      loading.value = false;
    }
  }

  /**
   * Logout the current user
   */
  async function logout() {
    loading.value = true;

    try {
      await AuthService.logout();
      user.value = null;
    } catch (err) {
      error.value = err.message || 'Logout failed';
    } finally {
      loading.value = false;
    }
  }

  /**
   * Check authentication status
   * Retrieves user profile if token exists
   */
  async function checkAuth() {
    if (AuthService.isAuthenticated()) {
      loading.value = true;

      try {
        const response = await AuthService.getProfile();
        user.value = response.data.user || response.user;
        console.log('User profile loaded, theme preference:', user.value?.theme_preference);
        // Apply theme preference after loading user profile
        if (user.value?.theme_preference) {
          const ThemeService = (await import('../services/theme.service')).default;
          ThemeService.applyTheme(user.value.theme_preference);
        }
      } catch (err) {
        user.value = null;
        AuthService.clearToken();
      } finally {
        loading.value = false;
      }
    } else {
      user.value = null;
    }

    authChecked.value = true;
  }

  /**
   * Update user profile
   * @param {Object} userData - Updated user data
   */
  async function updateProfile(userData) {
    loading.value = true;
    error.value = null;

    try {
      const response = await UserService.updateProfile(userData);
      if (response.success) {
        // Update the user in the store
        user.value = response.data.user;
      }
      return response;
    } catch (err) {
      error.value = err.message || 'Profile update failed';
      throw err;
    } finally {
      loading.value = false;
    }
  }

  /**
   * Change user password
   * @param {Object} passwordData - Password change data
   */
  async function changePassword(passwordData) {
    loading.value = true;
    error.value = null;

    try {
      const response = await UserService.changePassword(passwordData);
      return response;
    } catch (err) {
      error.value = err.message || 'Password change failed';
      throw err;
    } finally {
      loading.value = false;
    }
  }

  /**
   * Update user preference (theme, language, etc.)
   * @param {string} preferenceName - Name of the preference to update
   * @param {any} value - New value for the preference
   */
  function updateUserPreference(preferenceName, value) {
    if (user.value) {
      user.value = {
        ...user.value,
        [preferenceName]: value
      };
    }
  }

  /**
   * Update user theme preference
   * @param {string} theme - Theme preference ('light', 'dark', or 'system')
   */
  async function updateThemePreference(theme) {
    loading.value = true;
    error.value = null;

    try {
      // Apply theme immediately for better UX
      const ThemeService = (await import('../services/theme.service')).default;
      ThemeService.applyTheme(theme);

      const response = await UserService.updateThemePreference(theme);
      if (response.success) {
        console.log('Theme preference updated successfully:', theme);
        updateUserPreference('theme_preference', theme);
        // Ensure localStorage is also updated
        localStorage.setItem('theme_preference', theme);
      }
      return response;
    } catch (err) {
      error.value = err.message || 'Theme preference update failed';
      console.error('Failed to update theme preference:', err);
      throw err;
    } finally {
      loading.value = false;
    }
  }

  /**
   * Reset the auth store state
   */
  function resetState() {
    user.value = null;
    loading.value = false;
    error.value = null;
    authChecked.value = false;
  }

  return {
    // State
    user,
    loading,
    error,
    authChecked,

    // Getters
    isAuthenticated,
    isAdmin,
    isEstimatorManager,
    canManageWorkTypes,

    // Actions
    register,
    login,
    logout,
    checkAuth,
    updateProfile,
    changePassword,
    updateUserPreference,
    updateThemePreference,
    resetState
  };
});
