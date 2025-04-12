'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      // Enable UUID extension if not already enabled
      await queryInterface.sequelize.query('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";');

      const createTableIfNotExists = async (tableName, columns, options = {}) => {
        try {
          console.log(`Attempting to create table: ${tableName}`);
          await queryInterface.createTable(tableName, columns, options);
          console.log(`Table ${tableName} created successfully.`);
        } catch (error) {
          if (error.name === 'SequelizeTableExistsError' || (error.original && error.original.code === '42P07')) { // 42P07 is PostgreSQL code for "duplicate table"
            console.log(`Table ${tableName} already exists, skipping creation.`);
          } else {
            console.error(`Error creating table ${tableName}:`, error);
            throw error; // Re-throw other errors
          }
        }
      };

      // Create invoices table
      await createTableIfNotExists('invoices', {
        id: { type: Sequelize.UUID, defaultValue: Sequelize.literal('uuid_generate_v4()'), primaryKey: true },
        invoice_number: { type: Sequelize.STRING, allowNull: false, unique: true },
        client_id: { type: Sequelize.STRING, allowNull: true }, // Made nullable temporarily, will be fixed later
        card_dav_uri: { type: Sequelize.STRING, allowNull: true }, // Made nullable temporarily
        date_created: { type: Sequelize.DATEONLY, allowNull: false },
        date_due: { type: Sequelize.DATEONLY, allowNull: false },
        status: { type: Sequelize.ENUM('draft', 'sent', 'viewed', 'paid', 'overdue'), defaultValue: 'draft' },
        subtotal: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 0.00 },
        tax_total: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 0.00 },
        discount_amount: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 0.00 },
        total: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 0.00 },
        notes: { type: Sequelize.TEXT, allowNull: true },
        terms: { type: Sequelize.TEXT, allowNull: true },
        pdf_path: { type: Sequelize.STRING, allowNull: true, comment: 'Path to the generated PDF file' },
        created_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
        updated_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
        deleted_at: { type: Sequelize.DATE, allowNull: true }
      });
      await queryInterface.addIndex('invoices', ['client_id']).catch(e => console.log("Index invoices_client_id likely exists"));
      await queryInterface.addIndex('invoices', ['status']).catch(e => console.log("Index invoices_status likely exists"));


      // Create invoice_items table
      await createTableIfNotExists('invoice_items', {
        id: { type: Sequelize.UUID, defaultValue: Sequelize.literal('uuid_generate_v4()'), primaryKey: true },
        invoice_id: { type: Sequelize.UUID, allowNull: false, references: { model: 'invoices', key: 'id' }, onDelete: 'CASCADE' },
        description: { type: Sequelize.TEXT, allowNull: false },
        quantity: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 1.00 },
        price: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 0.00 },
        tax_rate: { type: Sequelize.DECIMAL(5, 2), allowNull: false, defaultValue: 0.00 },
        item_total: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 0.00 },
        sort_order: { type: Sequelize.INTEGER, allowNull: false, defaultValue: 0 },
        created_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
        updated_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') }
      });
       await queryInterface.addIndex('invoice_items', ['invoice_id']).catch(e => console.log("Index invoice_items_invoice_id likely exists"));


      // Create payments table
      await createTableIfNotExists('payments', {
        id: { type: Sequelize.UUID, defaultValue: Sequelize.literal('uuid_generate_v4()'), primaryKey: true },
        invoice_id: { type: Sequelize.UUID, allowNull: false, references: { model: 'invoices', key: 'id' }, onDelete: 'CASCADE' },
        amount: { type: Sequelize.DECIMAL(10, 2), allowNull: false },
        payment_date: { type: Sequelize.DATEONLY, allowNull: false },
        payment_method: { type: Sequelize.STRING(50), allowNull: true },
        notes: { type: Sequelize.TEXT, allowNull: true },
        reference_number: { type: Sequelize.STRING(100), allowNull: true },
        created_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
        updated_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') }
      });
      await queryInterface.addIndex('payments', ['invoice_id']).catch(e => console.log("Index payments_invoice_id likely exists"));


      // Create estimates table
      await createTableIfNotExists('estimates', {
        id: { type: Sequelize.UUID, defaultValue: Sequelize.literal('uuid_generate_v4()'), primaryKey: true },
        estimate_number: { type: Sequelize.STRING, allowNull: false, unique: true },
        client_id: { type: Sequelize.STRING, allowNull: true }, // Made nullable temporarily
        card_dav_uri: { type: Sequelize.STRING, allowNull: true }, // Made nullable temporarily
        date_created: { type: Sequelize.DATEONLY, allowNull: false },
        date_valid_until: { type: Sequelize.DATEONLY, allowNull: false },
        status: { type: Sequelize.ENUM('draft', 'sent', 'viewed', 'accepted', 'rejected', 'expired'), defaultValue: 'draft' },
        subtotal: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 0.00 },
        tax_total: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 0.00 },
        discount_amount: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 0.00 },
        total: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 0.00 },
        notes: { type: Sequelize.TEXT, allowNull: true },
        terms: { type: Sequelize.TEXT, allowNull: true },
        pdf_path: { type: Sequelize.STRING, allowNull: true, comment: 'Path to the generated PDF file' },
        converted_to_invoice_id: { type: Sequelize.UUID, allowNull: true, references: { model: 'invoices', key: 'id' }, onDelete: 'SET NULL' },
        created_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
        updated_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
        deleted_at: { type: Sequelize.DATE, allowNull: true }
      });
      await queryInterface.addIndex('estimates', ['client_id']).catch(e => console.log("Index estimates_client_id likely exists"));
      await queryInterface.addIndex('estimates', ['status']).catch(e => console.log("Index estimates_status likely exists"));


      // Create estimate_items table
      await createTableIfNotExists('estimate_items', {
        id: { type: Sequelize.UUID, defaultValue: Sequelize.literal('uuid_generate_v4()'), primaryKey: true },
        estimate_id: { type: Sequelize.UUID, allowNull: false, references: { model: 'estimates', key: 'id' }, onDelete: 'CASCADE' },
        description: { type: Sequelize.TEXT, allowNull: false },
        quantity: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 1.00 },
        price: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 0.00 },
        tax_rate: { type: Sequelize.DECIMAL(5, 2), allowNull: false, defaultValue: 0.00 },
        item_total: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 0.00 },
        sort_order: { type: Sequelize.INTEGER, allowNull: false, defaultValue: 0 },
        created_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
        updated_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') }
      });
      await queryInterface.addIndex('estimate_items', ['estimate_id']).catch(e => console.log("Index estimate_items_estimate_id likely exists"));


      // Create products table
      await createTableIfNotExists('products', {
        id: { type: Sequelize.UUID, defaultValue: Sequelize.literal('uuid_generate_v4()'), primaryKey: true },
        name: { type: Sequelize.STRING, allowNull: false },
        description: { type: Sequelize.TEXT, allowNull: true },
        price: { type: Sequelize.DECIMAL(10, 2), allowNull: false, defaultValue: 0.00 },
        tax_rate: { type: Sequelize.DECIMAL(5, 2), allowNull: false, defaultValue: 0.00 },
        is_active: { type: Sequelize.BOOLEAN, allowNull: false, defaultValue: true },
        created_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
        updated_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') }
        // Note: 'type' and 'unit' columns are added in later migrations
      });

    } catch (error) {
      console.error('Migration failed:', error);
      throw error;
    }
  },

  down: async (queryInterface, Sequelize) => {
    try {
      // Drop tables in reverse order to handle dependencies
      await queryInterface.dropTable('estimate_items', { cascade: true });
      await queryInterface.dropTable('invoice_items', { cascade: true });
      await queryInterface.dropTable('payments', { cascade: true });
      await queryInterface.dropTable('estimates', { cascade: true });
      await queryInterface.dropTable('invoices', { cascade: true });
      await queryInterface.dropTable('products', { cascade: true });
    } catch (error) {
      console.error('Reversal migration failed:', error);
      throw error;
    }
  }
};
