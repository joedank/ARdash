'use strict';
const { v4: uuidv4 } = require('uuid');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Check if we already have products in the table
    const productCount = await queryInterface.sequelize.query(
      'SELECT COUNT(*) FROM products;',
      { type: queryInterface.sequelize.QueryTypes.SELECT }
    );
    
    // Only add sample products if the table is empty
    if (parseInt(productCount[0].count) === 0) {
      const now = new Date();
      
      return queryInterface.bulkInsert('products', [
        {
          id: uuidv4(),
          name: 'Standard Inspection',
          description: 'Complete inspection of the property including structure, systems, and components.',
          price: 299.99,
          tax_rate: 7.5,
          is_active: true,
          type: 'service',
          created_at: now,
          updated_at: now
        },
        {
          id: uuidv4(),
          name: 'Detailed Assessment',
          description: 'In-depth assessment including thermal imaging and detailed report with recommendations.',
          price: 499.99,
          tax_rate: 7.5,
          is_active: true,
          type: 'service',
          created_at: now,
          updated_at: now
        },
        {
          id: uuidv4(),
          name: 'Moisture Detection Service',
          description: 'Specialized service to identify hidden moisture and potential water damage.',
          price: 199.99,
          tax_rate: 7.5,
          is_active: true,
          type: 'service',
          created_at: now,
          updated_at: now
        },
        {
          id: uuidv4(),
          name: 'Moisture Meter',
          description: 'Professional-grade moisture meter for detecting moisture levels in various materials.',
          price: 149.99,
          tax_rate: 7.5,
          is_active: true,
          type: 'product',
          created_at: now,
          updated_at: now
        },
        {
          id: uuidv4(),
          name: 'Dehumidifier Rental',
          description: 'High-capacity dehumidifier rental for drying out spaces after water damage.',
          price: 75.00,
          tax_rate: 7.5,
          is_active: true,
          type: 'product',
          created_at: now,
          updated_at: now
        }
      ]);
    }
    
    return Promise.resolve();
  },

  down: async (queryInterface, Sequelize) => {
    // Remove all sample products in case of rollback
    return queryInterface.bulkDelete('products', null, {});
  }
};
