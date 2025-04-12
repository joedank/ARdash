const estimateService = require('../services/estimateService');
const llmEstimateService = require('../services/llmEstimateService');
const logger = require('../utils/logger');
const { ValidationError, NotFoundError } = require('../utils/errors');
const fs = require('fs').promises;
const path = require('path');
const projectService = require('../services/projectService'); // Import project service
const { formatAssessmentToMarkdown } = require('../services/assessmentFormatterService'); // Import the new formatter

/**
 * List all estimates with optional filters
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const listEstimates = async (req, res) => {
  try {
    const {
      status,
      clientId,
      dateFrom,
      dateTo,
      page = 0,
      limit = 10
    } = req.query;

    const filters = {
      status,
      clientId,
      dateFrom,
      dateTo
    };

    const result = await estimateService.listEstimates(
      filters,
      parseInt(page, 10),
      parseInt(limit, 10)
    );

    return res.status(200).json({
      success: true,
      data: result
    });
  } catch (error) {
    logger.error('Error listing estimates:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to list estimates',
      error: error.message
    });
  }
};

/**
 * Create a new estimate
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const createEstimate = async (req, res) => {
  try {
    const estimateData = req.body;

    // Validate required fields (use client_fk_id)
    if (!estimateData.client_fk_id) {
      return res.status(400).json({
        success: false,
        message: 'Client ID (client_fk_id) is required'
      });
    }

    if (!estimateData.dateCreated) {
      estimateData.dateCreated = new Date();
    }

    // Create the estimate
    const estimate = await estimateService.createEstimate(estimateData);

    // If this estimate is associated with a project, update the project
    if (estimateData.project_id && estimate) {
      try {
        // Get project service to update the project
        const projectService = require('../services/projectService');

        // Update the project with this estimate ID
        await projectService.updateProject(estimateData.project_id, {
          estimate_id: estimate.id
        });

        logger.info(`Updated project ${estimateData.project_id} with estimate ${estimate.id}`);
      } catch (projectError) {
        // Log error but continue, as the estimate was created successfully
        logger.error(`Error updating project with estimate: ${projectError.message}`);
      }
    }

    return res.status(201).json({
      success: true,
      message: 'Estimate created successfully',
      data: estimate
    });
  } catch (error) {
    logger.error('Error creating estimate:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to create estimate',
      error: error.message
    });
  }
};

/**
 * Create a new estimate with source mapping for bidirectional linking
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const createEstimateWithSourceMap = async (req, res) => {
  try {
    const estimateData = req.body;

    // Validate required fields
    if (!estimateData.clientId) {
      return res.status(400).json({
        success: false,
        message: 'Client ID is required'
      });
    }

    if (!estimateData.items || !Array.isArray(estimateData.items) || estimateData.items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Items array is required and must not be empty'
      });
    }

    logger.info(`Creating estimate with source map for client ${estimateData.clientId} with ${estimateData.items.length} items`);

    // Format data for the estimateService
    const formattedData = {
      client_fk_id: estimateData.clientId,
      address_id: estimateData.addressId, // Optional
      dateCreated: new Date(),
      project_id: estimateData.sourceProjectId, // Optional project reference
      status: 'draft',
      items: estimateData.items.map(item => ({
        description: item.description,
        quantity: parseFloat(item.quantity),
        unit_price: parseFloat(item.unitPrice),
        total: parseFloat(item.total),
        unit: item.unit,
        // Source tracking
        source_type: item.sourceType,
        source_id: item.sourceId,
        source_data: item.sourceData || null
      })),
      sourceMap: estimateData.sourceMap || {}
    };

    // Create the estimate with source mapping
    const estimate = await estimateService.createEstimateWithSourceMap(formattedData);

    // If this estimate is associated with a project, update the project
    if (estimateData.sourceProjectId && estimate) {
      try {
        // Update the project with this estimate ID
        await projectService.updateProject(estimateData.sourceProjectId, {
          estimate_id: estimate.id
        });

        logger.info(`Updated project ${estimateData.sourceProjectId} with estimate ${estimate.id}`);
      } catch (projectError) {
        // Log error but continue, as the estimate was created successfully
        logger.error(`Error updating project with estimate: ${projectError.message}`);
      }
    }

    return res.status(201).json({
      success: true,
      message: 'Estimate with source map created successfully',
      data: estimate
    });
  } catch (error) {
    logger.error('Error creating estimate with source map:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to create estimate with source map',
      error: error.message
    });
  }
};
/**
 * Get estimate details
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getEstimate = async (req, res) => {
  try {
    const { id } = req.params;

    // Validate UUID format before querying the database
    if (!id || id === 'undefined' || id === 'null') {
      logger.warn(`Invalid estimate ID provided: ${id}`);
      return res.status(400).json({
        success: false,
        message: 'Invalid estimate ID provided'
      });
    }

    // UUID validation using regex
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(id)) {
      logger.warn(`Invalid UUID format: ${id}`);
      return res.status(400).json({
        success: false,
        message: 'Invalid UUID format'
      });
    }

    const estimate = await estimateService.getEstimateWithDetails(id);

    if (!estimate) {
      return res.status(404).json({
        success: false,
        message: 'Estimate not found'
      });
    }

    return res.status(200).json({
      success: true,
      data: estimate
    });
  } catch (error) {
    logger.error(`Error getting estimate by ID: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get estimate',
      error: error.message
    });
  }
};

/**
 * Update an estimate
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const updateEstimate = async (req, res) => {
  try {
    const { id } = req.params;
    const estimateData = req.body;

    const updatedEstimate = await estimateService.updateEstimate(id, estimateData);

    return res.status(200).json({
      success: true,
      message: 'Estimate updated successfully',
      data: updatedEstimate
    });
  } catch (error) {
    logger.error(`Error updating estimate: ${req.params.id}:`, error);

    // Handle different types of errors
    if (error instanceof ValidationError) {
      return res.status(error.statusCode).json({
        success: false,
        message: 'Validation error',
        error: error.message,
        field: error.field
      });
    } else if (error instanceof NotFoundError) {
      return res.status(error.statusCode).json({
        success: false,
        message: 'Not found error',
        error: error.message
      });
    }

    // Handle any other errors as internal server errors
    return res.status(500).json({
      success: false,
      message: 'Failed to update estimate',
      error: error.message
    });
  }
};

/**
 * Delete an estimate
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const deleteEstimate = async (req, res) => {
  try {
    const { id } = req.params;

    const success = await estimateService.deleteEstimate(id);

    if (!success) {
      return res.status(404).json({
        success: false,
        message: 'Estimate not found or could not be deleted'
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Estimate deleted successfully'
    });
  } catch (error) {
    logger.error(`Error deleting estimate: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to delete estimate',
      error: error.message
    });
  }
};

/**
 * Mark estimate as sent
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const markEstimateAsSent = async (req, res) => {
  try {
    const { id } = req.params;

    const estimate = await estimateService.markEstimateAsSent(id);

    return res.status(200).json({
      success: true,
      message: 'Estimate marked as sent',
      data: estimate
    });
  } catch (error) {
    logger.error(`Error marking estimate as sent: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to mark estimate as sent',
      error: error.message
    });
  }
};

/**
 * Mark estimate as accepted
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const markEstimateAsAccepted = async (req, res) => {
  try {
    const { id } = req.params;

    const estimate = await estimateService.markEstimateAsAccepted(id);

    return res.status(200).json({
      success: true,
      message: 'Estimate marked as accepted',
      data: estimate
    });
  } catch (error) {
    logger.error(`Error marking estimate as accepted: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to mark estimate as accepted',
      error: error.message
    });
  }
};

/**
 * Mark estimate as rejected
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const markEstimateAsRejected = async (req, res) => {
  try {
    const { id } = req.params;

    const estimate = await estimateService.markEstimateAsRejected(id);

    return res.status(200).json({
      success: true,
      message: 'Estimate marked as rejected',
      data: estimate
    });
  } catch (error) {
    logger.error(`Error marking estimate as rejected: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to mark estimate as rejected',
      error: error.message
    });
  }
};

/**
 * Convert estimate to invoice
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const convertToInvoice = async (req, res) => {
  try {
    const { id } = req.params;

    const invoice = await estimateService.convertToInvoice(id);

    return res.status(200).json({
      success: true,
      message: 'Estimate converted to invoice successfully',
      data: invoice
    });
  } catch (error) {
    logger.error(`Error converting estimate to invoice: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to convert estimate to invoice',
      error: error.message
    });
  }
};

/**
 * Generate estimate PDF
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const downloadPdf = async (req, res) => {
  try {
    const { id } = req.params;

    // Use the new service function
    const pdfPath = await estimateService.generateEstimatePDF(id);

    // Verify file exists before sending
    try {
      await fs.access(pdfPath);
    } catch (err) {
      logger.error(`Generated PDF not found at path: ${pdfPath}`, err);
      return res.status(404).json({
        success: false,
        message: 'PDF file not found after generation.',
      });
    }

    // Send file as response
    const filename = path.basename(pdfPath);

    // Set headers for download
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);

    // Stream file for potentially large PDFs
    const fileStream = require('fs').createReadStream(pdfPath);
    fileStream.pipe(res);

    // Handle stream errors
    fileStream.on('error', (err) => {
        logger.error(`Error streaming PDF file ${pdfPath}:`, err);
        // Avoid sending another response if headers already sent
        if (!res.headersSent) {
            res.status(500).json({
                success: false,
                message: 'Failed to stream PDF file.',
                error: err.message
            });
        }
    });

  } catch (error) {
    logger.error(`Error generating or sending PDF for estimate ${req.params.id}:`, error);
     if (!res.headersSent) {
        res.status(500).json({
          success: false,
          message: 'Failed to generate or send PDF',
          error: error.message
        });
     }
  }
};

/**
 * Get the next available estimate number
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getNextEstimateNumber = async (req, res) => {
  try {
    const nextNumber = await estimateService.generateEstimateNumber();
    return res.status(200).json({
      success: true,
      data: { estimateNumber: nextNumber }
    });
  } catch (error) {
    logger.error('Error generating next estimate number:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to generate next estimate number',
      error: error.message
    });
  }
};

/**
 * Get source mapping for bidirectional linking between assessment and estimate
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getEstimateSourceMap = async (req, res) => {
  try {
    const { id } = req.params;

    // Validate UUID format before querying the database
    if (!id || id === 'undefined' || id === 'null') {
      logger.warn(`Invalid estimate ID provided: ${id}`);
      return res.status(400).json({
        success: false,
        message: 'Invalid estimate ID provided'
      });
    }

    // UUID validation using regex
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(id)) {
      logger.warn(`Invalid UUID format: ${id}`);
      return res.status(400).json({
        success: false,
        message: 'Invalid UUID format'
      });
    }

    const sourceMap = await estimateService.getEstimateSourceMap(id);

    return res.status(200).json({
      success: true,
      data: sourceMap
    });
  } catch (error) {
    logger.error(`Error getting estimate source map: ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get estimate source map',
      error: error.message
    });
  }
};
/**
 * Analyze estimate scope using LLM for initial details.
 * @param {Object} req - Express request object (body should contain 'description' and optional 'targetPrice')
 * @param {Object} res - Express response object
 */
