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
    }
  }),

  getters: {
    getPhase: (state) => state.phase,
    getClarify: (state) => state.clarify,
    getItems: (state) => state.items,
    isLoading: (state) => state.loading,
    getError: (state) => state.error,
    getAssessment: (state) => state.assessment,
    getOptions: (state) => state.options
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

        // Call the API
        const response = await estimatesV2Service.generate({
          assessment: payload.assessment,
          options: payload.options || this.options
        });

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

        return { success: true, data: response.data };
      } catch (error) {
        console.error('Error starting estimate generation:', error);
        const errorMessage = error.message || 'Failed to start estimate generation';
        this.error = errorMessage;
        return { success: false, error: errorMessage };
      } finally {
        this.loading = false;
      }
    },

    /**
     * Submit clarifications and continue the estimate generation process
     * @param {Object} answers - Contains measurements and answers to questions
     * @returns {Promise} - Result of the operation
     */
    async submitClarifications(answers) {
      this.loading = true;
      this.error = null;

      try {
        // Create a structured object with the original assessment and answers
        const updatedAssessment = {
          originalText: this.assessment,
          measurements: answers.measurements,
          questionAnswers: answers.questionAnswers
        };

        // Keep the text version for other uses if needed
        const updatedAssessmentText = this.createUpdatedAssessment(this.assessment, answers);

        // Call the API again with the structured assessment object and phase=clarifyDone
        const response = await estimatesV2Service.generate({
          assessment: updatedAssessment, // Send structured object instead of text
          phase: 'clarifyDone', // Add phase parameter to indicate clarifications are done
          options: this.options
        });

        // Process the response
        if (response.data?.phase === 'clarify') {
          // Still needs more clarification
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

        return { success: true, data: response.data };
      } catch (error) {
        console.error('Error submitting clarifications:', error);
        const errorMessage = error.message || 'Failed to submit clarifications';
        this.error = errorMessage;
        return { success: false, error: errorMessage };
      } finally {
        this.loading = false;
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
