const { sequelize } = require('../models');
const logger = require('./logger');

/**
 * Initialize database
 * - Sync models
 * - Run seeders if needed
 */
async function initDb(force = false) {
  try {
    // Sync all models
    // force: true will drop the table if it already exists
    await sequelize.sync({ force });
    logger.info('Database synchronized successfully');
    
    // Run seeders if needed
    if (force) {
      logger.info('Running seeders...');
      // await runSeeders();
      logger.info('Seeders completed');
    }
    
    return true;
  } catch (error) {
    logger.error('Database initialization failed:', error);
    return false;
  }
}

/**
 * Run database seeders
 */
async function runSeeders() {
  // Add seeder logic here
  // Example: await require('../seeders/userSeeder')();
}

module.exports = initDb;
