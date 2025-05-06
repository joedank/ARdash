'use strict';

const languageModelProvider = require('./languageModelProvider');
const logger = require('../utils/logger');
const { z } = require('zod');
const NodeCache = require('node-cache');

// Create a cache with 10-minute TTL for draft work types
const cache = new NodeCache({ stdTTL: 600 });

// Map of valid units for each measurement type
const unitMap = {
  area: ['sq ft', 'sq yd', 'sq m'],
  linear: ['ft', 'in', 'yd', 'm'],
  quantity: ['each', 'job', 'set']
};

/**
 * Schema for validating generated draft work types
 */
const DraftWorkTypeSchema = z.object({
  name: z.string().min(3).max(255),
  parentBucket: z.enum([
    'Interior-Structural', 
    'Interior-Finish', 
    'Exterior-Structural', 
    'Exterior-Finish', 
    'Mechanical'
  ]),
  measurementType: z.enum(['area', 'linear', 'quantity']),
  suggestedUnits: z.string().min(1).max(50)
}).refine(
  data => unitMap[data.measurementType].includes(data.suggestedUnits),
  {
    message: 'Suggested units must be compatible with the measurement type',
    path: ['suggestedUnits'] 
  }
);

/**
 * Service for generating draft work types using language models
 */
class DraftWorkTypeService {
  /**
   * Generate draft work types from text fragments
   * @param {string[]} fragments - Text fragments that didn't match existing work types
   * @returns {Promise<Array>} - Array of draft work type objects
   */
  async generateDrafts(fragments) {
    if (!fragments?.length) return [];
    
    try {
      // Generate cache key from normalized fragments
      const key = JSON.stringify(fragments.map(f => f.trim().toLowerCase()));
      
      // Try to get from cache first
      const cachedResults = cache.get(key);
      if (cachedResults) {
        logger.debug('Returning cached draft work types for fragments');
        return cachedResults;
      }
      
      logger.debug('Cache miss for draft work types, generating from LLM');
      
      // If not in cache, generate from LLM
      const prompt = this.buildPrompt(fragments);
      logger.debug('Sending draft work type generation prompt to language model');
      
      const response = await languageModelProvider.generateChatCompletion(prompt.messages, {
        temperature: 0.2,
        max_tokens: 512
      });
      
      if (!response?.choices?.[0]?.message?.content) {
        logger.warn('Empty response from language model for draft work types');
        return [];
      }
      
      // Parse the JSON response
      let draftWorkTypes;
      try {
        draftWorkTypes = languageModelProvider.parseJsonResponse(response.choices[0].message.content);
      } catch (error) {
        logger.error('Error parsing language model response:', error);
        return [];
      }
      
      if (!Array.isArray(draftWorkTypes)) {
        logger.warn('Invalid response format from language model, expected array');
        return [];
      }
      
      // Validate each draft work type against the schema
      const validatedDrafts = [];
      for (const draft of draftWorkTypes) {
        try {
          const validatedDraft = DraftWorkTypeSchema.parse(draft);
          validatedDrafts.push(validatedDraft);
        } catch (validationError) {
          logger.warn('Invalid draft work type:', draft, validationError.errors);
          // Continue with other drafts
        }
      }
      
      // Cache the validated results
      cache.set(key, validatedDrafts);
      
      return validatedDrafts;
    } catch (error) {
      logger.error('Error generating draft work types:', error);
      return [];
    }
  }
  
  /**
   * Build the prompt for draft work type generation
   * @param {string[]} fragments - Text fragments that didn't match existing work types
   * @returns {Object} - Prompt object with messages
   * @private
   */
  buildPrompt(fragments) {
    const systemPrompt = `You are a construction expert that specializes in categorizing repair tasks for mobile homes.

Your job is to analyze each construction task described and create standardized work types with the following properties:
- name: A clear, concise name for the work type (3-50 chars)
- parentBucket: One of: Interior-Structural, Interior-Finish, Exterior-Structural, Exterior-Finish, Mechanical
- measurementType: One of: area, linear, quantity
- suggestedUnits: Appropriate units based on measurementType:
  - For area: "sq ft", "sq yd", or "sq m"
  - For linear: "ft", "in", "yd", or "m"
  - For quantity: "each", "job", or "set"

Respond ONLY with a JSON array of work type objects.`;

    const userPrompt = `For each construction task described below, analyze it and propose appropriate work type objects in JSON format:

${fragments.map((fragment, index) => `[${index + 1}] "${fragment}"`).join('\n\n')}

Return a JSON array containing a work type object for each identified task. Use this format:
[
  {
    "name": "Roof Shingle Replacement",
    "parentBucket": "Exterior-Finish",
    "measurementType": "area",
    "suggestedUnits": "sq ft"
  },
  ...
]`;

    return {
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt }
      ]
    };
  }
}

module.exports = new DraftWorkTypeService();
