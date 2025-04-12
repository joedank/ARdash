const winston = require('winston');
const path = require('path');
const fs = require('fs');
const config = require('../config');

// Create logs directory if it doesn't exist
const logsDir = path.join(__dirname, '../../../logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

// Determine log level based on environment
const logLevel = config.nodeEnv === 'development' ? 'debug' : 'info';

// Define log format with timestamp, error stack traces, and JSON formatting
const logFormat = winston.format.combine(
  winston.format.timestamp({
    format: 'YYYY-MM-DD HH:mm:ss'
  }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json()
);

// Create logger with multiple transports
const logger = winston.createLogger({
  level: logLevel,
  format: logFormat,
  defaultMeta: { service: 'api-service' },
  transports: [
    // Console logs with colorized output
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.printf(
          info => {
            const { timestamp, level, message, ...meta } = info;
            // Only show metadata if it exists and isn't empty
            const metaStr = Object.keys(meta).length > 0 
              ? ` ${JSON.stringify(meta, null, 2)}`
              : '';
            return `${timestamp} ${level}: ${message}${metaStr}`;
          }
        )
      )
    }),
    // File logs for different levels
    new winston.transports.File({ 
      filename: path.join(logsDir, 'error.log'), 
      level: 'error',
      maxsize: 10485760, // 10MB
      maxFiles: 5
    }),
    new winston.transports.File({ 
      filename: path.join(logsDir, 'combined.log'),
      maxsize: 10485760, // 10MB
      maxFiles: 5 
    })
  ]
});

// Add specialized LLM logging
if (config.nodeEnv === 'development') {
  logger.add(
    new winston.transports.File({
      filename: path.join(logsDir, 'llm.log'),
      level: 'debug',
      maxsize: 10485760, // 10MB
      maxFiles: 5,
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      )
    })
  );
}

// Add request tracing method
logger.logRequest = (req, message, meta = {}) => {
  logger.info(message, {
    requestId: req.id,
    userId: req.user?.id,
    method: req.method,
    path: req.path,
    ...meta
  });
};

// Add LLM-specific logging method
logger.logLLM = (action, data, meta = {}) => {
  logger.debug(`LLM ${action}`, {
    llm: true,
    timestamp: new Date().toISOString(),
    action,
    ...data,
    ...meta
  });
};

module.exports = logger;