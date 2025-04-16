-- Rename active column to is_active to match the model definition
ALTER TABLE communities 
  RENAME COLUMN active TO is_active;
