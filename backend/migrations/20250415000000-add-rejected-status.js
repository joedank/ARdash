'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    try {
      // Add 'rejected' value to the enum_projects_status type only if it doesn't exist
      await queryInterface.sequelize.query(`
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_enum
            WHERE enumtypid = 'enum_projects_status'::regtype
              AND enumlabel = 'rejected'
          ) THEN
            ALTER TYPE enum_projects_status ADD VALUE 'rejected';
          END IF;
        END$$;
      `);
      
      console.log('Successfully added "rejected" to enum_projects_status');
    } catch (error) {
      console.error('Error adding "rejected" to enum_projects_status:', error);
      throw error;
    }
  },

  async down (queryInterface, Sequelize) {
    // Note: PostgreSQL doesn't support removing enum values directly
    // To reverse this, we would need to:
    // 1. Create a new enum without 'rejected'
    // 2. Update the column to use the new enum
    // 3. Drop the old enum
    // This is a complex operation and may require manual intervention
    console.log('WARNING: Removing enum values is not directly supported in PostgreSQL.');
    console.log('To reverse this migration, you may need to recreate the enum type without the "rejected" value.');
  }
};
