const { Umzug, SequelizeStorage } = require('umzug');
const { sequelize } = require('../database');
const logger = require('../logger');

/**
 * Run database migrations
 */
async function runMigrations() {
  logger.info('Running database migrations...');

  const umzug = new Umzug({
    migrations: { glob: 'backend/migrations/*.js' },
    context: sequelize.getQueryInterface(),
    storage: new SequelizeStorage({ sequelize }),
    logger,
  });

  await umzug.up();
  logger.info('Database migrations applied successfully');
}

module.exports = runMigrations;