const analyzeEstimateScope = async (req, res) => {
  try {
    const { description, targetPrice, assessmentData } = req.body;

    if (!description || typeof description !== 'string' || description.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Project description is required and must be a non-empty string.'
      });
    }

    // Convert targetPrice to number if present, otherwise pass undefined
    const numericTargetPrice = targetPrice !== undefined && targetPrice !== null && !isNaN(parseFloat(targetPrice))
      ? parseFloat(targetPrice)
      : undefined;

    logger.info(`Received LLM analysis request for description: "${description}", target price: ${numericTargetPrice}, with assessment data: ${!!assessmentData}`);

    // Pass the assessmentData to the LLM service
    const analysisResult = await llmEstimateService.startInitialAnalysis(description.trim(), numericTargetPrice, assessmentData);

    if (analysisResult && !analysisResult.error) {
      return res.status(200).json({
        success: true,
        message: 'Analysis successful.',
        data: analysisResult
      });
    } else if (analysisResult && analysisResult.error) {
       // Handle errors reported by the service (e.g., parsing failure)
       logger.warn(`LLM analysis service reported an error: ${analysisResult.error}`);
       // Decide on appropriate status code, 400 might be suitable if input caused LLM issues
       return res.status(400).json({
         success: false,
         message: `Analysis failed: ${analysisResult.error}`,
         rawContent: analysisResult.rawContent // Optionally include raw content for debugging
       });
    } else {
       // Should not happen if service returns null/undefined without error, but handle defensively
       logger.error('LLM analysis service returned an unexpected null/undefined result.');
       return res.status(500).json({
         success: false,
         message: 'Analysis failed due to an unexpected service error.'
       });
    }

  } catch (error) {
    logger.error('Error in analyzeEstimateScope controller:', error);
    // Handle errors thrown by the service (e.g., API call failure)
    return res.status(500).json({
      success: false,
      message: 'Failed to analyze estimate scope due to an internal error.',
      error: error.message // Provide error message for debugging
    });
  }
};

