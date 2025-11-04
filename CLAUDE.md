# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a construction management web application with two main components:
- **Backend**: Node.js/Express API server with PostgreSQL database
- **Frontend**: Vue 3 SPA with Vite, PrimeVue UI components, and Tailwind CSS

## Common Development Commands

### Running the Application

```bash
# Start both frontend and backend concurrently
npm run dev

# Start services individually
npm run frontend:dev    # Frontend on port 5173
npm run backend:dev     # Backend on port 3000

# Using Docker
docker-compose up       # Start all services in containers

# Production build
npm run frontend:build
npm run backend:start
```

### Database Management

```bash
# Run migrations
cd backend && npm run migrate

# Generate work type embeddings
npm run embed:work-types

# Backfill embeddings for existing products
cd backend && npm run embed:backfill

# Direct database access via Docker
docker exec management-db-1 psql -U postgres -d management_db -c "QUERY HERE"

# List tables
docker exec management-db-1 psql -U postgres -d management_db -c "\dt"

# Describe table structure
docker exec management-db-1 psql -U postgres -d management_db -c "\d table_name"

# Check recent records
docker exec management-db-1 psql -U postgres -d management_db -c "SELECT * FROM table_name ORDER BY created_at DESC LIMIT 10;"
```

### Testing

```bash
# Backend tests
cd backend && npm test

# Frontend E2E tests
cd frontend && npm run test:e2e
```

## High-Level Architecture

### Backend Architecture

The backend follows a layered architecture:

1. **Routes** (`/backend/src/routes/`): Define API endpoints and middleware
2. **Controllers** (`/backend/src/controllers/`): Handle HTTP requests/responses
3. **Services** (`/backend/src/services/`): Business logic and external integrations
4. **Models** (`/backend/src/models/`): Sequelize ORM models for database entities
5. **Migrations** (`/backend/migrations/`): Database schema changes
6. **Workers** (`/backend/src/workers/`): Background job processors (BullMQ)
7. **Queues** (`/backend/src/queues/`): Job queue definitions

Key patterns:
- **Provider Abstraction**: AI services use provider pattern (`languageModelProvider.js`, `embeddingProvider.js`)
- **Standardized Error Handling**: Custom error classes and middleware for consistent API responses
- **Transaction-Based Migrations**: Safe schema changes with view dependency handling
- **Vector Search**: PostgreSQL with pgvector extension for semantic similarity

### Frontend Architecture

The frontend uses Vue 3 Composition API:

1. **Views** (`/frontend/src/views/`): Page-level components
2. **Components** (`/frontend/src/components/`): Reusable UI components
3. **Services** (`/frontend/src/services/`): API communication layer
4. **Stores** (`/frontend/src/stores/`): Pinia state management
5. **Composables** (`/frontend/src/composables/`): Reusable composition functions
6. **Router** (`/frontend/src/router/`): Vue Router configuration

Key patterns:
- **Standardized Services**: All API services extend `BaseService` for consistent data handling
- **Case Conversion**: Automatic camelCase/snake_case conversion at API boundaries
- **Component Guidelines**: Consistent structure with proper error handling and validation
- **Dual ID Pattern**: Support for both `id` and `entityId` properties for compatibility

### Database Schema

PostgreSQL with extensions:
- **pgvector**: Vector embeddings for semantic search (products, work types)
- **pg_trgm**: Trigram matching for fuzzy text search

Key tables:
- `users`, `clients`, `projects`, `estimates`, `invoices`: Core business entities
- `work_types`, `work_type_materials`, `work_type_tags`: Knowledge base
- `products`: Catalog with vector embeddings
- `settings`: Configuration storage

### External Integrations

- **AI Providers**: OpenAI, Google Gemini (configurable via settings)
- **PDF Generation**: Puppeteer with EJS templates
- **File Storage**: Local filesystem with uploads directory
- **Background Jobs**: Redis + BullMQ for async processing

## Important Patterns and Conventions

### API Path Prefixing

- API service has `baseURL: '/api'`
- Service methods use paths without `/api/` prefix
- ESLint rule prevents hard-coded `/api/` prefixes

### Case Naming Conventions

- **Frontend**: camelCase for all properties
- **Backend/Database**: snake_case for all fields
- **Conversion**: Handled automatically by standardized services
- **CRITICAL**: When updating Sequelize models in backend services, always convert snake_case API data to camelCase model properties manually

### Error Handling

- All API responses use `{ success, message, data }` format
- Custom error classes for different error types
- Comprehensive error middleware for consistent responses

### Database Migrations

- Idempotent migrations with existence checks
- Transaction-based approach for schema changes
- View dependency handling with `ViewManager` utility
- Function signature: `async up(queryInterface, Sequelize)`

