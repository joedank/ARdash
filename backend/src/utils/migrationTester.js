'use strict';

const path = require('path');
const fs = require('fs');
const { exec } = require('child_process');
const util = require('util');
const execAsync = util.promisify(exec);

/**
 * Provides utilities for testing migrations in isolation
 */
class MigrationTester {
  /**
   * Creates a new MigrationTester
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    this.migrationPath = options.migrationPath || path.join(process.cwd(), 'src', 'migrations');
    this.testDbConfig = options.testDbConfig || {
      username: 'postgres',
      password: 'postgres',
      database: 'management_test_db',
      host: 'localhost',
      port: 5432,
      dialect: 'postgres'
    };
    this.logger = options.logger || console;
    this.backupDir = options.backupDir || path.join(process.cwd(), 'database', 'backups');
  }

  /**
   * Creates a test database backup
   * @param {string} [suffix] - Optional suffix for the backup name
   * @returns {Promise<string>} - Path to the backup file
   */
  async createBackup(suffix = '') {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const backupName = `test_db_backup_${timestamp}${suffix}.sql`;
    const backupPath = path.join(this.backupDir, backupName);
    
    // Ensure backup directory exists
    if (!fs.existsSync(this.backupDir)) {
      fs.mkdirSync(this.backupDir, { recursive: true });
    }
    
    const { host, port, username, database } = this.testDbConfig;
    const command = `pg_dump -h ${host} -p ${port} -U ${username} -d ${database} -f ${backupPath}`;
    
    try {
      await execAsync(command);
      this.logger.info(`Created backup at ${backupPath}`);
      return backupPath;
    } catch (error) {
      this.logger.error(`Failed to create backup: ${error.message}`);
      throw error;
    }
  }

  /**
   * Restores a database from backup
   * @param {string} backupPath - Path to the backup file
   * @returns {Promise<boolean>} - Success indicator
   */
  async restoreFromBackup(backupPath) {
    const { host, port, username, database } = this.testDbConfig;
    const command = `psql -h ${host} -p ${port} -U ${username} -d ${database} -f ${backupPath}`;
    
    try {
      await execAsync(command);
      this.logger.info(`Restored from backup ${backupPath}`);
      return true;
    } catch (error) {
      this.logger.error(`Failed to restore backup: ${error.message}`);
      throw error;
    }
  }

  /**
   * Tests a migration file in isolation
   * @param {string} migrationFile - Migration filename
   * @returns {Promise<Object>} - Test results
   */
  async testMigration(migrationFile) {
    const fullPath = path.join(this.migrationPath, migrationFile);
    
    if (!fs.existsSync(fullPath)) {
      throw new Error(`Migration file not found: ${fullPath}`);
    }
    
    // Create backup before testing
    const backupPath = await this.createBackup(`_pre_${migrationFile}`);
    
    try {
      // Apply migration using Sequelize CLI
      await execAsync(`npx sequelize-cli db:migrate --to ${migrationFile}`);
      
      // Test if we can undo the migration
      await execAsync(`npx sequelize-cli db:migrate:undo --name ${migrationFile}`);
      
      // Re-apply to leave in applied state
      await execAsync(`npx sequelize-cli db:migrate --to ${migrationFile}`);
      
      return {
        success: true,
        file: migrationFile,
        backup: backupPath,
        message: 'Migration test successful'
      };
    } catch (error) {
      // Restore from backup on failure
      await this.restoreFromBackup(backupPath);
      
      return {
        success: false,
        file: migrationFile,
        backup: backupPath,
        error: error.message,
        message: 'Migration test failed - database restored from backup'
      };
    }
  }
}

module.exports = MigrationTester;