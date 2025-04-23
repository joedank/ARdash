'use strict';

require('dotenv').config();
const { Sequelize } = require('sequelize');
const MigrationTester = require('../utils/migrationTester');
const DatabaseVerifier = require('../utils/databaseVerifier');

async function testMigration() {
  try {
    console.log('Starting payment_terms migration test...');
    
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
    
    // Create tester and verifier instances
    const tester = new MigrationTester({
      testDbConfig: {
        username: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        host: process.env.DB_HOST,
        port: process.env.DB_PORT
      }
    });
    
    const verifier = new DatabaseVerifier(sequelize.getQueryInterface());
    
    // Verify view status before migration
    console.log('Verifying views before migration...');
    const viewsBefore = await verifier.verifyViews();
    console.log(`Valid views before: ${viewsBefore.valid.length}`);
    
    if (viewsBefore.invalid.length > 0) {
      console.error('Found invalid views before migration:', viewsBefore.invalid);
    }
    
    // Test the migration
    console.log('Testing migration...');
    const result = await tester.testMigration('20250423144500-fix-payment-terms-column-type.js');
    
    if (result.success) {
      console.log(`Migration test successful: ${result.message}`);
      
      // Verify view status after migration
      console.log('Verifying views after migration...');
      const viewsAfter = await verifier.verifyViews();
      console.log(`Valid views after: ${viewsAfter.valid.length}`);
      
      if (viewsAfter.invalid.length > 0) {
        console.error('Found invalid views after migration:', viewsAfter.invalid);
      } else {
        console.log('All views are valid after migration.');
      }
    } else {
      console.error(`Migration test failed: ${result.message}`);
      console.error(`Error: ${result.error}`);
      console.log(`A backup was created at: ${result.backup}`);
    }
    
    await sequelize.close();
  } catch (error) {
    console.error('Error testing migration:', error);
    process.exit(1);
  }
}

// Run the test
testMigration();