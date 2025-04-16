const { AdType, Community, sequelize } = require('../models');
const logger = require('../utils/logger');

/**
 * Service for handling ad type operations
 */
class AdTypeService {
  /**
   * Get all ad types for a community
   * @param {number} communityId - Community ID
   * @returns {Promise<Array>} - List of ad types
   */
  async getAdTypesForCommunity(communityId) {
    try {
      return await AdType.findAll({
        where: { community_id: communityId },
        order: [['name', 'ASC']]
      });
    } catch (error) {
      logger.error(`Error getting ad types for community ${communityId}:`, error);
      throw error;
    }
  }

  /**
   * Get an ad type by ID
   * @param {number} id - Ad Type ID
   * @returns {Promise<Object|null>} - Ad type object
   */
  async getAdTypeById(id) {
    try {
      return await AdType.findByPk(id, {
        include: [
          {
            model: Community,
            as: 'community',
            required: false
          }
        ]
      });
    } catch (error) {
      logger.error(`Error getting ad type by ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Create a new ad type
   * @param {Object} adTypeData - Ad type data
   * @returns {Promise<Object>} - Created ad type
   */
  async createAdType(adTypeData) {
    try {
      // Verify the community exists
      const community = await Community.findByPk(adTypeData.community_id);
      if (!community) {
        throw new Error(`Community with ID ${adTypeData.community_id} not found`);
      }

      // Create the ad type
      const adType = await AdType.create(adTypeData);
      logger.info(`Created new ad type: ${adTypeData.name} for community ${adTypeData.community_id}`);

      return adType;
    } catch (error) {
      logger.error('Error creating ad type:', error);
      throw error;
    }
  }

  /**
   * Update an ad type
   * @param {number} id - Ad Type ID
   * @param {Object} data - Updated ad type data
   * @returns {Promise<Object>} - Updated ad type
   */
  async updateAdType(id, data) {
    try {
      const adType = await AdType.findByPk(id);
      if (!adType) {
        throw new Error(`Ad Type with ID ${id} not found`);
      }

      // Update the ad type
      await adType.update(data);
      logger.info(`Updated ad type with ID: ${id}`);

      return adType;
    } catch (error) {
      logger.error(`Error updating ad type ${id}:`, error);
      throw error;
    }
  }

  /**
   * Delete an ad type
   * @param {number} id - Ad Type ID
   * @returns {Promise<boolean>} - Success status
   */
  async deleteAdType(id) {
    let transaction;

    try {
      transaction = await sequelize.transaction();

      const adType = await AdType.findByPk(id);
      if (!adType) {
        throw new Error(`Ad Type with ID ${id} not found`);
      }

      // Check if this ad type is selected by any communities
      const selectedBy = await Community.findOne({
        where: { selected_ad_type_id: id }
      });

      if (selectedBy) {
        // Update community to remove reference to this ad type
        await selectedBy.update({ selected_ad_type_id: null }, { transaction });
      }

      // Delete the ad type
      await adType.destroy({ transaction });
      await transaction.commit();

      logger.info(`Deleted ad type with ID: ${id}`);
      return true;
    } catch (error) {
      if (transaction) await transaction.rollback();
      logger.error(`Error deleting ad type ${id}:`, error);
      throw error;
    }
  }
}

module.exports = new AdTypeService();
