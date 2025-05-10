'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // First, get all foreign key constraints that reference pre_assessments
    const foreignKeys = await queryInterface.getForeignKeys('projects');
    const preAssessmentFK = foreignKeys.find(fk => fk.referencedTableName === 'pre_assessments');
    
    // Remove foreign key constraint if exists
    if (preAssessmentFK) {
      await queryInterface.removeConstraint('projects', preAssessmentFK.constraintName);
    }
    
    // Check for any column referencing pre_assessments and drop it
    const projectColumns = await queryInterface.describeTable('projects');
    if (projectColumns.pre_assessment_id) {
      await queryInterface.removeColumn('projects', 'pre_assessment_id');
    }
    
    // Drop the pre_assessments table
    await queryInterface.dropTable('pre_assessments');
  },

  down: async (queryInterface, Sequelize) => {
    // Recreate minimal pre_assessments table so migration is reversible
    await queryInterface.createTable('pre_assessments', {
      id: {
        type: Sequelize.UUID,
        primaryKey: true,
        defaultValue: Sequelize.literal('gen_random_uuid()')
      },
      client_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: 'clients', key: 'id' },
        onDelete: 'CASCADE'
      },
      client_address_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: 'client_addresses', key: 'id' },
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
  }
};
