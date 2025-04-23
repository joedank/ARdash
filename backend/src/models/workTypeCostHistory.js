'use strict';

module.exports = (sequelize, DataTypes) => {
  const WorkTypeCostHistory = sequelize.define('WorkTypeCostHistory', {
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
    region: {
      type: DataTypes.TEXT,
      allowNull: false,
      defaultValue: 'default'
    },
    unit_cost_material: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
      validate: {
        isDecimal: true,
        min: 0
      }
    },
    unit_cost_labor: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
      validate: {
        isDecimal: true,
        min: 0
      }
    },
    captured_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW
    },
    updated_by: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'users',
        key: 'id'
      }
    }
  }, {
    tableName: 'work_type_cost_history',
    timestamps: true,
    underscored: true,
    defaultScope: {
      order: [['captured_at', 'DESC']]
    },
    indexes: [
      {
        fields: ['work_type_id', 'captured_at'],
        name: 'work_type_cost_history_work_type_id_captured_at_idx'
      }
    ]
  });

  WorkTypeCostHistory.associate = function(models) {
    // Belongs to WorkType
    WorkTypeCostHistory.belongsTo(models.WorkType, {
      foreignKey: 'work_type_id',
      as: 'workType'
    });

    // Belongs to User (who updated it)
    WorkTypeCostHistory.belongsTo(models.User, {
      foreignKey: 'updated_by',
      as: 'updatedBy'
    });
  };

  return WorkTypeCostHistory;
};
