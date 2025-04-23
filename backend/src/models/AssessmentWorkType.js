'use strict';

module.exports = (sequelize, DataTypes) => {
  const AssessmentWorkType = sequelize.define('AssessmentWorkType', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    assessment_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'projects',
        key: 'id'
      },
      field: 'assessment_id'
    },
    work_type_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'work_types',
        key: 'id'
      },
      field: 'work_type_id'
    },
    confidence: {
      type: DataTypes.DECIMAL(4, 3),
      allowNull: true,
      comment: '0-1 similarity score',
      field: 'confidence'
    }
  }, {
    sequelize,
    modelName: 'AssessmentWorkType',
    tableName: 'assessment_work_types',
    underscored: true,
    timestamps: false,
    createdAt: 'created_at',
    updatedAt: false
  });
  
  AssessmentWorkType.associate = function(models) {
    // Association with Project (as Assessment)
    AssessmentWorkType.belongsTo(models.Project, {
      foreignKey: 'assessment_id',
      as: 'assessment'
    });

    // Association with WorkType
    AssessmentWorkType.belongsTo(models.WorkType, {
      foreignKey: 'work_type_id',
      as: 'workType'
    });
  };
  
  return AssessmentWorkType;
};
