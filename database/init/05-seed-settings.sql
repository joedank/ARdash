-- Create settings table if it doesn't exist
CREATE TABLE IF NOT EXISTS settings (
    id UUID PRIMARY KEY,
    "key" VARCHAR(255) NOT NULL UNIQUE,
    value TEXT,
    "group" VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Print a message for debugging
DO $$
BEGIN
    RAISE NOTICE 'Settings table created or already exists';
END $$;

-- Insert default embedding model setting if it doesn't exist
INSERT INTO settings (id, "key", value, "group", description, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'deepseek_embedding_model',
    'deepseek-embed-v1',
    'ai',
    'Default embedding model for DeepSeek provider',
    NOW(), 
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM settings WHERE "key" = 'deepseek_embedding_model'
);

DO $$
BEGIN
    RAISE NOTICE 'Deepseek embedding model setting added if needed';
END $$;

-- Insert embedding provider setting if it doesn't exist
INSERT INTO settings (id, "key", value, "group", description, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'embedding_provider',
    'deepseek',
    'ai',
    'Default embedding provider',
    NOW(), 
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM settings WHERE "key" = 'embedding_provider'
);

DO $$
BEGIN
    RAISE NOTICE 'Embedding provider setting added if needed';
END $$;

-- Insert vector similarity enabled setting if it doesn't exist
INSERT INTO settings (id, "key", value, "group", description, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'enable_vector_similarity',
    'true',
    'ai',
    'Enable or disable vector similarity search',
    NOW(), 
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM settings WHERE "key" = 'enable_vector_similarity'
);

DO $$
BEGIN
    RAISE NOTICE 'Vector similarity enabled setting added if needed';
END $$;

-- Verify our settings were added
SELECT 'Settings in database:' AS message;
SELECT "key", value, "group" FROM settings WHERE "key" IN ('deepseek_embedding_model', 'embedding_provider', 'enable_vector_similarity');
