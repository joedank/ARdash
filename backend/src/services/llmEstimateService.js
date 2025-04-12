const deepSeekServiceInstance = require('./deepseekService');
const logger = require('../utils/logger');
const { formatAssessmentToMarkdown } = require("./assessmentFormatterService");
// Import models
const { LLMPrompt, Product } = require('../models');
const { Op } = require('sequelize');
const stringSimilarity = require('string-similarity');

// --- Service Implementation ---

class LLMEstimateService {
  constructor(deepSeekService) {
    if (!deepSeekService) {
      throw new Error("DeepSeekService instance is required.");
    }
    this.deepSeekService = deepSeekService;

    // Cache for prompts to avoid excessive database queries
    this.promptCache = {};
    this.promptCacheTime = 0;
    // Cache expiration time (5 minutes)
    this.CACHE_EXPIRY = 5 * 60 * 1000;
  }

  /**
   * Retrieves a prompt from the database or cache
   * @param {string} name - The name of the prompt to retrieve
   * @returns {Promise<string>} - The prompt text
   * @private
   */
  async getPrompt(name) {
    // Check if cache needs refreshing
    const now = Date.now();
    if (!this.promptCache[name] || now - this.promptCacheTime > this.CACHE_EXPIRY) {
      try {
        const prompt = await LLMPrompt.findOne({ where: { name } });
        if (prompt) {
          this.promptCache[name] = prompt.prompt_text;
          this.promptCacheTime = now;
        } else {
          logger.error(`Prompt "${name}" not found in database`);
          // Return a default fallback if the prompt is missing
          return this._getDefaultPrompt(name);
        }
      } catch (error) {
        logger.error(`Error fetching prompt "${name}":`, error);
        return this._getDefaultPrompt(name);
      }
    }

    return this.promptCache[name];
  }

  /**
   * Returns default prompts for fallback
   * @param {string} name - The name of the prompt
   * @returns {string} - Default prompt text
   * @private
   */
  _getDefaultPrompt(name) {
    // Fallback defaults in case database query fails
    const defaults = {
      initialAnalysis: `
Role: You are an expert estimator analyzing construction project requirements for a small mobile home repair and renovation company. Our services span a variety of repairs including roofing, door and window fixes, leveling, subfloor work, remodeling, bathroom updates, and painting.
Task: Analyze the given project description and identify the repair type(s) present. Based on the identified repair type(s), generate a JSON object containing:
- repair_type: a string indicating the primary repair category (e.g., "roofing", "door", "window", "remodeling", "painting").
- required_measurements: an array of strings specifying only the necessary measurements for the job.
   * For roofing:
       - If it is a full roof replacement, include full roof measurements (e.g., "roof_square_footage", "roof_pitch").
       - If it is a localized repair (e.g., "tile removal to locate a leak"), include only localized measurements (e.g., "localized_area_sq_ft").
   * For door and window repairs:
       - Request counts and dimensions as needed.
   * For remodeling or painting:
       - Request room or surface area measurements as applicable.
- required_services: an array of strings listing the repair services needed.
- clarifying_questions: an array of strings for any questions that help clarify missing or ambiguous details. Ensure the questions are directly pertinent to the identified repair type and do not ask for extraneous data.
Guidelines:
1. Identify the repair type(s) by examining keywords in the description (e.g., "leak", "remove tiles" imply roofing; "door", "window" imply fixture repairs).
2. If the description specifies a localized repair (e.g., "remove tiles to locate a leak"), avoid asking for full-scale measurements such as total roof square footage.
3. Generate clarifying questions only when the provided description lacks necessary details, ensuring they relate directly to the task (for example, ask for the affected area's dimensions rather than the entire roof if the job is partial).
4. Base your questions on our industry practices and the standard service types we provide.
Example Input: "I have to remove ceramic tiles on a roof due to a leak. We'll remove tiles to locate the water intrusion point and replace the underlayment. The wood appears intact. A full roof replacement is not necessary."
Example Output:
{
  "repair_type": "roofing",
  "required_measurements": ["localized_area_sq_ft"],
  "required_services": ["tile_removal", "underlayment_replacement"],
  "clarifying_questions": ["What is the approximate size of the affected area? (Please provide only localized measurements.)"]
}
Focus ONLY on repair and service work relevant to our technicians.
Input Description:`,

      initialAnalysisWithAssessment: `
Role: You are an expert estimator analyzing construction project requirements for a small mobile home repair and renovation company. Our services span a variety of repairs including roofing, door and window fixes, leveling, subfloor work, remodeling, bathroom updates, and painting.
Task: Using BOTH the project description AND the provided assessment data, identify the repair type(s) present and generate a JSON object containing:
- repair_type: a string indicating the primary repair category (e.g., "roofing", "door", "window", "remodeling", "painting").
- required_measurements: an array of strings specifying only the necessary measurements for the job. Use measurements from the assessment data if available.
   * For roofing:
       - If it is a full roof replacement, include full roof measurements (e.g., "roof_square_footage", "roof_pitch").
       - If it is a localized repair (e.g., "tile removal to locate a leak"), include only localized measurements (e.g., "localized_area_sq_ft").
   * For door and window repairs:
       - Request counts and dimensions as needed.
   * For remodeling or painting:
       - Request room or surface area measurements as applicable.
- required_services: an array of strings listing the repair services needed.
- clarifying_questions: an array of strings for any questions that help clarify missing or ambiguous details that were NOT included in the assessment data. Focus only on information that's still needed.

Guidelines:
1. Prioritize measurements and conditions found in the assessment data.
2. Only include questions for information that ISN'T provided in either the project description or assessment data.
3. When possible, use precise values from assessment data rather than asking for estimates.
4. If the assessment includes measurements, avoid asking for the same measurements in your clarifying questions.
5. If assessment data conflicts with the description, prioritize assessment data as it's more reliable.
6. Focus ONLY on repair and service work relevant to our technicians.

Example Input:
Project Description: "I need to replace the roof on my mobile home."
Assessment Data:
- Measurements: Roof dimensions 60' x 15', pitch 3:12
- Condition: Shingles worn and curling, some soft spots in decking
- Materials: Requires 3-tab shingles, new underlayment, limited decking replacement

Example Output:
{
  "repair_type": "roofing",
  "required_measurements": ["roof_square_footage", "roof_pitch"],
  "required_services": ["roof_tear_off", "deck_repair", "underlayment_installation", "shingle_installation"],
  "clarifying_questions": ["Are there any penetrations (vents, skylights) in the roof?", "Do you want to upgrade from 3-tab to architectural shingles?"]
}

Input Description:`,

      serviceMatch: `
Role: You are a service specialist matching project needs to available services.
Context: You have access to the following data:
- Project requirements
- Available service catalog
- Measurements and specifications

Task: Match project needs to existing services or suggest new services.
Format: Return a JSON object with:
- matched_services: array of existing service IDs
- new_service_suggestions: array of suggested new services
- estimated_hours: calculated labor hours for each service

Base your estimates on industry standards and best practices.`,

      laborHoursCalculation: `
Role: You are an estimation expert calculating required labor hours.
Task: Calculate precise labor hours needed for each service based on measurements.
Rules:
- Include standard labor rates
- Account for job complexity factors
- Consider crew size requirements
- Factor in site conditions and access

Format: Return a JSON object with detailed calculations and explanations.`,

      newService: `
Role: You are a service catalog manager creating new service entries.
Task: Generate complete service specifications for new offerings.
Required Fields:
- name: Clear, standardized service name
- description: Detailed service description
- unit: Appropriate unit of measurement (typically hours or fixed fee)
- type: Service classification
- base_rate: Standard hourly or fixed fee rate

Format: Return a JSON object matching the service catalog schema.`
    };

    return defaults[name] || 'No prompt available.';
  }

