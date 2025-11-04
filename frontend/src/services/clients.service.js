import apiService from './api.service';
import { normalizeClient, toSnakeCase, isValidUuid } from '../utils/casing';

/**
 * Service for handling client operations
 */
class ClientsService {
  /**
   * Create a new client
   * @param {Object} clientData - Client data (name, email, etc.)
   * @returns {Promise} Response data with created client
   */
  async createClient(clientData) {
    try {
      // Convert camelCase to snake_case for backend
      const snakeCaseData = toSnakeCase(clientData);
      const response = await apiService.post('/clients', snakeCaseData);

      if (response.success && response.data) {
        return {
          ...response,
          data: normalizeClient(response.data)
        };
      }

      return response;
    } catch (error) {
      console.error('Error creating client:', error);
      return {
        success: false,
        message: 'Failed to create client',
        error: error.message
      };
    }
  }

  /**
   * Get all clients
   * @param {Object} options - Optional filters
   * @param {string} options.type - Client type filter (property_manager or resident)
   * @returns {Promise} Response data with clients array
   */
  async getAllClients(options = {}) {
    try {
      let queryParams = '';

      if (options.type) {
        queryParams = `?type=${options.type}`;
      }

      const response = await apiService.get(`/clients${queryParams}`);

      if (response.success && response.data) {
        const normalizedData = response.data.map(client => normalizeClient(client));
        
        return {
          ...response,
          data: normalizedData
        };
      }

      return response;
    } catch (error) {
      console.error('Error fetching clients:', error);
      return {
        success: false,
        message: 'Failed to fetch clients',
        error: error.message
      };
    }
  }

  /**
   * Get clients by type
   * @param {string} type - Client type (property_manager or resident)
   * @returns {Promise} Response data with clients array
   */
  async getClientsByType(type) {
    try {
      const response = await apiService.get(`/clients/type/${type}`);

      if (response.success && response.data) {
        return {
          ...response,
          data: response.data.map(client => normalizeClient(client))
        };
      }

      return response;
    } catch (error) {
      console.error('Error fetching clients by type:', error);
      return {
        success: false,
        message: 'Failed to fetch clients by type',
        error: error.message
      };
    }
  }

  /**
   * Search clients by name, company, or email
   * @param {string} query - Search query
   * @param {string} type - Optional client type filter
   * @returns {Promise} Response data with matching clients
   */
  async searchClients(query, type = null) {
    try {
      const typeParam = type ? `&type=${type}` : '';
      const response = await apiService.get(`/clients/search?q=${encodeURIComponent(query)}${typeParam}`);

      if (response.success && response.data) {
        return {
          ...response,
          data: response.data.map(client => normalizeClient(client))
        };
      }

      return response;
    } catch (error) {
      console.error('Error searching clients:', error);
      return {
        success: false,
        message: 'Failed to search clients',
        error: error.message
      };
    }
  }

  /**
   * Get client by ID
   * @param {string} id - Client ID
   * @returns {Promise} Response data with client details
   */
  async getClientById(id) {
    if (!isValidUuid(id)) {
      console.error('Invalid client ID format:', id);
      return { success: false, message: 'Invalid client ID format' };
    }

    try {
      const response = await apiService.get(`/clients/${id}`);

      if (response.success && response.data) {
        return {
          ...response,
          data: normalizeClient(response.data)
        };
      }

      return response;
    } catch (error) {
      console.error('Error fetching client:', error);
      return {
        success: false,
        message: 'Failed to fetch client',
        error: error.message
      };
    }
  }

  /**
   * Get client by ID (alias for getClientById for backward compatibility)
   * @param {string} id - Client ID
   * @returns {Promise} Response data with client details
   */
  async getClient(id) {
    return this.getClientById(id);
  }

