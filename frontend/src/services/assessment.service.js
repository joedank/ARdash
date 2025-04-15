import api from './api.service';
import { toCamelCase, toSnakeCase } from '@/utils/casing';

// Assessment service for handling communication with the assessment API
const assessmentService = {
  // Get assessment data for an estimate
  async getAssessmentForEstimate(estimateId) {
    try {
      const response = await api.get(`/api/assessment/for-estimate/${estimateId}`);
      return response.data;
    } catch (error) {
      console.error('Error fetching assessment for estimate:', error);
      return null; // Return null to allow the application to continue
    }
  }
};

export { assessmentService };