  /**
   * Generates estimate items from assessment using LLM.
   * @param {Object} assessment - Raw assessment object
   * @param {Object} options - Optional controls { aggressiveness, mode }
   * @returns {Object} Response containing estimate line items and optional debug info
   */
  async generateEstimateFromAssessment(assessment, options = {}) {
    try {
      // Apply defaults and validation
      const validOptions = {
        aggressiveness: this._validateAggressiveness(options.aggressiveness ?? 0.6),
        mode: this._validateMode(options.mode ?? "replace-focused"),
        debug: options.debug === true
      };

      // Format assessment to markdown - reuse the formatter from Milestone 1
      let formattedMarkdown;

      // If assessment has pre-formatted markdown, use it directly
      if (assessment.formattedMarkdown) {
        formattedMarkdown = assessment.formattedMarkdown;
        logger.info("Using pre-formatted assessment markdown");
      } else {
        // Otherwise format it now using the Milestone 1 formatter
        formattedMarkdown = formatAssessmentToMarkdown(assessment);
        logger.info("Formatted assessment data to markdown");
      }

      // Build LLM prompt with the formatted markdown
      const prompt = this._buildPrompt(formattedMarkdown, validOptions.aggressiveness, validOptions.mode);

      // Log the request with additional context
      logger.debug(`LLM Estimate Request - Mode: ${validOptions.mode}, Aggressiveness: ${validOptions.aggressiveness}`);
      logger.logLLM('estimate_request', {
        assessmentId: assessment.id || 'unknown',
        markdownLength: formattedMarkdown.length,
        mode: validOptions.mode,
        aggressiveness: validOptions.aggressiveness
      });

      // Call LLM with appropriate parameters
      const llmResponse = await this.deepSeekService.generateChatCompletion([
        {
          role: "system",
          content: "You are a professional construction estimator. Respond ONLY with a valid JSON array of line items."
        },
        {
          role: "user",
          content: prompt,
        }
      ], 'deepseek-chat', false, {
        temperature: this._calculateTemperature(validOptions.aggressiveness),
        max_tokens: 2000
      });

      if (!llmResponse || !llmResponse.choices || llmResponse.choices.length === 0) {
        throw new Error("Empty or invalid response from LLM API");
      }

      const responseContent = llmResponse.choices[0].message?.content;
      if (!responseContent) {
        throw new Error("Empty content in LLM response");
      }

      // Store raw response for audit/debug
      try {
        logger.logLLM('estimate_response_raw', {
          responseLength: responseContent.length,
          timestamp: new Date().toISOString(),
          response: responseContent.substring(0, 500) + (responseContent.length > 500 ? '...' : '')
        });
      } catch (logError) {
        logger.warn('Failed to log raw LLM response', { error: logError });
      }

      // Extract and parse JSON from response
      const items = this._extractLineItems(responseContent);

      // Calculate totals and validate output
      const processedItems = this._postProcessItems(items);

      // Prepare response object
      const response = {
        success: true,
        data: processedItems
      };

      // Include debug information if requested
      if (validOptions.debug) {
        response.debug = {
          prompt,
          rawResponse: responseContent,
          options: validOptions
        };
      }

      return response;
    } catch (error) {
      // Enhanced error logging with context
      logger.error(`LLM Estimate Error: ${error.message}`, { error });

      // Record estimation failures for analytics
      try {
        logger.logLLM('estimate_failure', {
          error: error.message,
          stack: error.stack,
          timestamp: new Date().toISOString()
        });
      } catch (logError) {
        logger.warn('Failed to log LLM error', { error: logError });
      }

      // Return detailed error information
      return {
        success: false,
        error: error.message,
        diagnosticCode: error.code || 'ESTIMATION_ERROR',
        data: []
      };
    }
  }

