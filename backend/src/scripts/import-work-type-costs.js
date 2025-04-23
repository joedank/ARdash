'use strict';

const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const { v4: uuidv4 } = require('uuid');
const { Sequelize } = require('sequelize');

// Setup database connection
const db = require('../models');
const { WorkType, WorkTypeMaterial, WorkTypeCostHistory, Product } = db;

/**
 * Import work type costs from CSV
 */
async function importWorkTypeCosts() {
  console.log('Starting import of work type costs...');
  const transaction = await db.sequelize.transaction();
  
  try {
    const results = [];
    
    // Read the CSV file
    await new Promise((resolve, reject) => {
      fs.createReadStream(path.join(__dirname, '../data/seed-work-type-costs.csv'))
        .pipe(csv())
        .on('data', (data) => results.push(data))
        .on('end', resolve)
        .on('error', reject);
    });
    
    console.log(`Read ${results.length} work type costs from CSV`);
    
    // Process each row
    for (const row of results) {
      // Find the work type by ID or name
      let workType = null;
      
      if (row.id) {
        workType = await WorkType.findByPk(row.id, { transaction });
      }
      
      if (!workType && row.name) {
        workType = await WorkType.findOne({
          where: {
            name: row.name
          },
          transaction
        });
      }
      
      if (!workType) {
        console.log(`Work type not found for ID: ${row.id} / Name: ${row.name}`);
        continue;
      }
      
      // Update work type with cost data
      await workType.update({
        unit_cost_material: parseFloat(row.unit_cost_material) || null,
        unit_cost_labor: parseFloat(row.unit_cost_labor) || null,
        productivity_unit_per_hr: parseFloat(row.productivity_unit_per_hr) || null,
        revision: Sequelize.literal('revision + 1')
      }, { transaction });
      
      // Create cost history record
      await WorkTypeCostHistory.create({
        id: uuidv4(),
        work_type_id: workType.id,
        region: 'default',
        unit_cost_material: parseFloat(row.unit_cost_material) || null,
        unit_cost_labor: parseFloat(row.unit_cost_labor) || null,
        captured_at: new Date()
      }, { transaction });
      
      console.log(`Updated work type: ${workType.name}`);
    }
    
    await transaction.commit();
    console.log('Work type costs import completed successfully');
  } catch (error) {
    await transaction.rollback();
    console.error('Error importing work type costs:', error);
    throw error;
  }
}

/**
 * Import work type materials from CSV
 */
async function importWorkTypeMaterials() {
  console.log('Starting import of work type materials...');
  const transaction = await db.sequelize.transaction();
  
  try {
    const results = [];
    
    // Read the CSV file
    await new Promise((resolve, reject) => {
      fs.createReadStream(path.join(__dirname, '../data/seed-work-type-materials.csv'))
        .pipe(csv())
        .on('data', (data) => results.push(data))
        .on('end', resolve)
        .on('error', reject);
    });
    
    console.log(`Read ${results.length} work type materials from CSV`);
    
    // Process each row
    for (const row of results) {
      // Find the work type
      const workType = await WorkType.findByPk(row.work_type_id, { transaction });
      
      if (!workType) {
        console.log(`Work type not found for ID: ${row.work_type_id}`);
        continue;
      }
      
      // Find or create the product
      let product = null;
      
      if (row.product_id) {
        product = await Product.findByPk(row.product_id, { transaction });
      }
      
      if (!product && row.product_name) {
        // Try to find by name
        product = await Product.findOne({
          where: {
            name: row.product_name
          },
          transaction
        });
        
        // Create product if it doesn't exist
        if (!product) {
          product = await Product.create({
            id: row.product_id || uuidv4(),
            name: row.product_name,
            type: 'material',
            // Default values for required fields
            price: 0,
            tax_rate: 0,
            unit: row.unit || 'each'
          }, { transaction });
          
          console.log(`Created product: ${product.name}`);
        }
      }
      
      if (!product) {
        console.log(`Product not found for ID: ${row.product_id} / Name: ${row.product_name}`);
        continue;
      }
      
      // Create the work type material association
      await WorkTypeMaterial.create({
        id: uuidv4(),
        work_type_id: workType.id,
        product_id: product.id,
        qty_per_unit: parseFloat(row.qty_per_unit) || 1,
        unit: row.unit || 'each'
      }, { transaction });
      
      console.log(`Mapped ${product.name} to work type: ${workType.name}`);
    }
    
    await transaction.commit();
    console.log('Work type materials import completed successfully');
  } catch (error) {
    await transaction.rollback();
    console.error('Error importing work type materials:', error);
    throw error;
  }
}

/**
 * Main function to run all imports
 */
async function main() {
  try {
    await importWorkTypeCosts();
    await importWorkTypeMaterials();
    
    console.log('All imports completed successfully');
    process.exit(0);
  } catch (error) {
    console.error('Import failed:', error);
    process.exit(1);
  }
}

// Run the import if this file is executed directly
if (require.main === module) {
  main();
}

module.exports = {
  importWorkTypeCosts,
  importWorkTypeMaterials
};
