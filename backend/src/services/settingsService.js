const { Settings } = require('../models');
const logger = require('../utils/logger');

/**
 * Service for managing application settings
 */
class SettingsService {
  /**
   * Get a setting by key
   * @param {string} key - Setting key
   * @returns {Promise<Object|null>} - Setting object or null
   */
  async getSetting(key) {
    try {
      return await Settings.findOne({
        where: { key }
      });
    } catch (error) {
      logger.error(`Error getting setting '${key}':`, error);
      throw error;
    }
  }

  /**
   * Get a setting value by key
   * @param {string} key - Setting key
   * @param {string} defaultValue - Default value if setting not found
   * @returns {Promise<string|null>} - Setting value or default
   */
  async getSettingValue(key, defaultValue = null) {
    try {
      const setting = await this.getSetting(key);
      return setting ? setting.value : defaultValue;
    } catch (error) {
      logger.error(`Error getting setting value '${key}':`, error);
      return defaultValue;
    }
  }

  /**
   * Update a setting
   * @param {string} key - Setting key
   * @param {string} value - New value
   * @param {string} group - Optional group name
   * @returns {Promise<Object>} - Updated setting
   */
  async updateSetting(key, value, group = 'general') {
    try {
      // Use findOrCreate and rely on model's timestamp settings
      const [setting, created] = await Settings.findOrCreate({
        where: { key },
        defaults: {
          key,
          value,
          group
          // Timestamps (createdAt, updatedAt) handled by Sequelize
          // due to timestamps: true and underscored: true in model
        }
      });

      if (!created) {
        // If record existed, update value and group if provided
        // updatedAt will be handled automatically by Sequelize
        await setting.update({
          value,
          group: group || setting.group
        });
      }

      // Return the instance (either newly created or found/updated)
      return setting;
    } catch (error) {
      logger.error(`Error updating setting '${key}':`, error);
      throw error;
    }
  }

  /**
   * Delete a setting
   * @param {string} key - Setting key
   * @returns {Promise<boolean>} - Success status
   */
  async deleteSetting(key) {
    try {
      const result = await Settings.destroy({
        where: { key }
      });

      return result > 0;
    } catch (error) {
      logger.error(`Error deleting setting '${key}':`, error);
      throw error;
    }
  }

  /**
   * Get all settings
   * @returns {Promise<Array>} - All settings
   */
  async getAllSettings() {
    try {
      return await Settings.findAll({
        order: [
          ['group', 'ASC'],
          ['key', 'ASC']
        ]
      });
    } catch (error) {
      logger.error('Error getting all settings:', error);
      throw error;
    }
  }

  /**
   * Get settings by group
   * @param {string} group - Settings group
   * @returns {Promise<Array>} - Settings in the group
   */
  async getSettingsByGroup(group) {
    try {
      return await Settings.findAll({
        where: { group },
        order: [['key', 'ASC']]
      });
    } catch (error) {
      logger.error(`Error getting settings for group '${group}':`, error);
      throw error;
    }
  }

  /**
   * Get settings for multiple groups
   * @param {Array<string>} groups - Settings groups
   * @returns {Promise<Object>} - Settings grouped by group name
   */
  async getSettingsByGroups(groups) {
    try {
      const settings = await Settings.findAll({
        where: {
          group: groups
        },
        order: [
          ['group', 'ASC'],
          ['key', 'ASC']
        ]
      });

      // Group settings by group name
      const groupedSettings = {};
      for (const setting of settings) {
        if (!groupedSettings[setting.group]) {
          groupedSettings[setting.group] = [];
        }
        groupedSettings[setting.group].push(setting);
      }

      return groupedSettings;
    } catch (error) {
      logger.error(`Error getting settings for groups '${groups}':`, error);
      throw error;
    }
  }

