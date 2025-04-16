'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class AdType extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      AdType.belongsTo(models.Community, {
        foreignKey: 'community_id',
        as: 'community'
      });
      AdType.hasMany(models.Community, {
        foreignKey: 'selected_ad_type_id',
        as: 'selectedByCommunities',
        constraints: false // Prevent circular reference errors
      });
    }
  }

  AdType.init({
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    community_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'communities',
        key: 'id'
      },
      field: 'community_id'
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    width: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
      defaultValue: 0
    },
    height: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
      defaultValue: 0
    },
    cost: {
      type: DataTypes.DECIMAL(10, 1),
      allowNull: true,
      defaultValue: 0
    },
    start_date: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'start_date'
    },
    end_date: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'end_date'
    },
    deadline_date: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'deadline_date'
    },
    term_months: {
      type: DataTypes.DECIMAL(3, 1),
      allowNull: true,
      field: 'term_months'
    }
  }, {
    sequelize,
    modelName: 'AdType',
    tableName: 'ad_types',
    timestamps: true,
    underscored: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    indexes: [
      { fields: ['community_id'] },
      { fields: ['name'] }
    ]
  });

  return AdType;
};
