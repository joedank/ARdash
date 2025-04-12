// Load environment variables at the very beginning
require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });

const app = require('./app');
const config = require('./config');
const logger = require('./utils/logger');
const { testConnection } = require('./utils/database');
const initDb = require('./utils/initDb');
const runMigrations = require('./utils/migrations/run-migrations');

// Log the current environment and configuration
logger.debug('Starting server with ENV:', process.env.NODE_ENV);
logger.debug('DB_HOST from env:', process.env.DB_HOST);
logger.debug('Using config:', JSON.stringify(config, null, 2));

// Improved startup with better error handling
async function startServer() {
  try {
    // Test database connection
    const dbConnected = await testConnection();
    if (!dbConnected) {
      logger.warn('Database connection failed, but server will start without database functionality');
    } else {
      logger.info('Database connection successful');
      
      // Initialize database (sync models)
      try {
        await initDb(false); // Set to true to force reset tables (use with caution)
        logger.info('Database models synchronized');
        
        // Run migrations
        try {
          await runMigrations();
          logger.info('Database migrations applied successfully');
        } catch (migrationError) {
          logger.warn('Database migrations failed:', migrationError);
          logger.warn('Server will start, but some features may not work properly');
        }
      } catch (dbInitError) {
        logger.warn('Database model synchronization failed:', dbInitError);
        logger.warn('Server will start, but database functionality may be limited');
      }
    }
    
    // Start server
    const server = app.listen(config.port, () => {
      logger.info(`Server started in ${config.nodeEnv} mode on port ${config.port}`);
      logger.info(`API is available at http://localhost:${config.port}${config.apiPrefix}`);
    });
    
    // Handle unhandled rejections
    process.on('unhandledRejection', (err) => {
      logger.error('Unhandled Rejection:', err);
      server.close(() => {
        process.exit(1);
      });
    });
    
    return server;
  } catch (error) {
    logger.error('Server startup failed:', error);
    process.exit(1);
  }
}

// Start the server
const server = startServer();

module.exports = server;
