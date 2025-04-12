'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const settings = [
      // Company information settings
      {
        key: 'company_name',
        value: 'Your Company',
        description: 'Company name displayed on invoices and estimates',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        key: 'company_address',
        value: '123 Business St, Suite 100, City, State, 12345',
        description: 'Company address displayed on invoices and estimates',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        key: 'company_phone',
        value: '(555) 123-4567',
        description: 'Company phone number displayed on invoices and estimates',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        key: 'company_email',
        value: 'billing@yourcompany.com',
        description: 'Company email displayed on invoices and estimates',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        key: 'company_website',
        value: 'www.yourcompany.com',
        description: 'Company website displayed on invoices and estimates',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        key: 'company_logo_path',
        value: '',
        description: 'Path to company logo file for invoices and estimates (within uploads/logos directory)',
        created_at: new Date(),
        updated_at: new Date()
      },
      
      // Invoice settings
      {
        key: 'invoice_prefix',
        value: 'INV-',
        description: 'Prefix for invoice numbers (e.g., INV-00001)',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        key: 'invoice_due_days',
        value: '30',
        description: 'Default number of days until invoice is due',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        key: 'default_invoice_terms',
        value: 'Payment is due within {due_days} days from the date of invoice. Late payments are subject to a 1.5% monthly fee.',
        description: 'Default terms and conditions for invoices',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        key: 'pdf_invoice_footer',
        value: 'Thank you for your business. Please contact us with any questions regarding this invoice.',
        description: 'Custom footer text for invoice PDFs',
        created_at: new Date(),
        updated_at: new Date()
      },
      
      // Estimate settings
      {
        key: 'estimate_prefix',
        value: 'EST-',
        description: 'Prefix for estimate numbers (e.g., EST-00001)',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        key: 'estimate_valid_days',
        value: '30',
        description: 'Default number of days estimates are valid',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        key: 'default_estimate_terms',
        value: 'This estimate is valid for {valid_days} days from the date issued. To accept this estimate, please sign and return.',
        description: 'Default terms and conditions for estimates',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        key: 'pdf_estimate_footer',
        value: 'Thank you for considering our services. Please contact us with any questions regarding this estimate.',
        description: 'Custom footer text for estimate PDFs',
        created_at: new Date(),
        updated_at: new Date()
      },
      
      // PDF styling
      {
        key: 'primary_color',
        value: '#3b82f6',
        description: 'Primary color for PDF documents (hex code)',
        created_at: new Date(),
        updated_at: new Date()
      }
    ];

    const table = await queryInterface.sequelize.query(
      `SELECT table_name FROM information_schema.tables WHERE table_name = 'settings';`
    );

    const tableExists = table[0].length > 0;

    if (tableExists) {
      // Check each setting and only insert if it doesn't exist
      for (const setting of settings) {
        const existingSetting = await queryInterface.sequelize.query(
          `SELECT * FROM settings WHERE key = '${setting.key}';`
        );

        if (existingSetting[0].length === 0) {
          await queryInterface.sequelize.query(
            `INSERT INTO settings (key, value, description, created_at, updated_at) 
             VALUES ('${setting.key}', '${setting.value.replace(/'/g, "''")}', '${setting.description.replace(/'/g, "''")}', '${setting.created_at.toISOString()}', '${setting.updated_at.toISOString()}');`
          );
        }
      }
    } else {
      // If the table doesn't exist, create it
      await queryInterface.createTable('settings', {
        id: {
          allowNull: false,
          autoIncrement: true,
          primaryKey: true,
          type: Sequelize.INTEGER
        },
        key: {
          type: Sequelize.STRING,
          allowNull: false,
          unique: true
        },
        value: {
          type: Sequelize.TEXT,
          allowNull: true
        },
        description: {
          type: Sequelize.TEXT,
          allowNull: true
        },
        created_at: {
          allowNull: false,
          type: Sequelize.DATE
        },
        updated_at: {
          allowNull: false,
          type: Sequelize.DATE
        }
      });

      // Insert all settings
      await queryInterface.bulkInsert('settings', settings);
    }
  },

  down: async (queryInterface, Sequelize) => {
    // Remove specific settings added in this migration
    const settingsToRemove = [
      'company_logo_path',
      'company_website',
      'pdf_invoice_footer',
      'pdf_estimate_footer',
      'primary_color'
    ];

    for (const key of settingsToRemove) {
      await queryInterface.sequelize.query(
        `DELETE FROM settings WHERE key = '${key}';`
      );
    }
  }
};
