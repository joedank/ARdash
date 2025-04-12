const settingsService = require('../services/settingsService');
const logger = require('../utils/logger');

/**
 * Get all settings
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getAllSettings = async (req, res) => {
  try {
    const settings = await settingsService.getAllSettings();
    return res.status(200).json({
      success: true,
      data: settings
    });
  } catch (error) {
    logger.error('Error getting all settings:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get settings',
      error: error.message
    });
  }
};

/**
 * Get settings by group
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getSettingsByGroup = async (req, res) => {
  try {
    const { group } = req.params;
    
    const settings = await settingsService.getSettingsByGroup(group);
    return res.status(200).json({
      success: true,
      data: settings
    });
  } catch (error) {
    logger.error(`Error getting settings for group: ${req.params.group}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get settings by group',
      error: error.message
    });
  }
};

/**
 * Get a specific setting
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getSetting = async (req, res) => {
  try {
    const { key } = req.params;
    
    const setting = await settingsService.getSetting(key);
    
    if (!setting) {
      return res.status(404).json({
        success: false,
        message: 'Setting not found'
      });
    }
    
    return res.status(200).json({
      success: true,
      data: setting
    });
  } catch (error) {
    logger.error(`Error getting setting by key: ${req.params.key}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get setting',
      error: error.message
    });
  }
};

/**
 * Update a setting
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const updateSetting = async (req, res) => {
  try {
    const { key } = req.params;
    const { value, group } = req.body;
    
    if (value === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Value is required'
      });
    }
    
    const setting = await settingsService.updateSetting(key, value, group);
    
    return res.status(200).json({
      success: true,
      message: 'Setting updated successfully',
      data: setting
    });
  } catch (error) {
    logger.error(`Error updating setting: ${req.params.key}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to update setting',
      error: error.message
    });
  }
};

/**
 * Update multiple settings
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const updateMultipleSettings = async (req, res) => {
  try {
    const { settings, group } = req.body;
    
    if (!settings || !Object.keys(settings).length) {
      return res.status(400).json({
        success: false,
        message: 'Settings object is required'
      });
    }
    
    await settingsService.updateMultipleSettings(settings, group);
    
    return res.status(200).json({
      success: true,
      message: 'Settings updated successfully'
    });
  } catch (error) {
    logger.error('Error updating multiple settings:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to update settings',
      error: error.message
    });
  }
};

/**
 * Delete a setting
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const deleteSetting = async (req, res) => {
  try {
    const { key } = req.params;
    
    const success = await settingsService.deleteSetting(key);
    
    if (!success) {
      return res.status(404).json({
        success: false,
        message: 'Setting not found or could not be deleted'
      });
    }
    
    return res.status(200).json({
      success: true,
      message: 'Setting deleted successfully'
    });
  } catch (error) {
    logger.error(`Error deleting setting: ${req.params.key}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to delete setting',
      error: error.message
    });
  }
};

module.exports = {
  getAllSettings,
  getSettingsByGroup,
  getSetting,
  updateSetting,
  updateMultipleSettings,
  deleteSetting
};
