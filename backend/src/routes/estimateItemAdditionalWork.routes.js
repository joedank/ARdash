const express = require('express');
const router = express.Router();
const estimateItemAdditionalWorkController = require('../controllers/estimateItemAdditionalWork.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { validateUuid } = require('../middleware/uuidValidator');

// Apply authentication middleware to all routes
router.use(authenticate);

// Routes for individual estimate items
router.route('/estimate-items/:estimateItemId/additional-work')
  .post(validateUuid('estimateItemId'), estimateItemAdditionalWorkController.createOrUpdate)
  .get(validateUuid('estimateItemId'), estimateItemAdditionalWorkController.get)
  .delete(validateUuid('estimateItemId'), estimateItemAdditionalWorkController.delete);

// Route to get all additional work for an estimate
router.get('/estimates/:estimateId/additional-work', 
  validateUuid('estimateId'),
  estimateItemAdditionalWorkController.getByEstimate
);

module.exports = router;
