'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      // First check if the table exists
      const tableInfo = await queryInterface.describeTable('products');
      
      // Only add the column if it doesn't already exist
      if (!tableInfo.unit) {
        await queryInterface.addColumn('products', 'unit', {
          type: Sequelize.STRING,
          allowNull: true,
          defaultValue: 'each'
        });
        
        // Update existing products to use the default unit
        await queryInterface.sequelize.query(
          'UPDATE products SET unit = \'each\' WHERE unit IS NULL'
        );
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
      await queryInterface.removeColumn('products', 'unit');
      return Promise.resolve();
    } catch (error) {
      return Promise.reject(error);
    }
  }
};
