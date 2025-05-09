'use strict';

const { Project, ProjectInspection, ProjectPhoto, Client, ClientAddress, Estimate, EstimateItem, sequelize } = require('../models');
const { ValidationError } = require('../utils/errors');
const fs = require('fs').promises;
const path = require('path');
const sharp = require('sharp');
const { Op } = require('sequelize');
const logger = require('../utils/logger');

class ProjectService {
  /**
   * Get all projects with optional filters
   * @param {Object} filters - Filter parameters
   * @param {string} filters.type - Filter by project type
   * @param {string} filters.status - Filter by project status
   * @param {boolean} filters.includeConverted - Whether to include converted assessments
   * @returns {Promise<Array>} List of projects
   */
  async getAllProjects(filters = {}) {
    const where = {};

    // Apply type filter if specified
    if (filters.type && filters.type !== 'all') {
      where.type = filters.type;
    }

    // Apply status filter if specified
    if (filters.status && filters.status !== 'all') {
      where.status = filters.status;
    }

    // Filter out converted assessments unless explicitly requested
    if (filters.includeConverted !== true) {
      where.converted_to_job_id = null;
    }

    return await Project.findAll({
      where,
      include: [{
        model: Client,
        as: 'client',
        attributes: ['id', 'display_name', 'company', 'email', 'phone'],
        include: [{
          model: ClientAddress,
          as: 'addresses'
        }]
      }, {
        model: ClientAddress,
        as: 'address',
        required: false
      }, {
        model: Estimate,
        as: 'estimate',
        required: false,
        include: [{
          model: EstimateItem,
          as: 'items'
        }]
      }, {
        // Include related assessment if this is an active job
        model: Project,
        as: 'assessment',
        required: false
      }, {
        // Include converted job if this is an assessment
        model: Project,
        as: 'convertedJob',
        required: false
      }],
      // order: [
      //   ['scheduled_date', 'DESC'],
      //   ['created_at', 'DESC']
      // ]
    });
  }

  /**
   * Create a new project
   * @param {Object} data - Project data
   * @returns {Promise<Object>} Created project
   */
  async createProject(data) {
    const { client_id, estimate_id, address_id, condition, scheduled_date, type = 'assessment', status } = data;

    // Validate client exists
    const client = await Client.findByPk(client_id, {
      include: [{ model: ClientAddress, as: 'addresses' }]
    });
    if (!client) {
      throw new ValidationError('Client not found');
    }

    // Process address_id
    let finalAddressId = address_id;

    // If no address_id provided, try to find primary or first client address
    if (!finalAddressId && client.addresses && client.addresses.length > 0) {
      // Look for primary address first
      const primaryAddress = client.addresses.find(addr => addr.is_primary);
      // If no primary address, use the first one
      finalAddressId = primaryAddress ? primaryAddress.id : client.addresses[0].id;
    }

    // Validate address if provided
    if (finalAddressId) {
      const address = await ClientAddress.findByPk(finalAddressId);
      if (!address) {
        throw new ValidationError('Address not found');
      }
      if (address.client_id !== client_id) {
        throw new ValidationError('Address does not belong to this client');
      }
    }

    // Validate estimate if provided
    if (estimate_id) {
      const estimate = await Estimate.findByPk(estimate_id);
      if (!estimate) {
        throw new ValidationError('Estimate not found');
      }
      if (estimate.client_id !== client_id) {
        throw new ValidationError('Estimate does not belong to this client');
      }
    }

    // Determine appropriate status based on project type and scheduled date
    let initialStatus = status;
    if (!initialStatus) {
      initialStatus = 'pending';

      if (type === 'active') {
        const today = new Date();
        today.setHours(0, 0, 0, 0); // Set to start of day

        if (scheduled_date) {
          const scheduledDate = new Date(scheduled_date);
          scheduledDate.setHours(0, 0, 0, 0); // Set to start of day

          if (scheduledDate > today) {
            initialStatus = 'upcoming';
          } else {
            initialStatus = 'in_progress';
          }
        }
      }
    }

    return await Project.create({
      client_id,
      estimate_id,
      address_id: finalAddressId,
      condition,
      scheduled_date,
      type: type || (estimate_id ? 'active' : 'assessment'),
      status: initialStatus
    });
  }