  /**
   * Builds the prompt for the LLM based on formatted markdown and options
   * @param {string} markdown - Formatted assessment data markdown
   * @param {number} aggressiveness - Value between 0-1 controlling estimation aggressiveness
   * @param {string} mode - Estimation approach
   * @returns {string} - Complete prompt for LLM
   * @private
   */
  _buildPrompt(markdown, aggressiveness, mode) {
    // Convert aggressiveness level to percentage for clearer communication
    const aggressivenessPercent = Math.round(aggressiveness * 100);

    // Define behavior based on selected mode
    let modeGuidance = '';
    switch(mode) {
      case 'replace-focused':
        modeGuidance = 'Prioritize replacement over repair when conditions indicate moderate to severe damage. Include necessary prep work.';
        break;
      case 'repair-focused':
        modeGuidance = 'Prioritize repair solutions where feasible. Only recommend replacement for severe damage or when repair would be impractical.';
        break;
      case 'maintenance-focused':
        modeGuidance = 'Focus on preventative maintenance. Include cleaning, treating, and minor repairs to prevent future deterioration.';
        break;
      case 'comprehensive':
        modeGuidance = 'Include a complete set of line items covering replacement, repair, maintenance, and preparation for optimal results.';
        break;
      default:
        modeGuidance = 'Balance repair and replacement based on condition severity. Include standard preparation work.';
    }

    // Use exact prompt format from Milestone 2 guide
    return `
You are a professional construction estimator with expertise in creating detailed, accurate estimates from field assessments. Your task is to generate estimate line items based on the following structured assessment data.

GUIDELINES:
1. For each MEASUREMENT tagged with REPLACE, create a line item with appropriate quantity and unit.
   - For AREA measurements (sq ft): Use the square footage for materials like flooring, roofing, drywall, etc.
   - For LINEAR measurements (ln ft): Use the linear footage for trim, molding, baseboards, bracing, etc.
   - For QUANTITY measurements: Use the exact count with the specified unit (each, pieces, etc.).
2. For each CONDITION with REPAIR, TREAT, or CLEAN tags, generate a preparation item.
3. Estimate unit pricing based on materials provided.
4. Include prep work for any related condition modifiers.
5. Use the REPLACEMENT INDICATORS as a final guide.
6. Consider the project SCOPE to understand the complete context.
7. Include materials specified in the MATERIALS section with appropriate quantities.
8. Apply standard waste factors (10% for most materials).
9. Ensure the unit in each line item matches the measurement type (sq ft, ln ft, each, etc.).

RESPOND ONLY IN JSON FORMAT WITH AN ARRAY OF OBJECTS, EACH WITH:
{
  "description": "Clear and specific description of work to be performed",
  "quantity": 123,
  "unit": "sq ft | ln ft | each | pieces | boxes | gallons | hours",
  "unitPrice": 10.50,
  "total": 1290.00,
  "sourceType": "measurement | condition | material",
  "sourceId": "measurement-1234",
  "measurementType": "area | linear | quantity"  // Include this to indicate the type of measurement
}

AGGRESSIVENESS LEVEL: ${aggressivenessPercent}% – ${aggressivenessPercent < 30 ? 'conservative approach' : aggressivenessPercent > 70 ? 'comprehensive approach' : 'balanced approach'}

MODE: ${mode} – ${modeGuidance}

ASSESSMENT DATA BELOW:
=======================
${markdown}
`;
  }

  /**
   * Extracts line items from LLM response.
   * Uses multiple strategies to handle various response formats.
   * @param {string} llmResponse - Raw response from LLM
   * @returns {Array} - Extracted line items
   * @private
   */
  _extractLineItems(llmResponse) {
    try {
      let parsedData = null;

      // Strategy 1: Look for JSON array within the response
      const jsonMatch = llmResponse.match(/\[\s*{.*}\s*\]/s);
      if (jsonMatch && jsonMatch[0]) {
        try {
          parsedData = JSON.parse(jsonMatch[0]);
          if (Array.isArray(parsedData)) {
            logger.debug("Successfully parsed JSON array directly");

            // Validate in new format
            try {
              this._validateLineItems(parsedData);
              return parsedData; // Valid array format
            } catch (validationError) {
              logger.warn("Validation failed for direct JSON array:", { error: validationError.message });
              // Continue to next strategy - no early return
            }
          }
        } catch (e) {
          logger.warn("Failed to parse JSON array match", { match: jsonMatch[0] });
        }
      }

      // Strategy 2: Check for legacy line_items format
      try {
        // Attempt to parse the entire response as an object
        const legacyObject = JSON.parse(llmResponse.replace(/```json|```/g, '').trim());
        const convertedItems = this._validateLegacyResponseFormat(legacyObject);
        if (convertedItems) {
          logger.info("Converted legacy line_items format to new array format");
          return convertedItems;
        }
      } catch (e) {
        // Not a legacy format - continue
      }

      // Strategy 3: Look for JSON object sequence if not in array format
      const objectMatches = llmResponse.match(/{[^{}]*"description"[^{}]*}/g);
      if (objectMatches && objectMatches.length > 0) {
        try {
          // Wrap matched objects in an array
          parsedData = JSON.parse(`[${objectMatches.join(',')}]`);
          logger.debug("Parsed objects sequence into array");
          return parsedData;
        } catch (e) {
          logger.warn("Failed to parse object sequence", { matches: objectMatches });
        }
      }

      // Strategy 4: Fall back to basic cleaning if JSON not properly formatted
      if (llmResponse.includes('"description"') && llmResponse.includes('"quantity"')) {
        // Attempt to clean and parse the response
        const cleanedResponse = llmResponse
          .replace(/```json/g, '')
          .replace(/```/g, '')
          .trim();

        try {
          parsedData = JSON.parse(cleanedResponse);

          // Check if it's the root array format or needs extraction
          if (Array.isArray(parsedData)) {
            logger.debug("Parsed cleaned response as array");
            return parsedData;
          } else if (parsedData && typeof parsedData === 'object') {
            // Check for legacy format one more time
            const convertedItems = this._validateLegacyResponseFormat(parsedData);
            if (convertedItems) {
              logger.info("Converted legacy format from cleaned response");
              return convertedItems;
            }
          }
        } catch (e) {
          logger.warn("Failed to parse cleaned response", { cleaned: cleanedResponse });
        }
      }

      // If all parsing attempts fail, log detailed error and return empty array
      logger.error("All parsing strategies failed for LLM response", {
        responseSample: llmResponse.substring(0, 200) + '...'
      });
      return [];
    } catch (error) {
      logger.error("Error in extractLineItems", { error });
      return [];
    }
  }

