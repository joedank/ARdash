'use strict';

const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { validateUuid, validateMultipleUuids } = require('../middleware/uuidValidator');
const estimateItemPhotosController = require('../controllers/estimateItemPhotos.controller');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function(req, file, cb) {
    // Temporarily store in uploads/temp
    const tempDir = path.join(__dirname, '../../uploads/temp');
    cb(null, tempDir);
  },
  filename: function(req, file, cb) {
    // Use the original filename temporarily
    // The controller will rename it with a UUID later
    cb(null, file.originalname);
  }
});

// Create the upload middleware
const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max file size
  },
  fileFilter: function(req, file, cb) {
    // Accept only images
    if (!file.mimetype.startsWith('image/')) {
      return cb(new Error('Only image files are allowed'));
    }
    cb(null, true);
  }
});

// Endpoint: Upload a photo for an estimate item
router.post(
  '/estimate-items/:estimateItemId/photos',
  validateUuid('estimateItemId'),
  upload.single('photo'),
  estimateItemPhotosController.uploadPhoto
);

// Endpoint: Get all photos for an estimate item
router.get(
  '/estimate-items/:estimateItemId/photos',
  validateUuid('estimateItemId'),
  estimateItemPhotosController.getPhotos
);

// Endpoint: Get a single photo by ID
router.get(
  '/estimate-items/:estimateItemId/photos/:photoId',
  validateMultipleUuids(['estimateItemId', 'photoId']),
  estimateItemPhotosController.getPhotoById
);

// Endpoint: Update a photo's metadata
router.put(
  '/estimate-items/:estimateItemId/photos/:photoId',
  validateMultipleUuids(['estimateItemId', 'photoId']),
  estimateItemPhotosController.updatePhoto
);

// Endpoint: Delete a photo
router.delete(
  '/estimate-items/:estimateItemId/photos/:photoId',
  validateMultipleUuids(['estimateItemId', 'photoId']),
  estimateItemPhotosController.deletePhoto
);

// Endpoint: Get all photos for a specific estimate
router.get(
  '/estimates/:estimateId/photos',
  validateUuid('estimateId'),
  estimateItemPhotosController.getPhotosByEstimateId
);

module.exports = router;
