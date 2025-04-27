'use strict';

const { v4: uuidv4 } = require('uuid');

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Get all work types with non-standard UUIDs
      // Using NOT SIMILAR TO instead of !~ which doesn't work with UUID type
      const workTypes = await queryInterface.sequelize.query(
        `SELECT id, name FROM work_types WHERE id::text NOT SIMILAR TO '[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}'`,
        { type: Sequelize.QueryTypes.SELECT }
      );

      console.log(`Found ${workTypes.length} work types with non-standard UUIDs`);

      // Update each work type with a new UUID
      for (const workType of workTypes) {
        const oldId = workType.id;
        const newId = uuidv4();
        
        console.log(`Updating work type "${workType.name}" from ${oldId} to ${newId}`);
        
        // Start a transaction for each update to ensure consistency
        await queryInterface.sequelize.transaction(async (transaction) => {
          // Update foreign keys in work_type_materials
          await queryInterface.sequelize.query(
            `UPDATE work_type_materials SET work_type_id = '${newId}' WHERE work_type_id = '${oldId}'`,
            { transaction }
          );
          
          // Update foreign keys in work_type_tags
          await queryInterface.sequelize.query(
            `UPDATE work_type_tags SET work_type_id = '${newId}' WHERE work_type_id = '${oldId}'`,
            { transaction }
          );
          
          // Update foreign keys in work_type_cost_history
          await queryInterface.sequelize.query(
            `UPDATE work_type_cost_history SET work_type_id = '${newId}' WHERE work_type_id = '${oldId}'`,
            { transaction }
          );
          
          // Update the work type itself
          await queryInterface.sequelize.query(
            `UPDATE work_types SET id = '${newId}' WHERE id = '${oldId}'`,
            { transaction }
          );
        });
      }
      
      console.log('Successfully updated all non-standard UUIDs');
    } catch (error) {
      console.error('Failed to update work type UUIDs:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    console.log('This migration cannot be reverted as it would require the original UUIDs');
  }
};
