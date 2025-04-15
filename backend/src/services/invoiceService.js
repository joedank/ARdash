const { Invoice, InvoiceItem, Payment, Settings, Client, ClientAddress } = require('../models');
const { Op } = require('sequelize');
const fs = require('fs').promises;
const path = require('path');
const logger = require('../utils/logger');
const pdfService = require('./pdfService');

/**
 * Service for handling invoice operations
 */
class InvoiceService {
  /**
   * Generate a new invoice number
   * @returns {Promise<string>} - New invoice number
   */
  async generateInvoiceNumber() {
    let prefix = 'INV-'; // Define prefix with default value outside try block
    try {
      const settingPrefix = await this.getSetting('invoice_prefix');
      if (settingPrefix) {
        prefix = settingPrefix; // Update if setting exists
      }
      let number = 1;
      let newInvoiceNumber;
      let existingInvoice = null;

      // Find the highest existing number first
      const highestInvoice = await Invoice.findOne({
        order: [['invoiceNumber', 'DESC']],
        paranoid: false // Include soft-deleted records in the check
      });

      if (highestInvoice && highestInvoice.invoiceNumber) {
        const numberPart = highestInvoice.invoiceNumber.substring(prefix.length);
        const parsedNumber = parseInt(numberPart, 10);
        if (!isNaN(parsedNumber)) {
          number = parsedNumber + 1;
        }
      }

      // Loop to ensure uniqueness, checking against existing records
      do {
        newInvoiceNumber = `${prefix}${number.toString().padStart(5, '0')}`;
        // logger.debug(`Attempting to generate invoice number: ${newInvoiceNumber}`); // Removed for brevity
        existingInvoice = await Invoice.findOne({
          where: { invoiceNumber: newInvoiceNumber },
          paranoid: false // Include soft-deleted records in the check
        });

        if (existingInvoice) {
          logger.warn(`Invoice number ${newInvoiceNumber} already exists (possibly soft-deleted). Incrementing.`);
          number++; // Increment if it exists
        }
      } while (existingInvoice);

      logger.debug(`Final unique invoice number generated: ${newInvoiceNumber}`);
      return newInvoiceNumber;
    } catch (error) {
      logger.error('Error generating invoice number:', error);
      // Fallback in case of error during generation
      const fallbackNumber = `${prefix}${Math.floor(100000 + Math.random() * 900000)}`;
      logger.warn(`Falling back to random invoice number: ${fallbackNumber}`);
      return fallbackNumber;
    }
  }

  /**
   * Get a setting value by key
   * @param {string} key - Setting key
   * @returns {Promise<string|null>} - Setting value or null
   */
  async getSetting(key) {
    const setting = await Settings.findOne({ where: { key } });
    return setting ? setting.value : null;
  }

  /**
   * Create a new invoice
   * @param {Object} invoiceData - Invoice data
   * @returns {Promise<Object>} - Created invoice
   */
  async createInvoice(invoiceData) {
    try {
      // Log the entire incoming data object
      logger.debug('Entering createInvoice with invoiceData:', JSON.stringify(invoiceData, null, 2));
      // Ensure client exists using client_id as the primary identifier
      const clientId = invoiceData.client_id;
      if (!clientId) {
        throw new Error('Client ID (client_id) is required');
      }
      const client = await Client.findByPk(clientId, {
        include: [
          {
            model: ClientAddress,
            as: 'addresses'
          }
        ]
      });

      if (!client) {
        throw new Error('Client not found');
      }

      // Generate invoice number if not provided
      if (!invoiceData.invoiceNumber) {
        invoiceData.invoiceNumber = await this.generateInvoiceNumber();
      }

      // Set due date if not provided
      if (!invoiceData.dateDue) {
        const dueDays = parseInt(await this.getSetting('invoice_due_days') || '30', 10);
        const dueDate = new Date(invoiceData.dateCreated);
        dueDate.setDate(dueDate.getDate() + dueDays);
        invoiceData.dateDue = dueDate;
      }

      // Set terms if not provided
      if (!invoiceData.terms) {
        let terms = await this.getSetting('default_invoice_terms') || '';
        terms = terms.replace('{due_days}',
          await this.getSetting('invoice_due_days') || '30');
        invoiceData.terms = terms;
      }

      // Create the invoice
      // Revert to using spread operator, assuming date strings are handled correctly now
      // and that the database schema is correct after migrations.
      const invoice = await Invoice.create({
        ...invoiceData, // Spread the incoming data (should include dateCreated, dateDue as strings)
        client_id: clientId, // Use the standardized field name
        address_id: invoiceData.address_id,
        subtotal: 0,
        taxTotal: 0,
        total: 0,
        pdfPath: null // Ensure pdfPath isn't spread if it exists in invoiceData
      });

      // Create invoice items
      if (invoiceData.items && Array.isArray(invoiceData.items)) {
        for (const [index, item] of invoiceData.items.entries()) {
          await InvoiceItem.create({
            ...item,
            invoiceId: invoice.id,
            sortOrder: index
          });
        }
      }

      // Calculate totals
      await this.calculateInvoiceTotals(invoice.id);

      // Generate PDF
      if (invoiceData.generatePdf) {
        await this.generatePdf(invoice.id);
      }

      return this.getInvoiceWithDetails(invoice.id);
    } catch (error) {
      if (error.name === 'SequelizeValidationError') {
        // Log detailed validation errors
        const validationErrors = error.errors.map(err => ({
          message: err.message,
          path: err.path,
          value: err.value,
          type: err.type
        }));
        logger.error('Sequelize Validation Error creating invoice:', JSON.stringify(validationErrors, null, 2));
      } else {
        // Log other types of errors
        logger.error('Error creating invoice:', error);
      }
      throw error; // Re-throw the error to be caught by the controller
    }
  }