  /**
   * Post-processes line items to ensure consistent formatting and values.
   * @param {Array} items - Raw line items from LLM
   * @returns {Array} - Processed items with consistent values
   * @private
   */
  _postProcessItems(items) {
    if (!Array.isArray(items)) return [];

    try {
      // Try to validate the items first
      this._validateLineItems(items);
    } catch (validationError) {
      logger.warn("Line items validation failed, forcing standardization:", { error: validationError.message });
      // Continue with processing anyway to standardize format
    }

    return items.map(item => {
      // Ensure all required fields exist in the Milestone 2 format
      const processedItem = {
        description: String(item.description || item.service_name || "Unspecified work"),
        quantity: parseFloat(item.quantity) || 1,
        unit: String(item.unit || "each").toLowerCase(),
        unitPrice: parseFloat(item.unitPrice || item.unit_price || item.rate || 0),
        sourceType: String(item.sourceType || item.source_type || "unknown").toLowerCase(),
        sourceId: String(item.sourceId || item.source_id || `generated-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`)
      };

      // Calculate total if not provided or incorrect
      processedItem.total = Math.round((processedItem.quantity * processedItem.unitPrice) * 100) / 100;

      return processedItem;
    });
  }

  /**
   * Validates and normalizes the aggressiveness parameter.
   * @param {number|string} value - Aggressiveness value to validate
   * @returns {number} - Normalized value between 0-1
   * @private
   */
  _validateAggressiveness(value) {
    const num = parseFloat(value);
    if (isNaN(num)) return 0.6;
    return Math.max(0, Math.min(1, num));
  }

  /**
   * Validates the mode parameter.
   * @param {string} mode - Mode value to validate
   * @returns {string} - Valid mode or default
   * @private
   */
  _validateMode(mode) {
    const validModes = ["replace-focused", "repair-focused", "maintenance-focused", "comprehensive"];
    return validModes.includes(mode) ? mode : "replace-focused";
  }

  /**
   * Calculates appropriate temperature based on aggressiveness.
   * Lower aggressiveness = lower temperature for more conservative estimates.
   * @param {number} aggressiveness - Aggressiveness value (0-1)
   * @returns {number} - Temperature value for LLM
   * @private
   */
  _calculateTemperature(aggressiveness) {
    // Scale between 0.1 and 0.7 based on aggressiveness
    return 0.1 + (aggressiveness * 0.6);
  }

  /**
   * Formats assessment data into a structured text for the LLM
   * @param {Object} assessmentData - Assessment data from project
   * @returns {string} - Formatted assessment data as text
   * @private
   */
  _formatAssessmentData(assessmentData) {
    // If assessmentData already has formatted markdown, use it
    if (assessmentData.formattedMarkdown) {
      return assessmentData.formattedMarkdown;
    }

    // Otherwise, fall back to the original formatting logic
    if (!assessmentData || !assessmentData.inspections || assessmentData.inspections.length === 0) {
      return "No assessment data available.";
    }

    let formattedText = "ASSESSMENT DATA:\n";

    // Process inspection data by category
    const conditionInspections = assessmentData.inspections.filter(i => i.category === 'condition');
    const measurementInspections = assessmentData.inspections.filter(i => i.category === 'measurements');
    const materialsInspections = assessmentData.inspections.filter(i => i.category === 'materials');

    // Add scope from condition assessments
    if (conditionInspections.length > 0) {
      formattedText += "SCOPE & CONDITIONS:\n";
      conditionInspections.forEach(inspection => {
        if (inspection.content && inspection.content.assessment) {
          formattedText += `- ${inspection.content.assessment}\n`;
        }
      });
      formattedText += "\n";
    }

    // Add measurements
    if (measurementInspections.length > 0) {
      formattedText += "MEASUREMENTS:\n";
      measurementInspections.forEach(inspection => {
        if (inspection.content && inspection.content.dimensions) {
          const dimensions = inspection.content.dimensions;
          Object.entries(dimensions).forEach(([key, value]) => {
            formattedText += `- ${key}: ${value}\n`;
          });
        }
      });
      formattedText += "\n";
    }

    // Add materials
    if (materialsInspections.length > 0) {
      formattedText += "MATERIALS:\n";
      materialsInspections.forEach(inspection => {
        if (inspection.content && inspection.content.items && Array.isArray(inspection.content.items)) {
          inspection.content.items.forEach(item => {
            formattedText += `- ${item.name}: ${item.quantity} ${item.unit || ''}\n`;
          });
        }
      });
    }

    return formattedText;
  }

  /**
   * Starts the estimation process by analyzing the initial project description.
   * @param {string} projectDescription - The user's initial description of the project.
   * @param {number} [targetPrice] - Optional target price for the estimate.
   * @param {Object} [assessmentData] - Optional assessment data from project
   * @returns {Promise<object|null>} - A promise resolving to the parsed analysis JSON object or null if failed.
   */
  async startInitialAnalysis(projectDescription, targetPrice, assessmentData) {
    logger.info(`Starting initial analysis for description: "${projectDescription}"`);
    if (!projectDescription) {
      throw new Error("Project description cannot be empty.");
    }

    // Determine which prompt to use based on whether assessment data is provided
    const promptName = assessmentData ? 'initialAnalysisWithAssessment' : 'initialAnalysis';

    // Get prompt from database or cache
    const promptTemplate = await this.getPrompt(promptName);
    let formattedAssessmentData = "";

    if (assessmentData) {
      formattedAssessmentData = this._formatAssessmentData(assessmentData);
      logger.info("Using assessment data in analysis");
    }

    // Construct the message for the LLM
    const messages = [
      {
        role: "system",
        content: promptTemplate // The prompt defines the role, task, and format
      },
      {
        role: "user",
        content: projectDescription // Append the actual description
      }
    ];

    // Add assessment data if available
    if (assessmentData && formattedAssessmentData) {
      messages[1].content += `\n\n${formattedAssessmentData}`;
    }

    // Add target price to the context if provided (optional, might refine prompt later)
    if (targetPrice !== undefined && targetPrice !== null) { // Check explicitly for undefined/null
        messages[1].content += `\nThe client has indicated a target budget of approximately ${targetPrice}. Keep this in mind but focus first on identifying necessary details.`;
    }

    try {
      // Call DeepSeek API (using deepseek-chat for analysis)
      const completion = await this.deepSeekService.generateChatCompletion(messages, 'deepseek-chat', false);

      if (completion && completion.choices && completion.choices.length > 0) {
        const responseContent = completion.choices[0].message?.content;
        if (responseContent) {
          logger.debug("Received analysis from DeepSeek:", responseContent);
          // Parse the JSON response
          const analysisResult = this.deepSeekService.parseJsonResponse(responseContent);
          if (analysisResult) {
            logger.info("Successfully parsed initial analysis result.");
            // Add target price to the result object if it was provided
            analysisResult.targetPrice = targetPrice;
            // Add a flag to indicate if assessment data was used
            analysisResult.usedAssessmentData = !!assessmentData;
            return analysisResult;
          } else {
            logger.error("Failed to parse JSON response from DeepSeek analysis.");
            // Handle cases where the LLM didn't return valid JSON
            // Maybe return the raw content or a specific error object
            return { error: "Failed to parse LLM response", rawContent: responseContent };
          }
        } else {
           logger.error("DeepSeek response content is empty.");
           return { error: "LLM response was empty." };
        }
      } else {
        logger.error("Invalid or empty response structure from DeepSeek.");
        return { error: "Invalid response structure from LLM." };
      }
    } catch (error) {
      logger.error("Error during initial analysis API call:", error);
      // Rethrow or return a structured error
      throw error; // Or return { error: `API call failed: ${error.message}` };
    }
  }

