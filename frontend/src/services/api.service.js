import axios from 'axios';

// Determine the base URL based on the environment
const isDevelopment = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';

// Debug logging
console.log('API Service Initialization - hostname:', window.location.hostname);
console.log('Using development mode:', isDevelopment);

// Create an axios instance
const apiService = axios.create({
  // When accessed via job.806040.xyz, use relative URL; otherwise use localhost
  baseURL: isDevelopment ? 'http://localhost:3000/api' : '/api',
  timeout: 360000, // 6 minutes timeout for LLM calls
  withCredentials: true, // Important for cookies/authentication across domains
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest'
  }
});

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

export default apiService;
