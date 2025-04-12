'use strict';

const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class ProjectInspection extends Model {
    static associate(models) {
      // Association with Project
      ProjectInspection.belongsTo(models.Project, {
        foreignKey: 'project_id',
        as: 'project'
      });

      // Association with Photos
      ProjectInspection.hasMany(models.ProjectPhoto, {
        foreignKey: 'inspection_id',
        as: 'photos'
      });
    }
  }

  ProjectInspection.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    project_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'projects',
        key: 'id'
      },
      field: 'project_id'
    },
    category: {
      type: DataTypes.ENUM('condition', 'measurements', 'materials'),
      allowNull: false,
      field: 'category',
      validate: {
        isIn: [['condition', 'measurements', 'materials']]
      }
    },
    content: {
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: {},
      field: 'content',
      validate: {
        isValidContent(value) {
          // Validate content structure based on category
          switch (this.category) {
            case 'condition':
              if (!value.assessment || typeof value.assessment !== 'string') {
                throw new Error('Condition assessment must include a description');
              }
              break;
            case 'measurements':
              // Support for new structure with items array
              if (Array.isArray(value.items) && value.items.length > 0) {
                // Check at least one item has valid dimensions
                const hasValidItem = value.items.some(item => 
                  item.dimensions && 
                  typeof item.dimensions === 'object' && 
                  item.description && 
                  typeof item.description === 'string'
                );
                
                if (!hasValidItem) {
                  throw new Error('Measurements must include at least one item with dimensions and description');
                }
              } 
              // Support for legacy structure
              else if (!value.dimensions || typeof value.dimensions !== 'object') {
                throw new Error('Measurements must include dimensions');
              }
              else if (!value.description || typeof value.description !== 'string') {
                throw new Error('Measurements must include a description of what is being measured');
              }
              break;
            case 'materials':
              if (!Array.isArray(value.items)) {
                throw new Error('Materials must include an array of items');
              }
              break;
          }
        }
      }
    }
  }, {
    sequelize,
    modelName: 'ProjectInspection',
    tableName: 'project_inspections',
    underscored: true,
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false // We don't need updated_at for inspections
  });

  return ProjectInspection;
};