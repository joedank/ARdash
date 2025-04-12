import apiService from './api.service';

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
    return apiService.post('/clients', clientData);
  }

  /**
   * Get all clients
   * @param {string} type - Optional client type filter (property_manager or resident)
   * @returns {Promise} Response data with clients array
   */
  async getAllClients(type = null) {
    const queryParam = type ? `?type=${type}` : '';
    return apiService.get(`/clients${queryParam}`);
  }

  /**
   * Get clients by type
   * @param {string} type - Client type (property_manager or resident)
   * @returns {Promise} Response data with clients array
   */
  async getClientsByType(type) {
    return apiService.get(`/clients/type/${type}`);
  }

  /**
   * Search clients by name, company, or email
   * @param {string} query - Search query
   * @param {string} type - Optional client type filter
   * @returns {Promise} Response data with matching clients
   */
  async searchClients(query, type = null) {
    const typeParam = type ? `&type=${type}` : '';
    return apiService.get(`/clients/search?q=${encodeURIComponent(query)}${typeParam}`);
  }

  /**
   * Get client by ID
   * @param {string} id - Client ID
   * @returns {Promise} Response data with client details
   */
  async getClientById(id) {
    return apiService.get(`/clients/${id}`);
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
   * Update client settings
   * @param {string} id - Client ID
   * @param {Object} data - Client data to update
   * @returns {Promise} Response data with updated client
   */
  async updateClient(id, data) {
    return apiService.put(`/clients/${id}`, data);
  }

  /**
   * Add a new address to a client
   * @param {string} clientId - Client ID
   * @param {Object} addressData - Address data
   * @returns {Promise} Response data with created address
   */
  async addClientAddress(clientId, addressData) {
    return apiService.post(`/clients/${clientId}/addresses`, addressData);
  }

  /**
   * Update a client address
   * @param {string} clientId - Client ID
   * @param {string} addressId - Address ID
   * @param {Object} addressData - Address data to update
   * @returns {Promise} Response data with updated address
   */
  async updateClientAddress(clientId, addressId, addressData) {
    return apiService.put(`/clients/${clientId}/addresses/${addressId}`, addressData);
  }

  /**
   * Delete a client address
   * @param {string} clientId - Client ID
   * @param {string} addressId - Address ID
   * @returns {Promise} Response data
   */
  async deleteClientAddress(clientId, addressId) {
    return apiService.delete(`/clients/${clientId}/addresses/${addressId}`);
  }

  /**
   * Get a client address by ID
   * @param {string} clientId - Client ID
   * @param {string} addressId - Address ID
   * @returns {Promise} Response data with address details
   */
  async getClientAddress(clientId, addressId) {
    return apiService.get(`/clients/${clientId}/addresses/${addressId}`);
  }
}

export default new ClientsService();