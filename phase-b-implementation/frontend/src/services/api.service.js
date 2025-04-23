import axios from 'axios';
import { toSnakeCase } from '@/utils/casing';

// Debug logging
console.log('API Service Initialization - hostname:', window.location.hostname);

/**
 * In prod we keep baseURL empty — axios will send requests
 * to the same origin that served the frontend (job.806040.xyz).
 * During local dev we proxy `/api` to port 3000 via Vite.
 */
const apiService = axios.create({
  baseURL: '',              // <— empty string is safest
  timeout: 360000, // 6 minutes timeout for LLM calls
  withCredentials: true, // Important for cookies/authentication across domains
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest'
  }
});

/**
 * Helper function to convert request data to snake_case
 * @param {Object|Array} data - Request data to convert
 * @returns {Object|Array} - Data with keys converted to snake_case
 */
const convertRequestToSnakeCase = (data) => {
  // Skip conversion for FormData, File, Blob, etc.
  if (data instanceof FormData || data instanceof File || data instanceof Blob) {
    return data;
  }

  // Skip conversion for null/undefined
  if (data === null || data === undefined) {
    return data;
  }

  return toSnakeCase(data);
};

// Request interceptor
apiService.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    // Don't override Content-Type if it's already set (e.g., for multipart/form-data)
    if (!config.headers['Content-Type']) {
      config.headers['Content-Type'] = 'application/json';
    }

    // Log the URL before any processing
    if (config.url) {
      // Add debug logging to see exactly what's being sent
      console.log('[apiService request] Before processing:', config.method?.toUpperCase(), config.url);

      // No need to modify URLs that already have the /api prefix
      // All service methods have been updated to include the /api prefix

      // Convert request data to snake_case if it exists and is not FormData
      if (config.data && !(config.data instanceof FormData)) {
        config.data = convertRequestToSnakeCase(config.data);
      }

      // Log the final URL that will be sent
      console.log('[apiService request] After processing:', config.method?.toUpperCase(), config.url);
    }

    return config;
  },
  error => {
    return Promise.reject(error);
  }
);

// Response interceptor
apiService.interceptors.response.use(
  response => {
    // Return the response data directly to simplify access
    return response.data;
  },
  error => {
    // Handle errors globally while preserving error details
    console.error('API Error:', error?.response?.data || error.message || error);

    // Create a more detailed error object
    const enhancedError = new Error(error?.response?.data?.message || error.message || 'Unknown error');
    enhancedError.response = error.response; // Preserve the original response
    enhancedError.status = error?.response?.status;
    enhancedError.data = error?.response?.data;

    return Promise.reject(enhancedError);
  }
);

// Export the helper function for direct use in services
export { convertRequestToSnakeCase };

export default apiService;
