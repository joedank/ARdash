## Current Implementation Status

### Current Progress
1. **Work Types Knowledge Base (Phase A & B)**: Completed with standardized taxonomy, measurement types, similarity search, cost tracking, materials management, and safety tags
2. **Work Types API**: Implemented with complete CRUD operations, similarity search endpoint, and role-based access control
3. **Database Standardization**: Completed with all fields successfully converted to snake_case format
4. **Frontend Adaptation**: Significant progress with standardized services implemented for key entities (invoices, estimates, clients, work types)
5. **Backend Standardization**: Partially completed with updated controllers created and some deployed
6. **Standardized Service Pattern**: Implemented for critical components with proper data conversion between frontend and backend
7. **Database Migration**: Successfully migrated from SQLite to PostgreSQL with proper column naming and data types
8. **Communities Module**: Implemented communities and ad types functionality with proper database structure

### Open Issues
1. **Property Naming Inconsistencies**: Some components still use mixed camelCase and snake_case in frontend templates
2. **Controller Replacement**: Some updated controllers still need to be deployed
3. **Entity ID Handling**: Some components may still rely on specific ID field names (id vs entityId)
4. **Assessment Data Display Issue**: [FIXED] The assessment-to-estimate conversion workflow had an issue where assessment data was not displaying after selection
   - Fixed incorrect API endpoint URL in `standardized-estimates.service.js` (changed from `/api/assessment/for-project/${projectId}` to `/estimates/llm/assessment/${projectId}`)
   - Enhanced frontend components to handle both `formattedMarkdown` and `formattedData` properties
   - Added computed property `normalizedAssessment` in `AssessmentToEstimateView.vue` to ensure consistent data structure
   - Updated `AssessmentMarkdownPanel.vue` to use either property with a fallback mechanism

### Critical Next Steps
1. Enhance assessment-to-estimate conversion workflow:
   - Add validation to ensure all required data is present before allowing estimate creation
   - Implement comprehensive error handling for missing or malformed inspection data
   - Add unit tests to verify assessment data loading and display
2. Continue implementing standardized services for remaining entities
3. Ensure consistent property naming in all frontend components (use camelCase consistently)
4. Deploy remaining updated controllers
5. Add robust error handling and logging throughout the application
6. Implement fallback mechanisms for potentially undefined values in critical functions
7. Complete testing of communities module functionality
8. Implement additional validation for work type materials and tags endpoints
9. Enhance work type cost history visualization with trend analysis
10. Integrate work type safety tags with estimate generation for safety requirements

# Database and Routes Map

This document provides a comprehensive overview of the database structure and API routes in the Construction Management Web Application. It serves as a reference to prevent duplicate or confusing routes and to maintain a clear understanding of the data relationships.

## Database Structure

### Core Entities

#### Work Types
- **Table**: `work_types`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `name`, `parent_bucket`, `measurement_type`, `suggested_units`, `name_vec`, `revision`, `updated_by`, `unit_cost_material`, `unit_cost_labor`, `productivity_unit_per_hr`
- **Relationships**:
  - One-to-Many with `work_type_materials`
  - One-to-Many with `work_type_tags`
  - One-to-Many with `work_type_cost_history`
- **Parent Buckets**: Interior-Structural, Interior-Finish, Exterior-Structural, Exterior-Finish, Mechanical
- **Measurement Types**: ENUM ('area', 'linear', 'quantity') with check constraints
- **Constraints**: Check constraint ensures suggested_units match measurement_type:
  - area → 'sq ft', 'sq yd', 'sq m'
  - linear → 'ft', 'in', 'yd', 'm'
  - quantity → 'each', 'job', 'set'
- **Indexes**: Trigram index on name column (idx_work_types_name) using gin (name gin_trgm_ops)
- **Notes**: Uses pg_trgm for similarity search (0.85 threshold for duplicates), prepared for pgvector integration, includes revision tracking, cost tracking, material mapping, and safety tags

#### Work Type Materials
- **Table**: `work_type_materials`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `work_type_id`, `product_id`, `qty_per_unit`, `unit`
- **Relationships**:
  - Many-to-One with `work_types` (via `work_type_id`)
  - Many-to-One with `products` (via `product_id`)
