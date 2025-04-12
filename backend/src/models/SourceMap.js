'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class SourceMap extends Model {
    static associate(models) {
      SourceMap.belongsTo(models.EstimateItem, {
        foreignKey: 'estimate_item_id',
        as: 'estimateItem'
      });
    }
  }

  SourceMap.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    estimate_item_id: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'estimate_item_id',
      references: {
        model: 'estimate_items',
        key: 'id'
      }
    },
    source_type: {
      type: DataTypes.STRING(50),
      allowNull: false
    },
    source_data: {
      type: DataTypes.JSONB,
      allowNull: false
    }
  }, {
    sequelize,
    modelName: 'SourceMap',
    tableName: 'source_maps',
    underscored: true,
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
  });

  return SourceMap;
};