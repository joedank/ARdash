import apiService from './api.service';

/**
 * Service for interacting with the V2 estimate generation API
 */
const estimatesV2Service = {
  /**
   * Generate an estimate using the smart AI conversation workflow
   * @param {Object} payload - The request payload
   * @param {string} payload.assessment - The assessment text
   * @param {Object} payload.options - Optional settings for generation
   * @returns {Promise} - The API response
   */
  generate(payload) {
    return apiService.post('/estimates/v2/generate', payload);
  },
  
  /**
   * Get status of an estimate generation job
   * @param {string} jobId - The job ID to check status for
   * @returns {Promise} - The API response
   */
  getJobStatus(jobId) {
    return apiService.get(`/estimate-jobs/${jobId}/status`);
  },
  
  /**
   * Poll for job status until complete or failed
   * @param {string} jobId - The job ID to poll
   * @param {number} interval - Polling interval in milliseconds (default: 2000)
   * @param {number} timeout - Maximum polling time in milliseconds (default: 60000)
   * @returns {Promise} - Resolves with the job result or rejects with error
   */
  async pollJobStatus(jobId, interval = 2000, timeout = 60000) {
    const startTime = Date.now();
    
    return new Promise((resolve, reject) => {
      const checkStatus = async () => {
        if (Date.now() - startTime > timeout) {
          return reject(new Error(`Job status polling timed out after ${timeout}ms`));
        }
        
        try {
          const response = await this.getJobStatus(jobId);
          
          if (!response.success) {
            return reject(new Error(response.message || 'Failed to get job status'));
          }
          
          const { state, progress, result, failReason } = response.data;
          
          // If job is completed, resolve with the result
          if (state === 'completed' && result) {
            if (result.success) {
              return resolve(result);
            } else {
              return reject(new Error(result.error || 'Job completed with error'));
            }
          }
          
          // If job failed, reject with the reason
          if (state === 'failed') {
            return reject(new Error(failReason || 'Job failed'));
          }
          
          // Otherwise, wait and check again
          setTimeout(checkStatus, interval);
        } catch (error) {
          return reject(error);
        }
      };
      
      // Start checking
      checkStatus();
    });
  },
  
  /**
   * Cancel an estimate generation job
   * @param {string} jobId - The job ID to cancel
   * @returns {Promise} - The API response
   */
  cancelJob(jobId) {
    return apiService.delete(`/estimate-jobs/${jobId}`);
  }
};

export default estimatesV2Service;