- **Notes**: Maps work types to their required materials with quantity calculations

#### Work Type Tags
- **Table**: `work_type_tags`
- **Primary Key**: Composite (`work_type_id`, `tag`)
- **Key Fields**: `work_type_id`, `tag`
- **Relationships**:
  - Many-to-One with `work_types` (via `work_type_id`)
- **Notes**: Stores safety, permitting, and licensing requirements as tags

#### Work Type Cost History
- **Table**: `work_type_cost_history`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `work_type_id`, `region`, `unit_cost_material`, `unit_cost_labor`, `captured_at`, `updated_by`
- **Relationships**:
  - Many-to-One with `work_types` (via `work_type_id`)
  - Many-to-One with `users` (via `updated_by`)
- **Notes**: Records cost changes over time with region support for geographic variations

#### Users
- **Table**: `users`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `username`, `email`, `password`, `role`, `theme_preference`
- **Relationships**: None explicitly defined in foreign keys
- **Notes**: Supports soft delete with `deleted_at`

#### Clients
- **Table**: `clients`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `display_name`, `company`, `email`, `phone`, `client_type`
- **Relationships**:
  - One-to-Many with `client_addresses`
  - One-to-Many with `projects`
  - One-to-Many with `invoices` (via `client_id`) [Standardized from `client_fk_id`]
  - One-to-Many with `estimates` (via `client_id`) [Standardized from `client_fk_id`]
- **Notes**: Includes payment terms and tax rate defaults

#### Client Addresses
- **Table**: `client_addresses`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `client_id`, `name`, `street_address`, `city`, `state`, `postal_code`, `is_primary`
- **Relationships**:
  - Many-to-One with `clients`
  - One-to-Many with `projects` (via `address_id`)
  - One-to-Many with `invoices` (via `address_id`)
  - One-to-Many with `estimates` (via `address_id`)
  - One-to-Many with `pre_assessments` (via `client_address_id`)
- **Notes**: Supports primary address flag

#### Projects
- **Table**: `projects`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `client_id`, `type`, `status`, `scheduled_date`, `condition`
- **Relationships**:
  - Many-to-One with `clients`
  - Many-to-One with `client_addresses` (via `address_id`)
  - Many-to-One with `estimates` (via `estimate_id`)
  - One-to-Many with `project_inspections`
  - One-to-Many with `project_photos`
  - Self-referential: Assessment to Job conversion (via `converted_to_job_id`)
  - Many-to-One with `pre_assessments` (via `pre_assessment_id`)
  - One-to-One with `project_inspections` (scoped association for condition category)
- **Notes**:
  - Supports multiple project types and statuses
  - The `condition` field replaced the previous `scope` field
  - The `assessment_id` field has been removed in favor of using `project_inspections` with `category = 'condition'`
  - Condition-style "assessment" is now a `project_inspections` row where `category = 'condition'`

#### Project Inspections
- **Table**: `project_inspections`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `project_id`, `category`, `content` (JSONB)
- **Relationships**:
  - Many-to-One with `projects`
  - One-to-Many with `project_photos` (via `inspection_id`)
- **Notes**: Stores structured inspection data in JSON format
- **Content Structure**:
  - `measurements`: Contains items with dimensions, quantities, and measurement types
  - `condition`: Contains assessment details, severity, and notes
  - `materials`: Contains items with name, specification, quantity, and unit
- **Access Pattern**:
  - When queried via `projectService.getProjectWithDetails()`, inspections are returned with the alias `project.inspections`
  - The `getAssessmentData()` function in `estimates.controller.js` processes these inspections to extract measurements, conditions, and materials

#### Project Photos
- **Table**: `project_photos`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `project_id`, `photo_type`, `file_path`
- **Relationships**:
  - Many-to-One with `projects`
  - Many-to-One with `project_inspections` (optional, via `inspection_id`)
- **Notes**: Categorizes photos by type (before, after, etc.)

