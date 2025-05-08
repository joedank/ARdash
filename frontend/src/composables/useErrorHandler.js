import { ref } from 'vue';
import { useToast } from 'vue-toastification';

/**
 * Composable for standardized error handling
 * Provides consistent error handling across components
 * @returns {Object} Error handling utilities
 */
export default function useErrorHandler() {
  const toast = useToast();
  const error = ref(null);
  const rawErrorContent = ref(null);
  
  /**
   * Handle an error with standardized processing
   * @param {Error} err - Error object to handle
   * @param {string} customMessage - Optional custom message to display
   * @returns {Object} Structured error information
   */
  const handleError = (err, customMessage = null) => {
    console.error('Error occurred:', err);
    
    // Extract error message from different possible structures
    let errorMessage = customMessage;
    
    if (!errorMessage) {
      if (err.response?.data?.message) {
        errorMessage = err.response.data.message;
      } else if (err.message) {
        errorMessage = err.message;
      } else {
        errorMessage = 'An unexpected error occurred';
      }
    }
    
    // Store error info
    error.value = errorMessage;
    rawErrorContent.value = err.response?.data?.error || err.response?.data?.rawContent || null;
    
    // Show toast notification
    toast.error(errorMessage);
    
    // Return structured error info
    return {
      message: errorMessage,
      raw: rawErrorContent.value,
      status: err.response?.status || 500
    };
  };
  
  /**
   * Clear current error state
   */
  const clearError = () => {
    error.value = null;
    rawErrorContent.value = null;
  };
  
  /**
   * Display a success toast notification
   * @param {string} message - Success message to display
   */
  const successToast = (message) => {
    toast.success(message);
  };
  
  return {
    error,
    rawErrorContent,
    handleError,
    clearError,
    successToast
  };
}
