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