  /**
   * Get projects scheduled for today
   * @returns {Promise<Array>} Today's projects
   */
  async getTodayProjects() {
    const today = new Date();
    // Format as YYYY-MM-DD string for DATEONLY comparison
    const formattedDate = today.toISOString().split('T')[0];

    return await Project.findAll({
      where: {
        scheduled_date: formattedDate
      },
      include: [{
        model: Client,
        as: 'client',
        attributes: ['id', 'display_name', 'company', 'email', 'phone'],
        include: [{
          model: ClientAddress,
          as: 'addresses'
        }]
      }, {
        model: Estimate,
        as: 'estimate',
        required: false,
        include: [{
          model: EstimateItem,
          as: 'items'
        }]
      }, {
        model: ClientAddress,
        as: 'address',
        required: false
      }],
      // order: [
      //   ['type', 'DESC'], // assessments first
      //   ['created_at', 'ASC']
      // ]
    });
  }

  /**
   * Get a project with all its details
   * @param {string} projectId - Project ID
   * @returns {Promise<Object>} Project with details
   */
  async getProjectWithDetails(projectId) {
    const project = await Project.findByPk(projectId, {
      include: [
        {
          model: Client,
          as: 'client',
          attributes: ['id', 'display_name', 'company', 'email', 'phone'],
          include: [{
            model: ClientAddress,
            as: 'addresses'
          }]
        },
        {
          model: Estimate,
          as: 'estimate',
          include: [{
            model: EstimateItem,
            as: 'items'
          }]
        },
        {
          model: ClientAddress,
          as: 'address'
        },
        {
          model: ProjectInspection,
          as: 'inspections',
          include: [{
            model: ProjectPhoto,
            as: 'photos'
          }],
          order: [['created_at', 'DESC']] // Sort by creation date, newest first
        },
        {
          model: ProjectInspection,
          as: 'conditionInspection',
          where: { category: 'condition' },
          required: false
        },
        {
          model: ProjectPhoto,
          as: 'photos',
          where: {
            inspection_id: null // Only direct project photos
          },
          required: false
        },
        // Include related assessment if this is an active job
        {
          model: Project,
          as: 'assessment',
          required: false,
          include: [
            {
              model: ProjectInspection,
              as: 'inspections'
            },
            {
              model: ProjectPhoto,
              as: 'photos',
              required: false
            }
          ]
        },
        // Include converted job if this is an assessment
        {
          model: Project,
          as: 'convertedJob',
          required: false
        }
      ]
    });

    if (!project) {
      throw new ValidationError('Project not found');
    }

    return project;
  }

  /**
   * Alias kept for controller compatibility.
   * @param {string} projectId
   * @returns {Promise<Object>}
   */
  async getProject(projectId) {
    return this.getProjectWithDetails(projectId);
  }

  /**
   * Update project
   * @param {string} projectId - Project ID
   * @param {Object} data - Updated project data
   * @returns {Promise<Object>} Updated project
   */
  async updateProject(projectId, data) {
    const project = await Project.findByPk(projectId);
    if (!project) {
      throw new ValidationError('Project not found');
    }

    // Extract updateable fields
    const { client_id, type, status, scheduled_date, condition } = data;

    // Validate client if changing
    if (client_id && client_id !== project.client_id) {
      const client = await Client.findByPk(client_id);
      if (!client) {
        throw new ValidationError('Client not found');
      }
    }

    // Update the project
    const updateData = {
      client_id: client_id || project.client_id,
      type: type || project.type,
      status: status || project.status,
      scheduled_date: scheduled_date || project.scheduled_date,
      condition: condition !== undefined ? condition : project.condition
    };

    // Include address_id if provided
    if (data.address_id) {
      const address = await ClientAddress.findByPk(data.address_id);
      if (!address) {
        throw new ValidationError('Address not found');
      }
      if (address.client_id !== (client_id || project.client_id)) {
        throw new ValidationError('Address does not belong to this client');
      }
      updateData.address_id = data.address_id;
    }

    await project.update(updateData);

    // Return the updated project with client info
    return await this.getProjectWithDetails(projectId);
  }

