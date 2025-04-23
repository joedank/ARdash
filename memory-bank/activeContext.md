# Active Context: Construction Management Web Application

This document captures the current work focus, recent changes, active decisions, and important patterns and preferences.

## Current Focus

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
- ⏳ Collecting user feedback on AI Wizard (v2) UX
- ⏳ Monitoring vector search performance metrics
- ⏳ Fine-tuning confidence thresholds based on real-world data
- ✅ Expanded work types knowledge base with cost, productivity, material data and safety tags (Phase B)

## Recent Achievements

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



### Implemented Caching for Work Types Knowledge Base

- Implemented a Cache class with TTL (Time-To-Live) support for work types service
- Added caching for findSimilarWorkTypes method to improve performance during estimate generation
- Added caching for getTagsByFrequency method to reduce database load
- Created database migrations for improved data integrity with proper indexes
- Added comprehensive OpenAPI documentation for work types API endpoints
- Created integration tests for cost history endpoints and validation
- Implemented proper cache invalidation when work types are updated

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

## Recent Changes

- Updated database migration process to handle view dependencies automatically
- Created transactional approach to schema changes that properly drops and recreates dependent views
- Implemented migration testing scripts to verify migrations in controlled environments
- Added utility functions for identifying database object dependencies before modification
- Enhanced database documentation generation to maintain up-to-date schema information
- Fixed PostgreSQL column type change for payment_terms field in clients table
- Created model-schema comparison tools to identify and fix discrepancies

- Created comprehensive implementation guide for unified LLM estimate generator (llmEST.md)
- Implemented core component structure for estimate generator with dual-mode interface
- Developed catalog integration for similarity checking and duplicate prevention
- Built assessment context integration for improved estimate accuracy
- Fixed LLM estimate generator bugs: correct placement of `analyzeScope` and updated method calls
- Refactored frontend mapping and data handling for estimates

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

- Implement AI-driven conversation workflow for smarter inspection-to-estimate conversion
- Develop catalog deduplication with both trigram (pg_trgm) and vector similarity (pgvector) matching
- Create user interfaces for handling potential duplicate detection with confidence scoring
- Implement automatic product linking for high-confidence matches
- Build interactive duplicate resolution for medium-confidence matches
- Add comprehensive end-to-end testing for both generation modes
- Add documentation for the newly implemented catalog similarity features
- Add detailed unit testing for assessment data matching functionality
- Improve error handling for edge cases in measurement matching
- Gather user feedback on the improved estimate generation workflow
- Consider extending the smart data utilization pattern to other parts of the application
- Collect user feedback on work types UI implementation for further refinements
- Enhance work types dashboard widget with additional data visualizations
