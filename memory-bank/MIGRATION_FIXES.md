# Database Migration Fixes

This document outlines the key migration issues that were fixed and the patterns implemented to ensure smooth database migrations.

## Common Migration Issues

### 1. Non-Idempotent Migrations

**Problem**: Migrations would fail when run multiple times because they didn't check if objects already existed.

**Solution**: Made migrations idempotent by adding existence checks:

```javascript
// Check if table exists before creating
const tableExists = await queryInterface.sequelize.query(
  `SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_name = 'work_types'
  );`,
  { type: Sequelize.QueryTypes.SELECT }
);

if (tableExists[0].exists) {
  console.log('work_types table already exists, skipping creation');
  return; // Exit early if the table already exists
}

// Check if column exists before adding
const columnExists = async (tableName, columnName) => {
  try {
    const tableInfo = await queryInterface.describeTable(tableName);
    return !!tableInfo[columnName];
  } catch (error) {
    return false;
  }
};

if (!(await columnExists('invoices', 'client_id'))) {
  console.log('Adding client_id column to invoices table...');
  await queryInterface.addColumn('invoices', 'client_id', {
    type: Sequelize.UUID,
    allowNull: true,
    references: {
      model: 'clients',
      key: 'id'
    }
  });
}
```

### 2. PostgreSQL Constraint Limitations

**Problem**: PostgreSQL doesn't support `IF NOT EXISTS` syntax for constraints, causing errors when migrations were run multiple times.

**Solution**: Used DO blocks with explicit existence checks:

```javascript
await queryInterface.sequelize.query(`
  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM pg_constraint 
      WHERE conname = 'check_unit_cost_material_non_negative'
    ) THEN
      ALTER TABLE work_types
      ADD CONSTRAINT check_unit_cost_material_non_negative
      CHECK (unit_cost_material IS NULL OR unit_cost_material >= 0);
    END IF;
  END $$;
`);
```

### 3. Migration Order Dependencies

**Problem**: Some migrations depended on others but would run in the wrong order due to timestamp-based sorting.

**Solution**: 
- Moved problematic migrations to _archive directory to prevent execution
- Created direct SQL scripts to fix database issues when migrations fail
- Implemented proper ordering in new migrations

### 4. Schema Evolution Issues

**Problem**: Transitioning from old patterns (assessment_id) to new patterns (project_inspections) caused circular references.

**Solution**: 
- Updated Project model to use condition instead of scope and removed assessment_id attribute
- Implemented Project.hasOne association with ProjectInspection for condition category
- Fixed assessment to job conversion to use the new pattern
- Created migration to safely transition data

```javascript
// Migration to transition from assessment_id to project_inspections
module.exports = {
  up: async (queryInterface, Sequelize) => {
    return queryInterface.sequelize.transaction(async (transaction) => {
      // Get all projects with assessment_id
      const projects = await queryInterface.sequelize.query(
        `SELECT id, assessment_id FROM projects WHERE assessment_id IS NOT NULL`,
        { type: Sequelize.QueryTypes.SELECT, transaction }
      );

      // For each project, create a project_inspection with category='condition'
      for (const project of projects) {
        // Get the assessment project's scope
        const assessment = await queryInterface.sequelize.query(
          `SELECT scope FROM projects WHERE id = :id`,
          { 
            replacements: { id: project.assessment_id },
            type: Sequelize.QueryTypes.SELECT,
            transaction
          }
        );

        if (assessment.length > 0 && assessment[0].scope) {
          // Create project_inspection with the scope data
          await queryInterface.sequelize.query(
            `INSERT INTO project_inspections (
              id, project_id, category, content, created_at, updated_at
            ) VALUES (
              uuid_generate_v4(), :projectId, 'condition', 
              :content::jsonb, NOW(), NOW()
            )`,
            { 
              replacements: { 
                projectId: project.id,
                content: JSON.stringify({ text: assessment[0].scope })
              },
              type: Sequelize.QueryTypes.INSERT,
              transaction
            }
          );
        }
      }

      // Remove assessment_id column (only after data is migrated)
      await queryInterface.removeColumn('projects', 'assessment_id', { transaction });
      
      console.log('Successfully migrated from assessment_id to project_inspections');
    });
  },

  down: async (queryInterface, Sequelize) => {
    // This migration is not reversible as it involves data transformation
    console.log('This migration cannot be reversed');
  }
};
```

### 5. View Dependencies

**Problem**: Database views would break when referenced columns were modified.

**Solution**: Implemented transaction-based view handling with dependency detection:

```javascript
// Transaction-based approach to dropping and recreating views
module.exports = {
  up: async (queryInterface, Sequelize) => {
    return queryInterface.sequelize.transaction(async (transaction) => {
      // First drop the view that depends on the column
      await queryInterface.sequelize.query(
        'DROP VIEW IF EXISTS client_view;',
        { transaction }
      );

      // Now alter the column type
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
  }
};
```

