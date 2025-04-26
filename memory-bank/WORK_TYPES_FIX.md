# Work Types Migration Fixes

This document outlines the specific issues and fixes related to the work_types table and its related tables.

## Background

The work_types table is a central part of the knowledge base for construction tasks. It has several related tables:

- **work_type_materials**: Maps work types to their required materials
- **work_type_tags**: Stores safety and permit requirements for work types
- **work_type_cost_history**: Tracks cost changes over time with region support

## Issues Encountered

### 1. Table Creation Order

**Problem**: The work_types table creation was failing because it referenced tables that didn't exist yet or had circular dependencies.

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

### 2. ENUM Type Creation

**Problem**: The ENUM type for measurement_type was being created multiple times, causing errors.

**Solution**: Added checks to see if the ENUM type already exists:

```javascript
module.exports = {
  up: async (queryInterface, Sequelize) => {
    return queryInterface.sequelize.transaction(async (transaction) => {
      // Check if ENUM type already exists
      const enumExists = await queryInterface.sequelize.query(
        `SELECT EXISTS (
          SELECT FROM pg_type 
          WHERE typname = 'enum_work_types_measurement_type'
        );`,
        { type: Sequelize.QueryTypes.SELECT, transaction }
      );

      if (!enumExists[0].exists) {
        // Create the ENUM type for measurement types
        await queryInterface.sequelize.query(
          `CREATE TYPE enum_work_types_measurement_type AS ENUM ('area', 'linear', 'quantity');`,
          { transaction }
        );
      }

      // Continue with table creation...
    });
  }
};
```

### 3. Check Constraint Issues

**Problem**: Check constraints were being added multiple times, causing errors.

**Solution**: Used DO blocks with explicit existence checks:

```javascript
await queryInterface.sequelize.query(`
  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM pg_constraint 
      WHERE conname = 'check_suggested_units'
    ) THEN
      ALTER TABLE work_types ADD CONSTRAINT check_suggested_units
      CHECK (
        (measurement_type = 'area' AND suggested_units IN ('sq ft', 'sq yd', 'sq m')) OR
        (measurement_type = 'linear' AND suggested_units IN ('ft', 'in', 'yd', 'm')) OR
        (measurement_type = 'quantity' AND suggested_units IN ('each', 'job', 'set'))
      );
    END IF;
  END $$;
`);
```

### 4. Index Creation Issues

**Problem**: Trigram and vector indexes were being created multiple times.

**Solution**: Added checks for existing indexes:

```javascript
await queryInterface.sequelize.query(`
  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM pg_indexes 
      WHERE indexname = 'idx_work_types_name'
    ) THEN
      CREATE INDEX idx_work_types_name ON work_types USING gin (name gin_trgm_ops);
    END IF;
  END $$;
`);
```

### 5. Composite Unique Index Issues

**Problem**: Composite unique indexes on work_type_materials were failing when run multiple times.

**Solution**: Added checks for existing indexes:

```javascript
await queryInterface.sequelize.query(`
  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM pg_indexes 
      WHERE indexname = 'work_type_materials_unique_product'
    ) THEN
      CREATE UNIQUE INDEX work_type_materials_unique_product 
      ON work_type_materials (work_type_id, product_id);
    END IF;
  END $$;
`);
```

## Direct SQL Fix Script

When migrations failed repeatedly, we created a direct SQL script to fix the database:

