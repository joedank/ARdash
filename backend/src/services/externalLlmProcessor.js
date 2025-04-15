const logger = require('../utils/logger');

/**
 * Process external LLM response to generate estimate line items
 * @param {string} responseText - Raw response text from external LLM
 * @param {Object} assessmentData - Optional assessment data
 * @returns {Promise<Object>} - Processed line items or error
 */
async function processExternalLlmResponse(responseText, assessmentData) {
  try {
    logger.info('Processing external LLM response');
    
    if (!responseText || typeof responseText !== 'string' || responseText.trim() === '') {
      return {
        success: false,
        error: 'Response text is required and cannot be empty',
        diagnosticCode: 'EMPTY_RESPONSE'
      };
    }

    // Try to extract JSON if it's embedded in a markdown code block
    let jsonContent = responseText.trim();
    
    // Extract JSON from markdown code blocks if present
    const jsonBlockMatch = jsonContent.match(/```(?:json)?\\s*([\\s\\S]*?)```/);
    if (jsonBlockMatch && jsonBlockMatch[1]) {
      jsonContent = jsonBlockMatch[1].trim();
    }
    
    // Try to parse as JSON
    let parsedData;
    try {
      parsedData = JSON.parse(jsonContent);
      logger.info('Successfully parsed external LLM response as JSON');
    } catch (parseError) {
      // If parsing fails, try other extraction strategies
      logger.warn(`JSON parsing failed: ${parseError.message}`);
      
      // Try to extract JSON by looking for array brackets
      const jsonMatch = responseText.match(/\[\s*{.*}\s*\]/s);
      if (jsonMatch && jsonMatch[0]) {
        try {
          parsedData = JSON.parse(jsonMatch[0]);
          logger.info('Successfully parsed JSON array from response');
        } catch (e) {
          logger.warn(`Failed to parse JSON array match: ${e.message}`);
        }
      }
      
      if (!parsedData) {
        return {
          success: false,
          error: 'Unable to parse valid line items from the response',
          diagnosticCode: 'PARSING_ERROR'
        };
      }
    }
    
    // Handle different response formats
    let lineItems;
    
    // If it's already an array of line items
    if (Array.isArray(parsedData)) {
      lineItems = parsedData;
    }
    // If it's an object with a line_items property
    else if (parsedData && parsedData.line_items && Array.isArray(parsedData.line_items)) {
      lineItems = parsedData.line_items;
    }
    // Any other format is not supported
    else {
      return {
        success: false,
        error: 'The response format is not supported. Expected an array of line items or an object with a line_items array',
        diagnosticCode: 'UNSUPPORTED_FORMAT'
      };
    }
    
    // Validate and post-process the line items
    const processedItems = postProcessItems(lineItems, assessmentData);
    
    logger.info(`Successfully processed ${processedItems.length} line items from external LLM response`);
    
    return {
      success: true,
      data: processedItems,
      message: 'Successfully processed external LLM response'
    };
  } catch (error) {
    logger.error(`Error processing external LLM response: ${error.message}`, { error });
    return {
      success: false,
      error: `Failed to process external LLM response: ${error.message}`,
      diagnosticCode: 'PROCESSING_ERROR'
    };
  }
}

/**
 * Post-processes line items to ensure consistent formatting and values.
 * @param {Array} items - Raw line items from LLM
 * @param {Object} assessmentData - Optional assessment data to enhance processing
 * @returns {Array} - Processed items with consistent values
 */
function postProcessItems(items, assessmentData = null) {
  if (!Array.isArray(items)) return [];

  try {
    // Try to validate the items first
    validateLineItems(items);
  } catch (validationError) {
    logger.warn(`Line items validation failed, forcing standardization: ${validationError.message}`);
    // Continue with processing anyway to standardize format
  }

  // Generate a unique assessment source identifier if we have assessment data
  const assessmentSourceId = assessmentData && assessmentData.projectId ? 
    `assessment-${assessmentData.projectId}` : 
    `external-${Date.now()}`;

  return items.map(item => {
    // Ensure all required fields exist in the standard format
    const processedItem = {
      description: String(item.description || item.service_name || "Unspecified work"),
      quantity: parseFloat(item.quantity) || 1,
      unit: String(item.unit || "each").toLowerCase(),
      unitPrice: parseFloat(item.unitPrice || item.unit_price || item.rate || 0),
      sourceType: String(item.sourceType || item.source_type || (assessmentData ? "assessment" : "external")),
      sourceId: String(item.sourceId || item.source_id || assessmentSourceId + `-${Math.random().toString(36).substring(2, 7)}`)
    };

    // Calculate total if not provided or incorrect
    processedItem.total = Math.round((processedItem.quantity * processedItem.unitPrice) * 100) / 100;
    
    // Add data for assessment linking if available
    if (assessmentData && assessmentData.projectId) {
      processedItem.sourceData = {
        projectId: assessmentData.projectId,
        assessmentDate: assessmentData.date || new Date().toISOString().split('T')[0],
        assessmentType: "external"
      };
    }

    return processedItem;
  });
}

/**
 * Validates the line items structure
 * @param {Array} items - The line items to validate
 * @throws {Error} If validation fails
 */
function validateLineItems(items) {
  if (!Array.isArray(items)) {
    throw new Error("Response must be a valid array of line items");
  }

  if (items.length === 0) {
    throw new Error("Response contains no line items");
  }

  // Validate each line item has the required fields
  items.forEach((item, index) => {
    // Check required fields
    if (!item.description && !item.service_name) {
      throw new Error(`Line item at index ${index} is missing required 'description' or 'service_name'`);
    }

    // Quantity is required but we can default to 1 if missing
    if (item.quantity !== undefined && item.quantity !== null && isNaN(Number(item.quantity))) {
      throw new Error(`Line item at index ${index} has invalid 'quantity'; must be a number`);
    }

    // Unit is required but we can default to 'each' if missing
    if (item.unit !== undefined && typeof item.unit !== 'string') {
      throw new Error(`Line item at index ${index} has invalid 'unit'; must be a string`);
    }

    // Unit price is required but we can default to 0 if missing
    const price = item.unitPrice || item.unit_price || item.rate;
    if (price !== undefined && price !== null && isNaN(Number(price))) {
      throw new Error(`Line item at index ${index} has invalid price; must be a number`);
    }
  });

  return true;
}

module.exports = {
  processExternalLlmResponse
};