  /**
   * Get dependencies for a project
   * @param {string} projectId - Project ID
   * @returns {Promise<Object>} Dependencies information
   */
  async getProjectDependencies(projectId) {
    const project = await Project.findByPk(projectId);
    if (!project) {
      throw new ValidationError('Project not found');
    }

    // Check for related job if this is an assessment
    let relatedJob = null;
    if (project.converted_to_job_id) {
      relatedJob = await Project.findByPk(project.converted_to_job_id, {
        attributes: ['id', 'type', 'status', 'client_id'],
        include: [{ model: Client, as: 'client', attributes: ['display_name'] }]
      });
    }

    // Check if this is a job linked to an assessment
    let relatedAssessment = null;
    if (project.assessment_id) {
      relatedAssessment = await Project.findByPk(project.assessment_id, {
        attributes: ['id', 'type', 'status', 'client_id'],
        include: [{ model: Client, as: 'client', attributes: ['display_name'] }]
      });
    }

    // Check for inspections
    const inspectionsCount = await ProjectInspection.count({
      where: { project_id: projectId }
    });

    // Check for photos
    const photosCount = await ProjectPhoto.count({
      where: { project_id: projectId }
    });

    // Check for related estimates
    const estimatesCount = await Estimate.count({
      where: { project_id: projectId }
    });

    return {
      hasRelatedJob: !!relatedJob,
      relatedJob,
      hasRelatedAssessment: !!relatedAssessment,
      relatedAssessment,
      inspectionsCount,
      photosCount,
      estimatesCount,
      hasDependencies: !!relatedJob || !!relatedAssessment || inspectionsCount > 0 || photosCount > 0 || estimatesCount > 0
    };
  }

  /**
   * Delete a project
   * @param {string} projectId - Project ID
   * @returns {Promise<boolean>} Success indicator
   */
  async deleteProject(projectId) {
    // Use a transaction to ensure all related records are deleted or none are
    const transaction = await sequelize.transaction();

    try {
      // Fetch the project with related records
      const project = await Project.findByPk(projectId, {
        include: [
          {
            model: ProjectInspection,
            as: 'inspections',
            include: [
              {
                model: ProjectPhoto,
                as: 'photos'
              }
            ]
          },
          {
            model: ProjectPhoto,
            as: 'photos',
            where: {
              inspection_id: null // Only direct project photos
            },
            required: false
          }
        ],
        transaction
      });

      if (!project) {
        await transaction.rollback();
        throw new ValidationError('Project not found');
      }

      // Handle bidirectional references

      // 1. If this is an assessment with a converted job, update the job
      if (project.converted_to_job_id) {
        await Project.update(
          { assessment_id: null },
          {
            where: { id: project.converted_to_job_id },
            transaction
          }
        );
        logger.info(`Updated job ${project.converted_to_job_id} to remove assessment reference`);
      }

      // 2. If this is a job linked to an assessment, update the assessment
      if (project.assessment_id) {
        await Project.update(
          { converted_to_job_id: null },
          {
            where: { id: project.assessment_id },
            transaction
          }
        );
        logger.info(`Updated assessment ${project.assessment_id} to remove job reference`);
      }

      // Delete associated photos from file system
      try {
        // Delete direct project photos
        for (const photo of project.photos || []) {
          if (photo.file_path) {
            await fs.unlink(photo.file_path).catch(() => {
              // Ignore if file doesn't exist
            });
          }
          // Delete the photo record from the database
          await photo.destroy({ transaction });
        }

        // Delete inspection-related photos
        for (const inspection of project.inspections || []) {
          if (inspection.photos && inspection.photos.length > 0) {
            for (const photo of inspection.photos) {
              if (photo.file_path) {
                await fs.unlink(photo.file_path).catch(() => {
                  // Ignore if file doesn't exist
                });
              }
              // Delete the photo record from the database
              await photo.destroy({ transaction });
            }
          }
          // Delete the inspection record from the database
          await inspection.destroy({ transaction });
        }

        // Attempt to remove the project photos directory
        const photosDir = path.join('uploads', 'project-photos', projectId);
        await fs.rmdir(photosDir, { recursive: true }).catch(() => {
          // Ignore if directory doesn't exist or can't be removed
        });
      } catch (error) {
        // Log but continue with deletion
        console.error('Error removing project files:', error);
      }

      // Now delete all related ProjectInspection records that might not have been included in the includes
      await ProjectInspection.destroy({
        where: { project_id: projectId },
        transaction
      });

      // Now delete all related ProjectPhoto records that might not have been included in the includes
      await ProjectPhoto.destroy({
        where: { project_id: projectId },
        transaction
      });

      // Finally delete the project from the database
      await project.destroy({ transaction });

      // Commit the transaction
      await transaction.commit();

      return true;
    } catch (error) {
      // Rollback the transaction if any error occurs
      await transaction.rollback();
      console.error('Error deleting project:', error);
      throw error;
    }
  }