  /**
   * Processes the user-submitted measurements and answers to clarifying questions.
   * This is the second step after initial analysis, now updated to match Milestone 2 format.
   * @param {object} clarificationData - Object containing measurements, answers, originalDescription, analysisResult.
   * @returns {Promise<object>} - A promise resolving to the result of this processing step in the Milestone 2 format.
   */
  async handleClarifications(clarificationData) {
    const { measurements, answers, originalDescription, analysisResult } = clarificationData;
    logger.info('Handling estimate clarifications with Milestone 2 format...');
    logger.debug('Received Measurements:', JSON.stringify(measurements));
    logger.debug('Received Answers:', JSON.stringify(answers));
    logger.debug('Original Description:', originalDescription);
    logger.debug('Original Analysis:', JSON.stringify(analysisResult));

    try {
      // Create assessment data from the clarification inputs
      const assessmentData = {
        scope: originalDescription,
        measurements: [],
        conditions: [],
        materials: [],
        date: new Date().toISOString().split('T')[0],
        inspector: 'User',
        projectId: `clarification-${Date.now()}`
      };

      // Convert measurements to assessment format
      if (measurements && typeof measurements === 'object') {
        Object.entries(measurements).forEach(([key, value]) => {
          // Skip empty or invalid values
          if (!value || isNaN(Number(value))) return;

          assessmentData.measurements.push({
            label: key.replace(/_/g, ' '),
            value: Number(value),
            unit: this._inferUnitFromKey(key), // Helper to infer unit from key name
            recommendation: 'REPLACE', // Default to replace for all measurements
            sourceId: `measurement-${key}`
          });
        });
      }

      // Convert answers to conditions if appropriate
      if (answers && Array.isArray(analysisResult.clarifying_questions)) {
        analysisResult.clarifying_questions.forEach((question, index) => {
          const answer = answers[index];
          if (!answer) return;

          // Look for condition-related answers
          if (question.toLowerCase().includes('condition') ||
              question.toLowerCase().includes('damage') ||
              question.toLowerCase().includes('wear')) {

            assessmentData.conditions.push({
              location: 'General',
              issue: question,
              severity: this._inferSeverityFromAnswer(answer),
              modifiers: [],
              sourceId: `condition-${index}`
            });
          }

          // Look for material-related answers
          if (question.toLowerCase().includes('material') ||
              question.toLowerCase().includes('type') ||
              question.toLowerCase().includes('brand')) {

            assessmentData.materials.push({
              name: answer,
              specification: question,
              sourceId: `material-${index}`
            });
          }
        });
      }

      // Generate enhanced assessment markdown using formatter from Milestone 1
      const formattedMarkdown = formatAssessmentToMarkdown(assessmentData);

      // Determine appropriate parameters based on the original analysis
      const aggressiveness = 0.6; // Default to medium aggressiveness
      const mode = 'replace-focused'; // Default to replace-focused mode

      // Build LLM prompt with the formatted markdown
      const prompt = this._buildPrompt(formattedMarkdown, aggressiveness, mode);

      // Log the request
      logger.debug(`LLM Clarification Request using Milestone 2 format`);
      logger.logLLM('clarification_request', {
        markdownLength: formattedMarkdown.length,
        mode: mode,
        aggressiveness: aggressiveness
      });

      // Call LLM with appropriate parameters
      const llmResponse = await this.deepSeekService.generateChatCompletion([
        {
          role: "system",
          content: "You are a professional construction estimator. Respond ONLY with a valid JSON array of line items."
        },
        {
          role: "user",
          content: prompt,
        }
      ], 'deepseek-chat', false, {
        temperature: this._calculateTemperature(aggressiveness),
        max_tokens: 2000
      });

      if (!llmResponse || !llmResponse.choices || llmResponse.choices.length === 0) {
        throw new Error("Empty or invalid response from LLM API");
      }

      const responseContent = llmResponse.choices[0].message?.content;
      if (!responseContent) {
        throw new Error("Empty content in LLM response");
      }

      // Store raw response for audit/debug
      try {
        logger.logLLM('clarification_response_raw', {
          responseLength: responseContent.length,
          timestamp: new Date().toISOString(),
          response: responseContent.substring(0, 500) + (responseContent.length > 500 ? '...' : '')
        });
      } catch (logError) {
        logger.warn('Failed to log raw LLM response', { error: logError });
      }

      // Extract and parse JSON from response
      const items = this._extractLineItems(responseContent);

      // Calculate totals and validate output
      const processedItems = this._postProcessItems(items);

      // Return the result in the format for handleClarifications
      // but using the new line items format internally
      logger.info('Successfully processed clarifications with Milestone 2 format');
      return {
        success: true,
        data: {
          line_items: processedItems, // Keep backward compatibility with line_items key
          total_estimate: processedItems.reduce((sum, item) => sum + item.total, 0),
          confidence_level: "high", // Default to high confidence with user-provided measurements
          _milestone2Format: true // Flag to indicate this is the new format
        },
        message: "Successfully processed measurements and answers"
      };

    } catch (error) {
      logger.error('Error during handleClarifications:', error);
      return {
        success: false,
        error: error.message || 'Failed to process clarifications',
        diagnosticCode: error.code || 'CLARIFICATION_ERROR',
        message: "An error occurred while processing your measurements and answers"
      };
    }
  }

