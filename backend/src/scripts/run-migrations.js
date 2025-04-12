'use strict';

const path = require('path');
const { sequelize } = require('../utils/database');
const { Sequelize } = require('sequelize');
const { Umzug, SequelizeStorage } = require('umzug');

// Create Umzug instance for migrations
const umzug = new Umzug({
  migrations: {
    glob: path.join(__dirname, '../migrations/*.js'),
    resolve: ({ name, path, context }) => {
      const migration = require(path);
      return {
        name,
        up: async () => migration.up(context.queryInterface, context.sequelize),
        down: async () => migration.down(context.queryInterface, context.sequelize)
      };
    }
  },
  context: sequelize.getQueryInterface(),
  storage: new SequelizeStorage({ sequelize }),
  logger: console
});

// Create Umzug instance for seeders
const seeder = new Umzug({
  migrations: {
    glob: path.join(__dirname, '../seeders/*.js'),
    resolve: ({ name, path, context }) => {
      const seeder = require(path);
      return {
        name,
        up: async () => seeder.up(context.queryInterface, context.sequelize),
        down: async () => seeder.down(context.queryInterface, context.sequelize)
      };
    }
  },
  context: sequelize.getQueryInterface(),
  storage: new SequelizeStorage({ 
    sequelize,
    tableName: 'sequelizemeta_seeders'
  }),
  logger: console
});

async function runMigrations() {
  console.log('Running migrations...');
  try {
    await umzug.up();
    console.log('All migrations executed successfully');
    return true;
  } catch (error) {
    console.error('Migration failed:', error);
    return false;
  }
}

async function runSeeders() {
  console.log('Running seeders...');
  try {
    await seeder.up();
    console.log('All seeders executed successfully');
    return true;
  } catch (error) {
    console.error('Seeder failed:', error);
    return false;
  }
}

async function main() {
  try {
    // Test database connection
    console.log('Testing database connection...');
    await sequelize.authenticate();
    console.log('Database connection OK!');
    
    // Run migrations
    const migrationsSuccess = await runMigrations();
    if (!migrationsSuccess) {
      process.exit(1);
    }
    
    // Run seeders
    const seedersSuccess = await runSeeders();
    if (!seedersSuccess) {
      process.exit(1);
    }
    
    console.log('All migrations and seeders completed successfully');
    process.exit(0);
  } catch (error) {
    console.error('Unable to connect to the database:', error);
    process.exit(1);
  }
}

// Run the main function
main();
