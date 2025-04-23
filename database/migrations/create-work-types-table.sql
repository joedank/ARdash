-- Create the work_types table for mobile-home repair tasks

CREATE TABLE IF NOT EXISTS work_types (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    parent_bucket VARCHAR(100) NOT NULL,
    measurement_type VARCHAR(50) NOT NULL,
    suggested_units VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create an index on the name column for faster lookups and similarity matching
CREATE INDEX IF NOT EXISTS idx_work_types_name ON work_types USING gin (name gin_trgm_ops);

-- Create an index on the parent_bucket for category filtering
CREATE INDEX IF NOT EXISTS idx_work_types_parent_bucket ON work_types (parent_bucket);

-- Extension for trigram matching should already be installed since the app uses pg_trgm
-- But if not, this would enable it: 
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;

COMMENT ON TABLE work_types IS 'Mobile-home repair and remodel work types with measurement specifications';
COMMENT ON COLUMN work_types.id IS 'Unique identifier for the work type';
COMMENT ON COLUMN work_types.name IS 'Descriptive name of the work type';
COMMENT ON COLUMN work_types.parent_bucket IS 'Category grouping (Interior-Structural, Interior-Finish, Exterior-Structural, Exterior-Finish, Mechanical)';
COMMENT ON COLUMN work_types.measurement_type IS 'Type of measurement (area, linear, quantity)';
COMMENT ON COLUMN work_types.suggested_units IS 'Suggested unit for measurement (sq ft, ft, each, job, etc.)';
