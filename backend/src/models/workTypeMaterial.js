'use strict';

module.exports = (sequelize, DataTypes) => {
  const WorkTypeMaterial = sequelize.define('WorkTypeMaterial', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
      allowNull: false
    },
    work_type_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'work_types',
        key: 'id'
      }
    },
    product_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'products',
        key: 'id'
      }
    },
    qty_per_unit: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      defaultValue: 1.0,
      validate: {
        isDecimal: true,
        min: 0
      }
    },
    unit: {
      type: DataTypes.STRING(20),
      allowNull: false,
      validate: {
        notEmpty: true
      }
    }
  }, {
    tableName: 'work_type_materials',
    timestamps: true,
    underscored: true,
    indexes: [
      {
        unique: true,
        fields: ['work_type_id', 'product_id'],
        name: 'work_type_materials_work_type_id_product_id_unique'
      }
    ]
  });

  WorkTypeMaterial.associate = function(models) {
    // Belongs to WorkType
    WorkTypeMaterial.belongsTo(models.WorkType, {
      foreignKey: 'work_type_id',
      as: 'workType',
      onDelete: 'CASCADE'
    });

    // Belongs to Product
    WorkTypeMaterial.belongsTo(models.Product, {
      foreignKey: 'product_id',
      as: 'product',
      onDelete: 'RESTRICT'
    });
  };

  return WorkTypeMaterial;
};
