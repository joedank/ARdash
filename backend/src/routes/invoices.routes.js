const express = require('express');
const router = express.Router();
const invoicesController = require('../controllers/invoices.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { validateUuid } = require('../middleware/uuidValidator');

// Apply authentication middleware to all routes
router.use(authenticate);

// GET /api/invoices - List all invoices
router.get('/', invoicesController.listInvoices);

// POST /api/invoices - Create new invoice
router.post('/', invoicesController.createInvoice);

// GET /api/invoices/next-number - Get next invoice number
router.get('/next-number', invoicesController.getNextInvoiceNumber);

// GET /api/invoices/:id - Get invoice details
router.get('/:id', validateUuid('id'), invoicesController.getInvoice);

// PUT /api/invoices/:id - Update invoice
router.put('/:id', validateUuid('id'), invoicesController.updateInvoice);

// DELETE /api/invoices/:id - Delete invoice
router.delete('/:id', validateUuid('id'), invoicesController.deleteInvoice);

// POST /api/invoices/:id/mark-sent - Mark invoice as sent
router.post('/:id/mark-sent', validateUuid('id'), invoicesController.markInvoiceAsSent);

// POST /api/invoices/:id/mark-viewed - Mark invoice as viewed
router.post('/:id/mark-viewed', validateUuid('id'), invoicesController.markInvoiceAsViewed);

// POST /api/invoices/:id/payments - Add payment to invoice
router.post('/:id/payments', validateUuid('id'), invoicesController.addPayment);

// PUT /api/invoices/:id/payments/:paymentId - Update payment
router.put('/:id/payments/:paymentId', validateUuid('id'), validateUuid('paymentId'), invoicesController.updatePayment);

// DELETE /api/invoices/:id/payments/:paymentId - Delete payment
router.delete('/:id/payments/:paymentId', validateUuid('id'), validateUuid('paymentId'), invoicesController.deletePayment);

// GET /api/invoices/:id/pdf - Generate invoice PDF
router.get('/:id/pdf', validateUuid('id'), invoicesController.getInvoicePdf); // Updated to use the new retrieval method

module.exports = router;