'use strict';

const request = require('supertest');
const { expect } = require('chai');
const app = require('../../src/app');
const { WorkType, WorkTypeCostHistory, User } = require('../../src/models');
const { v4: uuidv4 } = require('uuid');
const jwt = require('../../src/utils/jwt');

describe('Work Types API', () => {
  let testWorkType;
  let testUser;
  let adminUser;
  let userToken;
  let adminToken;
  let estimatorManagerToken;

  before(async () => {
    // Create test user
    testUser = await User.create({
      id: uuidv4(),
      email: 'test-user@example.com',
      password: 'password123',
      first_name: 'Test',
      last_name: 'User',
      role: 'user'
    });

    // Create admin user
    adminUser = await User.create({
      id: uuidv4(),
      email: 'test-admin@example.com',
      password: 'password123',
      first_name: 'Admin',
      last_name: 'User',
      role: 'admin'
    });

    // Create estimator manager user
    const estimatorManager = await User.create({
      id: uuidv4(),
      email: 'test-estimator@example.com',
      password: 'password123',
      first_name: 'Estimator',
      last_name: 'Manager',
      role: 'estimator_manager'
    });

    // Create tokens
    userToken = jwt.generateToken(testUser);
    adminToken = jwt.generateToken(adminUser);
    estimatorManagerToken = jwt.generateToken(estimatorManager);

    // Create test work type
    testWorkType = await WorkType.create({
      id: uuidv4(),
      name: 'Test Work Type',
      parent_bucket: 'Interior-Structural',
      measurement_type: 'area',
      suggested_units: 'sq ft',
      unit_cost_material: 10.50,
      unit_cost_labor: 25.75,
      productivity_unit_per_hr: 5.5,
      revision: 1
    });

    // Create test cost history
    await WorkTypeCostHistory.create({
      id: uuidv4(),
      work_type_id: testWorkType.id,
      region: 'default',
      unit_cost_material: 10.50,
      unit_cost_labor: 25.75,
      captured_at: new Date(),
      updated_by: adminUser.id
    });

    await WorkTypeCostHistory.create({
      id: uuidv4(),
      work_type_id: testWorkType.id,
      region: 'northeast',
      unit_cost_material: 12.50,
      unit_cost_labor: 28.75,
      captured_at: new Date(Date.now() - 86400000), // 1 day ago
      updated_by: adminUser.id
    });
  });

  after(async () => {
    // Clean up test data
    await WorkTypeCostHistory.destroy({ where: { work_type_id: testWorkType.id } });
    await WorkType.destroy({ where: { id: testWorkType.id } });
    await User.destroy({ where: { id: testUser.id } });
    await User.destroy({ where: { id: adminUser.id } });
  });

  describe('GET /api/work-types/:id/costs/history', () => {
    it('should return cost history for a work type', async () => {
      const response = await request(app)
        .get(`/api/work-types/${testWorkType.id}/costs/history`)
        .set('Authorization', `Bearer ${userToken}`)
        .expect(200);

      expect(response.body).to.have.property('success', true);
      expect(response.body).to.have.property('data');
      expect(response.body.data).to.be.an('array');
      expect(response.body.data).to.have.length.at.least(2);
      
      // Check structure of first history record
      const historyRecord = response.body.data[0];
      expect(historyRecord).to.have.property('id');
      expect(historyRecord).to.have.property('work_type_id', testWorkType.id);
      expect(historyRecord).to.have.property('region');
      expect(historyRecord).to.have.property('unit_cost_material');
      expect(historyRecord).to.have.property('unit_cost_labor');
      expect(historyRecord).to.have.property('captured_at');
    });

    it('should filter cost history by region', async () => {
      const response = await request(app)
        .get(`/api/work-types/${testWorkType.id}/costs/history?region=northeast`)
        .set('Authorization', `Bearer ${userToken}`)
        .expect(200);

      expect(response.body).to.have.property('success', true);
      expect(response.body).to.have.property('data');
      expect(response.body.data).to.be.an('array');
      expect(response.body.data).to.have.length.at.least(1);
      
      // Check that all records have the correct region
      response.body.data.forEach(record => {
        expect(record).to.have.property('region', 'northeast');
      });
    });

    it('should limit the number of records returned', async () => {
      const response = await request(app)
        .get(`/api/work-types/${testWorkType.id}/costs/history?limit=1`)
        .set('Authorization', `Bearer ${userToken}`)
        .expect(200);

      expect(response.body).to.have.property('success', true);
      expect(response.body).to.have.property('data');
      expect(response.body.data).to.be.an('array');
      expect(response.body.data).to.have.length(1);
    });

    it('should return 404 for non-existent work type', async () => {
      const nonExistentId = uuidv4();
      const response = await request(app)
        .get(`/api/work-types/${nonExistentId}/costs/history`)
        .set('Authorization', `Bearer ${userToken}`)
        .expect(404);

      expect(response.body).to.have.property('success', false);
      expect(response.body).to.have.property('message');
    });
  });

  describe('PATCH /api/work-types/:id/costs', () => {
    it('should allow admin to update costs', async () => {
      const response = await request(app)
        .patch(`/api/work-types/${testWorkType.id}/costs`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          unit_cost_material: 11.50,
          unit_cost_labor: 26.75,
          productivity_unit_per_hr: 6.0
        })
        .expect(200);

      expect(response.body).to.have.property('success', true);
      expect(response.body).to.have.property('data');
      expect(response.body.data).to.have.property('workType');
      expect(response.body.data).to.have.property('costHistory');
      expect(response.body.data.workType).to.have.property('unit_cost_material', '11.50');
      expect(response.body.data.workType).to.have.property('unit_cost_labor', '26.75');
      expect(response.body.data.workType).to.have.property('productivity_unit_per_hr', '6.00');
    });

    it('should allow estimator_manager to update costs', async () => {
      const response = await request(app)
        .patch(`/api/work-types/${testWorkType.id}/costs`)
        .set('Authorization', `Bearer ${estimatorManagerToken}`)
        .send({
          unit_cost_material: 12.00,
          unit_cost_labor: 27.00,
          productivity_unit_per_hr: 6.5
        })
        .expect(200);

      expect(response.body).to.have.property('success', true);
      expect(response.body.data.workType).to.have.property('unit_cost_material', '12.00');
      expect(response.body.data.workType).to.have.property('unit_cost_labor', '27.00');
      expect(response.body.data.workType).to.have.property('productivity_unit_per_hr', '6.50');
    });

    it('should not allow regular user to update costs', async () => {
      const response = await request(app)
        .patch(`/api/work-types/${testWorkType.id}/costs`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          unit_cost_material: 13.00,
          unit_cost_labor: 28.00
        })
        .expect(403);

      expect(response.body).to.have.property('success', false);
      expect(response.body).to.have.property('message');
    });

    it('should reject negative cost values', async () => {
      const response = await request(app)
        .patch(`/api/work-types/${testWorkType.id}/costs`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          unit_cost_material: -5.00,
          unit_cost_labor: 28.00
        })
        .expect(400);

      expect(response.body).to.have.property('success', false);
      expect(response.body).to.have.property('message');
    });
  });
});
