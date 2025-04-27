const express = require('express');
const router = express.Router();
const aiProviderController = require('../controllers/aiProvider.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { isAdmin } = require('../middleware/role.middleware');

// Apply authentication and admin middleware to all routes
router.use(authenticate);
router.use(isAdmin);

// GET /api/ai-provider - Get all AI provider settings
router.get('/', aiProviderController.getAiProviderSettings);

// GET /api/ai-provider/options - Get available AI provider options
router.get('/options', aiProviderController.getAiProviderOptions);

// POST /api/ai-provider - Update AI provider settings
router.post('/', aiProviderController.updateAiProviderSettings);

// POST /api/ai-provider/test-language-model - Test language model connection
router.post('/test-language-model', aiProviderController.testLanguageModelConnection);

// POST /api/ai-provider/test-embedding - Test embedding model connection
router.post('/test-embedding', aiProviderController.testEmbeddingConnection);

module.exports = router;
