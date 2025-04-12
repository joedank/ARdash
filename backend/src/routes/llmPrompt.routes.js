const express = require('express');
const router = express.Router();
const llmPromptController = require('../controllers/llmPrompt.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { isAdmin } = require('../middleware/role.middleware');

// Apply authentication middleware to all routes
router.use(authenticate);

// Admin-only routes
router.get('/', isAdmin, llmPromptController.getAllPrompts);
router.get('/:id', isAdmin, llmPromptController.getPromptById);
router.put('/:id', isAdmin, llmPromptController.updatePrompt);

// Non-admin routes (for LLM service to fetch prompts)
router.get('/name/:name', llmPromptController.getPromptByName);

module.exports = router;
