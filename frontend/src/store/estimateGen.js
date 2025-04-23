/**
 * Vuex store module for the AI conversation estimate generation workflow
 */

import estimatesV2Service from '@/services/estimatesV2.service.js';

// Initial state
const state = {
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
};

// Getters
const getters = {
  getPhase: state => state.phase,
  getClarify: state => state.clarify,
  getItems: state => state.items,
  isLoading: state => state.loading,
  getError: state => state.error,
  getAssessment: state => state.assessment,
  getOptions: state => state.options
};

// Actions
const actions = {
  /**
   * Start the estimate generation process with an assessment
   * @param {Object} context - Vuex context
   * @param {Object} payload - Contains assessment text and optional settings
   * @returns {Promise} - Result of the operation
   */
  async startGeneration({ commit }, payload) {
    commit('SET_LOADING', true);
    commit('SET_ERROR', null);
    
    try {
      // Save the assessment text for later use
      commit('SET_ASSESSMENT', payload.assessment);
      
      // Merge custom options if provided
      if (payload.options) {
        commit('SET_OPTIONS', {
          ...state.options,
          ...payload.options
        });
      }
      
      // Call the API
      const response = await estimatesV2Service.generate({
        assessment: payload.assessment,
        options: payload.options || state.options
      });
      
      // Process the response based on the phase
      if (response.data?.phase === 'clarify') {
        commit('SET_PHASE', 'clarify');
        commit('SET_CLARIFY', {
          requiredMeasurements: response.data.requiredMeasurements || [],
          questions: response.data.questions || []
        });
      } else if (response.data?.phase === 'done') {
        commit('SET_PHASE', 'review');
        commit('SET_ITEMS', response.data.items || []);
      } else {
        throw new Error('Unexpected response format');
      }
      
      return { success: true, data: response.data };
    } catch (error) {
      console.error('Error starting estimate generation:', error);
      const errorMessage = error.message || 'Failed to start estimate generation';
      commit('SET_ERROR', errorMessage);
      return { success: false, error: errorMessage };
    } finally {
      commit('SET_LOADING', false);
    }
  },
  
  /**
   * Submit clarifications and continue the estimate generation process
   * @param {Object} context - Vuex context
   * @param {Object} answers - Contains measurements and answers to questions
   * @returns {Promise} - Result of the operation
   */
  async submitClarifications({ commit, state }, answers) {
    commit('SET_LOADING', true);
    commit('SET_ERROR', null);
    
    try {
      // Create an updated assessment with the clarification answers
      const updatedAssessment = createUpdatedAssessment(state.assessment, answers);
      
      // Call the API again with the updated assessment
      const response = await estimatesV2Service.generate({
        assessment: updatedAssessment,
        options: state.options
      });
      
      // Process the response
      if (response.data?.phase === 'clarify') {
        // Still needs more clarification
        commit('SET_CLARIFY', {
          requiredMeasurements: response.data.requiredMeasurements || [],
          questions: response.data.questions || []
        });
      } else if (response.data?.phase === 'done') {
        commit('SET_PHASE', 'review');
        commit('SET_ITEMS', response.data.items || []);
      } else {
        throw new Error('Unexpected response format');
      }
      
      return { success: true, data: response.data };
    } catch (error) {
      console.error('Error submitting clarifications:', error);
      const errorMessage = error.message || 'Failed to submit clarifications';
      commit('SET_ERROR', errorMessage);
      return { success: false, error: errorMessage };
    } finally {
      commit('SET_LOADING', false);
    }
  },
  
  /**
   * Accept a catalog match for an item
   * @param {Object} context - Vuex context
   * @param {Object} payload - Contains index and productId
   */
  acceptMatch({ commit, state }, { index, productId }) {
    if (index >= 0 && index < state.items.length) {
      // Find the match details from the matches array
      const match = state.items[index].matches?.find(m => m.id === productId);
      
      if (match) {
        // Update the item with the matched product info
        const updatedItems = [...state.items];
        updatedItems[index] = {
          ...updatedItems[index],
          catalogStatus: 'match',
          productId: productId,
          matchedName: match.name,
          score: match.score
        };
        commit('SET_ITEMS', updatedItems);
      }
    }
  },
  
  /**
   * Reset the store to its initial state
   * @param {Object} context - Vuex context
   */
  resetState({ commit }) {
    commit('RESET_STATE');
  }
};

// Mutations
const mutations = {
  SET_PHASE(state, phase) {
    state.phase = phase;
  },
  SET_CLARIFY(state, clarify) {
    state.clarify = clarify;
  },
  SET_ITEMS(state, items) {
    state.items = items;
  },
  SET_LOADING(state, loading) {
    state.loading = loading;
  },
  SET_ERROR(state, error) {
    state.error = error;
  },
  SET_ASSESSMENT(state, assessment) {
    state.assessment = assessment;
  },
  SET_OPTIONS(state, options) {
    state.options = options;
  },
  RESET_STATE(state) {
    state.phase = 'idle';
    state.clarify = {
      requiredMeasurements: [],
      questions: []
    };
    state.items = [];
    state.loading = false;
    state.error = null;
    state.assessment = '';
    state.options = {
      temperature: 0.5,
      hardThreshold: 0.85,
      softThreshold: 0.60
    };
  }
};

/**
 * Helper function to create an updated assessment text with the clarification answers
 * @param {string} originalAssessment - The original assessment text
 * @param {Object} answers - Contains measurements and answers to questions
 * @returns {string} - The updated assessment text
 */
function createUpdatedAssessment(originalAssessment, answers) {
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

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
};
