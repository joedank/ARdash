# Smart AI Conversation & Catalog Deduplication

## Overview

This implementation adds a smarter conversation workflow with the AI and an intelligent catalog deduplication system to prevent duplicates in the product database.

## Key Features

### 1. Smarter Conversation with the AI

- **First Pass**: The AI quickly reads inspection notes and tells you *only* what's missing (measurements or details).
- **Second Pass**: After filling the gaps, the AI writes the full list of repair items with prices.
- **Contextual Understanding**: The system understands what information is already available and only asks for what's truly missing.

### 2. Catalog Deduplication

- **Intelligent Matching**: Each new line item the AI suggests is compared to what's already in your products table.
- **Tiered Confidence Levels**:
  - **High Confidence Match** (>85%): Automatically links to existing product
  - **Medium Confidence Match** (60-85%): Shows "possible duplicates" pop-up for user decision
  - **Low Confidence Match** (<60%): Adds as a new product to the catalog
- **Database-Level Similarity**: Uses PostgreSQL extensions for efficient similarity checking:
  - **pg_trgm**: For letter triplet matching (catches typos and wording tweaks)
  - **pgvector**: Optional semantic vector matching (catches synonyms and related concepts)

### 3. System Architecture

- **PromptEngine**: Specialized prompt builder and parser for two-phase estimation
- **CatalogService**: Handles similarity matching and product management
- **V2 Controller**: Orchestrates the conversation and catalog integration workflow

## Technical Changes

### New Files Added

1. `/backend/src/v2/PromptEngine.js` - Handles AI prompt generation and parsing
2. `/backend/src/v2/CatalogService.js` - Manages catalog integration with similarity matching
3. `/backend/src/v2/estimate.controller.v2.js` - V2 controller for the smart conversation workflow
4. `/backend/src/migrations/20250417000000-add-vector-column-to-products.js` - Migration to add vector support
5. `/backend/src/utils/vectorize-products.js` - Utility to generate vector embeddings for products

### Routes Added

- `POST /api/estimates/v2/generate` - The new endpoint for the smart conversation and catalog integration

### Database Enhancements

- Added support for PostgreSQL's `pg_trgm` extension for fuzzy text matching
- Optional support for `pgvector` extension for semantic similarity matching
- Added GIN index on product names for faster similarity searches

## Usage Instructions

### API Endpoint

```
POST /api/estimates/v2/generate
```

### Request Format

```json
{
  "assessment": "Detail inspection notes here...",
  "options": {
    "temperature": 0.5,
    "hardThreshold": 0.85,
    "softThreshold": 0.60
  }
}
```

### Response Format - Clarification Needed

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

### Response Format - Completed Estimate

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

## Frontend Integration Guide

The frontend should handle:

1. **Initial Assessment Submission**:
   - Send the assessment text to `/api/estimates/v2/generate`
   - Handle the response based on the phase

2. **Clarification Phase**:
   - Display required measurements and questions to the user
   - Collect answers and updated assessment information
   - Send the updated assessment back to `/api/estimates/v2/generate`

3. **Catalog Integration Phase**:
   - Display generated line items with their catalog status
   - For "match" items, show the matched product name
   - For "review" items, show a selection UI with possible matches
   - For "created" items, indicate that a new product was added

4. **Final Estimate Creation**:
   - Once all items are reviewed, allow the user to create the estimate
   - Send chosen products and any modifications to the standard estimate creation endpoint

## Setting Up PostgreSQL Extensions

### pg_trgm Setup (Required)

```sql
-- Run as PostgreSQL superuser
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create index for faster similarity searches
CREATE INDEX idx_products_name_gin ON products USING GIN (name gin_trgm_ops);
```

### pgvector Setup (Optional)

```sql
-- Run as PostgreSQL superuser
CREATE EXTENSION IF NOT EXISTS vector;

-- Add vector column to products table
ALTER TABLE products ADD COLUMN name_vec vector(384);

-- Generate embeddings for existing products
node backend/src/utils/vectorize-products.js
```

## Implementation Details

### Similarity Matching Process

1. **Text Similarity with pg_trgm**:
   - Compares trigrams (3-letter sequences) between strings
   - Effective for catching typos, word order changes, and slight variations
   - Fast and efficient directly in SQL

2. **Semantic Similarity with pgvector** (optional):
   - Uses vector embeddings to capture meaning
   - Better at catching synonyms and conceptual similarity
   - Requires additional setup and API calls to generate embeddings

3. **Fallback Mechanism**:
   - If PostgreSQL extensions aren't available, falls back to JavaScript-based similarity
   - Ensures the system works even without the specialized extensions

### Conversation Flow

1. **Initial Analysis**:
   - AI analyzes assessment text to identify missing information
   - Uses a specialized prompt focused on identifying gaps

2. **Clarification Request**:
   - If missing information is detected, system returns required measurements and questions
   - Frontend collects this information from the user

3. **Line Item Generation**:
   - Once all necessary information is available, AI generates line items
   - System parses and validates the response

4. **Catalog Integration**:
   - Each line item is compared against the product catalog
   - Similarity matching determines if it's a duplicate or a new product

5. **Final Review**:
   - User reviews the generated items and catalog matches
   - Makes final decisions on medium-confidence matches

## Next Steps & Future Enhancements

1. **Embedding Update Automation**:
   - Set up a process to automatically update vector embeddings when products are added/modified

2. **Enhanced Vector Similarity**:
   - Implement more advanced vector operations for better semantic matching
   - Consider using more specialized embeddings for construction terminology

3. **Feedback Loop**:
   - Track user decisions for medium-confidence matches to improve future matching
   - Use this data to adjust similarity thresholds over time

4. **Multi-Modal Integration**:
   - Incorporate image data from assessment photos for more context
   - Consider OCR for measurements written on photos

5. **Progressive Learning**:
   - Have the system learn from previously generated estimates
   - Improve prompt quality based on successful outcomes