  /**
   * Helper to infer unit from measurement key name
   * @param {string} key - Measurement key name
   * @returns {string} - Inferred unit
   * @private
   */
  _inferUnitFromKey(key) {
    const keyLower = key.toLowerCase();

    if (keyLower.includes('area') ||
        keyLower.includes('square') ||
        keyLower.includes('sq') ||
        keyLower.includes('footage')) {
      return 'sq ft';
    }

    if (keyLower.includes('length') ||
        keyLower.includes('width') ||
        keyLower.includes('height') ||
        keyLower.includes('perimeter') ||
        keyLower.includes('linear') ||
        keyLower.includes('ln')) {
      return 'ln ft';
    }

    if (keyLower.includes('count') ||
        keyLower.includes('number') ||
        keyLower.includes('qty') ||
        keyLower.includes('quantity')) {
      return 'each';
    }

    // Default to square feet for most construction measurements
    return 'sq ft';
  }

  /**
   * Helper to infer severity from condition answer
   * @param {string} answer - Answer about condition
   * @returns {string} - Inferred severity (Mild, Moderate, Severe)
   * @private
   */
  _inferSeverityFromAnswer(answer) {
    const answerLower = answer.toLowerCase();

    if (answerLower.includes('severe') ||
        answerLower.includes('bad') ||
        answerLower.includes('critical') ||
        answerLower.includes('extensive') ||
        answerLower.includes('high')) {
      return 'Severe';
    }

    if (answerLower.includes('moderate') ||
        answerLower.includes('medium') ||
        answerLower.includes('partial') ||
        answerLower.includes('some')) {
      return 'Moderate';
    }

    // Default to mild
    return 'Mild';
  }

  /**
   * Simplify prompt if it's too long to prevent timeouts
   *
   * @param {Object} prompt - The prompt object with system and user messages
   * @returns {Object} - Simplified prompt if needed
   * @private
   */
  _simplifyPromptIfNeeded(prompt) {
    // Estimate token count (very rough estimation)
    const estimateTokens = (text) => Math.ceil(text.length / 4);

    const systemTokens = estimateTokens(prompt.system);
    const userTokens = estimateTokens(prompt.user);
    const totalTokens = systemTokens + userTokens;

    logger.debug(`Estimated token count: ${totalTokens} (system: ${systemTokens}, user: ${userTokens})`);

    // Always simplify prompts for consistency and reliability
    logger.info('Simplifying prompt to improve reliability...');

    // Simplified system prompt - focus on the essential task
    const simplifiedSystemPrompt = `
Role: You are an expert repair services estimator for a small repair company.

Task: Based on the project description, measurements, and answers provided, generate specific service line items for an estimate. Focus ONLY on repair services, not physical products.

Format: Return a valid JSON object with the following structure:
{
  "line_items": [
    {
      "service_name": string,       // Descriptive name of the repair service
      "hours": number,              // Estimated labor hours
      "rate": number,               // Hourly rate or fixed fee
      "unit": string,              // Unit of measurement (hours, flat fee)
      "description": string,        // Brief description of the service
      "notes": string              // Any special considerations or requirements
    }
  ],
  "total_estimate": number,         // Sum of all line items (hours * rate or fixed fees)
  "confidence_level": string        // "high", "medium", or "low" based on data completeness
}`;

    // Keep user prompt minimal with just the essential information
    const simplifiedUserPrompt = `
Original Project Description:
${prompt.user.split('Original Project Description:')[1].split('Initial Analysis:')[0].trim()}

Submitted Measurements:
${prompt.user.split('Submitted Measurements:')[1].split('Answers to Clarifying Questions:')[0].trim()}

Answers to Clarifying Questions:
${prompt.user.split('Answers to Clarifying Questions:')[1].split('Based on this information')[0].trim()}

Based on this information, please generate line items for an estimate that reflects the scope of work, materials, and quantities.
`;

    return {
      system: simplifiedSystemPrompt,
      user: simplifiedUserPrompt
    };
  }

  /**
   * Construct the prompt for the clarification step
   *
   * @param {string} originalDescription - The original project description
   * @param {Object} initialAnalysis - The initial analysis result
   * @param {Object} measurements - User submitted measurements
   * @param {Object} answers - User submitted answers to clarifying questions
   * @param {string} clarificationPromptTemplate - Template from database
   * @returns {Object} - The constructed prompt with system and user messages
   * @private
   */
  _constructClarificationPrompt(originalDescription, initialAnalysis, measurements, answers, clarificationPromptTemplate) {
    // Convert measurements and answers to formatted strings for the prompt
    const measurementsText = this._formatMeasurementsForPrompt(measurements);
    const answersText = this._formatAnswersForPrompt(answers, initialAnalysis.clarifying_questions);

    // Use the database template or fall back to a default
    const systemPrompt = clarificationPromptTemplate || `
Role: You are an expert repair services estimator for a small repair company analyzing detailed project requirements.

Task: Based on the original project description and the additional measurements and answers provided,
generate specific service recommendations and create line items for an estimate. Focus ONLY on repair services, not products or materials.

Your goal is to be precise, comprehensive, and follow standard repair service estimating practices.

Format: Return a valid JSON object with the following structure:
{
    "line_items": [
    {
    "service_id": string | null,  // If matched to catalog, provide ID; otherwise null
    "service_name": string,       // Descriptive name of the repair service
    "hours": number,              // Estimated labor hours
    "rate": number,               // Hourly rate or fixed fee
    "unit": string,              // Unit of measurement (hours, flat fee)
    "description": string,        // Brief description of the service
    "notes": string              // Any special considerations or requirements
    }
    ],
    "total_estimate": number,         // Sum of all line items (hours * rate or fixed fees)
    "additional_recommendations": [    // Optional suggestions for supplementary services
    {
    "description": string,
    "reason": string
    }
    ],
    "confidence_level": string        // "high", "medium", or "low" based on data completeness
}

Focus ONLY on service-based line items and labor estimates. We are a small repair company that only offers repair services, not products. Calculate hours based on
industry standards and project complexity factors.
`;

    // User prompt contains all the context from original request and new data
    const userPrompt = `
Original Project Description:
${originalDescription}

Initial Analysis:
${JSON.stringify(initialAnalysis, null, 2)}

Submitted Measurements:
${measurementsText}

Answers to Clarifying Questions:
${answersText}

Based on this information, please generate detailed line items for an estimate that would
accurately reflect the scope of work, required materials, and appropriate quantities.

For each line item, try to provide specific product details that would help match to a product
catalog. Include calculations that show how you determined quantities.

Please ensure all calculations are accurate and include appropriate waste factors and rounding.
`;

    return {
      system: systemPrompt,
      user: userPrompt
    };
  }