  /**
   * Delete a project with references (enhanced version of deleteProject)
   * @param {string} projectId - Project ID
   * @returns {Promise<boolean>} Success indicator
   */
  async deleteProjectWithReferences(projectId) {
    const transaction = await sequelize.transaction();

    try {
      // Fetch the project with all its relationships
      const project = await Project.findByPk(projectId, {
        include: [
          {
            model: ProjectInspection,
            as: 'inspections',
            include: [{ model: ProjectPhoto, as: 'photos' }]
          },
          {
            model: ProjectPhoto,
            as: 'photos',
            where: { inspection_id: null },
            required: false
          },
          {
            model: Estimate,
            as: 'estimate',
            required: false
          }
        ],
        transaction
      });

      if (!project) {
        await transaction.rollback();
        throw new ValidationError('Project not found');
      }

      // If this is a job, find and delete the associated assessment
      if (project.type === 'active' && project.assessment_id) {
        // First get the assessment
        const assessment = await Project.findByPk(project.assessment_id, { transaction });

        if (assessment) {
          // Delete assessment's photos and inspections first
          await this._deleteProjectPhotosAndInspections(assessment.id, transaction);

          // Delete the assessment
          await assessment.destroy({ transaction });
          logger.info(`Deleted associated assessment: ${assessment.id}`);
        }
      }

      // If this is an assessment, find and delete the converted job
      if (project.type === 'assessment' && project.converted_to_job_id) {
        // First get the job
        const job = await Project.findByPk(project.converted_to_job_id, { transaction });

        if (job) {
          // Delete job's photos and inspections first
          await this._deleteProjectPhotosAndInspections(job.id, transaction);

          // Delete the job
          await job.destroy({ transaction });
          logger.info(`Deleted converted job: ${job.id}`);
        }
      }

      // Delete this project's photos and inspections
      await this._deleteProjectPhotosAndInspections(projectId, transaction);

      // Delete any associated estimates
      if (project.estimate) {
        // Delete estimate items first
        await EstimateItem.destroy({
          where: { estimate_id: project.estimate.id },
          transaction
        });

        // Delete the estimate
        await project.estimate.destroy({ transaction });
        logger.info(`Deleted associated estimate: ${project.estimate.id}`);
      }

      // Finally delete the project
      await project.destroy({ transaction });

      // Commit transaction
      await transaction.commit();
      return true;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error deleting project with references:', error);
      throw error;
    }
  }

  /**
   * Helper method to delete a project's photos and inspections
   * @param {string} projectId - Project ID
   * @param {Transaction} transaction - Active transaction
   * @private
   */
  async _deleteProjectPhotosAndInspections(projectId, transaction) {
    // Delete inspection photos
    await ProjectPhoto.destroy({
      where: {
        project_id: projectId,
        inspection_id: { [Op.not]: null }
      },
      transaction
    });

    // Delete inspections
    await ProjectInspection.destroy({
      where: { project_id: projectId },
      transaction
    });

    // Delete direct project photos
    await ProjectPhoto.destroy({
      where: {
        project_id: projectId,
        inspection_id: null
      },
      transaction
    });

    // Attempt to remove the photos directory
    try {
      const photosDir = path.join('uploads', 'project-photos', projectId);
      await fs.rmdir(photosDir, { recursive: true }).catch(() => {
        // Ignore if directory doesn't exist or can't be removed
      });
    } catch (error) {
      logger.error(`Error removing photos directory for project ${projectId}:`, error);
    }
  }

  /**
   * Update project status
   * @param {string} projectId - Project ID
   * @param {string} status - New status
   * @returns {Promise<Object>} Updated project
   */
  async updateProjectStatus(projectId, status) {
    const project = await Project.findByPk(projectId);
    if (!project) {
      throw new ValidationError('Project not found');
    }

    return await project.update({ status });
  }

