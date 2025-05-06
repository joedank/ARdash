import apiService from './api.service';

/**
 * Service for interacting with the V2 estimate generation API
 */
const estimatesV2Service = {
  /**
   * Process external LLM response text
   * @param {Object} payload - Payload with the LLM response text
   * @param {string} payload.text - The raw LLM response text
   * @returns {Promise} - The API response
   */
  processExternal(payload) {
    return api.post('/estimates/llm/process-external', payload);
  },
  /**
   * Generate an estimate using the smart AI conversation workflow
   * @param {Object} payload - The request payload
   * @param {string|Object} payload.assessment - The assessment text or structured assessment object
   * @param {string} payload.phase - Optional phase indicator (e.g., 'clarifyDone')
   * @param {Object} payload.options - Optional settings for generation
   * @param {Array<string>} payload.clarifications - Optional array of clarification strings
   * @param {Array<Object>} payload.messages - Optional array of message objects with role and content
   * @returns {Promise} - The API response
   *
   * Note: You can provide either clarifications or messages, not both.
   * If both are provided, messages will take precedence.
   * Clarifications will be automatically converted to messages with role='user'.
   */
  generate(payload) {
    // always include assessmentId; omit empty clarifications/messages
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
