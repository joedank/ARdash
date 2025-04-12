const express = require('express');
const router = express.Router();
const clientsController = require('../controllers/clients.controller');
const { authenticate } = require('../middleware/auth.middleware');

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
router.get('/:id', clientsController.getClientById);

// PUT /api/clients/:id - Update client settings
router.put('/:id', clientsController.updateClient);

// DELETE /api/clients/:id - Delete a client
router.delete('/:id', clientsController.deleteClient);

// Address Management
// POST /api/clients/:id/addresses - Add a new address to client
router.post('/:id/addresses', clientsController.addClientAddress);

// GET /api/clients/:id/addresses/:addressId - Get client address
router.get('/:id/addresses/:addressId', clientsController.getClientAddress);

// PUT /api/clients/:id/addresses/:addressId - Update client address
router.put('/:id/addresses/:addressId', clientsController.updateClientAddress);

// DELETE /api/clients/:id/addresses/:addressId - Delete client address
router.delete('/:id/addresses/:addressId', clientsController.deleteClientAddress);

module.exports = router;