#### Estimates
- **Table**: `estimates`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `estimate_number`, `status`, `dateCreated`, `validUntil`
- **Relationships**:
  - Many-to-One with `clients` (via `client_id`) [Standardized from `client_fk_id`]
  - Many-to-One with `client_addresses` (via `address_id`)
  - Many-to-One with `projects` (via `project_id`)
  - One-to-Many with `estimate_items`
  - Many-to-One with `invoices` (when converted, via `converted_to_invoice_id`)
- **Notes**: Supports PDF generation and conversion to invoice

#### Estimate Items
- **Table**: `estimate_items`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `estimate_id`, `description`, `quantity`, `price`, `tax_rate`
- **Relationships**:
  - Many-to-One with `estimates`
  - Many-to-One with `products` (optional, via `product_id`)
  - One-to-Many with `source_maps`
- **Notes**: Supports custom product data and source tracking

#### Invoices
- **Table**: `invoices`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `invoice_number`, `status`, `date_created`, `date_due`
- **Relationships**:
  - Many-to-One with `clients` (via `client_id`) [Standardized from `client_fk_id`]
  - Many-to-One with `client_addresses` (via `address_id`)
  - One-to-Many with `invoice_items`
  - One-to-Many with `payments`
- **Notes**: Supports PDF generation and soft delete

#### Invoice Items
- **Table**: `invoice_items`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `invoice_id`, `description`, `quantity`, `price`, `tax_rate`
- **Relationships**:
  - Many-to-One with `invoices`
- **Notes**: Similar structure to estimate items

#### Products
- **Table**: `products`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `name`, `price`, `tax_rate`, `type`, `unit`
- **Relationships**:
  - One-to-Many with `estimate_items` (via `product_id`)
- **Notes**: Supports product and service types, unit-based pricing (sq ft, ln ft, each), soft delete

#### Payments
- **Table**: `payments`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `invoice_id`, `amount`, `payment_date`, `payment_method`
- **Relationships**:
  - Many-to-One with `invoices`
- **Notes**: Tracks payment history for invoices

#### Settings
- **Table**: `settings`
- **Primary Key**: `id` (Integer)
- **Key Fields**: `key`, `value`, `group`
- **Relationships**: None
- **Notes**: Stores application configuration
- **Special Groups**:
  - `ai_provider`: Stores AI provider configuration settings
  - `llm_settings`: Stores language model configuration
  - `embedding_settings`: Stores embedding model configuration
- **AI Provider Settings**:
  - `openai_api_key`: API key for OpenAI
  - `deepseek_api_key`: API key for DeepSeek
  - `anthropic_api_key`: API key for Anthropic
  - `language_model_provider`: Selected provider for language model (openai, deepseek, anthropic)
  - `language_model`: Selected model name for the chosen provider
  - `embedding_provider`: Selected provider for embeddings (openai, deepseek)
  - `embedding_model`: Selected model name for embeddings
  - `embedding_enabled`: Boolean flag to enable/disable embedding functionality

#### LLM Prompts
- **Table**: `llm_prompts`
- **Primary Key**: `id` (Integer)
- **Key Fields**: `name`, `description`, `prompt_text`
- **Relationships**: None
- **Notes**: Stores configurable prompts for LLM integration

#### Source Maps
- **Table**: `source_maps`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `estimate_item_id`, `source_type`, `source_data` (JSONB)
- **Relationships**:
  - Many-to-One with `estimate_items`
- **Notes**: Maps estimate items to their data sources

### Pre-Assessment System

#### Pre Assessments
- **Table**: `pre_assessments`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `client_id`, `project_type`, `project_subtype`, `problem_description`
- **Relationships**:
  - Many-to-One with `clients`
  - Many-to-One with `client_addresses` (via `client_address_id`)
  - One-to-Many with `pre_assessment_photos`
  - One-to-Many with `pre_assessment_project_types`
  - One-to-Many with `projects` (via `pre_assessment_id`)
- **Notes**: Stores initial assessment data before project creation

#### Pre Assessment Photos
- **Table**: `pre_assessment_photos`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `pre_assessment_id`, `file_path`, `original_name`, `area_label`
- **Relationships**:
  - Many-to-One with `pre_assessments`
- **Notes**: Supports annotations in JSON format

