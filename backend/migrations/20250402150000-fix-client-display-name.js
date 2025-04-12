'use strict';

/**
 * Migration to ensure client display_name is properly configured
 * and add a name alias to display_name for backwards compatibility
 */
module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      // First check if display_name column exists
      const tableInfo = await queryInterface.sequelize.query(
        `SELECT column_name, data_type 
         FROM information_schema.columns 
         WHERE table_name = 'clients' AND column_name = 'display_name'`
      );
      
      // If display_name doesn't exist, create it
      if (tableInfo[0].length === 0) {
        await queryInterface.addColumn('clients', 'display_name', {
          type: Sequelize.STRING,
          allowNull: false,
          defaultValue: 'Unknown Client'
        });
        
        // Index the display_name field for better performance
        await queryInterface.addIndex('clients', ['display_name']);
      }
      
      // Create a virtual column for name that returns display_name
      // This is done through a database view
      await queryInterface.sequelize.query(`
        CREATE OR REPLACE VIEW client_view AS
        SELECT 
          id,
          display_name AS name,
          company,
          email,
          phone,
          payment_terms,
          default_tax_rate,
          default_currency,
          notes,
          is_active,
          client_type,
          created_at,
          updated_at
        FROM clients;
      `);
      
      console.log('Migration completed successfully: client display_name setup');
    } catch (error) {
      console.error('Migration failed:', error);
      throw error;
    }
  },

  down: async (queryInterface, Sequelize) => {
    try {
      // Drop the view
      await queryInterface.sequelize.query('DROP VIEW IF EXISTS client_view');
      
      // We don't remove the display_name column to avoid data loss
      console.log('Migration rolled back successfully');
    } catch (error) {
      console.error('Migration rollback failed:', error);
      throw error;
    }
  }
};
