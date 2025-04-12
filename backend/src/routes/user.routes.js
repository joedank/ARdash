const express = require('express');
const userController = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();

// GET /api/users
router.get('/', userController.getAllUsers);

// GET /api/users/:id
router.get('/:id', userController.getUserById);

// POST /api/users
router.post('/', userController.createUser);

// PUT /api/users/profile
router.put('/profile', authenticate, userController.updateProfile);

// PUT /api/users/password
router.put('/password', authenticate, userController.changePassword);

// PUT /api/users/preferences/theme
router.put('/preferences/theme', authenticate, userController.updateThemePreference);

module.exports = router;
