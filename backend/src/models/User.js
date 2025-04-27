'use strict';
const { Model } = require('sequelize');
// Use our bcrypt compatibility layer that uses bcryptjs instead of bcrypt
const bcrypt = require('../utils/bcrypt-compat');

module.exports = (sequelize, DataTypes) => {
  class User extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here if needed
      // Example: User.hasMany(models.Post);
    }

    // Instance method to check password
    async checkPassword(password) {
      console.log('Inside checkPassword method:');
      console.log('- Plaintext password:', password);
      console.log('- Stored hash:', this.password);
      console.log('- Hash is bcrypt?', /^\$2/.test(this.password));
      const result = await bcrypt.compare(password, this.password);
      console.log('- Password comparison result:', result);
      return result;
    }
  }

  User.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    username: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true
      }
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    firstName: {
      type: DataTypes.STRING,
      allowNull: true,
      field: 'first_name' // Ensure snake_case in DB
    },
    lastName: {
      type: DataTypes.STRING,
      allowNull: true,
      field: 'last_name' // Ensure snake_case in DB
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      field: 'is_active' // Ensure snake_case in DB
    },
    role: {
      type: DataTypes.ENUM('user', 'admin', 'estimator_manager'),
      defaultValue: 'user'
    },
    theme_preference: {
      type: DataTypes.STRING,
      defaultValue: 'dark',
      allowNull: false,
      validate: {
        isIn: [['light', 'dark', 'system']]
      },
      field: 'theme_preference' // Ensure snake_case in DB
    },
    avatar: {
      type: DataTypes.STRING,
      allowNull: true,
      field: 'avatar' // Keep camelCase for consistency with frontend or use snake_case 'avatar_url' if preferred
    }
  }, {
    sequelize,
    modelName: 'User',
    tableName: 'users',
    timestamps: true,
    paranoid: true, // Soft deletes
    underscored: true, // Use snake_case for createdAt, updatedAt, deletedAt
    hooks: {
      beforeCreate: async (user) => {
        // Always hash passwords that aren't already hashed
        if (user.password && !user.password.startsWith('$2')) {
          user.password = await bcrypt.hash(user.password, 10);
        }
      },
      beforeUpdate: async (user) => {
        // Always hash passwords that aren't already hashed
        if (user.changed('password') && !user.password.startsWith('$2')) {
          user.password = await bcrypt.hash(user.password, 10);
        }
      }
    }
  });

  return User;
};
