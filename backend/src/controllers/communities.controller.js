const communityService = require('../services/communityService');
const { ValidationError, NotFoundError } = require('../utils/errors');
const logger = require('../utils/logger');

/**
 * Get all communities with optional filtering
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.getAllCommunities = async (req, res, next) => {
  try {
    const isActive = req.query.isActive === 'true' ? true :
                     req.query.isActive === 'false' ? false : undefined;

    const communities = await communityService.getAllCommunities({ isActive });

    res.json({
      success: true,
      data: communities
    });
  } catch (error) {
    logger.error('Error in getAllCommunities controller:', error);
    next(error);
  }
};

/**
 * Get a community by ID
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.getCommunityById = async (req, res, next) => {
  try {
    const { id } = req.params;

    // Validate ID is a number
    if (isNaN(parseInt(id))) {
      throw new ValidationError('Community ID must be a number');
    }

    const community = await communityService.getCommunityById(id);

    if (!community) {
      throw new NotFoundError(`Community with ID ${id} not found`);
    }

    res.json({
      success: true,
      data: community
    });
  } catch (error) {
    logger.error(`Error in getCommunityById controller for ID ${req.params.id}:`, error);
    next(error);
  }
};

/**
 * Create a new community
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.createCommunity = async (req, res, next) => {
  try {
    // Validate required fields
    if (!req.body.name) {
      throw new ValidationError('Community name is required');
    }

    const community = await communityService.createCommunity(req.body);

    res.status(201).json({
      success: true,
      data: community,
      message: 'Community created successfully'
    });
  } catch (error) {
    logger.error('Error in createCommunity controller:', error);
    next(error);
  }
};

/**
 * Update a community
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.updateCommunity = async (req, res, next) => {
  try {
    const { id } = req.params;

    // Validate ID is a number
    if (isNaN(parseInt(id))) {
      throw new ValidationError('Community ID must be a number');
    }

    const community = await communityService.updateCommunity(id, req.body);

    res.json({
      success: true,
      data: community,
      message: 'Community updated successfully'
    });
  } catch (error) {
    logger.error(`Error in updateCommunity controller for ID ${req.params.id}:`, error);
    next(error);
  }
};

/**
 * Delete a community
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.deleteCommunity = async (req, res, next) => {
  try {
    const { id } = req.params;

    // Validate ID is a number
    if (isNaN(parseInt(id))) {
      throw new ValidationError('Community ID must be a number');
    }

    await communityService.deleteCommunity(id);

    res.json({
      success: true,
      message: 'Community deleted successfully'
    });
  } catch (error) {
    logger.error(`Error in deleteCommunity controller for ID ${req.params.id}:`, error);
    next(error);
  }
};

/**
 * Search communities
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.searchCommunities = async (req, res, next) => {
  try {
    const { q } = req.query;

    if (!q) {
      throw new ValidationError('Search query is required');
    }

    const communities = await communityService.searchCommunities(q);

    res.json({
      success: true,
      data: communities
    });
  } catch (error) {
    logger.error(`Error in searchCommunities controller for query ${req.query.q}:`, error);
    next(error);
  }
};

/**
 * Set a community's active status
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.setActiveStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { isActive } = req.body;

    // Validate ID is a number
    if (isNaN(parseInt(id))) {
      throw new ValidationError('Community ID must be a number');
    }

    // Validate isActive is a boolean
    if (typeof isActive !== 'boolean') {
      throw new ValidationError('isActive must be a boolean');
    }

    try {
      const community = await communityService.setActiveStatus(id, isActive);

      res.json({
        success: true,
        data: community,
        message: `Community status updated to ${isActive ? 'active' : 'inactive'}`
      });
    } catch (serviceError) {
      // Check if this is a validation error about ad types
      if (serviceError.message && (
          serviceError.message.includes('No ad types defined') ||
          serviceError.message.includes('No ad type selected')
        )) {
        throw new ValidationError(serviceError.message);
      }
      // Re-throw other errors
      throw serviceError;
    }
  } catch (error) {
    logger.error(`Error in setActiveStatus controller for ID ${req.params.id}:`, error);
    next(error);
  }
};

/**
 * Select an ad type for a community
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
exports.selectAdType = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { adTypeId } = req.body;

    // Validate IDs are numbers
    if (isNaN(parseInt(id)) || isNaN(parseInt(adTypeId))) {
      throw new ValidationError('Community ID and Ad Type ID must be numbers');
    }

    const community = await communityService.selectAdType(id, adTypeId);

    res.json({
      success: true,
      data: community,
      message: 'Selected ad type updated successfully'
    });
  } catch (error) {
    logger.error(`Error in selectAdType controller for ID ${req.params.id}:`, error);
    next(error);
  }
};