## Specific Migration Fixes

### 1. Fixed scope-to-condition Migration

**Problem**: The migration to rename 'scope' to 'condition' in the projects table was failing because it didn't handle existing data properly.

**Solution**: Created a new migration that safely renames the column and updates all references:

```javascript
module.exports = {
  up: async (queryInterface, Sequelize) => {
    return queryInterface.sequelize.transaction(async (transaction) => {
      // Check if condition column already exists
      const tableInfo = await queryInterface.describeTable('projects');
      
      if (!tableInfo.condition && tableInfo.scope) {
        // Rename scope to condition
        await queryInterface.renameColumn('projects', 'scope', 'condition', { transaction });
        console.log('Renamed scope column to condition');
      } else if (tableInfo.condition && tableInfo.scope) {
        // Both columns exist, copy data from scope to condition
        await queryInterface.sequelize.query(
          `UPDATE projects SET condition = scope WHERE condition IS NULL AND scope IS NOT NULL`,
          { transaction }
        );
        // Then drop the scope column
        await queryInterface.removeColumn('projects', 'scope', { transaction });
        console.log('Copied data from scope to condition and removed scope column');
      } else if (tableInfo.condition) {
        console.log('Condition column already exists, no action needed');
      } else {
        console.log('Neither scope nor condition column exists, creating condition column');
        await queryInterface.addColumn('projects', 'condition', {
          type: Sequelize.TEXT,
          allowNull: true
        }, { transaction });
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    return queryInterface.sequelize.transaction(async (transaction) => {
      const tableInfo = await queryInterface.describeTable('projects');
      
      if (tableInfo.condition && !tableInfo.scope) {
        await queryInterface.renameColumn('projects', 'condition', 'scope', { transaction });
      }
    });
  }
};
```

### 2. Fixed work_types Table Creation Order

**Problem**: The work_types table creation was failing because it referenced tables that didn't exist yet.

**Solution**: Reordered migrations and added existence checks:

```javascript
module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Check if tables exist before creating relationships
    const tableExists = async (tableName) => {
      const result = await queryInterface.sequelize.query(
        `SELECT EXISTS (
          SELECT FROM information_schema.tables 
          WHERE table_name = '${tableName}'
        );`,
        { type: Sequelize.QueryTypes.SELECT }
      );
      return result[0].exists;
    };

    return queryInterface.sequelize.transaction(async (transaction) => {
      // Create work_types table first if it doesn't exist
      if (!(await tableExists('work_types'))) {
        await queryInterface.createTable('work_types', {
          id: {
            type: Sequelize.UUID,
            defaultValue: Sequelize.UUIDV4,
            primaryKey: true
          },
          // ... other columns
        }, { transaction });
      }

      // Then create dependent tables
      if (!(await tableExists('work_type_materials'))) {
        await queryInterface.createTable('work_type_materials', {
          // ... columns
          work_type_id: {
            type: Sequelize.UUID,
            references: {
              model: 'work_types',
              key: 'id'
            },
            onUpdate: 'CASCADE',
            onDelete: 'CASCADE'
          },
          // ... other columns
        }, { transaction });
      }
    });
  }
};
```

### 3. Fixed client_view Migration

**Problem**: The client_view migration was failing because it depended on non-existent modules.

**Solution**: Simplified the migration to use direct SQL without external dependencies:

```javascript
module.exports = {
  up: async (queryInterface, Sequelize) => {
    return queryInterface.sequelize.transaction(async (transaction) => {
      // Check if view exists
      const viewExists = await queryInterface.sequelize.query(
        `SELECT EXISTS (
          SELECT FROM information_schema.views 
          WHERE table_name = 'client_view'
        );`,
        { type: Sequelize.QueryTypes.SELECT, transaction }
      );

      if (viewExists[0].exists) {
        // Drop the view if it exists
        await queryInterface.sequelize.query(
          'DROP VIEW IF EXISTS client_view;',
          { transaction }
        );
      }

      // Create the view with a simple definition
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
    return queryInterface.sequelize.query('DROP VIEW IF EXISTS client_view;');
  }
};
```

## Best Practices for Future Migrations

1. **Always make migrations idempotent** by checking if objects exist before creating or modifying them
2. **Use transactions** for all schema changes to ensure atomicity
3. **Handle view dependencies** by dropping and recreating views within the same transaction
4. **Test migrations** in isolated environments before applying to production
5. **Document migration changes** in comments and separate documentation
6. **Create direct SQL scripts** for emergency fixes when migrations fail
7. **Follow one-migration-per-change rule** to prevent complex dependencies
8. **Add detailed logging** to help diagnose issues
9. **Make down migrations safe** by checking for object existence before dropping
10. **Use DO blocks with IF NOT EXISTS checks** for constraints in PostgreSQL
