'use strict';

const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class ProjectPhoto extends Model {
    static associate(models) {
      // Association with Project
      ProjectPhoto.belongsTo(models.Project, {
        foreignKey: 'project_id',
        as: 'project'
      });

      // Association with Inspection (optional)
      ProjectPhoto.belongsTo(models.ProjectInspection, {
        foreignKey: 'inspection_id',
        as: 'inspection'
      });
    }

    // Get the full URL for the photo
    getUrl(req) {
      if (!this.file_path) return null;
      return `${req.protocol}://${req.get('host')}/${this.file_path}`;
    }
  }

  ProjectPhoto.init({
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
    inspection_id: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'project_inspections',
        key: 'id'
      },
      field: 'inspection_id'
    },
    photo_type: {
      type: DataTypes.ENUM('before', 'after', 'receipt', 'assessment', 'condition'), // Added 'condition'
      allowNull: false,
      field: 'photo_type',
      validate: {
        isIn: [['before', 'after', 'receipt', 'assessment', 'condition']] // Added 'condition'
      }
    },
    file_path: {
      type: DataTypes.STRING,
      allowNull: false,
      field: 'file_path',
      validate: {
        notEmpty: true
      }
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true,
      field: 'notes'
    }
  }, {
    sequelize,
    modelName: 'ProjectPhoto',
    tableName: 'project_photos',
    underscored: true,
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false, // We don't need updated_at for photos
    hooks: {
      // Add validation to ensure photos are associated correctly
      beforeValidate: async (photo, options) => {
        if (photo.inspection_id) {
          const inspection = await sequelize.models.ProjectInspection.findByPk(photo.inspection_id);
          if (!inspection) {
            throw new Error('Invalid inspection_id');
          }
          if (inspection.project_id !== photo.project_id) {
            throw new Error('Inspection must belong to the same project');
          }
          // Only allow photos of type 'condition' to be linked to inspections
          if (photo.photo_type !== 'condition') {
            throw new Error('Only condition photos can be linked to inspections');
          }
          // Ensure the inspection is of type 'condition'
          if (inspection.category !== 'condition') {
            throw new Error('Photos can only be linked to condition inspections');
          }
        }
      },
      // Clean up old files when deleting photos
      beforeDestroy: async (photo, options) => {
        const fs = require('fs').promises;
        try {
          await fs.unlink(photo.file_path);
        } catch (error) {
          console.error('Error deleting photo file:', error);
        }
      }
    }
  });

  return ProjectPhoto;
};