  /**
   * Update an existing invoice
   * @param {string} invoiceId - Invoice ID to update
   * @param {Object} invoiceData - Updated invoice data
   * @returns {Promise<Object>} - Updated invoice
   */
  async updateInvoice(invoiceId, invoiceData) {
    try {
      const invoice = await Invoice.findByPk(invoiceId);
      if (!invoice) {
        throw new Error('Invoice not found');
      }

      // Prevent updating certain fields if invoice is not in draft status
      if (invoice.status !== 'draft' &&
          (invoiceData.clientId || invoiceData.invoiceNumber)) {
        throw new Error('Cannot change client or invoice number for non-draft invoices');
      }

      // Update invoice fields
      await invoice.update(invoiceData);

      // Update invoice items if provided
      if (invoiceData.items && Array.isArray(invoiceData.items)) {
        // Delete existing items
        await InvoiceItem.destroy({ where: { invoiceId } });

        // Create new items
        for (const [index, item] of invoiceData.items.entries()) {
          await InvoiceItem.create({
            ...item,
            invoiceId,
            sortOrder: index
          });
        }
      }

      // Recalculate totals
      await this.calculateInvoiceTotals(invoiceId);

      // Generate new PDF if requested
      if (invoiceData.generatePdf) {
        await this.generatePdf(invoiceId);
      }

      return this.getInvoiceWithDetails(invoiceId);
    } catch (error) {
      logger.error(`Error updating invoice ${invoiceId}:`, error);
      throw error;
    }
  }

  /**
   * Get an invoice with all details
   * @param {string} invoiceId - Invoice ID
   * @returns {Promise<Object>} - Invoice with details
   */
  async getInvoiceWithDetails(invoiceId) {
    try {
      const invoice = await Invoice.findByPk(invoiceId, {
        include: [
          { model: InvoiceItem, as: 'items' },
          { model: Payment, as: 'payments' },
          {
            model: Client,
            as: 'client',
            include: [
              { model: ClientAddress, as: 'addresses' }
            ]
          },
          {
            model: ClientAddress,
            as: 'address'
          }
        ]
      });

      if (!invoice) {
        logger.warn(`Invoice not found with ID: ${invoiceId}`);
        return null;
      }

      // Additional logging to debug client information
      if (!invoice.client) {
        logger.warn(`Client data not loaded for invoice ${invoiceId} with client_fk_id: ${invoice.client_fk_id}`);

        // Try to load client data directly if the association failed
        if (invoice.client_fk_id) {
          try {
            const client = await Client.findByPk(invoice.client_fk_id, {
              include: [{ model: ClientAddress, as: 'addresses' }]
            });

            if (client) {
              logger.info(`Successfully loaded client data directly: ${client.display_name}`);
              invoice.client = client;
            } else {
              logger.warn(`Client with ID ${invoice.client_fk_id} not found in database`);
            }
          } catch (clientError) {
            logger.error(`Error loading client data directly: ${clientError.message}`);
          }
        }
      } else {
        logger.info(`Client data loaded successfully: ${invoice.client.display_name || invoice.client.display_name}`);
      }

      return invoice;
    } catch (error) {
      logger.error(`Error getting invoice details for ID ${invoiceId}:`, error);
      throw error;
    }
  }

