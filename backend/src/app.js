// Load environment variables
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');
const path = require('path');
const routes = require('./routes');
const config = require('./config');
const logger = require('./utils/logger');
const { initializeDatabase } = require('./utils/dbInit');
const { testConnection } = require('./utils/database');
const { standardizedErrorMiddleware } = require('./middleware/standardized-error.middleware');

// Create Express app
const app = express();

// Configure CORS with specific settings
const corsOptions = {
  origin: [
    'http://localhost:5173',
    'http://127.0.0.1:5173',
    'https://job.806040.xyz',
    'http://job.806040.xyz',
    'http://192.168.0.190:5173'  // Add local IP address
  ], // Frontend URLs
  methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  credentials: true,
  exposedHeaders: ['Content-Length', 'Content-Type', 'Content-Disposition'],
  optionsSuccessStatus: 200 // For legacy browser support
};

// Apply CORS before any other middleware
app.use(cors(corsOptions));

// Add CORS headers to every response as a backup
app.use((req, res, next) => {
  // Set CORS headers for every response
  res.header('Access-Control-Allow-Origin', req.headers.origin || '*');
  res.header('Access-Control-Allow-Methods', 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  res.header('Access-Control-Allow-Credentials', 'true');
  
  // Handle OPTIONS method directly
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  
  next();
});

// Apply helmet with settings that don't interfere with CORS
app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' }, // Allow cross-origin resource sharing
  contentSecurityPolicy: false // Disable CSP for troubleshooting
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// Serve static files from the uploads directory with CORS headers
app.use('/uploads', (req, res, next) => {
  // Allow specific origins instead of wildcard for better security
  const allowedOrigins = ['http://localhost:5173', 'http://127.0.0.1:5173', 'https://job.806040.xyz', 'http://job.806040.xyz', 'http://192.168.0.190:5173'];
  const origin = req.headers.origin;
  
  if (allowedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  } else {
    // For requests without origin header (like direct browser requests)
    res.setHeader('Access-Control-Allow-Origin', '*');
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

/**
 * Error Handling Flow:
 * 
 * 1. When an error occurs in a route handler or middleware:
 *    - If thrown explicitly: throw new SomeError('message');
 *    - If via next(): next(new SomeError('message'));
 * 
 * 2. The standardizedErrorMiddleware catches all errors and:
 *    - Logs detailed error information (including request context)
 *    - Formats the response according to error type
 *    - Applies appropriate HTTP status codes
 *    - Returns a standardized response: { success: false, message: string, data?: object }
 * 
 * 3. Custom error classes can be imported and used in controllers:
 *    const { ValidationError, NotFoundError, AuthenticationError, 
 *            AuthorizationError, UUIDValidationError, BusinessLogicError 
 *          } = require('../middleware/standardized-error.middleware');
 * 
 * 4. Common error handling cases:
 *    - Validation errors: ValidationError, status 400
 *    - Authentication errors: AuthenticationError, status 401
 *    - Authorization errors: AuthorizationError, status 403
 *    - Not found errors: NotFoundError, status 404
 *    - UUID format errors: UUIDValidationError, status 400
 *    - Business logic errors: BusinessLogicError, status 422
 *    - Database errors: handled automatically with appropriate responses
 */

// Apply standardized error handling middleware
app.use(standardizedErrorMiddleware);

// 404 handler (using standardized response format)
app.use((req, res) => {
  res.status(404).json({
    success: false,
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