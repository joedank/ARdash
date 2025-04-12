const puppeteer = require('puppeteer');
const ejs = require('ejs');
const fs = require('fs').promises;
const path = require('path');
const logger = require('../utils/logger');
const { Settings, ClientAddress, Client } = require('../models');

/**
 * Service for generating PDF documents (invoices and estimates) using Puppeteer and EJS
 */
class PDFService {
  /**
   * Get a setting value by key
   * @param {string} key - Setting key
   * @returns {Promise<string|null>} - Setting value or null
   */
  async getSetting(key) {
    try {
      const setting = await Settings.findOne({ where: { key } });
      return setting ? setting.value : null;
    } catch (error) {
      logger.error(`Error fetching setting ${key}:`, error);
      return null;
    }
  }

  /**
   * Generate a PDF document for an invoice
   * @param {string} invoiceId - ID of the invoice
   * @returns {Promise<string>} - Path to generated PDF
   */
  async generateInvoicePDF(invoiceId) {
    try {
      const { Invoice, InvoiceItem, Payment } = require('../models'); // Client, ClientAddress already required

      logger.info(`Starting PDF generation for invoice ID: ${invoiceId}`);

      // Get the invoice with all details
      const invoice = await Invoice.findByPk(invoiceId, {
        include: [
          { model: InvoiceItem, as: 'items', order: [['sort_order', 'ASC']] }, // Ensure items are ordered
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
            as: 'address' // Specific address linked to the invoice
          }
        ]
      });

      if (!invoice) {
        throw new Error(`Invoice with ID ${invoiceId} not found`);
      }

      if (!invoice.client) {
        throw new Error(`Client for invoice ID ${invoiceId} not found`);
      }

      logger.info(`Found invoice ${invoiceId} with invoice number: ${invoice.invoiceNumber}`);

      // Determine the correct client address to use
      let clientAddress = invoice.address; // Use the specific address if available
      if (!clientAddress && invoice.client.addresses && invoice.client.addresses.length > 0) {
        // Fallback to primary or first address from the client
        clientAddress = invoice.client.addresses.find(addr => addr.is_primary) || invoice.client.addresses[0];
      }

      // Set up output directory and filename
      const uploadsDir = path.join(__dirname, '../../uploads/invoices');
      await fs.mkdir(uploadsDir, { recursive: true }); // Ensure directory exists

      const filename = `invoice_${invoice.invoiceNumber.replace(/[^a-zA-Z0-9]/g, '_')}.pdf`;
      const fullPath = path.join(uploadsDir, filename);

      logger.info(`Will generate PDF at path: ${fullPath}`);

      // Generate PDF using the new method
      const pdfPath = await this.generatePdf({
        type: 'invoice',
        data: invoice.toJSON(), // Pass plain JSON object
        client: invoice.client.toJSON(), // Pass plain JSON object
        clientAddress: clientAddress ? clientAddress.toJSON() : null, // Pass plain JSON object or null
        filename,
        outputDir: uploadsDir
      });

      logger.info(`PDF generated successfully at: ${pdfPath}`);

      // Update invoice with PDF path
      await invoice.update({ pdfPath });
      logger.info(`Updated invoice ${invoiceId} with PDF path: ${pdfPath}`);

      return pdfPath;
    } catch (error) {
      logger.error(`Error generating PDF for invoice ${invoiceId}:`, error);
      throw error; // Re-throw the error to be caught by the controller
    }
  }

  /**
   * Generate a PDF document for an invoice or estimate using Puppeteer
   * @param {Object} options - Options for PDF generation
   * @param {string} options.type - 'invoice' or 'estimate'
   * @param {Object} options.data - Invoice or estimate data (plain object)
   * @param {Object} options.client - Client information (plain object)
   * @param {Object|null} options.clientAddress - Client address information (plain object) or null
   * @param {string} options.filename - Output filename
   * @param {string} options.outputDir - Directory to save the PDF
   * @returns {Promise<string>} - Path to generated PDF
   */
  async generatePdf(options) {
    let browser = null;
    try {
      const { type, data, client, clientAddress, filename, outputDir } = options;

      if (!['invoice', 'estimate'].includes(type)) {
        throw new Error('Invalid document type. Must be "invoice" or "estimate"');
      }

      if (!data || !client) {
        throw new Error('Missing required data for PDF generation');
      }

      // --- Load Settings ---
      const settingsKeys = [
        'company_name', 'company_address', 'company_phone', 'company_email',
        'company_website', 'company_logo_path', 'primary_color', 'pdf_background_color',
        'pdf_secondary_color', 'pdf_table_border_color', 'pdf_page_margin',
        'pdf_header_margin', 'pdf_footer_margin', 'pdf_watermark_text',
        'pdf_invoice_footer', 'pdf_estimate_footer'
      ];
      const settingsPromises = settingsKeys.map(key => this.getSetting(key));
      const settingsValues = await Promise.all(settingsPromises);
      const settings = settingsKeys.reduce((acc, key, index) => {
        acc[key] = settingsValues[index];
        return acc;
      }, {});

      // Provide defaults for essential settings
      settings.company_name = settings.company_name || 'Your Company';
      settings.primary_color = settings.primary_color || '#3b82f6';
      settings.pdf_background_color = settings.pdf_background_color || '#f8f9fa';
      settings.pdf_secondary_color = settings.pdf_secondary_color || '#64748b';
      settings.pdf_table_border_color = settings.pdf_table_border_color || '#e2e8f0';
      settings.pdf_page_margin = settings.pdf_page_margin || '50';
      settings.pdf_header_margin = settings.pdf_header_margin || '30';
      settings.pdf_footer_margin = settings.pdf_footer_margin || '30';
      settings.pdf_invoice_footer = settings.pdf_invoice_footer || 'Thank you for your business.';
      settings.pdf_estimate_footer = settings.pdf_estimate_footer || 'Thank you for considering our services.';

      logger.debug('PDF Settings Loaded for Puppeteer:', settings);

      // --- Prepare Logo Data URI ---
      let logoDataUri = null;
      if (settings.company_logo_path) {
        try {
          const logoPath = path.join(__dirname, '../../uploads/logos', settings.company_logo_path);
          const logoBuffer = await fs.readFile(logoPath);
          const ext = path.extname(settings.company_logo_path).toLowerCase().substring(1);
          const mimeType = `image/${ext === 'jpg' ? 'jpeg' : ext}`; // Handle jpg/jpeg
          logoDataUri = `data:${mimeType};base64,${logoBuffer.toString('base64')}`;
          logger.debug(`Generated logo data URI for ${settings.company_logo_path}`);
        } catch (logoError) {
          logger.error(`Could not read or encode logo file: ${settings.company_logo_path}`, logoError);
          // Continue without logo if there's an error
        }
      }

      // --- Prepare Template Data ---
      const templateData = {
        type,
        data,
        client,
        clientAddress,
        settings,
        logoDataUri: logoDataUri, // Pass the data URI
        formatCurrency: (value) => `$${parseFloat(value || 0).toFixed(2)}`,
        formatDate: (dateString) => dateString ? new Date(dateString).toLocaleDateString() : '',
        nl2br: (str) => (str || '').replace(/(\r\n|\n\r|\r|\n)/g, '<br>'),
        // Add any other helper functions needed in the template
      };

      // --- Render HTML ---
      const templatePath = path.join(__dirname, '../templates/pdf/invoice.ejs'); // Assuming one template for now
      const htmlContent = await ejs.renderFile(templatePath, templateData);

      // --- Launch Puppeteer ---
      logger.info('Launching Puppeteer browser...');
      browser = await puppeteer.launch({
        headless: true, // Use true for server environments
        args: ['--no-sandbox', '--disable-setuid-sandbox'] // Necessary for some environments
      });
      const page = await browser.newPage();

      // --- Generate PDF ---
      logger.info('Setting page content and generating PDF...');
      // It's crucial to wait until network is idle if loading external resources like fonts or images
      await page.setContent(htmlContent, { waitUntil: 'networkidle0' });

      // Define PDF options
      const pdfPath = path.join(outputDir, filename);
      const pdfOptions = {
        path: pdfPath,
        format: 'Letter', // Standard US Letter size
        printBackground: true, // Include background colors and images
        margin: {
          top: `${settings.pdf_header_margin}px`,
          right: `${settings.pdf_page_margin}px`,
          bottom: `${settings.pdf_footer_margin}px`,
          left: `${settings.pdf_page_margin}px`,
        },
        // We might need displayHeaderFooter and header/footer templates later
        // displayHeaderFooter: true,
        // headerTemplate: '<div></div>', // Empty header, handled in main content
        // footerTemplate: `<div style="font-size: 9px; margin: 0 auto; text-align: center; width: 100%;">Page <span class="pageNumber"></span> of <span class="totalPages"></span></div>`,
      };

      await page.pdf(pdfOptions);
      logger.info(`PDF successfully generated at ${pdfPath}`);

      return pdfPath;

    } catch (error) {
      logger.error(`Error in generatePdf with Puppeteer: ${error.message}`, error.stack);
      throw error; // Re-throw the error
    } finally {
      if (browser) {
        logger.info('Closing Puppeteer browser...');
        await browser.close();
      }
    }
  }
}

module.exports = new PDFService();