'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const transaction = await queryInterface.sequelize.transaction();
    
    try {
      // Add CHECK constraint to ensure productivity_unit_per_hr is non-negative
      await queryInterface.sequelize.query(
        `ALTER TABLE work_types ADD CONSTRAINT check_productivity_non_negative 
         CHECK (productivity_unit_per_hr IS NULL OR productivity_unit_per_hr >= 0);`,
        { transaction }
      );
      
      await transaction.commit();
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  },

  down: async (queryInterface, Sequelize) => {
    const transaction = await queryInterface.sequelize.transaction();
    
    try {
      // Remove the CHECK constraint
      await queryInterface.sequelize.query(
        `ALTER TABLE work_types DROP CONSTRAINT IF EXISTS check_productivity_non_negative;`,
        { transaction }
      );
      
      await transaction.commit();
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }
};
