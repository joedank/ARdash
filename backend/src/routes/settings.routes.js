const express = require('express');
const router = express.Router();
const settingsController = require('../controllers/settings.controller');
const { authenticate } = require('../middleware/auth.middleware');

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

module.exports = router;
