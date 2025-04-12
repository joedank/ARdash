'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Create ENUM type for role if it doesn't exist
      const enumName = 'enum_users_role';
      const enumValues = ['user', 'admin'];
      await queryInterface.sequelize.query(`
        DO $$ BEGIN
          CREATE TYPE "${enumName}" AS ENUM(${enumValues.map(v => `'${v}'`).join(', ')});
        EXCEPTION
          WHEN duplicate_object THEN null;
        END $$;
      `);

      // Create users table
      await queryInterface.createTable('users', {
        id: {
          type: Sequelize.UUID,
          defaultValue: Sequelize.UUIDV4,
          primaryKey: true
        },
        username: {
          type: Sequelize.STRING,
          allowNull: false,
          unique: true
        },
        email: {
          type: Sequelize.STRING,
          allowNull: false,
          unique: true
          // Email validation is typically handled at the model/application level
        },
        password: {
          type: Sequelize.STRING,
          allowNull: false
        },
        first_name: { // Corresponds to firstName in model
          type: Sequelize.STRING,
          allowNull: true
        },
        last_name: { // Corresponds to lastName in model
          type: Sequelize.STRING,
          allowNull: true
        },
        is_active: { // Corresponds to isActive in model
          type: Sequelize.BOOLEAN,
          defaultValue: true,
          allowNull: false
        },
        role: {
          type: enumName, // Use the created ENUM type
          defaultValue: 'user',
          allowNull: false
        },
        theme_preference: { // Corresponds to theme_preference in model
          type: Sequelize.STRING,
          defaultValue: 'dark',
          allowNull: false
          // isIn validation is model level
        },
        avatar: { // Corresponds to avatar in model
          type: Sequelize.STRING,
          allowNull: true
        },
        created_at: { // Corresponds to underscored: true
          type: Sequelize.DATE,
          allowNull: false,
          defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
        },
        updated_at: { // Corresponds to underscored: true
          type: Sequelize.DATE,
          allowNull: false,
          defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
        },
        deleted_at: { // Corresponds to paranoid: true
          type: Sequelize.DATE,
          allowNull: true
        }
      });

      // Add indexes
      await queryInterface.addIndex('users', ['username'], { unique: true });
      await queryInterface.addIndex('users', ['email'], { unique: true });

    } catch (error) {
      console.error('Failed to create users table:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    try {
      await queryInterface.dropTable('users');
      // Optionally drop the ENUM type if no other table uses it
      await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_users_role";');
    } catch (error) {
      console.error('Failed to drop users table:', error);
      throw error;
    }
  }
};