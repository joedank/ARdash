const express = require('express');
const router = express.Router();
const addressesController = require('../controllers/addresses.controller');
const { validateUuid } = require('../middleware/uuidValidator');

// Get address by ID
router.get('/:addressId', validateUuid('addressId'), addressesController.getAddressById);

// Update address
router.put('/:addressId', validateUuid('addressId'), addressesController.updateAddress);

// Delete address
router.delete('/:addressId', validateUuid('addressId'), addressesController.deleteAddress);

module.exports = router;