#### Pre Assessment Project Types
- **Table**: `pre_assessment_project_types`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `pre_assessment_id`, `project_type`, `project_subtype`
- **Relationships**:
  - Many-to-One with `pre_assessments`
- **Notes**: Links pre-assessments to project types

#### Project Types
- **Table**: `project_types`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `name`, `value`, `description`, `active`
- **Relationships**:
  - One-to-Many with `project_subtypes`
- **Notes**: Defines available project types

#### Project Subtypes
- **Table**: `project_subtypes`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `project_type_id`, `name`, `value`, `description`, `active`
- **Relationships**:
  - Many-to-One with `project_types`
- **Notes**: Defines subtypes for each project type

#### Projects Status Transitions
Projects use the following status values, defined as an enum type in PostgreSQL:
- **Enum**: `enum_projects_status`
- **Values**: `pending`, `upcoming`, `in_progress`, `completed`, `rejected`
- **Transition Logic**:
  - New assessment projects start with `pending` status
  - Assessment projects can be marked as `rejected` when customers choose not to proceed
  - New active projects are determined by scheduled date:
    - Future dates → `upcoming`
    - Current or past dates → `in_progress`
  - Projects converted from assessments inherit the same date-based logic
  - Automatic transition: `upcoming` → `in_progress` when scheduled date arrives
  - Manual transition: `in_progress` → `completed` when work is finished
- **Associated API Endpoints**:
  - `GET /api/projects/upcoming` - Gets all upcoming projects
  - `GET /api/projects/rejected` - Gets all rejected assessments
  - `POST /api/projects/:id/reject` - Rejects an assessment with optional reason
  - `POST /api/projects/update-upcoming` - Updates projects from upcoming to in_progress
- **Automation**: Daily CRON job to update status for projects whose scheduled date has arrived

#### Project Type Questionnaires
- **Table**: `project_type_questionnaires`
- **Primary Key**: `id` (UUID)
- **Key Fields**: `project_type`, `project_subtype`, `questionnaire_schema` (JSONB)
- **Relationships**: None directly defined
- **Notes**: Stores questionnaire templates for project types

### Views

#### Client View
- **Table**: `client_view`
- **Purpose**: Provides a consolidated view of client data
- **Notes**: Not a physical table, but a database view

### Communities Module

#### Communities
- **Table**: `communities`
- **Primary Key**: `id` (Integer)
- **Key Fields**: `name`, `address`, `city`, `phone`, `spaces`, `state`
- **Relationships**:
  - One-to-Many with `ad_types` (via `community_id`)
  - Many-to-One with `ad_types` (via `selected_ad_type_id`)
- **Notes**: Stores community information with ad specialist contact details
- **Special Fields**:
  - `is_active` (Boolean): Indicates if the community is currently active
  - `ad_specialist_name`, `ad_specialist_email`, `ad_specialist_phone`: Contact information for ad specialists
  - `newsletter_link`: URL to the community newsletter
  - `general_notes`: Text field for additional information

#### Ad Types
- **Table**: `ad_types`
- **Primary Key**: `id` (Integer)
- **Key Fields**: `community_id`, `name`, `width`, `height`, `cost`
- **Relationships**:
  - Many-to-One with `communities` (via `community_id`)
  - One-to-Many with `communities` (via `selected_ad_type_id` in communities table)
- **Notes**: Stores advertisement types available for each community
- **Special Fields**:
  - `start_date`, `end_date`, `deadline_date`: Date fields for ad scheduling
  - `term_months`: Duration of the advertisement in months

## API Routes Structure

Based on the backend routes file (`backend/src/routes/index.js`), the following API routes are defined:

### Work Types Management
- `/api/work-types` - Work types CRUD operations and similarity search
- `/api/work-types/:id` - Individual work type operations with UUID validation
- `/api/work-types/:id/costs` - Update costs for a work type with cost history tracking
- `/api/work-types/:id/costs/history` - Get cost history for a work type with region filtering
- `/api/work-types/:id/materials` - Add materials to a work type
- `/api/work-types/:id/materials/:materialId` - Remove a material from a work type
- `/api/work-types/:id/tags` - Add tags to a work type
- `/api/work-types/:id/tags/:tag` - Remove a tag from a work type
- `/api/work-types/similar` - Find similar work types by name with threshold parameter
- `/api/work-types/tags/frequency` - Get tags grouped by frequency
- `/api/work-types/import` - Batch import of work types from CSV data

