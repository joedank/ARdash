'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Client extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      Client.hasMany(models.ClientAddress, {
        foreignKey: 'client_id',
        as: 'addresses',
        onDelete: 'CASCADE'
      });
      Client.hasMany(models.Invoice, {
        foreignKey: 'client_id',
        as: 'invoices'
      });
      Client.hasMany(models.Estimate, {
        foreignKey: 'client_id',
        as: 'estimates'
      });
      Client.hasMany(models.Project, {
        foreignKey: 'client_id',
        as: 'projects'
      });
    }
  }

  Client.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    display_name: {
      type: DataTypes.STRING,
      allowNull: false,
      field: 'display_name'
    },
    // Virtual field that returns display_name for backward compatibility
    name: {
      type: DataTypes.VIRTUAL,
      get() {
        return this.getDataValue('display_name');
      }
    },
    company: {
      type: DataTypes.STRING,
      allowNull: true
    },
    email: {
      type: DataTypes.STRING,
      allowNull: true
    },
    phone: {
      type: DataTypes.STRING,
      allowNull: true
    },
    payment_terms: {
      // Use TEXT instead of STRING to avoid type conversion issues
      type: DataTypes.TEXT,
      allowNull: true,
      field: 'payment_terms'
    },
    default_tax_rate: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
      defaultValue: null,
      field: 'default_tax_rate'
    },
    default_currency: {
      type: DataTypes.STRING(3),
      allowNull: true,
      defaultValue: 'USD',
      field: 'default_currency'
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: 'is_active'
    },
    client_type: {
      type: DataTypes.ENUM('property_manager', 'resident'),
      allowNull: true, // Keep true for now, can be changed later
      defaultValue: 'resident',
      field: 'client_type',
      comment: 'Indicates if client is a property manager or resident'
    }
  }, {
    sequelize,
    modelName: 'Client',
    tableName: 'clients',
    timestamps: true,
    underscored: true, // Use snake_case for createdAt, updatedAt
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    indexes: [
      { fields: ['is_active'] },
      { fields: ['display_name'] },
      { fields: ['client_type'] }
    ]
  });

  return Client;
};
