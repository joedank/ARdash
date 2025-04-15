'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Get info about projects table
      const projectTableInfo = await queryInterface.describeTable('projects');
      
      // Check for client_fk_id and standardize to client_id if needed
      if (projectTableInfo.client_fk_id && !projectTableInfo.client_id) {
        await queryInterface.renameColumn('projects', 'client_fk_id', 'client_id');
        console.log('Renamed projects.client_fk_id to client_id');
      }
      
      // Check for clientId (camelCase) and standardize to client_id if needed
      if (projectTableInfo.clientId && !projectTableInfo.client_id) {
        await queryInterface.renameColumn('projects', 'clientId', 'client_id');
        console.log('Renamed projects.clientId to client_id');
      }
      
      // Check for address_fk_id and standardize to address_id if needed
      if (projectTableInfo.address_fk_id && !projectTableInfo.address_id) {
        await queryInterface.renameColumn('projects', 'address_fk_id', 'address_id');
        console.log('Renamed projects.address_fk_id to address_id');
      }
      
      // Check for addressId (camelCase) and standardize to address_id if needed
      if (projectTableInfo.addressId && !projectTableInfo.address_id) {
        await queryInterface.renameColumn('projects', 'addressId', 'address_id');
        console.log('Renamed projects.addressId to address_id');
      }
      
      // Check for estimate_fk_id and standardize to estimate_id if needed
      if (projectTableInfo.estimate_fk_id && !projectTableInfo.estimate_id) {
        await queryInterface.renameColumn('projects', 'estimate_fk_id', 'estimate_id');
        console.log('Renamed projects.estimate_fk_id to estimate_id');
      }
      
      // Check for estimateId (camelCase) and standardize to estimate_id if needed
      if (projectTableInfo.estimateId && !projectTableInfo.estimate_id) {
        await queryInterface.renameColumn('projects', 'estimateId', 'estimate_id');
        console.log('Renamed projects.estimateId to estimate_id');
      }
      
      // Now check project_inspections table
      const inspectionTableInfo = await queryInterface.describeTable('project_inspections');
      
      // Check for project_fk_id and standardize to project_id if needed
      if (inspectionTableInfo.project_fk_id && !inspectionTableInfo.project_id) {
        await queryInterface.renameColumn('project_inspections', 'project_fk_id', 'project_id');
        console.log('Renamed project_inspections.project_fk_id to project_id');
      }
      
      // Check for projectId (camelCase) and standardize to project_id if needed
      if (inspectionTableInfo.projectId && !inspectionTableInfo.project_id) {
        await queryInterface.renameColumn('project_inspections', 'projectId', 'project_id');
        console.log('Renamed project_inspections.projectId to project_id');
      }
      
      // Now check project_photos table
      const photoTableInfo = await queryInterface.describeTable('project_photos');
      
      // Check for project_fk_id and standardize to project_id if needed
      if (photoTableInfo.project_fk_id && !photoTableInfo.project_id) {
        await queryInterface.renameColumn('project_photos', 'project_fk_id', 'project_id');
        console.log('Renamed project_photos.project_fk_id to project_id');
      }
      
      // Check for projectId (camelCase) and standardize to project_id if needed
      if (photoTableInfo.projectId && !photoTableInfo.project_id) {
        await queryInterface.renameColumn('project_photos', 'projectId', 'project_id');
        console.log('Renamed project_photos.projectId to project_id');
      }
      
      // Check for inspection_fk_id and standardize to inspection_id if needed
      if (photoTableInfo.inspection_fk_id && !photoTableInfo.inspection_id) {
        await queryInterface.renameColumn('project_photos', 'inspection_fk_id', 'inspection_id');
        console.log('Renamed project_photos.inspection_fk_id to inspection_id');
      }
      
      // Check for inspectionId (camelCase) and standardize to inspection_id if needed
      if (photoTableInfo.inspectionId && !photoTableInfo.inspection_id) {
        await queryInterface.renameColumn('project_photos', 'inspectionId', 'inspection_id');
        console.log('Renamed project_photos.inspectionId to inspection_id');
      }

    } catch (err) {
      console.error('Error in migration:', err);
      throw err;
    }
  },

  async down(queryInterface, Sequelize) {
    console.log('This migration cannot be reversed automatically. Column renames would need manual restoration if needed.');
    // Note: We don't provide a downgrade path because we don't know which columns were actually renamed
    // If needed, table backups should be made before running this migration
  }
};
