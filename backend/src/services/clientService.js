const { Client, ClientAddress, sequelize } = require('../models');
const logger = require('../utils/logger');
const { Op } = require('sequelize');

/**
 * Service for handling client operations
 */
class ClientService {
  /**
   * Create a new client with optional addresses
   * @param {Object} clientData - Client data including optional addresses array
   * @returns {Promise<Object>} - Created client with addresses
   */
  async createClient(clientData) {
    let transaction;

    try {
      // Begin a transaction to ensure data integrity
      transaction = await sequelize.transaction();

      // Extract addresses from client data
      const { addresses, ...clientOnly } = clientData;

      // Set default client_type if not provided
      if (!clientOnly.client_type) {
        clientOnly.client_type = 'resident';
      }

      // Explicitly generate a UUID for the client if not provided
      if (!clientOnly.id) {
        const { v4: uuidv4 } = require('uuid');
        clientOnly.id = uuidv4();
      }

      // Create the client without addresses first
      const client = await Client.create(clientOnly, { transaction });
      logger.info(`Created new client: ${clientOnly.display_name} (Type: ${clientOnly.client_type}) with ID: ${client.id}`);

      // Now create addresses if they exist
      if (addresses && Array.isArray(addresses) && addresses.length > 0) {
        for (const addressData of addresses) {
          // Skip empty addresses
          if (!addressData.street_address || !addressData.city || !addressData.state || !addressData.postal_code) {
            logger.warn('Skipping incomplete address for client', client.id);
            continue;
          }

          // Ensure client_id is set and remove any temporary id
          const { id, ...addressOnly } = addressData;

          // Create the address with explicit reference to the client
          await ClientAddress.create({
            ...addressOnly,
            client_id: client.id
          }, { transaction });
        }
        logger.info(`Added ${addresses.length} addresses for client ${client.id}`);
      }

      // Commit the transaction
      await transaction.commit();

      // Fetch the complete client with addresses
      return await this.getClientById(client.id);
    } catch (error) {
      // Rollback the transaction if any error occurs
      if (transaction) await transaction.rollback();
      logger.error('Error creating client:', error);
      throw error;
    }
  }

  /**
   * Get a client by ID with all associated data
   * @param {string} id - Client ID
   * @returns {Promise<Object|null>} - Complete client object with addresses
   */
  async getClientById(id) {
    try {
      return await Client.findByPk(id, {
        include: [
          {
            model: ClientAddress,
            as: 'addresses',
            order: [['is_primary', 'DESC'], ['created_at', 'ASC']]
          }
        ]
      });
    } catch (error) {
      logger.error(`Error getting client by ID: ${id}:`, error);
      throw error;
    }
  }

  /**
   * Get all clients
   * @param {string} type - Optional client type filter (property_manager or resident)
   * @returns {Promise<Array>} - List of clients
   */
  async getAllClients(type = null) {
    try {
      const whereClause = {};

      // Add client_type filter if provided
      if (type) {
        whereClause.client_type = type;
      }

      return await Client.findAll({
        where: whereClause,
        include: [
          {
            model: ClientAddress,
            as: 'addresses',
            required: false
          }
        ],
        order: [['display_name', 'ASC']]
      });
    } catch (error) {
      logger.error('Error getting all clients:', error);
      throw error;
    }
  }

  /**
   * Search for clients by name, company, or email
   * @param {string} query - Search query
   * @param {string} type - Optional client type filter (property_manager or resident)
   * @returns {Promise<Array>} - Matched clients
   */
  async searchClients(query, type = null) {
    try {
      const searchQuery = `%${query}%`;
      const whereClause = {
        [Op.or]: [
          { display_name: { [Op.iLike]: searchQuery } },
          { company: { [Op.iLike]: searchQuery } },
          { email: { [Op.iLike]: searchQuery } }
        ]
      };

      // Add client_type filter if provided
      if (type) {
        whereClause.client_type = type;
      }

      return await Client.findAll({
        where: whereClause,
        include: [
          {
            model: ClientAddress,
            as: 'addresses',
            required: false
          }
        ],
        order: [['display_name', 'ASC']]
      });
    } catch (error) {
      logger.error(`Error searching clients for query "${query}":`, error);
      throw error;
    }
  }

