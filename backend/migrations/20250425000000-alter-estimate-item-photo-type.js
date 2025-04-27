'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.sequelize.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_estimate_item_photos_photo_type') THEN
          ALTER TYPE estimate_item_photo_type RENAME TO enum_estimate_item_photos_photo_type;
        END IF;
      END$$;
    `);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.sequelize.query(`
      DO $$
      BEGIN
        IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_estimate_item_photos_photo_type') THEN
          ALTER TYPE enum_estimate_item_photos_photo_type RENAME TO estimate_item_photo_type;
        END IF;
      END$$;
    `);
  }
};
