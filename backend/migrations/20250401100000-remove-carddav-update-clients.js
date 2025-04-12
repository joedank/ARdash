'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      // 1. Add new columns to clients table
      await queryInterface.addColumn('clients', 'display_name', {
        type: Sequelize.STRING,
        allowNull: true, // Initially allow null during migration
      }).catch(error => {
        console.log('Error adding display_name column (may already exist):', error.message);
      });
      
      await queryInterface.addColumn('clients', 'company', {
        type: Sequelize.STRING,
        allowNull: true,
      }).catch(error => {
        console.log('Error adding company column (may already exist):', error.message);
      });
      
      await queryInterface.addColumn('clients', 'email', {
        type: Sequelize.STRING,
        allowNull: true,
      }).catch(error => {
        console.log('Error adding email column (may already exist):', error.message);
      });
      
      await queryInterface.addColumn('clients', 'phone', {
        type: Sequelize.STRING,
        allowNull: true,
      }).catch(error => {
        console.log('Error adding phone column (may already exist):', error.message);
      });
      
      // 2. Transfer data from CardDavCache to Client
      await queryInterface.sequelize.query(`
        UPDATE clients c
        SET 
          display_name = cc.display_name,
          company = cc.company,
          email = cc.email,
          phone = cc.phone
        FROM carddav_cache cc
        WHERE c.carddav_cache_id = cc.id
      `).catch(error => {
        console.log('Error transferring data from carddav_cache to clients:', error.message);
      });
      
      // 3. Make display_name non-nullable after data transfer
      await queryInterface.changeColumn('clients', 'display_name', {
        type: Sequelize.STRING,
        allowNull: false,
      }).catch(error => {
        console.log('Error making display_name non-nullable:', error.message);
      });
      
      // 4. Add index on display_name
      await queryInterface.addIndex('clients', ['display_name'], {
        name: 'clients_display_name'
      }).catch(error => {
        console.log('Error adding index on display_name (may already exist):', error.message);
      });
      
      // 5. Make carddav_cache_id nullable (prepare for removal)
      await queryInterface.changeColumn('clients', 'carddav_cache_id', {
        type: Sequelize.UUID,
        allowNull: true, // Change from false to true
        references: {
          model: 'carddav_cache',
          key: 'id'
        },
        unique: true
      }).catch(error => {
        console.log('Error making carddav_cache_id nullable:', error.message);
      });
      
      console.log('Migration completed successfully');
    } catch (error) {
      console.error('Migration failed:', error);
    }
  },

  down: async (queryInterface, Sequelize) => {
    try {
      // 1. Make carddav_cache_id non-nullable again
      await queryInterface.changeColumn('clients', 'carddav_cache_id', {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'carddav_cache',
          key: 'id'
        },
        unique: true
      }).catch(error => {
        console.log('Error making carddav_cache_id non-nullable:', error.message);
      });
      
      // 2. Remove index on display_name
      await queryInterface.removeIndex('clients', 'clients_display_name').catch(error => {
        console.log('Error removing index on display_name:', error.message);
      });
      
      // 3. Remove new columns
      await queryInterface.removeColumn('clients', 'display_name').catch(error => {
        console.log('Error removing display_name column:', error.message);
      });
      await queryInterface.removeColumn('clients', 'company').catch(error => {
        console.log('Error removing company column:', error.message);
      });
      await queryInterface.removeColumn('clients', 'email').catch(error => {
        console.log('Error removing email column:', error.message);
      });
      await queryInterface.removeColumn('clients', 'phone').catch(error => {
        console.log('Error removing phone column:', error.message);
      });
      
      console.log('Rollback completed successfully');
    } catch (error) {
      console.error('Rollback failed:', error);
    }
  }
};
