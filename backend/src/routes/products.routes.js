const express = require('express');
const router = express.Router();
const productsController = require('../controllers/products.controller');
const { authenticate } = require('../middleware/auth.middleware');

// Apply authentication middleware to all routes
router.use(authenticate);

// GET /api/products - List all products
router.get('/', productsController.listProducts);

// POST /api/products - Create new product
router.post('/', productsController.createProduct);

// GET /api/products/:id - Get product details
router.get('/:id', productsController.getProduct);

// PUT /api/products/:id - Update product
router.put('/:id', productsController.updateProduct);

// DELETE /api/products/:id - Delete product
router.delete('/:id', productsController.deleteProduct);

module.exports = router;
