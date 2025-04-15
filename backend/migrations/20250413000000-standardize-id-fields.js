'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Step 1: Add new standardized client_id column to invoices table
      await queryInterface.addColumn('invoices', 'client_id_new', {
        type: Sequelize.UUID,
        allowNull: true,
        references: {
          model: 'clients',
          key: 'id'
        }
      });

      // Step 2: Copy data from client_fk_id to the new client_id_new column
      await queryInterface.sequelize.query(`
        UPDATE invoices 
        SET client_id_new = client_fk_id
        WHERE client_fk_id IS NOT NULL
      `);

      // Step 3: Add new standardized client_id column to estimates table
      await queryInterface.addColumn('estimates', 'client_id_new', {
        type: Sequelize.UUID,
        allowNull: true,
        references: {
          model: 'clients',
          key: 'id'
        }
      });

      // Step 4: Copy data from client_fk_id to the new client_id_new column
      await queryInterface.sequelize.query(`
        UPDATE estimates 
        SET client_id_new = client_fk_id
        WHERE client_fk_id IS NOT NULL
      `);

      // Step 5: Drop foreign key constraints on client_fk_id columns
      await queryInterface.removeConstraint('invoices', 'invoices_client_fk_id_fkey');
      await queryInterface.removeConstraint('estimates', 'estimates_client_fk_id_fkey');

      // Step 6: Rename client_id_new to client_id in invoices table
      await queryInterface.removeColumn('invoices', 'client_fk_id');
      await queryInterface.renameColumn('invoices', 'client_id_new', 'client_id');
      
      // Step 7: Rename client_id_new to client_id in estimates table
      await queryInterface.removeColumn('estimates', 'client_fk_id');
      await queryInterface.renameColumn('estimates', 'client_id_new', 'client_id');

      // Step 8: Add index on the new client_id column in invoices
      await queryInterface.addIndex('invoices', ['client_id']);
      
      // Step 9: Add index on the new client_id column in estimates
      await queryInterface.addIndex('estimates', ['client_id']);

      console.log('Successfully standardized client ID field names in invoices and estimates tables');
    } catch (error) {
      console.error('Error standardizing client ID field names:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    try {
      // Step 1: Add back the client_fk_id column to invoices table
      await queryInterface.addColumn('invoices', 'client_fk_id', {
        type: Sequelize.UUID,
        allowNull: true,
        references: {
          model: 'clients',
          key: 'id'
        }
      });

      // Step 2: Copy data back from client_id to client_fk_id in invoices table
      await queryInterface.sequelize.query(`
        UPDATE invoices
        SET client_fk_id = client_id
        WHERE client_id IS NOT NULL
      `);

      // Step 3: Add back the client_fk_id column to estimates table
      await queryInterface.addColumn('estimates', 'client_fk_id', {
        type: Sequelize.UUID,
        allowNull: true,
        references: {
          model: 'clients',
          key: 'id'
        }
      });

      // Step 4: Copy data back from client_id to client_fk_id in estimates table
      await queryInterface.sequelize.query(`
        UPDATE estimates
        SET client_fk_id = client_id
        WHERE client_id IS NOT NULL
      `);

      // Step 5: Remove the new client_id columns
      await queryInterface.removeColumn('invoices', 'client_id');
      await queryInterface.removeColumn('estimates', 'client_id');
      
      // Step 6: Add indices back on client_fk_id columns
      await queryInterface.addIndex('invoices', ['client_fk_id']);
      await queryInterface.addIndex('estimates', ['client_fk_id']);

      console.log('Successfully reverted client ID field name standardization');
    } catch (error) {
      console.error('Error reverting client ID field name standardization:', error);
      throw error;
    }
  }
};