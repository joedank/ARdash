/**
 * Test to ensure password hashing logic handles pre-hashed passwords correctly
 * This protects against regression where bcrypt-hashed passwords get double-hashed
 */

const request = require('supertest');
const bcrypt = require('bcryptjs');
const { sequelize } = require('../../src/utils/database');
const { v4: uuidv4 } = require('uuid');
const app = require('../../src/app');

describe('Password Hashing Regression Tests', () => {
  let testUserId;
  const testUsername = 'testuser_' + new Date().getTime();
  const plainPassword = 'test123';
  let bcryptHash;

  beforeAll(async () => {
    // Generate a bcrypt hash
    bcryptHash = await bcrypt.hash(plainPassword, 10);
    
    // Create a test user with an already-hashed password using raw SQL
    // This simulates what happens when we manually insert users with hashed passwords
    testUserId = uuidv4();
    await sequelize.query(`
      INSERT INTO users (
        id, username, email, password, first_name, last_name, 
        is_active, role, theme_preference, created_at, updated_at
      ) VALUES (
        :id, :username, :email, :password, 'Test', 'User',
        true, 'user', 'dark', NOW(), NOW()
      )
    `, {
      replacements: {
        id: testUserId,
        username: testUsername,
        email: `${testUsername}@example.com`,
        password: bcryptHash
      },
      type: sequelize.QueryTypes.INSERT
    });
  });

  afterAll(async () => {
    // Clean up test user
    await sequelize.query('DELETE FROM users WHERE id = :id', {
      replacements: { id: testUserId }
    });
  });

  test('Login succeeds with pre-hashed password', async () => {
    // Attempt to login with the plaintext password
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        username: testUsername,
        password: plainPassword
      });

    // Check that login was successful
    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.message).toBe('Login successful');
    expect(response.body.data.user.username).toBe(testUsername);
    expect(response.body.data.token).toBeTruthy();
  });

  test('Password is not double-hashed when updated', async () => {
    // First login to get a token
    const loginResponse = await request(app)
      .post('/api/auth/login')
      .send({
        username: testUsername,
        password: plainPassword
      });

    const token = loginResponse.body.data.token;

    // Update password to a new plaintext value
    const newPassword = 'newpassword123';
    const updateResponse = await request(app)
      .put('/api/users/password')
      .set('Authorization', `Bearer ${token}`)
      .send({
        currentPassword: plainPassword,
        newPassword: newPassword
      });

    // Check update was successful
    expect(updateResponse.status).toBe(200);
    expect(updateResponse.body.success).toBe(true);

    // Try to login with the new password
    const newLoginResponse = await request(app)
      .post('/api/auth/login')
      .send({
        username: testUsername,
        password: newPassword
      });

    // Check login with new password succeeds
    expect(newLoginResponse.status).toBe(200);
    expect(newLoginResponse.body.success).toBe(true);
    
    // Verify the stored password is a bcrypt hash and not double-hashed
    const userResult = await sequelize.query(
      'SELECT password FROM users WHERE id = :id',
      {
        replacements: { id: testUserId },
        type: sequelize.QueryTypes.SELECT
      }
    );
    
    const storedPassword = userResult[0].password;
    expect(storedPassword).toMatch(/^\$2[aby]\$\d+\$/); // Matches bcrypt hash format
    
    // Verify we can compare the plaintext against the stored hash
    const passwordMatches = await bcrypt.compare(newPassword, storedPassword);
    expect(passwordMatches).toBe(true);
  });
});
