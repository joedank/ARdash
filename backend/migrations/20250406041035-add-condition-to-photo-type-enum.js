'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    // Add 'condition' to the existing ENUM type in PostgreSQL
    await queryInterface.sequelize.query(`ALTER TYPE "enum_project_photos_photo_type" ADD VALUE 'condition';`);
  },

  async down (queryInterface, Sequelize) {
    // Removing an ENUM value is complex and potentially destructive if the value is in use.
    // It often requires updating rows using the value first, then removing it.
    // For simplicity, we'll make the down migration a no-op or log a warning.
    // If rollback is truly needed, manual database intervention is safer.
    console.log(`Rolling back 'add-condition-to-photo-type-enum' migration requires manual steps.`);
    console.log(`You may need to update rows using 'condition' before attempting to remove it from the ENUM.`);
    // Example (requires checking if 'condition' is in use first):
    // await queryInterface.sequelize.query(`ALTER TYPE "enum_project_photos_photo_type" RENAME TO "enum_project_photos_photo_type_old";`);
    // await queryInterface.sequelize.query(`CREATE TYPE "enum_project_photos_photo_type" AS ENUM('before', 'after', 'receipt', 'assessment');`);
    // await queryInterface.sequelize.query(`ALTER TABLE "project_photos" ALTER COLUMN "photo_type" TYPE "enum_project_photos_photo_type" USING "photo_type"::text::"enum_project_photos_photo_type";`);
    // await queryInterface.sequelize.query(`DROP TYPE "enum_project_photos_photo_type_old";`);
    return Promise.resolve(); // Indicate successful (no-op) rollback
  }
};
