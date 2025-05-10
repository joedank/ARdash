'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // This migration removes pre_assessments table and related references
    // Since we've already done this manually, we'll just check if items exist before trying to remove them
    
    try {
      // Check if the table exists before trying to drop it
      const tableExists = await queryInterface.sequelize.query(
        "SELECT EXISTS (SELECT FROM pg_catalog.pg_tables WHERE schemaname = 'public' AND tablename = 'pre_assessments')",
        { type: Sequelize.QueryTypes.SELECT }
      );
      
      if (tableExists[0].exists) {
        // Check for foreign key constraints
        const constraints = await queryInterface.sequelize.query(
          "SELECT conname FROM pg_constraint WHERE confrelid = 'pre_assessments'::regclass",
          { type: Sequelize.QueryTypes.SELECT }
        );
        
        // Remove all foreign key constraints
        for (const constraint of constraints) {
          const tableName = await queryInterface.sequelize.query(
            `SELECT conrelid::regclass::text FROM pg_constraint WHERE conname = '${constraint.conname}'`,
            { type: Sequelize.QueryTypes.SELECT }
          );
          
          await queryInterface.removeConstraint(tableName[0].conrelid, constraint.conname);
        }
        
        // Drop the table
        await queryInterface.dropTable('pre_assessments');
      }
      
      // Check if pre_assessment_id column exists in projects table
      const projectColumns = await queryInterface.describeTable('projects').catch(() => null);
      if (projectColumns && projectColumns.pre_assessment_id) {
        await queryInterface.removeColumn('projects', 'pre_assessment_id');
      }
      
    } catch (error) {
      console.log('Migration already applied or error occurred:', error.message);
    }
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
