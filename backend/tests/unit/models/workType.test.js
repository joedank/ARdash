'use strict';

const { expect } = require('chai');
const { WorkType } = require('../../../src/models');
const { ValidationError } = require('sequelize');

describe('WorkType Model', () => {
  describe('Validation', () => {
    it('should create a valid work type with all fields', async () => {
      const workType = WorkType.build({
        id: '12345678-1234-1234-1234-123456789012',
        name: 'Test Work Type',
        parent_bucket: 'test-bucket',
        measurement_type: 'area',
        suggested_units: 'sq ft',
        unit_cost_material: 10.50,
        unit_cost_labor: 25.75,
        productivity_unit_per_hr: 5.5,
        revision: 1
      });
      
      await expect(workType.validate()).to.not.be.rejected;
    });
    
    it('should reject negative material cost', async () => {
      const workType = WorkType.build({
        id: '12345678-1234-1234-1234-123456789012',
        name: 'Test Work Type',
        parent_bucket: 'test-bucket',
        measurement_type: 'area',
        suggested_units: 'sq ft',
        unit_cost_material: -10.50, // Negative value
        unit_cost_labor: 25.75,
        productivity_unit_per_hr: 5.5,
        revision: 1
      });
      
      await expect(workType.validate()).to.be.rejectedWith(ValidationError);
    });
    
    it('should reject negative labor cost', async () => {
      const workType = WorkType.build({
        id: '12345678-1234-1234-1234-123456789012',
        name: 'Test Work Type',
        parent_bucket: 'test-bucket',
        measurement_type: 'area',
        suggested_units: 'sq ft',
        unit_cost_material: 10.50,
        unit_cost_labor: -25.75, // Negative value
        productivity_unit_per_hr: 5.5,
        revision: 1
      });
      
      await expect(workType.validate()).to.be.rejectedWith(ValidationError);
    });
    
    it('should reject negative productivity', async () => {
      const workType = WorkType.build({
        id: '12345678-1234-1234-1234-123456789012',
        name: 'Test Work Type',
        parent_bucket: 'test-bucket',
        measurement_type: 'area',
        suggested_units: 'sq ft',
        unit_cost_material: 10.50,
        unit_cost_labor: 25.75,
        productivity_unit_per_hr: -5.5, // Negative value
        revision: 1
      });
      
      await expect(workType.validate()).to.be.rejectedWith(ValidationError);
    });
    
    it('should allow null values for cost fields', async () => {
      const workType = WorkType.build({
        id: '12345678-1234-1234-1234-123456789012',
        name: 'Test Work Type',
        parent_bucket: 'test-bucket',
        measurement_type: 'area',
        suggested_units: 'sq ft',
        unit_cost_material: null,
        unit_cost_labor: null,
        productivity_unit_per_hr: null,
        revision: 1
      });
      
      await expect(workType.validate()).to.not.be.rejected;
    });
    
    it('should require name field', async () => {
      const workType = WorkType.build({
        id: '12345678-1234-1234-1234-123456789012',
        // name is missing
        parent_bucket: 'test-bucket',
        measurement_type: 'area',
        suggested_units: 'sq ft',
        revision: 1
      });
      
      await expect(workType.validate()).to.be.rejectedWith(ValidationError);
    });
    
    it('should require parent_bucket field', async () => {
      const workType = WorkType.build({
        id: '12345678-1234-1234-1234-123456789012',
        name: 'Test Work Type',
        // parent_bucket is missing
        measurement_type: 'area',
        suggested_units: 'sq ft',
        revision: 1
      });
      
      await expect(workType.validate()).to.be.rejectedWith(ValidationError);
    });
    
    it('should require measurement_type field', async () => {
      const workType = WorkType.build({
        id: '12345678-1234-1234-1234-123456789012',
        name: 'Test Work Type',
        parent_bucket: 'test-bucket',
        // measurement_type is missing
        suggested_units: 'sq ft',
        revision: 1
      });
      
      await expect(workType.validate()).to.be.rejectedWith(ValidationError);
    });
    
    it('should validate measurement_type values', async () => {
      const workType = WorkType.build({
        id: '12345678-1234-1234-1234-123456789012',
        name: 'Test Work Type',
        parent_bucket: 'test-bucket',
        measurement_type: 'invalid-type', // Invalid value
        suggested_units: 'sq ft',
        revision: 1
      });
      
      await expect(workType.validate()).to.be.rejectedWith(ValidationError);
    });
  });
});