### Authentication and User Management
- `/api/auth` - Authentication routes
- `/api/users` - User management
- `/api/admin` - Administrative functions

### Client Management
- `/api/clients` - Client CRUD operations [Standardized with UUID validation]
- `/api/clients/:clientId/addresses` - Client address management [Standardized with UUID validation]
- `/api/addresses` - Direct address operations [Standardized, new route]

### Financial Management
- `/api/invoices` - Invoice management
- `/api/invoices/:invoiceId/items` - Invoice line items
- `/api/invoices/:invoiceId/payments` - Invoice payments
- `/api/estimates` - Estimate management
- `/api/estimates/:estimateId/items` - Estimate line items
- `/api/products` - Product catalog management

### Project Management
- `/api/projects` - Project CRUD operations [Standardized with UUID validation]
- `/api/projects/:projectId/inspections` - Project inspection data [Standardized with UUID validation]
- `/api/projects/:projectId/photos` - Project photo management [Standardized with UUID validation]
- `/api/assessment` - Assessment-specific operations
- `/api/communities` - Community management operations
- `/api/communities/:communityId/ad-types` - Ad types for specific communities

### System Configuration
- `/api/settings` - Application settings
- `/api/ai-provider` - AI provider configuration and management
- `/api/ai-provider/options` - Available AI provider options (models, providers)
- `/api/llm-prompts` - LLM prompt management
- `/api/upload` - File upload handling
- `/api/status` - System status checks

## Error Handling Architecture

The application now uses a standardized error handling middleware that ensures consistent error responses across all routes.

### Error Response Format
- All error responses follow the format: `{ success: false, message: string, data?: object }`
- Success responses follow the format: `{ success: true, message?: string, data: object }`

### Error Types and Status Codes
| Error Type | HTTP Status | Description |
|------------|-------------|-------------|
| ValidationError | 400 | Input validation errors with field information |
| UUIDValidationError | 400 | Invalid UUID format in route parameters |
| AuthenticationError | 401 | User is not authenticated |
| AuthorizationError | 403 | User lacks permission for the action |
| NotFoundError | 404 | Resource not found |
| BusinessLogicError | 422 | Business logic constraint violated |
| DatabaseError | 500 | Database operation error |

### Error Handling Integration
- Error middleware is registered after all routes but before the 404 handler
- All controllers pass errors to the middleware via `next(error)`
- Error middleware provides detailed logging with request context
- 404 handler uses the standardized response format

### Error Utilities
- Centralized `utils/errors.js` exports all error classes
- Controllers import and use appropriate error classes
- UUID validation middleware uses UUIDValidationError
- Database errors are automatically converted to standardized format

## Identified Issues and Inconsistencies

### Client ID Inconsistencies [Partially Resolved]
- **Problem**: Mixed naming and types for client IDs across tables
  - `estimates` and `invoices` tables now use standardized `client_id` field [Resolved]
  - Some frontend components use camelCase (`clientId`) while backend uses snake_case (`client_id`)
  - Inconsistent parameter naming in API routes
- **Impact**: Causes confusion in data mapping, increases risk of query errors, and complicates maintenance
- **Current Status**: Field names standardized in database tables; frontend adaptation in progress

### Address Reference Inconsistencies
- **Problem**: Inconsistent field naming for address references
  - Most tables use `address_id` to reference client addresses
  - `pre_assessments` uses `client_address_id` instead
  - Address retrieval lacks standardized approach (sometimes via client, sometimes direct)
  - Fallback mechanisms for missing addresses vary across components
- **Impact**: Complicates address management, increases risk of null references in documents
- **Current Status**: Added standardized address service; additional standardization pending

### Project Relationship Complexity [Improved]
- **Problem**: Complex and occasionally circular relationships
  - Self-referential relationships (`converted_to_job_id`)
  - Projects can link to both `pre_assessment_id` and `estimate_id`
  - Photo relationships to both projects and inspections add complexity
  - Relationship cascade behaviors not consistently defined
