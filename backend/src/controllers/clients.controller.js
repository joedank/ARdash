const clientService = require('../services/clientService');
const logger = require('../utils/logger');
const { success, error } = require('../utils/response.util');

/**
 * Get all clients with optional type filter
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getAllClients = async (req, res) => {
  try {
    const { type } = req.query;
    const clients = await clientService.getAllClients(type);
    return res.status(200).json(success(clients, 'Clients retrieved successfully'));
  } catch (err) {
    logger.error('Error getting all clients:', err);
    return res.status(500).json(error('Failed to get clients', { message: err.message }));
  }
};

/**
 * Get clients by type
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getClientsByType = async (req, res) => {
  try {
    const { type } = req.params;
    
    // Validate type parameter
    if (!['property_manager', 'resident'].includes(type)) {
      return res.status(400).json(error('Invalid client type. Must be "property_manager" or "resident"'));
    }
    
    const clients = await clientService.getClientsByType(type);
    
    return res.status(200).json(success(clients, 'Clients retrieved successfully'));
  } catch (err) {
    logger.error(`Error getting clients by type ${req.params.type}:`, err);
    return res.status(500).json(error('Failed to get clients by type', { message: err.message }));
  }
};

/**
 * Create a new client
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const createClient = async (req, res) => {
  try {
    const clientData = req.body;
    
    // Validation - check for required fields
    if (!clientData.display_name) {
      return res.status(400).json(error('Client name is required'));
    }
    
    // Validate client_type if provided
    if (clientData.client_type && !['property_manager', 'resident'].includes(clientData.client_type)) {
      return res.status(400).json(error('Invalid client type. Must be "property_manager" or "resident"'));
    }
    
    const client = await clientService.createClient(clientData);
    
    return res.status(201).json(success(client, 'Client created successfully'));
  } catch (err) {
    logger.error('Error creating client:', err);
    return res.status(500).json(error('Failed to create client', { message: err.message }));
  }
};

/**
 * Search clients by name, company, or email with optional type filter
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const searchClients = async (req, res) => {
  try {
    const { q, type } = req.query;
    
    if (!q) {
      return res.status(400).json(error('Search query is required'));
    }
    
    // Validate type parameter if provided
    if (type && !['property_manager', 'resident'].includes(type)) {
      return res.status(400).json(error('Invalid client type. Must be "property_manager" or "resident"'));
    }
    
    const clients = await clientService.searchClients(q, type);
    return res.status(200).json(success(clients, 'Clients search completed successfully'));
  } catch (err) {
    logger.error('Error searching clients:', err);
    return res.status(500).json(error('Failed to search clients', { message: err.message }));
  }
};

/**
 * Get client by ID
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getClientById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const client = await clientService.getClientById(id);
    
    if (!client) {
      return res.status(404).json(error('Client not found'));
    }
    
    return res.status(200).json(success(client, 'Client retrieved successfully'));
  } catch (err) {
    logger.error(`Error getting client by ID: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to get client', { message: err.message }));
  }
};

/**
 * Update client settings with nested address handling
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const updateClient = async (req, res) => {
  try {
    const { id } = req.params;
    const clientData = req.body;
    
    // Remove any fields that shouldn't be updated directly
    delete clientData.id;
    
    // Validate client_type if provided
    if (clientData.client_type && !['property_manager', 'resident'].includes(clientData.client_type)) {
      return res.status(400).json(error('Invalid client type. Must be "property_manager" or "resident"'));
    }
    
    // Log the received data for debugging
    logger.info(`Updating client ${id} with data:`, { 
      ...clientData, 
      addresses: clientData.addresses ? `${clientData.addresses.length} addresses` : 'none'
    });
    
    // Use the enhanced clientService.updateClient which handles nested addresses
    const client = await clientService.updateClient(id, clientData);
    
    // Return the updated client with its addresses
    return res.status(200).json(success(client, 'Client updated successfully'));
  } catch (err) {
    logger.error(`Error updating client ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to update client', { message: err.message }));
  }
};

/**
 * Delete client
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const deleteClient = async (req, res) => {
  try {
    const { id } = req.params;
    
    await clientService.deleteClient(id);
    
    return res.status(200).json(success(null, 'Client deleted successfully'));
  } catch (err) {
    logger.error(`Error deleting client ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to delete client', { message: err.message }));
  }
};

/**
 * Add an address to a client
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const addClientAddress = async (req, res) => {
  try {
    const { id } = req.params;
    const addressData = req.body;
    
    // Validate required fields
    const requiredFields = ['name', 'street_address', 'city', 'state', 'postal_code'];
    for (const field of requiredFields) {
      if (!addressData[field]) {
        return res.status(400).json(error(`${field} is required`));
      }
    }
    
    const address = await clientService.addClientAddress(id, addressData);
    
    return res.status(201).json(success(address, 'Address added successfully'));
  } catch (err) {
    logger.error(`Error adding address to client ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to add address', { message: err.message }));
  }
};

/**
 * Update a client address
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const updateClientAddress = async (req, res) => {
  try {
    const { id, addressId } = req.params;
    const addressData = req.body;
    
    // Remove any fields that shouldn't be updated directly
    delete addressData.id;
    delete addressData.client_id;
    
    const address = await clientService.updateClientAddress(addressId, addressData);
    
    return res.status(200).json(success(address, 'Address updated successfully'));
  } catch (err) {
    logger.error(`Error updating address ${req.params.addressId}:`, err);
    return res.status(500).json(error('Failed to update address', { message: err.message }));
  }
};

/**
 * Delete a client address
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const deleteClientAddress = async (req, res) => {
  try {
    const { id, addressId } = req.params;
    
    await clientService.deleteClientAddress(addressId);
    
    return res.status(200).json(success(null, 'Address deleted successfully'));
  } catch (err) {
    logger.error(`Error deleting address ${req.params.addressId}:`, err);
    return res.status(500).json(error('Failed to delete address', { message: err.message }));
  }
};

/**
 * Get a client address by ID
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getClientAddress = async (req, res) => {
  try {
    const { id, addressId } = req.params;
    
    const address = await clientService.getClientAddress(id, addressId);
    
    if (!address) {
      return res.status(404).json(error('Address not found'));
    }
    
    return res.status(200).json(success(address, 'Address retrieved successfully'));
  } catch (err) {
    logger.error(`Error getting address ${req.params.addressId}:`, err);
    return res.status(500).json(error('Failed to get address', { message: err.message }));
  }
};

module.exports = {
  getAllClients,
  getClientsByType,
  createClient,
  searchClients,
  getClientById,
  updateClient,
  deleteClient,
  addClientAddress,
  updateClientAddress,
  deleteClientAddress,
  getClientAddress
};