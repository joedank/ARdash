
### Fixed PDF Settings Bug with Empty Values

- **Identified Issue**: Empty strings ('') from form fields would overwrite existing settings in the database, causing colors and logos to disappear in generated PDFs
- **Implementation Details**:
  - **Frontend Fixes** (PdfSettings.vue):
    - Skip empty strings, null, and undefined values when building settings objects
    - Only send companyLogoPath when logo has explicitly changed
    - Added whitespace detection to properly handle strings with only spaces
    - Created a reusable isBlank() utility function in validation.js
    - Added "Remove Logo" button with explicit deletion handling
  - **Backend Fixes** (settingsService.js):
    - Skip empty strings, null, and whitespace-only values before Settings.upsert
    - Added special handling for explicit null values as deletion requests
    - Implemented DB cleanup migration to remove existing empty settings
  - **API Integration Fixes**:
    - Added check to prevent API calls with empty settings objects
    - Fixed response handling for empty settings groups
- **Results**:
  - PDF colors and logo now persist correctly after form submission
  - Users can explicitly remove a logo with the Remove Logo button
  - Whitespace-only strings are properly detected and handled
  - Database remains clean without accumulating empty settings
  - Improved user experience with clear visual feedback- ✅ Fixed PDF Settings Bug Preventing Logo and Colors from Persisting
- ✅ Fixed Empty Settings Values Handling in Frontend and Backend# Active Context: Construction Management Web Application

This document captures the current work focus, recent changes, active decisions, and important patterns and preferences.

## Current Focus

### BetterReplacementsManager MacOS Application Improvements

- ✅ Fixed UI Redundancy: Removed duplicate shortcut display from navigation title in DetailView
- ✅ Enhanced Toolbar Design: Converted stethoscope icon to settings gear icon and aligned to right using .primaryAction placement
- Simplified interface by eliminating redundant selected shortcut display next to toolbar buttons
- Improved toolbar organization with settings button properly separated from main action buttons

### Previous Construction Management Focus

- ✅ Fixed Client Address Deletion Error from Pre-Assessments Table Dependencies  
- ✅ Removed Deprecated Pre-Assessments Feature from Codebase and Database
- ✅ Fixed Client Address Deletion Casing Mismatch at API Boundary
- ✅ Enhanced Work Type Detection with Separate Thresholds for Suggestions vs New Creation
- ✅ Implemented Multiple Confidence Thresholds for Fragment Processing (0.35/0.60)  
- ✅ Fixed Router Integration in SuggestedChip Component for Work Type Creation
- ✅ Restored Database from April 24th Backup with Idempotent Migration Handling
- ✅ Fixed Non-Idempotent Migrations (ENUM values, extensions, indexes) for Reliable Restoration
- ✅ Fixed NULL Timestamp Issues in Settings Table from Legacy Data
- ✅ Fixed Frontend Docker Container Rollup Module Issues with Multi-Stage Build
- ✅ Fixed Database Migration Issues with Settings Table Index and Legacy Function Signatures
- ✅ Fixed PostgreSQL pgvector Dimension Limit for HNSW/IVFFLAT Indexes (max 2000 dims)
- ✅ Fixed Data Type Mismatch in Settings Seed Migration (UUID vs INTEGER)
- ✅ Fixed Project Model Naming Collision Between Column and Association

