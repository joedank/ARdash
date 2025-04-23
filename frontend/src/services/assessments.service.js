/**
 * Assessments Service
 * 
 * Service for interacting with assessments API endpoints
 */

import apiClient from './api.service';
import { toCamelCase, toSnakeCase } from '../utils/casing';

/**
 * Assessments service for work type detection and management
 */
class AssessmentsService {
  /**
   * Detect work types based on condition text
   * @param {string} conditionText - The condition text to analyze
   * @returns {Promise<Array>} Array of matching work types with confidence scores
   */
  async detectWorkTypes(conditionText) {
    try {
      // Skip detection for very short text
      if (!conditionText || conditionText.length < 15) {
        console.warn('Condition text too short for work type detection');
        return [];
      }

      const response = await apiClient.post('/api/assessments/detect-work-types', {
        condition: conditionText
      });

      if (response.data?.success && Array.isArray(response.data.data)) {
        // Convert to camelCase
        return toCamelCase(response.data.data);
      }

      return [];
    } catch (error) {
      console.error('Error detecting work types:', error);
      return [];
    }
  }

  /**
   * Toggle a work type in the assessment
   * @param {Array} currentWorkTypes - Current array of work type IDs
   * @param {Object} workType - Work type to toggle
   * @returns {Array} Updated array of work type IDs
   */
  toggleWorkType(currentWorkTypes, workType) {
    if (!workType || !workType.workTypeId) {
      console.warn('Invalid work type provided for toggle');
      return currentWorkTypes;
    }

    // Create a new array to avoid modifying the original
    const workTypes = Array.isArray(currentWorkTypes) ? [...currentWorkTypes] : [];
    
    // Check if the work type is already in the array
    const index = workTypes.findIndex(id => id === workType.workTypeId);
    
    // Toggle the work type
    if (index !== -1) {
      // Remove the work type
      workTypes.splice(index, 1);
    } else {
      // Add the work type
      workTypes.push(workType.workTypeId);
    }
    
    return workTypes;
  }

  /**
   * Get assessment data for an estimate
   * @param {string} estimateId - Estimate ID
   * @returns {Promise<Object>} Assessment data
   */
  async getAssessmentForEstimate(estimateId) {
    try {
      const response = await apiClient.get(`/assessment/for-estimate/${estimateId}`);
      
      if (response.data) {
        return toCamelCase(response.data);
      }
      
      return null;
    } catch (error) {
      console.error('Error fetching assessment for estimate:', error);
      return null; // Return null to allow the application to continue
    }
  }
}

// Export singleton instance
export default new AssessmentsService();