/**
 * Get assessment data for a project to use in estimate generation
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getAssessmentData = async (req, res) => {
  try {
    const { projectId } = req.params;

    if (!projectId) {
      return res.status(400).json({
        success: false,
        message: 'Project ID is required.'
      });
    }

    // Get project with details
    const project = await projectService.getProjectWithDetails(projectId);

    if (!project) {
      return res.status(404).json({
        success: false,
        message: 'Project not found.'
      });
    }

    // Extract relevant assessment data
    const assessmentData = {
      date: project.scheduled_date,
      inspector: project.inspector || project.assigned_to || 'Unknown',
      projectId: project.id,
      scope: project.scope,
      measurements: [],
      materials: [],
      conditions: [],
      notes: project.notes || ''
    };

    // Process inspection data for measurements, conditions, and materials
    if (project.inspections && project.inspections.length > 0) {
      project.inspections.forEach(inspection => {
        const content = inspection.content || {};

        // Process measurements
        if (inspection.category === 'measurements') {
          if (content.items && Array.isArray(content.items)) {
            // Handle new array-based measurement format
            content.items.forEach(item => {
              if (item && item.dimensions) {
                const value = calculateMeasurementValue(item.dimensions);
                const unit = determineMeasurementUnit(item.dimensions);

                assessmentData.measurements.push({
                  label: item.description || 'Unlabeled',
                  value,
                  unit,
                  material: item.material || '',
                  location: item.location || ''
                });
              }
            });
          } else if (content.dimensions) {
            // Handle legacy single measurement format
            assessmentData.measurements.push({
              label: content.description || 'Unlabeled',
              value: calculateMeasurementValue(content.dimensions),
              unit: determineMeasurementUnit(content.dimensions),
              material: content.material || '',
              location: content.location || ''
            });
          }
        }

        // Process conditions
        else if (inspection.category === 'condition') {
          assessmentData.conditions.push({
            location: content.location || 'General',
            issue: content.issue || 'Unspecified Issue',
            severity: content.severity || 'Unknown',
          });
        }

        // Process materials
        else if (inspection.category === 'materials') {
          if (content.items && Array.isArray(content.items)) {
            content.items.forEach(item => {
              if (item && item.name) {
                assessmentData.materials.push({
                  name: item.name,
                  specification: item.specification || item.description || '',
                  quantity: item.quantity || '',
                  unit: item.unit || 'each'
                });
              }
            });
          } else if (content.name) {
            // Handle legacy single material format
            assessmentData.materials.push({
              name: content.name,
              specification: content.specification || content.description || '',
              quantity: content.quantity || '',
              unit: content.unit || 'each'
            });
          }
        }
      });
    }

    // Format the assessment data into markdown using our enhanced formatter
    const markdown = formatAssessmentToMarkdown(assessmentData);

    // Return the original assessment data and the formatted markdown
    return res.status(200).json({
      success: true,
      message: 'Assessment data retrieved successfully.',
      data: {
        ...assessmentData,
        formattedMarkdown: markdown
      }
    });
  } catch (error) {
    logger.error(`Error getting assessment data for project ${req.params.projectId}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get assessment data.',
      error: error.message
    });
  }
};

/**
 * Calculate a single measurement value from dimensions object
 */
