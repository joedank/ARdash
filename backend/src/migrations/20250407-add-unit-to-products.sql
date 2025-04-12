-- Check if the unit column already exists
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'unit'
    ) THEN
        -- Add unit column to products table
        ALTER TABLE products 
        ADD COLUMN unit VARCHAR(50) DEFAULT 'each';

        -- Update existing products to use the default unit
        UPDATE products SET unit = 'each' WHERE unit IS NULL;
    END IF;
END $$;
