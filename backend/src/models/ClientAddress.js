'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class ClientAddress extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      ClientAddress.belongsTo(models.Client, {
        foreignKey: 'client_id',
        as: 'client'
      });
      ClientAddress.hasMany(models.Invoice, {
        foreignKey: 'address_id',
        as: 'invoices',
        constraints: false
      });
      ClientAddress.hasMany(models.Estimate, {
        foreignKey: 'address_id',
        as: 'estimates',
        constraints: false
      });
    }
  }

  ClientAddress.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    client_id: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'client_id',
      references: {
        model: 'clients', // Use table name here
        key: 'id'
      }
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      comment: 'Name or label for this address (e.g., "Main Office", "Property at 123 Main St")'
    },
    street_address: {
      type: DataTypes.TEXT,
      allowNull: false,
      field: 'street_address'
    },
    city: {
      type: DataTypes.STRING,
      allowNull: false
    },
    state: {
      type: DataTypes.STRING,
      allowNull: false
    },
    postal_code: {
      type: DataTypes.STRING,
      allowNull: false,
      field: 'postal_code'
    },
    country: {
      type: DataTypes.STRING,
      allowNull: true,
      defaultValue: 'USA'
    },
    is_primary: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
      field: 'is_primary',
      comment: 'Indicates if this is the primary address for the client'
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    sequelize,
    modelName: 'ClientAddress',
    tableName: 'client_addresses',
    timestamps: true,
    underscored: true, // Use snake_case for createdAt, updatedAt
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    indexes: [
      { fields: ['client_id'] },
      { fields: ['is_primary'] }
    ]
  });

  return ClientAddress;
};