  /**
   * Add an inspection to a project
   * @param {string} projectId - Project ID
   * @param {Object} data - Inspection data
   * @returns {Promise<Object>} Created inspection
   */
  async addInspection(projectId, data) {
    const { category, content } = data;

    // Use a transaction to ensure data consistency
    const transaction = await sequelize.transaction();

    try {
      const project = await Project.findByPk(projectId, { transaction });
      if (!project) {
        await transaction.rollback();
        throw new ValidationError('Project not found');
      }

      // Find and delete existing inspections of the same category
      await ProjectInspection.destroy({
        where: {
          project_id: projectId,
          category
        },
        transaction
      });

      // Create the new inspection
      const newInspection = await ProjectInspection.create({
        project_id: projectId,
        category,
        content
      }, { transaction });

      // Commit the transaction
      await transaction.commit();

      return newInspection;
    } catch (error) {
      // Rollback the transaction in case of error
      await transaction.rollback();
      throw error;
    }
  }

  /**
   * Add a photo to a project
   * @param {string} projectId - Project ID
   * @param {Object} photoFile - Photo file
   * @param {Object} data - Photo data
   * @returns {Promise<Object>} Created photo
   */
  async addProjectPhoto(projectId, photoFile, data) {
    const { photo_type, inspection_id, notes } = data;

    const project = await Project.findByPk(projectId);
    if (!project) {
      throw new ValidationError('Project not found');
    }

    if (inspection_id) {
      const inspection = await ProjectInspection.findByPk(inspection_id);
      if (!inspection || inspection.project_id !== projectId) {
        throw new ValidationError('Invalid inspection ID');
      }
    }

    // Create photos directory if it doesn't exist
    const photosDir = path.join('uploads', 'project-photos', projectId);
    await fs.mkdir(photosDir, { recursive: true });

    // Process and save the image
    const timestamp = Date.now();
    const extension = path.extname(photoFile.originalname);
    const fileName = `${timestamp}${extension}`;
    const filePath = path.join(photosDir, fileName);

    console.log('Processing photo:', {
      originalName: photoFile.originalname,
      fileName,
      extension,
      filePath
    });

    // Optimize the image
    const sharpInstance = sharp(photoFile.buffer)
      .resize(1920, 1920, { // Max dimension 1920px
        fit: 'inside',
        withoutEnlargement: true
      });

    // Keep original format if it's PNG, otherwise convert to JPEG
    if (extension.toLowerCase() === '.png') {
      await sharpInstance.png({ quality: 80 }).toFile(filePath);
    } else {
      await sharpInstance.jpeg({ quality: 80 }).toFile(filePath);
    }

    // Calculate relative path for frontend use
    const relativePath = path.join('uploads', 'project-photos', projectId, fileName).replace(/\\/g, '/');

    console.log('Saving photo:', {
      projectId,
      photoType: photo_type,
      relativePath,
      originalName: photoFile.originalname
    });

    // Create database record
    return await ProjectPhoto.create({
      project_id: projectId,
      inspection_id,
      photo_type,
      file_path: relativePath, // Store relative path instead of system path
      notes
    });
  }

  /**
   * Delete a photo from a project
   * @param {string} projectId - Project ID
   * @param {string} photoId - Photo ID
   * @returns {Promise<boolean>} Success indicator
   */
  async deleteProjectPhoto(projectId, photoId) {
    const photo = await ProjectPhoto.findOne({
      where: {
        id: photoId,
        project_id: projectId
      }
    });

    if (!photo) {
      throw new ValidationError('Photo not found');
    }

    // Delete the physical file
    if (photo.file_path) {
      try {
        const fullPath = path.resolve(photo.file_path); // Resolve to absolute path
        await fs.unlink(fullPath);
        console.log(`Deleted photo file: ${fullPath}`);
      } catch (error) {
        // Log error but continue to delete DB record
        console.error(`Failed to delete photo file ${photo.file_path}:`, error);
        // Optionally, you might want to re-throw or handle differently
        // depending on whether file deletion failure should prevent DB deletion
      }
    }

    // Delete the database record
    await photo.destroy();
    return true;
  }


