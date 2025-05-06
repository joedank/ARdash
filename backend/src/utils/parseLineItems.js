/**
 * Utility for parsing line items from AI responses
 */
const logger = require('./logger');
const ApiError = require('../utils/api-error');
const { z } = require('zod');

const lineItemSchema = z.object({
  description: z.string(),
  quantity: z.number().positive(),
  unitCost: z.number().positive(),
  laborHours: z.number().nonnegative(),
  parentBucket: z.string(),
  total: z.number().positive()
}).strict();

const lineItemsSchema = z.array(lineItemSchema);

/**
 * Parse line items from AI response text
 * @param {string} response - Raw text from AI response
 * @returns {Array|Object} - Parsed line items
 * @throws {ApiError} - If parsing fails
 */
function parseLineItems(response) {
  try {
    // Try to find JSON in the response (non-greedy match)
    const jsonMatch = response.match(/\{[\s\S]*?\}|\[[\s\S]*?\]/);
    if (!jsonMatch) {
      logger.error('Line-item parse failure - No JSON block found', { response });
      throw new ApiError(422, 'Could not parse AI line-items', { rawText: response });
    }
    
    // Parse and validate the JSON
    const parsed = JSON.parse(jsonMatch[0]);
    const validated = lineItemsSchema.parse(parsed);
    return validated;
  } catch (e) {
    logger.error('Line-item parse failure', { response, error: e.message });
    throw new ApiError(422, 'Could not parse AI line-items', { rawText: response });
  }
}

module.exports = parseLineItems;
