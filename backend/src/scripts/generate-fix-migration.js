'use strict';

require('dotenv').config();
const { Sequelize } = require('sequelize');
const ModelSyncTool = require('../utils/modelSyncTool');
const models = require('../models');

/**
 * Command-line tool to generate migrations for fixing model-schema mismatches
 */
async function main() {
  try {
    // Create a Sequelize instance for migration generation
    const sequelize = new Sequelize(
      process.env.DB_NAME,
      process.env.DB_USER,
      process.env.DB_PASSWORD,
      {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        dialect: 'postgres',
        logging: false
      }
    );
    
    // Create a queryInterface instance
    const queryInterface = sequelize.getQueryInterface();
    
    console.log('Checking for model-schema mismatches...');
    
    // Create a model sync tool
    const syncTool = new ModelSyncTool(queryInterface, models);
    
    // Generate fix migration
    const result = await syncTool.generateFixMigration();
    
    if (result.created) {
      console.log(`Created migration file: ${result.path}`);
      console.log('Mismatches found:');
      
      for (const mismatch of result.mismatches) {
        console.log(`- ${mismatch.model} (${mismatch.tableName}):`);
        
        for (const issue of mismatch.mismatches) {
          if (issue.issue === 'type_mismatch') {
            console.log(`  - Column "${issue.column}": type mismatch (DB: ${issue.dbType}, Model: ${issue.modelType})`);
          } 
          else if (issue.issue === 'nullable_mismatch') {
            console.log(`  - Column "${issue.column}": nullable mismatch (DB: ${issue.dbNullable}, Model: ${issue.modelNullable})`);
          }
          else if (issue.issue === 'missing_in_db') {
            console.log(`  - Column "${issue.field}": missing in database`);
          }
          else if (issue.issue === 'missing_in_model') {
            console.log(`  - Column "${issue.column}": missing in model`);
          }
        }
      }
      
      console.log('\nPlease review the generated migration before running it!');
    } else {
      console.log('No mismatches found. Database schema matches models.');
    }
    
    await sequelize.close();
  } catch (error) {
    console.error('Error generating migration:', error);
    process.exit(1);
  }
}

// Run the main function
main();