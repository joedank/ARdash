const { Sequelize } = require('sequelize');
const logger = require('./logger');

// Direct hardcoded configuration to ensure connection works
const dbConfig = {
  database: 'management_db',
  username: 'josephmcmyne',
  password: '',
  host: 'localhost',  // Explicitly use localhost instead of 'db'
  port: 5432,
  dialect: 'postgres',
  logging: msg => logger.debug(msg),
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000
  }
};

// Log connection details for debugging
logger.debug('Using database config:', {
  database: dbConfig.database,
  username: dbConfig.username,
  host: dbConfig.host,
  port: dbConfig.port
});

// Create Sequelize instance with explicit config
const sequelize = new Sequelize(
  dbConfig.database,
  dbConfig.username,
  dbConfig.password,
  {
    host: dbConfig.host,
    port: dbConfig.port,
    dialect: dbConfig.dialect,
    logging: dbConfig.logging,
    pool: dbConfig.pool
  }
);

// Test the connection
async function testConnection() {
  try {
    await sequelize.authenticate();
    logger.info('Database connection established successfully');
    return true;
  } catch (error) {
    logger.error('Unable to connect to the database:', error);
    return false;
  }
}

module.exports = {
  sequelize,
  testConnection
};
