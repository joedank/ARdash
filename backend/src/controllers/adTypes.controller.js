const adTypeService = require('../services/adTypeService');
const { ValidationError, NotFoundError } = require('../utils/errors');
const logger = require('../utils/logger');

/**
 * Get all ad types for a community
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.getAdTypesForCommunity = async (req, res, next) => {
  try {
    const { communityId } = req.params;
    
    // Validate communityId is a number
    if (isNaN(parseInt(communityId))) {
      throw new ValidationError('Community ID must be a number');
    }
    
    const adTypes = await adTypeService.getAdTypesForCommunity(communityId);
    
    res.json({
      success: true,
      data: adTypes
    });
  } catch (error) {
    logger.error(`Error in getAdTypesForCommunity controller for community ID ${req.params.communityId}:`, error);
    next(error);
  }
};

/**
 * Get an ad type by ID
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.getAdTypeById = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    // Validate ID is a number
    if (isNaN(parseInt(id))) {
      throw new ValidationError('Ad Type ID must be a number');
    }
    
    const adType = await adTypeService.getAdTypeById(id);
    
    if (!adType) {
      throw new NotFoundError(`Ad Type with ID ${id} not found`);
    }
    
    res.json({
      success: true,
      data: adType
    });
  } catch (error) {
    logger.error(`Error in getAdTypeById controller for ID ${req.params.id}:`, error);
    next(error);
  }
};

/**
 * Create a new ad type
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.createAdType = async (req, res, next) => {
  try {
    // Validate required fields
    if (!req.body.name) {
      throw new ValidationError('Ad type name is required');
    }
    
    if (!req.body.community_id && !req.params.communityId) {
      throw new ValidationError('Community ID is required');
    }
    
    // Use community_id from body or from params
    const adTypeData = {
      ...req.body,
      community_id: req.body.community_id || req.params.communityId
    };
    
    const adType = await adTypeService.createAdType(adTypeData);
    
    res.status(201).json({
      success: true,
      data: adType,
      message: 'Ad type created successfully'
    });
  } catch (error) {
    logger.error('Error in createAdType controller:', error);
    next(error);
  }
};

/**
 * Update an ad type
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.updateAdType = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    // Validate ID is a number
    if (isNaN(parseInt(id))) {
      throw new ValidationError('Ad Type ID must be a number');
    }
    
    const adType = await adTypeService.updateAdType(id, req.body);
    
    res.json({
      success: true,
      data: adType,
      message: 'Ad type updated successfully'
    });
  } catch (error) {
    logger.error(`Error in updateAdType controller for ID ${req.params.id}:`, error);
    next(error);
  }
};

/**
 * Delete an ad type
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.deleteAdType = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    // Validate ID is a number
    if (isNaN(parseInt(id))) {
      throw new ValidationError('Ad Type ID must be a number');
    }
    
    await adTypeService.deleteAdType(id);
    
    res.json({
      success: true,
      message: 'Ad type deleted successfully'
    });
  } catch (error) {
    logger.error(`Error in deleteAdType controller for ID ${req.params.id}:`, error);
    next(error);
  }
};