'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    const qi = queryInterface;
    try {
      // First, check if the table exists
      const [tableExists] = await qi.sequelize.query(
        `SELECT 1 FROM information_schema.tables
         WHERE table_name = 'estimate_item_photos'`
      );

      if (tableExists.length === 0) {
        console.log('Table estimate_item_photos does not exist, skipping migration');
        return;
      }

      // Check the current data type of the photo_type column
      const [columnInfo] = await qi.sequelize.query(
        `SELECT data_type, udt_name FROM information_schema.columns
         WHERE table_name = 'estimate_item_photos' AND column_name = 'photo_type'`
      );

      if (columnInfo.length === 0) {
        console.log('Column photo_type does not exist, skipping migration');
        return;
      }

      // If the column is already TEXT type, we don't need to do anything
      if (columnInfo[0].data_type === 'text') {
        console.log('Column photo_type is already TEXT type, skipping migration');
        return;
      }

      // If we get here, we need to modify the column
      await qi.sequelize.transaction(async (t) => {
        // 1. Create a temporary column with text type
        await qi.sequelize.query(
          `ALTER TABLE estimate_item_photos ADD COLUMN temp_photo_type TEXT`,
          { transaction: t }
        );

        // 2. Copy data from enum column to text column
        await qi.sequelize.query(
          `UPDATE estimate_item_photos SET temp_photo_type = photo_type::TEXT`,
          { transaction: t }
        );

        // 3. Drop the enum column
        await qi.sequelize.query(
          `ALTER TABLE estimate_item_photos DROP COLUMN photo_type`,
          { transaction: t }
        );

        // 4. Rename the text column to the original name
        await qi.sequelize.query(
          `ALTER TABLE estimate_item_photos RENAME COLUMN temp_photo_type TO photo_type`,
          { transaction: t }
        );

        // 5. Add NOT NULL constraint and default value
        await qi.sequelize.query(
          `ALTER TABLE estimate_item_photos ALTER COLUMN photo_type SET NOT NULL`,
          { transaction: t }
        );

        await qi.sequelize.query(
          `ALTER TABLE estimate_item_photos ALTER COLUMN photo_type SET DEFAULT 'progress'`,
          { transaction: t }
        );

        // 6. Add check constraint to ensure valid values
        await qi.sequelize.query(
          `ALTER TABLE estimate_item_photos ADD CONSTRAINT check_photo_type
           CHECK (photo_type IN ('progress', 'completed', 'issue', 'material', 'other'))`,
          { transaction: t }
        );

        console.log('Successfully converted photo_type column from enum to text');
      });
    } catch (error) {
      console.error('Error in fix-estimate-item-photos-enum migration:', error.message);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    const qi = queryInterface;
    try {
      // First, check if the table exists
      const [tableExists] = await qi.sequelize.query(
        `SELECT 1 FROM information_schema.tables
         WHERE table_name = 'estimate_item_photos'`
      );

      if (tableExists.length === 0) {
        console.log('Table estimate_item_photos does not exist, skipping down migration');
        return;
      }

      // Check if the column exists and is text type
      const [columnInfo] = await qi.sequelize.query(
        `SELECT data_type FROM information_schema.columns
         WHERE table_name = 'estimate_item_photos' AND column_name = 'photo_type'`
      );

      if (columnInfo.length === 0 || columnInfo[0].data_type !== 'text') {
        console.log('Column photo_type is not TEXT type, skipping down migration');
        return;
      }

      await qi.sequelize.transaction(async (t) => {
        // 1. Drop the check constraint if it exists
        await qi.sequelize.query(
          `ALTER TABLE estimate_item_photos DROP CONSTRAINT IF EXISTS check_photo_type`,
          { transaction: t }
        );

        // 2. Create the enum type if it doesn't exist
        await qi.sequelize.query(
          `DO $$
           BEGIN
             IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'estimate_item_photo_type') THEN
               CREATE TYPE estimate_item_photo_type AS ENUM ('progress', 'completed', 'issue', 'material', 'other');
             END IF;
           END
           $$`,
          { transaction: t }
        );

        // 3. Create a temporary column with enum type
        await qi.sequelize.query(
          `ALTER TABLE estimate_item_photos ADD COLUMN temp_photo_type estimate_item_photo_type`,
          { transaction: t }
        );

        // 4. Copy data from text column to enum column
        await qi.sequelize.query(
          `UPDATE estimate_item_photos SET temp_photo_type = photo_type::estimate_item_photo_type`,
          { transaction: t }
        );

        // 5. Drop the text column
        await qi.sequelize.query(
          `ALTER TABLE estimate_item_photos DROP COLUMN photo_type`,
          { transaction: t }
        );

        // 6. Rename the enum column to the original name
        await qi.sequelize.query(
          `ALTER TABLE estimate_item_photos RENAME COLUMN temp_photo_type TO photo_type`,
          { transaction: t }
        );

        // 7. Add NOT NULL constraint and default value
        await qi.sequelize.query(
          `ALTER TABLE estimate_item_photos ALTER COLUMN photo_type SET NOT NULL`,
          { transaction: t }
        );

        await qi.sequelize.query(
          `ALTER TABLE estimate_item_photos ALTER COLUMN photo_type SET DEFAULT 'progress'`,
          { transaction: t }
        );

        console.log('Successfully converted photo_type column from text back to enum');
      });
    } catch (error) {
      console.error('Error in fix-estimate-item-photos-enum down migration:', error.message);
      throw error;
    }
  }
};
