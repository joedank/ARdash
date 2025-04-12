const express = require('express');
const router = express.Router();
const estimatesController = require('../controllers/estimates.controller');
const { authenticate } = require('../middleware/auth.middleware');

// Apply authentication middleware to all routes
router.use(authenticate);

// --- LLM Estimation Routes ---
// POST /api/estimates/llm/analyze - Analyze project scope using LLM
router.post('/llm/analyze', estimatesController.analyzeEstimateScope);

// GET /api/estimates/llm/assessment/:projectId - Get assessment data for a project
router.get('/llm/assessment/:projectId', estimatesController.getAssessmentData);

// POST /api/estimates/llm/clarify - Submit measurements and answers to clarifying questions
router.post('/llm/clarify', estimatesController.submitEstimateClarifications);

// POST /api/estimates/llm/match-products - Match products to line items
router.post('/llm/match-products', estimatesController.matchProductsToLineItems);

// POST /api/estimates/llm/create-products - Create new products from unmatched line items
router.post('/llm/create-products', estimatesController.createProductsFromLineItems);

// POST /api/estimates/llm/generate - Generate estimate from assessment with enhanced parameters
router.post('/llm/generate', estimatesController.generateEstimateFromAssessment);

// --- Source Mapping Routes ---
// POST /api/estimates/with-source-map - Create estimate with source mapping for bidirectional linking
router.post('/with-source-map', estimatesController.createEstimateWithSourceMap);

// GET /api/estimates/:id/source-map - Get source map for bidirectional linking
router.get('/:id/source-map', estimatesController.getEstimateSourceMap);

// --- Standard Estimate Routes ---

// GET /api/estimates/next-number - Get next available estimate number
router.get('/next-number', estimatesController.getNextEstimateNumber);

// GET /api/estimates - List all estimates
router.get('/', estimatesController.listEstimates);

// POST /api/estimates - Create new estimate
router.post('/', estimatesController.createEstimate);

// GET /api/estimates/:id - Get estimate details
router.get('/:id', estimatesController.getEstimate);

// PUT /api/estimates/:id - Update estimate
router.put('/:id', estimatesController.updateEstimate);

// DELETE /api/estimates/:id - Delete estimate
router.delete('/:id', estimatesController.deleteEstimate);

// POST /api/estimates/:id/mark-sent - Mark estimate as sent
router.post('/:id/mark-sent', estimatesController.markEstimateAsSent);

// POST /api/estimates/:id/mark-accepted - Mark estimate as accepted
router.post('/:id/mark-accepted', estimatesController.markEstimateAsAccepted);

// POST /api/estimates/:id/mark-rejected - Mark estimate as rejected
router.post('/:id/mark-rejected', estimatesController.markEstimateAsRejected);

// POST /api/estimates/:id/convert - Convert estimate to invoice
router.post('/:id/convert', estimatesController.convertToInvoice);

// GET /api/estimates/:id/pdf - Generate estimate PDF
router.get('/:id/pdf', estimatesController.downloadPdf);

module.exports = router;
