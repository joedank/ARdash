'use strict';

/**
 * Registry of all database view definitions for migrations and schema management
 */
const viewDefinitions = {
  client_view: `
    CREATE OR REPLACE VIEW client_view AS
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
    FROM clients;
  `,
  
  // Add more view definitions here as needed
};

module.exports = viewDefinitions;