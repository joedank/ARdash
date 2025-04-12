'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      const columns = await queryInterface.describeTable('products').catch(() => ({})); // Handle case where table might not exist yet

      // Only proceed if the 'type' column actually exists
      if (columns.type) {
        console.log("Found 'type' column in products table. Proceeding with cleanup...");

        // Remove default constraint if it exists
        try {
          await queryInterface.sequelize.query(`
            ALTER TABLE products ALTER COLUMN type DROP DEFAULT;
          `);
        } catch (e) {
          console.warn("Could not drop default on 'type' column, maybe it doesn't exist?");
        }

        // Convert to varchar temporarily to allow deletion/update
        await queryInterface.sequelize.query(`
          ALTER TABLE products ALTER COLUMN type TYPE varchar(255);
        `);

        // Delete all products where type is 'service'
        await queryInterface.sequelize.query(`
          DELETE FROM products WHERE type = 'service';
        `);

        // Set any remaining NULL or non-product types to 'product'
        await queryInterface.sequelize.query(`
          UPDATE products SET type = 'product'
          WHERE type IS NULL OR type != 'product';
        `);

        // Drop the enum type if it exists
        await queryInterface.sequelize.query(`
          DO $$
          BEGIN
            IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_products_type') THEN
              DROP TYPE enum_products_type;
            END IF;
          END
          $$;
        `);

        // Create new enum type
        await queryInterface.sequelize.query(`
          CREATE TYPE enum_products_type AS ENUM ('product');
        `);

        // Convert the column to the enum type
        await queryInterface.sequelize.query(`
          ALTER TABLE products
          ALTER COLUMN type TYPE enum_products_type
          USING type::enum_products_type;
        `);

        // Set the default value
        await queryInterface.sequelize.query(`
          ALTER TABLE products
          ALTER COLUMN type SET DEFAULT 'product'::enum_products_type;
        `);

      } else {
        console.log("'type' column does not exist in products table yet. Skipping service removal logic.");
        // The 'type' column will be added correctly by a later migration.
      }

    } catch (error) {
      console.error('Migration failed:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    // Reverting this is complex as it depends on whether the 'up' logic actually ran.
    // For simplicity and robustness, we'll ensure the original state (product, service enum) exists.
    try {
       const columns = await queryInterface.describeTable('products').catch(() => ({}));

       if (columns.type) {
          console.log("Attempting to revert 'remove-services-from-products' migration...");
          // Remove default constraint
          try {
             await queryInterface.sequelize.query(`
               ALTER TABLE products ALTER COLUMN type DROP DEFAULT;
             `);
          } catch(e) { console.warn("Could not drop default during revert."); }

          // Convert to varchar temporarily
          await queryInterface.sequelize.query(`
            ALTER TABLE products
            ALTER COLUMN type TYPE varchar(255)
            USING type::text;
          `);

          // Drop the restricted enum type
          await queryInterface.sequelize.query(`
            DROP TYPE IF EXISTS enum_products_type;
          `);

          // Create original enum type
          await queryInterface.sequelize.query(`
            CREATE TYPE enum_products_type AS ENUM ('product', 'service');
          `);

          // Convert back to enum type (defaulting existing to 'product')
          await queryInterface.sequelize.query(`
            ALTER TABLE products
            ALTER COLUMN type TYPE enum_products_type
            USING 'product'::enum_products_type;
          `);

          // Restore original default (assuming it was 'service', adjust if needed)
          await queryInterface.sequelize.query(`
            ALTER TABLE products
            ALTER COLUMN type SET DEFAULT 'service'::enum_products_type;
          `);
       } else {
          console.log("'type' column does not exist. Skipping revert logic for 'remove-services-from-products'.");
       }
    } catch (error) {
      console.error('Migration reversal failed:', error);
      // Avoid throwing error in down migration
    }
  }
};
