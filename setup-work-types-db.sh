#!/bin/bash

# Shell script to set up the work types knowledge base

# Exit on error
set -e

echo "=== Work Types Knowledge Base Setup ==="
echo "1. Creating database migration for work_types table..."

# Set variables
ROOT_DIR="/Volumes/4TB/Users/josephmcmyne/myProjects/management"
MIGRATIONS_DIR="$ROOT_DIR/database/migrations"
PASTE_FILE="$ROOT_DIR/work_types.csv"
BACKEND_DIR="$ROOT_DIR/backend"

# Check if migration exists
if [ -f "$MIGRATIONS_DIR/create-work-types-table.sql" ]; then
  echo "✓ Migration file already exists"
else
  echo "× Migration file not found. Please create it first."
  exit 1
fi

# Check if CSV file exists
if [ -f "$PASTE_FILE" ]; then
  echo "✓ Work types CSV found"
else
  echo "× Work types CSV not found. Please create it first."
  exit 1
fi

# Run the migration
echo "2. Running database migration..."
docker exec -i management-db-1 psql -U postgres management_db < "$MIGRATIONS_DIR/create-work-types-table.sql"
echo "✓ Migration completed"

# Import the work types
echo "3. Importing work types from CSV..."
cd "$BACKEND_DIR"
NODE_SCRIPT=$(cat << 'EOF'
const fs = require('fs');
const path = require('path');
const { parse } = require('csv-parse/sync');
const { v4: uuidv4 } = require('uuid');
const { sequelize, Sequelize } = require('./src/models');

const WorkType = sequelize.define('WorkType', {
  id: {
    type: Sequelize.UUID,
    defaultValue: Sequelize.UUIDV4,
    primaryKey: true
  },
  name: Sequelize.STRING,
  parent_bucket: Sequelize.STRING,
  measurement_type: Sequelize.STRING,
  suggested_units: Sequelize.STRING
}, {
  tableName: 'work_types',
  underscored: true,
  timestamps: true
});

async function importWorkTypes() {
  try {
    const csvFile = process.argv[2];
    console.log(`Reading CSV file: ${csvFile}`);
    
    const fileContent = fs.readFileSync(csvFile, 'utf8');
    const records = parse(fileContent, {
      columns: true,
      skip_empty_lines: true
    });
    
    console.log(`Found ${records.length} work types to import`);
    
    const transaction = await sequelize.transaction();
    
    try {
      let created = 0;
      for (const record of records) {
        // Generate UUID if needed
        if (!record.id || record.id.startsWith('<uuid')) {
          record.id = uuidv4();
        }
        
        await WorkType.create(record, { transaction });
        created++;
      }
      
      await transaction.commit();
      console.log(`Successfully imported ${created} work types`);
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
    
    await sequelize.close();
  } catch (error) {
    console.error('Import failed:', error);
    process.exit(1);
  }
}

importWorkTypes();
EOF
)

# Save the script to a temporary file
TEMP_SCRIPT=$(mktemp)
echo "$NODE_SCRIPT" > "$TEMP_SCRIPT"

# Run the Node.js script inside the Docker container
docker exec -i management-backend-1 node "$TEMP_SCRIPT" "$PASTE_FILE"
echo "✓ Work types imported"

# Clean up
rm "$TEMP_SCRIPT"

# Merge Vue component parts
echo "4. Merging Vue component parts..."
cd "$ROOT_DIR/frontend/src/components/work-types"
node merge-work-types-component.js

# Verify the merged file exists
if [ -f "WorkTypesList.vue" ]; then
  echo "✓ Vue component merged successfully"
else
  echo "× Failed to merge Vue component"
  exit 1
fi

echo "=== Setup completed successfully ==="
echo "Your work types knowledge base is now ready to use!"
echo ""
echo "To access the work types, navigate to:"
echo "http://localhost:5173/work-types"
echo ""
echo "Make sure to integrate the work-types-routes.js file in your main router."
echo "Enjoy your new work types knowledge base!"