- ✅ Fixed Vector Dimension and HNSW Index Migration Issues
- ✅ Fixed migration function signature pattern to follow Sequelize standards
- ✅ Fixed Work Type Detection in Frontend UI
- ✅ Fixed Vector Dimensionality Mismatch in Work Type Detection
- ✅ Fixed Language Model Provider API Key and Model Selection Issues
- ✅ Refactored settings retrieval with unified suffix map pattern for consistency
- ✅ Deprecated direct DeepSeek service usage in favor of provider abstraction
- ✅ Fixed DeepSeek API testing in AI Provider Settings component
- ✅ Migrated embedding provider from DeepSeek to Google Gemini
- ✅ Removed DeepSeek from embedding options in AI Provider UI
- ✅ Fixed foreign key constraint issue with source_maps and estimate_items
- ✅ Fixed Sequelize client_type column syntax issues with invalid COMMENT...USING syntax
- ✅ Fixed database initialization issue by properly handling view dependencies
- ✅ Enhanced error handling to prevent circular JSON reference errors in logs
- ✅ Improved migration system with multiple fallback mechanisms
- ✅ Fixed Docker migration setup to correctly locate and process migration files
- ✅ Implemented robust database schema management system with view dependency handling
- ✅ Enhanced work types knowledge base with improved database structure and validation
- ✅ Converted raw SQL migration to Sequelize for CI parity and transaction handling
- ✅ Implemented ENUM constraints for measurement types and units validation
- ✅ Added name_vec column and revision tracking for future enhancements
- ✅ Fixed Unicode issues in work types data and added stronger duplicate prevention
- ✅ Implemented rate limiting for similarity search API endpoints
- ✅ Aligned search parameters for consistency across the application
- ✅ Completed Phase B enhancements to work types with costs, materials, and safety tags
- ✅ Added cost history tracking with region support for analyzing price trends
- ✅ Integrated cost and safety data with PromptEngine for better estimate generation
- ✅ Created comprehensive UI for managing work type costs, materials, and safety requirements
- ✅ Implemented caching for work types knowledge base to improve performance
- ✅ Added composite unique index on work_type_materials to prevent duplicates
- ✅ Created comprehensive OpenAPI documentation for work types API
- ✅ Added integration tests for cost history endpoints
- ✅ Integrated frontend components with work_types database entries
- ✅ Finalizing unified LLM estimate generator implementation with API endpoint consistency fixes
- ✅ Completing backend similarity checking service for catalog integration
- ✅ Enhancing ItemsList component for better integration with catalog actions
- ✅ Implementing strong error handling for LLM generation processes
- ✅ Optimizing performance for asynchronous operations in estimate generation
- ✅ Fixed LLM estimate generator service field structure issues
- ✅ Implemented smart assessment data utilization to prevent redundant data entry
- ✅ Installed pgvector and pg_trgm PostgreSQL extensions for enhanced similarity search
- ✅ Implemented AI-driven conversation workflow for inspections and estimate creation
- ✅ Implemented intelligent catalog deduplication with similarity matching
- ✅ Completed vector search implementation for catalog matching
- ✅ Integrated existing DeepSeek API with vector embeddings functionality
- ✅ Implemented automated embedding generation for new catalog products
- ✅ Created work types knowledge base for mobile-home repair tasks
- ✅ Implemented similarity search for work types to prevent duplicates
- ✅ Fixed API prefix duplication issue in frontend services causing `/api/api/` paths
- ✅ Created custom ESLint rule to prevent hard-coded `/api/` prefixes
- ✅ Implemented automatic script to clean up duplicate prefixes
- ✅ Added documentation about API path prefixing convention to README.md
- ✅ Successfully ran script to fix all 15 affected service files
- ✅ Manually fixed remaining instances in community.service.js
- ✅ Verified fix by testing login and communities page functionality
- ✅ Fixed AI Provider Settings component syntax error and improved error handling
- ✅ Fixed AI Provider Settings response format handling to properly display settings
- ✅ Fixed JobId Mismatch in Embedding Queue Integration
- ✅ Fixed Docker Configuration for BullMQ Module Resolution
- ✅ Fixed migration issues with non-idempotent migrations causing endless restart loops
- ✅ Fixed scope-to-condition migration to properly handle assessment_id removal
- ✅ Fixed work_types table creation order in migrations to prevent relation errors
- ✅ Fixed client_view migration to remove dependency on non-existent modules
- ✅ Created direct SQL scripts to fix database issues when migrations fail
- ⏳ Implementing CI check to prevent regression of API prefix issues
- ⏳ Collecting user feedback on AI Wizard (v2) UX
- ⏳ Monitoring vector search performance metrics
- ⏳ Fine-tuning confidence thresholds based on real-world data
- ⏳ Fixing Redis connection configuration for BullMQ workers
- ⏳ Testing the full estimate job generation pipeline

## Recent Achievements  

### Fixed Client Address Deletion and Removed Pre-Assessments Feature

- **Identified Issue**: Address deletion was failing with transaction abort due to SQL query for non-existent `status` column in deprecated `pre_assessments` table
- **Root Cause**: The `SafeAddressService.safeDeleteAddress` method was querying the pre_assessments table which had been deprecated but not fully removed
- **Implementation Details**:
  - Removed the pre-assessment check from `addressService.safe.js` that was causing the SQL error
  - Removed pre-assessment references from `ClientSettings.vue` frontend component
  - Created migration to drop the pre_assessments table completely
  - Dropped the foreign key constraint from projects table to pre_assessments
  - Dropped the pre_assessment_id column from projects table  
  - Fixed migration file to use proper Sequelize syntax instead of non-existent `getForeignKeys` method
  - Updated migration to handle cases where table/constraints might already be removed
