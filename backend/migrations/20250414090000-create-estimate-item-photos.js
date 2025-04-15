'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('estimate_item_photos', {
      id: {
        allowNull: false,
        primaryKey: true,
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4
      },
      estimate_item_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'estimate_items',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      file_path: {
        type: Sequelize.STRING,
        allowNull: false
      },
      original_name: {
        type: Sequelize.STRING,
        allowNull: true
      },
      photo_type: {
        type: Sequelize.ENUM('progress', 'completed', 'issue', 'material', 'other'),
        allowNull: false,
        defaultValue: 'progress'
      },
      notes: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      metadata: {
        type: Sequelize.JSONB,
        allowNull: true
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });

    // Add an index to improve query performance
    await queryInterface.addIndex('estimate_item_photos', ['estimate_item_id']);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('estimate_item_photos');
  }
};
