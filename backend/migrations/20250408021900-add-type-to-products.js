'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Check if table exists
      const tableExists = await queryInterface.showAllTables()
        .then(tables => tables.includes('products'));
      
      if (!tableExists) {
        console.log('Products table does not exist yet. Skipping migration.');
        return;
      }
      
      // Check if type column already exists
      const columns = await queryInterface.describeTable('products');
      if (columns.type) {
        console.log('Type column already exists in products table. Skipping migration.');
        return;
      }
      
      // Create enum if it doesn't exist
      await queryInterface.sequelize.query(`
        DO $$
        BEGIN
          IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_products_type') THEN
            CREATE TYPE enum_products_type AS ENUM ('product', 'service');
          END IF;
        END
        $$;
      `);
      
      // Add the type column
      await queryInterface.addColumn('products', 'type', {
        type: Sequelize.ENUM('product', 'service'),
        defaultValue: 'service',
        allowNull: false
      });
      
      console.log('Successfully added type column to products table.');
      
    } catch (error) {
      console.error('Migration failed:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    try {
      // Check if table exists
      const tableExists = await queryInterface.showAllTables()
        .then(tables => tables.includes('products'));
      
      if (!tableExists) {
        console.log('Products table does not exist. Skipping down migration.');
        return;
      }
      
      // Check if type column exists
      const columns = await queryInterface.describeTable('products');
      if (!columns.type) {
        console.log('Type column does not exist in products table. Skipping down migration.');
        return;
      }
      
      // Remove the type column
      await queryInterface.removeColumn('products', 'type');
      
      // Drop the enum type if it exists and is not in use elsewhere
      await queryInterface.sequelize.query(`
        DO $$
        BEGIN
          IF EXISTS (
            SELECT 1 FROM pg_type 
            WHERE typname = 'enum_products_type' 
            AND NOT EXISTS (
              SELECT 1 FROM pg_depend 
              WHERE objid = 'enum_products_type'::regtype::oid 
              AND deptype = 'n'
            )
          ) THEN
            DROP TYPE enum_products_type;
          END IF;
        END
        $$;
      `);
      
      console.log('Successfully removed type column from products table.');
      
    } catch (error) {
      console.error('Down migration failed:', error);
      // Don't throw in down migration to avoid blocking other migrations
    }
  }
};
