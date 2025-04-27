# Database View Management

## Overview

PostgreSQL views can create dependencies that prevent schema changes to referenced tables and columns. The `ViewManager` utility provides a solution for safely managing schema changes when views are involved.

## Problem

When trying to alter a column that's referenced by a view, PostgreSQL will raise an error:

```
ERROR: cannot alter type of a column used by a view or rule
DETAIL: rule _RETURN on view client_view depends on column "payment_terms"
```

This happens because PostgreSQL doesn't automatically update views when the underlying tables change.

## Solution

The `ViewManager` utility implements the "Transaction-Based View Management Pattern" to handle these dependencies:

1. Identify views that depend on the column being modified
2. Temporarily drop those views
3. Make the required schema changes
4. Recreate the views with their original definitions
5. All within a single transaction for atomicity

## Usage

### Example: Altering a Column Type

```javascript
// In a migration file
const ViewManager = require('../src/utils/ViewManager');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    return queryInterface.sequelize.transaction(async (transaction) => {
      const viewManager = new ViewManager(queryInterface);
      
      // Safely alter the column type, handling any dependent views
      await viewManager.safelyAlterColumnType(
        'clients',       // table name
        'payment_terms', // column name
        'VARCHAR(255)',  // new type
        transaction      // transaction object
      );
      
      return Promise.resolve();
    });
  },
  
  down: async (queryInterface, Sequelize) => {
    // Similar approach for downgrade...
  }
};
```

### Working with Individual Views

You can also work with views directly:

```javascript
// Drop and recreate a specific view
await viewManager.dropAndRecreateView(
  'client_view',                  // view name
  viewDefinitions.client_view,    // view definition
  transaction                     // transaction object
);

// Get dependent views for a table
const views = await viewManager.getDependentViews('clients');

// Get view definition
const definition = await viewManager.getViewDefinition('client_view');
```

## View Definitions Registry

To maintain consistency, view definitions are stored in a central registry:

```javascript
// src/config/viewDefinitions.js
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
  
  // Add other view definitions as needed
};
```

This ensures that all migrations use the same view definitions when recreating views.

## Checking for Dependencies

Before making schema changes, you can check if columns are used in views:

```javascript
const hasViewDependencies = await viewManager.checkColumnUsedInViews(
  'clients',       // table name
  'payment_terms'  // column name
);

if (hasViewDependencies) {
  console.log('This column is used in one or more views');
}
```

## Best Practices

1. **Always use transactions** when modifying schema with view dependencies
2. **Keep view definitions in the registry** to ensure consistency
3. **Check for dependencies before making changes** to avoid unexpected errors
4. **Update the view registry** when view definitions change
5. **Consider view dependencies** when planning database changes

## Technical Details

The `ViewManager` uses PostgreSQL system catalogs to identify view dependencies:

- `pg_depend`: Tracks dependencies between database objects
- `pg_rewrite`: Stores view query rules
- `pg_class`: Stores database object information
- `pg_attribute`: Stores column information
- `pg_get_viewdef()`: Gets the SQL definition of a view

These PostgreSQL internals allow the utility to accurately identify which views depend on specific tables and columns.
