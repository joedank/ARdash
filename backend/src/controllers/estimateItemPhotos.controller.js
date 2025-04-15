'use strict';

const { EstimateItemPhoto, EstimateItem } = require('../models');
const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const { ValidationError, NotFoundError, DatabaseError } = require('../utils/errors');
const logger = require('../utils/logger');

// Define upload directory for estimate item photos
const UPLOAD_DIR = path.join(__dirname, '../../uploads/estimate-items');

// Create directory if it doesn't exist
if (!fs.existsSync(UPLOAD_DIR)) {
  fs.mkdirSync(UPLOAD_DIR, { recursive: true });
}

/**
 * Controller for handling estimate item photos
 */
const estimateItemPhotosController = {
  /**
   * Upload a photo for an estimate item
   */
  async uploadPhoto(req, res, next) {
    try {
      const { estimateItemId } = req.params;
      
      // Check if the estimate item exists
      const estimateItem = await EstimateItem.findByPk(estimateItemId);
      if (!estimateItem) {
        throw new NotFoundError('EstimateItem', estimateItemId);
      }
      
      // Check if file was uploaded
      if (!req.file) {
        throw new ValidationError('No file uploaded');
      }
      
      const { originalname, filename, mimetype } = req.file;
      const photoType = req.body.photoType || 'progress';
      const notes = req.body.notes || '';
      
      // Generate a UUID for the filename
      const fileUuid = uuidv4();
      const fileExtension = path.extname(originalname);
      const newFilename = `${fileUuid}${fileExtension}`;
      
      // Create the destination path
      const itemDir = path.join(UPLOAD_DIR, estimateItemId);
      if (!fs.existsSync(itemDir)) {
        fs.mkdirSync(itemDir, { recursive: true });
      }
      
      // Move the file to its final destination
      const filePath = path.join(itemDir, newFilename);
      fs.renameSync(req.file.path, filePath);
      
      // Save relative path to database
      const relativePath = path.join('estimate-items', estimateItemId, newFilename);
      
      // Create the database record
      const photo = await EstimateItemPhoto.create({
        estimate_item_id: estimateItemId,
        file_path: relativePath,
        original_name: originalname,
        photo_type: photoType,
        notes: notes,
        metadata: {
          mimetype: mimetype,
          timestamp: new Date().toISOString()
        }
      });
      
      // Log the successful upload
      logger.info(`Uploaded photo for estimate item ${estimateItemId}: ${photo.id}`);
      
      // Return success response
      return res.status(201).json({
        success: true,
        message: 'Photo uploaded successfully',
        data: photo
      });
    } catch (error) {
      next(error);
    }
  },
  
  /**
   * Get all photos for an estimate item
   */
  async getPhotos(req, res, next) {
    try {
      const { estimateItemId } = req.params;
      
      // Check if the estimate item exists
      const estimateItem = await EstimateItem.findByPk(estimateItemId);
      if (!estimateItem) {
        throw new NotFoundError('EstimateItem', estimateItemId);
      }
      
      // Get all photos for this estimate item
      const photos = await EstimateItemPhoto.findAll({
        where: { estimate_item_id: estimateItemId },
        order: [['created_at', 'DESC']]
      });
      
      // Return success response
      return res.json({
        success: true,
        data: photos
      });
    } catch (error) {
      next(error);
    }
  },
  
  /**
   * Get a single photo by ID
   */
  async getPhotoById(req, res, next) {
    try {
      const { estimateItemId, photoId } = req.params;
      
      // Find the photo
      const photo = await EstimateItemPhoto.findOne({
        where: { 
          id: photoId,
          estimate_item_id: estimateItemId
        }
      });
      
      if (!photo) {
        throw new NotFoundError('EstimateItemPhoto', photoId);
      }
      
      // Return success response
      return res.json({
        success: true,
        data: photo
      });
    } catch (error) {
      next(error);
    }
  },
  
  /**
   * Delete a photo by ID
   */
  async deletePhoto(req, res, next) {
    try {
      const { estimateItemId, photoId } = req.params;
      
      // Find the photo
      const photo = await EstimateItemPhoto.findOne({
        where: { 
          id: photoId,
          estimate_item_id: estimateItemId
        }
      });
      
      if (!photo) {
        throw new NotFoundError('EstimateItemPhoto', photoId);
      }
      
      // Get the full file path
      const filePath = path.join(__dirname, '../../uploads', photo.file_path);
      
      // Delete the file if it exists
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
      
      // Delete the database record
      await photo.destroy();
      
      // Log the deletion
      logger.info(`Deleted photo ${photoId} for estimate item ${estimateItemId}`);
      
      // Return success response
      return res.json({
        success: true,
        message: 'Photo deleted successfully'
      });
    } catch (error) {
      next(error);
    }
  },
  
  /**
   * Update a photo's metadata (notes, photo_type)
   */
  async updatePhoto(req, res, next) {
    try {
      const { estimateItemId, photoId } = req.params;
      const { notes, photoType } = req.body;
      
      // Find the photo
      const photo = await EstimateItemPhoto.findOne({
        where: { 
          id: photoId,
          estimate_item_id: estimateItemId
        }
      });
      
      if (!photo) {
        throw new NotFoundError('EstimateItemPhoto', photoId);
      }
      
      // Update fields if provided
      const updates = {};
      if (notes !== undefined) updates.notes = notes;
      if (photoType !== undefined) updates.photo_type = photoType;
      
      // Apply updates
      await photo.update(updates);
      
      // Return success response
      return res.json({
        success: true,
        message: 'Photo updated successfully',
        data: photo
      });
    } catch (error) {
      next(error);
    }
  },
  
  /**
   * Get all photos for a project estimate
   */
  async getPhotosByEstimateId(req, res, next) {
    try {
      const { estimateId } = req.params;
      
      // Find all estimate items for this estimate
      const estimateItems = await EstimateItem.findAll({
        where: { estimate_id: estimateId },
        attributes: ['id', 'description']
      });
      
      if (!estimateItems || estimateItems.length === 0) {
        return res.json({
          success: true,
          data: []
        });
      }
      
      // Get all item IDs
      const itemIds = estimateItems.map(item => item.id);
      
      // Get all photos for these items
      const photos = await EstimateItemPhoto.findAll({
        where: { estimate_item_id: itemIds },
        order: [['created_at', 'DESC']]
      });
      
      // Group photos by estimate item
      const photosByItem = {};
      for (const item of estimateItems) {
        photosByItem[item.id] = {
          itemId: item.id,
          description: item.description,
          photos: photos.filter(photo => photo.estimate_item_id === item.id)
        };
      }
      
      // Return success response
      return res.json({
        success: true,
        data: photosByItem
      });
    } catch (error) {
      next(error);
    }
  }
};

module.exports = estimateItemPhotosController;
