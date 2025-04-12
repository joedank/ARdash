-- Create the ENUM type if it doesn't exist
CREATE TYPE product_type AS ENUM ('product', 'service');

-- Add the type column to the products table
ALTER TABLE products 
ADD COLUMN type product_type 
DEFAULT 'service' NOT NULL;

-- Add an index on the new column
CREATE INDEX products_type_idx ON products(type);

-- Add sample products
INSERT INTO products (id, name, description, price, tax_rate, is_active, type, created_at, updated_at)
VALUES 
(uuid_generate_v4(), 'Standard Inspection', 'Complete inspection of the property including structure, systems, and components.', 299.99, 7.5, true, 'service', NOW(), NOW()),
(uuid_generate_v4(), 'Detailed Assessment', 'In-depth assessment including thermal imaging and detailed report with recommendations.', 499.99, 7.5, true, 'service', NOW(), NOW()),
(uuid_generate_v4(), 'Moisture Detection Service', 'Specialized service to identify hidden moisture and potential water damage.', 199.99, 7.5, true, 'service', NOW(), NOW()),
(uuid_generate_v4(), 'Moisture Meter', 'Professional-grade moisture meter for detecting moisture levels in various materials.', 149.99, 7.5, true, 'product', NOW(), NOW()),
(uuid_generate_v4(), 'Dehumidifier Rental', 'High-capacity dehumidifier rental for drying out spaces after water damage.', 75.00, 7.5, true, 'product', NOW(), NOW());