- **Results**:
  - Client addresses can now be deleted successfully without transaction errors
  - All references to the deprecated pre_assessments feature have been removed
  - Database schema is cleaner without orphaned tables
  - Migration system now properly handles already-applied changes

### Enhanced Work Type Detection with Multiple Confidence Thresholds

- **Identified Issue**: Work type detection logic was dropping fragments from unmatched once any match ≥ 0.35 was found
- **Business Rule Change**: Need to keep normal suggestions at 0.35+, but also treat fragments with top score < 0.60 as candidates for new work types
- **Implementation Details**:
  - Added `HARD_CREATE = 0.60` threshold in workTypeDetectionService.js
  - Modified detection logic to keep fragments with top scores < HARD_CREATE in the unmatched list
  - Enhanced frontend with visual cues - yellow chips with "(new)" indicator for unmatched fragments
  - Added integration with Vue Router for seamless navigation to work type creation page
  - Created comprehensive tests to validate the new threshold-based behavior
- **Results**:
  - Fragments with no good matches (< 0.35) appear only in unmatched list (previous behavior)
  - Fragments with moderate matches (0.35-0.60) now appear in both existing and unmatched lists
  - Fragments with strong matches (≥ 0.60) appear only in existing suggestions
  - "Cleaning skylight" now appears in unmatched list even with a 0.44 match to "Skylight Replacement"
  - Improved user experience with clear paths for creating new work types when needed

### Implemented Robust Database Restoration Process with Idempotent Migrations

- **Identified Issues**: Several migrations were not idempotent, causing restoration failures
  - ENUM value additions failed with "value already exists" errors
  - Extension creation lacked IF NOT EXISTS clauses
  - Index creation without proper existence checks
  - NULL timestamp values in settings table violating NOT NULL constraints

- **Implemented Solutions**:
  - Refactored enum-modifying migrations to use PostgreSQL DO blocks with existence checks
  - Added proper IF NOT EXISTS clauses to extension and index creation
  - Created migrations to handle NULL timestamps in existing data
  - Developed PostgreSQL-specific patterns for safe idempotent migrations

- **Results**:
  - Successfully restored database from April 24th backup
  - Applied all post-backup migrations cleanly
  - Maintained both legacy data (communities table) and newer schema elements
  - Established patterns for reliable database restoration and migration

### Fixed Vector Dimension and HNSW Index Migration Issues

- **Identified Issues**: Migration failures due to dimension limits on existing ivfflat index and incorrect function signatures
- **Implemented Solutions**:
  - Added DO block to identify and drop ivfflat indexes before altering vector dimensions
  - Fixed SQL dollar quoting syntax from `DO $` to `DO $$` for proper PostgreSQL compatibility
  - Updated migration function signatures from `async up({ context: queryInterface })` to `async up(queryInterface, Sequelize)`
  - Added compatibility layer with `const qi = queryInterface` where needed
  - Added drop statement for existing HNSW indexes before recreation to prevent conflicts
  - Modified `setup-work-types-db.sh` script to skip duplicate index creation
  - Enhanced pgvector version checks to safely handle older versions
- **Results**: Migrations now complete successfully without errors about undefined sequelize or dimension limits

### Implemented V2 Estimate Generation Performance Improvements

- **Offloaded Embedding Calls**: Implemented BullMQ job queue and worker to handle embedding generation asynchronously, unblocking the API thread.
- **Replaced In-Memory Cache with Redis**: Switched work type detection cache from in-memory to Redis using `cache-manager` for shared caching across replicas.
- **Added pgvector HNSW Index**: Created a database migration to add an HNSW index on the `work_types.name_vec` column, significantly improving vector search performance.
- **Reduced Vector Precision**: Optimized vector literal generation by reducing precision from 6 to 4 decimal places, decreasing payload size.
- **Compacted Assessment Payloads**: Implemented a utility to trim assessment data (scope, notes) before sending to the LLM, reducing token usage and latency.
- **Asynchronous Estimate Generation**: Refactored the estimate generation endpoint to use a fire-and-forget pattern with BullMQ, returning a job ID for status polling, improving UI responsiveness.

### Fixed Work Type Detection in Frontend UI

