'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Add 'estimator_manager' to the enum_users_role type
      await queryInterface.sequelize.query(`
        ALTER TYPE "enum_users_role" ADD VALUE 'estimator_manager' AFTER 'user';
      `);
      
      console.log('Successfully added estimator_manager role to enum_users_role');
    } catch (error) {
      console.error('Failed to add estimator_manager role:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    try {
      // Unfortunately, PostgreSQL doesn't support removing values from an enum type
      // We would need to create a new type, update the column, and drop the old type
      console.log('Cannot remove enum value in PostgreSQL. No action taken in down migration.');
    } catch (error) {
      console.error('Error in down migration:', error);
      throw error;
    }
  }
};