  /**
   * Format measurements into a readable string for the prompt
   *
   * @param {Object} measurements - The measurements object
   * @returns {string} - Formatted measurements text
   * @private
   */
  _formatMeasurementsForPrompt(measurements) {
    if (!measurements || Object.keys(measurements).length === 0) {
      return "No measurements provided.";
    }

    return Object.entries(measurements)
      .map(([key, value]) => `- ${key}: ${value}`)
      .join('\n');
  }

  /**
   * Format answers into a readable string for the prompt
   *
   * @param {Object} answers - The answers object
   * @param {Array} clarifyingQuestions - Original clarifying questions from initial analysis
   * @returns {string} - Formatted answers text
   * @private
   */
  _formatAnswersForPrompt(answers, clarifyingQuestions) {
    if (!answers || Object.keys(answers).length === 0) {
      return "No answers to clarifying questions provided.";
    }

    // If we have the original questions array, match answers to questions
    if (Array.isArray(clarifyingQuestions)) {
      return clarifyingQuestions
        .map(question => {
          const answer = answers[question] || "No answer provided";
          return `Q: ${question}\nA: ${answer}`;
        })
        .join('\n\n');
    }

    // Fallback if we don't have the original questions or they're not in expected format
    return Object.entries(answers)
      .map(([question, answer]) => `Q: ${question}\nA: ${answer}`)
      .join('\n\n');
  }

  /**
   * Validate the response structure for estimate line items
   *
   * @param {Array} items - The parsed line items array
   * @throws {Error} - If validation fails
   * @private
   */
  _validateLineItems(items) {
    if (!Array.isArray(items)) {
      throw new Error("Response must be a valid array of line items");
    }

    if (items.length === 0) {
      throw new Error("Response contains no line items");
    }

    // Validate each line item matches Milestone 2 format
    items.forEach((item, index) => {
      // Check required fields
      if (!item.description || typeof item.description !== 'string') {
        throw new Error(`Line item at index ${index} is missing required 'description' string`);
      }

      if (item.quantity === undefined || item.quantity === null || isNaN(Number(item.quantity))) {
        throw new Error(`Line item at index ${index} is missing required 'quantity' number`);
      }

      if (!item.unit || typeof item.unit !== 'string') {
        throw new Error(`Line item at index ${index} is missing required 'unit' string`);
      }

      if (item.unitPrice === undefined || item.unitPrice === null || isNaN(Number(item.unitPrice))) {
        throw new Error(`Line item at index ${index} is missing required 'unitPrice' number`);
      }

      // Optional but valuable fields
      if (item.sourceType !== undefined && typeof item.sourceType !== 'string') {
        throw new Error(`Line item at index ${index} has invalid 'sourceType'; must be a string`);
      }

      if (item.sourceId !== undefined && typeof item.sourceId !== 'string') {
        throw new Error(`Line item at index ${index} has invalid 'sourceId'; must be a string`);
      }
    });

    return true;
  }

  /**
   * Validate legacy response format for backward compatibility
   *
   * @param {Object} response - The legacy line items format with line_items array
   * @returns {Array} - Converted line items in Milestone 2 format
   * @private
   */
  _validateLegacyResponseFormat(response) {
    // Check if this is the old format
    if (response && response.line_items && Array.isArray(response.line_items)) {
      logger.info("Detected legacy line items format - converting to new format");

      // Convert each legacy line item to new format
      return response.line_items.map(item => ({
        description: item.service_name || item.description || "Unspecified work",
        quantity: 1, // Default to 1 if no quantity specified
        unit: item.unit || "hours",
        unitPrice: item.rate || 0,
        total: (item.hours || 1) * (item.rate || 0),
        sourceType: "service",
        sourceId: `legacy-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`
      }));
    }

    // Not legacy format
    return null;
  }

