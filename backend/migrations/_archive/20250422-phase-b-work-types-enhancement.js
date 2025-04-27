'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const transaction = await queryInterface.sequelize.transaction();
    
    try {
      // 1. Add new columns to work_types table
      await queryInterface.addColumn(
        'work_types',
        'unit_cost_material',
        {
          type: Sequelize.DECIMAL(10, 2),
          allowNull: true,
        },
        { transaction }
      );
      
      await queryInterface.addColumn(
        'work_types',
        'unit_cost_labor',
        {
          type: Sequelize.DECIMAL(10, 2),
          allowNull: true,
        },
        { transaction }
      );
      
      await queryInterface.addColumn(
        'work_types',
        'productivity_unit_per_hr',
        {
          type: Sequelize.DECIMAL(10, 2),
          allowNull: true,
        },
        { transaction }
      );
      
      // 2. Create work_type_materials table
      await queryInterface.createTable('work_type_materials', {
        id: {
          type: Sequelize.UUID,
          defaultValue: Sequelize.UUIDV4,
          primaryKey: true
        },
        work_type_id: {
          type: Sequelize.UUID,
          allowNull: false,
          references: {
            model: 'work_types',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'CASCADE'
        },
        product_id: {
          type: Sequelize.UUID,
          allowNull: false,
          references: {
            model: 'products',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'RESTRICT'
        },
        qty_per_unit: {
          type: Sequelize.DECIMAL(10, 2),
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
      }, { transaction });
      
      // 3. Create work_type_tags table
      await queryInterface.createTable('work_type_tags', {
        work_type_id: {
          type: Sequelize.UUID,
          allowNull: false,
          references: {
            model: 'work_types',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'CASCADE',
          primaryKey: true
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
      }, { transaction });
      
      // 4. Create work_type_cost_history table
      await queryInterface.createTable('work_type_cost_history', {
        id: {
          type: Sequelize.UUID,
          defaultValue: Sequelize.UUIDV4,
          primaryKey: true
        },
        work_type_id: {
          type: Sequelize.UUID,
          allowNull: false,
          references: {
            model: 'work_types',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'CASCADE'
        },
        region: {
          type: Sequelize.TEXT,
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
          onUpdate: 'CASCADE',
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
      }, { transaction });

      // Add indexes for performance
      await queryInterface.addIndex('work_type_materials', ['work_type_id'], { transaction });
      await queryInterface.addIndex('work_type_materials', ['product_id'], { transaction });
      await queryInterface.addIndex('work_type_tags', ['work_type_id', 'tag'], { transaction });
      await queryInterface.addIndex('work_type_cost_history', ['work_type_id', 'region'], { transaction });
      await queryInterface.addIndex('work_type_cost_history', ['captured_at'], { transaction });
      
      await transaction.commit();
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  },

  down: async (queryInterface, Sequelize) => {
    const transaction = await queryInterface.sequelize.transaction();
    
    try {
      // Drop tables in reverse order
      await queryInterface.dropTable('work_type_cost_history', { transaction });
      await queryInterface.dropTable('work_type_tags', { transaction });
      await queryInterface.dropTable('work_type_materials', { transaction });
      
      // Remove columns from work_types table
      await queryInterface.removeColumn('work_types', 'productivity_unit_per_hr', { transaction });
      await queryInterface.removeColumn('work_types', 'unit_cost_labor', { transaction });
      await queryInterface.removeColumn('work_types', 'unit_cost_material', { transaction });
      
      await transaction.commit();
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }
};
