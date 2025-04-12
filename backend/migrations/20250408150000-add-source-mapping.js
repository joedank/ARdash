'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    // Add source mapping columns to estimate_items
    await queryInterface.addColumn('estimate_items', 'product_id', {
      type: Sequelize.UUID,
      allowNull: true,
      references: {
        model: 'products',
        key: 'id'
      }
    });

    await queryInterface.addColumn('estimate_items', 'source_data', {
      type: Sequelize.JSONB,
      allowNull: true
    });

    await queryInterface.addColumn('estimate_items', 'unit', {
      type: Sequelize.STRING(50),
      allowNull: true
    });

    await queryInterface.addColumn('estimate_items', 'custom_product_data', {
      type: Sequelize.JSONB,
      allowNull: true
    });

    // Create source_maps table
    await queryInterface.createTable('source_maps', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
      },
      estimate_item_id: {
        type: Sequelize.UUID,
        references: {
          model: 'estimate_items',
          key: 'id'
        },
        onDelete: 'CASCADE'
      },
      source_type: {
        type: Sequelize.STRING(50),
        allowNull: false
      },
      source_data: {
        type: Sequelize.JSONB,
        allowNull: false
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false
      }
    });

    // Add indexes
    await queryInterface.addIndex('estimate_items', ['product_id']);
    await queryInterface.addIndex('source_maps', ['estimate_item_id']);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('source_maps');
    await queryInterface.removeColumn('estimate_items', 'product_id');
    await queryInterface.removeColumn('estimate_items', 'source_data');
    await queryInterface.removeColumn('estimate_items', 'unit');
    await queryInterface.removeColumn('estimate_items', 'custom_product_data');
  }
};