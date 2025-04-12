const { sequelize } = require('../database');
const fs = require('fs');
const path = require('path');
const logger = require('../logger');

/**
 * Run database migrations
 */
async function runMigrations() {
  try {
    logger.info('Running database migrations...');
    
    // Add theme_preference column to users table
    await sequelize.query(`
      ALTER TABLE users 
      ADD COLUMN IF NOT EXISTS theme_preference VARCHAR(10) DEFAULT 'dark' NOT NULL;
    `);
    
    // Update existing users to have a default theme preference
    await sequelize.query(`
      UPDATE users 
      SET theme_preference = 'dark' 
      WHERE theme_preference IS NULL;
    `);
    
    logger.info('Database migrations completed successfully.');
  } catch (error) {
    logger.error('Error running database migrations:', error);
    throw error;
  }
}

module.exports = runMigrations;
