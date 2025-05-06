const jwt = require('jsonwebtoken');

// Get the JWT secret from environment or use the Docker default
const JWT_SECRET = process.env.JWT_SECRET || 'docker-jwt-secret';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '1d';

// Create a payload for a test user
const payload = {
  id: 'test-user-id',
  username: 'tester',
  email: 'test@example.com',
  role: 'admin'
};

// Generate the token
const token = jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });

console.log('Test JWT Token:');
console.log(token);
