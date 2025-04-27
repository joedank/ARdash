#!/bin/bash
set -e

echo "This script will fix the settings table and restart the services without running migrations."

# Enable required PostgreSQL extensions
echo "Enabling required PostgreSQL extensions..."
docker exec -i management-db-1 psql -U postgres -d management_db << EOF
-- Enable uuid-ossp extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pgvector extension for vector operations
CREATE EXTENSION IF NOT EXISTS "vector";
EOF

# Fix estimate_item_additional_work relations
echo "Checking and fixing estimate_item_additional_work relations..."
docker exec -i management-db-1 psql -U postgres -d management_db << EOF
-- Check if the relation already exists
DO \$\$
BEGIN
    -- Check if estimate_item_additional_work table exists
    IF EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_name = 'estimate_item_additional_work'
    ) THEN
        RAISE NOTICE 'estimate_item_additional_work table exists';

        -- Check if estimate_item_id column exists
        IF EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_name = 'estimate_item_additional_work' AND column_name = 'estimate_item_id'
        ) THEN
            RAISE NOTICE 'estimate_item_id column exists in estimate_item_additional_work table';

            -- Check if the relation already exists
            IF EXISTS (
                SELECT FROM information_schema.table_constraints
                WHERE constraint_name = 'estimate_item_additional_work_estimate_item_id'
            ) THEN
                RAISE NOTICE 'Relation estimate_item_additional_work_estimate_item_id already exists, skipping...';
            ELSE
                RAISE NOTICE 'Adding foreign key constraint for estimate_item_id...';
                ALTER TABLE estimate_item_additional_work
                ADD CONSTRAINT estimate_item_additional_work_estimate_item_id
                FOREIGN KEY (estimate_item_id) REFERENCES estimate_items(id) ON DELETE CASCADE ON UPDATE CASCADE;
            END IF;
        ELSE
            RAISE NOTICE 'estimate_item_id column does not exist in estimate_item_additional_work table, skipping...';
        END IF;
    ELSE
        RAISE NOTICE 'estimate_item_additional_work table does not exist, skipping...';
    END IF;
END \$\$;
EOF

# Fix invoices and estimates tables
echo "Checking and fixing invoices and estimates tables..."
docker exec -i management-db-1 psql -U postgres -d management_db << EOF
-- Check if client_id column exists in invoices
DO \$\$
BEGIN
    -- Check if invoices table exists
    IF EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_name = 'invoices'
    ) THEN
        -- Check if client_id column exists
        IF EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_name = 'invoices' AND column_name = 'client_id'
        ) THEN
            RAISE NOTICE 'client_id column already exists in invoices table';

            -- Check if client_id is UUID type
            IF (
                SELECT data_type
                FROM information_schema.columns
                WHERE table_name = 'invoices' AND column_name = 'client_id'
            ) != 'uuid' THEN
                RAISE NOTICE 'client_id column in invoices is not UUID type, updating...';

                -- Create a temporary column with UUID type
                ALTER TABLE invoices ADD COLUMN client_id_new UUID REFERENCES clients(id);

                -- Try to convert existing values
                UPDATE invoices
                SET client_id_new = client_id::uuid
                WHERE client_id IS NOT NULL
                AND client_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$';

                -- Drop old column and rename new one
                ALTER TABLE invoices DROP COLUMN client_id;
                ALTER TABLE invoices RENAME COLUMN client_id_new TO client_id;
                RAISE NOTICE 'Successfully updated client_id column in invoices to UUID type';
            END IF;
        ELSE
            RAISE NOTICE 'Adding client_id column to invoices table';
            ALTER TABLE invoices ADD COLUMN client_id UUID REFERENCES clients(id);
        END IF;

        -- Ensure index exists
        CREATE INDEX IF NOT EXISTS invoices_client_id_idx ON invoices(client_id);
    ELSE
        RAISE NOTICE 'invoices table does not exist, skipping';
    END IF;

    -- Check if estimates table exists
    IF EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_name = 'estimates'
    ) THEN
        -- Check if client_id column exists
        IF EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_name = 'estimates' AND column_name = 'client_id'
        ) THEN
            RAISE NOTICE 'client_id column already exists in estimates table';

            -- Check if client_id is UUID type
            IF (
                SELECT data_type
                FROM information_schema.columns
                WHERE table_name = 'estimates' AND column_name = 'client_id'
            ) != 'uuid' THEN
                RAISE NOTICE 'client_id column in estimates is not UUID type, updating...';

                -- Create a temporary column with UUID type
                ALTER TABLE estimates ADD COLUMN client_id_new UUID REFERENCES clients(id);

                -- Try to convert existing values
                UPDATE estimates
                SET client_id_new = client_id::uuid
                WHERE client_id IS NOT NULL
                AND client_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$';

                -- Drop old column and rename new one
                ALTER TABLE estimates DROP COLUMN client_id;
                ALTER TABLE estimates RENAME COLUMN client_id_new TO client_id;
                RAISE NOTICE 'Successfully updated client_id column in estimates to UUID type';
            END IF;
        ELSE
            RAISE NOTICE 'Adding client_id column to estimates table';
            ALTER TABLE estimates ADD COLUMN client_id UUID REFERENCES clients(id);
        END IF;

        -- Ensure index exists
        CREATE INDEX IF NOT EXISTS estimates_client_id_idx ON estimates(client_id);
    ELSE
        RAISE NOTICE 'estimates table does not exist, skipping';
    END IF;
END \$\$;
EOF

# Create the settings table directly
echo "Creating settings table and inserting default values..."
docker exec -i management-db-1 psql -U postgres -d management_db << EOF
-- Create settings table if it doesn't exist
CREATE TABLE IF NOT EXISTS settings (
  id SERIAL PRIMARY KEY,
  key VARCHAR(255) NOT NULL UNIQUE,
  value TEXT,
  "group" VARCHAR(255) NOT NULL DEFAULT 'general',
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_settings_group ON settings ("group");

-- Insert default AI provider settings if they don't exist
INSERT INTO settings (key, value, "group", description)
VALUES
  ('deepseek_embedding_model', 'deepseek-embedding', 'ai', 'Default embedding model for DeepSeek')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

INSERT INTO settings (key, value, "group", description)
VALUES
  ('embedding_provider', 'deepseek', 'ai', 'Default embedding provider')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

INSERT INTO settings (key, value, "group", description)
VALUES
  ('enable_vector_similarity', 'true', 'ai', 'Enable vector similarity search')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

-- Verify settings were created
SELECT * FROM settings WHERE "group" = 'ai';
EOF

echo "Settings table created and default values inserted."

# Restart the services
echo "Restarting services..."
docker compose restart backend embedding-worker estimate-worker

echo "Done! Services have been restarted."
echo "Check logs with: docker compose logs -f"
