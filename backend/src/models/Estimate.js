'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Estimate extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      Estimate.hasMany(models.EstimateItem, {
        foreignKey: {
          name: 'estimateId', // Model attribute name
          field: 'estimate_id' // Actual database column name
        },
        as: 'items',
        onDelete: 'CASCADE'
      });
      Estimate.belongsTo(models.Invoice, {
        foreignKey: 'convertedToInvoiceId',
        as: 'invoice',
        constraints: false // Optional relationship
      });
      Estimate.belongsTo(models.Client, {
        foreignKey: 'client_fk_id',
        as: 'client'
      });
      Estimate.belongsTo(models.ClientAddress, {
        foreignKey: 'address_id',
        as: 'address'
      });
      Estimate.belongsTo(models.Project, {
        foreignKey: 'project_id',
        as: 'project'
      });
    }
  }

  Estimate.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    estimateNumber: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      field: 'estimate_number'
    },
    clientId: { // Legacy field
      type: DataTypes.STRING,
      allowNull: true,
      comment: 'Legacy NextCloud contact UID (deprecated)',
      field: 'client_id'
    },
    client_fk_id: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'clients',
        key: 'id'
      },
      field: 'client_fk_id',
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
      field: 'dateCreated'
    },
    validUntil: {
      type: DataTypes.DATEONLY,
      allowNull: false,
      field: 'validUntil'
    },
    status: {
      type: DataTypes.ENUM('draft', 'sent', 'accepted', 'rejected', 'expired'),
      defaultValue: 'draft',
      field: 'status'
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
      field: 'tax_total'
    },
    discountAmount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      defaultValue: 0.00,
      field: 'discount_amount'
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
      field: 'pdf_path'
    },
    convertedToInvoiceId: {
      type: DataTypes.UUID,
      allowNull: true,
      comment: 'Reference to invoice if this estimate was converted',
      field: 'converted_to_invoice_id'
    },
    project_id: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'projects',
        key: 'id'
      },
      field: 'project_id',
      comment: 'Reference to project if this estimate is associated with a project'
    }
  }, {
    sequelize,
    modelName: 'Estimate',
    tableName: 'estimates',
    timestamps: true,
    paranoid: true, // Soft deletes
    underscored: true, // Use snake_case for createdAt, updatedAt, deletedAt
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    deletedAt: 'deleted_at',
    indexes: [
      { unique: true, fields: ['estimate_number'] },
      { fields: ['client_id'] }, // Legacy index
      { fields: ['client_fk_id'] },
      { fields: ['status'] },
      { fields: ['address_id'] },
      { fields: ['project_id'] }
    ]
  });

  return Estimate;
};