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
   * Validates that aggressiveness is a number between 0 and 1 (inclusive)
   * @param {number} value
   * @returns {number}
   * @throws {Error} if value is not valid
   */
  _validateAggressiveness(value) {
    if (typeof value !== 'number' || isNaN(value) || value < 0 || value > 1) {
      throw new Error('Aggressiveness must be a number between 0 and 1');
    }
    return value;
  }

  /**
   * Validates that mode is a non-empty string and matches allowed values
   * @param {string} mode
   * @returns {string}
   * @throws {Error} if mode is not valid
   */
  _validateMode(mode) {
    const allowedModes = ['replace-focused', 'repair-focused', 'full'];
    if (typeof mode !== 'string' || !allowedModes.includes(mode)) {
      throw new Error(`Mode must be one of: ${allowedModes.join(', ')}`);
    }
    return mode;
  }

  /**
   * Builds the LLM prompt string using assessment markdown, aggressiveness, and mode
   * @param {string} markdown - The formatted assessment markdown
   * @param {number} aggressiveness - Aggressiveness value (0-1)
   * @param {string} mode - Mode for estimate ('replace-focused', 'repair-focused', 'full')
   * @returns {string} - The constructed prompt
   */
  _buildPrompt(markdown, aggressiveness, mode) {
    return `# Estimation Request\nMode: ${mode}\nAggressiveness: ${aggressiveness}\n\n## Assessment\n${markdown}`;
  }

  /**
   * Calculates the temperature value for the LLM based on aggressiveness (0-1)
   * @param {number} aggressiveness
   * @returns {number} temperature (0.2 to 1.0)
   */
  _calculateTemperature(aggressiveness) {
    // Map aggressiveness (0-1) to temperature (0.2-1.0)
    // Low aggressiveness = conservative (0.2), high = more creative (1.0)
    const minTemp = 0.2;
    const maxTemp = 1.0;
    if (typeof aggressiveness !== 'number' || isNaN(aggressiveness)) return minTemp;
    return Math.min(maxTemp, Math.max(minTemp, minTemp + (maxTemp - minTemp) * aggressiveness));
  }

  /**
   * Extracts an array of line items from a string (tries to parse JSON)
   * @param {string} responseText
   * @returns {Array} Array of line items or []
   */
  _extractLineItems(responseText) {
    if (!responseText || typeof responseText !== 'string') return [];
    // Try to extract JSON array from markdown code block
    const jsonBlockMatch = responseText.match(/```(?:json)?\s*([\s\S]*?)```/);
    let jsonContent = responseText;
    if (jsonBlockMatch && jsonBlockMatch[1]) {
      jsonContent = jsonBlockMatch[1].trim();
    }
    try {
      const parsed = JSON.parse(jsonContent);
      return Array.isArray(parsed) ? parsed : (parsed.line_items || []);
    } catch (e) {
      return [];
    }
  }

  /**
   * Post-processes the array of line items (normalization, defaults, etc.)
   * @param {Array} items
   * @returns {Array} processed items
   */
  _postProcessItems(items) {
    if (!Array.isArray(items)) return [];
    // Example: add normalization or default values if needed
    return items.map(item => ({ ...item }));
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
- required_services: an array of strings listing the specific repair services needed. THIS FIELD MUST CONTAIN AT LEAST ONE SERVICE, EVEN FOR GENERAL REPAIRS. Common services include: "roof_replacement", "tile_removal", "underlayment_replacement", "window_installation", "door_repair", "painting", "flooring", etc.
- clarifying_questions: an array of strings for any questions that help clarify missing or ambiguous details. Ensure the questions are directly pertinent to the identified repair type and do not ask for extraneous data.
Guidelines:
1. Identify the repair type(s) by examining keywords in the description (e.g., "leak", "remove tiles" imply roofing; "door", "window" imply fixture repairs).
2. If the description specifies a localized repair (e.g., "remove tiles to locate a leak"), avoid asking for full-scale measurements such as total roof square footage.
3. Generate clarifying questions only when the provided description lacks necessary details, ensuring they relate directly to the task (for example, ask for the affected area's dimensions rather than the entire roof if the job is partial).
4. Base your questions on our industry practices and the standard service types we provide.
5. ALWAYS include at least one specific service in the required_services array, even for general repairs.
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
   * Process external LLM response to generate estimate line items
   * @param {string} responseText - Raw response text from external LLM
   * @param {Object} assessmentData - Optional assessment data
   * @returns {Promise<Object>} - Processed line items or error
   */
  async processExternalLlmResponse(responseText, assessmentData) {
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
        logger.warn(`JSON parsing failed, trying other extraction strategies: ${parseError.message}`);
        parsedData = this._extractLineItems(responseText);

        if (!parsedData || !Array.isArray(parsedData) || parsedData.length === 0) {
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

      // Process and validate the line items
      try {
        // Validate that each line item has the required fields
        this._validateLineItems(lineItems);
      } catch (validationError) {
        logger.warn(`Validation error processing external LLM response: ${validationError.message}`);
        // Continue processing, but note the validation error in logs
      }

      // Post-process the items to ensure consistent format
      const processedItems = this._postProcessItems(lineItems);

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
   * Analyzes the project scope using LLM to extract repair types, measurements, and clarifying questions.
   * @param {Object} params - Parameters object
   * @param {string} params.scope - The scope/description to analyze
   * @param {string} params.projectId - The project ID associated with this scope
   * @param {Object} params.assessmentData - Optional assessment data object
   * @param {string} params.mode - Optional estimation mode
   * @param {number} params.aggressiveness - Optional aggressiveness level
   * @returns {Promise<Object>} - Analysis result
   */
  async analyzeScope(params = {}) {
    try {
      const { scope, projectId, assessmentData, mode, aggressiveness } = params;
      
      console.log('\n===== LLM SERVICE - ANALYZE SCOPE =====');
      console.log('Parameters:');
      console.log('- Scope:', scope?.substring(0, 50) + '...');
      console.log('- Project ID:', projectId);
      console.log('- Assessment data available:', !!assessmentData);
      console.log('- Mode:', mode);
      console.log('- Aggressiveness:', aggressiveness);
      
      if (!scope || typeof scope !== 'string') {
        throw new Error('Scope description is required');
      }

      // Use the same prompt as initialAnalysis
      const prompt = this._getDefaultPrompt('initialAnalysis') + `\n${scope}`;
      console.log('\nPrompt used (first 200 chars):', prompt.substring(0, 200) + '...');
      
      console.log('\nCalling DeepSeek API...');
      const llmResponse = await this.deepSeekService.generateChatCompletion([
        {
          role: "system",
          content: "You are a professional construction estimator. Analyze the project scope and respond with a JSON object."
        },
        {
          role: "user",
          content: prompt
        }
      ], 'deepseek-chat', false, {
        temperature: 0.3, // More deterministic for analysis
        max_tokens: 512
      });
      
      console.log('\nReceived LLM response');
      let content = llmResponse?.choices?.[0]?.message?.content || '';
      console.log('Raw content (first 500 chars):', content.substring(0, 500) + (content.length > 500 ? '...' : ''));
      
      if (!content) {
        throw new Error('No response from LLM');
      }
      
      // Try to parse as JSON
      let analysis;
      try {
        analysis = JSON.parse(content);
        console.log('\nSuccessfully parsed direct JSON:', JSON.stringify(analysis, null, 2));
      } catch (err) {
        console.log('\nFailed to parse direct JSON, attempting to extract from code block:', err.message);
        // Try to extract JSON from code block
        const match = content.match(/```(?:json)?\s*([\s\S]*?)```/);
        if (match && match[1]) {
          try {
            const extracted = match[1].trim();
            console.log('Extracted JSON from code block (first 200 chars):', extracted.substring(0, 200) + '...');
            analysis = JSON.parse(extracted);
            console.log('Successfully parsed JSON from code block:', JSON.stringify(analysis, null, 2));
          } catch (e) {
            console.log('Failed to parse JSON from code block:', e.message);
            console.log('Raw extracted content:', match[1]);
            throw new Error('Failed to parse LLM response as JSON');
          }
        } else {
          console.log('Could not find JSON in code block');
          console.log('Raw content:', content);
          throw new Error('Failed to parse LLM response as JSON');
        }
      }
      
      // Ensure all required fields exist with defaults
      const result = {
        repair_type: analysis.repair_type || 'General Repair',
        required_measurements: Array.isArray(analysis.required_measurements) ? analysis.required_measurements : [],
        required_services: Array.isArray(analysis.required_services) ? analysis.required_services : ['general_repair_service'],
        clarifying_questions: Array.isArray(analysis.clarifying_questions) ? analysis.clarifying_questions : []
      };
      
      // If projectId was provided, add it to the result
      if (projectId) {
        result.projectId = projectId;
      }
      
      // Log what was received and what we're returning
      console.log('\nFinal processed result:', JSON.stringify(result, null, 2));
      console.log('===== END LLM SERVICE - ANALYZE SCOPE =====\n');
      
      return { success: true, data: result };
    } catch (error) {
      console.log('\n===== ERROR IN LLM SERVICE - ANALYZE SCOPE =====');
      console.log('Error message:', error.message);
      console.log('Error stack:', error.stack);
      console.log('===== END ERROR IN LLM SERVICE - ANALYZE SCOPE =====\n');
      
      logger.error('Error in analyzeScope:', error);
      return { 
        success: false, 
        message: error.message,
        // Provide a fallback result with defaults
        data: {
          repair_type: 'General Repair',
          required_measurements: [],
          required_services: ['general_repair_service'],
          clarifying_questions: []
        }
      };
    }
  }

  /**
   * Generates estimate items from assessment using LLM.
   * @param {Object} params - Parameters object
   * @param {string} params.projectId - Project ID to generate estimate for
   * @param {Object} params.assessment - Optional assessment data object
   * @param {string} params.mode - Optional estimation mode
   * @param {number} params.aggressiveness - Optional aggressiveness level
   * @returns {Object} Response containing estimate line items and optional debug info
   */
  async generateEstimateFromAssessment(params = {}) {

    try {
      // Extract parameters
      const { projectId, assessment: assessmentData, mode, aggressiveness } = params;

      // Validate project ID
      if (!projectId) {
        throw new Error('Project ID is required');
      }

      logger.info(`Generating estimate for project ID: ${projectId}`);

      // Apply defaults and validation
      const validOptions = {
        aggressiveness: this._validateAggressiveness(aggressiveness ?? 0.6),
        mode: this._validateMode(mode ?? "replace-focused"),
        debug: params.debug === true
      };

      // Determine assessment data source
      let assessment = assessmentData;

      // If no assessment data provided, try to fetch it using the project ID
      if (!assessment || Object.keys(assessment).length === 0) {
        logger.info(`No assessment data provided, fetching from project ID: ${projectId}`);
        try {
          // Import here to avoid circular dependency
          const projectService = require('./projectService');
          const project = await projectService.getProjectWithDetails(projectId);

          if (!project) {
            throw new Error(`Project not found with ID: ${projectId}`);
          }

          // Format the assessment data
          assessment = {
            id: project.id,
            projectId: project.id,
            scope: project.scope,
            inspections: project.inspections || [],
            photos: project.photos || [],
            date: project.scheduled_date,
            client: project.client,
            address: project.address
          };

          logger.info(`Successfully fetched project data for ID: ${projectId}`);
        } catch (fetchError) {
          logger.error(`Error fetching project data: ${fetchError.message}`, { error: fetchError });
          throw new Error(`Failed to fetch project data: ${fetchError.message}`);
        }
      }

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
   * Match LLM-generated line items to actual products in catalog
   * @param {Array} lineItems - Array of line items to match
   * @returns {Promise<Object>} - Object with matched products for each line item
   */
  async matchProductsToLineItems(lineItems) {
    try {
      logger.info(`Matching ${lineItems.length} line items to products`);

      // Validate input
      if (!lineItems || !Array.isArray(lineItems) || lineItems.length === 0) {
        return {
          success: false,
          error: 'Line items are required and must be a non-empty array',
          lineItems: []
        };
      }

      // Fetch all products of type 'service' from the database
      const products = await Product.findAll({
        where: {
          type: 'service'
        }
      });

      if (!products || products.length === 0) {
        logger.warn('No products found in the database');
        return {
          success: true,
          message: 'No products found to match against',
          lineItems: lineItems.map(item => ({
            original: item,
            matches: []
          }))
        };
      }

      logger.info(`Found ${products.length} products to match against`);

      // Process each line item to find potential matches
      const processedLineItems = lineItems.map((item, index) => {
        try {
          // --- Start: Robust Unit Extraction ---
          let itemUnit = 'each'; // Default unit

          if (item && item.measurementType) {
            if (item.measurementType === 'area') {
              // For area measurements, check both structures
              if (item.dimensions && item.dimensions.units) {
                itemUnit = item.dimensions.units;
              } else if (item.units) {
                itemUnit = item.units;
              } else {
                itemUnit = 'sq ft'; // Default for area
              }
            } else if (item.measurementType === 'linear') {
              // For linear measurements, check both structures
              if (item.dimensions && item.dimensions.units) {
                itemUnit = item.dimensions.units;
              } else if (item.units) {
                itemUnit = item.units;
              } else {
                itemUnit = 'ln ft'; // Default for linear
              }
            } else if (item.measurementType === 'quantity') {
              // For quantity measurements
              itemUnit = item.quantityUnit || item.unit || 'each';
            }
          } else if (item.unit) {
            // Fallback to explicit unit property if available
            itemUnit = item.unit;
          }
          
          itemUnit = (itemUnit || 'each').toLowerCase(); // Normalize and ensure fallback
          // --- End: Robust Unit Extraction ---

          // Normalize the item description for matching
          const itemName = (item.description || '').toLowerCase();

          // Find potential matches based on name similarity and unit compatibility
          const matches = products
            .map(product => {
              const productName = (product.name || '').toLowerCase();
              const productDescription = (product.description || '').toLowerCase();
              const productUnit = (product.unit || 'each').toLowerCase();

              // Calculate similarity scores
              const nameScore = stringSimilarity.compareTwoStrings(itemName, productName);
              const descriptionScore = productDescription ?
                stringSimilarity.compareTwoStrings(itemName, productDescription) : 0;

              // Use the higher of the two scores
              const similarityScore = Math.max(nameScore, descriptionScore);

              // Unit compatibility check (exact match or compatible units)
              const unitCompatible = itemUnit === productUnit ||
                (this._areUnitsCompatible(itemUnit, productUnit));

              // Apply a penalty if units are not compatible
              const finalScore = unitCompatible ? similarityScore : similarityScore * 0.5;

              return {
                product,
                service: product, // Add service property for frontend compatibility
                score: finalScore,
                unitCompatible
              };
            })
            // Filter out very low matches
            .filter(match => match.score > 0.3)
            // Sort by score (highest first)
            .sort((a, b) => b.score - a.score)
            // Take top 3 matches
            .slice(0, 3);

          return {
            original: item,
            matches
          };
        } catch (itemError) {
          logger.error(`Error processing line item at index ${index}: ${itemError.message}`, { item, error: itemError });
          // Return the original item with no matches in case of error
          return {
            original: item,
            matches: []
          };
        }
      });

      return {
        success: true,
        lineItems: processedLineItems
      };
    } catch (error) {
      logger.error(`Error matching products to line items: ${error.message}`, { error });
      throw new Error(`Failed to match products to line items: ${error.message}`);
    }
  }

  /**
   * Check if two units are compatible for conversion
   * @param {string} unit1 - First unit
   * @param {string} unit2 - Second unit
   * @returns {boolean} - Whether the units are compatible
   * @private
   */
  _areUnitsCompatible(unit1, unit2) {
    // Normalize units
    unit1 = unit1.toLowerCase().trim();
    unit2 = unit2.toLowerCase().trim();

    // If units are identical, they're compatible
    if (unit1 === unit2) return true;

    // Define groups of compatible units
    const areaUnits = ['sq ft', 'square foot', 'square feet', 'sqft', 'sf'];
    const linearUnits = ['ln ft', 'linear foot', 'linear feet', 'ft', 'foot', 'feet', 'lnft', 'lf'];
    const countUnits = ['each', 'ea', 'unit', 'piece', 'pc', 'count'];

    // Check if both units are in the same group
    return (
      (areaUnits.includes(unit1) && areaUnits.includes(unit2)) ||
      (linearUnits.includes(unit1) && linearUnits.includes(unit2)) ||
      (countUnits.includes(unit1) && countUnits.includes(unit2))
    );
  }

  /**
   * Create new products from unmatched line items
   * @param {Array} newProducts - Array of new product data
   * @returns {Promise<Array>} - Array of created products
   */
  async createNewProducts(newProducts) {
    try {
      logger.info(`Creating ${newProducts.length} new products`);

      // Validate input
      if (!newProducts || !Array.isArray(newProducts) || newProducts.length === 0) {
        throw new Error('New products are required and must be a non-empty array');
      }

      // Create products in the database
      const createdProducts = await Promise.all(
        newProducts.map(async (productData) => {
          try {
            // Ensure type is set to 'service'
            const newProduct = await Product.create({
              name: productData.name,
              description: productData.description,
              price: productData.price,
              unit: productData.unit,
              type: 'service' // Always create as service type
            });

            return newProduct;
          } catch (error) {
            logger.error(`Error creating product ${productData.name}: ${error.message}`);
            throw error;
          }
        })
      );

      logger.info(`Successfully created ${createdProducts.length} new products`);
      return createdProducts;
    } catch (error) {
      logger.error(`Error creating new products: ${error.message}`, { error });
      throw new Error(`Failed to create new products: ${error.message}`);
    }
  }
}

module.exports = new LLMEstimateService(deepSeekServiceInstance);
