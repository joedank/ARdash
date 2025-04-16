const estimateService = require('../services/estimateService');
const llmEstimateService = require('../services/llmEstimateService');
const externalLlmProcessor = require('../services/externalLlmProcessor');
const logger = require('../utils/logger');
const { ValidationError, NotFoundError } = require('../utils/errors');
const fs = require('fs').promises;
const path = require('path');
const projectService = require('../services/projectService'); // Import project service
const { formatAssessmentToMarkdown } = require('../services/assessmentFormatterService'); // Import the new formatter
const { success, error } = require('../utils/response.util'); // Import standardized response utilities

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

    logger.info(`Listing estimates with filters: ${JSON.stringify(filters)}, page: ${page}, limit: ${limit}`);

    const result = await estimateService.listEstimates(
      filters,
      parseInt(page, 10),
      parseInt(limit, 10)
    );

    logger.info(`Estimate count: ${result.total}, total pages: ${result.totalPages}`);

    return res.status(200).json(success(result, 'Estimates retrieved successfully'));
  } catch (err) {
    logger.error('Error listing estimates:', err);
    return res.status(500).json(error('Failed to list estimates', { message: err.message }));
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

    // Validate required fields
    if (!estimateData.client_id) {
      return res.status(400).json(error('Client ID (client_id) is required'));
    }

    if (!estimateData.dateCreated) {
      estimateData.dateCreated = new Date();
    }

    // Create the estimate - bidirectional relationship is now handled in the service
    const estimate = await estimateService.createEstimate(estimateData);

    // Log success for monitoring
    if (estimateData.project_id && estimate) {
      logger.info(`Created estimate ${estimate.id} for project ${estimateData.project_id}`);
    }

    return res.status(201).json(success(estimate, 'Estimate created successfully'));
  } catch (err) {
    logger.error('Error creating estimate:', err);

    // Add more detailed error handling for relationship errors
    if (err.message && err.message.includes('Project')) {
      return res.status(400).json(error('Project relationship error', { message: err.message }));
    }

    return res.status(500).json(error('Failed to create estimate', { message: err.message }));
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
      return res.status(400).json(error('Client ID is required'));
    }

    if (!estimateData.items || !Array.isArray(estimateData.items) || estimateData.items.length === 0) {
      return res.status(400).json(error('Items array is required and must not be empty'));
    }

    logger.info(`Creating estimate with source map for client ${estimateData.clientId} with ${estimateData.items.length} items`);

    // Format data for the estimateService
    const formattedData = {
      client_id: estimateData.clientId,
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

    // Create the estimate with source mapping - bidirectional relationship is now handled in the service
    const estimate = await estimateService.createEstimateWithSourceMap(formattedData);

    // Log success for monitoring
    if (estimateData.sourceProjectId && estimate) {
      logger.info(`Created estimate ${estimate.id} with source map for project ${estimateData.sourceProjectId}`);
    }

    return res.status(201).json(success(estimate, 'Estimate with source map created successfully'));
  } catch (err) {
    logger.error('Error creating estimate with source map:', err);

    // Add more detailed error handling for relationship errors
    if (err.message && err.message.includes('Project')) {
      return res.status(400).json(error('Project relationship error', { message: err.message }));
    }

    return res.status(500).json(error('Failed to create estimate with source map', { message: err.message }));
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
      return res.status(400).json(error('Invalid estimate ID provided'));
    }

    // UUID validation using regex
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(id)) {
      logger.warn(`Invalid UUID format: ${id}`);
      return res.status(400).json(error('Invalid UUID format'));
    }

    const estimate = await estimateService.getEstimateWithDetails(id);

    if (!estimate) {
      return res.status(404).json(error('Estimate not found'));
    }

    return res.status(200).json(success(estimate, 'Estimate retrieved successfully'));
  } catch (err) {
    logger.error(`Error getting estimate by ID: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to get estimate', { message: err.message }));
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

    return res.status(200).json(success(updatedEstimate, 'Estimate updated successfully'));
  } catch (err) {
    logger.error(`Error updating estimate: ${req.params.id}:`, err);

    // Handle different types of errors
    if (err instanceof ValidationError) {
      return res.status(err.statusCode).json(error('Validation error', { message: err.message, field: err.field }));
    } else if (err instanceof NotFoundError) {
      return res.status(err.statusCode).json(error('Not found error', { message: err.message }));
    }

    // Handle any other errors as internal server errors
    return res.status(500).json(error('Failed to update estimate', { message: err.message }));
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

    const deleted = await estimateService.deleteEstimate(id);

    if (!deleted) {
      return res.status(404).json(error('Estimate not found or could not be deleted'));
    }

    return res.status(200).json(success(null, 'Estimate deleted successfully'));
  } catch (err) {
    logger.error(`Error deleting estimate: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to delete estimate', { message: err.message }));
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

    return res.status(200).json(success(estimate, 'Estimate marked as sent'));
  } catch (err) {
    logger.error(`Error marking estimate as sent: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to mark estimate as sent', { message: err.message }));
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

    return res.status(200).json(success(estimate, 'Estimate marked as accepted'));
  } catch (err) {
    logger.error(`Error marking estimate as accepted: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to mark estimate as accepted', { message: err.message }));
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

    return res.status(200).json(success(estimate, 'Estimate marked as rejected'));
  } catch (err) {
    logger.error(`Error marking estimate as rejected: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to mark estimate as rejected', { message: err.message }));
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

    return res.status(200).json(success(invoice, 'Estimate converted to invoice successfully'));
  } catch (err) {
    logger.error(`Error converting estimate to invoice: ${req.params.id}:`, err);
    return res.status(500).json(error('Failed to convert estimate to invoice', { message: err.message }));
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
    logger.info(`PDF download requested for estimate ID: ${id}`);

    // Generate a fresh PDF
    logger.info(`Generating fresh PDF for estimate ID: ${id}`);
    const pdfPath = await estimateService.generateEstimatePDF(id);
    logger.info(`PDF generated at path: ${pdfPath}`);

    // Verify file exists before sending
    try {
      await fs.access(pdfPath);
      logger.info(`Verified PDF exists at path: ${pdfPath}`);
    } catch (err) {
      logger.error(`Generated PDF not found at path: ${pdfPath}`, err);
      return res.status(404).json(error('PDF file not found after generation.'));
    }

    // Get file information
    const filename = path.basename(pdfPath);
    logger.info(`Sending PDF with filename: ${filename}`);

    // Set appropriate headers
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);

    // Use the file system to read the file directly instead of streaming
    try {
      const fileData = await fs.readFile(pdfPath);
      logger.info(`Successfully read PDF file, size: ${fileData.length} bytes`);
      return res.send(fileData);
    } catch (readError) {
      logger.error(`Error reading PDF file at ${pdfPath}:`, readError);
      return res.status(500).json(error('Error reading PDF file', { message: readError.message }));
    }
  } catch (err) {
    logger.error(`Error generating or sending PDF for estimate ${req.params.id}:`, err);
    if (!res.headersSent) {
      return res.status(500).json(error('Failed to generate or send PDF', { message: err.message }));
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
    return res.status(200).json(success({ estimateNumber: nextNumber }, 'Next estimate number generated successfully'));
  } catch (err) {
    logger.error('Error generating next estimate number:', err);
    return res.status(500).json(error('Failed to generate next estimate number', { message: err.message }));
  }
};

/**
 * Get source map for an estimate item
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getEstimateSourceMap = async (req, res) => {
  try {
    const { estimateId, itemId } = req.params;

    // Validate UUIDs
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(estimateId)) {
      return res.status(400).json(error('Invalid estimate ID format'));
    }
    if (!uuidRegex.test(itemId)) {
      return res.status(400).json(error('Invalid item ID format'));
    }

    const sourceMap = await estimateService.getSourceMapForItem(itemId);

    if (!sourceMap) {
      return res.status(404).json(error('Source map not found for this item'));
    }

    return res.status(200).json(success(sourceMap, 'Source map retrieved successfully'));
  } catch (err) {
    logger.error(`Error getting source map for item ${req.params.itemId}:`, err);
    return res.status(500).json(error('Failed to get source map', { message: err.message }));
  }
};

// LLM Related Controllers

/**
 * Analyze project scope using LLM
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const analyzeEstimateScope = async (req, res) => {
  try {
    const { description, assessmentData, mode, aggressiveness } = req.body;

    if (!description) {
      return res.status(400).json(error('Description is required'));
    }

    logger.info(`Analyzing estimate scope with mode: ${mode}, aggressiveness: ${aggressiveness}`);

    // Call the LLM service to analyze the scope
    const analysisResult = await llmEstimateService.analyzeScope({
      scope: description, // Make sure we use 'scope' here as expected by the method
      assessmentData,
      mode,
      aggressiveness
    });

    if (!analysisResult.success) {
       // Pass the detailed error message from the service
       return res.status(400).json(error(analysisResult.message || 'LLM analysis failed', analysisResult.data));
    }

    // Check if clarifications are needed
    if (analysisResult.clarificationsNeeded) {
       return res.status(200).json(success({
         clarificationsNeeded: true,
         questions: analysisResult.questions,
         contextId: analysisResult.contextId // Include context ID for follow-up
       }, 'Clarifications needed for estimate'));
    } else {
       // If no clarifications needed, return the generated line items
       return res.status(200).json(success({
         clarificationsNeeded: false,
         lineItems: analysisResult.lineItems
       }, 'Estimate scope analyzed successfully'));
    }

  } catch (err) {
    logger.error('Error analyzing estimate scope:', err);
    return res.status(500).json(error('Failed to analyze estimate scope', { message: err.message }));
  }
};


/**
 * Get assessment data formatted for LLM
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getAssessmentData = async (req, res) => {
  try {
    const { projectId } = req.params;

    // Validate UUID
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(projectId)) {
      return res.status(400).json(error('Invalid project ID format'));
    }

    // Fetch project with inspections and photos
    const project = await projectService.getProjectWithDetails(projectId);

    if (!project) {
      return res.status(404).json(error('Project not found'));
    }

    // Extract measurements, conditions, and materials from inspections
    const inspections = project.inspections || [];
    const measurements = [];
    const conditions = [];
    const materials = [];

    logger.info(`Processing ${inspections.length} inspections for project ${projectId}`);

    inspections.forEach((inspection) => {
      if (!inspection || !inspection.category || !inspection.content) return;

      // Parse the content if it's a string (JSON)
      let parsedContent = inspection.content;
      if (typeof inspection.content === 'string') {
        try {
          parsedContent = JSON.parse(inspection.content);
        } catch (err) {
          logger.error(`Error parsing inspection content: ${err.message}`);
          // Continue with the original content if parsing fails
        }
      }

      logger.info(`Processing inspection category: ${inspection.category}`);

      if (inspection.category === 'measurements') {
        // Handle measurements data structure
        if (parsedContent.items && Array.isArray(parsedContent.items)) {
          // Extract items from the measurements object
          parsedContent.items.forEach(item => {
            // Convert dimensions to a standardized format
            if (item.dimensions) {
              // Area measurement
              if (item.measurementType === 'area') {
                measurements.push({
                  label: item.description,
                  value: item.dimensions.length * item.dimensions.width,
                  unit: item.dimensions.units || 'sq ft',
                  measurementType: 'area',
                  location: item.location || ''
                });
              }
              // Linear measurement
              else if (item.measurementType === 'linear') {
                measurements.push({
                  label: item.description,
                  value: item.dimensions.length,
                  unit: item.dimensions.units || 'ln ft',
                  measurementType: 'linear',
                  location: item.location || ''
                });
              }
            }
            // Quantity measurement
            else if (item.measurementType === 'quantity') {
              measurements.push({
                label: item.description,
                value: item.quantity,
                unit: item.quantityUnit || 'each',
                measurementType: 'quantity',
                location: item.location || ''
              });
            }
          });
        } else {
          // If it's not in the expected format, add it as-is
          measurements.push(parsedContent);
        }
      } else if (inspection.category === 'condition') {
        // Handle condition data structure
        if (parsedContent.assessment) {
          conditions.push({
            location: parsedContent.location || 'General',
            issue: parsedContent.assessment,
            severity: parsedContent.severity || 'Moderate',
            notes: parsedContent.notes || ''
          });
        } else {
          conditions.push(parsedContent);
        }
      } else if (inspection.category === 'materials') {
        // Handle materials data structure
        if (parsedContent.items && Array.isArray(parsedContent.items)) {
          parsedContent.items.forEach(item => {
            if (item.name) {
              materials.push({
                name: item.name,
                specification: item.specification || '',
                quantity: item.quantity || '',
                unit: item.unit || ''
              });
            }
          });
        } else {
          materials.push(parsedContent);
        }
      }
    });

    logger.info(`Extracted ${measurements.length} measurements, ${conditions.length} conditions, ${materials.length} materials`);


    // Format the assessment data using the new service
    const assessmentData = {
      scope: project.scope,
      inspections: inspections,
      photos: project.project_photos || [],
      measurements,
      conditions,
      materials,
      // Add project details
      projectId: project.id,
      date: project.scheduled_date,
      inspector: project.inspector || 'Unknown',
      client: project.client ? {
        id: project.client.id,
        name: `${project.client.first_name || ''} ${project.client.last_name || ''}`.trim(),
        email: project.client.email,
        phone: project.client.phone
      } : null,
      address: project.address ? {
        id: project.address.id,
        street: project.address.street,
        city: project.address.city,
        state: project.address.state,
        zip: project.address.zip
      } : null
    };

    // Example of how you might structure the data for the formatter
    const formattedMarkdown = formatAssessmentToMarkdown(assessmentData);

    // Return the formatted data
    return res.status(200).json(success({
      formattedData: formattedMarkdown,
      rawAssessmentData: assessmentData // Optionally return raw data too
    }, 'Assessment data retrieved and formatted successfully'));

  } catch (err) {
    logger.error(`Error getting assessment data for project ${req.params.projectId}:`, err);
    return res.status(500).json(error('Failed to get assessment data', { message: err.message }));
  }
};


// Helper function (consider moving to a utility file if used elsewhere)
function calculateMeasurementValue(dimensions) {
  if (!dimensions) return 0;
  if (dimensions.length && dimensions.width) return parseFloat(dimensions.length) * parseFloat(dimensions.width);
  if (dimensions.linearFeet) return parseFloat(dimensions.linearFeet);
  if (dimensions.quantity) return parseFloat(dimensions.quantity);
  return 0;
}

// Helper function (consider moving to a utility file if used elsewhere)
function determineMeasurementUnit(dimensions) {
  if (!dimensions) return 'unit';
  if (dimensions.length && dimensions.width) return 'sq ft';
  if (dimensions.linearFeet) return 'ln ft';
  if (dimensions.quantity) return 'each';
  return 'unit';
}


/**
 * Submit clarifications for an estimate analysis
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const submitEstimateClarifications = async (req, res) => {
  try {
    const { contextId, answers } = req.body;

    if (!contextId || !answers) {
      return res.status(400).json(error('Context ID and answers are required'));
    }

    logger.info(`Submitting clarifications for context ID: ${contextId}`);

    // Call the LLM service to handle clarifications
    const clarificationResult = await llmEstimateService.handleClarifications({
      contextId,
      answers
    });

     if (!clarificationResult.success) {
        // Pass the detailed error message from the service
        return res.status(500).json(error(clarificationResult.message || 'Failed to process clarifications', clarificationResult.data));
     }

    // Return the final line items after clarifications
    return res.status(200).json(success({
      lineItems: clarificationResult.lineItems
    }, 'Clarifications processed successfully'));

  } catch (err) {
    logger.error('Error submitting estimate clarifications:', err);
     // Check if it's a known error type from the service
     if (err.message.includes('Context not found') || err.message.includes('Invalid context')) {
        return res.status(404).json(error('Clarification context not found or invalid', { message: err.message }));
     }
    return res.status(500).json(error('Failed to submit estimate clarifications', { message: err.message }));
  }
};

/**
 * Match generated line items to products in the catalog
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const matchProductsToLineItems = async (req, res) => {
  try {
    const { lineItems } = req.body;

    if (!lineItems || !Array.isArray(lineItems)) {
      return res.status(400).json(error('Line items array is required'));
    }

    logger.info(`Matching products for ${lineItems.length} line items`);

    // Call the service to match products
    const matchedItems = await llmEstimateService.matchProducts(lineItems);

    return res.status(200).json(success(matchedItems, 'Products matched successfully'));

  } catch (err) {
    logger.error('Error matching products to line items:', err);
    return res.status(500).json(error('Failed to match products', { message: err.message }));
  }
};

/**
 * Create new products based on unmatched line items
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const createProductsFromLineItems = async (req, res) => {
  try {
    const { lineItems } = req.body;

    if (!lineItems || !Array.isArray(lineItems)) {
      return res.status(400).json(error('Line items array is required'));
    }

    logger.info(`Creating products for ${lineItems.length} line items`);

    // Call the service to create products
    const createdProducts = await llmEstimateService.createProductsFromUnmatched(lineItems);

    return res.status(201).json(success(createdProducts, 'Products created successfully'));

  } catch (err) {
    logger.error('Error creating products from line items:', err);
    return res.status(500).json(error('Failed to create products', { message: err.message }));
  }
};


/**
 * Generate estimate directly from assessment data
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const generateEstimateFromAssessment = async (req, res) => {
  try {
    // Log the entire request body for debugging
    logger.info('Received request body for estimate generation:', JSON.stringify(req.body, null, 2));

    // Extract data from request body
    const { projectId, assessment, mode, aggressiveness, options } = req.body;

    // Try to find project ID from different possible sources
    let finalProjectId = projectId;

    // If no direct projectId, try to extract from assessment object
    if (!finalProjectId && assessment) {
      logger.info('No direct projectId provided, trying to extract from assessment object');

      // Try different possible locations for project ID
      if (assessment.projectId) {
        finalProjectId = assessment.projectId;
        logger.info(`Extracted project ID from assessment.projectId: ${finalProjectId}`);
      } else if (assessment.project && assessment.project.id) {
        finalProjectId = assessment.project.id;
        logger.info(`Extracted project ID from assessment.project.id: ${finalProjectId}`);
      } else if (assessment.project && assessment.project.project_id) {
        finalProjectId = assessment.project.project_id;
        logger.info(`Extracted project ID from assessment.project.project_id: ${finalProjectId}`);
      } else if (assessment.id) {
        finalProjectId = assessment.id;
        logger.info(`Using assessment.id as project ID: ${finalProjectId}`);
      } else if (assessment.assessmentId) {
        finalProjectId = assessment.assessmentId;
        logger.info(`Using assessment.assessmentId as project ID: ${finalProjectId}`);
      } else if (assessment.client && assessment.client.projectId) {
        finalProjectId = assessment.client.projectId;
        logger.info(`Extracted project ID from assessment.client.projectId: ${finalProjectId}`);
      } else if (assessment.client && assessment.client.project_id) {
        finalProjectId = assessment.client.project_id;
        logger.info(`Extracted project ID from assessment.client.project_id: ${finalProjectId}`);
      }

      // Log assessment structure for debugging
      logger.info('Assessment structure:', {
        hasProject: !!assessment.project,
        projectKeys: assessment.project ? Object.keys(assessment.project) : [],
        hasId: !!assessment.id,
        hasProjectId: !!assessment.projectId,
        hasAssessmentId: !!assessment.assessmentId,
        hasClient: !!assessment.client,
        clientKeys: assessment.client ? Object.keys(assessment.client) : []
      });
    }

    // Final validation
    if (!finalProjectId) {
      logger.error('No project ID found in request', { body: req.body });
      return res.status(400).json(error('Project ID is required. Could not find project ID in any of the expected locations.'));
    }

    // Validate UUID format
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(finalProjectId)) {
      logger.error(`Invalid project ID format: ${finalProjectId}`);
      return res.status(400).json(error(`Invalid project ID format: ${finalProjectId}. Expected UUID format.`));
    }

    // Extract options from either direct parameters or options object
    const finalOptions = {
      mode: options?.mode || mode,
      aggressiveness: options?.aggressiveness !== undefined ? options.aggressiveness : aggressiveness
    };

    logger.info(`Generating estimate directly from assessment project ID: ${finalProjectId}`);
    logger.info(`Options:`, finalOptions);

    // Call the service function with the extracted project ID and options
    const result = await llmEstimateService.generateEstimateFromAssessment({
      projectId: finalProjectId,
      mode: finalOptions.mode,
      aggressiveness: finalOptions.aggressiveness,
      // Pass the full assessment object if available for additional context
      assessment: assessment
    });

    if (result.success) {
      res.json(success(result.data, 'Estimate generated successfully from assessment'));
    } else {
      // Use the error message from the service
      res.status(400).json(error(result.message || 'Failed to generate estimate from assessment', result.data));
    }
  } catch (err) {
    logger.error('Error generating estimate from assessment:', err);
    res.status(500).json(error('Failed to generate estimate from assessment', { message: err.message }));
  }
};

/**
 * Process externally generated LLM response
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const processExternalLlmResponse = async (req, res) => {
  try {
    const { responseText, assessmentData } = req.body;

    if (!responseText) {
      return res.status(400).json(error('LLM response text is required'));
    }

    logger.info('Processing external LLM response');

    // Call the dedicated processor service
    const result = await externalLlmProcessor.processExternalLlmResponse(responseText, assessmentData);

    if (!result.success) {
      // Use the error message from the processor
      return res.status(400).json(error(result.message || 'Failed to process external LLM response', result.data));
    }

    // Return the processed line items
    return res.json(success(result.data, 'External LLM response processed successfully'));

  } catch (err) {
    logger.error('Error processing external LLM response:', err);
    return res.status(500).json(error('Failed to process external LLM response', { message: err.message }));
  }
};


module.exports = {
  listEstimates,
  createEstimate,
  createEstimateWithSourceMap,
  getEstimate,
  updateEstimate,
  deleteEstimate,
  markEstimateAsSent,
  markEstimateAsAccepted,
  markEstimateAsRejected,
  convertToInvoice,
  downloadPdf,
  getNextEstimateNumber,
  getEstimateSourceMap,
  // LLM related
  analyzeEstimateScope,
  getAssessmentData,
  submitEstimateClarifications,
  matchProductsToLineItems,
  createProductsFromLineItems,
  generateEstimateFromAssessment,
  processExternalLlmResponse
};