function calculateMeasurementValue(dimensions) {
  if (!dimensions) return '0';

  if (dimensions.length && dimensions.width) {
    // Area calculation
    return (parseFloat(dimensions.length) * parseFloat(dimensions.width)).toFixed(2);
  } else if (dimensions.length) {
    // Linear measurement
    return dimensions.length.toString();
  } else if (dimensions.count) {
    // Count measurement
    return dimensions.count.toString();
  }

  return '0';
}

/**
 * Determine the unit type based on dimensions
 */
function determineMeasurementUnit(dimensions) {
  if (!dimensions) return 'each';

  if (dimensions.length && dimensions.width) {
    return 'sq ft';
  } else if (dimensions.length) {
    return 'ln ft';
  } else if (dimensions.count) {
    return 'each';
  }

  return 'each';
}

/**
 * Submit clarifications (measurements and answers) for LLM estimate generation.
 * @param {Object} req - Express request object (body should contain 'measurements', 'answers', 'originalDescription', 'analysisResult')
 * @param {Object} res - Express response object
 */
const submitEstimateClarifications = async (req, res) => {
  try {
    const { measurements, answers, originalDescription, analysisResult } = req.body;

    // Basic validation
    if (!measurements || typeof measurements !== 'object') {
      return res.status(400).json({ success: false, message: 'Measurements object is required.' });
    }
    if (!answers || typeof answers !== 'object') {
      return res.status(400).json({ success: false, message: 'Answers object is required.' });
    }
     if (!originalDescription || typeof originalDescription !== 'string') {
      return res.status(400).json({ success: false, message: 'Original description is required.' });
    }
     if (!analysisResult || typeof analysisResult !== 'object') {
      return res.status(400).json({ success: false, message: 'Original analysis result is required.' });
    }

    logger.info('Received estimate clarifications submission.');

    // Call the service to handle clarifications and generate line items
    const clarificationResult = await llmEstimateService.handleClarifications({
      measurements,
      answers,
      originalDescription,
      analysisResult
    });

    if (clarificationResult && !clarificationResult.error) {
      return res.status(200).json({
        success: true,
        message: 'Clarifications processed successfully.',
        data: clarificationResult.data // Send back the generated line items
      });
    } else {
      // Handle potential errors from the clarification processing step
      logger.error('Error processing estimate clarifications:', clarificationResult?.error || 'Unknown error');
       return res.status(500).json({
         success: false,
         message: 'Failed to process clarifications due to an internal error.',
         error: clarificationResult?.error
       });
    }

  } catch (error) {
    logger.error('Error in submitEstimateClarifications controller:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to submit estimate clarifications due to an internal error.',
      error: error.message
    });
  }
};

