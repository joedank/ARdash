import { useToast as useVueToast } from 'vue-toastification';

/**
 * Composable for showing toast notifications with consistent styling
 * Wraps vue-toastification to provide a standardized interface
 * 
 * @returns {Object} Toast methods with standardized options
 */
export function useToast() {
  const toast = useVueToast();
  
  // Default options that align with the design system
  const defaultOptions = {
    timeout: 5000,
    closeOnClick: true,
    pauseOnFocusLoss: true,
    pauseOnHover: true,
    draggable: true,
    draggablePercent: 0.6,
    showCloseButtonOnHover: false,
    hideProgressBar: false,
    closeButton: 'button',
    icon: true,
    rtl: false
  };

  return {
    /**
     * Show success toast notification
     * @param {string} message - Message to display
     * @param {Object} options - Override default options
     */
    success(message, options = {}) {
      toast.success(message, { ...defaultOptions, ...options });
    },

    /**
     * Show error toast notification
     * @param {string} message - Message to display
     * @param {Object} options - Override default options
     */
    error(message, options = {}) {
      toast.error(message, { ...defaultOptions, ...options });
    },

    /**
     * Show info toast notification
     * @param {string} message - Message to display
     * @param {Object} options - Override default options
     */
    info(message, options = {}) {
      toast.info(message, { ...defaultOptions, ...options });
    },

    /**
     * Show warning toast notification
     * @param {string} message - Message to display
     * @param {Object} options - Override default options
     */
    warning(message, options = {}) {
      toast.warning(message, { ...defaultOptions, ...options });
    }
  };
}