  /**
   * Update client with nested address handling
   * @param {string} id - Client ID
   * @param {Object} data - Client data to update (including addresses array)
   * @returns {Promise<Object>} - Updated client with addresses
   */
  async updateClient(id, data) {
    let transaction;
    
    try {
      transaction = await sequelize.transaction();
      
      const client = await Client.findByPk(id);
      if (!client) {
        throw new Error(`Client with ID ${id} not found`);
      }
      
      // Extract addresses from data
      const { addresses, ...clientData } = data;
      
      // Update client properties
      await client.update(clientData, { transaction });
      
      // Handle addresses if provided
      if (addresses && Array.isArray(addresses)) {
        // Find existing addresses for this client
        const existingAddresses = await ClientAddress.findAll({
          where: { client_id: id }
        });
        
        // Create a map of existing addresses by ID for easier lookup
        const existingAddressMap = existingAddresses.reduce((map, addr) => {
          map[addr.id] = addr;
          return map;
        }, {});
        
        // Find which address is marked as primary
        const primaryAddress = addresses.find(addr => addr.is_primary);
        
        // If an address is marked as primary, unmark all others
        if (primaryAddress) {
          await ClientAddress.update(
            { is_primary: false },
            { 
              where: { client_id: id },
              transaction 
            }
          );
        }
        
        // Keep track of processed address IDs to determine which ones to remove
        const processedAddressIds = [];
        
        // Process each address
        for (const address of addresses) {
          // Clean the address data to ensure required fields
          const addressData = {
            name: address.name,
            street_address: address.street_address,
            city: address.city,
            state: address.state,
            postal_code: address.postal_code,
            country: address.country || 'USA',
            is_primary: address.is_primary,
            notes: address.notes || ''
          };
          
          if (address.id && existingAddressMap[address.id]) {
            // Update existing address using findByPk and update pattern
            // instead of the bulk update to ensure the update works
            const existingAddress = await ClientAddress.findByPk(address.id);
            if (existingAddress && existingAddress.client_id === id) {
              await existingAddress.update(addressData, { transaction });
              processedAddressIds.push(address.id);
              logger.info(`Updated address ${address.id} for client ${id}`);
            }
          } else {
            // Create new address only if it doesn't already exist
            const newAddress = await ClientAddress.create(
              {
                ...addressData,
                client_id: id
              },
              { transaction }
            );
            processedAddressIds.push(newAddress.id);
            logger.info(`Created new address for client ${id}`);
          }
        }
        
        // Optional: Remove addresses that weren't in the update request
        // Uncomment if you want to delete addresses not included in the update
        /*
        const addressesToRemove = existingAddresses.filter(addr => 
          !processedAddressIds.includes(addr.id)
        );
        
        for (const addrToRemove of addressesToRemove) {
          await addrToRemove.destroy({ transaction });
          logger.info(`Removed address ${addrToRemove.id} for client ${id}`);
        }
        */
      }
      
      await transaction.commit();
      
      // Return the updated client with addresses
      return await this.getClientById(id);
    } catch (error) {
      if (transaction) await transaction.rollback();
      logger.error(`Error updating client ${id}:`, error);
      throw error;
    }
  }

  /**
   * Delete a client
   * @param {string} id - Client ID
   * @returns {Promise<boolean>} - Success status
   */
  async deleteClient(id) {
    try {
      const client = await Client.findByPk(id);

      if (!client) {
        throw new Error(`Client with ID ${id} not found`);
      }

      // Delete associated addresses
      await ClientAddress.destroy({
        where: { client_id: id }
      });

      // Delete the client
      await client.destroy();
      return true;
    } catch (error) {
      logger.error(`Error deleting client ${id}:`, error);
      throw error;
    }
  }

