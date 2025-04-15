'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Payment extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      Payment.belongsTo(models.Invoice, {
        foreignKey: 'invoiceId' // Keep as camelCase for model association
      });
    }
  }

  Payment.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    invoiceId: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'invoice_id',
      references: { // Add reference for foreign key constraint
        model: 'invoices',
        key: 'id'
      }
    },
    amount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    },
    paymentDate: {
      type: DataTypes.DATEONLY,
      allowNull: false,
      field: 'payment_date'
    },
    paymentMethod: {
      // Changed from ENUM to STRING to avoid type conversion issues
      type: DataTypes.STRING,
      defaultValue: 'other',
      field: 'payment_method',
      validate: {
        isIn: [['cash', 'check', 'credit_card', 'bank_transfer', 'other']]
      }
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    referenceNumber: {
      type: DataTypes.STRING,
      allowNull: true,
      comment: 'Reference/transaction number for the payment',
      field: 'reference_number'
    }
  }, {
    sequelize,
    modelName: 'Payment',
    tableName: 'payments',
    timestamps: true,
    underscored: true, // Use snake_case for createdAt, updatedAt
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    indexes: [
      { fields: ['invoice_id'] },
      { fields: ['payment_date'] }
    ]
  });

  return Payment;
};
