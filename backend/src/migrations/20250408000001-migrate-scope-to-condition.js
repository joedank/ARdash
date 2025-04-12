'use strict';

/**
 * Migration to transfer scope data from projects to condition inspections
 * This addresses the issue where scope data was stored in the project table 
 * but should be part of the condition inspection data
 */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Get access to the models
      const { Project, ProjectInspection } = require('../models');
      const { Op } = require('sequelize');

      // Find all projects with non-empty scope data
      const projects = await Project.findAll({
        where: {
          scope: {
            [Op.and]: [
              { [Op.not]: null },
              { [Op.ne]: '' }
            ]
          }
        },
        include: [{
          model: ProjectInspection,
          as: 'inspections',
          where: {
            category: 'condition'
          },
          required: false
        }]
      });

      console.log(`Found ${projects.length} projects with scope data to migrate`);

      // Process each project
      for (const project of projects) {
        if (!project.scope) continue;

        // Check if project has condition inspection
        const conditionInspection = project.inspections && project.inspections.length > 0 
          ? project.inspections[0] 
          : null;

        if (!conditionInspection) {
          // Create new condition inspection with scope data
          await ProjectInspection.create({
            project_id: project.id,
            category: 'condition',
            content: {
              assessment: `Project Scope: ${project.scope}`
            }
          });
          console.log(`Created new condition inspection for project ${project.id}`);
        } else {
          // Update existing condition inspection
          const currentAssessment = conditionInspection.content.assessment || '';
          
          // Only append scope if it's not already there
          if (!currentAssessment.includes(project.scope)) {
            const updatedContent = {
              ...conditionInspection.content,
              assessment: currentAssessment 
                ? `${currentAssessment}\n\nProject Scope: ${project.scope}`
                : `Project Scope: ${project.scope}`
            };
            
            await conditionInspection.update({ content: updatedContent });
            console.log(`Updated condition inspection for project ${project.id}`);
          } else {
            console.log(`Scope already present in condition for project ${project.id}`);
          }
        }
      }

      console.log('Scope migration completed successfully');
      return Promise.resolve();
    } catch (error) {
      console.error('Error during scope migration:', error);
      return Promise.reject(error);
    }
  },

  async down(queryInterface, Sequelize) {
    // No down migration as we're not removing data, just duplicating it
    // The original scope field is preserved in the projects table
    return Promise.resolve();
  }
};
