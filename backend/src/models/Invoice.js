'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Invoice extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      Invoice.hasMany(models.InvoiceItem, {
        foreignKey: 'invoiceId', // Keep as camelCase for model association
        as: 'items',
        onDelete: 'CASCADE'
      });
      Invoice.hasMany(models.Payment, {
        foreignKey: 'invoiceId', // Keep as camelCase for model association
        as: 'payments',
        onDelete: 'CASCADE'
      });
      Invoice.belongsTo(models.Client, {
        foreignKey: 'client_id', // Standardized client ID reference
        as: 'client'
      });
      Invoice.belongsTo(models.ClientAddress, {
        foreignKey: 'address_id',
        as: 'address'
      });
    }
  }

  Invoice.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    invoiceNumber: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      field: 'invoice_number'
    },
    // clientId field removed as client_id_legacy column doesn't exist in the database
    client_id: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'clients',
        key: 'id'
      },
      field: 'client_id',
      comment: 'Foreign key to clients table'
    },
    address_id: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'client_addresses',
        key: 'id'
      },
      field: 'address_id',
      comment: 'Foreign key to client_addresses table for the selected address'
    },
    dateCreated: {
      type: DataTypes.DATEONLY,
      allowNull: false,
      field: 'date_created' // Corrected to snake_case
    },
    dateDue: {
      type: DataTypes.DATEONLY,
      allowNull: false,
      field: 'date_due' // Corrected to snake_case
    },
    status: {
      type: DataTypes.ENUM('draft', 'sent', 'viewed', 'paid', 'overdue'),
      defaultValue: 'draft'
    },
    subtotal: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      defaultValue: 0.00
    },
    taxTotal: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      defaultValue: 0.00,
      field: 'tax_total' // Corrected to snake_case
    },
    discountAmount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      defaultValue: 0.00,
      field: 'discount_amount' // Corrected to snake_case
    },
    total: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      defaultValue: 0.00
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    terms: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    pdfPath: {
      type: DataTypes.STRING,
      allowNull: true,
      comment: 'Path to the generated PDF file',
      field: 'pdf_path' // Corrected to snake_case
    }
  }, {
    sequelize,
    modelName: 'Invoice',
    tableName: 'invoices',
    timestamps: true,
    paranoid: true, // Soft deletes
    underscored: true, // Use snake_case for createdAt, updatedAt, deletedAt
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    deletedAt: 'deleted_at',
    indexes: [
      { unique: true, fields: ['invoice_number'] },
      // Legacy index removed as client_id_legacy column doesn't exist
      { fields: ['client_id'] },
      { fields: ['status'] },
      { fields: ['address_id'] }
    ]
  });

  return Invoice;
};