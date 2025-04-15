const { ClientAddress } = require('../models');
const logger = require('../utils/logger');

/**
 * Service for handling standardized address operations
 */
class AddressService {
  /**
   * Get all addresses for a client
   * 
   * @param {string} clientId - Client ID
   * @returns {Promise<Array>} - Array of addresses
   */
  async getClientAddresses(clientId) {
    try {
      return await ClientAddress.findAll({
        where: { client_id: clientId },
        order: [
          ['is_primary', 'DESC'], // Primary addresses first
          ['created_at', 'DESC']  // Then most recently created
        ]
      });
    } catch (error) {
      logger.error(`Error getting addresses for client ${clientId}:`, error);
      throw error;
    }
  }

  /**
   * Get the primary address for a client
   * Falls back to the most recently created address if no primary is set
   * 
   * @param {string} clientId - Client ID
   * @returns {Promise<Object|null>} - Primary address or null if none exist
   */
  async getPrimaryAddress(clientId) {
    try {
      // First try to get the primary address
      let address = await ClientAddress.findOne({
        where: {
          client_id: clientId,
          is_primary: true
        }
      });
      
      // If no primary address exists, get the most recent address
      if (!address) {
        address = await ClientAddress.findOne({
          where: { client_id: clientId },
          order: [['created_at', 'DESC']]
        });
      }
      
      return address;
    } catch (error) {
      logger.error(`Error getting primary address for client ${clientId}:`, error);
      throw error;
    }
  }

  /**
   * Get a specific address by ID
   * 
   * @param {string} addressId - Address ID
   * @returns {Promise<Object|null>} - Address or null if not found
   */
  async getAddressById(addressId) {
    try {
      return await ClientAddress.findByPk(addressId);
    } catch (error) {
      logger.error(`Error getting address ${addressId}:`, error);
      throw error;
    }
  }

  /**
   * Add a new address for a client
   * 
   * @param {string} clientId - Client ID
   * @param {Object} addressData - Address data
   * @returns {Promise<Object>} - Created address
   */
  async addClientAddress(clientId, addressData) {
    try {
      // If this is marked as primary, ensure other addresses are not primary
      if (addressData.is_primary) {
        await ClientAddress.update(
          { is_primary: false },
          { where: { client_id: clientId } }
        );
      }
      
      // Create the new address
      return await ClientAddress.create({
        ...addressData,
        client_id: clientId
      });
    } catch (error) {
      logger.error(`Error adding address for client ${clientId}:`, error);
      throw error;
    }
  }

  /**
   * Update an address
   * 
   * @param {string} addressId - Address ID
   * @param {Object} addressData - Address data to update
   * @returns {Promise<Object>} - Updated address
   */
  async updateAddress(addressId, addressData) {
    try {
      const address = await ClientAddress.findByPk(addressId);
      
      if (!address) {
        throw new Error(`Address ${addressId} not found`);
      }
      
      // If this address is being set as primary, update other addresses
      if (addressData.is_primary && !address.is_primary) {
        await ClientAddress.update(
          { is_primary: false },
          { where: { client_id: address.client_id } }
        );
      }
      
      // Update the address
      await address.update(addressData);
      
      return address;
    } catch (error) {
      logger.error(`Error updating address ${addressId}:`, error);
      throw error;
    }
  }

  /**
   * Delete an address
   * 
   * @param {string} addressId - Address ID
   * @returns {Promise<boolean>} - Success indicator
   */
  async deleteAddress(addressId) {
    try {
      const address = await ClientAddress.findByPk(addressId);
      
      if (!address) {
        throw new Error(`Address ${addressId} not found`);
      }
      
      await address.destroy();
      
      // If this was a primary address, set another address as primary
      if (address.is_primary) {
        const otherAddress = await ClientAddress.findOne({
          where: { client_id: address.client_id },
          order: [['created_at', 'DESC']]
        });
        
        if (otherAddress) {
          await otherAddress.update({ is_primary: true });
        }
      }
      
      return true;
    } catch (error) {
      logger.error(`Error deleting address ${addressId}:`, error);
      throw error;
    }
  }

  /**
   * Format an address object as a display string
   * 
   * @param {Object} address - Address object
   * @returns {string} - Formatted address string
   */
  formatAddressForDisplay(address) {
    if (!address) return '';
    
    const parts = [
      address.street_address,
      address.city,
      address.state,
      address.postal_code,
      address.country
    ].filter(Boolean);
    
    return parts.join(', ');
  }
}

module.exports = new AddressService();
