const express = require('express');
const router = express.Router();
const clientsController = require('../controllers/clients.controller');
const addressesController = require('../controllers/addresses.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { validateUuid, validateMultipleUuids } = require('../middleware/uuidValidator');

// Apply authentication middleware to all routes
router.use(authenticate);

// Client Management
// GET /api/clients - Get all clients
router.get('/', clientsController.getAllClients);

// POST /api/clients - Create a new client
router.post('/', clientsController.createClient);

// GET /api/clients/search?q=query - Search clients
router.get('/search', clientsController.searchClients);

// GET /api/clients/type/:type - Get clients by type
router.get('/type/:type', clientsController.getClientsByType);

// GET /api/clients/:id - Get specific client details
router.get('/:id', validateUuid('id'), clientsController.getClientById);

// PUT /api/clients/:id - Update client settings
router.put('/:id', validateUuid('id'), clientsController.updateClient);

// DELETE /api/clients/:id - Delete a client
router.delete('/:id', validateUuid('id'), clientsController.deleteClient);

// Address Management
// GET /api/clients/:id/addresses - Get all addresses for a client
router.get('/:id/addresses', validateUuid('id'), addressesController.getClientAddresses);

// GET /api/clients/:id/primary-address - Get primary address for a client
router.get('/:id/primary-address', validateUuid('id'), addressesController.getPrimaryAddress);

// POST /api/clients/:id/addresses - Add a new address to client
router.post('/:id/addresses', validateUuid('id'), addressesController.createAddress);

// GET /api/clients/:id/addresses/:addressId - Get client address
router.get(
  '/:id/addresses/:addressId', 
  validateMultipleUuids(['id', 'addressId']), 
  addressesController.getAddressById
);

// PUT /api/clients/:id/addresses/:addressId - Update client address
router.put(
  '/:id/addresses/:addressId', 
  validateMultipleUuids(['id', 'addressId']), 
  addressesController.updateAddress
);

// DELETE /api/clients/:id/addresses/:addressId - Delete client address
router.delete(
  '/:id/addresses/:addressId', 
  validateMultipleUuids(['id', 'addressId']), 
  addressesController.deleteAddress
);

module.exports = router;