const express = require('express');
const statusRoutes = require('./status.routes');
const userRoutes = require('./user.routes');
const authRoutes = require('./auth.routes');
const adminRoutes = require('./admin.routes');
const clientsRoutes = require('./clients.routes');
const addressesRoutes = require('./addresses.routes');
const invoicesRoutes = require('./invoices.routes');
const estimatesRoutes = require('./estimates.routes');
const productsRoutes = require('./products.routes');
const settingsRoutes = require('./settings.routes');
const uploadRoutes = require('./upload.routes');
const projectsRoutes = require('./projects.routes');
const llmPromptRoutes = require('./llmPrompt.routes');
const assessmentsRoutes = require('./assessments.routes');
const estimateItemPhotosRoutes = require('./estimateItemPhotos.routes');
const estimateItemAdditionalWorkRoutes = require('./estimateItemAdditionalWork.routes');
const communitiesRoutes = require('./communities.routes');
const workTypesRoutes = require('./workTypes.routes');
const materialsRoutes = require('./materials.routes');

const router = express.Router();

// Health check route
router.use('/status', statusRoutes);

// User routes
router.use('/users', userRoutes);

// Authentication routes
router.use('/auth', authRoutes);
router.use('/admin', adminRoutes);

// Invoicing/Estimating routes
router.use('/clients', clientsRoutes);
router.use('/addresses', addressesRoutes);
router.use('/invoices', invoicesRoutes);
router.use('/estimates', estimatesRoutes);
router.use('/products', productsRoutes);
router.use('/settings', settingsRoutes);
router.use('/upload', uploadRoutes);

// Project management routes
router.use('/projects', projectsRoutes);

// LLM Prompt management routes
router.use('/llm-prompts', llmPromptRoutes);

// Assessment routes
router.use('/assessments', assessmentsRoutes);

// Estimate item photos routes
router.use('/api', estimateItemPhotosRoutes);

// Estimate item additional work routes
router.use('/api', estimateItemAdditionalWorkRoutes);

// Communities and ad types routes
router.use('/communities', communitiesRoutes);

// Work types routes for mobile-home repair tasks
router.use('/work-types', workTypesRoutes);

// Materials routes for work type materials
router.use('/materials', materialsRoutes);

module.exports = router;