'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Using a transaction to ensure all operations succeed or fail together
    return queryInterface.sequelize.transaction(async (transaction) => {
      // First drop the view that depends on the column
      await queryInterface.sequelize.query(
        'DROP VIEW IF EXISTS client_view;',
        { transaction }
      );
      
      // Now alter the column type (since it's already nullable with no default)
      await queryInterface.sequelize.query(
        'ALTER TABLE "clients" ALTER COLUMN "payment_terms" TYPE TEXT;',
        { transaction }
      );
      
      // Recreate the view with the exact same definition
      await queryInterface.sequelize.query(
        `CREATE OR REPLACE VIEW client_view AS
         SELECT id,
           display_name AS name,
           company,
           email,
           phone,
           payment_terms,
           default_tax_rate,
           default_currency,
           notes,
           is_active,
           client_type,
           created_at,
           updated_at
         FROM clients;`,
        { transaction }
      );
    });
  },
  
  down: async (queryInterface, Sequelize) => {
    // Revert changes in a transaction
    return queryInterface.sequelize.transaction(async (transaction) => {
      // Drop the view
      await queryInterface.sequelize.query(
        'DROP VIEW IF EXISTS client_view;',
        { transaction }
      );
      
      // Change column back to VARCHAR
      await queryInterface.sequelize.query(
        'ALTER TABLE "clients" ALTER COLUMN "payment_terms" TYPE VARCHAR(255);',
        { transaction }
      );
      
      // Recreate the view
      await queryInterface.sequelize.query(
        `CREATE OR REPLACE VIEW client_view AS
         SELECT id,
           display_name AS name,
           company,
           email,
           phone,
           payment_terms,
           default_tax_rate,
           default_currency,
           notes,
           is_active,
           client_type,
           created_at,
           updated_at
         FROM clients;`,
        { transaction }
      );
    });
  }
};