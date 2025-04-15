'use strict';

const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Project extends Model {
    static associate(models) {
      // Association with Client
      Project.belongsTo(models.Client, {
        foreignKey: 'client_id',
        as: 'client'
      });

      // Association with Estimate (optional)
      Project.belongsTo(models.Estimate, {
        foreignKey: 'estimate_id',
        as: 'estimate'
      });

      // Association with Client Address (optional)
      Project.belongsTo(models.ClientAddress, {
        foreignKey: 'address_id',
        as: 'address'
      });

      // Association with Inspections
      Project.hasMany(models.ProjectInspection, {
        foreignKey: 'project_id',
        as: 'inspections'
      });

      // Association with Photos
      Project.hasMany(models.ProjectPhoto, {
        foreignKey: 'project_id',
        as: 'photos'
      });
      
      // Self-referential associations for project conversion workflow
      // Assessment to active job relationship
      Project.belongsTo(models.Project, {
        foreignKey: 'assessment_id',
        as: 'assessment'
      });
      
      Project.hasMany(models.Project, {
        foreignKey: 'assessment_id',
        as: 'derivedProjects'
      });
      
      // Converted job reference relationship
      Project.belongsTo(models.Project, {
        foreignKey: 'converted_to_job_id',
        as: 'convertedJob'
      });
      
      Project.hasOne(models.Project, {
        foreignKey: 'converted_to_job_id',
        as: 'originalAssessment'
      });
    }
  }

  Project.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    client_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'clients',
        key: 'id'
      },
      field: 'client_id'
    },
    address_id: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'client_addresses',
        key: 'id'
      },
      field: 'address_id',
      comment: 'Foreign key to client_addresses table for the selected address'
    },
    estimate_id: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'estimates',
        key: 'id'
      },
      field: 'estimate_id'
    },
    type: {
      type: DataTypes.ENUM('assessment', 'active'),
      allowNull: false,
      defaultValue: 'assessment',
      field: 'type'
    },
    status: {
      type: DataTypes.ENUM('pending', 'in_progress', 'completed', 'upcoming', 'rejected'),
      defaultValue: 'pending',
      allowNull: false,
      field: 'status'
    },
    scheduled_date: {
      type: DataTypes.DATEONLY,
      allowNull: false,
      field: 'scheduled_date'
    },
    scope: {
      type: DataTypes.TEXT,
      allowNull: true,
      field: 'scope'
    },
    additional_work: {
      type: DataTypes.TEXT,
      allowNull: true,
      field: 'additional_work'
    },
    assessment_id: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'projects',
        key: 'id'
      },
      field: 'assessment_id',
      comment: 'Reference to the original assessment project when converted to an active job'
    },
    converted_to_job_id: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'projects',
        key: 'id'
      },
      field: 'converted_to_job_id',
      comment: 'Reference to the active job that this assessment was converted to'
    }
  }, {
    sequelize,
    modelName: 'Project',
    tableName: 'projects',
    underscored: true,
    timestamps: true,
    createdAt: 'created_at', // Explicit mapping
    updatedAt: 'updated_at'  // Explicit mapping
  });

  return Project;
};