'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class EstimateItemPhoto extends Model {
    static associate(models) {
      // Define association with EstimateItem
      EstimateItemPhoto.belongsTo(models.EstimateItem, {
        foreignKey: 'estimate_item_id',
        as: 'estimateItem'
      });
    }
  }

  EstimateItemPhoto.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    estimate_item_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'estimate_items',
        key: 'id'
      }
    },
    file_path: {
      type: DataTypes.STRING,
      allowNull: false
    },
    original_name: {
      type: DataTypes.STRING,
      allowNull: true
    },
    photo_type: {
      type: DataTypes.TEXT,
      allowNull: false,
      defaultValue: 'progress',
      validate: {
        isIn: {
          args: [['progress', 'completed', 'issue', 'material', 'other']],
          msg: "Photo type must be one of: progress, completed, issue, material, other"
        }
      }
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    metadata: {
      type: DataTypes.JSONB,
      allowNull: true
    }
  }, {
    sequelize,
    modelName: 'EstimateItemPhoto',
    tableName: 'estimate_item_photos',
    underscored: true, // Use snake_case for the database fields
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
  });

  return EstimateItemPhoto;
};
