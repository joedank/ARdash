'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      // Create settings table if it doesn't exist
      await queryInterface.createTable('settings', {
        id: {
          type: Sequelize.INTEGER,
          primaryKey: true,
          autoIncrement: true
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
        group: {
          type: Sequelize.STRING,
          allowNull: false,
          defaultValue: 'general'
        },
        description: {
          type: Sequelize.TEXT,
          allowNull: true
        },
        created_at: {
          type: Sequelize.DATE,
          allowNull: false,
          defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
        },
        updated_at: {
          type: Sequelize.DATE,
          allowNull: false,
          defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
        }
      }).catch(error => {
        if (error.name === 'SequelizeUniqueConstraintError' || error.name === 'SequelizeTableExistsError') {
          console.log('Settings table already exists, continuing...');
        } else {
          throw error;
        }
      });

      // Add PDF settings
      const now = new Date();
      const pdfSettings = [
        {
          key: 'company_name',
          value: 'Your Company',
          group: 'company',
          description: 'Company name displayed on invoices and estimates'
        },
        {
          key: 'company_address',
          value: '123 Business St, Suite 100, City, State, 12345',
          group: 'company',
          description: 'Company address displayed on invoices and estimates'
        },
        {
          key: 'company_phone',
          value: '(555) 123-4567',
          group: 'company',
          description: 'Company phone number displayed on invoices and estimates'
        },
        {
          key: 'company_email',
          value: 'billing@yourcompany.com',
          group: 'company',
          description: 'Company email displayed on invoices and estimates'
        },
        {
          key: 'company_website',
          value: 'www.yourcompany.com',
          group: 'company',
          description: 'Company website displayed on invoices and estimates'
        },
        {
          key: 'company_logo_path',
          value: '',
          group: 'company',
          description: 'Path to company logo file for invoices and estimates'
        },
        {
          key: 'primary_color',
          value: '#3b82f6',
          group: 'appearance',
          description: 'Primary color for PDF documents (hex code)'
        },
        {
          key: 'pdf_invoice_footer',
          value: 'Thank you for your business. Please contact us with any questions regarding this invoice.',
          group: 'invoice',
          description: 'Custom footer text for invoice PDFs'
        },
        {
          key: 'pdf_estimate_footer',
          value: 'Thank you for considering our services. Please contact us with any questions regarding this estimate.',
          group: 'estimate',
          description: 'Custom footer text for estimate PDFs'
        }
      ];

      // Insert settings using Sequelize's built-in methods
      for (const setting of pdfSettings) {
        await queryInterface.bulkInsert('settings', [{
          ...setting,
          created_at: now,
          updated_at: now
        }], {
          ignoreDuplicates: true
        });
      }
    } catch (error) {
      console.error('Migration failed:', error);
      throw error;
    }
  },

  down: async (queryInterface, Sequelize) => {
    try {
      // Remove PDF settings
      const pdfSettingKeys = [
        'company_name',
        'company_address',
        'company_phone',
        'company_email',
        'company_website',
        'company_logo_path',
        'primary_color',
        'pdf_invoice_footer',
        'pdf_estimate_footer'
      ];

      await queryInterface.bulkDelete('settings', {
        key: {
          [Sequelize.Op.in]: pdfSettingKeys
        }
      });
    } catch (error) {
      console.error('Migration reversal failed:', error);
      throw error;
    }
  }
};
