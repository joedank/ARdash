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
      return await bcrypt.compare(password, this.password);
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
      type: DataTypes.ENUM('user', 'admin'),
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
        if (user.password) {
          user.password = await bcrypt.hash(user.password, 10);
        }
      },
      beforeUpdate: async (user) => {
        if (user.changed('password')) {
          user.password = await bcrypt.hash(user.password, 10);
        }
      }
    }
  });

  return User;
};
