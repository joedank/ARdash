'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      const tables = await queryInterface.showAllTables();
      const tableExists = tables.includes('carddav_cache');

      if (tableExists) {
        console.log('carddav_cache table exists. Checking columns...');
        const columns = await queryInterface.describeTable('carddav_cache');

        // Rename columns if they exist with camelCase names
        if (columns.clientId && !columns.client_id) {
          console.log('Renaming clientId to client_id');
          await queryInterface.renameColumn('carddav_cache', 'clientId', 'client_id');
        }
        if (columns.cardDavUri && !columns.card_dav_uri) {
          console.log('Renaming cardDavUri to card_dav_uri');
          await queryInterface.renameColumn('carddav_cache', 'cardDavUri', 'card_dav_uri');
        }
        if (columns.vcardData && !columns.vcard_data) {
          console.log('Renaming vcardData to vcard_data');
          await queryInterface.renameColumn('carddav_cache', 'vcardData', 'vcard_data');
        }
        if (columns.displayName && !columns.display_name) {
          console.log('Renaming displayName to display_name');
          await queryInterface.renameColumn('carddav_cache', 'displayName', 'display_name');
        }
        if (columns.lastSynced && !columns.last_synced) {
          console.log('Renaming lastSynced to last_synced');
          await queryInterface.renameColumn('carddav_cache', 'lastSynced', 'last_synced');
        }
        // Add missing columns if necessary (e.g., created_at, updated_at if table was created manually before)
        if (!columns.created_at) {
           await queryInterface.addColumn('carddav_cache', 'created_at', { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') });
        }
         if (!columns.updated_at) {
           await queryInterface.addColumn('carddav_cache', 'updated_at', { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') });
        }


      } else {
        console.log('carddav_cache table does not exist. Creating table...');
        // Create the table with snake_case column names
        await queryInterface.createTable('carddav_cache', {
          id: {
            type: Sequelize.UUID,
            defaultValue: Sequelize.UUIDV4,
            primaryKey: true
          },
          client_id: {
            type: Sequelize.STRING,
            allowNull: false,
            unique: true,
            comment: 'NextCloud contact UID'
          },
          card_dav_uri: {
            type: Sequelize.STRING,
            allowNull: false,
            unique: true,
            comment: 'Full CardDAV URI for the contact'
          },
          etag: {
            type: Sequelize.STRING,
            allowNull: true,
            comment: 'ETag for tracking changes'
          },
          vcard_data: {
            type: Sequelize.TEXT,
            allowNull: false,
            comment: 'Full vCard data'
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
             defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
          },
          updated_at: {
            type: Sequelize.DATE,
            allowNull: false,
             defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
          }
        });

        // Add indexes
        await queryInterface.addIndex('carddav_cache', ['client_id'], {
          name: 'carddav_cache_client_id',
          unique: true
        });

        await queryInterface.addIndex('carddav_cache', ['card_dav_uri'], {
          name: 'carddav_cache_card_dav_uri',
          unique: true
        });
      }
    } catch (error) {
      console.error('Migration failed:', error);
      throw error;
    }
  },

  down: async (queryInterface, Sequelize) => {
    // Reverting this is complex and potentially destructive if columns were renamed.
    // A simple approach is to drop the table if it exists.
    console.log('Reverting fix-carddav-cache migration by dropping the table.');
    await queryInterface.dropTable('carddav_cache').catch(error => {
       console.error('Error dropping carddav_cache table during revert:', error);
       // Ignore error if table doesn't exist
    });
  }
};
