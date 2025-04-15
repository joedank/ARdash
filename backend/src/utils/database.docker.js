const { Sequelize } = require('sequelize');
const logger = require('./logger');
require('dotenv').config();

// Use environment variables for configuration
const dbConfig = {
  database: process.env.DB_NAME || 'management_db',
  username: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASS || 'postgres',
  host: process.env.DB_HOST || 'db',
  port: process.env.DB_PORT || 5432,
  dialect: 'postgres',
  logging: console.log, // Use console.log for more visible debugging
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000
  }
};

// Log connection details for debugging
console.log('Using database config:', {
  database: dbConfig.database,
  username: dbConfig.username,
  host: dbConfig.host,
  port: dbConfig.port
});

// Create Sequelize instance with configuration from environment variables
const sequelize = new Sequelize(
  dbConfig.database,
  dbConfig.username,
  dbConfig.password,
  {
    host: dbConfig.host,
    port: dbConfig.port,
    dialect: dbConfig.dialect,
    logging: dbConfig.logging,
    pool: dbConfig.pool,
    retry: {
      max: 5,          // Maximum retry attempts
      timeout: 60000    // 60 seconds timeout for retry
    }
  }
);

// Test the connection
async function testConnection() {
  try {
    await sequelize.authenticate();
    console.log('Database connection established successfully');
    return true;
  } catch (error) {
    console.error('Unable to connect to the database:', error);
    return false;
  }
}

module.exports = {
  sequelize,
  testConnection
};
