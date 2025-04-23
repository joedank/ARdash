'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // First, make sure the pg_trgm extension is available
    await queryInterface.sequelize.query('CREATE EXTENSION IF NOT EXISTS pg_trgm;');
    
    // Create the ENUM type for measurement types
    await queryInterface.sequelize.query(
      `CREATE TYPE enum_work_types_measurement_type AS ENUM ('area', 'linear', 'quantity');`
    );
    
    // Create the work_types table
    await queryInterface.createTable('work_types', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false
      },
      name: {
        type: Sequelize.STRING(255),
        allowNull: false
      },
      parent_bucket: {
        type: Sequelize.STRING(100),
        allowNull: false
      },
      measurement_type: {
        type: Sequelize.ENUM('area', 'linear', 'quantity'),
        allowNull: false
      },
      suggested_units: {
        type: Sequelize.STRING(50),
        allowNull: false
      },
      name_vec: {
        type: Sequelize.VECTOR(384),
        allowNull: true,
        comment: 'Vector embedding for semantic similarity search'
      },
      revision: {
        type: Sequelize.INTEGER,
        defaultValue: 1,
        allowNull: false,
        comment: 'Revision number for tracking updates'
      },
      updated_by: {
        type: Sequelize.UUID,
        allowNull: true,
        comment: 'User ID of the last person to update this record'
      },
      created_at: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
        allowNull: false
      },
      updated_at: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
        allowNull: false
      }
    });
    
    // Add check constraint on suggested_units based on measurement_type
    await queryInterface.sequelize.query(`
      ALTER TABLE work_types 
      ADD CONSTRAINT check_suggested_units 
      CHECK (
        (measurement_type = 'area' AND suggested_units IN ('sq ft', 'sq yd', 'sq m')) OR
        (measurement_type = 'linear' AND suggested_units IN ('ft', 'in', 'yd', 'm')) OR
        (measurement_type = 'quantity' AND suggested_units IN ('each', 'job', 'set'))
      );
    `);
    
    // Create indexes for efficient queries
    await queryInterface.addIndex('work_types', {
      fields: ['parent_bucket'],
      name: 'idx_work_types_parent_bucket'
    });
    
    // Create trigram index for similarity search
    await queryInterface.sequelize.query(`
      CREATE INDEX idx_work_types_name ON work_types USING gin (name gin_trgm_ops);
    `);
    
    // Add table and column comments
    await queryInterface.sequelize.query(`
      COMMENT ON TABLE work_types IS 'Mobile-home repair and remodel work types with measurement specifications';
      COMMENT ON COLUMN work_types.id IS 'Unique identifier for the work type';
      COMMENT ON COLUMN work_types.name IS 'Descriptive name of the work type';
      COMMENT ON COLUMN work_types.parent_bucket IS 'Category grouping (Interior-Structural, Interior-Finish, Exterior-Structural, Exterior-Finish, Mechanical)';
      COMMENT ON COLUMN work_types.measurement_type IS 'Type of measurement (area, linear, quantity)';
      COMMENT ON COLUMN work_types.suggested_units IS 'Suggested unit for measurement (sq ft, ft, each, job, etc.)';
      COMMENT ON COLUMN work_types.name_vec IS 'Vector embedding for semantic similarity search';
      COMMENT ON COLUMN work_types.revision IS 'Revision number for tracking updates';
      COMMENT ON COLUMN work_types.updated_by IS 'User ID of the last person to update this record';
    `);
  },

  down: async (queryInterface, Sequelize) => {
    // Drop the work_types table
    await queryInterface.dropTable('work_types');
    
    // Drop the ENUM type
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS enum_work_types_measurement_type;');
    
    // Note: We don't drop the pg_trgm extension as it might be used by other tables
  }
};