  /**
   * Convert project to estimate
   * @param {string} projectId - Project ID
   * @returns {Promise<Object>} Conversion result
   */
  async convertToEstimate(projectId) {
    const project = await this.getProjectWithDetails(projectId);

    if (project.type !== 'assessment') {
      throw new ValidationError('Only assessment projects can be converted to estimates');
    }

    if (project.estimate_id) {
      throw new ValidationError('Project already has an associated estimate');
    }

    // Create estimate items from inspection data
    const estimateItems = [];
    for (const inspection of project.inspections) {
      if (inspection.category === 'materials' && inspection.content.items) {
        estimateItems.push(...inspection.content.items.map(item => ({
          description: item.name,
          quantity: item.quantity,
          price: item.estimatedPrice || 0
        })));
      }
    }

    // First create the estimate without items
    const estimate = await Estimate.create({
      client_fk_id: project.client_id,
      dateCreated: new Date(),
      validUntil: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
      status: 'draft'
    });

    // Then create the items separately if there are any
    if (estimateItems.length > 0) {
      // Add estimate ID to each item
      const itemsWithEstimateId = estimateItems.map(item => ({
        ...item,
        estimateId: estimate.id
      }));

      // Create the items
      await EstimateItem.bulkCreate(itemsWithEstimateId);
    }

    // Update project
    await project.update({
      estimate_id: estimate.id,
      type: 'active'
    });

    // Reload the estimate with items
    const reloadedEstimate = await Estimate.findByPk(estimate.id, {
      include: [{
        model: EstimateItem,
        as: 'items'
      }]
    });

    return { project, estimate: reloadedEstimate };
  }

