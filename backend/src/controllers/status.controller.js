/**
 * Status controller for health checks
 */
class StatusController {
  /**
   * Get API status
   * @param {object} req - Express request object
   * @param {object} res - Express response object
   */
  getStatus(req, res) {
    res.status(200).json({
      status: 'success',
      message: 'API is running',
      timestamp: new Date(),
      environment: process.env.NODE_ENV
    });
  }
}

module.exports = new StatusController();
