'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class EstimateItem extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      EstimateItem.belongsTo(models.Estimate, {
        foreignKey: {
          name: 'estimateId', // Model attribute name
          field: 'estimate_id' // Actual database column name
        }
      });
      
      EstimateItem.belongsTo(models.Product, {
        foreignKey: 'product_id',
        as: 'product'
      });

      EstimateItem.hasMany(models.SourceMap, {
        foreignKey: 'estimate_item_id',
        as: 'sourceMaps'
      });

      EstimateItem.hasMany(models.EstimateItemAdditionalWork, {
        foreignKey: 'estimate_item_id',
        as: 'additionalWork'
      });
    }
  }

  EstimateItem.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    estimateId: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'estimate_id', // Explicit mapping to snake_case column name
      references: { // Add reference for foreign key constraint
        model: 'estimates',
        key: 'id'
      }
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    quantity: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      defaultValue: 1.00
    },
    price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      defaultValue: 0.00
    },
    taxRate: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: false,
      defaultValue: 0.00,
      field: 'tax_rate' // Explicit mapping
    },
    itemTotal: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      defaultValue: 0.00,
      field: 'item_total' // Explicit mapping
    },
    sortOrder: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
      field: 'sort_order' // Explicit mapping
    },
    product_id: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'products',
        key: 'id'
      }
    },
    source_data: {
      type: DataTypes.JSONB,
      allowNull: true
    },
    unit: {
      type: DataTypes.STRING(50),
      allowNull: true
    },
    custom_product_data: {
      type: DataTypes.JSONB,
      allowNull: true
    }
  }, {
    sequelize,
    modelName: 'EstimateItem',
    tableName: 'estimate_items',
    timestamps: true,
    underscored: true, // Use snake_case for createdAt, updatedAt
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    indexes: [
      { fields: ['estimate_id'] }
    ]
  });

  return EstimateItem;
};
