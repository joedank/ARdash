'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    try {
      const columns = await queryInterface.describeTable('users');

      if (!columns.created_at) {
        console.log('Adding created_at column to users table');
        await queryInterface.addColumn('users', 'created_at', {
          type: Sequelize.DATE,
          allowNull: false,
          defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
        });
      } else {
         console.log('Column created_at already exists in users table.');
         // Ensure it's not nullable and has default if it exists but lacks these
         await queryInterface.changeColumn('users', 'created_at', {
             type: Sequelize.DATE,
             allowNull: false,
             defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
         });
      }

      if (!columns.updated_at) {
         console.log('Adding updated_at column to users table');
        await queryInterface.addColumn('users', 'updated_at', {
          type: Sequelize.DATE,
          allowNull: false,
          defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
        });
      } else {
         console.log('Column updated_at already exists in users table.');
          // Ensure it's not nullable and has default if it exists but lacks these
         await queryInterface.changeColumn('users', 'updated_at', {
             type: Sequelize.DATE,
             allowNull: false,
             defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
         });
      }
    } catch (error) {
       console.error('Failed migration add-timestamps-to-users:', error);
       // Allow migration to continue if table doesn't exist yet (should be created by previous migration)
       if (error.name === 'SequelizeDatabaseError' && error.message.includes('relation "users" does not exist')) {
          console.warn('Users table does not exist yet, skipping timestamp addition.');
       } else {
          throw error;
       }
    }
  },

  async down (queryInterface, Sequelize) {
    try {
       console.log('Removing created_at and updated_at columns from users table');
      await queryInterface.removeColumn('users', 'created_at');
      await queryInterface.removeColumn('users', 'updated_at');
    } catch (error) {
       console.error('Failed migration reversal add-timestamps-to-users:', error);
        if (error.name === 'SequelizeDatabaseError' && error.message.includes('relation "users" does not exist')) {
          console.warn('Users table does not exist, skipping timestamp removal.');
       } else {
          // Don't throw error on down migration failure for robustness
          console.warn('Could not remove timestamp columns, they might not exist.');
       }
    }
  }
};
