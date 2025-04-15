-- Begin transaction
BEGIN;

-- 1. Fix invoices table: Migrate data from client_id (varchar) to client_id_new (uuid) and drop varchar column
UPDATE invoices
SET client_id_new = client_id::uuid
WHERE client_id_new IS NULL AND client_id IS NOT NULL AND client_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$';

-- Drop the character varying client_id column
ALTER TABLE invoices DROP COLUMN client_id;

-- Rename client_id_new to client_id
ALTER TABLE invoices RENAME COLUMN client_id_new TO client_id;

-- 2. Fix estimates table: Consolidate client_id, client_fk_id, and client_id_new into client_id

-- First, ensure client_id_new has the correct UUIDs
UPDATE estimates
SET client_id_new = client_id::uuid
WHERE client_id_new IS NULL AND client_id IS NOT NULL AND client_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$';

-- Transfer data from client_fk_id if client_id_new is still null
UPDATE estimates
SET client_id_new = client_fk_id
WHERE client_id_new IS NULL AND client_fk_id IS NOT NULL;

-- Drop the character varying client_id column
ALTER TABLE estimates DROP COLUMN client_id;

-- Drop the client_fk_id column after ensuring data is migrated
ALTER TABLE estimates DROP COLUMN client_fk_id;

-- Rename client_id_new to client_id
ALTER TABLE estimates RENAME COLUMN client_id_new TO client_id;

-- 3. Fix camelCase column names in estimates

-- Rename dateCreated to date_created
ALTER TABLE estimates RENAME COLUMN "dateCreated" TO date_created;

-- Rename validUntil to valid_until
ALTER TABLE estimates RENAME COLUMN "validUntil" TO valid_until;

-- Add indices for better performance
CREATE INDEX IF NOT EXISTS invoices_client_id_idx ON invoices (client_id);
CREATE INDEX IF NOT EXISTS estimates_client_id_idx ON estimates (client_id);

-- Create foreign key constraints
ALTER TABLE invoices ADD CONSTRAINT invoices_client_id_fkey
FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL;

ALTER TABLE estimates ADD CONSTRAINT estimates_client_id_fkey
FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL;

-- Mark the migration as completed in the SequelizeMeta table
INSERT INTO "SequelizeMeta" (name) 
VALUES ('20250413000000-standardize-id-fields.js')
ON CONFLICT (name) DO NOTHING;

-- Commit the transaction
COMMIT;
