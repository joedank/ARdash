const { Community, AdType, sequelize } = require('../models');
const logger = require('../utils/logger');
const { Op } = require('sequelize');

/**
 * Service for handling community and ad type operations
 */
class CommunityService {
  /**
   * Get all communities with optional filtering
   * @param {Object} filters - Optional filters including isActive
   * @returns {Promise<Array>} - List of communities
   */
  async getAllCommunities(filters = {}) {
    try {
      const whereClause = {};

      // Apply is_active filter if provided
      if (filters.isActive !== undefined) {
        whereClause.is_active = filters.isActive;
      }

      return await Community.findAll({
        where: whereClause,
        include: [
          {
            model: AdType,
            as: 'selectedAdType',
            required: false
          }
        ],
        order: [['name', 'ASC']]
      });
    } catch (error) {
      logger.error('Error getting all communities:', error);
      throw error;
    }
  }

  /**
   * Get a community by ID with all associated ad types
   * @param {number} id - Community ID
   * @returns {Promise<Object|null>} - Complete community object with ad types
   */
  async getCommunityById(id) {
    try {
      return await Community.findByPk(id, {
        include: [
          {
            model: AdType,
            as: 'adTypes',
            required: false
          },
          {
            model: AdType,
            as: 'selectedAdType',
            required: false
          }
        ]
      });
    } catch (error) {
      logger.error(`Error getting community by ID: ${id}:`, error);
      throw error;
    }
  }

  /**
   * Create a new community
   * @param {Object} communityData - Community data
   * @returns {Promise<Object>} - Created community
   */
  async createCommunity(communityData) {
    try {
      // Create the community
      const community = await Community.create(communityData);
      logger.info(`Created new community: ${communityData.name} with ID: ${community.id}`);

      return community;
    } catch (error) {
      logger.error('Error creating community:', error);
      throw error;
    }
  }

  /**
   * Update a community
   * @param {number} id - Community ID
   * @param {Object} data - Updated community data
   * @returns {Promise<Object>} - Updated community
   */
  async updateCommunity(id, data) {
    try {
      const community = await Community.findByPk(id);

      if (!community) {
        throw new Error(`Community with ID ${id} not found`);
      }

      // Update the community
      await community.update(data);
      logger.info(`Updated community with ID: ${id}`);

      return community;
    } catch (error) {
      logger.error(`Error updating community ${id}:`, error);
      throw error;
    }
  }

  /**
   * Delete a community
   * @param {number} id - Community ID
   * @returns {Promise<boolean>} - Success status
   */
  async deleteCommunity(id) {
    let transaction;

    try {
      transaction = await sequelize.transaction();

      const community = await Community.findByPk(id);
      if (!community) {
        throw new Error(`Community with ID ${id} not found`);
      }

      // Delete associated ad types
      await AdType.destroy({
        where: { community_id: id },
        transaction
      });

      // Delete the community
      await community.destroy({ transaction });
      await transaction.commit();

      logger.info(`Deleted community with ID: ${id}`);
      return true;
    } catch (error) {
      if (transaction) await transaction.rollback();
      logger.error(`Error deleting community ${id}:`, error);
      throw error;
    }
  }

  /**
   * Search for communities by name or city
   * @param {string} query - Search query
   * @returns {Promise<Array>} - Matched communities
   */
  async searchCommunities(query) {
    try {
      const searchQuery = `%${query}%`;
      return await Community.findAll({
        where: {
          [Op.or]: [
            { name: { [Op.iLike]: searchQuery } },
            { city: { [Op.iLike]: searchQuery } }
          ]
        },
        include: [
          {
            model: AdType,
            as: 'selectedAdType',
            required: false
          }
        ],
        order: [['name', 'ASC']]
      });
    } catch (error) {
      logger.error(`Error searching communities with query "${query}":`, error);
      throw error;
    }
  }

  /**
   * Set a community's active status
   * @param {number} id - Community ID
   * @param {boolean} isActive - New active status
   * @returns {Promise<Object>} - Updated community
   */
  async setActiveStatus(id, isActive) {
    let transaction;

    try {
      transaction = await sequelize.transaction();

      // Get the community with its ad types
      const community = await Community.findByPk(id, {
        include: [
          {
            model: AdType,
            as: 'adTypes',
            required: false
          }
        ],
        transaction
      });

      if (!community) {
        throw new Error(`Community with ID ${id} not found`);
      }

      // If trying to activate, validate that the community has ad types and a selected ad type
      if (isActive) {
        // Check if the community has ad types
        if (!community.adTypes || community.adTypes.length === 0) {
          throw new Error(`Cannot activate community ${id}: No ad types defined`);
        }

        // Check if the community has a selected ad type
        if (!community.selected_ad_type_id) {
          throw new Error(`Cannot activate community ${id}: No ad type selected`);
        }
      }

      await community.update({ is_active: isActive }, { transaction });
      await transaction.commit();

      logger.info(`Updated active status for community ${id} to ${isActive}`);
      return community;
    } catch (error) {
      if (transaction) await transaction.rollback();
      logger.error(`Error updating active status for community ${id}:`, error);
      throw error;
    }
  }

  /**
   * Select an ad type for a community
   * @param {number} communityId - Community ID
   * @param {number} adTypeId - Ad Type ID
   * @returns {Promise<Object>} - Updated community
   */
  async selectAdType(communityId, adTypeId) {
    try {
      // Verify the ad type exists and belongs to this community
      const adType = await AdType.findOne({
        where: {
          id: adTypeId,
          community_id: communityId
        }
      });

      if (!adType) {
        throw new Error(`Ad Type with ID ${adTypeId} not found for community ${communityId}`);
      }

      // Update the community with the selected ad type
      const community = await Community.findByPk(communityId);
      if (!community) {
        throw new Error(`Community with ID ${communityId} not found`);
      }

      await community.update({ selected_ad_type_id: adTypeId });
      logger.info(`Selected ad type ${adTypeId} for community ${communityId}`);
      return community;
    } catch (error) {
      logger.error(`Error selecting ad type for community ${communityId}:`, error);
      throw error;
    }
  }
}

module.exports = new CommunityService();
