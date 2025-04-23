'use strict';

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const { extractWorkTypes } = require('./extract-work-types');
const { importWorkTypes } = require('./import-work-types');

/**
 * Runs the SQL migration to create the work_types table
 * @param {string} migrationPath - Path to the SQL migration file
 * @returns {Promise<void>}
 */
function runMigration(migrationPath) {
  return new Promise((resolve, reject) => {
    // Connect to PostgreSQL and run the migration
    const command = `docker exec -i management-db-1 psql -U postgres management_db < ${migrationPath}`;
    
    console.log(`Running migration: ${command}`);
    
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error(`Migration failed: ${error.message}`);
        return reject(error);
      }
      
      if (stderr) {
        console.warn(`Migration warnings: ${stderr}`);
      }
      
      console.log(`Migration completed: ${stdout}`);
      resolve();
    });
  });
}

/**
 * Setup work types: extract from paste.txt, run migration, import to database
 * @param {string} pasteFilePath - Path to the paste.txt file
 */
async function setupWorkTypes(pasteFilePath) {
  try {
    console.log('Starting work types setup process');
    
    // Define paths
    const rootDir = path.resolve(__dirname, '../../../');
    const migrationPath = path.join(rootDir, 'database/migrations/create-work-types-table.sql');
    const tempCsvPath = path.join(rootDir, 'temp_work_types.csv');
    
    // Step 1: Extract work types from paste.txt
    console.log('Step 1: Extracting work types from paste.txt');
    const extractResult = await extractWorkTypes(pasteFilePath, tempCsvPath);
    console.log(`Extracted ${extractResult.count} work types to ${extractResult.outputPath}`);
    
    // Step 2: Run SQL migration to create the table
    console.log('Step 2: Running SQL migration to create the work_types table');
    await runMigration(migrationPath);
    
    // Step 3: Import the work types into the database
    console.log('Step 3: Importing work types into the database');
    await importWorkTypes(tempCsvPath);
    
    // Step 4: Cleanup temporary files
    console.log('Step 4: Cleaning up temporary files');
    fs.unlinkSync(tempCsvPath);
    
    console.log('Work types setup process completed successfully');
  } catch (error) {
    console.error('Setup process failed:', error);
    throw error;
  }
}

// Check if this is being run directly
if (require.main === module) {
  const pasteFilePath = process.argv[2];
  
  if (!pasteFilePath) {
    console.error('Please provide the path to paste.txt: node setup-work-types.js <paste-file-path>');
    process.exit(1);
  }
  
  setupWorkTypes(pasteFilePath)
    .then(() => {
      console.log('Setup process completed');
      process.exit(0);
    })
    .catch(error => {
      console.error('Setup process failed:', error);
      process.exit(1);
    });
} else {
  // Export for use in other scripts
  module.exports = { setupWorkTypes };
}
