const express = require('express');
const { getUsers, createUser, updateUser, deleteUser } = require('../controllers/admin.controller.js');
const { authenticate, authorize } = require('../middleware/auth.middleware.js');

const router = express.Router();

router.use(authenticate);
router.use(authorize(['admin'])); // Only admins can access these routes

router.get('/users', getUsers);
router.post('/users', createUser);
router.put('/users/:id', updateUser);
router.delete('/users/:id', deleteUser);

module.exports = router;
