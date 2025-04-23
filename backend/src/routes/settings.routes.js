const express = require('express');
const router = express.Router();
const settingsController = require('../controllers/settings.controller');
const llmPromptController = require('../controllers/llmPrompt.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { isAdmin } = require('../middleware/role.middleware');
const { validateUuid } = require('../middleware/uuidValidator');

// Apply authentication middleware to all routes
router.use(authenticate);

// GET /api/settings - Get all settings
router.get('/', settingsController.getAllSettings);

// GET /api/settings/group/:group - Get settings by group
router.get('/group/:group', settingsController.getSettingsByGroup);

// GET /api/settings/:key - Get a specific setting
router.get('/:key', settingsController.getSetting);

// POST /api/settings/:key - Update a setting
router.post('/:key', settingsController.updateSetting);

// POST /api/settings - Update multiple settings
router.post('/', settingsController.updateMultipleSettings);

// DELETE /api/settings/:key - Delete a setting
router.delete('/:key', settingsController.deleteSetting);

// LLM Prompts routes
// GET /api/settings/llm-prompts - Get all LLM prompts
router.get('/llm-prompts', isAdmin, llmPromptController.getAllPrompts);

// GET /api/settings/llm-prompts/:id - Get a specific LLM prompt
router.get('/llm-prompts/:id', isAdmin, validateUuid('id'), llmPromptController.getPromptById);

// PUT /api/settings/llm-prompts/:id - Update a specific LLM prompt
router.put('/llm-prompts/:id', isAdmin, validateUuid('id'), llmPromptController.updatePrompt);

// PUT /api/settings/llm-prompts/batch - Update multiple LLM prompts
router.put('/llm-prompts/batch', isAdmin, (req, res) => {
  // Batch update not implemented in the existing controller
  // Return a 501 Not Implemented response
  res.status(501).json({
    success: false,
    message: 'Batch update not implemented'
  });
});

// POST /api/settings/llm-prompts/:id/reset - Reset a LLM prompt to default
router.post('/llm-prompts/:id/reset', isAdmin, validateUuid('id'), (req, res) => {
  // Reset not implemented in the existing controller
  // Return a 501 Not Implemented response
  res.status(501).json({
    success: false,
    message: 'Reset not implemented'
  });
});

module.exports = router;
