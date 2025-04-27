'use strict';

/**
 * This script tests the ViewManager utility by performing a safe column type change
 * with view dependencies. It provides verification that the utility works as expected.
 */

const { Sequelize } = require('sequelize');
require('dotenv').config({ path: '../backend/.env' });
const ViewManager = require('../backend/src/utils/ViewManager');

// Connect to the database
const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    dialect: 'postgres',
    logging: console.log
  }
);

async function testViewManager() {
  console.log('Testing ViewManager Utility');
  console.log('---------------------------');
  
  try {
    // Create a queryInterface instance
    const queryInterface = sequelize.getQueryInterface();
    
    // Initialize the ViewManager
    const viewManager = new ViewManager(queryInterface);
    
    // 1. Get dependent views for the clients table
    console.log('\n1. Checking dependent views for clients table:');
    const dependentViews = await viewManager.getDependentViews('clients');
    console.log('   Dependent views:', dependentViews);
    
    // 2. Get dependent views for the payment_terms column
    console.log('\n2. Checking dependent views for payment_terms column:');
    const columnDependentViews = await viewManager.getDependentViewsForColumn('clients', 'payment_terms');
    console.log('   Dependent views for column:', columnDependentViews);
    
    // 3. Get the definition of client_view
    console.log('\n3. Getting definition of client_view:');
    const viewDef = await viewManager.getViewDefinition('client_view');
    console.log('   View definition:', viewDef.trim());
    
    // 4. Check current data type of payment_terms
    console.log('\n4. Checking current data type of payment_terms:');
    const [columnTypeResult] = await sequelize.query(`
      SELECT data_type, character_maximum_length
      FROM information_schema.columns
      WHERE table_name = 'clients' AND column_name = 'payment_terms'
    `);
    console.log('   Current data type:', columnTypeResult[0]);
    
    // 5. Test a safe column type change within a transaction
    console.log('\n5. Testing safe column type change (transaction will be rolled back):');
    await sequelize.transaction(async (transaction) => {
      try {
        // Change the column type (will be rolled back)
        console.log('   Changing column type to TEXT...');
        await viewManager.safelyAlterColumnType('clients', 'payment_terms', 'TEXT', transaction);
        
        // Check if column type was changed
        const [afterChangeResult] = await sequelize.query(`
          SELECT data_type, character_maximum_length
          FROM information_schema.columns
          WHERE table_name = 'clients' AND column_name = 'payment_terms'
        `, { transaction });
        
        console.log('   After change data type:', afterChangeResult[0]);
        
        // Check if client_view still exists
        const [afterViewCheck] = await sequelize.query(`
          SELECT viewname
          FROM pg_catalog.pg_views
          WHERE viewname = 'client_view'
        `, { transaction });
        
        console.log('   client_view exists after change:', afterViewCheck.length > 0);
        
        // Test that the view still works
        const [viewResult] = await sequelize.query(`
          SELECT count(*) FROM client_view
        `, { transaction });
        
        console.log('   View query successful, results:', viewResult[0]);
        
        // Intentionally throw error to rollback - this is just a test
        throw new Error('INTENTIONAL ROLLBACK - This is expected');
      } catch (error) {
        if (error.message === 'INTENTIONAL ROLLBACK - This is expected') {
          console.log('   Successfully tested column change and rollback');
        } else {
          console.error('   Error during test:', error.message);
        }
        
        // Re-throw to ensure rollback
        throw error;
      }
    }).catch(error => {
      if (error.message === 'INTENTIONAL ROLLBACK - This is expected') {
        console.log('   Transaction successfully rolled back as intended');
      } else {
        console.error('   Transaction error:', error.message);
      }
    });
    
    // 6. Verify everything is back to normal after rollback
    console.log('\n6. Verifying state after rollback:');
    const [finalTypeResult] = await sequelize.query(`
      SELECT data_type, character_maximum_length
      FROM information_schema.columns
      WHERE table_name = 'clients' AND column_name = 'payment_terms'
    `);
    console.log('   Final data type:', finalTypeResult[0]);
    
    const [finalViewCheck] = await sequelize.query(`
      SELECT viewname
      FROM pg_catalog.pg_views
      WHERE viewname = 'client_view'
    `);
    
    console.log('   client_view exists after rollback:', finalViewCheck.length > 0);
    
    console.log('\nTest completed successfully!');
    
  } catch (error) {
    console.error('Test failed:', error);
  } finally {
    // Close the database connection
    await sequelize.close();
  }
}

// Run the test
testViewManager().catch(console.error);
