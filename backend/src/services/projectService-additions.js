// New methods to add to projectService.js

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
},

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
},

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