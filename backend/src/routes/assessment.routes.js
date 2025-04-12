// routes/assessment.routes.js
const express = require("express");
const router = express.Router();
const { formatAssessmentToMarkdown, generateMarkdownPreview } = require("../services/assessmentFormatterService");
const { getAssessmentById } = require("../services/assessmentService");
const { authenticate } = require('../middleware/auth.middleware');

/**
 * @route   GET /api/assessments/:id/markdown
 * @desc    Get formatted markdown assessment data for LLM processing
 * @access  Private
 */
router.get("/:id/markdown", authenticate, async (req, res) => {
  try {
    const raw = await getAssessmentById(req.params.id); // assumes fully populated
    const markdown = formatAssessmentToMarkdown(raw);
    res.json({ success: true, data: markdown });
  } catch (err) {
    console.error("Markdown formatting failed", err);
    res.status(500).json({ success: false, message: "Unable to format assessment." });
  }
});

/**
 * @route   GET /api/assessments/:id/markdown-preview
 * @desc    Get formatted markdown assessment data with preview HTML
 * @access  Private
 */
router.get("/:id/markdown-preview", authenticate, async (req, res) => {
  try {
    const raw = await getAssessmentById(req.params.id);
    const preview = generateMarkdownPreview(raw);
    
    // Add LLM context profile if requested
    if (req.query.includeLlmContext === 'true') {
      preview.llmContext = {
        aggressiveness: parseFloat(req.query.aggressiveness) || 0.6,
        mode: req.query.mode || 'replace-focused'
      };
    }
    
    // Add debug information if requested
    if (req.query.debug === 'true') {
      // Get the enriched data with all debug info
      const { applyRulesToAssessment } = require('../utils/rulesEngine');
      preview.debug = {
        enrichedData: applyRulesToAssessment(raw)
      };
    }
    
    res.json({
      success: true,
      data: preview
    });
  } catch (err) {
    console.error("Markdown preview generation failed", err);
    res.status(500).json({
      success: false,
      message: "Unable to generate markdown preview."
    });
  }
});

module.exports = router;