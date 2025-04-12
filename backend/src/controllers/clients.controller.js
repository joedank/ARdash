const clientService = require('../services/clientService');
const logger = require('../utils/logger');

/**
 * Get all clients with optional type filter
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getAllClients = async (req, res) => {
  try {
    const { type } = req.query;
    const clients = await clientService.getAllClients(type);
    return res.status(200).json({
      success: true,
      data: clients
    });
  } catch (error) {
    logger.error('Error getting all clients:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get clients',
      error: error.message
    });
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
      return res.status(400).json({
        success: false,
        message: 'Invalid client type. Must be "property_manager" or "resident"'
      });
    }
    
    const clients = await clientService.getClientsByType(type);
    
    return res.status(200).json({
      success: true,
      data: clients
    });
  } catch (error) {
    logger.error(`Error getting clients by type ${req.params.type}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get clients by type',
      error: error.message
    });
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
      return res.status(400).json({
        success: false,
        message: 'Client name is required'
      });
    }
    
    // Validate client_type if provided
    if (clientData.client_type && !['property_manager', 'resident'].includes(clientData.client_type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid client type. Must be "property_manager" or "resident"'
      });
    }
    
    const client = await clientService.createClient(clientData);
    
    return res.status(201).json({
      success: true,
      message: 'Client created successfully',
      data: client
    });
  } catch (error) {
    logger.error('Error creating client:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to create client',
      error: error.message
    });
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
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }
    
    // Validate type parameter if provided
    if (type && !['property_manager', 'resident'].includes(type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid client type. Must be "property_manager" or "resident"'
      });
    }
    
    const clients = await clientService.searchClients(q, type);
    return res.status(200).json({
      success: true,
      data: clients
    });
  } catch (error) {
    logger.error('Error searching clients:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to search clients',
      error: error.message
    });
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
      return res.status(404).json({
        success: false,
        message: 'Client not found'
      });
    }
    
    return res.status(200).json({
      success: true,
      data: client
    });
  } catch (error) {
    logger.error(`Error getting client by ID: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get client',
      error: error.message
    });
  }
};

/**
 * Update client settings
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
      return res.status(400).json({
        success: false,
        message: 'Invalid client type. Must be "property_manager" or "resident"'
      });
    }
    
    const client = await clientService.updateClient(id, clientData);
    
    return res.status(200).json({
      success: true,
      message: 'Client updated successfully',
      data: client
    });
  } catch (error) {
    logger.error(`Error updating client ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to update client',
      error: error.message
    });
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
    
    return res.status(200).json({
      success: true,
      message: 'Client deleted successfully'
    });
  } catch (error) {
    logger.error(`Error deleting client ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to delete client',
      error: error.message
    });
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
        return res.status(400).json({
          success: false,
          message: `${field} is required`
        });
      }
    }
    
    const address = await clientService.addClientAddress(id, addressData);
    
    return res.status(201).json({
      success: true,
      message: 'Address added successfully',
      data: address
    });
  } catch (error) {
    logger.error(`Error adding address to client ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to add address',
      error: error.message
    });
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
 * Delete a client address
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const deleteClientAddress = async (req, res) => {
  try {
    const { id, addressId } = req.params;
    
    await clientService.deleteClientAddress(addressId);
    
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