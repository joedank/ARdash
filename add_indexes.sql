-- Add missing indexes to communities table
CREATE INDEX IF NOT EXISTS communities_name ON communities(name);
CREATE INDEX IF NOT EXISTS communities_city ON communities(city);
CREATE INDEX IF NOT EXISTS communities_is_active ON communities(is_active);
