'use strict';

const express = require('express');
const router = express.Router();
const controller = require('../controllers/materialsController');
const { authenticate } = require('../middleware/auth.middleware');
const rateLimit = require('express-rate-limit');

// Rate limiter for search endpoints
const searchLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 60, // 60 requests per minute
  message: 'Too many search requests, please try again later',
  standardHeaders: true,
  legacyHeaders: false
});

/**
 * @route   GET /api/materials/search
 * @desc    Find products by name using trigram similarity
 * @access  Private
 * @note    This route doesn't use the UUID validator as it doesn't use path parameters
 */
router.get('/search', authenticate, searchLimiter, controller.findByName);

/**
 * @route   GET /api/materials/sku/:sku
 * @desc    Find product by SKU
 * @access  Private
 */
router.get('/sku/:sku', authenticate, controller.findBySku);

/**
 * @route   GET /api/materials/resolve/:identifier
 * @desc    Resolve product ID by SKU or name
 * @access  Private
 */
router.get('/resolve/:identifier', authenticate, controller.resolveProductId);

/**
 * @route   GET /api/materials/frequent
 * @desc    Get frequently used materials
 * @access  Private
 * @note    This route doesn't use the UUID validator as it doesn't use path parameters
 */
router.get('/frequent', authenticate, controller.getFrequentlyUsedMaterials);

/**
 * @route   POST /api/materials
 * @desc    Create a new product
 * @access  Private
 * @note    This route doesn't use the UUID validator as it doesn't use path parameters
 */
router.post('/', authenticate, controller.createProduct);

module.exports = router;
