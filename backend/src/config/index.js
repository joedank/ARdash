// Load environment variables
require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });

const config = {
  port: process.env.PORT || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  apiPrefix: process.env.API_PREFIX || '/api',
  db: {
    database: process.env.DB_NAME || 'management_db',
    username: process.env.DB_USER || 'josephmcmyne',
    password: process.env.DB_PASS || '',
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres'
  }
};

// Debug the loaded config
console.log('Loaded configuration:', JSON.stringify(config, null, 2));

module.exports = config;
