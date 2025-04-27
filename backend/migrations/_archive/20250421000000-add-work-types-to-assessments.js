'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Check if pgvector extension is available
    let vectorExtensionAvailable = false;
    try {
      await queryInterface.sequelize.query('SELECT 1 FROM pg_extension WHERE extname = \'vector\';');
      vectorExtensionAvailable = true;
      console.log('pgvector extension is already installed');
    } catch (error) {
      console.warn('Warning: pgvector extension is not available. Vector operations will be skipped.');
      console.warn('Error details:', error.message);
    }
    // Step 1: Add the work_types JSONB column to projects (assessments)
    try {
      await queryInterface.sequelize.query(`
        ALTER TABLE projects
        ADD COLUMN work_types JSONB DEFAULT '[]'::jsonb;
      `);
      console.log('Added work_types JSONB column to projects table');
    } catch (error) {
      console.error('Error adding work_types column to projects table:', error.message);
      throw error;
    }

    // Step 2: Create the assessment_work_types table for tracking relationships
    try {
      await queryInterface.createTable('assessment_work_types', {
        id: {
          type: Sequelize.UUID,
          defaultValue: Sequelize.literal('gen_random_uuid()'),
          primaryKey: true
        },
        assessment_id: {
          type: Sequelize.UUID,
          allowNull: false,
          references: {
            model: 'projects',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'CASCADE'
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
        confidence: {
          type: Sequelize.DECIMAL(4, 3),
          allowNull: true,
          comment: '0-1 similarity score'
        },
        created_at: {
          type: Sequelize.DATE,
          allowNull: false,
          defaultValue: Sequelize.fn('NOW')
        }
      });
      console.log('Created assessment_work_types table');

      // Step 3: Create index for quick fetch in ProjectView
      await queryInterface.addIndex('assessment_work_types', ['assessment_id'], {
        name: 'idx_awt_assessment'
      });
      console.log('Added index idx_awt_assessment on assessment_work_types.assessment_id');
    } catch (error) {
      console.error('Error creating assessment_work_types table:', error.message);
      throw error;
    }
  },

  down: async (queryInterface, Sequelize) => {
    // Drop the assessment_work_types table
    try {
      await queryInterface.dropTable('assessment_work_types');
      console.log('Dropped assessment_work_types table');
    } catch (error) {
      console.error('Error dropping assessment_work_types table:', error.message);
    }

    // Remove the work_types column from projects table
    try {
      await queryInterface.sequelize.query(`
        ALTER TABLE projects
        DROP COLUMN IF EXISTS work_types;
      `);
      console.log('Removed work_types column from projects table');
    } catch (error) {
      console.error('Error removing work_types column:', error.message);
    }
  }
};
