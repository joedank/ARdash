'use strict';

const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const { sequelize, WorkType } = require('../models');
const logger = require('../utils/logger');

/**
 * Parses CSV data from a string
 * @param {string} csvData - CSV data as a string
 * @returns {Array} Array of objects representing CSV rows
 */
function parseCSV(csvData) {
  // Split by lines and filter out empty lines
  const lines = csvData.split('\n').filter(line => line.trim() !== '');
  
  // Get headers from the first line
  const headers = lines[0].split(',').map(header => header.trim());
  
  // Process data rows
  const data = [];
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i];
    
    // Skip lines that might be part of explanatory text or notes
    if (line.startsWith('Citations for') || line.startsWith('⸻') || line.startsWith('Phase')) {
      continue;
    }
    
    const values = line.split(',').map(value => value.trim());
    
    // Create object from headers and values
    const rowObject = {};
    headers.forEach((header, index) => {
      rowObject[header] = values[index] || '';
    });
    
    data.push(rowObject);
  }
  
  return data;
}

/**
 * Imports work types from CSV file
 * @param {string} filePath - Path to the CSV file
 */
async function importWorkTypes(filePath) {
  try {
    console.log(`Importing work types from ${filePath}`);
    
    // Read the file
    const fileContent = fs.readFileSync(filePath, 'utf8');
    
    // Parse CSV data
    const workTypes = parseCSV(fileContent);
    console.log(`Found ${workTypes.length} work types to import`);
    
    // Start transaction
    const transaction = await sequelize.transaction();
    
    try {
      let created = 0;
      let skipped = 0;
      
      // Process each work type
      for (const workTypeData of workTypes) {
        try {
          // Skip if missing required fields
          if (!workTypeData.name || !workTypeData.parent_bucket || 
              !workTypeData.measurement_type || !workTypeData.suggested_units) {
            console.log(`Skipping work type with missing required fields: ${JSON.stringify(workTypeData)}`);
            skipped++;
            continue;
          }
          
          // Generate UUID if it's a placeholder
          if (!workTypeData.id || workTypeData.id.startsWith('<uuid')) {
            workTypeData.id = uuidv4();
          }
          
          // Check if work type already exists
          const existingWorkType = await WorkType.findOne({
            where: { name: workTypeData.name },
            transaction
          });
          
          if (existingWorkType) {
            console.log(`Work type already exists: ${workTypeData.name}`);
            skipped++;
            continue;
          }
          
          // Create the work type
          await WorkType.create(workTypeData, { transaction });
          created++;
          console.log(`Created work type: ${workTypeData.name}`);
        } catch (error) {
          console.error(`Error processing work type: ${workTypeData.name}`, error);
          skipped++;
        }
      }
      
      // Commit the transaction
      await transaction.commit();
      console.log(`Import completed: ${created} created, ${skipped} skipped`);
    } catch (error) {
      // Rollback the transaction
      await transaction.rollback();
      console.error('Transaction failed:', error);
      throw error;
    }
  } catch (error) {
    console.error('Import failed:', error);
    throw error;
  }
}

// Check if this is being run directly
if (require.main === module) {
  const filePath = process.argv[2];
  
  if (!filePath) {
    console.error('Please provide a file path: node import-work-types.js <file-path>');
    process.exit(1);
  }
  
  importWorkTypes(filePath)
    .then(() => {
      console.log('Import process completed');
      process.exit(0);
    })
    .catch(error => {
      console.error('Import process failed:', error);
      process.exit(1);
    });
} else {
  // Export for use in other scripts
  module.exports = {
    importWorkTypes,
    parseCSV
  };
}