- **Impact**: Makes queries complex, increases risk of orphaned records, complicates data maintenance
- **Current Status**: Field names standardized in project-related tables; relationship documentation improved; assessment_id removed in favor of project_inspections

### Assessment to Condition Transition [Completed]
- **Problem**: Projects used `assessment_id` to reference assessment projects, creating circular references
- **Old Pattern**: Projects had an `assessment_id` column that referenced another project
- **New Pattern**: Condition-style "assessment" is now a `project_inspections` row where `category = 'condition'`
- **Implementation**:
  - Removed `assessment_id` attribute from Project model
  - Renamed `scope` to `condition` to match the database schema
  - Added scoped association: `Project.hasOne(ProjectInspection, { as: 'condition', scope: { category: 'condition' } })`
  - Updated all services to use the new pattern
  - Fixed assessment to job conversion to use the new pattern
- **Benefits**:
  - Simplified data model with fewer circular references
  - More consistent with the inspection-based architecture
  - Better separation of concerns between project metadata and inspection data
  - Easier to query and maintain
- **Current Status**: Fully implemented and tested

### Route Naming Inconsistencies [Partially Resolved]
- **Problem**: Inconsistent API route structures
  - Some routes use plural nouns (`/api/clients`), others might use singular
  - Nested resource routes follow different patterns in different controllers
  - Parameter naming varies (`clientId` vs `client_id` in routes)
  - Response format consistency not enforced across all endpoints
- **Impact**: Makes frontend service integration more complex, increases learning curve for developers
- **Current Status**: clients.routes.js, addresses.routes.js, and projects.routes.js now use standardized patterns

### UUID Validation Inconsistencies [Partially Resolved]
- **Problem**: Inconsistent UUID validation across controllers
  - Some controllers implement proper UUID validation with regex
  - Others pass UUIDs directly to queries without validation
  - Frontend validation for UUIDs before API calls varies
  - Error response format for invalid UUIDs not standardized
- **Impact**: Results in cryptic database errors instead of helpful validation messages
- **Current Status**: UUID validation middleware now used in clients, addresses, and projects routes; standardized error handling middleware integrated into app.js

## Standardization Implementation Progress

### Phase 1: Infrastructure Improvements [Completed]
- [x] Created UUID validation middleware (`uuidValidator.js`) with proper regex pattern
- [x] Implemented case conversion utilities in frontend (`casing.js`)
- [x] Created standardized error handling middleware (`standardized-error.middleware.js`)
- [x] Integrated standardized error handling middleware into app.js
- [x] Created centralized error classes in utils/errors.js
- [x] Implemented API adapter (`apiAdapter.js`) for frontend standardization
- [x] Enhanced clients, addresses, and projects routes with UUID validation
- [x] Created standardized address service for consistent address operations
- [x] Implemented standardized projects service for frontend
- [x] Created test suite for validation and standardization

### Phase 2: Database Standardization [Completed]
- [x] Created migration to standardize client_fk_id to client_id in invoices and estimates tables
- [x] Created migration to standardize project-related field names (client_id, address_id, project_id)
- [x] Created additional migration (20250413001000-standardize-remaining-fields.js) for remaining entities
- [x] Verified Project model uses standardized field names
- [x] Ran migrations in development environment for project-related tables
- [x] Created and applied SQL script to fix migration issues (handling client_id_new columns)
- [x] Successfully standardized all database fields to snake_case
- [x] Complete database field naming conventions with snake_case standard

### Phase 3: Route Standardization [In Progress]
- [x] Enhanced clients.routes.js with UUID validation
- [x] Added addresses.routes.js with standardized endpoints
- [x] Updated projects.routes.js with UUID validation
- [x] Integrated standardized error handling middleware into app.js
- [x] Updated 404 handler to use standardized response format
- [ ] Update remaining route files with UUID validation
- [ ] Apply the standardized response format to all controllers

