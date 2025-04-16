import apiService from './api.service';

/**
 * Service for managing application settings
 */
class SettingsService {
  /**
   * Get all settings
   * @returns {Promise} Response data with all settings
   */
  async getAllSettings() {
    return apiService.get('/api/settings');
  }

  /**
   * Get settings by group
   * @param {string} group - Settings group
   * @returns {Promise} Response data with settings in the group
   */
  async getSettingsByGroup(group) {
    return apiService.get(`/api/settings/group/${group}`);
  }

  /**
   * Get a specific setting
   * @param {string} key - Setting key
   * @returns {Promise} Response data with the setting
   */
  async getSetting(key) {
    return apiService.get(`/api/settings/${key}`);
  }

  /**
   * Get a setting value by key
   * @param {string} key - Setting key
   * @param {string} defaultValue - Default value if setting not found
   * @returns {Promise<string>} Setting value or default
   */
  async getSettingValue(key, defaultValue = null) {
    try {
      const response = await this.getSetting(key);
      if (response && response.success && response.data && response.data.value !== undefined) {
        return response.data.value;
      }
      return defaultValue;
    } catch (error) {
      console.error(`Error getting setting value for '${key}':`, error);
      return defaultValue;
    }
  }

  /**
   * Update a setting
   * @param {string} key - Setting key
   * @param {string} value - New value
   * @param {string} group - Optional settings group
   * @returns {Promise} Response data with updated setting
   */
  async updateSetting(key, value, group) {
    return apiService.post(`/api/settings/${key}`, { value, group });
  }

  /**
   * Update multiple settings at once
   * @param {Object} settings - Key-value pairs to update
   * @param {string} group - Optional settings group
   * @returns {Promise} Response data
   */
  async updateMultipleSettings(settings, group) {
    return apiService.post('/api/settings', { settings, group });
  }
}

export default new SettingsService();
