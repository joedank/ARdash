-- Add extensions
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS vector;

-- Create enum for measurement_type
CREATE TYPE enum_work_types_measurement_type AS ENUM ('area', 'linear', 'quantity');

-- Create the work_types table
CREATE TABLE IF NOT EXISTS work_types (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    parent_bucket VARCHAR(100) NOT NULL,
    measurement_type enum_work_types_measurement_type NOT NULL,
    suggested_units VARCHAR(50) NOT NULL,
    unit_cost_material DECIMAL(10, 2),
    unit_cost_labor DECIMAL(10, 2),
    productivity_unit_per_hr DECIMAL(10, 2),
    name_vec VECTOR(384),
    revision INTEGER NOT NULL DEFAULT 1,
    updated_by UUID,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_unit_cost_material_non_negative CHECK (unit_cost_material IS NULL OR unit_cost_material >= 0),
    CONSTRAINT check_unit_cost_labor_non_negative CHECK (unit_cost_labor IS NULL OR unit_cost_labor >= 0),
    CONSTRAINT check_productivity_unit_per_hr_non_negative CHECK (productivity_unit_per_hr IS NULL OR productivity_unit_per_hr >= 0)
);

-- Create the work_type_materials table
CREATE TABLE IF NOT EXISTS work_type_materials (
    id UUID PRIMARY KEY,
    work_type_id UUID NOT NULL REFERENCES work_types(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    qty_per_unit DECIMAL(10, 4) NOT NULL DEFAULT 1.0,
    unit VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_qty_per_unit_non_negative CHECK (qty_per_unit >= 0)
);

-- Add unique constraint for work_type_id and product_id
CREATE UNIQUE INDEX IF NOT EXISTS work_type_materials_work_type_id_product_id_unique 
ON work_type_materials (work_type_id, product_id);

-- Add index on product_id
CREATE INDEX IF NOT EXISTS work_type_materials_product_id_idx 
ON work_type_materials (product_id);

-- Create the work_type_tags table
CREATE TABLE IF NOT EXISTS work_type_tags (
    work_type_id UUID NOT NULL REFERENCES work_types(id) ON DELETE CASCADE,
    tag VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (work_type_id, tag)
);

-- Create the work_type_cost_history table
CREATE TABLE IF NOT EXISTS work_type_cost_history (
    id UUID PRIMARY KEY,
    work_type_id UUID NOT NULL REFERENCES work_types(id) ON DELETE CASCADE,
    region VARCHAR(50) NOT NULL DEFAULT 'default',
    unit_cost_material DECIMAL(10, 2),
    unit_cost_labor DECIMAL(10, 2),
    captured_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_history_unit_cost_material_non_negative CHECK (unit_cost_material IS NULL OR unit_cost_material >= 0),
    CONSTRAINT check_history_unit_cost_labor_non_negative CHECK (unit_cost_labor IS NULL OR unit_cost_labor >= 0)
);

-- Add index on work_type_id and captured_at
CREATE INDEX IF NOT EXISTS work_type_cost_history_work_type_id_captured_at_idx 
ON work_type_cost_history (work_type_id, captured_at);

-- Add estimator_manager role to enum_users_role if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_users_role') THEN
        CREATE TYPE enum_users_role AS ENUM ('user', 'admin', 'estimator_manager');
    ELSE
        -- Check if the enum already has the value
        BEGIN
            ALTER TYPE enum_users_role ADD VALUE 'estimator_manager' AFTER 'user';
        EXCEPTION
            WHEN duplicate_object THEN
                -- Value already exists, do nothing
        END;
    END IF;
END
$$;
