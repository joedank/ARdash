'use strict';

require('dotenv').config();
const { Sequelize } = require('sequelize');
const DocumentationGenerator = require('../utils/documentationGenerator');
const path = require('path');

async function generateDocumentation() {
  try {
    console.log('Starting database documentation generation...');
    
    // Create a Sequelize instance
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
    
    // Create documentation generator
    const docGenerator = new DocumentationGenerator(
      sequelize.getQueryInterface(), 
      {
        outputDir: path.join(process.cwd(), '..', 'docs', 'database')
      }
    );
    
    // Generate documentation
    console.log('Generating documentation...');
    await docGenerator.generateDocs();
    
    console.log('Documentation generation completed successfully!');
    console.log('Documentation files:');
    console.log('- schema.md: Tables and columns');
    console.log('- views.md: View definitions and dependencies');
    console.log('- relationships.md: Foreign key relationships');
    console.log('- indices.md: Database indexes');
    
    await sequelize.close();
  } catch (error) {
    console.error('Error generating documentation:', error);
    process.exit(1);
  }
}

// Run the generator
generateDocumentation();