'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Get all measurement type inspections
    const [inspections] = await queryInterface.sequelize.query(
      `SELECT id, content FROM project_inspections WHERE category = 'measurements'`
    );
    
    // Update each inspection to add the description field if it doesn't exist
    for (const inspection of inspections) {
      const content = inspection.content;
      if (!content.description) {
        content.description = ''; // Add empty description field
        await queryInterface.sequelize.query(
          `UPDATE project_inspections SET content = :content WHERE id = :id`,
          {
            replacements: { 
              content: JSON.stringify(content),
              id: inspection.id 
            },
            type: Sequelize.QueryTypes.UPDATE
          }
        );
      }
    }
  },

  down: async (queryInterface, Sequelize) => {
    // This migration adds a field to JSON data, so down migration would remove it
    // Get all measurement type inspections
    const [inspections] = await queryInterface.sequelize.query(
      `SELECT id, content FROM project_inspections WHERE category = 'measurements'`
    );
    
    // Remove description field from each inspection
    for (const inspection of inspections) {
      const content = inspection.content;
      if (content.description !== undefined) {
        delete content.description;
        await queryInterface.sequelize.query(
          `UPDATE project_inspections SET content = :content WHERE id = :id`,
          {
            replacements: { 
              content: JSON.stringify(content),
              id: inspection.id 
            },
            type: Sequelize.QueryTypes.UPDATE
          }
        );
      }
    }
  }
};