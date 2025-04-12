'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Step 1: Find all photos linked to inspections
    const [photos] = await queryInterface.sequelize.query(`
      SELECT p.id, p.photo_type, p.inspection_id, i.category 
      FROM project_photos p 
      LEFT JOIN project_inspections i ON p.inspection_id = i.id 
      WHERE p.inspection_id IS NOT NULL
    `);

    // Step 2: Unlink photos that don't meet the new criteria
    for (const photo of photos) {
      if (photo.photo_type !== 'condition' || photo.category !== 'condition') {
        await queryInterface.sequelize.query(
          `UPDATE project_photos SET inspection_id = NULL WHERE id = :id`,
          {
            replacements: { id: photo.id },
            type: Sequelize.QueryTypes.UPDATE
          }
        );
      }
    }
  },

  down: async (queryInterface, Sequelize) => {
    // No down migration needed as we can't determine the original inspection_id values
    console.log('Skipping down migration for photo cleanup');
  }
};