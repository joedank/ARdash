'use strict';

const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

/**
 * Extracts work types from the paste.txt file and generates a CSV file with proper UUIDs
 * @param {string} inputPath - Path to the paste.txt file
 * @param {string} outputPath - Path to save the generated CSV file
 */
function extractWorkTypes(inputPath, outputPath) {
  try {
    console.log(`Extracting work types from ${inputPath}`);
    
    // Read the input file
    const content = fs.readFileSync(inputPath, 'utf8');
    
    // Find the CSV portion of the content
    const csvStartIndex = content.indexOf('id,name,parent_bucket,measurement_type,suggested_units');
    const csvEndIndex = content.indexOf('Citations for top sources used');
    
    if (csvStartIndex === -1 || csvEndIndex === -1) {
      throw new Error('Could not find CSV data in the input file');
    }
    
    // Extract CSV content
    let csvContent = content.substring(csvStartIndex, csvEndIndex).trim();
    
    // Replace placeholder UUIDs with real UUIDs
    const lines = csvContent.split('\n');
    const headers = lines[0]; // Keep the headers
    
    const transformedLines = lines.slice(1).map(line => {
      // Find ID placeholder format like <uuid001>
      if (line.includes('<uuid')) {
        return line.replace(/<uuid\\d+>/, uuidv4());
      }
      return line;
    });
    
    // Join the headers and transformed lines
    const outputContent = [headers, ...transformedLines].join('\n');
    
    // Write to output file
    fs.writeFileSync(outputPath, outputContent);
    
    console.log(`Successfully extracted work types and saved to ${outputPath}`);
    console.log(`Processed ${transformedLines.length} work types`);
    
    return {
      count: transformedLines.length,
      outputPath
    };
  } catch (error) {
    console.error('Extraction failed:', error);
    throw error;
  }
}

// Check if this is being run directly
if (require.main === module) {
  const inputPath = process.argv[2];
  const outputPath = process.argv[3] || path.join(process.cwd(), 'work_types.csv');
  
  if (!inputPath) {
    console.error('Please provide an input file path: node extract-work-types.js <input-path> [output-path]');
    process.exit(1);
  }
  
  try {
    extractWorkTypes(inputPath, outputPath);
    process.exit(0);
  } catch (error) {
    console.error('Extraction process failed:', error);
    process.exit(1);
  }
} else {
  // Export for use in other scripts
  module.exports = { extractWorkTypes };
}
