'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('estimate_item_additional_work', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
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
      description: {
        type: Sequelize.TEXT,
        allowNull: false
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.fn('NOW')
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.fn('NOW')
      }
    });

    // Add index for faster lookups
    await queryInterface.addIndex('estimate_item_additional_work', ['estimate_item_id']);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('estimate_item_additional_work');
  }
};