/**
 * Match LLM-generated line items to actual products in catalog
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const matchProductsToLineItems = async (req, res) => {
  try {
    const { lineItems } = req.body;

    // Basic validation
    if (!lineItems || !Array.isArray(lineItems) || lineItems.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Line items are required and must be a non-empty array.'
      });
    }

    logger.info(`Received product matching request for ${lineItems.length} line items.`);

    // Call service method to perform matching
    const matchResult = await llmEstimateService.matchProductsToLineItems(lineItems);

    return res.status(200).json({
      success: true,
      message: 'Product matching completed successfully.',
      data: matchResult
    });
  } catch (error) {
    logger.error('Error in matchProductsToLineItems controller:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to match products to line items.',
      error: error.message
    });
  }
};

/**
 * Create new products from unmatched line items
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const createProductsFromLineItems = async (req, res) => {
  try {
    const { newProducts } = req.body;

    // Basic validation
    if (!newProducts || !Array.isArray(newProducts) || newProducts.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'New products data is required and must be a non-empty array.'
      });
    }

    logger.info(`Received request to create ${newProducts.length} new products.`);

    // Call service method to create new products
    const createdProducts = await llmEstimateService.createNewProducts(newProducts);

    return res.status(201).json({
      success: true,
      message: `Successfully created ${createdProducts.length} new products.`,
      data: createdProducts
    });
  } catch (error) {
    logger.error('Error in createProductsFromLineItems controller:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to create new products from line items.',
      error: error.message
    });
  }
};

/**
 * Generate estimate directly from assessment data with enhanced parameters
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const generateEstimateFromAssessment = async (req, res) => {
  try {
    const { assessment, options = {} } = req.body;

    // Validate input
    if (!assessment) {
      return res.status(400).json({
        success: false,
        message: 'Assessment data is required.'
      });
    }

    // Log the request
    logger.info(`Generating estimate from assessment with options:`, {
      assessmentId: assessment.id || 'unknown',
      options
    });

    // Call the service to generate estimate items
    const result = await llmEstimateService.generateEstimateFromAssessment(assessment, options);

    if (result.success) {
      res.json({
        success: true,
        data: result.data,
        debug: result.debug
      });
    } else {
      res.status(400).json({
        success: false,
        message: 'Estimate generation failed',
        error: result.error
      });
    }
  } catch (error) {
    logger.error('Error generating estimate from assessment:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate estimate from assessment',
      error: error.message
    });
  }
};

module.exports = {
  listEstimates,
  createEstimate,
  createEstimateWithSourceMap, // Add the new controller method
  getEstimate,
  updateEstimate,
  deleteEstimate,
  markEstimateAsSent,
  markEstimateAsAccepted,
  markEstimateAsRejected,
  convertToInvoice,
  downloadPdf,
  getNextEstimateNumber,
  analyzeEstimateScope,
  getAssessmentData,
  submitEstimateClarifications,
  matchProductsToLineItems,
  createProductsFromLineItems,
  generateEstimateFromAssessment,
  getEstimateSourceMap // Add the source map getter
};
