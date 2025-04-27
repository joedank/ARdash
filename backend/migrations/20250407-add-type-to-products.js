'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      // First check if the table exists
      const tableInfo = await queryInterface.describeTable('products');
      
      // Only add the column if it doesn't already exist
      if (!tableInfo.type) {
        await queryInterface.addColumn('products', 'type', {
          type: Sequelize.ENUM('product', 'service'),
          defaultValue: 'service',
          allowNull: false
        });
        
        // Add an index on the new column
        await queryInterface.addIndex('products', ['type']);
      }
      
      return Promise.resolve();
    } catch (error) {
      // If the table doesn't exist yet, we can safely ignore the error
      // as the column will be created when the table is created
      if (error.name === 'SequelizeDatabaseError' && error.message.includes('relation "products" does not exist')) {
        return Promise.resolve();
      }
      return Promise.reject(error);
    }
  },
  
  down: async (queryInterface) => {
    try {
      // Remove the column in case of rollback
      await queryInterface.removeColumn('products', 'type');
      // Remove the ENUM type
      await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_products_type";');
      return Promise.resolve();
    } catch (error) {
      return Promise.reject(error);
    }
  }
};