```sql
-- Check if pg_trgm extension exists and install if needed
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_extension WHERE extname = 'pg_trgm'
  ) THEN
    CREATE EXTENSION pg_trgm;
  END IF;
END $$;

-- Check if pgvector extension exists and install if needed
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_extension WHERE extname = 'vector'
  ) THEN
    CREATE EXTENSION vector;
  END IF;
END $$;

-- Create ENUM type if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type WHERE typname = 'enum_work_types_measurement_type'
  ) THEN
    CREATE TYPE enum_work_types_measurement_type AS ENUM ('area', 'linear', 'quantity');
  END IF;
END $$;

-- Create work_types table if it doesn't exist
CREATE TABLE IF NOT EXISTS work_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  parent_bucket VARCHAR(100) NOT NULL,
  measurement_type enum_work_types_measurement_type NOT NULL,
  suggested_units VARCHAR(50) NOT NULL,
  name_vec vector(1536),
  unit_cost_material DECIMAL(10, 2),
  unit_cost_labor DECIMAL(10, 2),
  productivity_unit_per_hr DECIMAL(10, 2),
  revision INTEGER DEFAULT 1,
  updated_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add check constraint if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'check_suggested_units'
  ) THEN
    ALTER TABLE work_types ADD CONSTRAINT check_suggested_units
    CHECK (
      (measurement_type = 'area' AND suggested_units IN ('sq ft', 'sq yd', 'sq m')) OR
      (measurement_type = 'linear' AND suggested_units IN ('ft', 'in', 'yd', 'm')) OR
      (measurement_type = 'quantity' AND suggested_units IN ('each', 'job', 'set'))
    );
  END IF;
END $$;

-- Create trigram index if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE indexname = 'idx_work_types_name'
  ) THEN
    CREATE INDEX idx_work_types_name ON work_types USING gin (name gin_trgm_ops);
  END IF;
END $$;

-- Create work_type_materials table if it doesn't exist
CREATE TABLE IF NOT EXISTS work_type_materials (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  work_type_id UUID NOT NULL REFERENCES work_types(id) ON DELETE CASCADE,
  product_id UUID NOT NULL,
  qty_per_unit DECIMAL(10, 2) NOT NULL DEFAULT 1,
  unit VARCHAR(50) NOT NULL DEFAULT 'each',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create unique index on work_type_materials if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE indexname = 'work_type_materials_unique_product'
  ) THEN
    CREATE UNIQUE INDEX work_type_materials_unique_product 
    ON work_type_materials (work_type_id, product_id);
  END IF;
END $$;

-- Create work_type_tags table if it doesn't exist
CREATE TABLE IF NOT EXISTS work_type_tags (
  work_type_id UUID NOT NULL REFERENCES work_types(id) ON DELETE CASCADE,
  tag VARCHAR(100) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (work_type_id, tag)
);

-- Create work_type_cost_history table if it doesn't exist
CREATE TABLE IF NOT EXISTS work_type_cost_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  work_type_id UUID NOT NULL REFERENCES work_types(id) ON DELETE CASCADE,
  region VARCHAR(100) NOT NULL DEFAULT 'default',
  unit_cost_material DECIMAL(10, 2),
  unit_cost_labor DECIMAL(10, 2),
  captured_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add non-negative check constraints if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'check_unit_cost_material_non_negative'
  ) THEN
    ALTER TABLE work_types ADD CONSTRAINT check_unit_cost_material_non_negative
    CHECK (unit_cost_material IS NULL OR unit_cost_material >= 0);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'check_unit_cost_labor_non_negative'
  ) THEN
    ALTER TABLE work_types ADD CONSTRAINT check_unit_cost_labor_non_negative
    CHECK (unit_cost_labor IS NULL OR unit_cost_labor >= 0);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'check_productivity_unit_per_hr_positive'
  ) THEN
    ALTER TABLE work_types ADD CONSTRAINT check_productivity_unit_per_hr_positive
    CHECK (productivity_unit_per_hr IS NULL OR productivity_unit_per_hr > 0);
  END IF;
END $$;
```

## Model Updates

After fixing the database schema, we updated the Sequelize models to match:

```javascript
// Work Type model
module.exports = (sequelize, DataTypes) => {
  const WorkType = sequelize.define('WorkType', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    name: {
      type: DataTypes.STRING(255),
      allowNull: false
    },
    parent_bucket: {
      type: DataTypes.STRING(100),
      allowNull: false
    },
    measurement_type: {
      type: DataTypes.ENUM('area', 'linear', 'quantity'),
      allowNull: false
    },
    suggested_units: {
      type: DataTypes.STRING(50),
      allowNull: false
    },
    name_vec: {
      type: DataTypes.VECTOR(1536),
      allowNull: true
    },
    unit_cost_material: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
      validate: {
        min: 0
      }
    },
    unit_cost_labor: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
      validate: {
        min: 0
      }
    },
    productivity_unit_per_hr: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
      validate: {
        min: 0.01
      }
    },
    revision: {
      type: DataTypes.INTEGER,
      defaultValue: 1
    },
    updated_by: {
      type: DataTypes.UUID,
      allowNull: true
    }
  }, {
    tableName: 'work_types',
    underscored: true
  });

  WorkType.associate = (models) => {
    WorkType.hasMany(models.WorkTypeMaterial, {
      foreignKey: 'work_type_id',
      as: 'materials'
    });
    
    WorkType.hasMany(models.WorkTypeCostHistory, {
      foreignKey: 'work_type_id',
      as: 'costHistory'
    });
  };

  return WorkType;
};
```

## Lessons Learned

1. **Always make migrations idempotent** by checking if objects exist before creating or modifying them
2. **Use transactions** for all schema changes to ensure atomicity
3. **Check for ENUM types** before creating them
4. **Use DO blocks with IF NOT EXISTS checks** for constraints and indexes
5. **Create direct SQL scripts** for emergency fixes when migrations fail
6. **Test migrations** in isolated environments before applying to production
7. **Document migration changes** in comments and separate documentation
8. **Follow one-migration-per-change rule** to prevent complex dependencies
9. **Add detailed logging** to help diagnose issues
10. **Make down migrations safe** by checking for object existence before dropping