### Work Types System

Phase B implementation includes:
- Cost tracking with historical data
- Material requirements mapping
- Safety tags and requirements
- Vector similarity search
- Frontend management UI with tabbed interface

### Memory Bank

The `/memory-bank/` directory contains important context:
- `activeContext.md`: Current work focus and recent changes
- `techContext.md`: Technical stack and patterns
- `productContext.md`: Product goals and user experience
- `systemPatterns.md`: Detailed implementation patterns
- Component guidelines and standardization approaches

## Key Considerations

1. **Docker Development**: Multi-stage builds separate dev and prod concerns
2. **Vector Dimensions**: pgvector indexes limited to 2000 dimensions
3. **API Boundaries**: Always use standardized services for API calls
4. **PDF Generation**: Robust error handling with fallbacks for undefined values
5. **Background Jobs**: Use BullMQ workers for long-running operations
6. **Settings Management**: Database-first with environment variable fallbacks
7. **View Dependencies**: Check before altering database columns
8. **Work Type Detection**: Multiple confidence thresholds (0.35/0.60) for suggestions

## Current Issues and Recent Findings

### Payment Field Mapping Issue (2025-07-17) - RESOLVED

**Issue**: When editing payments in invoice editing, payment method changes weren't saving. Frontend showed correct data being sent, backend received correct data, but Sequelize wasn't updating the fields.

**Root Cause**: Case conversion mismatch between API service and Sequelize models:
1. Frontend sends camelCase: `{ paymentMethod: "check" }`
2. API service auto-converts to snake_case: `{ payment_method: "check" }`
3. Backend services were passing snake_case directly to Sequelize
4. Sequelize models expect camelCase property names, not snake_case database field names
5. Payment model defines: `paymentMethod: { field: 'payment_method' }` - so model property is camelCase

**Solution**: In backend services (invoiceService.js), manually convert snake_case API data to camelCase before calling Sequelize methods:

```javascript
// Convert snake_case keys to camelCase for Sequelize model
const updateData = {};
if (paymentData.amount !== undefined) updateData.amount = paymentData.amount;
if (paymentData.payment_date !== undefined) updateData.paymentDate = paymentData.payment_date;
if (paymentData.payment_method !== undefined) updateData.paymentMethod = paymentData.payment_method;
if (paymentData.notes !== undefined) updateData.notes = paymentData.notes;
if (paymentData.reference_number !== undefined) updateData.referenceNumber = paymentData.reference_number;

await payment.update(updateData);
```

**Prevention**: Always check field mapping when implementing CRUD operations with Sequelize models. When backend services receive snake_case data from API service, convert to camelCase before passing to Sequelize.

### Invoice Payment System (2025-01-17)

**Issue**: When recording payments in the invoice section, the payment amount doesn't appear to be deducted from the owed amount when viewing the invoice. This should also reflect when generating PDF invoices.

**Analysis Findings**:
- **Database Schema**: Properly structured with foreign key relationships
  - `invoices` table: Contains `total`, `subtotal`, `tax_total`, `discount_amount` fields
  - `payments` table: Links to invoices via `invoice_id` with `amount`, `payment_date`, `payment_method`
- **Backend Implementation**: Fully functional payment processing
  - Payment recording via `POST /api/invoices/:id/payments` (invoices.controller.js:216)
  - `invoiceService.addPayment()` creates payment and recalculates totals (invoiceService.js:533)
  - `calculateInvoiceTotals()` computes balance and updates invoice status (invoiceService.js:392)
  - Status automatically changes to 'paid' when `totalPaid >= total` (invoiceService.js:468)
- **Frontend Implementation**: Payment UI exists but may have display issues
  - Payment modal in InvoiceDetail.vue (lines 349-455)
  - Payment history table displays recorded payments (lines 305-345)
  - Payment form submits to backend correctly (submitPayment function)
- **PDF Generation**: Template includes payment calculations
  - Shows "Total Paid" and "Balance Due" sections (invoice.ejs:357-370)
  - Calculates balance as `data.total - totalPaid`
  - Displays payment history table if payments exist (lines 374-397)

**Root Cause**: The payment system appears to be fully implemented. The issue is likely in:
1. Frontend display logic not showing updated balance after payment
2. Invoice totals section not reflecting payments in real-time
3. Potential caching issues or state management problems

**Next Steps**: 
1. Test actual payment recording to verify backend calculations
2. Check if frontend state updates correctly after payment submission
3. Verify PDF generation reflects payments accurately
4. Investigate any caching issues in invoice display

## Development Workflow Reminders

- **Docker Restart Reminder**: Always restart backend/frontend using docker after changes need to be tested