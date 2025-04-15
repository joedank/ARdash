const addressService = require('../services/addressService');
const logger = require('../utils/logger');

/**
 * Get all addresses for a client
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getClientAddresses = async (req, res) => {
  try {
    const { clientId } = req.params;
    
    const addresses = await addressService.getClientAddresses(clientId);
    
    return res.status(200).json({
      success: true,
      data: addresses
    });
  } catch (error) {
    logger.error(`Error getting addresses for client ${req.params.clientId}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get addresses',
      error: error.message
    });
  }
};

/**
 * Get primary address for a client
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getPrimaryAddress = async (req, res) => {
  try {
    const { clientId } = req.params;
    
    const address = await addressService.getPrimaryAddress(clientId);
    
    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'No addresses found for this client'
      });
    }
    
    return res.status(200).json({
      success: true,
      data: address
    });
  } catch (error) {
    logger.error(`Error getting primary address for client ${req.params.clientId}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get primary address',
      error: error.message
    });
  }
};

/**
 * Get address by ID
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getAddressById = async (req, res) => {
  try {
    const { addressId } = req.params;
    
    const address = await addressService.getAddressById(addressId);
    
    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'Address not found'
      });
    }
    
    return res.status(200).json({
      success: true,
      data: address
    });
  } catch (error) {
    logger.error(`Error getting address ${req.params.addressId}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get address',
      error: error.message
    });
  }
};

/**
 * Create a new address for a client
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const createAddress = async (req, res) => {
  try {
    const { clientId } = req.params;
    const addressData = req.body;
    
    // Validate required fields
    const requiredFields = ['name', 'street_address', 'city', 'state', 'postal_code'];
    for (const field of requiredFields) {
      if (!addressData[field]) {
        return res.status(400).json({
          success: false,
          message: `${field} is required`
        });
      }
    }
    
    const address = await addressService.addClientAddress(clientId, addressData);
    
    return res.status(201).json({
      success: true,
      message: 'Address created successfully',
      data: address
    });
  } catch (error) {
    logger.error(`Error creating address for client ${req.params.clientId}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to create address',
      error: error.message
    });
  }
};

/**
 * Update an address
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const updateAddress = async (req, res) => {
  try {
    const { addressId } = req.params;
    const addressData = req.body;
    
    // Remove any fields that shouldn't be updated directly
    delete addressData.id;
    delete addressData.client_id;
    
    const address = await addressService.updateAddress(addressId, addressData);
    
    return res.status(200).json({
      success: true,
      message: 'Address updated successfully',
      data: address
    });
  } catch (error) {
    logger.error(`Error updating address ${req.params.addressId}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to update address',
      error: error.message
    });
  }
};

/**
 * Delete an address
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const deleteAddress = async (req, res) => {
  try {
    const { addressId } = req.params;
    
    await addressService.deleteAddress(addressId);
    
    return res.status(200).json({
      success: true,
      message: 'Address deleted successfully'
    });
  } catch (error) {
    logger.error(`Error deleting address ${req.params.addressId}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to delete address',
      error: error.message
    });
  }
};

module.exports = {
  getClientAddresses,
  getPrimaryAddress,
  getAddressById,
  createAddress,
  updateAddress,
  deleteAddress
};