- Resolved critical issue with work type suggestions not appearing when typing in the condition field
- Fixed multiple issues in the workTypeDetectionService.js:
  - Added support for typed arrays (like Float32Array) by converting them to plain arrays using Array.from()
  - Fixed vector literal formatting with precision control using Number(v.toFixed(6))
  - Simplified the vector query by removing unreachable code branch
  - Fixed variable scope issue by hoisting vecResults to the outer scope
  - Fixed SQL query binding parameters to only pass the vector literal
  - Added null check to the score filter to prevent errors
- Enhanced error handling and logging throughout the detection process
- Successfully tested the fix with real-world condition text inputs
- Improved the user experience by providing relevant work type suggestions based on condition text

### Fixed DeepSeek API Testing Issue in AI Provider Settings

- Resolved critical error: `TypeError: Cannot read properties of undefined (reading 'model')` when testing API connections
- Fixed two related issues:
  - Double response unwrapping in ai-provider.service.js was removing the success flag needed by components
  - Frontend component was expecting deeper nesting (`response.data.data.model`) than the API provided
- Implemented comprehensive solution:
  - Updated service methods to return complete response objects without unwrapping
  - Updated component to access data at the correct nesting level
  - Maintained the standardized `{ success, data?, message? }` response format through all layers
  - Added detailed logging to validate response structures
- Ensured consistency in API response handling across the application
- Successfully fixed both language model and embedding API testing functionality

### Fixed Foreign Key Constraint Issue in source_maps Table and Database Initialization

- Resolved critical error: `insert or update on table "source_maps" violates foreign key constraint "source_maps_estimate_item_id_fkey"`
- Fixed two related issues:
  - Sequelize-sync was trying to re-define client_type with invalid COMMENT...USING syntax
  - source_maps table rows were being inserted before referenced estimate_items rows existed
- Implemented comprehensive solution:
  - Created migration to clean up orphaned records and add DEFERRABLE INITIALLY DEFERRED constraint
  - Updated initDb.js to use `{ alter: false }` to prevent automatic schema modifications
  - Removed problematic `comment` field from Client.js model to prevent invalid SQL generation
  - Fixed Docker migration setup to correctly locate and process migration files
  - Used proper transaction handling to ensure atomic operations
  - Created configuration files for consistent database access in both local and container environments
- Added verification steps to confirm all foreign key references are valid
- Successfully eliminated startup errors and ensured data integrity

### Fixed Database Initialization with View Dependency Handling

- Resolved critical database initialization error: `cannot alter type of a column used by a view or rule`
- Fixed issues with the `payment_terms` column modification being blocked by `client_view` dependency
- Implemented multi-layered solution with both preventive measures and fallback mechanisms
- Added proper sequence for safe schema modifications: drop view → modify column → recreate view
- Enhanced logging to prevent circular JSON reference errors when handling Sequelize objects
- Created `safeStringify()` utility function to handle complex objects with circular references
- Modified Sequelize sync to use `{ alter: false }` to prevent automatic schema modifications
- Added transaction-based approach to ensure atomicity of view operations
- Developed custom Umzug logger to safely handle log serialization
- Implemented fallback mechanisms to ensure database initialization succeeds even if primary approach fails

### Fixed AI Provider Settings Component and Response Format Handling

- Fixed Vue component syntax error in `AiProviderSettings.vue` causing compilation failure
- Restructured large, monolithic `loadData` function into smaller, focused functions for better maintainability
- Improved error handling with proper try/catch/finally blocks throughout asynchronous code
- Enhanced data validation with robust null/undefined checking at all levels
- Refactored `ai-provider.service.js` to properly handle unexpected API response formats
- Implemented fallback mechanisms to ensure UI remains functional even when API responses are incomplete
- Added detailed debugging logging to help identify response structure issues
- Applied software engineering best practices with single-responsibility functions and better code organization
- Fixed response format handling to properly display AI provider settings in the UI
- Enhanced service methods to handle different response structures with proper fallbacks
- Added more robust error handling with detailed error messages
- Implemented flexible response structure handling to accommodate different API response formats
- Added enhanced debugging information to trace data flow through the application
- Updated backend controller with more detailed logging for better diagnostics

### Completed API Prefix Duplication Fix

