'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Add composite unique index on work_type_id and product_id columns
      await queryInterface.addIndex('work_type_materials', ['work_type_id', 'product_id'], {
        name: 'work_type_materials_work_type_id_product_id_unique',
        unique: true
      });
      
      console.log('Successfully added composite unique index on work_type_materials (work_type_id, product_id)');
    } catch (error) {
      // If the index already exists, log and continue
      if (error.name === 'SequelizeUniqueConstraintError' || 
          (error.message && error.message.includes('already exists'))) {
        console.log('Composite unique index already exists, skipping');
        return;
      }
      
      console.error('Failed to add composite unique index:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    try {
      // Remove the composite unique index
      await queryInterface.removeIndex('work_type_materials', 'work_type_materials_work_type_id_product_id_unique');
      
      console.log('Successfully removed composite unique index from work_type_materials');
    } catch (error) {
      console.error('Error removing composite unique index:', error);
      throw error;
    }
  }
};