  /**
   * Get client by ID
   * @param {string} id - Client ID
   * @returns {Promise<Object|null>} - Client object with addresses
   */
  async getClientById(id) {
    try {
      return await Client.findByPk(id, {
        include: [
          {
            model: ClientAddress,
            as: 'addresses',
            required: false
          }
        ]
      });
    } catch (error) {
      logger.error(`Error getting client by ID ${id}:`, error);
      throw error;
    }
  }

  /**
   * Get clients by type
   * @param {string} type - Client type (property_manager or resident)
   * @returns {Promise<Array>} - List of clients of the specified type
   */
  async getClientsByType(type) {
    try {
      return await Client.findAll({
        where: { client_type: type },
        include: [
          {
            model: ClientAddress,
            as: 'addresses',
            required: false
          }
        ],
        order: [['display_name', 'ASC']]
      });
    } catch (error) {
      logger.error(`Error getting clients by type ${type}:`, error);
      throw error;
    }
  }

  /**
   * Add an address to a client
   * @param {string} clientId - Client ID
   * @param {Object} addressData - Address data
   * @returns {Promise<Object>} - Created address
   */
  async addClientAddress(clientId, addressData) {
    try {
      // If this is set as primary, unset any existing primary addresses
      if (addressData.is_primary) {
        await ClientAddress.update(
          { is_primary: false },
          { where: { client_id: clientId, is_primary: true } }
        );
      }

      // Create the new address
      const address = await ClientAddress.create({
        ...addressData,
        client_id: clientId
      });

      return address;
    } catch (error) {
      logger.error(`Error adding address to client ${clientId}:`, error);
      throw error;
    }
  }

  /**
   * Update a client address
   * @param {string} addressId - Address ID
   * @param {Object} addressData - Updated address data
   * @returns {Promise<Object>} - Updated address
   */
  async updateClientAddress(addressId, addressData) {
    try {
      const address = await ClientAddress.findByPk(addressId);

      if (!address) {
        throw new Error(`Address with ID ${addressId} not found`);
      }

      // If this is being set as primary, unset any existing primary addresses
      if (addressData.is_primary && !address.is_primary) {
        await ClientAddress.update(
          { is_primary: false },
          { where: { client_id: address.client_id, is_primary: true } }
        );
      }

      await address.update(addressData);
      return address;
    } catch (error) {
      logger.error(`Error updating address ${addressId}:`, error);
      throw error;
    }
  }

  /**
   * Delete a client address
   * @param {string} addressId - Address ID
   * @returns {Promise<boolean>} - Success status
   */
  async deleteClientAddress(addressId) {
    try {
      const address = await ClientAddress.findByPk(addressId);

      if (!address) {
        throw new Error(`Address with ID ${addressId} not found`);
      }

      // If this was a primary address, set another address as primary
      if (address.is_primary) {
        const nextAddress = await ClientAddress.findOne({
          where: {
            client_id: address.client_id,
            id: { [Op.not]: addressId }
          },
          order: [['created_at', 'ASC']]
        });

        if (nextAddress) {
          await nextAddress.update({ is_primary: true });
        }
      }

      await address.destroy();
      return true;
    } catch (error) {
      logger.error(`Error deleting address ${addressId}:`, error);
      throw error;
    }
  }

  /**
   * Get a client address by ID
   * @param {string} clientId - Client ID
   * @param {string} addressId - Address ID
   * @returns {Promise<Object|null>} - Address object
   */
  async getClientAddress(clientId, addressId) {
    try {
      return await ClientAddress.findOne({
        where: {
          id: addressId,
          client_id: clientId
        }
      });
    } catch (error) {
      logger.error(`Error getting address ${addressId} for client ${clientId}:`, error);
      throw error;
    }
  }
}

module.exports = new ClientService();