const invoiceService = require('../services/invoiceService');
const pdfService = require('../services/pdfService');
const { Client } = require('../models');
const logger = require('../utils/logger');
const fs = require('fs').promises;
const path = require('path');
const { success, error } = require('../utils/response.util');

/**
 * List all invoices with optional filters
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const listInvoices = async (req, res) => {
  try {
    const {
      status,
      clientId,
      dateFrom,
      dateTo,
      page = 0,
      limit = 10
    } = req.query;

    const filters = {
      status,
      clientId,
      dateFrom,
      dateTo
    };

    logger.info(`Listing invoices with filters: ${JSON.stringify(filters)}, page: ${page}, limit: ${limit}`);

    const result = await invoiceService.listInvoices(
      filters,
      parseInt(page, 10),
      parseInt(limit, 10)
    );

    logger.info(`Invoice count: ${result.total}, total pages: ${result.totalPages}`);

    return res.status(200).json(success(result, 'Invoices retrieved successfully'));
  } catch (err) {
    logger.error('Error listing invoices:', err);
    return res.status(500).json(error('Failed to list invoices', { message: err.message }));
  }
};

/**
 * Create a new invoice
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const createInvoice = async (req, res) => {
  try {
    logger.debug('Received req.body in createInvoice:', JSON.stringify(req.body, null, 2));
    const { generatePdf, addressId, ...invoiceData } = req.body; // Extract generatePdf flag and addressId

    // Add addressId to invoiceData
    if (addressId) {
      invoiceData.address_id = addressId;
    }

    // Validate required fields
    logger.debug('Checking client ID:', JSON.stringify({ clientId: invoiceData.clientId, client_id: invoiceData.client_id }, null, 2));
    if (!invoiceData.clientId && !invoiceData.client_id) {
      return res.status(400).json(error('Client ID is required'));
    }

    // Use client_id if present, otherwise use clientId
    const clientIdToUse = invoiceData.client_id || invoiceData.clientId;

    // Check if client exists
    const client = await Client.findByPk(clientIdToUse);
    if (!client) {
      return res.status(404).json(error('Client not found'));
    }

    // Map client id to the correct field for the service layer
    invoiceData.client_id = clientIdToUse; // Use client_id instead of client_fk_id
    // Remove the original keys to avoid conflicts if clientId was used
    if (invoiceData.clientId) {
      delete invoiceData.clientId;
    }

    if (!invoiceData.dateCreated) {
      invoiceData.dateCreated = new Date();
    }

    logger.debug('Passing invoiceData to service:', JSON.stringify(invoiceData, null, 2));
    const invoice = await invoiceService.createInvoice(invoiceData);

    // Attempt to generate PDF if requested, but don't fail the request if PDF generation fails
    if (generatePdf && invoice && invoice.id) {
      try {
        logger.info(`Generating PDF for newly created invoice ID: ${invoice.id}`);
        await pdfService.generateInvoicePDF(invoice.id);
        logger.info(`Successfully generated PDF for invoice ID: ${invoice.id}`);
      } catch (pdfError) {
        logger.error(`Error generating PDF for invoice ID ${invoice.id} during creation:`, pdfError);
        // Do not re-throw or send error response here; invoice creation was successful.
      }
    }

    return res.status(201).json(success(invoice, 'Invoice created successfully'));
  } catch (err) {
    logger.error('Error creating invoice:', err);
    return res.status(500).json(error('Failed to create invoice', { message: err.message }));
  }
};

/**
 * Get invoice details
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getInvoice = async (req, res) => {
  try {
    const { id } = req.params;

    const invoice = await invoiceService.getInvoiceWithDetails(id);

    if (!invoice) {
      return res.status(404).json(error('Invoice not found'));
    }

    return res.status(200).json(success(invoice, 'Invoice retrieved successfully'));
  } catch (err) {
    logger.error(`Error getting invoice by ID: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to get invoice', { message: err.message }));
  }
};

/**
 * Update an invoice
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const updateInvoice = async (req, res) => {
  try {
    const { id } = req.params;
    const invoiceData = req.body;

    const updatedInvoice = await invoiceService.updateInvoice(id, invoiceData);

    return res.status(200).json(success(updatedInvoice, 'Invoice updated successfully'));
  } catch (err) {
    logger.error(`Error updating invoice: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to update invoice', { message: err.message }));
  }
};

/**
 * Delete an invoice
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const deleteInvoice = async (req, res) => {
  try {
    const { id } = req.params;

    const deleted = await invoiceService.deleteInvoice(id);

    if (!deleted) {
      return res.status(404).json(error('Invoice not found or could not be deleted'));
    }

    return res.status(200).json(success(null, 'Invoice deleted successfully'));
  } catch (err) {
    logger.error(`Error deleting invoice: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to delete invoice', { message: err.message }));
  }
};

/**
 * Mark invoice as sent
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const markInvoiceAsSent = async (req, res) => {
  try {
    const { id } = req.params;

    const invoice = await invoiceService.markInvoiceAsSent(id);

    return res.status(200).json(success(invoice, 'Invoice marked as sent'));
  } catch (err) {
    logger.error(`Error marking invoice as sent: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to mark invoice as sent', { message: err.message }));
  }
};

/**
 * Mark invoice as viewed
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const markInvoiceAsViewed = async (req, res) => {
  try {
    const { id } = req.params;

    const invoice = await invoiceService.markInvoiceAsViewed(id);

    return res.status(200).json(success(invoice, 'Invoice marked as viewed'));
  } catch (err) {
    logger.error(`Error marking invoice as viewed: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to mark invoice as viewed', { message: err.message }));
  }
};

/**
 * Add payment to invoice
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const addPayment = async (req, res) => {
  try {
    const { id } = req.params;
    const paymentData = req.body;

    // Validate required fields
    if (!paymentData.amount) {
      return res.status(400).json(error('Payment amount is required'));
    }

    if (!paymentData.paymentDate) {
      paymentData.paymentDate = new Date();
    }

    const invoice = await invoiceService.addPayment(id, paymentData);

    return res.status(200).json(success(invoice, 'Payment added successfully'));
  } catch (err) {
    logger.error(`Error adding payment to invoice: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to add payment', { message: err.message }));
  }
};

/**
 * Get invoice PDF file
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getInvoicePdf = async (req, res) => {
  try {
    const { id } = req.params;

    // First, try to generate a fresh PDF (most reliable option)
    logger.info(`Generating fresh PDF for invoice ID: ${id}`);
    let pdfPath;
    try {
      pdfPath = await pdfService.generateInvoicePDF(id);
      logger.info(`Successfully generated fresh PDF at path: ${pdfPath}`);
    } catch (genError) {
      logger.error(`Error generating fresh PDF for invoice ID ${id}:`, genError);
      return res.status(500).json(error('Failed to generate PDF', { message: genError.message }));
    }

    if (!pdfPath) {
      logger.error(`No PDF path returned from generation for invoice ID ${id}`);
      return res.status(500).json(error('Failed to get PDF path after generation'));
    }

    // Check if the file actually exists at the generated path
    try {
      await fs.access(pdfPath, fs.constants.R_OK);
      logger.info(`Verified PDF exists at path: ${pdfPath}`);
    } catch (accessError) {
      logger.error(`Generated PDF not found at path: ${pdfPath}`, accessError);
      return res.status(500).json(error('PDF generation succeeded but file not found', { message: accessError.message }));
    }

    // Set appropriate headers
    const filename = path.basename(pdfPath);
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `inline; filename="${filename}"`);

    // Use the file system to read the file directly instead of using sendFile
    try {
      const fileData = await fs.readFile(pdfPath);
      return res.send(fileData);
    } catch (readError) {
      logger.error(`Error reading PDF file at ${pdfPath}:`, readError);
      return res.status(500).json(error('Error reading PDF file', { message: readError.message }));
    }
  } catch (err) {
    logger.error(`Unexpected error processing PDF for invoice ID ${req.params.id}:`, err);
    return res.status(500).json(error('Unexpected error processing PDF request', { message: err.message }));
  }
};

/**
 * Get the next available invoice number
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getNextInvoiceNumber = async (req, res) => {
  try {
    const invoiceNumber = await invoiceService.generateInvoiceNumber();

    return res.status(200).json(success({ invoiceNumber }, 'Next invoice number generated successfully'));
  } catch (err) {
    logger.error('Error generating next invoice number:', err);
    return res.status(500).json(error('Failed to generate invoice number', { message: err.message }));
  }
};

module.exports = {
  listInvoices,
  createInvoice,
  getInvoice,
  updateInvoice,
  deleteInvoice,
  markInvoiceAsSent,
  markInvoiceAsViewed,
  addPayment,
  getInvoicePdf,
  getNextInvoiceNumber
};