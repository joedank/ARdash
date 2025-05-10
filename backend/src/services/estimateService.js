const { Estimate, EstimateItem, Invoice, Settings, Client, ClientAddress, SourceMap, sequelize } = require('../models');
const { ValidationError } = require('../utils/errors');
const { Op } = require('sequelize');
const fs = require('fs').promises;
const path = require('path');
const logger = require('../utils/logger');
const pdfService = require('./pdfService');
const invoiceService = require('./invoiceService'); // Keep for convertToInvoice
const fieldAdapter = require('../utils/field-adapter');

/**
 * Service for handling estimate operations
 */
class EstimateService {
  /**
   * Generate a new estimate number
   * @returns {Promise<string>} - New estimate number
   */
  async generateEstimateNumber() {
    try {
      const prefix = await this.getSetting('estimate_prefix') || 'EST-';
      let number = 1;
      let newEstimateNumber;
      let existingEstimate = null;

      // Find the highest existing number first
      const highestEstimate = await Estimate.findOne({
        order: [['estimateNumber', 'DESC']],
        paranoid: false // Include soft-deleted records
      });

      if (highestEstimate && highestEstimate.estimateNumber) {
        const numberPart = highestEstimate.estimateNumber.substring(prefix.length);
        const parsedNumber = parseInt(numberPart, 10);
        if (!isNaN(parsedNumber)) {
          number = parsedNumber + 1;
        }
      }

      // Loop to ensure uniqueness
      do {
        newEstimateNumber = `${prefix}${number.toString().padStart(5, '0')}`;
        logger.debug(`Attempting to generate estimate number: ${newEstimateNumber}`);
        existingEstimate = await Estimate.findOne({
          where: { estimateNumber: newEstimateNumber },
          paranoid: false // Include soft-deleted records
        });

        if (existingEstimate) {
          logger.warn(`Estimate number ${newEstimateNumber} already exists (possibly soft-deleted). Incrementing.`);
          number++;
        }
      } while (existingEstimate);

      logger.debug(`Final unique estimate number generated: ${newEstimateNumber}`);
      return newEstimateNumber;
    } catch (error) {
      logger.error('Error generating estimate number:', error);
      const fallbackNumber = `EST-${Math.floor(100000 + Math.random() * 900000)}`;
      logger.warn(`Falling back to random estimate number: ${fallbackNumber}`);
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
   * Create a new estimate with improved project linking
   * @param {Object} estimateData - Estimate data
   * @returns {Promise<Object>} - Created estimate
   */
  async createEstimate(estimateData) {
    let transaction = null;

    try {
      // Start a transaction to ensure data consistency
      transaction = await sequelize.transaction();

      // Ensure client exists using client_id
      if (!estimateData.client_id) {
          throw new Error('Client ID (client_id) is required');
      }
      const client = await Client.findByPk(estimateData.client_id, { transaction });
      if (!client) {
        throw new Error(`Client not found with ID: ${estimateData.client_id}`);
      }

      // Ensure address exists if address_id is provided
      if (estimateData.address_id) {
          const address = await ClientAddress.findOne({
              where: { id: estimateData.address_id, client_id: estimateData.client_id },
              transaction
          });
          if (!address) {
              throw new Error(`Address with ID ${estimateData.address_id} not found for client ${estimateData.client_id}`);
          }
      }

      // Verify project exists if project_id is provided
      let project = null;
      if (estimateData.project_id) {
        project = await require('../models').Project.findByPk(estimateData.project_id, { transaction });
        if (!project) {
          throw new Error(`Project not found with ID: ${estimateData.project_id}`);
        }
        // Ensure the project and client match
        if (project.client_id !== estimateData.client_id) {
          throw new Error(`Project ${estimateData.project_id} does not belong to client ${estimateData.client_id}`);
        }
      }

      // Generate estimate number if not provided
      if (!estimateData.estimateNumber) {
        estimateData.estimateNumber = await this.generateEstimateNumber();
      }

      // Set valid until date if not provided
      if (!estimateData.validUntil) {
        const validDays = parseInt(await this.getSetting('estimate_valid_days') || '30', 10);
        const createDate = estimateData.dateCreated ? new Date(estimateData.dateCreated) : new Date();
        const validDate = new Date(createDate);
        validDate.setDate(validDate.getDate() + validDays);
        estimateData.validUntil = validDate.toISOString().split('T')[0]; // Format as YYYY-MM-DD
      }

      // Ensure dateCreated is set
      if (!estimateData.dateCreated) {
        estimateData.dateCreated = new Date().toISOString().split('T')[0]; // Format as YYYY-MM-DD
      }

      // Set terms if not provided
      if (!estimateData.terms) {
        let terms = await this.getSetting('default_estimate_terms') ||
          'This estimate is valid for {valid_days} days.';
        terms = terms.replace('{valid_days}',
          await this.getSetting('estimate_valid_days') || '30');
        estimateData.terms = terms;
      }

      // Create the estimate
      const estimate = await Estimate.create({
        ...estimateData, // Includes client_id, address_id (if provided)
        subtotal: 0,
        taxTotal: 0,
        total: 0
      }, { transaction });

      // Create estimate items
      if (estimateData.items && Array.isArray(estimateData.items)) {
        for (const [index, item] of estimateData.items.entries()) {
          await EstimateItem.create({
            ...item,
            estimateId: estimate.id,
            sortOrder: index
          }, { transaction });
        }
      }

      // Calculate totals
      await this.calculateEstimateTotals(estimate.id, transaction);

      // IMPORTANT: Update the project to reference this estimate if project_id was provided
      if (project) {
        // Update project to link back to this estimate
        await project.update({ estimate_id: estimate.id }, { transaction });
        logger.info(`Updated project ${project.id} to reference estimate ${estimate.id}`);
      }

      // Commit the transaction
      await transaction.commit();
      transaction = null;

      // Return the complete estimate with details
      return this.getEstimateWithDetails(estimate.id);
    } catch (error) {
      // Rollback transaction on error
      if (transaction) await transaction.rollback();

      if (error.name === 'SequelizeValidationError') {
        // Log detailed validation errors
        const validationErrors = error.errors.map(err => ({
          message: err.message,
          path: err.path,
          value: err.value,
          type: err.type
        }));
        logger.error('Sequelize Validation Error creating estimate:', JSON.stringify(validationErrors, null, 2));
      } else {
        // Log other types of errors
        logger.error('Error creating estimate:', error);
      }
      throw error; // Re-throw the error
    }
  }

  /**
   * Create a new estimate with source mapping for bidirectional linking
   * @param {Object} estimateData - Estimate data with source mapping
   * @returns {Promise<Object>} - Created estimate with source mapping
   */
  async createEstimateWithSourceMap(estimateData) {
    let transaction = null;

    try {
      // Start a transaction to ensure data consistency
      transaction = await sequelize.transaction();

      // Ensure client exists using client_id
      if (!estimateData.client_id) {
        throw new Error('Client ID is required');
      }

      const client = await Client.findByPk(estimateData.client_id, { transaction });
      if (!client) {
        throw new Error(`Client not found with ID: ${estimateData.client_id}`);
      }

      // Verify project exists if project_id is provided
      let project = null;
      if (estimateData.project_id) {
        project = await require('../models').Project.findByPk(estimateData.project_id, { transaction });
        if (!project) {
          throw new Error(`Project not found with ID: ${estimateData.project_id}`);
        }
        // Ensure the project and client match
        if (project.client_id !== estimateData.client_id) {
          throw new Error(`Project ${estimateData.project_id} does not belong to client ${estimateData.client_id}`);
        }
      }

      // Generate estimate number if not provided
      if (!estimateData.estimateNumber) {
        estimateData.estimateNumber = await this.generateEstimateNumber();
      }

      // Set valid until date if not provided
      if (!estimateData.validUntil) {
        const validDays = parseInt(await this.getSetting('estimate_valid_days') || '30', 10);
        const createDate = estimateData.dateCreated ? new Date(estimateData.dateCreated) : new Date();
        const validDate = new Date(createDate);
        validDate.setDate(validDate.getDate() + validDays);
        estimateData.validUntil = validDate.toISOString().split('T')[0]; // Format as YYYY-MM-DD
      }

      // Ensure dateCreated is set
      if (!estimateData.dateCreated) {
        estimateData.dateCreated = new Date().toISOString().split('T')[0]; // Format as YYYY-MM-DD
      }

      // Set terms if not provided
      if (!estimateData.terms) {
        let terms = await this.getSetting('default_estimate_terms') ||
          'This estimate is valid for {valid_days} days.';
        terms = terms.replace('{valid_days}',
          await this.getSetting('estimate_valid_days') || '30');
        estimateData.terms = terms;
      }

      // Create the estimate
      const estimate = await Estimate.create({
        client_id: estimateData.client_id,
        address_id: estimateData.address_id || null,
        project_id: estimateData.project_id || null,
        estimateNumber: estimateData.estimateNumber,
        dateCreated: estimateData.dateCreated,
        validUntil: estimateData.validUntil,
        terms: estimateData.terms,
        status: estimateData.status || 'draft',
        subtotal: 0,
        taxTotal: 0,
        total: 0
      }, { transaction });

      logger.info(`Created new estimate with ID: ${estimate.id}`);

      // Create estimate items
      if (estimateData.items && Array.isArray(estimateData.items)) {
        for (const [index, item] of estimateData.items.entries()) {
          const estimateItem = await EstimateItem.create({
            description: item.description,
            quantity: item.quantity,
            unit: item.unit || 'each',
            price: item.unit_price || item.unitPrice,
            taxRate: item.taxRate || 0,
            estimateId: estimate.id,
            sortOrder: index,
            source_type: item.source_type || item.sourceType || null,
            source_id: item.source_id || item.sourceId || null,
            source_data: item.source_data || item.sourceData || null,
            product_id: item.product_id || null
          }, { transaction });

          // Add source mapping if sourceMap is provided and this item has a sourceId
          if (estimateData.sourceMap &&
              (item.source_id || item.sourceId) &&
              estimateData.sourceMap[(item.source_id || item.sourceId)]) {

            const sourceId = item.source_id || item.sourceId;
            const sourceMapData = estimateData.sourceMap[sourceId];

            await SourceMap.create({
              estimate_item_id: estimateItem.id,
              source_type: sourceMapData.type || 'unknown',
              source_data: {
                id: sourceId,
                label: sourceMapData.label || '',
                value: sourceMapData.value || '',
                unit: sourceMapData.unit || ''
              },
              created_at: new Date(),
              updated_at: new Date()
            }, { transaction });
          }
        }
      }

      // Calculate totals
      await this.calculateEstimateTotals(estimate.id, transaction);

      // IMPORTANT: Update the project to reference this estimate if project_id was provided
      if (project) {
        // Update project to link back to this estimate
        await project.update({ estimate_id: estimate.id }, { transaction });
        logger.info(`Updated project ${project.id} to reference estimate ${estimate.id}`);
      }

      // Commit the transaction
      await transaction.commit();
      transaction = null;

      return this.getEstimateWithDetails(estimate.id);
    } catch (error) {
      // Rollback transaction on error
      if (transaction) await transaction.rollback();

      logger.error('Error creating estimate with source map:', error);
      throw error; // Re-throw the error
    }
  }

  /**
   * Get source map for an estimate
   * @param {string} estimateId - Estimate ID
   * @returns {Promise<Object>} - Source mapping data
   */
  async getEstimateSourceMap(estimateId) {
    try {
      // Get all items for this estimate with their source mappings
      const items = await EstimateItem.findAll({
        where: { estimateId },
        include: [
          { model: SourceMap, as: 'sourceMaps' }
        ]
      });

      // Build a consolidated source map
      const sourceMap = {};

      for (const item of items) {
        if (item.source_id && item.source_type) {
          sourceMap[item.source_id] = {
            type: item.source_type,
            estimateItemId: item.id,
            // Include other relevant data from source_maps if available
            ...((item.sourceMaps && item.sourceMaps.length > 0) ?
                 item.sourceMaps[0].source_data : {})
          };
        }

        // Include source maps attached to this item
        if (item.sourceMaps && item.sourceMaps.length > 0) {
          for (const mapping of item.sourceMaps) {
            if (mapping.source_data && mapping.source_data.id) {
              sourceMap[mapping.source_data.id] = {
                type: mapping.source_type,
                estimateItemId: item.id,
                ...mapping.source_data
              };
            }
          }
        }
      }

      return sourceMap;
    } catch (error) {
      logger.error(`Error getting source map for estimate ${estimateId}:`, error);
      throw error; // Re-throw the error
    }
  }

  /**
   * Update an existing estimate
   * @param {string} estimateId - Estimate ID to update
   * @param {Object} estimateData - Updated estimate data
   * @returns {Promise<Object>} - Updated estimate
   */
  async updateEstimate(estimateId, estimateData) {
    try {
      const estimate = await Estimate.findByPk(estimateId);
      if (!estimate) {
        throw new Error('Estimate not found');
      }

      // Prevent updating certain fields if estimate is not in draft status
      if (estimate.status !== 'draft' &&
          (estimateData.client_id || estimateData.estimateNumber)) { // Check standardized client_id
        throw new ValidationError('Cannot change client or estimate number for non-draft estimates');
      }

       // Ensure address exists if address_id is provided and changing
       if (estimateData.address_id && estimateData.address_id !== estimate.address_id) {
        const client_id_to_check = estimateData.client_id || estimate.client_id; // Use standardized client_id
        const address = await ClientAddress.findOne({
            where: { id: estimateData.address_id, client_id: client_id_to_check }
        });
        if (!address) {
            throw new Error(`Address with ID ${estimateData.address_id} not found for client ${client_id_to_check}`);
        }
      }

      // Update estimate fields
      await estimate.update(estimateData);

      // Update estimate items if provided
      if (estimateData.items && Array.isArray(estimateData.items)) {
        // Delete existing items
        await EstimateItem.destroy({ where: { estimateId } });

        // Create new items
        for (const [index, item] of estimateData.items.entries()) {
          await EstimateItem.create({
            ...item,
            estimateId,
            sortOrder: index
          });
        }
      }

      // Recalculate totals
      await this.calculateEstimateTotals(estimateId);

      // PDF generation is now typically handled separately via controller/route
      // if (estimateData.generatePdf) {
      //  await this.generateEstimatePDF(estimateId); // Call new function if needed immediately
      // }

      return this.getEstimateWithDetails(estimateId);
    } catch (error) {
      logger.error(`Error updating estimate ${estimateId}:`, error);
      throw error;
    }
  }

  /**
   * Get an estimate with all details
   * @param {string} estimateId - Estimate ID
   * @returns {Promise<Object>} - Estimate with details
   */
  async getEstimateWithDetails(estimateId) {
    try {
      // Validate UUID format before querying
      const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
      if (!estimateId || !uuidRegex.test(estimateId)) {
        throw new Error(`Invalid UUID format: ${estimateId}`);
      }

      // MODIFICATION: Reinstate attributes array for main Estimate model
      // and correct the alias for EstimateItem include.
      const estimate = await Estimate.findByPk(estimateId, {
        attributes: [ // Explicitly list required attributes for Estimate
          'id',
          'estimate_number',
          'client_id',
          'address_id',
          'date_created',
          'valid_until',
          'status',
          'subtotal',
          'tax_total',
          'discount_amount',
          'total',
          'notes',
          'terms',
          'pdf_path',
          'converted_to_invoice_id',
          'project_id',
          'created_at',
          'updated_at'
        ],
        include: [
          {
            model: EstimateItem,
            as: 'items', // Corrected alias from 'estimateItems' to 'items'
            attributes: [
              'id',
              'estimate_id', // Keep field name consistent with model definition
              'description',
              'quantity',
              'price',
              'tax_rate',
              'item_total',
              'sort_order',
              'product_id',
              'source_data',
              'unit',
              'custom_product_data',
              'created_at',
              'updated_at'
            ],
            order: [['sort_order', 'ASC']]
          },
          {
            model: Invoice,
            as: 'invoice'
          },
          {
            model: Client,
            as: 'client',
            attributes: ['id', 'display_name', 'company', 'email', 'phone', 'client_type'],
            include: [{
              model: ClientAddress,
              as: 'addresses',
              attributes: [
                'id',
                'client_id',
                'name',
                'street_address',
                'city',
                'state',
                'postal_code',
                'country',
                'is_primary',
                'notes',
                'created_at',
                'updated_at'
              ]
            }]
          },
          {
            model: ClientAddress,
            as: 'address'
          },
          {
            model: require('../models').Project,
            as: 'project',
            attributes: [
              'id',
              'client_id',
              'address_id',
              'estimate_id',
              'type',
              'status',
              'scheduled_date',
              'condition',
              'additional_work',
              'assessment_id',
              'converted_to_job_id',
              'created_at',
              'updated_at'
            ]
          }
        ]
      });

      if (!estimate) {
        throw new Error(`Estimate with id ${estimateId} not found`);
      }

      return estimate;
    } catch (error) {
      logger.error('Error in getEstimateWithDetails:', error);
      throw error;
    }
  }

  /**
   * List estimates with optional filters
   * @param {Object} filters - Query filters
   * @param {number} page - Page number (0-based)
   * @param {number} limit - Items per page
   * @returns {Promise<Object>} - Paginated estimates
   */
  async listEstimates(filters = {}, page = 0, limit = 10) {
    const where = {};

    // Apply filters
    if (filters.status) {
      where.status = filters.status;
    }

    if (filters.clientId) { // Map to standardized client_id field
      where.client_id = filters.clientId;
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
    logger.info(`Estimate query: where=${JSON.stringify(where)}, limit=${limit}, offset=${offset}`);

    // Execute count query separately for debugging
    const count = await Estimate.count({ where });
    logger.info(`Raw estimate count from database: ${count}`);

    // Execute query
    const { rows } = await Estimate.findAndCountAll({
      where,
      include: [
        { model: EstimateItem, as: 'items' },
        { model: Client, as: 'client', attributes: ['id', 'display_name'] } // Include client name for list view
      ],
      order: [['dateCreated', 'DESC']],
      limit,
      offset
    });

    // Create pagination result
    const result = {
      estimates: rows,
      total: count,
      page,
      limit,
      totalPages: Math.ceil(count / limit)
    };

    logger.info(`Pagination result: total=${result.total}, totalPages=${result.totalPages}`);
    return result;
  }

  /**
   * Calculate estimate totals
   * @param {string} estimateId - Estimate ID
   * @param {Transaction} transaction - Optional Sequelize transaction
   * @returns {Promise<Object>} - Updated totals
   */
  async calculateEstimateTotals(estimateId, transaction = null) {
    try {
      // Get all items for this estimate
      const items = await EstimateItem.findAll({
        where: { estimateId },
        ...(transaction ? { transaction } : {})
      });

      let subtotal = 0;
      let taxTotal = 0;

      // Calculate item totals and update them
      for (const item of items) {
        const itemPrice = parseFloat(item.price) || 0;
        const itemQuantity = parseFloat(item.quantity) || 0;
        const itemTaxRate = parseFloat(item.taxRate) || 0;

        const itemSubtotal = itemPrice * itemQuantity;
        const itemTax = itemSubtotal * (itemTaxRate / 100);
        const itemTotal = itemSubtotal + itemTax;

        // Update itemTotal in the database if it changed
        if (item.itemTotal !== itemTotal) {
            await item.update({ itemTotal },
              transaction ? { transaction } : undefined);
        }

        subtotal += itemSubtotal;
        taxTotal += itemTax;
      }

      // Get the estimate
      const estimate = await Estimate.findByPk(estimateId,
        transaction ? { transaction } : undefined);
      if (!estimate) {
          logger.warn(`Estimate ${estimateId} not found during total calculation.`);
          return; // Or throw error
      }

      // Calculate total with discount
      const discountAmount = parseFloat(estimate.discountAmount) || 0;
      const total = subtotal + taxTotal - discountAmount;

      // Update estimate totals
      await estimate.update({
        subtotal,
        taxTotal,
        total,
        status: this.determineEstimateStatus(estimate) // Recalculate status based on dates
      }, transaction ? { transaction } : undefined);

      return {
        subtotal,
        taxTotal,
        discountAmount,
        total
      };
    } catch (error) {
      logger.error(`Error calculating totals for estimate ${estimateId}:`, error);
      throw error;
    }
  }

  /**
   * Determine estimate status based on dates and current status
   * @param {Object} estimate - Estimate object
   * @returns {string} - New status
   */
  determineEstimateStatus(estimate) {
    // If already accepted/rejected, don't change
    if (['accepted', 'rejected'].includes(estimate.status)) {
      return estimate.status;
    }

    // Check if expired
    const validUntil = new Date(estimate.validUntil);
    const today = new Date();
    today.setHours(0, 0, 0, 0); // Compare dates only

    if (validUntil < today && estimate.status !== 'draft') {
      return 'expired';
    }

    // Keep current status otherwise
    return estimate.status;
  }

  /**
   * Mark an estimate as sent
   * @param {string} estimateId - Estimate ID
   * @returns {Promise<Object>} - Updated estimate
   */
  async markEstimateAsSent(estimateId) {
    const estimate = await Estimate.findByPk(estimateId);

    if (!estimate) {
      throw new Error('Estimate not found');
    }

    if (estimate.status === 'draft') {
      await estimate.update({ status: 'sent' });

      // Generate PDF if not already generated
      if (!estimate.pdfPath) {
        await this.generateEstimatePDF(estimateId); // Call the new function
      }
    }

    return this.getEstimateWithDetails(estimateId);
  }

  /**
   * Mark an estimate as accepted
   * @param {string} estimateId - Estimate ID
   * @returns {Promise<Object>} - Updated estimate
   */
  async markEstimateAsAccepted(estimateId) {
    const estimate = await Estimate.findByPk(estimateId);

    if (!estimate) {
      throw new Error('Estimate not found');
    }

    if (['sent', 'viewed'].includes(estimate.status)) {
      await estimate.update({ status: 'accepted' });
    }

    return this.getEstimateWithDetails(estimateId);
  }

  /**
   * Mark an estimate as rejected
   * @param {string} estimateId - Estimate ID
   * @returns {Promise<Object>} - Updated estimate
   */
  async markEstimateAsRejected(estimateId) {
    const estimate = await Estimate.findByPk(estimateId);

    if (!estimate) {
      throw new Error('Estimate not found');
    }

    if (['sent', 'viewed'].includes(estimate.status)) {
      await estimate.update({ status: 'rejected' });
    }

    return this.getEstimateWithDetails(estimateId);
  }

  /**
   * Convert an estimate to an invoice
   * @param {string} estimateId - Estimate ID
   * @returns {Promise<Object>} - Created invoice
   */
  async convertToInvoice(estimateId) {
    try {
      const estimate = await this.getEstimateWithDetails(estimateId);

      if (!estimate) {
        throw new Error('Estimate not found');
      }

      // Only convert estimates that are accepted or sent/viewed
      if (!['accepted', 'sent', 'viewed'].includes(estimate.status)) {
        throw new Error('Only accepted, sent, or viewed estimates can be converted to invoices');
      }

      // Check if already converted
      if (estimate.convertedToInvoiceId) {
        const existingInvoice = await Invoice.findByPk(estimate.convertedToInvoiceId);
        if (existingInvoice) {
          logger.info(`Estimate ${estimateId} already converted to invoice ${existingInvoice.id}`);
          return existingInvoice;
        }
      }

      // Create invoice data from estimate
      const invoiceData = {
        client_id: estimate.client_id, // Use standardized client_id
        address_id: estimate.address_id, // Pass the selected address ID
        dateCreated: new Date().toISOString().split('T')[0], // Use today's date
        // dateDue will be set by createInvoice based on settings/client terms
        items: estimate.items.map(item => ({
          description: item.description,
          quantity: item.quantity,
          price: item.price,
          taxRate: item.taxRate
        })),
        notes: estimate.notes,
        terms: estimate.terms, // Consider using default invoice terms instead?
        discountAmount: estimate.discountAmount,
        status: 'draft', // Start invoice as draft
        generatePdf: true // Generate PDF upon creation
      };

      // Create the invoice using invoiceService
      const invoice = await invoiceService.createInvoice(invoiceData);

      // Update the estimate with the invoice ID
      await estimate.update({
        status: 'accepted', // Mark estimate as accepted upon conversion
        convertedToInvoiceId: invoice.id
      });

      logger.info(`Estimate ${estimateId} converted to invoice ${invoice.id}`);
      return invoice;
    } catch (error) {
      logger.error(`Error converting estimate ${estimateId} to invoice:`, error);
      throw error;
    }
  }

  /**
   * Delete an estimate
   * @param {string} estimateId - Estimate ID
   * @returns {Promise<boolean>} - Success status
   */
  async deleteEstimate(estimateId) {
    try {
      const estimate = await Estimate.findByPk(estimateId);

      if (!estimate) {
        throw new Error('Estimate not found');
      }

      // Allow deleting any estimate regardless of status

      // Delete associated items first
      await EstimateItem.destroy({ where: { estimateId } });

      // Delete the estimate (soft delete if paranoid: true)
      await estimate.destroy();

      logger.info(`Estimate ${estimateId} deleted successfully.`);
      return true;
    } catch (error) {
      logger.error(`Error deleting estimate ${estimateId}:`, error);
      throw error;
    }
  }

  /**
   * Generate or retrieve the PDF for an estimate
   * @param {string} estimateId - ID of the estimate
   * @returns {Promise<string>} - Path to the generated or existing PDF
   */
  async generateEstimatePDF(estimateId) {
    try {
      logger.info(`Starting PDF generation/retrieval for estimate ID: ${estimateId}`);

      const estimate = await this.getEstimateWithDetails(estimateId);

      if (!estimate) {
        throw new Error(`Estimate with ID ${estimateId} not found`);
      }

      // Log estimate details for debugging
      logger.info(`Estimate details: id=${estimate.id}, estimateNumber=${estimate.estimateNumber || estimate.estimate_number}, client_id=${estimate.client_id}`);

      if (!estimate.client) {
        throw new Error(`Client details not found for estimate ${estimateId}`);
      }

      // Log client details for debugging
      logger.info(`Client details: id=${estimate.client.id}, name=${estimate.client.display_name}`);

      // Log raw estimate data for debugging
      logger.debug('Raw estimate data:', JSON.stringify({
        id: estimate.id,
        estimateNumber: estimate.estimateNumber,
        estimate_number: estimate.estimate_number,
        client_id: estimate.client_id,
        address_id: estimate.address_id
      }));

      // Determine the correct client address to use
      // Use the specific address linked to the estimate first, then fallback to primary/first client address
      let clientAddress = null;

      if (estimate.address) {
        clientAddress = estimate.address;
        logger.info(`Using address directly linked to estimate: ${clientAddress.id}`);
      } else if (estimate.client.addresses && estimate.client.addresses.length > 0) {
        // Find primary address first
        clientAddress = estimate.client.addresses.find(addr => addr.is_primary);

        // If no primary address, use the first one
        if (!clientAddress) {
          clientAddress = estimate.client.addresses[0];
        }

        logger.info(`Using client address: ${clientAddress.id}, isPrimary: ${clientAddress.is_primary}`);
      } else {
        logger.warn(`No address found for estimate ${estimateId} or client ${estimate.client.id}`);
      }

      // Set up output directory and filename
      const uploadsDir = path.join(__dirname, '../../uploads/estimates');

      // Ensure directory exists
      try {
        await fs.mkdir(uploadsDir, { recursive: true });
        logger.info(`Ensured uploads directory exists at: ${uploadsDir}`);
      } catch (dirError) {
        logger.error(`Error creating uploads directory: ${uploadsDir}`, dirError);
        throw new Error(`Failed to create uploads directory: ${dirError.message}`);
      }

      // Safely create filename with fallback if estimateNumber is undefined
      const estimateNumber = estimate.estimateNumber || estimate.estimate_number || `EST-${Date.now()}`;
      const filename = `estimate_${estimateNumber.replace(/[^a-zA-Z0-9]/g, '_')}.pdf`;
      const fullPath = path.join(uploadsDir, filename);

      logger.info(`Target PDF path for estimate ${estimateId}: ${fullPath}`);

      // Regenerate PDF to ensure latest data/styling
      logger.info(`Generating fresh PDF for estimate ID: ${estimateId}`);

      // Prepare data for PDF service
      const estimateData = fieldAdapter.toFrontend(estimate.toJSON());
      const clientData = fieldAdapter.toFrontend(estimate.client.toJSON());
      const clientAddressData = clientAddress ? fieldAdapter.toFrontend(clientAddress.toJSON()) : null;

      logger.info(`Prepared data for PDF generation: estimate ${estimateId}, client ${clientData.id}`);

      // Generate PDF using the shared pdfService with normalized data
      const pdfPath = await pdfService.generatePdf({
        type: 'estimate',
        data: estimateData,
        client: clientData,
        clientAddress: clientAddressData,
        filename,
        outputDir: uploadsDir
      });

      logger.info(`Estimate PDF generated successfully at: ${pdfPath}`);

      // Update estimate with the new PDF path if it changed or was null
      if (estimate.pdfPath !== pdfPath) {
          await estimate.update({ pdfPath });
          logger.info(`Updated estimate ${estimateId} with PDF path: ${pdfPath}`);
      }

      return pdfPath;
    } catch (error) {
      logger.error(`Error generating PDF for estimate ${estimateId}:`, error);
      throw error; // Re-throw the error
    }
  }
}

module.exports = new EstimateService();