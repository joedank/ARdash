# Work Types Knowledge Base

This module implements a comprehensive knowledge base of mobile-home repair tasks with standardized measurement types and units. It's designed to help the AI Wizard v2 generate more accurate and consistent estimates.

## Overview

The work types knowledge base consists of:

1. A PostgreSQL database table (`work_types`) that stores structured task data
2. Backend API endpoints for managing and querying work types
3. A frontend interface for browsing, filtering, and managing work types
4. Similarity search functionality to find related work types and prevent duplicates

## Features

- **Structured Taxonomy**: Work types are organized into five parent buckets (Interior-Structural, Interior-Finish, Exterior-Structural, Exterior-Finish, Mechanical)
- **Standardized Measurements**: Each work type has a defined measurement type (area, linear, quantity) and suggested units
- **Similarity Matching**: Built-in trigram and vector similarity search to prevent duplicates
- **Responsive UI**: Full-featured interface for managing work types
- **AI Integration**: Ready for use with the AI Wizard v2 for estimate generation

## Setup Instructions

### 1. Run Database Migration

The database migration will create the `work_types` table with appropriate indexes:

```bash
# From the project root
./setup-work-types-db.sh
```

This script will:
- Run the database migration to create the work_types table
- Import the initial 80 work types from the CSV file
- Merge the Vue component parts into a single file

### 2. Integrate Routes

Add the work types routes to your main router configuration:

```javascript
// In src/router/index.js

// Import work types routes
import workTypesRoutes from './work-types-routes';

// Add to routes array
const routes = [
  // Other routes...
  ...workTypesRoutes
];
```

### 3. Add Navigation Link

Add a link to work types in your main navigation:

```html
<li>
  <router-link 
    to="/work-types" 
    class="nav-link"
    active-class="active"
  >
    Work Types
  </router-link>
</li>
```

## Using the Work Types Knowledge Base

### In the UI

The work types interface allows you to:

1. **Browse Work Types**: View all work types in a sortable, filterable table
2. **Filter by Category**: Filter by parent bucket or measurement type
3. **Search**: Quickly find work types by name
4. **Add New Work Types**: Create new work types with standardized measurement types
5. **Edit Work Types**: Modify existing work types to maintain knowledge base accuracy
6. **Delete Work Types**: Remove outdated or incorrect work types

### In the AI Wizard

The work types knowledge base can be integrated with the AI Wizard v2 to:

1. **Standardize Estimate Line Items**: Map generated line items to standard work types
2. **Suggest Appropriate Measurements**: Automatically determine if a task requires area, linear, or quantity measurements
3. **Provide Default Units**: Use standardized units for each work type
4. **Prevent Duplicates**: Ensure consistency by matching similar work descriptions to canonical work types

## API Endpoints

- `GET /api/work-types` - Get all work types with optional filtering
- `GET /api/work-types/:id` - Get a specific work type by ID
- `POST /api/work-types` - Create a new work type
- `PUT /api/work-types/:id` - Update an existing work type
- `DELETE /api/work-types/:id` - Delete a work type
- `GET /api/work-types/similar` - Find work types similar to a provided name

## Advanced Usage

### Similarity Search

The work types knowledge base implements similarity matching using PostgreSQL's trigram extension (pg_trgm). To find similar work types:

```javascript
// Frontend example
const result = await workTypesService.findSimilarWorkTypes('Bathroom Vanity', 0.3);
// Returns similar work types with a similarity score above 0.3
```

### Vector Similarity (Phase B)

In the next phase, we'll implement vector similarity with the pgvector extension, which will provide semantic matching capabilities beyond text similarity. This will help identify conceptually similar work types even when the terminology differs.

## Troubleshooting

### Common Issues

1. **Database Migration Fails**: Ensure PostgreSQL has the pg_trgm extension enabled
2. **Component Not Found**: Make sure the Vue component is properly merged and registered
3. **Route Not Found**: Verify the routes are correctly integrated in the main router
4. **Similarity Search Not Working**: Check that the pg_trgm extension is properly installed

### Logs

- Check backend logs with `docker logs management-backend-1`
- Check frontend logs in the browser console
- Check database logs with `docker logs management-db-1`

## Next Steps (Phase B)

The next phase of development will focus on:

1. **Typical Unit Cost**: Adding material and labor cost per unit
2. **Default Productivity Rate**: Adding crew hours per unit
3. **Default Materials List**: Linking to product catalog SKUs
4. **Safety / Permit Tags**: Adding safety requirements and permit needs
5. **Example Measurement Prompts**: Adding standardized measurement instructions

## Contributing

When adding new work types, please follow these guidelines:

1. Use clear, specific names
2. Assign the appropriate parent bucket
3. Set the correct measurement type and units
4. Check for similar existing work types first
5. Use sentence case for work type names
6. Include details in parentheses when needed (e.g., "Deck Construction (8×16)")

Happy estimating!