### Phase 4: Frontend Adaptation [In Progress]
- [x] Enhanced clients.service.js with UUID validation and case conversion
- [x] Created address.service.js for standardized address operations
- [x] Created standardized-projects.service.js for consistent field naming
- [x] Created field-adapter.js utility for consistent camelCase/snake_case conversion
- [x] Created base.service.js with standardized CRUD operations
- [x] Added standardized-estimates.service.js with enhanced error handling and timeout support
- [x] Created useErrorHandler.js composable for frontend error management
- [x] Started updating EstimatesList.vue to use standardized-estimates.service.js
- [ ] Complete EstimatesList.vue refactoring to use standardized service
- [ ] Update other service files to use the standardization utilities
- [ ] Refactor remaining components to use standardized services

### Phase 5: Testing and Verification [In Progress]
- [x] Created test suite for standardization verification
- [x] Tested the standardized error handling middleware
- [x] Verified field names are properly standardized in the database
- [ ] Test all updated API endpoints
- [ ] Verify case conversion in API requests
- [ ] Test error handling for invalid UUIDs

### Phase 6: Documentation and Training [Planned]
- [x] Updated database-routes-map.md with standardization progress
- [x] Enhanced standardization-implementation-plan.md with current status
- [x] Updated standardization-tools-README.md with new components
- [x] Added documentation of standardized error handling in app.js
- [x] Created example of proper error class usage
- [ ] Create standardized naming conventions guide
- [ ] Create examples of proper UUID validation usage
- [ ] Document standardized route definition pattern

## Standardization Recommendations

### ID Field Naming Standardization

1. **Primary Key Standardization**:
   - Use `id` as the column name for all primary keys
   - Ensure all IDs use UUID type consistently
   - Add database-level constraints to enforce UUID format

2. **Foreign Key Naming Convention**:
   - Use `{tableName}_id` pattern for all foreign keys (e.g., `client_id`, `address_id`)
   - Rename inconsistent columns via migration (e.g., `client_fk_id` → `client_id`)
   - Update all model references to use the standardized names

3. **Frontend-Backend Consistency**:
   - Use camelCase in frontend (`clientId`, `addressId`)
   - Use snake_case in database (`client_id`, `address_id`)
   - Implement consistent field mapping in API controllers
   - Create utility functions for consistent case conversion

4. **Data Type Consistency**:
   - Ensure all ID fields use the same data type (UUID)
   - Add validation for ID format in both frontend and backend
   - Create shared validation middleware for UUID format checking

### Address Management Standardization

1. **Field Naming Consistency**:
   - Use `address_id` consistently for all tables that reference addresses
   - Rename `client_address_id` to `address_id` in `pre_assessments` table
   - Update all model references to use the standardized names

2. **Standardized Address Service**:
   - Create dedicated functions for common address operations
   - Implement standardized functions like `getPrimaryAddress`, `getAddressById`
   - Centralize address selection logic for documents
   - Add consistent fallback to primary address when needed

3. **Address Format Standardization**:
   - Create consistent address formatter for display
   - Standardize address validation across the application
   - Implement clear visual indication of primary address

### Response Format Standardization

1. **Standard Response Structure**:
   - Enforce standard response format: `{ success: true|false, data: {}, message: "" }`
   - Use appropriate HTTP status codes consistently
   - Implement centralized error handling middleware
   - Document expected response format for all endpoints

2. **Error Response Format**:
   - Use consistent HTTP status codes for validation errors (400) and not found errors (404)
   - Include descriptive error messages in responses
   - Add error details when appropriate in development mode
   - Use standardized error classes for different error types

## Next Steps

1. **Route Standardization**:
   - Update remaining route files to use UUID validation middleware
   - Apply standardized response format to all controllers
   - Ensure all controllers use the appropriate error classes

2. **Frontend Adaptation**:
   - Refactor frontend components to use standardized services
   - Implement consistent error handling on the frontend
   - Update service files to use case conversion utilities

3. **Testing and Verification**:
   - Test all updated API endpoints
   - Verify case conversion in API requests
   - Test error handling for invalid UUIDs
   - Verify CRUD operations with standardized field names

4. **Documentation and Training**:
   - Create standardized naming conventions guide
   - Document UUID validation pattern
   - Document case conversion utilities
   - Provide examples of standardized error handling

This document will be updated as standardization progresses and additional issues or solutions are identified.
