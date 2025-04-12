'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('projects', 'assessment_id', {
      type: Sequelize.UUID,
      allowNull: true,
      references: {
        model: 'projects',
        key: 'id'
      }
    });
    
    await queryInterface.addIndex('projects', ['assessment_id']);
  },
  
  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeIndex('projects', ['assessment_id']);
    await queryInterface.removeColumn('projects', 'assessment_id');
  }
};