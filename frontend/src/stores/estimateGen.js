import { defineStore } from 'pinia';
import estimatesV2Service from '@/services/estimatesV2.service.js';

/**
 * Pinia store for the AI conversation estimate generation workflow
 */
export const useEstimateGenStore = defineStore('estimateGen', {
  state: () => ({
    phase: 'idle',
    clarify: {
      requiredMeasurements: [],
      questions: []
    },
    items: [],
    loading: false,
    error: null,
    assessment: '',
    options: {
      temperature: 0.5,
      hardThreshold: 0.85,
      softThreshold: 0.60
    },
    jobId: null,
    progress: 0,
    pollingActive: false
  }),

  getters: {
    getPhase: (state) => state.phase,
    getClarify: (state) => state.clarify,
    getItems: (state) => state.items,
    isLoading: (state) => state.loading,
    getError: (state) => state.error,
    getAssessment: (state) => state.assessment,
    getOptions: (state) => state.options,
    getJobId: (state) => state.jobId,
    getProgress: (state) => state.progress,
    isPollingActive: (state) => state.pollingActive
  },

  actions: {
    /**
     * Start the estimate generation process with an assessment
     * @param {Object} payload - Contains assessment text and optional settings
     * @returns {Promise} - Result of the operation
     */
    async startGeneration(payload) {
      this.loading = true;
      this.error = null;
      this.progress = 0;
      this.pollingActive = false;
      this.jobId = null;

      try {
        // Save the assessment text for later use
        this.assessment = payload.assessment;

        // Merge custom options if provided
        if (payload.options) {
          this.options = {
            ...this.options,
            ...payload.options
          };
        }

        // Call the API - for v2/generate endpoints, this will immediately return a job ID
        const response = await estimatesV2Service.generate({
          assessment: payload.assessment,
          options: payload.options || this.options
        });

        // If we received a jobId, start polling for job status
        if (response.data?.jobId) {
          this.jobId = response.data.jobId;
          this.pollingActive = true;
          
          // Start polling for job status
          this.pollJobStatus();
          
          return { success: true, jobId: this.jobId };
        } else {
          // Handle legacy response format (immediate result)
          return this.handleLegacyResponse(response);
        }
      } catch (error) {
        console.error('Error starting estimate generation:', error);
        const errorMessage = error.message || 'Failed to start estimate generation';
        this.error = errorMessage;
        return { success: false, error: errorMessage };
      } finally {
        // Don't set loading to false here - it will be set when polling completes
        // Keep loading true while polling is active
      }
    },
    
    /**
     * Poll for job status until completion
     */
    async pollJobStatus() {
      if (!this.jobId || !this.pollingActive) return;
      
      try {
        // Get job status
        const response = await estimatesV2Service.getJobStatus(this.jobId);
        
        if (!response.success) {
          throw new Error(response.message || 'Failed to get job status');
        }
        
        const { state, progress, result, failReason } = response.data;
        
        // Update progress
        this.progress = progress || 0;
        
        // If job is completed, process the result
        if (state === 'completed' && result) {
          if (result.success) {
            // Process result
            this.items = result.data || [];
            this.phase = 'review';
          } else {
            // Handle error
            throw new Error(result.error || 'Job completed with error');
          }
          
          // End polling
          this.pollingActive = false;
          this.loading = false;
          return;
        }
        
        // If job failed, handle error
        if (state === 'failed') {
          throw new Error(failReason || 'Job failed');
        }
        
        // Otherwise, continue polling after delay
        setTimeout(() => this.pollJobStatus(), 2000);
      } catch (error) {
        console.error('Error polling job status:', error);
        this.error = error.message || 'Failed to poll job status';
        this.pollingActive = false;
        this.loading = false;
      }
    },
    
    /**
     * Handle legacy response format (immediate result without job)
     * @param {Object} response - API response
     * @returns {Object} - Result of the operation
     */
    handleLegacyResponse(response) {
      // Process the response based on the phase
      if (response.data?.phase === 'clarify') {
        this.phase = 'clarify';
        this.clarify = {
          requiredMeasurements: response.data.requiredMeasurements || [],
          questions: response.data.questions || []
        };
      } else if (response.data?.phase === 'done') {
        this.phase = 'review';
        this.items = response.data.items || [];
      } else {
        throw new Error('Unexpected response format');
      }
      
      this.loading = false;
      return { success: true, data: response.data };
    },

    /**
     * Submit clarifications and continue the estimate generation process
     * @param {Object} answers - Contains measurements and answers to questions
     * @returns {Promise} - Result of the operation
     */
    async submitClarifications(answers) {
      this.loading = true;
      this.error = null;
      this.progress = 0;
      this.pollingActive = false;
      this.jobId = null;

      try {
        // Create a structured object with the original assessment and answers
        const updatedAssessment = {
          originalText: this.assessment,
          measurements: answers.measurements,
          questionAnswers: answers.questionAnswers
        };

        // Call the API again with the structured assessment object and phase=clarifyDone
        // This should also return a jobId now
        const response = await estimatesV2Service.generate({
          assessment: updatedAssessment, // Send structured object instead of text
          phase: 'clarifyDone', // Add phase parameter to indicate clarifications are done
          options: this.options
        });

        // If we received a jobId, start polling for job status
        if (response.data?.jobId) {
          this.jobId = response.data.jobId;
          this.pollingActive = true;
          
          // Start polling for job status
          this.pollJobStatus();
          
          return { success: true, jobId: this.jobId };
        } else {
          // Handle legacy response format (immediate result)
          return this.handleLegacyResponse(response);
        }
      } catch (error) {
        console.error('Error submitting clarifications:', error);
        const errorMessage = error.message || 'Failed to submit clarifications';
        this.error = errorMessage;
        return { success: false, error: errorMessage };
      } finally {
        // Loading state managed by polling
      }
    },

    /**
     * Accept a catalog match for an item
     * @param {Object} payload - Contains index and productId
     */
    acceptMatch({ index, productId }) {
      if (index >= 0 && index < this.items.length) {
        // Find the match details from the matches array
        const match = this.items[index].matches?.find(m => m.id === productId);

        if (match) {
          // Update the item with the matched product info
          const updatedItems = [...this.items];
          updatedItems[index] = {
            ...updatedItems[index],
            catalogStatus: 'match',
            productId: productId,
            matchedName: match.name,
            score: match.score
          };
          this.items = updatedItems;
        }
      }
    },

    /**
     * Reset the store to its initial state
     */
    resetState() {
      this.phase = 'idle';
      this.clarify = {
        requiredMeasurements: [],
        questions: []
      };
      this.items = [];
      this.loading = false;
      this.error = null;
      this.assessment = '';
      this.options = {
        temperature: 0.5,
        hardThreshold: 0.85,
        softThreshold: 0.60
      };
    },

    /**
     * Helper function to create an updated assessment text with the clarification answers
     * @param {string} originalAssessment - The original assessment text
     * @param {Object} answers - Contains measurements and answers to questions
     * @returns {string} - The updated assessment text
     */
    createUpdatedAssessment(originalAssessment, answers) {
      // Start with the original assessment
      let updatedText = originalAssessment;

      // Add a separator
      updatedText += '\n\n--- ADDITIONAL INFORMATION ---\n\n';

      // Add measurements if provided
      if (answers.measurements && Object.keys(answers.measurements).length > 0) {
        updatedText += 'Measurements:\n';
        for (const [key, value] of Object.entries(answers.measurements)) {
          updatedText += `- ${key}: ${value}\n`;
        }
        updatedText += '\n';
      }

      // Add answers to questions if provided
      if (answers.questionAnswers && Object.keys(answers.questionAnswers).length > 0) {
        updatedText += 'Answers:\n';
        for (const [question, answer] of Object.entries(answers.questionAnswers)) {
          updatedText += `- Q: ${question}\n  A: ${answer}\n`;
        }
      }

      return updatedText;
    }
  }
});