  /**
   * Update multiple settings at once
   * @param {Object} settings - Key-value pairs to update
   * @param {string} group - Optional group for new settings
   * @returns {Promise<boolean>} - Success status
   */
  async updateMultipleSettings(settings, group = 'general') {
    try {
      // Log the settings being updated
      logger.debug(`Updating ${Object.keys(settings).length} settings in group: ${group}`);
      logger.debug('Settings keys being updated:', Object.keys(settings));
      
      // Use Sequelize transaction to ensure all operations succeed or fail together
      await Settings.sequelize.transaction(async (transaction) => {
        for (const [key, value] of Object.entries(settings)) {
          try {
            // Handle special case for explicit null (signals deletion)
            if (value === null) {
              // Delete the setting if it exists
              await Settings.destroy({
                where: { key },
                transaction
              });
              logger.debug(`Deleted setting '${key}'`);
              continue;
            }
            
            // Skip empty or undefined values to prevent overwriting existing settings with blank values
            if (value === '' || value === undefined || (typeof value === 'string' && value.trim() === '')) {
              logger.debug(`Skipping empty or whitespace-only value for setting '${key}'`);
              continue;
            }
            
            // Use Sequelize upsert method to handle both insert and update cases
            // This will properly handle quoting reserved words like "group" and "value"
            await Settings.upsert(
              {
                key,
                value,
                group
                // timestamps (updatedAt, createdAt) handled automatically by Sequelize
              },
              { transaction }
            );
            
            logger.debug(`Upserted setting '${key}'`);
          } catch (settingError) {
            // Log the error for this specific setting
            logger.error(`Error upserting setting '${key}':`, settingError);
            // Re-throw to trigger transaction rollback
            throw settingError;
          }
        }
      });
      
      logger.info(`Successfully updated all ${Object.keys(settings).length} settings in group: ${group}`);
      return true;
    } catch (error) {
      logger.error('Error updating multiple settings:', error);
      throw error;
    }
  }

  /**
   * Initialize default PDF settings if they don't exist
   * @returns {Promise<boolean>} - Success status
   */
  async initializePdfSettings() {
    try {
      const defaultSettings = [
        {
          key: 'company_name',
          value: 'Your Company',
          group: 'company',
          description: 'Company name displayed on invoices and estimates'
        },
        {
          key: 'company_address',
          value: '123 Business St, Suite 100, City, State, 12345',
          group: 'company',
          description: 'Company address displayed on invoices and estimates'
        },
        {
          key: 'company_phone',
          value: '(555) 123-4567',
          group: 'company',
          description: 'Company phone number displayed on invoices and estimates'
        },
        {
          key: 'company_email',
          value: 'billing@yourcompany.com',
          group: 'company',
          description: 'Company email displayed on invoices and estimates'
        },
        {
          key: 'company_website',
          value: 'www.yourcompany.com',
          group: 'company',
          description: 'Company website displayed on invoices and estimates'
        },
        {
          key: 'company_logo_path',
          value: '',
          group: 'company',
          description: 'Path to company logo file for invoices and estimates'
        },
        {
          key: 'primary_color',
          value: '#3b82f6',
          group: 'appearance',
          description: 'Primary color for PDF documents (hex code)'
        },
        {
          key: 'pdf_invoice_footer',
          value: 'Thank you for your business. Please contact us with any questions regarding this invoice.',
          group: 'invoice',
          description: 'Custom footer text for invoice PDFs'
        },
        {
          key: 'pdf_estimate_footer',
          value: 'Thank you for considering our services. Please contact us with any questions regarding this estimate.',
          group: 'estimate',
          description: 'Custom footer text for estimate PDFs'
        }
      ];

      for (const setting of defaultSettings) {
        await Settings.findOrCreate({
          where: { key: setting.key },
          defaults: setting
        });
      }

      logger.info('PDF settings initialized successfully');
      return true;
    } catch (error) {
      logger.error('Error initializing PDF settings:', error);
      return false;
    }
  }
}

module.exports = new SettingsService();
