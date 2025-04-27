'use strict';

/**
 * View definitions registry for consistent recreation of views
 * Each view is defined as a SQL CREATE OR REPLACE VIEW statement
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

  // Add other view definitions here as needed
};

module.exports = viewDefinitions;
