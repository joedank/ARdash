'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    try {
      const columns = await queryInterface.describeTable('users');
      if (!columns.avatar) {
        console.log('Adding avatar column to users table');
        await queryInterface.addColumn('users', 'avatar', {
          type: Sequelize.STRING,
          allowNull: true,
          // field: 'avatar' // Sequelize handles underscored: true from model
        });
      } else {
        console.log('Column avatar already exists in users table.');
        // Optionally ensure it allows null if it exists but doesn't
        await queryInterface.changeColumn('users', 'avatar', {
           type: Sequelize.STRING,
           allowNull: true
        });
      }
    } catch (error) {
       console.error('Failed migration add-avatar-to-users:', error);
       if (error.name === 'SequelizeDatabaseError' && error.message.includes('relation "users" does not exist')) {
          console.warn('Users table does not exist yet, skipping avatar addition.');
       } else {
          throw error;
       }
    }
  },

  async down (queryInterface, Sequelize) {
    try {
       console.log('Removing avatar column from users table');
      await queryInterface.removeColumn('users', 'avatar');
    } catch (error) {
       console.error('Failed migration reversal add-avatar-to-users:', error);
       if (error.name === 'SequelizeDatabaseError' && error.message.includes('relation "users" does not exist')) {
          console.warn('Users table does not exist, skipping avatar removal.');
       } else {
          console.warn('Could not remove avatar column, it might not exist.');
       }
    }
  }
};