  /**
   * List invoices with optional filters
   * @param {Object} filters - Query filters
   * @param {number} page - Page number (0-based)
   * @param {number} limit - Items per page
   * @returns {Promise<Object>} - Paginated invoices
   */
  async listInvoices(filters = {}, page = 0, limit = 10) {
    const where = {};

    // Apply filters
    if (filters.status) {
      where.status = filters.status;
    }

    if (filters.clientId) {
      // Support both client_id (standardized) and client_fk_id (legacy) fields
      if (this._isUuid(filters.clientId)) {
        where[Op.or] = [
          { client_id: filters.clientId },
          { client_fk_id: filters.clientId }
        ];
      }
    }

    if (filters.dateFrom) {
      where.dateCreated = {
        ...where.dateCreated,
        [Op.gte]: filters.dateFrom
      };
    }

    if (filters.dateTo) {
      where.dateCreated = {
        ...where.dateCreated,
        [Op.lte]: filters.dateTo
      };
    }

    // Pagination
    const offset = page * limit;

    // Log the query parameters
    logger.info(`Invoice query: where=${JSON.stringify(where)}, limit=${limit}, offset=${offset}`);

    // Execute count query separately for debugging
    const count = await Invoice.count({ where });
    logger.info(`Raw invoice count from database: ${count}`);

    // Execute query
    const { rows } = await Invoice.findAndCountAll({
      where,
      include: [
        { model: InvoiceItem, as: 'items' },
        { model: Payment, as: 'payments' },
        {
          model: Client,
          as: 'client',
          include: [
            { model: ClientAddress, as: 'addresses' }
          ]
        },
        {
          model: ClientAddress,
          as: 'address'
        }
      ],
      order: [['dateCreated', 'DESC']],
      limit,
      offset
    });

    // Create pagination result
    const result = {
      invoices: rows,
      total: count,
      page,
      limit,
      totalPages: Math.ceil(count / limit)
    };

    logger.info(`Pagination result: total=${result.total}, totalPages=${result.totalPages}`);
    return result;
  }

  /**
   * Helper method to check if a string is a valid UUID
   * @param {string} str - String to check
   * @returns {boolean} - True if valid UUID
   * @private
   */
  _isUuid(str) {
    if (!str) return false;
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    return uuidRegex.test(str);
  }

  /**
   * Calculate invoice totals
   * @param {string} invoiceId - Invoice ID
   * @returns {Promise<Object>} - Updated totals
   */
  async calculateInvoiceTotals(invoiceId) {
    try {
      // Get all items for this invoice
      const items = await InvoiceItem.findAll({
        where: { invoiceId }
      });

      let subtotal = 0;
      let taxTotal = 0;

      // Calculate item totals and update them
      for (const item of items) {
        const itemSubtotal = parseFloat(item.price) * parseFloat(item.quantity);
        const itemTax = itemSubtotal * (parseFloat(item.taxRate) / 100);
        const itemTotal = itemSubtotal + itemTax;

        await item.update({
          itemTotal
        });

        subtotal += itemSubtotal;
        taxTotal += itemTax;
      }

      // Get the invoice
      const invoice = await Invoice.findByPk(invoiceId);

      // Calculate total with discount
      const discountAmount = parseFloat(invoice.discountAmount) || 0;
      const total = subtotal + taxTotal - discountAmount;

      // Get total payments
      const payments = await Payment.findAll({
        where: { invoiceId }
      });

      const totalPaid = payments.reduce((sum, payment) =>
        sum + parseFloat(payment.amount), 0);

      // Update invoice totals
      await invoice.update({
        subtotal,
        taxTotal,
        total,
        status: this.determineInvoiceStatus(invoice, totalPaid)
      });

      return {
        subtotal,
        taxTotal,
        discountAmount,
        total,
        totalPaid,
        balance: total - totalPaid
      };
    } catch (error) {
      logger.error(`Error calculating totals for invoice ${invoiceId}:`, error);
      throw error;
    }
  }

