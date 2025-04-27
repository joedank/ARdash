'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Check if index already exists
      const [results] = await queryInterface.sequelize.query(
        `SELECT 1 FROM pg_indexes WHERE indexname = 'work_type_materials_product_id_idx'`
      );
      
      if (results.length === 0) {
        // Add index on product_id column in work_type_materials table
        await queryInterface.addIndex('work_type_materials', ['product_id'], {
          name: 'work_type_materials_product_id_idx'
        });
        console.log('Successfully added index on work_type_materials.product_id');
      } else {
        console.log('Index work_type_materials_product_id_idx already exists, skipping creation');
      }
    } catch (error) {
      console.error('Failed to add index on work_type_materials.product_id:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    try {
      // Remove the index
      await queryInterface.removeIndex('work_type_materials', 'work_type_materials_product_id_idx');
      
      console.log('Successfully removed index on work_type_materials.product_id');
    } catch (error) {
      console.error('Error removing index on work_type_materials.product_id:', error);
      throw error;
    }
  }
};