- Successfully fixed 15 frontend service files with duplicate API prefixes
- Used the existing `scripts/stripApiPrefix.js` script to automatically remove duplicate prefixes
- Manually fixed remaining instances in `community.service.js` that weren't caught by the script
- Verified the custom ESLint rule (`no-hardcoded-api`) was properly configured to prevent future occurrences
- Confirmed documentation in README.md about the API path prefixing convention
- Restarted the frontend service and verified that login and communities page work correctly
- Checked browser network tab to ensure requests use correct paths without duplication
- Established a pattern for consistent API path handling across all service files

### Implemented Database Schema Management System

- Created comprehensive ViewManager utility for handling database view dependencies during schema changes
- Implemented DependencyAnalyzer to identify dependencies between database objects before modifications
- Created MigrationChecker for pre-migration validation to identify potential issues
- Developed ModelSchemaComparer and ModelSyncTool for reconciling differences between models and database
- Built robust migration testing framework with automatic database backup and restore
- Created a DocumentationGenerator for automatically documenting database structure
- Fixed critical issue with client_view dependency on payment_terms column using transaction-based migration
- Implemented proper error handling in migrations with rollback support
- Added view definitions registry for consistent recreation of views

### Implemented Caching for Work Types Knowledge Base [Superseded by Redis Cache]

- *Note: The initial in-memory cache (Cache class) has been replaced by a shared Redis cache.*
- Implemented Redis caching using `cache-manager` for `findSimilarWorkTypes` and `getTagsByFrequency` methods.
- Added fallback to memory cache if Redis connection fails.
- Created database migrations for improved data integrity with proper indexes.
- Added comprehensive OpenAPI documentation for work types API endpoints.
- Created integration tests for cost history endpoints and validation.
- Implemented proper cache invalidation when work types are updated.

### Completed Phase B Work Types Knowledge Base Enhancements

- Extended the work types database schema with cost, productivity, materials, and safety data
- Created bidirectional relationships between work types and materials through the product catalog
- Implemented cost history tracking with region support for trending and analysis
- Developed a tabbed UI for managing work type details, costs, and materials/safety
- Added automatic PromptEngine integration to include cost references and safety guidance in LLM prompts
- Created seed data and import scripts for batch updating of cost and material information
- Implemented role-based access control for cost editing and management
- Added visual safety tag indicators with color-coding based on risk category

### Implemented Work Types Knowledge Base for Mobile-Home Repair Tasks

- Created structured database schema for work types with PostgreSQL pg_trgm integration
- Implemented 80 standardized work types across five parent buckets
- Built flexible measurement type system (area, linear, quantity) with standard units
- Developed frontend interface for browsing, filtering, and managing work types
- Created similarity search functionality to prevent duplicate work types
- Integrated with existing pg_trgm and pgvector infrastructure for efficient matching
- Designed two-phase implementation plan with future cost/materials enhancements
- Added comprehensive documentation and setup automation scripts

### Implemented Smart AI Conversation Workflow and Catalog Deduplication

- Developed a two-phase AI conversation approach (Scope Scan → Draft Items)
- Created a three-step wizard UI for a guided user experience
- Implemented catalog deduplication with multiple confidence levels
- Integrated PostgreSQL extensions (pg_trgm, pgvector) for efficient similarity matching
- Added feature flag for gradual rollout and testing
- Created comprehensive documentation for setup and usage

### Completed LLM Estimate Generator Implementation and Enhancements

- Implemented missing endpoints for catalog similarity checking
- Enhanced ItemsList.vue with item selection and catalog match indicators
- Added bulk product creation capability to products.service.js
- Improved visual feedback for catalog matches with similarity scores
- Integrated CatalogActions component with the generator workflow
- Added finishing workflow to create complete estimates
- Fixed the `required_services` field being blank in the LLM response by updating API payloads
- Implemented smart detection of existing measurements from assessment data
- Added visual indicators to show which measurements are being used from assessments
- Eliminated redundant data entry by pre-filling information from assessment data
- Enhanced payload structure for consistent projectId handling across implementations

## Active Decisions

### LLM Estimate Generator Approach

- Implemented working solution based on AssessmentToEstimateView.vue reference model
- Ensured projectId is included consistently in multiple places in payload
- Maintained proper assessment data structure with necessary fields
- Used debug mode for better visibility during development
- Implemented smart assessment data utilization to eliminate redundant user input
- Added visual indicators to show which existing assessment data is being used
- Focused on showing only LLM-generated content without fallbacks
- Enhanced frontend validators to properly detect measurement existence in assessment data
- Improved controller handling of assessment data and project parameters

### Migration System Improvements

