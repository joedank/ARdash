const { sequelize } = require('./database');

// Run a query to add the theme_preference column to the users table
(async () => {
  try {
    await sequelize.query(`
      ALTER TABLE users 
      ADD COLUMN IF NOT EXISTS theme_preference VARCHAR(10) NOT NULL DEFAULT 'dark';
    `);
    console.log('Successfully added theme_preference column to users table');
    process.exit(0);
  } catch (error) {
    console.error('Error adding theme_preference column:', error);
    process.exit(1);
  }
})();
