const { sequelize } = require('./database');
const models = require('../models');
const logger = require('./logger');

async function initializeDatabase() {
  try {
    // Test connection
    await sequelize.authenticate();
    logger.info('Database connection has been established successfully.');

    // Create tables (force: false to avoid dropping existing tables)
    // await sequelize.sync({ alter: true }); // Disabled: Use migrations for schema changes
    // logger.info('All database tables have been synchronized.'); // Disabled

    // Create default settings if they don't exist
    await createDefaultSettings();
    
    // Initialize PDF settings
    const settingsService = require('../services/settingsService');
    await settingsService.initializePdfSettings();

    return true;
  } catch (error) {
    logger.error('Unable to initialize database:', error);
    return false;
  }
}

async function createDefaultSettings() {
  const defaultSettings = [
    {
      key: 'company_name',
      value: 'Your Construction Company',
      group: 'company',
      description: 'Name of your company'
    },
    {
      key: 'company_address',
      value: 'Your company address',
      group: 'company',
      description: 'Company address for invoices and estimates'
    },
    {
      key: 'company_phone',
      value: 'Your company phone',
      group: 'company',
      description: 'Company phone number'
    },
    {
      key: 'company_email',
      value: 'your@email.com',
      group: 'company',
      description: 'Company email for invoices and estimates'
    },
    {
      key: 'invoice_prefix',
      value: 'INV-',
      group: 'invoicing',
      description: 'Prefix for invoice numbers'
    },
    {
      key: 'estimate_prefix',
      value: 'EST-',
      group: 'invoicing',
      description: 'Prefix for estimate numbers'
    },
    {
      key: 'default_tax_rate',
      value: '0',
      group: 'invoicing',
      description: 'Default tax rate percentage'
    },
    {
      key: 'invoice_due_days',
      value: '30',
      group: 'invoicing',
      description: 'Default number of days until invoice is due'
    },
    {
      key: 'estimate_valid_days',
      value: '30',
      group: 'invoicing',
      description: 'Default number of days until estimate expires'
    },
    {
      key: 'default_invoice_notes',
      value: 'Thank you for your business!',
      group: 'invoicing',
      description: 'Default notes for new invoices'
    },
    {
      key: 'default_invoice_terms',
      value: 'Payment is due within {due_days} days of receipt.',
      group: 'invoicing',
      description: 'Default terms for new invoices'
    }
  ];

  const { Settings } = models;

  for (const setting of defaultSettings) {
    await Settings.findOrCreate({
      where: { key: setting.key },
      defaults: setting
    });
  }

  logger.info('Default settings have been initialized.');
}

module.exports = {
  initializeDatabase,
  createDefaultSettings
};