  /**
   * Determine invoice status based on payment and dates
   * @param {Object} invoice - Invoice object
   * @param {number} totalPaid - Total amount paid
   * @returns {string} - New status
   */
  determineInvoiceStatus(invoice, totalPaid) {
    // If draft, don't change status
    if (invoice.status === 'draft') {
      return 'draft';
    }

    const total = parseFloat(invoice.total);

    // If fully paid
    if (totalPaid >= total) {
      return 'paid';
    }

    // Check if overdue
    const dueDate = new Date(invoice.dateDue);
    const today = new Date();

    if (dueDate < today) {
      return 'overdue';
    }

    // Default to sent or viewed (keep existing status)
    return invoice.status === 'viewed' ? 'viewed' : 'sent';
  }

  /**
   * Mark an invoice as sent
   * @param {string} invoiceId - Invoice ID
   * @returns {Promise<Object>} - Updated invoice
   */
  async markInvoiceAsSent(invoiceId) {
    const invoice = await Invoice.findByPk(invoiceId);

    if (!invoice) {
      throw new Error('Invoice not found');
    }

    if (invoice.status === 'draft') {
      await invoice.update({ status: 'sent' });

      // Generate PDF if not already generated
      if (!invoice.pdfPath) {
        await this.generatePdf(invoiceId);
      }
    }

    return this.getInvoiceWithDetails(invoiceId);
  }

  /**
   * Mark an invoice as viewed
   * @param {string} invoiceId - Invoice ID
   * @returns {Promise<Object>} - Updated invoice
   */
  async markInvoiceAsViewed(invoiceId) {
    const invoice = await Invoice.findByPk(invoiceId);

    if (!invoice) {
      throw new Error('Invoice not found');
    }

    if (invoice.status === 'sent') {
      await invoice.update({ status: 'viewed' });
    }

    return this.getInvoiceWithDetails(invoiceId);
  }

  /**
   * Add a payment to an invoice
   * @param {string} invoiceId - Invoice ID
   * @param {Object} paymentData - Payment data
   * @returns {Promise<Object>} - Updated invoice
   */
  async addPayment(invoiceId, paymentData) {
    try {
      const invoice = await Invoice.findByPk(invoiceId);

      if (!invoice) {
        throw new Error('Invoice not found');
      }

      // Create the payment
      const payment = await Payment.create({
        ...paymentData,
        invoiceId
      });

      // Recalculate totals
      await this.calculateInvoiceTotals(invoiceId);

      return this.getInvoiceWithDetails(invoiceId);
    } catch (error) {
      logger.error(`Error adding payment to invoice ${invoiceId}:`, error);
      throw error;
    }
  }

  /**
   * Delete an invoice
   * @param {string} invoiceId - Invoice ID
   * @returns {Promise<boolean>} - Success status
   */
  async deleteInvoice(invoiceId) {
    try {
      const invoice = await Invoice.findByPk(invoiceId);

      if (!invoice) {
        throw new Error('Invoice not found');
      }

      // Allow deleting any invoice regardless of status

      // Delete the invoice (will cascade to items)
      await invoice.destroy();

      return true;
    } catch (error) {
      logger.error(`Error deleting invoice ${invoiceId}:`, error);
      throw error;
    }
  }

  /**
   * Generate a PDF for an invoice
   * @param {string} invoiceId - Invoice ID
   * @returns {Promise<string>} - Path to generated PDF
   */
  async generatePdf(invoiceId) {
    try {
      const invoice = await this.getInvoiceWithDetails(invoiceId);

      if (!invoice) {
        throw new Error('Invoice not found');
      }

      // Get client details from the invoice's client relationship
      const client = invoice.client;

      if (!client) {
        throw new Error('Client not found');
      }

      // Set up output directory and filename
      const uploadsDir = path.join(__dirname, '../../uploads/invoices');
      const filename = `invoice_${invoice.invoiceNumber.replace(/[^a-zA-Z0-9]/g, '_')}.pdf`;

      // Prepare client information in the format expected by the PDF service
      const clientForPdf = {
        displayName: client.display_name,
        company: client.company,
        email: client.email,
        phone: client.phone
      };

      // Generate PDF using PDF service
      const pdfPath = await pdfService.generatePdf({
        type: 'invoice',
        data: invoice,
        client: clientForPdf,
        filename,
        outputDir: uploadsDir
      });

      // Update invoice with PDF path
      await invoice.update({ pdfPath });

      return pdfPath;
    } catch (error) {
      logger.error(`Error generating PDF for invoice ${invoiceId}:`, error);
      throw error;
    }
  }
}

module.exports = new InvoiceService();