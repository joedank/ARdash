/**
 * Service for building prompts for LLM interactions
 */
const logger = require('../utils/logger');

/**
 * Build a prompt for estimate generation
 * @param {Object} assessment - Assessment data
 * @param {Object} options - Options for prompt generation
 * @returns {Object} - Prompt object with system, user, and messages
 */
function buildEstimatePrompt(assessment, options = {}) {
  // Extract assessment text
  const assessmentText = typeof assessment === 'string' 
    ? assessment 
    : (assessment.formattedData || assessment.formattedMarkdown || JSON.stringify(assessment));
  
  // Build user prompt
  const userPrompt = `Generate a detailed construction estimate based on this assessment:\n${assessmentText}`;
  
  // Build system prompt
  const systemPrompt = [
    'You are a senior construction estimator.',
    'Analyze the assessment and create a detailed estimate with appropriate line items.',
    'Consider all measurements, materials, and conditions in the assessment.',
  ].join(' ');
  
  // Return the prompt object
  return {
    system: systemPrompt,
    user: userPrompt,
    messages: [
      {
        role: 'assistant',
        content: JSON.stringify([{
          "description": "Example",
          "quantity": 1,
          "unit": "each",
          "unitCost": 10,
          "laborHours": 0.5,
          "parentBucket": "demo",
          "total": 10
        }])
      },
      {
        role: 'system',
        content: [
          'You are a senior construction estimator.',
          'Return **ONLY** a JSON array where each element has:',
          '{ "description": string, "quantity": number, "unit": string, "unitCost": number, "laborHours": number, "parentBucket": string, "total": number }',
          'No markdown, no code fences, no commentary.'
        ].join(' ')
      }
    ]
  };
}

module.exports = {
  buildEstimatePrompt
};
