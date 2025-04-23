/**
 * Script to merge the WorkTypesList component parts into a single file
 */

const fs = require('fs');
const path = require('path');

// Define the paths
const basePath = path.resolve(__dirname);
const partFiles = [
  path.join(basePath, 'WorkTypesList.part1.vue'),
  path.join(basePath, 'WorkTypesList.part2.vue'),
  path.join(basePath, 'WorkTypesList.part3.vue'),
  path.join(basePath, 'WorkTypesList.part4.vue')
];
const outputFile = path.join(basePath, 'WorkTypesList.vue');

// Function to merge the files
function mergeFiles() {
  try {
    console.log('Starting to merge WorkTypesList component parts...');
    
    // Read all part files
    const parts = partFiles.map((filePath, index) => {
      try {
        const content = fs.readFileSync(filePath, 'utf8');
        console.log(`Successfully read part ${index + 1}`);
        return content;
      } catch (err) {
        console.error(`Error reading part ${index + 1}:`, err);
        throw err;
      }
    });
    
    // Validate logical breaks
    let isValid = true;
    
    // Part 1 should start with <template> and include opening divs
    if (!parts[0].trim().startsWith('<template>')) {
      console.error('Part 1 does not start with <template> tag');
      isValid = false;
    }
    
    // Part 2 should continue template and include work types table
    if (!parts[1].includes('Work Types Table')) {
      console.error('Part 2 does not contain work types table section');
      isValid = false;
    }
    
    // Part 3 should continue template with form fields
    if (!parts[2].includes('Parent Bucket')) {
      console.error('Part 3 does not contain form fields');
      isValid = false;
    }
    
    // Part 4 should end template and include script
    if (!parts[3].includes('</template>') || !parts[3].includes('<script>')) {
      console.error('Part 4 does not contain closing template tag and script section');
      isValid = false;
    }
    
    if (!isValid) {
      console.error('Validation failed, files cannot be merged correctly');
      process.exit(1);
    }
    
    // Combine the parts
    const mergedContent = parts.join('');
    
    // Write to output file
    fs.writeFileSync(outputFile, mergedContent, 'utf8');
    console.log(`Successfully merged all parts into ${outputFile}`);
    
    // Optionally, remove part files
    if (process.argv.includes('--clean')) {
      partFiles.forEach((filePath) => {
        fs.unlinkSync(filePath);
        console.log(`Removed ${filePath}`);
      });
      console.log('All part files removed');
    }
    
    return true;
  } catch (err) {
    console.error('Error merging files:', err);
    return false;
  }
}

// Execute the merge function
mergeFiles();
