const invoiceService = require('../services/invoiceService');
const pdfService = require('../services/pdfService');
const { Client } = require('../models');
const logger = require('../utils/logger');
const fs = require('fs').promises;
const path = require('path');

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
    
    const result = await invoiceService.listInvoices(
      filters, 
      parseInt(page, 10), 
      parseInt(limit, 10)
    );
    
    return res.status(200).json({
      success: true,
      data: result
    });
  } catch (error) {
    logger.error('Error listing invoices:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to list invoices',
      error: error.message
    });
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
    if (!invoiceData.clientId) {
      return res.status(400).json({
        success: false,
        message: 'Client ID is required'
      });
    }
    
    // Check if client exists
    const client = await Client.findByPk(invoiceData.clientId);
    if (!client) {
      return res.status(404).json({
        success: false,
        message: 'Client not found'
      });
    }
    
    // Map clientId to client_fk_id for the service layer
    invoiceData.client_fk_id = invoiceData.clientId;
    delete invoiceData.clientId; // Remove the original key

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
    
    return res.status(201).json({
      success: true,
      message: 'Invoice created successfully',
      data: invoice
    });
  } catch (error) {
    logger.error('Error creating invoice:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to create invoice',
      error: error.message
    });
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
      return res.status(404).json({
        success: false,
        message: 'Invoice not found'
      });
    }
    
    return res.status(200).json({
      success: true,
      data: invoice
    });
  } catch (error) {
    logger.error(`Error getting invoice by ID: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get invoice',
      error: error.message
    });
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
    
    return res.status(200).json({
      success: true,
      message: 'Invoice updated successfully',
      data: updatedInvoice
    });
  } catch (error) {
    logger.error(`Error updating invoice: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to update invoice',
      error: error.message
    });
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
    
    const success = await invoiceService.deleteInvoice(id);
    
    if (!success) {
      return res.status(404).json({
        success: false,
        message: 'Invoice not found or could not be deleted'
      });
    }
    
    return res.status(200).json({
      success: true,
      message: 'Invoice deleted successfully'
    });
  } catch (error) {
    logger.error(`Error deleting invoice: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to delete invoice',
      error: error.message
    });
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
    
    return res.status(200).json({
      success: true,
      message: 'Invoice marked as sent',
      data: invoice
    });
  } catch (error) {
    logger.error(`Error marking invoice as sent: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to mark invoice as sent',
      error: error.message
    });
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
    
    return res.status(200).json({
      success: true,
      message: 'Invoice marked as viewed',
      data: invoice
    });
  } catch (error) {
    logger.error(`Error marking invoice as viewed: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to mark invoice as viewed',
      error: error.message
    });
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
      return res.status(400).json({
        success: false,
        message: 'Payment amount is required'
      });
    }
    
    if (!paymentData.paymentDate) {
      paymentData.paymentDate = new Date();
    }
    
    const invoice = await invoiceService.addPayment(id, paymentData);
    
    return res.status(200).json({
      success: true,
      message: 'Payment added successfully',
      data: invoice
    });
  } catch (error) {
    logger.error(`Error adding payment to invoice: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to add payment',
      error: error.message
    });
  }
};

/**
 * Generate invoice PDF
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const generatePdf = async (req, res) => {
  try {
    const { id } = req.params;
    
    const pdfPath = await invoiceService.generatePdf(id);
    
    // Send file as response
    const filename = path.basename(pdfPath);
    
    // Read the file
    const file = await fs.readFile(pdfPath);
    
    // Set headers
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    
    // Send file
    return res.status(200).send(file);
  } catch (error) {
    logger.error(`Error generating PDF for invoice: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to generate PDF',
      error: error.message
    });
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
      return res.status(500).json({
        success: false,
        message: 'Failed to generate PDF',
        error: genError.message
      });
    }

    if (!pdfPath) {
      logger.error(`No PDF path returned from generation for invoice ID ${id}`);
      return res.status(500).json({
        success: false,
        message: 'Failed to get PDF path after generation'
      });
    }
    
    // Check if the file actually exists at the generated path
    try {
      await fs.access(pdfPath, fs.constants.R_OK);
      logger.info(`Verified PDF exists at path: ${pdfPath}`);
    } catch (accessError) {
      logger.error(`Generated PDF not found at path: ${pdfPath}`, accessError);
      return res.status(500).json({
        success: false,
        message: 'PDF generation succeeded but file not found',
        error: accessError.message
      });
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
      return res.status(500).json({
        success: false,
        message: 'Error reading PDF file',
        error: readError.message
      });
    }
  } catch (error) {
    logger.error(`Unexpected error processing PDF for invoice ID ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Unexpected error processing PDF request',
      error: error.message
    });
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
    
    return res.status(200).json({
      success: true,
      data: {
        invoiceNumber
      }
    });
  } catch (error) {
    logger.error('Error generating next invoice number:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to generate invoice number',
      error: error.message
    });
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
  generatePdf,
  getInvoicePdf,
  getNextInvoiceNumber
};