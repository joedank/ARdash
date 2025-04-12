'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      // 1. Drop the foreign key constraint between clients and carddav_cache
      await queryInterface.sequelize.query(`
        DO $$
        BEGIN
          IF EXISTS (
            SELECT 1 FROM information_schema.table_constraints 
            WHERE constraint_name='clients_carddav_cache_id_fkey' 
            AND table_name='clients'
          ) THEN
            ALTER TABLE clients DROP CONSTRAINT clients_carddav_cache_id_fkey;
          END IF;
        END $$;
      `).catch(error => {
        console.log('Error dropping foreign key constraint (may not exist):', error.message);
      });
      
      // 2. Drop the unique index on carddav_cache_id
      await queryInterface.sequelize.query(`
        DROP INDEX IF EXISTS clients_carddav_cache_id;
      `).catch(error => {
        console.log('Error dropping index (may not exist):', error.message);
      });
      
      // 3. Remove the carddav_cache_id column from the clients table
      await queryInterface.removeColumn('clients', 'carddav_cache_id').catch(error => {
        console.log('Error removing carddav_cache_id column (may not exist):', error.message);
      });
      
      // 4. Drop the carddav_cache table
      await queryInterface.dropTable('carddav_cache').catch(error => {
        console.log('Error dropping carddav_cache table (may not exist):', error.message);
      });
      
      // 5. Delete CardDAV settings from the settings table
      await queryInterface.sequelize.query(`
        DELETE FROM settings WHERE key LIKE 'carddav_%';
      `).catch(error => {
        console.log('Error deleting CardDAV settings:', error.message);
      });
      
      console.log('Final CardDAV removal migration completed successfully');
    } catch (error) {
      console.error('Migration failed:', error);
    }
  },

  down: async (queryInterface, Sequelize) => {
    try {
      // 1. Create the carddav_cache table (simplified schema)
      await queryInterface.createTable('carddav_cache', {
        id: {
          type: Sequelize.UUID,
          defaultValue: Sequelize.UUIDV4,
          primaryKey: true
        },
        client_id: {
          type: Sequelize.STRING,
          allowNull: false,
          unique: true
        },
        card_dav_uri: {
          type: Sequelize.STRING,
          allowNull: false,
          unique: true
        },
        etag: {
          type: Sequelize.STRING,
          allowNull: true
        },
        vcard_data: {
          type: Sequelize.TEXT,
          allowNull: false
        },
        display_name: {
          type: Sequelize.STRING,
          allowNull: false
        },
        company: {
          type: Sequelize.STRING,
          allowNull: true
        },
        email: {
          type: Sequelize.STRING,
          allowNull: true
        },
        phone: {
          type: Sequelize.STRING,
          allowNull: true
        },
        address: {
          type: Sequelize.TEXT,
          allowNull: true
        },
        last_synced: {
          type: Sequelize.DATE,
          defaultValue: Sequelize.NOW
        },
        created_at: {
          type: Sequelize.DATE,
          allowNull: false,
          defaultValue: Sequelize.NOW
        },
        updated_at: {
          type: Sequelize.DATE,
          allowNull: false,
          defaultValue: Sequelize.NOW
        }
      }).catch(error => {
        console.log('Error creating carddav_cache table:', error.message);
      });
      
      // 2. Add carddav_cache_id column back to clients table
      await queryInterface.addColumn('clients', 'carddav_cache_id', {
        type: Sequelize.UUID,
        allowNull: true,
        references: {
          model: 'carddav_cache',
          key: 'id'
        }
      }).catch(error => {
        console.log('Error adding carddav_cache_id column:', error.message);
      });
      
      // 3. Re-add the unique index on carddav_cache_id
      await queryInterface.addIndex('clients', ['carddav_cache_id'], {
        name: 'clients_carddav_cache_id',
        unique: true
      }).catch(error => {
        console.log('Error creating index on carddav_cache_id:', error.message);
      });
      
      // 4. Add back some basic CardDAV settings
      await queryInterface.bulkInsert('settings', [
        {
          key: 'carddav_server_url',
          value: 'https://example.com/dav/addressbooks/',
          group: 'carddav',
          description: 'CardDAV server URL',
          created_at: new Date(),
          updated_at: new Date()
        },
        {
          key: 'carddav_username',
          value: 'username',
          group: 'carddav',
          description: 'CardDAV username',
          created_at: new Date(),
          updated_at: new Date()
        },
        {
          key: 'carddav_password',
          value: 'password',
          group: 'carddav',
          description: 'CardDAV password',
          created_at: new Date(),
          updated_at: new Date()
        }
      ]).catch(error => {
        console.log('Error inserting CardDAV settings:', error.message);
      });
      
      console.log('Rollback completed successfully');
    } catch (error) {
      console.error('Rollback failed:', error);
    }
  }
};
