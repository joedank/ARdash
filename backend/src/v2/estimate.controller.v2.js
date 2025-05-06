const languageModelProvider = require('../services/languageModelProvider');
const Prompt = require('./PromptEngine');
const Catalog = require('./CatalogService');
const logger = require('../utils/logger');
const { success, error } = require('../utils/response.util');
const parseLineItems = require('../utils/parseLineItems');
const promptBuilder = require('../services/promptBuilder');

/**
 * Generate a smart estimate with AI conversation and catalog deduplication
 * This is a phased approach that first checks what information is missing,
 * then generates line items with catalog integration
 *
 * @param {Object} req - Express request object
 * @param {Object} req.body - Request body
 * @param {string|Object} req.body.assessment - Assessment text or structured assessment object
 * @param {string} [req.body.phase] - Optional phase indicator (e.g., 'clarifyDone')
 * @param {Object} [req.body.options] - Optional settings for generation
 * @param {Array<string>} [req.body.clarifications] - Optional array of clarification strings
 * @param {Array<Object>} [req.body.messages] - Optional array of message objects with role and content
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 *
 * @returns {Object} JSON response with estimate data or clarification requests
 *
 * Note: The endpoint accepts either messages or clarifications, not both.
 * If both are provided, messages will take precedence.
 * Clarifications are automatically converted to messages with role='user'.
 */
