'use strict';

/**
 * Standardization Tests
 * 
 * These tests verify that the standardization implementations are working correctly,
 * including UUID validation, field name standardization, and error handling.
 */

const request = require('supertest');
const { expect } = require('chai');
const app = require('../app');
const { isValidUuid, validateUuid } = require('../middleware/uuidValidator');
const { standardizedErrorMiddleware } = require('../middleware/standardized-error.middleware');
const db = require('../models');
const { User, Client, Project } = db;
const jwt = require('../utils/jwt');

describe('Standardization Implementation Tests', () => {
  let token;
  let clientId;
  let projectId;
  let userId;

  before(async () => {
    // Create a test user for authentication
    const testUser = await User.create({
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      is_admin: true
    });
    userId = testUser.id;
    
    // Generate JWT token for authentication
    token = jwt.generateToken({ id: testUser.id, username: testUser.username, is_admin: true });
  });

  after(async () => {
    // Clean up test data
    await Project.destroy({ where: { client_id: clientId }, force: true });
    await Client.destroy({ where: { id: clientId }, force: true });
    await User.destroy({ where: { id: userId }, force: true });
  });

  describe('UUID Validation Tests', () => {
    it('should validate correct UUID format', () => {
      const validUuid = '123e4567-e89b-12d3-a456-426614174000';
      expect(isValidUuid(validUuid)).to.be.true;
    });

    it('should reject invalid UUID format', () => {
      const invalidUuid = '123-456-789';
      expect(isValidUuid(invalidUuid)).to.be.false;
    });

    it('should reject undefined UUID', () => {
      expect(isValidUuid(undefined)).to.be.false;
    });

    it('should reject null UUID', () => {
      expect(isValidUuid(null)).to.be.false;
    });

    it('should reject empty string UUID', () => {
      expect(isValidUuid('')).to.be.false;
    });
  });

  describe('API Standardization Tests', () => {
    it('should create a client with standardized fields', async () => {
      const clientData = {
        display_name: 'Test Client',
        email: 'client@example.com',
        phone: '123-456-7890',
        client_type: 'residential'
      };

      const response = await request(app)
        .post('/api/clients')
        .set('Authorization', `Bearer ${token}`)
        .send(clientData);

      expect(response.status).to.equal(201);
      expect(response.body.success).to.be.true;
      expect(response.body.data).to.have.property('id');
      
      // Store client ID for later tests
      clientId = response.body.data.id;
      
      // Verify client was created with correct fields
      const client = await Client.findByPk(clientId);
      expect(client).to.not.be.null;
      expect(client.display_name).to.equal(clientData.display_name);
    });

    it('should create a project with standardized client_id field', async () => {
      const projectData = {
        client_id: clientId,
        type: 'assessment',
        status: 'pending',
        scheduled_date: new Date().toISOString().split('T')[0],
        scope: 'Test project scope'
      };

      const response = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${token}`)
        .send(projectData);

      expect(response.status).to.equal(201);
      expect(response.body.success).to.be.true;
      expect(response.body.data).to.have.property('id');
      
      // Store project ID for later tests
      projectId = response.body.data.id;
      
      // Verify project was created with correct fields
      const project = await Project.findByPk(projectId);
      expect(project).to.not.be.null;
      expect(project.client_id).to.equal(clientId);
      expect(project.type).to.equal(projectData.type);
    });

    it('should reject invalid UUID in route parameter', async () => {
      const response = await request(app)
        .get('/api/projects/invalid-uuid')
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).to.equal(400);
      expect(response.body.success).to.be.false;
      expect(response.body.message).to.include('Invalid UUID');
    });

    it('should return 404 for non-existent project with valid UUID', async () => {
      const validNonExistentUuid = '00000000-0000-4000-a000-000000000000';
      
      const response = await request(app)
        .get(`/api/projects/${validNonExistentUuid}`)
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).to.equal(404);
      expect(response.body.success).to.be.false;
    });

    it('should successfully retrieve project with standardized response format', async () => {
      const response = await request(app)
        .get(`/api/projects/${projectId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).to.equal(200);
      expect(response.body.success).to.be.true;
      expect(response.body.data).to.have.property('id').equal(projectId);
      expect(response.body.data).to.have.property('client_id').equal(clientId);
    });

    it('should handle updating project with both camelCase and snake_case field names', async () => {
      const updateData = {
        clientId: clientId, // camelCase
        scope: 'Updated project scope', // no case conversion needed
        additional_work: 'Test additional work' // snake_case
      };

      const response = await request(app)
        .put(`/api/projects/${projectId}`)
        .set('Authorization', `Bearer ${token}`)
        .send(updateData);

      expect(response.status).to.equal(200);
      expect(response.body.success).to.be.true;
      
      // Verify project was updated correctly
      const project = await Project.findByPk(projectId);
      expect(project.scope).to.equal(updateData.scope);
      expect(project.additional_work).to.equal(updateData.additional_work);
    });
  });

  describe('Error Handling Tests', () => {
    it('should handle validation error with standardized format', async () => {
      // Try to create a project without required fields
      const invalidProjectData = {
        scope: 'Test project without required fields'
        // Missing client_id and scheduled_date
      };

      const response = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${token}`)
        .send(invalidProjectData);

      expect(response.status).to.equal(400);
      expect(response.body.success).to.be.false;
      expect(response.body.message).to.include('Validation');
    });

    it('should handle authentication error with standardized format', async () => {
      const response = await request(app)
        .get('/api/projects')
        .set('Authorization', 'Bearer invalid-token');

      expect(response.status).to.equal(401);
      expect(response.body.success).to.be.false;
      expect(response.body.message).to.include('auth');
    });

    it('should handle not found error with standardized format', async () => {
      const nonExistentId = '00000000-0000-4000-a000-000000000000';
      
      const response = await request(app)
        .get(`/api/clients/${nonExistentId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).to.equal(404);
      expect(response.body.success).to.be.false;
      expect(response.body.message).to.include('not found');
    });
  });
});
