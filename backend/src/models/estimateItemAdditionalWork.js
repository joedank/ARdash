'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class EstimateItemAdditionalWork extends Model {
    static associate(models) {
      // Define association with EstimateItem
      EstimateItemAdditionalWork.belongsTo(models.EstimateItem, {
        foreignKey: 'estimate_item_id',
        as: 'estimateItem'
      });
    }
  }
  
  EstimateItemAdditionalWork.init({
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
    description: {
      type: DataTypes.TEXT,
      allowNull: false
    }
  }, {
    sequelize,
    modelName: 'EstimateItemAdditionalWork',
    tableName: 'estimate_item_additional_work',
    underscored: true, // Use snake_case for the database fields
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
  });
  
  return EstimateItemAdditionalWork;
};
