# Database Migrations

This directory contains database migration files for the application.

## Recent Migrations

### 20250407-add-type-to-products.js

Added a 'type' column to the 'products' table to fix the issue with the product catalog in the estimate section. 
The column is an ENUM type with the following values:
- 'product'
- 'service'

This matches the model definition in `/src/models/Product.js`.

## Running Migrations

To run all pending migrations:

```bash
# Make sure you're in the backend directory
cd backend

# Install dependencies if needed
npm install

# Run migrations
npm run migrate
```

This will:
1. Run all pending migrations
2. Run seeders to add sample data if needed

## Creating New Migrations

When creating new migrations, use the following naming convention:
`YYYYMMDD-descriptive-name.js`

Example:
`20250407-add-type-to-products.js`

Migration files should always include both `up` and `down` methods to apply and revert changes.
