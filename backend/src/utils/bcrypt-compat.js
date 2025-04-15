/**
 * Bcrypt compatibility layer
 * 
 * This module provides a compatibility layer for bcrypt using bcryptjs,
 * which is a pure JavaScript implementation that works across all platforms.
 */

const bcryptjs = require('bcryptjs');
const logger = require('./logger');

logger.info('Using bcryptjs as a replacement for bcrypt');

// Export bcryptjs methods with the same interface as bcrypt
module.exports = {
  // Hash a password
  hash: (data, saltRounds) => {
    return new Promise((resolve, reject) => {
      bcryptjs.hash(data, saltRounds, (err, hash) => {
        if (err) return reject(err);
        resolve(hash);
      });
    });
  },
  
  // Compare a password with a hash
  compare: (data, hash) => {
    return new Promise((resolve, reject) => {
      bcryptjs.compare(data, hash, (err, result) => {
        if (err) return reject(err);
        resolve(result);
      });
    });
  },
  
  // Generate a salt
  genSalt: (rounds) => {
    return new Promise((resolve, reject) => {
      bcryptjs.genSalt(rounds, (err, salt) => {
        if (err) return reject(err);
        resolve(salt);
      });
    });
  }
};
