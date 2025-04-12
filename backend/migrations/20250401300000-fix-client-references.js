'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      // Update invoice records to ensure client_fk_id is properly set
      await queryInterface.sequelize.query(`
        UPDATE invoices i
        SET client_fk_id = c.id
        FROM clients c, carddav_cache cc
        WHERE i.client_id = cc.uid
        AND c.carddav_cache_id = cc.id
        AND i.client_fk_id IS NULL;
      `).catch(error => {
        console.log('Error updating invoice client_fk_id:', error.message);
      });
      
      // Update estimate records to ensure client_fk_id is properly set
      await queryInterface.sequelize.query(`
        UPDATE estimates e
        SET client_fk_id = c.id
        FROM clients c, carddav_cache cc
        WHERE e.client_id = cc.uid
        AND c.carddav_cache_id = cc.id
        AND e.client_fk_id IS NULL;
      `).catch(error => {
        console.log('Error updating estimate client_fk_id:', error.message);
      });
      
      // For any remaining invoices/estimates without client_fk_id, try to match directly by client name
      await queryInterface.sequelize.query(`
        UPDATE invoices i
        SET client_fk_id = c.id
        FROM clients c
        WHERE i.client_fk_id IS NULL
        AND i.client_name = c.display_name;
      `).catch(error => {
        console.log('Error updating invoice client_fk_id by name:', error.message);
      });
      
      await queryInterface.sequelize.query(`
        UPDATE estimates e
        SET client_fk_id = c.id
        FROM clients c
        WHERE e.client_fk_id IS NULL
        AND e.client_name = c.display_name;
      `).catch(error => {
        console.log('Error updating estimate client_fk_id by name:', error.message);
      });
      
      console.log('Migration to fix client references completed successfully');
    } catch (error) {
      console.error('Migration failed:', error);
    }
  },

  down: async (queryInterface, Sequelize) => {
    console.log('No rollback needed for this migration as it only fixes data inconsistencies');
    return Promise.resolve();
  }
};
