'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Check if work_types table already exists at the very beginning
      const exists = await queryInterface.sequelize.query(
        `SELECT EXISTS (
          SELECT FROM information_schema.tables
          WHERE table_name = 'work_types'
        );`,
        { type: Sequelize.QueryTypes.SELECT }
      );

      if (exists[0].exists) {
        console.log('work_types table already exists, skipping entire migration');
        return; // Exit early if the table already exists
      }
      // Create enum for measurement_type if it doesn't exist
      try {
        await queryInterface.sequelize.query(`
          CREATE TYPE enum_work_types_measurement_type AS ENUM ('area', 'linear', 'quantity');
        `);
        console.log('Created enum_work_types_measurement_type enum type');
      } catch (error) {
        // If the enum already exists, just log and continue
        if (error.original && error.original.code === '42710') {
          console.log('Enum type enum_work_types_measurement_type already exists, continuing...');
        } else {
          throw error;
        }
      }

      // Check if work_types table already exists
      const tableExists = await queryInterface.sequelize.query(
        `SELECT EXISTS (
          SELECT FROM information_schema.tables
          WHERE table_name = 'work_types'
        );`,
        { type: Sequelize.QueryTypes.SELECT }
      );

      // Only create the table if it doesn't exist
      if (!tableExists[0].exists) {
        console.log('Creating work_types table...');
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
          unit_cost_material: {
            type: Sequelize.DECIMAL(10, 2),
            allowNull: true
          },
          unit_cost_labor: {
            type: Sequelize.DECIMAL(10, 2),
            allowNull: true
          },
          productivity_unit_per_hr: {
            type: Sequelize.DECIMAL(10, 2),
            allowNull: true
          },
          name_vec: {
            type: Sequelize.VECTOR(384),
            allowNull: true
          },
          revision: {
            type: Sequelize.INTEGER,
            defaultValue: 1,
            allowNull: false
          },
          updated_by: {
            type: Sequelize.UUID,
            allowNull: true
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

        // Add CHECK constraints for non-negative costs
        await queryInterface.sequelize.query(`
          ALTER TABLE work_types
          ADD CONSTRAINT check_unit_cost_material_non_negative
          CHECK (unit_cost_material IS NULL OR unit_cost_material >= 0);
        `);

        await queryInterface.sequelize.query(`
          ALTER TABLE work_types
          ADD CONSTRAINT check_unit_cost_labor_non_negative
          CHECK (unit_cost_labor IS NULL OR unit_cost_labor >= 0);
        `);

        await queryInterface.sequelize.query(`
          ALTER TABLE work_types
          ADD CONSTRAINT check_productivity_unit_per_hr_non_negative
          CHECK (productivity_unit_per_hr IS NULL OR productivity_unit_per_hr >= 0);
        `);
      } else {
        console.log('work_types table already exists, skipping creation');
      }

      // Check if work_type_materials table already exists
      const materialsTableExists = await queryInterface.sequelize.query(
        `SELECT EXISTS (
          SELECT FROM information_schema.tables
          WHERE table_name = 'work_type_materials'
        );`,
        { type: Sequelize.QueryTypes.SELECT }
      );

      // Only create the table if it doesn't exist
      if (!materialsTableExists[0].exists) {
        console.log('Creating work_type_materials table...');
        // Create the work_type_materials table
        await queryInterface.createTable('work_type_materials', {
          id: {
            type: Sequelize.UUID,
            defaultValue: Sequelize.UUIDV4,
            primaryKey: true,
            allowNull: false
          },
          work_type_id: {
            type: Sequelize.UUID,
            allowNull: false,
            references: {
              model: 'work_types',
              key: 'id'
            },
            onDelete: 'CASCADE'
          },
          product_id: {
            type: Sequelize.UUID,
            allowNull: false,
            references: {
              model: 'products',
              key: 'id'
            },
            onDelete: 'RESTRICT'
          },
          qty_per_unit: {
            type: Sequelize.DECIMAL(10, 4),
            allowNull: false,
            defaultValue: 1.0
          },
          unit: {
            type: Sequelize.STRING(20),
            allowNull: false
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

        // Add CHECK constraint for non-negative quantity
        await queryInterface.sequelize.query(`
          ALTER TABLE work_type_materials
          ADD CONSTRAINT check_qty_per_unit_non_negative
          CHECK (qty_per_unit >= 0);
        `);

        // Add unique constraint for work_type_id and product_id
        await queryInterface.addIndex('work_type_materials', ['work_type_id', 'product_id'], {
          name: 'work_type_materials_work_type_id_product_id_unique',
          unique: true
        });

        // Add index on product_id
        await queryInterface.addIndex('work_type_materials', ['product_id'], {
          name: 'work_type_materials_product_id_idx'
        });
      } else {
        console.log('work_type_materials table already exists, skipping creation');
      }

      // Check if work_type_tags table already exists
      const tagsTableExists = await queryInterface.sequelize.query(
        `SELECT EXISTS (
          SELECT FROM information_schema.tables
          WHERE table_name = 'work_type_tags'
        );`,
        { type: Sequelize.QueryTypes.SELECT }
      );

      // Only create the table if it doesn't exist
      if (!tagsTableExists[0].exists) {
        console.log('Creating work_type_tags table...');
        // Create the work_type_tags table
        await queryInterface.createTable('work_type_tags', {
          work_type_id: {
            type: Sequelize.UUID,
            allowNull: false,
            primaryKey: true,
            references: {
              model: 'work_types',
              key: 'id'
            },
            onDelete: 'CASCADE'
          },
          tag: {
            type: Sequelize.STRING(50),
            allowNull: false,
            primaryKey: true
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
      } else {
        console.log('work_type_tags table already exists, skipping creation');
      }

      // Check if work_type_cost_history table already exists
      const costHistoryTableExists = await queryInterface.sequelize.query(
        `SELECT EXISTS (
          SELECT FROM information_schema.tables
          WHERE table_name = 'work_type_cost_history'
        );`,
        { type: Sequelize.QueryTypes.SELECT }
      );

      // Only create the table if it doesn't exist
      if (!costHistoryTableExists[0].exists) {
        console.log('Creating work_type_cost_history table...');
        // Create the work_type_cost_history table
        await queryInterface.createTable('work_type_cost_history', {
          id: {
            type: Sequelize.UUID,
            defaultValue: Sequelize.UUIDV4,
            primaryKey: true,
            allowNull: false
          },
          work_type_id: {
            type: Sequelize.UUID,
            allowNull: false,
            references: {
              model: 'work_types',
              key: 'id'
            },
            onDelete: 'CASCADE'
          },
          region: {
            type: Sequelize.STRING(50),
            allowNull: false,
            defaultValue: 'default'
          },
          unit_cost_material: {
            type: Sequelize.DECIMAL(10, 2),
            allowNull: true
          },
          unit_cost_labor: {
            type: Sequelize.DECIMAL(10, 2),
            allowNull: true
          },
          captured_at: {
            type: Sequelize.DATE,
            allowNull: false,
            defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
          },
          updated_by: {
            type: Sequelize.UUID,
            allowNull: true,
            references: {
              model: 'users',
              key: 'id'
            },
            onDelete: 'SET NULL'
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

        // Add CHECK constraints for non-negative costs in history
        await queryInterface.sequelize.query(`
          ALTER TABLE work_type_cost_history
          ADD CONSTRAINT check_history_unit_cost_material_non_negative
          CHECK (unit_cost_material IS NULL OR unit_cost_material >= 0);
        `);

        await queryInterface.sequelize.query(`
          ALTER TABLE work_type_cost_history
          ADD CONSTRAINT check_history_unit_cost_labor_non_negative
          CHECK (unit_cost_labor IS NULL OR unit_cost_labor >= 0);
        `);

        // Add index on work_type_id and captured_at
        await queryInterface.addIndex('work_type_cost_history', ['work_type_id', 'captured_at'], {
          name: 'work_type_cost_history_work_type_id_captured_at_idx'
        });
      } else {
        console.log('work_type_cost_history table already exists, skipping creation');
      }

      console.log('Successfully created work types tables');
    } catch (error) {
      console.error('Error creating work types tables:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    try {
      // Drop tables in reverse order
      await queryInterface.dropTable('work_type_cost_history');
      await queryInterface.dropTable('work_type_tags');
      await queryInterface.dropTable('work_type_materials');
      await queryInterface.dropTable('work_types');

      // Drop enum
      await queryInterface.sequelize.query(`
        DROP TYPE IF EXISTS enum_work_types_measurement_type;
      `);

      console.log('Successfully dropped work types tables');
    } catch (error) {
      console.error('Error dropping work types tables:', error);
      throw error;
    }
  }
};
