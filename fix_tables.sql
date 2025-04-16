-- Fix column names with hyphens in communities table
ALTER TABLE communities 
  RENAME COLUMN "ad-specialist-name" TO ad_specialist_name;

ALTER TABLE communities 
  RENAME COLUMN "ad-specialist-email" TO ad_specialist_email;

ALTER TABLE communities 
  RENAME COLUMN "ad-specialist-phone" TO ad_specialist_phone;

-- Add created_at and updated_at columns to communities table
ALTER TABLE communities 
  ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Add active boolean column to communities table
ALTER TABLE communities 
  ADD COLUMN active BOOLEAN DEFAULT FALSE;

-- Update active column based on state column
UPDATE communities 
  SET active = (state = 'Active');

-- Add created_at and updated_at columns to ad_types table
ALTER TABLE ad_types 
  ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Convert date columns in ad_types from text to date
ALTER TABLE ad_types 
  ALTER COLUMN start_date TYPE DATE USING start_date::DATE,
  ALTER COLUMN end_date TYPE DATE USING end_date::DATE,
  ALTER COLUMN deadline_date TYPE DATE USING deadline_date::DATE;
