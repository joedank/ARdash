'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Create projects table
    await queryInterface.createTable('projects', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
      },
      client_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'clients',
          key: 'id'
        }
      },
      estimate_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: {
          model: 'estimates',
          key: 'id'
        }
      },
      type: {
        type: Sequelize.ENUM('assessment', 'active'),
        allowNull: false,
        defaultValue: 'assessment'
      },
      status: {
        type: Sequelize.ENUM('pending', 'in_progress', 'completed'),
        defaultValue: 'pending',
        allowNull: false
      },
      scheduled_date: {
        type: Sequelize.DATEONLY,
        allowNull: false
      },
      scope: {
        type: Sequelize.TEXT,
        allowNull: true
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

    // Create project_inspections table
    await queryInterface.createTable('project_inspections', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
      },
      project_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'projects',
          key: 'id'
        }
      },
      category: {
        type: Sequelize.ENUM('condition', 'measurements', 'materials'),
        allowNull: false
      },
      content: {
        type: Sequelize.JSONB,
        allowNull: false,
        defaultValue: {}
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false
      }
    });

    // Create project_photos table
    await queryInterface.createTable('project_photos', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
      },
      project_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'projects',
          key: 'id'
        }
      },
      inspection_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: {
          model: 'project_inspections',
          key: 'id'
        }
      },
      photo_type: {
        type: Sequelize.ENUM('before', 'after', 'receipt', 'assessment'),
        allowNull: false
      },
      file_path: {
        type: Sequelize.STRING,
        allowNull: false
      },
      notes: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false
      }
    });

    // Add indexes
    await queryInterface.addIndex('projects', ['scheduled_date']);
    await queryInterface.addIndex('projects', ['client_id']);
    await queryInterface.addIndex('projects', ['estimate_id']);
    await queryInterface.addIndex('project_inspections', ['project_id']);
    await queryInterface.addIndex('project_photos', ['project_id']);
    await queryInterface.addIndex('project_photos', ['inspection_id']);
  },

  down: async (queryInterface, Sequelize) => {
    // Remove tables in reverse order
    await queryInterface.dropTable('project_photos');
    await queryInterface.dropTable('project_inspections');
    await queryInterface.dropTable('projects');
  }
};