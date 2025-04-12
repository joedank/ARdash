// Load environment variables
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');
const path = require('path');
const routes = require('./routes');
const config = require('./config');
const errorMiddleware = require('./middleware/error.middleware');
const logger = require('./utils/logger');
const { initializeDatabase } = require('./utils/dbInit');
const { testConnection } = require('./utils/database');

// Create Express app
const app = express();

// Configure CORS with specific settings
const corsOptions = {
  origin: [
    'http://localhost:5173',
    'http://127.0.0.1:5173',
    'https://job.806040.xyz',
    'http://job.806040.xyz'
  ], // Frontend URLs
  methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  credentials: true,
  exposedHeaders: ['Content-Length', 'Content-Type', 'Content-Disposition']
};

// Apply middlewares with proper CORS settings
app.use(cors(corsOptions));
app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' } // Allow cross-origin resource sharing
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// Serve static files from the uploads directory with CORS headers
app.use('/uploads', (req, res, next) => {
  // Allow specific origins instead of wildcard for better security
  const allowedOrigins = ['http://localhost:5173', 'http://127.0.0.1:5173', 'https://job.806040.xyz', 'http://job.806040.xyz'];
  const origin = req.headers.origin;
  
  if (allowedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  }
  
  res.setHeader('Cross-Origin-Resource-Policy', 'cross-origin');
  next();
}, express.static(path.join(__dirname, '../uploads')));

// Request logger middleware
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.originalUrl}`);
  next();
});

// API routes
app.use(config.apiPrefix, routes);

// Error handling middleware
app.use(errorMiddleware);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Route not found'
  });
});

// Initialize database
(async () => {
  try {
    // Test database connection
    const isConnected = await testConnection();
    if (!isConnected) {
      logger.error('Database connection failed');
      return;
    }
    
    // Initialize database with models and default settings
    await initializeDatabase();
    logger.info('Database initialized successfully');
  } catch (error) {
    logger.error('Database initialization error:', error);
  }
})();

module.exports = app;