- Standardized migration function signatures to match Sequelize expectations
- Used PostgreSQL DO blocks with explicit existence checks for safe idempotent migrations
- Implemented transaction-based approach for all schema changes to ensure atomicity
- Created clear pattern for handling PostgreSQL view dependencies
- Added standardized logging and error handling throughout migrations
- Implemented migration organization strategy with _archive directory for problematic files

## Recent Changes

### Fixed Database Migration Issues

- Fixed migration issues with non-idempotent migrations causing endless restart loops
- Made migrations idempotent by adding checks for existing columns and constraints
- Fixed scope-to-condition migration to properly handle assessment_id removal
- Updated Project model to use condition instead of scope and removed assessment_id attribute
- Fixed work_types table creation order in migrations to prevent relation errors
- Moved problematic migrations to _archive directory to prevent execution
- Fixed client_view migration to remove dependency on non-existent modules
- Created direct SQL scripts to fix database issues when migrations fail
- Added proper checks for existing constraints using DO blocks with IF NOT EXISTS checks
- Enhanced error handling in migrations with detailed logging
- Created documentation for migration fixes in MIGRATION_FIXES.md and WORK_TYPES_FIX.md
- Implemented Project.hasOne association with ProjectInspection for condition category
- Updated all services to use the new condition field instead of scope
- Fixed assessment to job conversion to use the new pattern without assessment_id

### Fixed Database Constraints and Foreign Keys

- Fixed foreign key constraint issues in source_maps table with proper DEFERRABLE INITIALLY DEFERRED
- Corrected Docker migration setup to locate and process migration files correctly
- Created proper .sequelizerc and config.json files for consistent database access
- Optimized function signatures in migrations to match Umzug resolver expectations
- Enhanced database initialization to safely handle database views during schema changes
- Implemented circular JSON reference handling in logger with safe string conversion
- Updated Docker entrypoint script to ensure migrations run before server startup
- Modified Sequelize sync to use `{ alter: false }` to prevent automatic schema changes
- Implemented multiple fallback mechanisms for database initialization
- Updated migration runner to properly handle view dependencies during migrations
- Updated database migration process to handle view dependencies automatically
- Created transactional approach to schema changes that properly drops and recreates dependent views
- Implemented migration testing scripts to verify migrations in controlled environments
- Added utility functions for identifying database object dependencies before modification
- Enhanced database documentation generation to maintain up-to-date schema information
- Fixed PostgreSQL column type change for payment_terms field in clients table
- Created model-schema comparison tools to identify and fix discrepancies

### Enhanced LLM Estimate Generator

- Created comprehensive implementation guide for unified LLM estimate generator (llmEST.md)
- Implemented core component structure for estimate generator with dual-mode interface
- Developed catalog integration for similarity checking and duplicate prevention
- Built assessment context integration for improved estimate accuracy
- Fixed LLM estimate generator bugs: correct placement of `analyzeScope` and updated method calls
- Refactored frontend mapping and data handling for estimates

### Improved Project Workflow

- Enhancing project workflow with complete status lifecycle including rejected assessments
- Improving assessment workflow with clearer status transition options and reason tracking
- Implementing dashboard view for rejected assessments to improve business analytics
- Automating project state transitions based on scheduled dates
- Fixing UUID validation issues in API endpoints that don't require path parameters
- Optimizing project dashboard for single active job workflow with proper error handling

## Additional Completed Tasks

### Fixed Assessment Data Display in Estimate Conversion

- Fixed assessment data not displaying after selection in the assessment-to-estimate conversion workflow
- Corrected API endpoint URL in standardized-estimates.service.js to use the proper endpoint
- Enhanced frontend components to handle both formattedMarkdown and formattedData properties
- Added computed property normalizedAssessment to ensure consistent data structure
- Improved error handling and debugging for assessment data loading

### WebSocket Security Implementation

- Fixed WebSocket connection issues when accessing the application over HTTPS
- Updated Vite configuration to use host-based settings instead of explicit protocol
- Prevented mixed content errors in modern browsers
- Ensured compatibility with Nginx Proxy Manager for SSL termination

### UI Enhancement with Tooltips

- Replaced explanatory text on buttons with tooltips for cleaner UI
- Implemented BaseTooltip component for contextual help
- Used concise tooltip text (e.g., "Ad type required") instead of longer explanations
- Fixed button variant validation issues to prevent console warnings

### Implemented Flexible AI Provider Management System

