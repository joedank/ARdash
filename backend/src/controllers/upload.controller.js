const fs = require('fs').promises;
const path = require('path');
const logger = require('../utils/logger');
const settingsService = require('../services/settingsService');

/**
 * Handle company logo upload
 * @param {Object} req - Express request object with multer file
 * @param {Object} res - Express response object
 */
const uploadCompanyLogo = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded'
      });
    }

    // Get file details
    const { filename, mimetype, size } = req.file;

    // Only allow image files
    if (!mimetype.startsWith('image/')) {
      // Delete the file
      await fs.unlink(req.file.path);
      return res.status(400).json({
        success: false,
        message: 'Only image files are allowed'
      });
    }

    // Size limit: 2MB
    const sizeLimit = 2 * 1024 * 1024; // 2MB
    if (size > sizeLimit) {
      // Delete the file
      await fs.unlink(req.file.path);
      return res.status(400).json({
        success: false,
        message: 'File size exceeds the limit (2MB)'
      });
    }

    // Update the company_logo_path setting
    await settingsService.updateSetting('company_logo_path', filename, 'company');

    return res.status(200).json({
      success: true,
      message: 'Logo uploaded successfully',
      data: {
        filename,
        path: `/uploads/logos/${filename}`
      }
    });
  } catch (error) {
    logger.error('Error uploading company logo:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to upload logo',
      error: error.message
    });
  }
};

module.exports = {
  uploadCompanyLogo
};
