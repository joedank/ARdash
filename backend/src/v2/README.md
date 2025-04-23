# Smart Estimation System V2

This directory contains the implementation of the new smart conversation-based estimation system with catalog deduplication.

## Overview

The V2 estimation system provides:

1. **A smarter conversation with the AI**
   - First, the AI quickly reads inspection notes and identifies only what's missing (measurements or details)
   - After gaps are filled, the AI writes the full list of repair items with prices

2. **Catalog deduplication**
   - New line items are compared to existing products in the database
   - High similarity matches (> 0.85) automatically link to existing products
   - Medium similarity matches (0.6 - 0.85) show a "possible duplicates" list for user decision
   - Truly new items are added to the catalog

## Components

### PromptEngine.js

A specialized prompt builder and parser for the estimation workflow:

- `buildScope(assessment)` - Creates a prompt to identify missing information
- `buildDraft(scopedAssessment, opts)` - Creates a prompt to generate line items
- `parseScope(text)` - Parses the scope analysis response with Zod validation
- `parseDraft(text)` - Parses the line items response with Zod validation

### CatalogService.js

Handles catalog integration with similarity matching:

- `findByTrgm(name)` - Uses PostgreSQL's pg_trgm extension for fuzzy text matching
- `findByVector(embed)` - Uses pgvector for semantic similarity (optional)
- `upsertOrMatch(draftItem, options)` - Creates new products or finds matches with confidence scoring
- Fallback implementation for environments without pg_trgm

### estimate.controller.v2.js

Orchestrates the estimation workflow:

1. **Phase 1:** Scope analysis to identify missing information
2. **Phase 2:** Request clarifications from the user if needed
3. **Phase 3:** Generate draft line items
4. **Phase 4:** Perform catalog matching with duplicate detection

## API Endpoint

```
POST /api/estimates/v2/generate
```

### Request Body

```json
{
  "assessment": "Detailed inspection notes...",
  "options": {
    "temperature": 0.5,
    "hardThreshold": 0.85,
    "softThreshold": 0.60
  }
}
```

### Response Format

#### Clarification Needed

```json
{
  "success": true,
  "message": "Additional information needed for estimate generation",
  "data": {
    "phase": "clarify",
    "requiredMeasurements": ["kitchen floor area", "cabinet linear feet"],
    "questions": ["What type of flooring is desired?"]
  }
}
```

#### Completed Estimate

```json
{
  "success": true,
  "message": "Estimate generation complete",
  "data": {
    "phase": "done",
    "items": [
      {
        "name": "Kitchen Floor Replacement",
        "measurementType": "AREA",
        "quantity": 120,
        "unitPrice": 8.5,
        "catalogStatus": "match",
        "productId": "550e8400-e29b-41d4-a716-446655440000",
        "score": 0.92,
        "matchedName": "Kitchen Floor Replacement"
      },
      {
        "name": "Cabinet Installation",
        "measurementType": "LINEAR",
        "quantity": 24,
        "unitPrice": 120,
        "catalogStatus": "review",
        "matches": [
          {
            "id": "550e8400-e29b-41d4-a716-446655440001",
            "name": "Cabinet Installation (Base)",
            "score": 0.75
          },
          {
            "id": "550e8400-e29b-41d4-a716-446655440002",
            "name": "Cabinet Installation (Wall)",
            "score": 0.72
          }
        ]
      },
      {
        "name": "Pendant Light Installation",
        "measurementType": "QUANTITY",
        "quantity": 3,
        "unitPrice": 85,
        "catalogStatus": "created",
        "productId": "550e8400-e29b-41d4-a716-446655440003"
      }
    ]
  }
}
```

## Database Extensions

### pg_trgm

This implementation uses PostgreSQL's pg_trgm extension for efficient fuzzy text matching. To enable:

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

### pgvector (Optional)

For enhanced semantic similarity matching, the optional pgvector extension can be used:

```sql
CREATE EXTENSION IF NOT EXISTS vector;

-- Add vector column to products table
ALTER TABLE products ADD COLUMN IF NOT EXISTS name_vec vector(384);
```

## Frontend Integration

The frontend should handle:

1. Initial assessment submission
2. Displaying and collecting answers to clarification questions
3. Showing catalog match information with confidence scores
4. Letting users choose between matches for medium-confidence matches
5. Final estimate creation with selected/approved items