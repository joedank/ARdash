'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Create clients table if it doesn't exist
    await queryInterface.createTable('clients', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
      },
      carddav_cache_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'carddav_cache',
          key: 'id'
        },
        unique: true
      },
      payment_terms: {
        type: Sequelize.STRING,
        allowNull: true
      },
      default_tax_rate: {
        type: Sequelize.DECIMAL(5, 2),
        allowNull: true,
        defaultValue: null
      },
      default_currency: {
        type: Sequelize.STRING(3),
        allowNull: true,
        defaultValue: 'USD'
      },
      notes: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      is_active: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false
      }
    }).catch(error => {
      console.log('Error creating clients table (may already exist):', error.message);
    });

    // Add indexes to clients table
    await queryInterface.addIndex('clients', ['carddav_cache_id'], {
      name: 'clients_carddav_cache_id',
      unique: true
    }).catch(error => {
      console.log('Error creating index on carddav_cache_id (may already exist):', error.message);
    });

    await queryInterface.addIndex('clients', ['is_active'], {
      name: 'clients_is_active'
    }).catch(error => {
      console.log('Error creating index on is_active (may already exist):', error.message);
    });

    // Create client_addresses table if it doesn't exist
    await queryInterface.createTable('client_addresses', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
      },
      client_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'clients',
          key: 'id'
        }
      },
      name: {
        type: Sequelize.STRING,
        allowNull: false,
        comment: 'Name or label for this address (e.g., "Main Office", "Property at 123 Main St")'
      },
      street_address: {
        type: Sequelize.TEXT,
        allowNull: false
      },
      city: {
        type: Sequelize.STRING,
        allowNull: false
      },
      state: {
        type: Sequelize.STRING,
        allowNull: false
      },
      postal_code: {
        type: Sequelize.STRING,
        allowNull: false
      },
      country: {
        type: Sequelize.STRING,
        allowNull: true,
        defaultValue: 'USA'
      },
      is_primary: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
        comment: 'Indicates if this is the primary address for the client'
      },
      notes: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false
      }
    }).catch(error => {
      console.log('Error creating client_addresses table (may already exist):', error.message);
    });

    // Add indexes to client_addresses table
    await queryInterface.addIndex('client_addresses', ['client_id'], {
      name: 'client_addresses_client_id'
    }).catch(error => {
      console.log('Error creating index on client_id (may already exist):', error.message);
    });

    await queryInterface.addIndex('client_addresses', ['is_primary'], {
      name: 'client_addresses_is_primary'
    }).catch(error => {
      console.log('Error creating index on is_primary (may already exist):', error.message);
    });

    // Add client_fk_id columns to invoices and estimates tables if they don't exist
    await queryInterface.sequelize.query(`
      DO $$
      BEGIN
        BEGIN
          ALTER TABLE invoices ADD COLUMN client_fk_id UUID REFERENCES clients(id);
        EXCEPTION
          WHEN duplicate_column THEN
            RAISE NOTICE 'Column client_fk_id already exists in invoices table';
        END;
        
        BEGIN
          ALTER TABLE estimates ADD COLUMN client_fk_id UUID REFERENCES clients(id);
        EXCEPTION
          WHEN duplicate_column THEN
            RAISE NOTICE 'Column client_fk_id already exists in estimates table';
        END;
      END $$;
    `).catch(error => {
      console.log('Error adding client_fk_id columns:', error.message);
    });
  },

  down: async (queryInterface, Sequelize) => {
    // Remove foreign key from invoices and estimates
    await queryInterface.removeColumn('invoices', 'client_fk_id').catch(error => {
      console.log('Error removing client_fk_id from invoices:', error.message);
    });
    
    await queryInterface.removeColumn('estimates', 'client_fk_id').catch(error => {
      console.log('Error removing client_fk_id from estimates:', error.message);
    });

    // Drop client_addresses table
    await queryInterface.dropTable('client_addresses').catch(error => {
      console.log('Error dropping client_addresses table:', error.message);
    });

    // Drop clients table
    await queryInterface.dropTable('clients').catch(error => {
      console.log('Error dropping clients table:', error.message);
    });
  }
};