  /**
   * Match line items from LLM-generated estimate to actual products in catalog
   * @param {Array} lineItems - Line items from LLM estimate generation
   * @returns {Promise<Object>} - Structured data with matches for each line item
   */
  async matchProductsToLineItems(lineItems) {
    logger.info(`Matching ${lineItems.length} line items to service catalog`);

    // Utility function for string similarity
    const calculateStringSimilarity = (str1, str2) => {
      // Normalize strings
      const normalized1 = str1.toLowerCase().replace(/[^a-z0-9\s]/g, '');
      const normalized2 = str2.toLowerCase().replace(/[^a-z0-9\s]/g, '');

      // Split into words
      const words1 = normalized1.split(/\s+/);
      const words2 = normalized2.split(/\s+/);

      // Count matching words
      const matchingWords = words1.filter(word => words2.includes(word)).length;

      // Calculate score as percentage of matching words relative to total unique words
      const uniqueWords = new Set([...words1, ...words2]);
      return matchingWords / uniqueWords.size;
    };

    // Normalize units for comparison
    const normalizeUnit = (unit) => {
      if (!unit) return '';

      // Map common variations to standardized units
      const unitMap = {
        'sq. ft.': 'sq ft',
        'square foot': 'sq ft',
        'square feet': 'sq ft',
        'sqft': 'sq ft',
        'linear foot': 'ln ft',
        'linear feet': 'ln ft',
        'ln. ft.': 'ln ft',
        'lnft': 'ln ft',
        'piece': 'each',
        'pieces': 'each',
        'ea': 'each',
        'ea.': 'each'
      };

      const normalizedUnit = unit.toLowerCase().trim();
      return unitMap[normalizedUnit] || normalizedUnit;
    };

    // Process each line item
    const matchedLineItems = await Promise.all(lineItems.map(async (lineItem) => {
      // Search products with similar name
      const searchTerm = lineItem.product_name || lineItem.description || "";
      let products = [];

      try {
        // First try: exact match
        products = await Product.findAll({
          where: {
            name: {
              [Op.iLike]: searchTerm
            },
            isActive: true,
            type: 'service'
          }
        });

        // If no exact matches, try partial match
        if (products.length === 0) {
          // Extract key words from product name
          const keyWords = searchTerm.split(' ')
            .filter(word => word.length > 3) // Only use words longer than 3 chars
            .map(word => word.toLowerCase());

          if (keyWords.length > 0) {
            const keyWordQueries = keyWords.map(word => ({
              name: {
                [Op.iLike]: `%${word}%`
              }
            }));

            products = await Product.findAll({
              where: {
                [Op.or]: keyWordQueries,
                type: 'service'
              },
              limit: 10 // Limit to top 10 matches
            });
          }
        }

        // If still no matches, try broader search
        if (products.length === 0) {
          const firstWord = searchTerm.split(' ')[0];
          if (firstWord && firstWord.length > 2) {
            products = await Product.findAll({
              where: {
                name: {
                  [Op.iLike]: `%${firstWord}%`
                },
                isActive: true,
                type: 'service' // Only match with services, not products
              },
              limit: 5 // Limit to avoid too many irrelevant results
            });
          }
        }

        logger.debug(`Found ${products.length} potential service matches for "${searchTerm}"`);
      } catch (error) {
        logger.error(`Error searching for service matches: ${error.message}`);
        products = []; // Reset in case of error
      }

      // Calculate similarity scores
      const normalizedLineItemUnit = normalizeUnit(lineItem.unit);

      const matchesWithScores = products.map(product => {
        // Calculate name similarity
        const nameSimilarity = calculateStringSimilarity(
          lineItem.product_name || lineItem.description || "",
          product.name
        );

        // Check unit compatibility
        const productUnit = normalizeUnit(product.unit);
        const unitMatch = productUnit === normalizedLineItemUnit ? 1 : 0;

        // Check price closeness (if both have prices)
        let priceMatch = 0;
        const lineItemPrice = lineItem.unit_price || lineItem.unitPrice;
        if (lineItemPrice && product.price) {
          const priceDiff = Math.abs(lineItemPrice - product.price) / Math.max(lineItemPrice, product.price);
          priceMatch = Math.max(0, 1 - priceDiff); // 1 for identical prices, 0 for very different prices
        }

        // Calculate combined score (weighted average)
        const score = (nameSimilarity * 0.6) + (unitMatch * 0.3) + (priceMatch * 0.1);

        return {
          product: {
            id: product.id,
            name: product.name,
            description: product.description,
            unit: product.unit,
            price: parseFloat(product.price), // Ensure price is numeric
            type: product.type
          },
          score: parseFloat(score.toFixed(2)), // Round to 2 decimal places for readability
          is_primary: false // Will set the highest score to true after sorting
        };
      });

      // Sort by score (descending)
      matchesWithScores.sort((a, b) => b.score - a.score);

      // Mark the best match as primary if it exists and has a minimum score
      if (matchesWithScores.length > 0 && matchesWithScores[0].score > 0.4) {
        matchesWithScores[0].is_primary = true;
      }

      // Determine match status
      let matchStatus = 'NO_MATCH';
      if (matchesWithScores.length > 0) {
        matchStatus = matchesWithScores[0].score > 0.7 ? 'CONFIDENT_MATCH' :
                   (matchesWithScores[0].score > 0.4 ? 'POSSIBLE_MATCH' : 'WEAK_MATCH');
      }

      return {
        original: lineItem,
        matches: matchesWithScores,
        match_status: matchStatus
      };
    }));

    // Calculate summary statistics
    const totalItems = matchedLineItems.length;
    const matchedItems = matchedLineItems.filter(item =>
      item.match_status === 'CONFIDENT_MATCH' || item.match_status === 'POSSIBLE_MATCH'
    ).length;
    const unmatchedItems = totalItems - matchedItems;

    return {
      lineItems: matchedLineItems,
      summary: {
        total_items: totalItems,
        matched_items: matchedItems,
        unmatched_items: unmatchedItems
      }
    };
  }

  /**
   * Create new services from unmatched line items
   * @param {Array} newServices - Array of new service data
   * @returns {Promise<Array>} - Array of created services
   */
  async createNewProducts(newServices) {
    logger.info(`Creating ${newServices.length} new services from unmatched line items`);

    try {
      // Create services one by one and collect results
      const createdServices = [];

      for (const serviceData of newServices) {
        // Ensure required fields are present
        if (!serviceData.name) {
          logger.warn('Skipping service creation due to missing name');
          continue;
        }

        // Create the service - always with type 'service'
        const service = await Product.create({
          name: serviceData.name,
          description: serviceData.description || '',
          price: serviceData.price || 0,
          unit: serviceData.unit || 'hour',
          type: 'service', // Always create as service type, regardless of what was passed
          isActive: true
        });

        createdServices.push(service);
      }

      return createdServices;
    } catch (error) {
      logger.error('Error creating new services:', error);
      throw new Error(`Failed to create new services: ${error.message}`);
    }
  }

  /**
   * Finalize estimate by creating line items with matched products
   * @param {Object} finalizedData - Object containing confirmed line items and estimate metadata
   * @returns {Promise<Object>} - Created estimate data
   */
  async finalizeEstimate(finalizedData) {
    // This method will be implemented later to create the actual estimate
    // with the matched and confirmed products
    logger.info('Finalizing estimate with matched products');

    // For now, just return the data to confirm it's working
    return {
      success: true,
      message: 'Estimate finalization endpoint reached',
      data: finalizedData
    };
  }
}

// Create an instance of the LLMEstimateService with the DeepSeek service
const llmEstimateServiceInstance = new LLMEstimateService(deepSeekServiceInstance);

// Export the instance
module.exports = llmEstimateServiceInstance;