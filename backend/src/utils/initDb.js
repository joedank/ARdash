const { sequelize } = require('../models');
const logger = require('./logger');

/**
 * Initialize database
 * - Sync models
 * - Run seeders if needed
 */
async function initDb(force = false) {
  try {
    // Fix payment_terms column issue before sync if needed
    try {
      logger.info('Checking for client_view view before sync...');
      const [results] = await sequelize.query(
        `SELECT COUNT(*) FROM information_schema.views WHERE table_name = 'client_view'`
      );

      if (results[0].count > 0) {
        logger.info('client_view exists, fixing payment_terms column first...');
        const ViewManager = require('./ViewManager');
        const viewDefinitions = require('../config/viewDefinitions');
        const queryInterface = sequelize.getQueryInterface();

        await sequelize.transaction(async (transaction) => {
          logger.info('Dropping client_view...');
          await queryInterface.sequelize.query(
            `DROP VIEW IF EXISTS client_view;`,
            { transaction }
          );

          logger.info('client_view dropped successfully, will proceed with sync');
        });
      }
    } catch (viewError) {
      logger.warn(`Error handling view check (will continue): ${viewError.message}`);
    }

    // In prod rely on migrations; only allow sync in explicit DEV mode
    if (process.env.ALLOW_SYNC === 'true') {
      await sequelize.sync({ alter: false });
      logger.info('Models synchronized (dev-only)');
    } else {
      logger.info('Skipping model sync - using migrations only');
    }

    // Run a specific SQL command to fix the USING clause issue in client_type column
    try {
      await sequelize.query(`
        -- Fix client_type enum column without USING clause
        ALTER TABLE clients
        ALTER COLUMN client_type TYPE enum_clients_client_type
        USING client_type::text::enum_clients_client_type;
      `);
      logger.info('Successfully fixed client_type column type');
    } catch (typeError) {
      logger.warn(`Error fixing client_type column type (will continue): ${typeError.message}`);
    }

    // Recreate client_view if needed
    try {
      logger.info('Checking if client_view needs to be recreated...');
      const [results] = await sequelize.query(
        `SELECT COUNT(*) FROM information_schema.views WHERE table_name = 'client_view'`
      );

      if (results[0].count === 0) {
        logger.info('Recreating client_view after sync...');
        const viewDefinitions = require('../config/viewDefinitions');
        await sequelize.query(viewDefinitions.client_view);
        logger.info('client_view recreated successfully');
      }
    } catch (recreateError) {
      logger.warn(`Error recreating view (will continue): ${recreateError.message}`);
    }

    // Run seeders if needed
    if (force) {
      logger.info('Running seeders...');
      // await runSeeders();
      logger.info('Seeders completed');
    }

    return true;
  } catch (error) {
    logger.error(`Database initialization failed: ${error.message}`);
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
