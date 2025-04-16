'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Community extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      Community.hasMany(models.AdType, {
        foreignKey: 'community_id',
        as: 'adTypes',
        onDelete: 'CASCADE'
      });
      Community.belongsTo(models.AdType, {
        foreignKey: 'selected_ad_type_id',
        as: 'selectedAdType',
        constraints: false // Prevent circular reference errors
      });
    }
  }

  Community.init({
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    address: {
      type: DataTypes.STRING,
      allowNull: true
    },
    city: {
      type: DataTypes.STRING,
      allowNull: true
    },
    state: {
      type: DataTypes.STRING,
      allowNull: true
    },
    phone: {
      type: DataTypes.STRING,
      allowNull: true
    },
    spaces: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    ad_specialist_name: {
      type: DataTypes.STRING,
      allowNull: true,
      field: 'ad_specialist_name'
    },
    ad_specialist_email: {
      type: DataTypes.STRING,
      allowNull: true,
      field: 'ad_specialist_email'
    },
    ad_specialist_phone: {
      type: DataTypes.STRING,
      allowNull: true,
      field: 'ad_specialist_phone'
    },
    selected_ad_type_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'ad_types',
        key: 'id'
      },
      field: 'selected_ad_type_id'
    },
    newsletter_link: {
      type: DataTypes.STRING,
      allowNull: true,
      field: 'newsletter_link'
    },
    general_notes: {
      type: DataTypes.TEXT,
      allowNull: true,
      field: 'general_notes'
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
      field: 'is_active'
    }
  }, {
    sequelize,
    modelName: 'Community',
    tableName: 'communities',
    timestamps: true,
    underscored: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    indexes: [
      { fields: ['name'] },
      { fields: ['city'] },
      { fields: ['is_active'] }
    ]
  });

  return Community;
};
