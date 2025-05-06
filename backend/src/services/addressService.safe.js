const { ClientAddress, sequelize } = require('../models');
const logger = require('../utils/logger');
const { Op } = require('sequelize');

/**
 * Service for handling safe address operations
 * This version includes robust error handling for address operations
 */
class SafeAddressService {
  /**
   * Safely delete an address, handling project references
   * 
   * @param {string} addressId - The ID of the address to delete
   * @param {Object} transaction - Optional Sequelize transaction
   * @returns {Promise<Object>} Result object with success status and message
   */
  async safeDeleteAddress(addressId, transaction) {
    const t = transaction || await sequelize.transaction();
    const createdTransaction = !transaction;
    
    try {
      // First, find the address
      const address = await ClientAddress.findByPk(addressId, { transaction: t });
      
      if (!address) {
        if (createdTransaction) await t.commit();
        return { 
          success: false, 
          message: `Address ${addressId} not found` 
        };
      }
      
      // Check if address is referenced by any projects
      const projectReferences = await sequelize.query(
        `SELECT COUNT(*) as count FROM projects WHERE address_id = :addressId`,
        {
          replacements: { addressId },
          type: sequelize.QueryTypes.SELECT,
          transaction: t
        }
      );
      
      const hasReferences = parseInt(projectReferences[0].count, 10) > 0;
      
      if (hasReferences) {
        // If address is referenced, mark it as non-primary if it was primary
        if (address.is_primary) {
          // Find another address to mark as primary
          const otherAddress = await ClientAddress.findOne({
            where: {
              client_id: address.client_id,
              id: { [Op.ne]: addressId }
            },
            order: [['created_at', 'ASC']],
            transaction: t
          });
          
          if (otherAddress) {
            await otherAddress.update({ is_primary: true }, { transaction: t });
            logger.info(`Set address ${otherAddress.id} as primary for client ${address.client_id}`);
          }
          
          // Update the referenced address to not be primary
          await address.update({ is_primary: false }, { transaction: t });
          logger.info(`Marked address ${addressId} as non-primary as it is referenced by projects`);
        }
        
        if (createdTransaction) await t.commit();
        return { 
          success: true, 
          message: `Address ${addressId} marked as non-primary (cannot be deleted due to project references)`,
          status: 'updated'
        };
      } else {
        // If no references, safe to delete
        await address.destroy({ transaction: t });
        logger.info(`Successfully deleted address ${addressId}`);
        
        if (createdTransaction) await t.commit();
        return { 
          success: true, 
          message: `Address ${addressId} successfully deleted`,
          status: 'deleted'
        };
      }
    } catch (error) {
      if (createdTransaction) await t.rollback();
      logger.error(`Error safely deleting address ${addressId}: ${error.message}`);
      return { 
        success: false, 
        message: `Error deleting address: ${error.message}`,
        error
      };
    }
  }
  
  /**
   * Update address primary status safely
   * 
   * @param {string} addressId - The ID of the address to mark as primary
   * @param {Object} transaction - Optional Sequelize transaction
   * @returns {Promise<Object>} Result object with success status
   */
  async setPrimaryAddress(addressId, transaction) {
    const t = transaction || await sequelize.transaction();
    const createdTransaction = !transaction;
    
    try {
      // Find the address
      const address = await ClientAddress.findByPk(addressId, { transaction: t });
      
      if (!address) {
        if (createdTransaction) await t.commit();
        return { 
          success: false, 
          message: `Address ${addressId} not found` 
        };
      }
      
      // Clear primary flag from all other addresses for this client
      await ClientAddress.update(
        { is_primary: false },
        { 
          where: { 
            client_id: address.client_id,
            id: { [Op.ne]: addressId }
          },
          transaction: t
        }
      );
      
      // Set this address as primary
      await address.update({ is_primary: true }, { transaction: t });
      logger.info(`Set address ${addressId} as primary for client ${address.client_id}`);
      
      if (createdTransaction) await t.commit();
      return { 
        success: true, 
        message: `Address ${addressId} set as primary`
      };
      
    } catch (error) {
      if (createdTransaction) await t.rollback();
      logger.error(`Error setting primary address ${addressId}: ${error.message}`);
      return { 
        success: false, 
        message: `Error setting primary address: ${error.message}`,
        error
      };
    }
  }
}

module.exports = new SafeAddressService();
