const express = require('express');
const router = express.Router();
const communitiesController = require('../controllers/communities.controller');
const adTypesController = require('../controllers/adTypes.controller');
const { authenticate } = require('../middleware/auth.middleware');

// Apply authentication middleware to all routes
router.use(authenticate);

// Community Management
// GET /api/communities - Get all communities
router.get('/', communitiesController.getAllCommunities);

// POST /api/communities - Create a new community
router.post('/', communitiesController.createCommunity);

// GET /api/communities/search?q=query - Search communities
router.get('/search', communitiesController.searchCommunities);

// GET /api/communities/:id - Get specific community details
router.get('/:id', communitiesController.getCommunityById);

// PUT /api/communities/:id - Update community
router.put('/:id', communitiesController.updateCommunity);

// DELETE /api/communities/:id - Delete a community
router.delete('/:id', communitiesController.deleteCommunity);

// PUT /api/communities/:id/active-status - Set community active status
router.put('/:id/active-status', communitiesController.setActiveStatus);

// PUT /api/communities/:id/select-ad-type - Select ad type for community
router.put('/:id/select-ad-type', communitiesController.selectAdType);

// Ad Type Management
// GET /api/communities/:communityId/ad-types - Get all ad types for a community
router.get('/:communityId/ad-types', adTypesController.getAdTypesForCommunity);

// POST /api/communities/:communityId/ad-types - Create a new ad type for a community
router.post('/:communityId/ad-types', adTypesController.createAdType);

// GET /api/communities/ad-types/:id - Get specific ad type details
router.get('/ad-types/:id', adTypesController.getAdTypeById);

// PUT /api/communities/ad-types/:id - Update ad type
router.put('/ad-types/:id', adTypesController.updateAdType);

// DELETE /api/communities/ad-types/:id - Delete an ad type
router.delete('/ad-types/:id', adTypesController.deleteAdType);

module.exports = router;