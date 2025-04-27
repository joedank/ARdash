#!/bin/bash
set -e

echo "This script will fix the database issues by manually creating the work_types table and enabling the pgvector extension."

# Enable required PostgreSQL extensions
echo "Enabling required PostgreSQL extensions..."
docker exec -i management-db-1 psql -U postgres -d management_db << EOF
-- Enable uuid-ossp extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pgvector extension for vector operations
CREATE EXTENSION IF NOT EXISTS "vector";
EOF

# Create work_types table and related tables
echo "Creating work_types table and related tables..."
docker exec -i management-db-1 psql -U postgres -d management_db << EOF
-- Create enum for measurement_type if it doesn't exist
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_work_types_measurement_type') THEN
        CREATE TYPE enum_work_types_measurement_type AS ENUM ('area', 'linear', 'quantity');
    END IF;
END \$\$;

-- Create work_types table if it doesn't exist
CREATE TABLE IF NOT EXISTS work_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    parent_bucket VARCHAR(100) NOT NULL,
    measurement_type enum_work_types_measurement_type NOT NULL,
    suggested_units VARCHAR(50) NOT NULL,
    unit_cost_material DECIMAL(10, 2),
    unit_cost_labor DECIMAL(10, 2),
    productivity_unit_per_hr DECIMAL(10, 2),
    name_vec vector(384),
    revision INTEGER NOT NULL DEFAULT 1,
    updated_by UUID,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Add CHECK constraints for non-negative costs
DO \$\$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'check_unit_cost_material_non_negative'
    ) THEN
        ALTER TABLE work_types
        ADD CONSTRAINT check_unit_cost_material_non_negative
        CHECK (unit_cost_material IS NULL OR unit_cost_material >= 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'check_unit_cost_labor_non_negative'
    ) THEN
        ALTER TABLE work_types
        ADD CONSTRAINT check_unit_cost_labor_non_negative
        CHECK (unit_cost_labor IS NULL OR unit_cost_labor >= 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'check_productivity_unit_per_hr_non_negative'
    ) THEN
        ALTER TABLE work_types
        ADD CONSTRAINT check_productivity_unit_per_hr_non_negative
        CHECK (productivity_unit_per_hr IS NULL OR productivity_unit_per_hr >= 0);
    END IF;
END \$\$;

-- Create work_type_materials table if it doesn't exist
CREATE TABLE IF NOT EXISTS work_type_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    work_type_id UUID NOT NULL REFERENCES work_types(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    qty_per_unit DECIMAL(10, 4) NOT NULL DEFAULT 1.0,
    unit VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Add CHECK constraint for non-negative quantity
DO \$\$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'check_qty_per_unit_non_negative'
    ) THEN
        ALTER TABLE work_type_materials
        ADD CONSTRAINT check_qty_per_unit_non_negative
        CHECK (qty_per_unit >= 0);
    END IF;
END \$\$;

-- Add unique constraint for work_type_id and product_id
DO \$\$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE indexname = 'work_type_materials_work_type_id_product_id_unique'
    ) THEN
        CREATE UNIQUE INDEX work_type_materials_work_type_id_product_id_unique
        ON work_type_materials(work_type_id, product_id);
    END IF;
END \$\$;

-- Add index on product_id
DO \$\$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE indexname = 'work_type_materials_product_id_idx'
    ) THEN
        CREATE INDEX work_type_materials_product_id_idx
        ON work_type_materials(product_id);
    END IF;
END \$\$;

-- Create work_type_tags table if it doesn't exist
CREATE TABLE IF NOT EXISTS work_type_tags (
    work_type_id UUID NOT NULL REFERENCES work_types(id) ON DELETE CASCADE,
    tag VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (work_type_id, tag)
);

-- Create work_type_cost_history table if it doesn't exist
CREATE TABLE IF NOT EXISTS work_type_cost_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    work_type_id UUID NOT NULL REFERENCES work_types(id) ON DELETE CASCADE,
    region VARCHAR(50) NOT NULL DEFAULT 'default',
    unit_cost_material DECIMAL(10, 2),
    unit_cost_labor DECIMAL(10, 2),
    captured_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Add CHECK constraints for non-negative costs in history
DO \$\$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'check_history_unit_cost_material_non_negative'
    ) THEN
        ALTER TABLE work_type_cost_history
        ADD CONSTRAINT check_history_unit_cost_material_non_negative
        CHECK (unit_cost_material IS NULL OR unit_cost_material >= 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'check_history_unit_cost_labor_non_negative'
    ) THEN
        ALTER TABLE work_type_cost_history
        ADD CONSTRAINT check_history_unit_cost_labor_non_negative
        CHECK (unit_cost_labor IS NULL OR unit_cost_labor >= 0);
    END IF;
END \$\$;

-- Add index on work_type_id and captured_at
DO \$\$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE indexname = 'work_type_cost_history_work_type_id_captured_at_idx'
    ) THEN
        CREATE INDEX work_type_cost_history_work_type_id_captured_at_idx
        ON work_type_cost_history(work_type_id, captured_at);
    END IF;
END \$\$;

-- Create vector similarity index
DO \$\$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE indexname = 'idx_work_types_name_vec'
    ) THEN
        CREATE INDEX idx_work_types_name_vec
        ON work_types USING ivfflat (name_vec vector_cosine_ops);
    END IF;
END \$\$;
EOF

echo "Database fixes applied successfully."
echo "Now restart the services with: ./docker-services.sh restart"
