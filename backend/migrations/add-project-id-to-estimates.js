'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('estimates', 'project_id', {
      type: Sequelize.UUID,
      allowNull: true,
      references: {
        model: 'projects',
        key: 'id'
      }
    });
    
    await queryInterface.addIndex('estimates', ['project_id']);
  },
  
  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeIndex('estimates', ['project_id']);
    await queryInterface.removeColumn('estimates', 'project_id');
  }
};