- Created a comprehensive system for managing AI language model and embedding providers
- Implemented embeddingProvider.js service with support for multiple providers (DeepSeek, Gemini, OpenAI)
- Created languageModelProvider.js service for language tasks with provider abstraction
- Updated workTypeDetectionService to use the new embeddingProvider instead of directly using DeepSeek
- Added AI provider controller with settings management and connection testing endpoints
- Created a settings-based approach with environment variable fallbacks for configuration
- Implemented frontend settings UI for AI provider management in admin settings
- Added connection testing features for both language and embedding providers
- Created database migration for adding AI provider settings
- Added proper error handling and reinitialize capabilities for config changes
- Implemented the AI provider settings UI in the existing settings menu with admin access control
- Default configuration uses DeepSeek for both language tasks and embedding with option to switch to Gemini embeddings as needed

### Communities Module Implementation

- Created models for Communities and AdTypes with proper relationships
- Implemented API endpoints for managing communities and ad types
- Built frontend components following project conventions
- Ensured communities can be created without ad types but require them for activation
- Added validation to prevent setting communities as active without ad types

### Database Migration

- Successfully migrated from SQLite to PostgreSQL
- Fixed column naming issues (active vs is_active) in communities table
- Implemented proper case conversion between frontend and backend
- Added debugging to trace data flow through the application

## Environment Details

- Frontend: Vue.js 3 with Vite running in Docker container on port 5173
- Backend: Node.js/Express running in Docker container on port 3000
- Database: PostgreSQL 16 running in Docker container on port 5432 (migrated from SQLite)
- Docker Compose for orchestration
- Nginx Proxy Manager for SSL termination in production

## Next Steps

- ✅ **Documented Migration Best Practices**: Created standardized patterns for idempotent migrations with proper function signatures
- ✅ **Fixed Address Deletion Issue**: Updated `addressService.js` to check for dependent records before deletion and provide descriptive error messages.
- ✅ **Fixed Address Display in Estimates**: Updated `ClientSelector.vue` to honor the estimate's linked `selectedAddressId` instead of defaulting to the primary address.
- **Implement CI Check**: Create CI check to validate migration function signatures and prevent regression
- **Monitor Performance**: Track the performance impact of the new job queues, Redis cache, and HNSW index
- **Refine Frontend Polling**: Improve the frontend UI for the asynchronous estimate generation (e.g., add progress indicators, cancellation options)
- **Optimize Compaction**: Fine-tune the `compactAssessment` utility based on LLM performance and accuracy
- **Scale Workers**: Adjust the concurrency settings for the embedding and estimate workers based on load
- **Add pgvector Version Check**: Implement a guard in the migration to check for pgvector >= 0.5 before creating the HNSW index
- **Fix Timeout Interval**: Update embedQueue.waitUntilFinished to clear the interval on resolve to prevent memory leaks
- **Implement Progress Reporting**: Add job.updateProgress() calls in the estimate worker for better UI feedback
- **Add Redis Outage Guards**: Implement additional error handling for cases where Redis is unavailable during job submission
- **Enhance Address Deletion**: Consider adding a `reassignTo` parameter in `deleteAddress` to update dependent records before deletion, with user confirmation.
- **Add Cascading Update Prompt**: Implement a confirmation dialog in `EditEstimate.vue` for cascading address updates to related projects if required by business rules.
- **Update Unit Tests**: Add regression tests for `ClientSelector.vue` to cover `selectedAddressId` propagation and single emit behavior.
- Implement AI-driven conversation workflow for smarter inspection-to-estimate conversion
- Develop catalog deduplication with both trigram (pg_trgm) and vector similarity (pgvector) matching
- Create user interfaces for handling potential duplicate detection with confidence scoring
- Implement automatic product linking for high-confidence matches
- Build interactive duplicate resolution for medium-confidence matches
- Add comprehensive end-to-end testing for both generation modes (including async flow)
- Add documentation for the newly implemented catalog similarity features
- Add detailed unit testing for assessment data matching functionality
- Improve error handling for edge cases in measurement matching
- Gather user feedback on the improved estimate generation workflow
- Consider extending the smart data utilization pattern to other parts of the application
- Collect user feedback on work types UI implementation for further refinements
- Enhance work types dashboard widget with additional data visualizations
- Test AI provider integration with various embedding models for performance comparison
- Consider adding more provider options as they become available
- Implement monitoring for API usage of different providers
