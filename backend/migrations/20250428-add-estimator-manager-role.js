'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Add estimator_manager role to enum_users_role if it doesn't exist already
      await queryInterface.sequelize.query(`
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_enum
            WHERE enumtypid = 'enum_users_role'::regtype
              AND enumlabel = 'estimator_manager'
          ) THEN
            ALTER TYPE "enum_users_role" ADD VALUE 'estimator_manager' AFTER 'user';
          END IF;
        END$$;
      `);
      console.log('Successfully processed estimator_manager role addition');
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