  /**
   * Update client settings including nested address updates
   * @param {string} id - Client ID
   * @param {Object} data - Client data to update (including addresses array)
   * @returns {Promise} Response data with updated client
   */
  async updateClient(id, data) {
    if (!isValidUuid(id)) {
      console.error('Invalid client ID format:', id);
      return { success: false, message: 'Invalid client ID format' };
    }

    try {
      // Make a copy of the data to avoid modifying the original
      const dataCopy = { ...data };
      
      // Extract _deleted_address_ids before conversion if it exists (it's already snake_case)
      const deletedAddressIds = dataCopy._deleted_address_ids;
      delete dataCopy._deleted_address_ids;
      
      // Convert camelCase to snake_case for backend, including all nested address objects
      const snakeCaseData = toSnakeCase(dataCopy);
      
      // Add back _deleted_address_ids if it existed (avoid double conversion)
      if (deletedAddressIds) {
        snakeCaseData._deleted_address_ids = deletedAddressIds;
      }
      
      const response = await apiService.put(`/clients/${id}`, snakeCaseData);

      if (response.success && response.data) {
        return {
          ...response,
          data: normalizeClient(response.data)
        };
      }

      return response;
    } catch (error) {
      console.error('Error updating client:', error);
      return {
        success: false,
        message: 'Failed to update client',
        error: error.message
      };
    }
  }

  /**
   * Add a new address to a client
   * @param {string} clientId - Client ID
   * @param {Object} addressData - Address data
   * @returns {Promise} Response data with created address
   */
  async addClientAddress(clientId, addressData) {
    if (!isValidUuid(clientId)) {
      console.error('Invalid client ID format:', clientId);
      return { success: false, message: 'Invalid client ID format' };
    }

    try {
      // Convert camelCase to snake_case for backend
      const snakeCaseData = toSnakeCase(addressData);
      return await apiService.post(`/clients/${clientId}/addresses`, snakeCaseData);
    } catch (error) {
      console.error('Error adding address:', error);
      return {
        success: false,
        message: 'Failed to add address',
        error: error.message
      };
    }
  }

  /**
   * Update a client address
   * @param {string} clientId - Client ID
   * @param {string} addressId - Address ID
   * @param {Object} addressData - Address data to update
   * @returns {Promise} Response data with updated address
   */
  async updateClientAddress(clientId, addressId, addressData) {
    if (!isValidUuid(clientId) || !isValidUuid(addressId)) {
      console.error('Invalid ID format:', { clientId, addressId });
      return { success: false, message: 'Invalid ID format' };
    }

    try {
      // Convert camelCase to snake_case for backend
      const snakeCaseData = toSnakeCase(addressData);
      return await apiService.put(`/clients/${clientId}/addresses/${addressId}`, snakeCaseData);
    } catch (error) {
      console.error('Error updating address:', error);
      return {
        success: false,
        message: 'Failed to update address',
        error: error.message
      };
    }
  }

  /**
   * Delete a client address
   * @param {string} clientId - Client ID
   * @param {string} addressId - Address ID
   * @returns {Promise} Response data
   */
  async deleteClientAddress(clientId, addressId) {
    if (!isValidUuid(clientId) || !isValidUuid(addressId)) {
      console.error('Invalid ID format:', { clientId, addressId });
      return { success: false, message: 'Invalid ID format' };
    }

    try {
      return await apiService.delete(`/clients/${clientId}/addresses/${addressId}`);
    } catch (error) {
      console.error('Error deleting address:', error);
      return {
        success: false,
        message: 'Failed to delete address',
        error: error.message
      };
    }
  }

  /**
   * Get a client address by ID
   * @param {string} clientId - Client ID
   * @param {string} addressId - Address ID
   * @returns {Promise} Response data with address details
   */
  async getClientAddress(clientId, addressId) {
    if (!isValidUuid(clientId) || !isValidUuid(addressId)) {
      console.error('Invalid ID format:', { clientId, addressId });
      return { success: false, message: 'Invalid ID format' };
    }

    try {
      return await apiService.get(`/clients/${clientId}/addresses/${addressId}`);
    } catch (error) {
      console.error('Error fetching address:', error);
      return {
        success: false,
        message: 'Failed to fetch address',
        error: error.message
      };
    }
  }

  /**
   * Delete a client
   * @param {string} id - Client ID
   * @returns {Promise} Response data
   */
  async deleteClient(id) {
    if (!isValidUuid(id)) {
      console.error('Invalid client ID format:', id);
      return { success: false, message: 'Invalid client ID format' };
    }

    try {
      return await apiService.delete(`/clients/${id}`);
    } catch (error) {
      console.error('Error deleting client:', error);
      return {
        success: false,
        message: 'Failed to delete client',
        error: error.message
      };
    }
  }
}

export default new ClientsService();