  /**
   * Convert assessment to active job
   * @param {string} assessmentId - Assessment Project ID
   * @param {string} estimateId - Estimate ID to associate with the job
   * @returns {Promise<Object>} Newly created job project
   */
  async convertAssessmentToJob(assessmentId, estimateId) {
    const transaction = await sequelize.transaction();

    try {
      // Validate the assessment exists
      const assessmentProject = await Project.findByPk(assessmentId, {
        include: [
          { model: Client, as: 'client' },
          { model: ProjectPhoto, as: 'photos', where: { photo_type: 'before' }, required: false },
          { model: Estimate, as: 'estimate', required: false }
        ],
        transaction
      });

      if (!assessmentProject) {
        throw new ValidationError('Assessment project not found');
      }

      if (assessmentProject.type !== 'assessment') {
        throw new ValidationError('Project is not an assessment');
      }

      // Verify the estimate exists
      const estimate = await Estimate.findByPk(estimateId, { transaction });
      if (!estimate) {
        throw new ValidationError('Estimate not found');
      }

      // Determine status based on scheduled date
      let initialStatus = 'in_progress';
      const today = new Date();
      today.setHours(0, 0, 0, 0); // Set to start of day

      // Use job's scheduled date or default to today
      const scheduledDate = assessmentProject.scheduled_date ? new Date(assessmentProject.scheduled_date) : new Date();
      scheduledDate.setHours(0, 0, 0, 0); // Set to start of day

      if (scheduledDate > today) {
        initialStatus = 'upcoming';
      }

      // Create a new job project linked to the assessment
      const jobProject = await Project.create({
        client_id: assessmentProject.client_id,
        address_id: assessmentProject.address_id,
        type: 'active',
        status: initialStatus,
        estimate_id: estimateId,
        scheduled_date: scheduledDate,
        condition: assessmentProject.condition // Use condition instead of scope
      }, { transaction });

      // Copy "before" photos to the new job
      if (assessmentProject.photos && assessmentProject.photos.length > 0) {
        for (const photo of assessmentProject.photos) {
          await ProjectPhoto.create({
            project_id: jobProject.id,
            photo_type: 'before',
            file_path: photo.file_path,
            notes: photo.notes,
            created_at: new Date(),
            updated_at: new Date()
          }, { transaction });
        }
      }

      // Mark estimate as accepted if not already
      if (estimate.status === 'draft' || estimate.status === 'sent') {
        await estimate.update({
          status: 'accepted'
        }, { transaction });
      }

      // Update assessment status to indicate it's been converted
      await assessmentProject.update({
        status: 'completed',
        converted_to_job_id: jobProject.id  // Add reference to the new job project
      }, { transaction });

      await transaction.commit();

      // Return the new job project with related data
      return await this.getProjectWithDetails(jobProject.id);
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }

  /**
   * Update additional work notes for a project
   * @param {string} projectId - Project ID
   * @param {string} notes - Additional work notes
   * @returns {Promise<Object>} Updated project
   */
  async updateAdditionalWork(projectId, notes) {
    const project = await Project.findByPk(projectId);

    if (!project) {
      throw new ValidationError('Project not found');
    }

    // Update the project with additional work notes
    await project.update({
      additional_work: notes
    });

    // Return the updated project with full details
    return await this.getProjectWithDetails(projectId);
  }

  /**
   * Get the current active job (the most recently updated 'in_progress' job)
   * @returns {Promise<Object|null>} The current active job or null if none found
   */
  async getCurrentActiveJob() {
    try {
      const activeJob = await Project.findOne({
        where: {
          type: 'active',
          status: 'in_progress'
        },
        include: [{
          model: Client,
          as: 'client',
          attributes: ['id', 'display_name', 'company', 'email', 'phone'],
          include: [{
            model: ClientAddress,
            as: 'addresses'
          }]
        }, {
          model: ClientAddress,
          as: 'address',
          required: false
        }, {
          model: Estimate,
          as: 'estimate',
          required: false,
          include: [{
            model: EstimateItem,
            as: 'items'
          }]
        }, {
          // Include related assessment if this is an active job
          model: Project,
          as: 'assessment',
          required: false
        }],
        order: [
          ['updated_at', 'DESC']
        ]
      });

      // If no active job is found, return null without error
      if (!activeJob) {
        logger.info('No active job found');
        return null;
      }

      return activeJob;
    } catch (error) {
      logger.error('Error getting current active job:', error);
      throw error;
    }
  }

  /**
   * Get upcoming projects (with 'upcoming' status)
   * @param {number} limit - Maximum number of projects to return
   * @returns {Promise<Array>} Upcoming projects
   */
  async getUpcomingProjects(limit = 5) {
    try {
      const projects = await Project.findAll({
        where: {
          status: 'upcoming',
          type: 'active' // Only active jobs
        },
        include: [{
          model: Client,
          as: 'client',
          attributes: ['id', 'display_name', 'company', 'email', 'phone'],
          include: [{
            model: ClientAddress,
            as: 'addresses'
          }]
        }, {
          model: ClientAddress,
          as: 'address',
          required: false
        }, {
          model: Estimate,
          as: 'estimate',
          required: false
        }],
        order: [
          ['scheduled_date', 'ASC'] // Earliest first
        ],
        limit
      });

      // Return empty array if no projects found
      if (!projects || projects.length === 0) {
        logger.info('No upcoming projects found');
        return [];
      }

      return projects;
    } catch (error) {
      logger.error('Error getting upcoming projects:', error);
      throw error;
    }
  }

  /**
   * Get assessment projects that haven't been converted to jobs
   * @param {number} limit - Maximum number of projects to return
   * @returns {Promise<Array>} Assessment projects
   */
  async getAssessmentProjects(limit = 10) {
    try {
      const projects = await Project.findAll({
        where: {
          type: 'assessment',
          converted_to_job_id: null, // Not converted to job yet
          status: {
            [Op.ne]: 'completed' // Not completed
          }
        },
        include: [{
          model: Client,
          as: 'client',
          attributes: ['id', 'display_name', 'company', 'email', 'phone'],
          include: [{
            model: ClientAddress,
            as: 'addresses'
          }]
        }, {
          model: ClientAddress,
          as: 'address',
          required: false
        }],
        order: [
          ['updated_at', 'DESC'] // Most recently updated first
        ],
        limit
      });

      // Return empty array if no projects found
      if (!projects || projects.length === 0) {
        logger.info('No assessment projects found');
        return [];
      }

      return projects;
    } catch (error) {
      logger.error('Error getting assessment projects:', error);
      throw error;
    }
  }

  /**
   * Get recently completed projects
   * @param {number} limit - Maximum number of projects to return
   * @returns {Promise<Array>} Recently completed projects
   */
  async getRecentlyCompletedProjects(limit = 5) {
    try {
      const projects = await Project.findAll({
        where: {
          status: 'completed',
          type: 'active' // Only active jobs, not assessments
        },
        include: [{
          model: Client,
          as: 'client',
          attributes: ['id', 'display_name', 'company', 'email', 'phone'],
          include: [{
            model: ClientAddress,
            as: 'addresses'
          }]
        }, {
          model: ClientAddress,
          as: 'address',
          required: false
        }, {
          model: Estimate,
          as: 'estimate',
          required: false
        }],
        order: [
          ['updated_at', 'DESC'] // Most recently completed first
        ],
        limit
      });

      // Return empty array if no projects found
      if (!projects || projects.length === 0) {
        logger.info('No recently completed projects found');
        return [];
      }

      return projects;
    } catch (error) {
      logger.error('Error getting recently completed projects:', error);
      throw error;
    }
  }

  /**
   * Update upcoming projects to in_progress when their scheduled date arrives
   * This method is designed to be called by a daily CRON job
   * @returns {Promise<Object>} Results with count of updated projects
   */
  async updateUpcomingProjects() {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0); // Set to start of day

      // Format as YYYY-MM-DD string for DATEONLY comparison
      const formattedDate = today.toISOString().split('T')[0];

      // Find upcoming projects with scheduled date that is today or earlier
      const upcomingProjects = await Project.findAll({
        where: {
          status: 'upcoming',
          scheduled_date: {
            [Op.lte]: formattedDate // Less than or equal to today
          }
        }
      });

      logger.info(`Found ${upcomingProjects.length} upcoming projects to update`);

      // Update the projects to in_progress
      let updatedCount = 0;
      const projectIds = [];

      for (const project of upcomingProjects) {
        await project.update({ status: 'in_progress' });
        updatedCount++;
        projectIds.push(project.id);
        logger.info(`Updated project ${project.id} from upcoming to in_progress`);
      }

      return {
        updatedCount,
        projectIds
      };
    } catch (error) {
      logger.error('Error updating upcoming projects:', error);
      throw error;
    }
  }

  /**
   * Get rejected assessment projects
   * @param {number} limit - Maximum number of projects to return
   * @returns {Promise<Array>} Rejected assessment projects
   */
  async getRejectedProjects(limit = 5) {
    try {
      const projects = await Project.findAll({
        where: {
          type: 'assessment',
          status: 'rejected'
        },
        include: [{
          model: Client,
          as: 'client',
          attributes: ['id', 'display_name', 'company', 'email', 'phone'],
          include: [{
            model: ClientAddress,
            as: 'addresses'
          }]
        }, {
          model: ClientAddress,
          as: 'address',
          required: false
        }],
        order: [
          ['updated_at', 'DESC'] // Most recently rejected first
        ],
        limit
      });

      // Return empty array if no projects found
      if (!projects || projects.length === 0) {
        logger.info('No rejected assessment projects found');
        return [];
      }

      return projects;
    } catch (error) {
      logger.error('Error getting rejected assessment projects:', error);
      throw error;
    }
  }

  /**
   * Update work types for a project assessment
   * @param {string} projectId - Project ID
   * @param {Array} workTypes - Array of work type IDs
   * @returns {Promise<Object>} Updated project
   */
  async updateWorkTypes(projectId, workTypes) {
    try {
      const project = await Project.findByPk(projectId);
      if (!project) {
        throw new ValidationError('Project not found');
      }

      if (!Array.isArray(workTypes)) {
        throw new ValidationError('Work types must be an array');
      }

      // Update the project with work types
      await project.update({
        work_types: workTypes
      });

      logger.info(`Updated work types for project ${projectId}: ${workTypes.length} work types`);

      // Return updated project with details
      return await this.getProjectWithDetails(projectId);
    } catch (error) {
      logger.error(`Error updating work types for project ${projectId}:`, error);
      throw error;
    }
  }

  /**
   * Reject an assessment project
   * @param {string} projectId - Project ID
   * @param {string} rejectionReason - Optional reason for rejection
   * @returns {Promise<Object>} Updated project
   */
  async rejectAssessment(projectId, rejectionReason = null) {
    try {
      const project = await Project.findByPk(projectId);
      if (!project) {
        throw new ValidationError('Project not found');
      }

      if (project.type !== 'assessment') {
        throw new ValidationError('Only assessment projects can be rejected');
      }

      if (project.converted_to_job_id) {
        throw new ValidationError('Cannot reject an assessment that has already been converted to a job');
      }

      // Update status and add rejection reason if provided
      const updateData = { status: 'rejected' };
      if (rejectionReason) {
        updateData.condition = project.condition
          ? `${project.condition}\n\nRejection Reason: ${rejectionReason}`
          : `Rejection Reason: ${rejectionReason}`;
      }

      await project.update(updateData);
      logger.info(`Assessment project ${projectId} marked as rejected`);

      // Return updated project with details
      return await this.getProjectWithDetails(projectId);
    } catch (error) {
      logger.error(`Error rejecting assessment project ${projectId}:`, error);
      throw error;
    }
  }
}

module.exports = new ProjectService();