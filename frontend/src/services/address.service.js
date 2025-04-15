import apiService from './api.service';
import { normalizeAddress, isValidUuid } from '../utils/casing';

/**
 * Service for handling address operations with standardized methods
 */
class AddressService {
  /**
   * Get all addresses for a client
   * @param {string} clientId - Client ID
   * @returns {Promise} - Response data with addresses array
   */
  async getClientAddresses(clientId) {
    if (!isValidUuid(clientId)) {
      console.error('Invalid client ID format:', clientId);
      return { success: false, message: 'Invalid client ID format' };
    }
    
    try {
      const response = await apiService.get(`/clients/${clientId}/addresses`);
      
      if (response && response.success && response.data) {
        // Normalize addresses for consistent usage
        return {
          ...response,
          data: response.data.map(address => normalizeAddress(address))
        };
      }
      
      return response;
    } catch (error) {
      console.error('Error fetching client addresses:', error);
      return {
        success: false,
        message: 'Failed to fetch client addresses',
        error: error.message
      };
    }
  }
  
  /**
   * Get the primary address for a client
   * @param {string} clientId - Client ID
   * @returns {Promise} - Response data with primary address or first address
   */
  async getPrimaryAddress(clientId) {
    if (!isValidUuid(clientId)) {
      console.error('Invalid client ID format:', clientId);
      return { success: false, message: 'Invalid client ID format' };
    }
    
    try {
      const response = await this.getClientAddresses(clientId);
      
      if (!response.success || !response.data || response.data.length === 0) {
        return {
          success: false,
          message: 'No addresses found for this client'
        };
      }
      
      // Find primary address or default to the first one
      const primaryAddress = response.data.find(addr => addr.isPrimary) || response.data[0];
      
      return {
        success: true,
        data: primaryAddress
      };
    } catch (error) {
      console.error('Error fetching primary address:', error);
      return {
        success: false,
        message: 'Failed to fetch primary address',
        error: error.message
      };
    }
  }
  
  /**
   * Get an address by ID
   * @param {string} addressId - Address ID
   * @returns {Promise} - Response data with address details
   */
  async getAddressById(addressId) {
    if (!isValidUuid(addressId)) {
      console.error('Invalid address ID format:', addressId);
      return { success: false, message: 'Invalid address ID format' };
    }
    
    try {
      // Since we don't have a direct endpoint for addresses by ID,
      // we need to use the client-specific endpoint
      // In a future API improvement, we would add a direct endpoint
      
      // For now, this is a stub implementation - in practice, you would need
      // to fetch the client ID first or modify the API to support direct address lookup
      console.warn('getAddressById is a stub implementation - consider enhancing the API');
      
      return {
        success: false,
        message: 'Address lookup by ID directly is not yet supported'
      };
    } catch (error) {
      console.error('Error fetching address by ID:', error);
      return {
        success: false,
        message: 'Failed to fetch address',
        error: error.message
      };
    }
  }
  
  /**
   * Get an address with fallback to primary
   * If the specified address cannot be found, falls back to the primary address
   * 
   * @param {string} clientId - Client ID
   * @param {string} addressId - Address ID (optional)
   * @returns {Promise} - Response data with address details
   */
  async getAddressWithFallback(clientId, addressId) {
    if (!isValidUuid(clientId)) {
      console.error('Invalid client ID format:', clientId);
      return { success: false, message: 'Invalid client ID format' };
    }
    
    try {
      // If addressId is provided and valid, try to get that specific address
      if (addressId && isValidUuid(addressId)) {
        const clientAddresses = await this.getClientAddresses(clientId);
        
        if (clientAddresses.success && clientAddresses.data) {
          const matchingAddress = clientAddresses.data.find(addr => addr.id === addressId);
          
          if (matchingAddress) {
            return {
              success: true,
              data: matchingAddress,
              source: 'specified'
            };
          }
        }
      }
      
      // If we can't find the specific address or none was provided, fall back to primary
      const primaryAddress = await this.getPrimaryAddress(clientId);
      
      if (primaryAddress.success && primaryAddress.data) {
        return {
          success: true,
          data: primaryAddress.data,
          source: 'fallback'
        };
      }
      
      // If no addresses exist for this client
      return {
        success: false,
        message: 'No addresses found for this client'
      };
    } catch (error) {
      console.error('Error in getAddressWithFallback:', error);
      return {
        success: false,
        message: 'Failed to fetch address',
        error: error.message
      };
    }
  }
  
  /**
   * Format an address object as a display string
   * @param {Object} address - Address object
   * @returns {string} - Formatted address string
   */
  formatAddressForDisplay(address) {
    if (!address) return '';
    
    const streetAddress = address.streetAddress || address.street_address;
    const postalCode = address.postalCode || address.postal_code;
    
    const parts = [
      streetAddress,
      address.city,
      address.state,
      postalCode,
      address.country
    ].filter(Boolean);
    
    return parts.join(', ');
  }
}

export default new AddressService();