exports.generate = async (req, res, next) => {
  try {
    logger.info('Starting estimate generation with AI conversation workflow');

    // Extract assessment information and phase from request
    const { assessment, phase } = req.body;

    if (!assessment) {
      return res.status(400).json(error('Assessment information is required'));
    }

    // Log the assessment structure to help with debugging
    logger.debug(`Assessment type: ${typeof assessment}`);
    logger.debug(`Assessment structure: ${typeof assessment === 'object' ? 'Object with keys: ' + Object.keys(assessment).join(', ') : 'String'}`);

    // Skip Phase 1 if we're coming from the clarify step
    if (phase !== 'clarifyDone') {
      // Phase 1 — Scope scan to detect missing information
      logger.info('Phase 1: Analyzing scope to identify missing information');
      const scopePrompt = Prompt.buildScope(assessment);

      // Make API call to language model provider
      logger.debug('Calling language model API for scope analysis');
      const scopeRaw = await languageModelProvider.generateChatCompletion(
        scopePrompt.messages,
        {
          max_tokens: scopePrompt.max_tokens,
          temperature: scopePrompt.temperature
        }
      );

      // Parse the scope analysis result
      try {
        const scopeResult = Prompt.parseScope(scopeRaw.choices[0].message.content);
        logger.debug(`Scope analysis identified ${scopeResult.requiredMeasurements.length} missing measurements and ${scopeResult.questions.length} questions`);

        // Phase 2 — If clarifications needed, return to frontend
        if (scopeResult.requiredMeasurements.length > 0 || scopeResult.questions.length > 0) {
          logger.info('Phase 2: Returning clarification requests to user');
          return res.json(success({
            phase: 'clarify',
            requiredMeasurements: scopeResult.requiredMeasurements,
            questions: scopeResult.questions
          }, 'Additional information needed for estimate generation'));
        }
      } catch (parseError) {
        logger.error('Error parsing scope analysis result', parseError);
        return res.status(500).json(error('Failed to parse AI response', {
          message: parseError.message,
          rawContent: scopeRaw.choices[0].message.content
        }));
      }
    } else {
      logger.info('Skipping Phase 1 (scope analysis) as clarifications have been provided');
    }

    // Extract messages or clarifications from request body
    const { messages = [], clarifications = [] } = req.body;

    // Process messages - ensure they're valid
    const validMessages = Array.isArray(messages)
      ? messages.filter(m => m && typeof m === 'object' && m.content && m.content.trim())
      : [];

    // Process clarifications - filter out empty strings and convert to messages format
    const validClarifications = Array.isArray(clarifications)
      ? clarifications
          .map(c => c?.trim())
          .filter(Boolean)
          .map(c => ({ role: 'user', content: c }))
      : [];

    // Merge client‑side messages & clarifications ↓
    const merged = [...(validMessages || []), ...(validClarifications || [])]
      .filter(m => m && m.content?.trim?.());

    /* If nothing came from the UI build a default prompt from the assessment */
    let fullMessages = merged;
    if (!fullMessages.length) {
      const assessmentId = req.body.assessmentId || (assessment.project && assessment.project.id);
      if (assessmentId) {
        try {
          const assessmentService = require('../services/assessmentService');
          const assessmentData = await assessmentService.getAssessment(assessmentId);
          fullMessages = [
            { role: 'system', content: 'You are a senior construction estimator.' },
            { role: 'user', content: `Generate a detailed estimate based on this assessment:\n${assessmentData.summary || JSON.stringify(assessment)}` }
          ];
          logger.warn('Built default prompt because no clarifications/messages were provided');
        } catch (assessmentError) {
          logger.error('Failed to fetch assessment for default prompt', assessmentError);
          // Fall back to using the assessment data directly
          fullMessages = [
            { role: 'system', content: 'You are a senior construction estimator.' },
            { role: 'user', content: `Generate a detailed estimate based on this assessment:\n${typeof assessment === 'string' ? assessment : JSON.stringify(assessment)}` }
          ];
        }
      } else {
        // No assessment ID, use the assessment data directly
        fullMessages = [
          { role: 'system', content: 'You are a senior construction estimator.' },
          { role: 'user', content: `Generate a detailed estimate based on this assessment:\n${typeof assessment === 'string' ? assessment : JSON.stringify(assessment)}` }
        ];
      }
    }

    // Phase 3 — Draft items if no clarifications needed
    logger.info('Phase 3: Generating draft items from assessment');
    const draftPrompt = Prompt.buildDraft(assessment, req.body.options || {});

    // If we have clarifications/messages from the frontend, add them to the prompt
    if (fullMessages.length > 0) {
      logger.info(`Adding ${fullMessages.length} clarification messages to the prompt`);
      draftPrompt.messages = [...(draftPrompt.messages || []), ...fullMessages];
    }

    // Make API call to language model provider
    logger.debug('Calling language model API for item generation');
    const draftRaw = await languageModelProvider.generateChatCompletion(
      draftPrompt.messages,
      {
        max_tokens: draftPrompt.max_tokens,
        temperature: draftPrompt.temperature
      }
    );

    // Parse the draft items result
    let draftItems;
    try {
      // First try using the PromptEngine's parser
      try {
        draftItems = Prompt.parseDraft(draftRaw.choices[0].message.content);
      } catch (promptEngineError) {
        // If that fails, try our more tolerant parseLineItems utility
        logger.warn('PromptEngine parser failed, trying parseLineItems utility', promptEngineError);
        const parsedResult = parseLineItems(draftRaw.choices[0].message.content);

        // Handle different response formats
        if (Array.isArray(parsedResult)) {
          draftItems = parsedResult;
        } else if (parsedResult && parsedResult.items && Array.isArray(parsedResult.items)) {
          draftItems = parsedResult.items;
        } else {
          throw new Error('Invalid response format: expected array or object with items array');
        }
      }

      logger.debug(`Generated ${draftItems.length} draft items`);
    } catch (parseError) {
      logger.error('Error parsing draft items result', parseError);

      // Check if this is a 422 error from parseLineItems
      if (parseError.statusCode === 422) {
        return res.status(422).json({
          success: false,
          message: parseError.message,
          data: {
            raw: parseError.rawText
          }
        });
      }

      return res.status(500).json(error('Failed to parse AI response for line items', {
        message: parseError.message,
        rawContent: draftRaw.choices[0].message.content
      }));
    }

    // Phase 4 — Catalog matching with duplicate detection
    logger.info('Phase 4: Performing catalog matching with duplicate detection');
    const finalItems = [];

    for (const item of draftItems) {
      try {
        // Match the item with the catalog
        const matchResult = await Catalog.upsertOrMatch(item, {
          hard: req.body.options?.hardThreshold || 0.85,
          soft: req.body.options?.softThreshold || 0.60
        });

        // Add the result to the final list with the original item data
        finalItems.push({
          ...item,
          catalogStatus: matchResult.kind,
          productId: matchResult.productId,
          matches: matchResult.matches,
          score: matchResult.score,
          matchedName: matchResult.matchedName
        });

        logger.debug(`Processed item "${item.name}" with catalog status: ${matchResult.kind}`);
      } catch (matchError) {
        logger.error(`Error matching item "${item.name}" with catalog`, matchError);
        // Still include the item, but mark the error
        finalItems.push({
          ...item,
          catalogStatus: 'error',
          error: matchError.message
        });
      }
    }

    // Return the complete result
    logger.info('Estimate generation complete, returning results');
    return res.json(success({
      phase: 'done',
      items: finalItems
    }, 'Estimate generation complete'));

  } catch (err) {
    logger.error('Error in estimate generation process', err);
    next(err);
  }
};