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

-- Insert deepseek_embedding_model setting if not exists
INSERT INTO settings (id, "key", value, "group", description, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'deepseek_embedding_model',
    'deepseek-embedding-002',
    'ai',
    'Default embedding model for DeepSeek provider',
    NOW(), 
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM settings WHERE "key" = 'deepseek_embedding_model'
);
