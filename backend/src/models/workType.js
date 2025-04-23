'use strict';

// Import custom data types with VECTOR support
const CustomDataTypes = require('../utils/sequelize-datatypes');

module.exports = (sequelize, DataTypes) => {
  const WorkType = sequelize.define('WorkType', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
      allowNull: false
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true
      }
    },
    parent_bucket: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true,
        isIn: [['Interior-Structural', 'Interior-Finish', 'Exterior-Structural', 'Exterior-Finish', 'Mechanical']]
      }
    },
    measurement_type: {
      type: DataTypes.ENUM('area', 'linear', 'quantity'),
      allowNull: false,
      validate: {
        notEmpty: true
      }
    },
    suggested_units: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true,
        isValidForMeasurementType(value) {
          const validUnits = {
            'area': ['sq ft', 'sq yd', 'sq m'],
            'linear': ['ft', 'in', 'yd', 'm'],
            'quantity': ['each', 'job', 'set']
          };

          if (!validUnits[this.measurement_type].includes(value)) {
            throw new Error(`${value} is not a valid unit for ${this.measurement_type} measurement type`);
          }
        }
      }
    },
    // New fields for Phase B
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
    productivity_unit_per_hr: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
      validate: {
        isDecimal: true,
        min: 0
      },
      // Add SQL-level CHECK constraint
      set(value) {
        if (value !== null && value < 0) {
          throw new Error('Productivity units per hour cannot be negative');
        }
        this.setDataValue('productivity_unit_per_hr', value);
      }
    },
    name_vec: {
      type: CustomDataTypes.VECTOR(384), // Use custom VECTOR type with fallback to TEXT
      allowNull: true
    },
    revision: {
      type: DataTypes.INTEGER,
      defaultValue: 1,
      allowNull: false
    },
    updated_by: {
      type: DataTypes.UUID,
      allowNull: true
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    },
    updated_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'work_types',
    timestamps: true,
    underscored: true
  });

  // Associations for Phase B
  WorkType.associate = function(models) {
    // Materials association
    WorkType.hasMany(models.WorkTypeMaterial, {
      foreignKey: 'work_type_id',
      as: 'materials'
    });

    // Tags association
    WorkType.hasMany(models.WorkTypeTag, {
      foreignKey: 'work_type_id',
      as: 'tags'
    });

    // Cost history association
    WorkType.hasMany(models.WorkTypeCostHistory, {
      foreignKey: 'work_type_id',
      as: 'costHistory'
    });
  };

  // Define a scope for the wizard that includes materials and tags
  WorkType.addScope('forWizard', {
    include: [
      {
        association: 'materials',
        include: ['product']
      },
      {
        association: 'tags'
      }
    ]
  });

  // Define a scope for cost analysis that includes cost history
  WorkType.addScope('withCostHistory', {
    include: [
      {
        association: 'costHistory',
        order: [['captured_at', 'DESC']],
        limit: 5
      }
    ]
  });

  return WorkType;
};
