'use strict';

module.exports = (sequelize, DataTypes) => {
  const WorkTypeTag = sequelize.define('WorkTypeTag', {
    work_type_id: {
      type: DataTypes.UUID,
      allowNull: false,
      primaryKey: true,
      references: {
        model: 'work_types',
        key: 'id'
      }
    },
    tag: {
      type: DataTypes.STRING(50),
      allowNull: false,
      primaryKey: true,
      validate: {
        notEmpty: true
      }
    }
  }, {
    tableName: 'work_type_tags',
    timestamps: true,
    underscored: true
  });

  WorkTypeTag.associate = function(models) {
    // Belongs to WorkType
    WorkTypeTag.belongsTo(models.WorkType, {
      foreignKey: 'work_type_id',
      as: 'workType',
      onDelete: 'CASCADE'
    });
  };

  return WorkTypeTag;
};
