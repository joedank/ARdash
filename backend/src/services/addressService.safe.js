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
      
      // Check for all possible references
      const references = {};
      let hasAnyReferences = false;

      // Check projects
      const projectReferences = await sequelize.query(
        `SELECT id, type, status FROM projects WHERE address_id = :addressId`,
        {
          replacements: { addressId },
          type: sequelize.QueryTypes.SELECT,
          transaction: t
        }
      );
      
      if (projectReferences.length > 0) {
        references.projects = projectReferences;
        hasAnyReferences = true;
      }

      // Check estimates
      const estimateReferences = await sequelize.query(
        `SELECT id, estimate_number, status FROM estimates WHERE address_id = :addressId`,
        {
          replacements: { addressId },
          type: sequelize.QueryTypes.SELECT,
          transaction: t
        }
      );
      
      if (estimateReferences.length > 0) {
        references.estimates = estimateReferences;
        hasAnyReferences = true;
      }

      // Check invoices
      const invoiceReferences = await sequelize.query(
        `SELECT id, invoice_number, status FROM invoices WHERE address_id = :addressId`,
        {
          replacements: { addressId },
          type: sequelize.QueryTypes.SELECT,
          transaction: t
        }
      );
      
      if (invoiceReferences.length > 0) {
        references.invoices = invoiceReferences;
        hasAnyReferences = true;
      }

      // pre-assessments check removed - feature deprecated
      
      // If the address is referenced anywhere
      if (hasAnyReferences) {
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
          logger.info(`Marked address ${addressId} as non-primary as it is referenced by other entities`);
        }
        
        if (createdTransaction) await t.commit();
        return { 
          success: true, 
          message: `Address ${addressId} cannot be deleted because it is referenced by other entities`,
          status: 'updated',
          references: references
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