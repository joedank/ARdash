/// <reference types="cypress" />

describe('Work Type Details', () => {
  beforeEach(() => {
    // Mock login
    cy.intercept('POST', '/api/auth/login', {
      statusCode: 200,
      body: {
        success: true,
        data: {
          token: 'fake-jwt-token',
          user: {
            id: '12345678-1234-1234-1234-123456789012',
            email: 'test@example.com',
            role: 'admin'
          }
        }
      }
    }).as('loginRequest');
    
    // Mock work type data
    cy.intercept('GET', '/api/work-types/*', {
      statusCode: 200,
      body: {
        success: true,
        data: {
          id: '12345678-1234-1234-1234-123456789012',
          name: 'Install Drywall',
          parentBucket: 'interior-walls',
          measurementType: 'area',
          suggestedUnits: 'sq ft',
          unitCostMaterial: 1.25,
          unitCostLabor: 2.75,
          productivityUnitPerHr: 50,
          revision: 1,
          tags: [
            { id: 'tag1', tag: 'dust-control' },
            { id: 'tag2', tag: 'fire-rated' }
          ]
        }
      }
    }).as('getWorkType');
    
    // Mock cost history
    cy.intercept('GET', '/api/work-types/*/costs/history', {
      statusCode: 200,
      body: {
        success: true,
        data: [
          {
            id: 'history1',
            workTypeId: '12345678-1234-1234-1234-123456789012',
            region: 'default',
            unitCostMaterial: 1.25,
            unitCostLabor: 2.75,
            capturedAt: '2025-04-01T12:00:00Z',
            updatedBy: '12345678-1234-1234-1234-123456789012'
          },
          {
            id: 'history2',
            workTypeId: '12345678-1234-1234-1234-123456789012',
            region: 'default',
            unitCostMaterial: 1.15,
            unitCostLabor: 2.50,
            capturedAt: '2025-03-01T12:00:00Z',
            updatedBy: '12345678-1234-1234-1234-123456789012'
          }
        ]
      }
    }).as('getCostHistory');
    
    // Mock materials
    cy.intercept('GET', '/api/work-types/*?include_materials=true&include_tags=true', {
      statusCode: 200,
      body: {
        success: true,
        data: {
          id: '12345678-1234-1234-1234-123456789012',
          name: 'Install Drywall',
          parentBucket: 'interior-walls',
          measurementType: 'area',
          suggestedUnits: 'sq ft',
          unitCostMaterial: 1.25,
          unitCostLabor: 2.75,
          productivityUnitPerHr: 50,
          revision: 1,
          materials: [
            {
              id: 'material1',
              productId: 'product1',
              qtyPerUnit: 0.031,
              unit: 'sheet',
              product: {
                id: 'product1',
                name: 'Drywall Sheet 4x8',
                sku: 'DW-48'
              }
            },
            {
              id: 'material2',
              productId: 'product2',
              qtyPerUnit: 0.1,
              unit: 'lb',
              product: {
                id: 'product2',
                name: 'Drywall Screws',
                sku: 'DW-SCR'
              }
            }
          ],
          tags: [
            { id: 'tag1', tag: 'dust-control' },
            { id: 'tag2', tag: 'fire-rated' }
          ]
        }
      }
    }).as('getWorkTypeWithMaterials');
    
    // Mock cost update
    cy.intercept('PATCH', '/api/work-types/*/costs', {
      statusCode: 200,
      body: {
        success: true,
        data: {
          workType: {
            id: '12345678-1234-1234-1234-123456789012',
            name: 'Install Drywall',
            unitCostMaterial: 1.35,
            unitCostLabor: 2.85,
            productivityUnitPerHr: 55,
            revision: 2
          },
          costHistory: {
            id: 'history3',
            workTypeId: '12345678-1234-1234-1234-123456789012',
            region: 'default',
            unitCostMaterial: 1.35,
            unitCostLabor: 2.85,
            capturedAt: '2025-04-28T12:00:00Z'
          }
        },
        message: 'Work type costs updated successfully'
      }
    }).as('updateCosts');
    
    // Login and visit work type details page
    cy.visit('/login');
    cy.get('input[name="email"]').type('test@example.com');
    cy.get('input[name="password"]').type('password');
    cy.get('button[type="submit"]').click();
    cy.wait('@loginRequest');
    
    cy.visit('/work-types/12345678-1234-1234-1234-123456789012');
    cy.wait('@getWorkType');
  });
  
  it('should display work type details', () => {
    cy.get('h1').should('contain', 'Install Drywall');
    cy.get('p').should('contain', 'Interior Walls');
    cy.get('p').should('contain', 'Area');
    cy.get('p').should('contain', 'sq ft');
  });
  
  it('should display cost information', () => {
    cy.contains('Cost Information').should('be.visible');
    cy.contains('Material Cost (per unit)').next().should('contain', '$1.25');
    cy.contains('Labor Cost (per unit)').next().should('contain', '$2.75');
    cy.contains('Productivity (units per hour)').next().should('contain', '50');
    cy.contains('Total Cost (per unit)').next().should('contain', '$4.00');
  });
  
  it('should navigate between tabs', () => {
    // Click on Costs tab
    cy.contains('button', 'Costs').click();
    cy.contains('Current Cost Details').should('be.visible');
    
    // Click on Materials & Safety tab
    cy.contains('button', 'Materials & Safety').click();
    cy.wait('@getWorkTypeWithMaterials');
    cy.contains('Default Materials').should('be.visible');
    cy.contains('Safety & Permit Tags').should('be.visible');
    
    // Click on History tab
    cy.contains('button', 'History').click();
    cy.wait('@getCostHistory');
    cy.contains('Cost History').should('be.visible');
  });
  
  it('should open and submit cost editor', () => {
    // Click Edit Costs button
    cy.contains('button', 'Edit Costs').click();
    
    // Modal should be visible
    cy.contains('Edit Costs for Install Drywall').should('be.visible');
    
    // Update values
    cy.get('input[id="material-cost"]').clear().type('1.35');
    cy.get('input[id="labor-cost"]').clear().type('2.85');
    cy.get('input[id="productivity"]').clear().type('55');
    
    // Submit form
    cy.contains('button', 'Save').click();
    cy.wait('@updateCosts');
    
    // Toast should appear
    cy.contains('Costs updated for Install Drywall').should('be.visible');
    
    // Values should be updated
    cy.contains('Material Cost (per unit)').next().should('contain', '$1.35');
    cy.contains('Labor Cost (per unit)').next().should('contain', '$2.85');
    cy.contains('Productivity (units per hour)').next().should('contain', '55');
  });
  
  it('should display materials and tags', () => {
    // Go to Materials & Safety tab
    cy.contains('button', 'Materials & Safety').click();
    cy.wait('@getWorkTypeWithMaterials');
    
    // Check materials
    cy.contains('Drywall Sheet 4x8').should('be.visible');
    cy.contains('Drywall Screws').should('be.visible');
    
    // Check tags
    cy.contains('dust-control').should('be.visible');
    cy.contains('fire-rated').should('be.visible');
  });
  
  it('should display cost history', () => {
    // Go to History tab
    cy.contains('button', 'History').click();
    cy.wait('@getCostHistory');
    
    // Check history entries
    cy.contains('Apr 1, 2025').should('be.visible');
    cy.contains('Mar 1, 2025').should('be.visible');
    
    // Check cost values
    cy.contains('$1.25').should('be.visible');
    cy.contains('$2.75').should('be.visible');
    cy.contains('$1.15').should('be.visible');
    cy.contains('$2.50').should('be.visible');
  });
});
