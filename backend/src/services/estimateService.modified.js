// Add this line to the beginning of the existing file
const fieldAdapter = require('../utils/field-adapter');

// Then modify the generateEstimatePDF method to use the field adapter
async generateEstimatePDF(estimateId) {
  try {
    logger.info(`Starting PDF generation/retrieval for estimate ID: ${estimateId}`);

    const estimate = await this.getEstimateWithDetails(estimateId);

    if (!estimate) {
      throw new Error(`Estimate with ID ${estimateId} not found`);
    }
    if (!estimate.client) {
      throw new Error(`Client details not found for estimate ${estimateId}`);
    }

    // Determine the correct client address to use
    // Use the specific address linked to the estimate first, then fallback to primary/first client address
    const clientAddress = estimate.address ||
                          (estimate.client.addresses && estimate.client.addresses.length > 0
                            ? (estimate.client.addresses.find(addr => addr.is_primary) || estimate.client.addresses[0])
                            : null);

    // Set up output directory and filename
    const uploadsDir = path.join(__dirname, '../../uploads/estimates');
    await fs.mkdir(uploadsDir, { recursive: true }); // Ensure directory exists

    const filename = `estimate_${estimate.estimateNumber.replace(/[^a-zA-Z0-9]/g, '_')}.pdf`;
    const fullPath = path.join(uploadsDir, filename);

    logger.info(`Target PDF path for estimate ${estimateId}: ${fullPath}`);

    // Regenerate PDF to ensure latest data/styling
    logger.info(`Generating fresh PDF for estimate ID: ${estimateId}`);

    // Generate PDF using the shared pdfService with normalized data
    const pdfPath = await pdfService.generatePdf({
      type: 'estimate',
      data: fieldAdapter.toFrontend(estimate.toJSON()), // Convert to camelCase
      client: fieldAdapter.toFrontend(estimate.client.toJSON()), // Convert to camelCase
      clientAddress: clientAddress ? fieldAdapter.toFrontend(clientAddress.toJSON()) : null, // Convert to camelCase
      filename,
      outputDir: uploadsDir
    });

    logger.info(`Estimate PDF generated successfully at: ${pdfPath}`);

    // Update estimate with the new PDF path if it changed or was null
    if (estimate.pdfPath !== pdfPath) {
        await estimate.update({ pdfPath });
        logger.info(`Updated estimate ${estimateId} with PDF path: ${pdfPath}`);
    }

    return pdfPath;
  } catch (error) {
    logger.error(`Error generating PDF for estimate ${estimateId}:`, error);
    throw error; // Re-throw the error
  }
}