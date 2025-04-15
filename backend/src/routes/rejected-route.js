// Route to add to projects.routes.js
/**
 * @route   GET /api/projects/rejected
 * @desc    Get rejected assessment projects
 * @access  Private
 * @note    This route doesn't require UUID validation as it only uses query parameters
 */
router.get('/rejected', authenticate, controller.getRejectedProjects);
