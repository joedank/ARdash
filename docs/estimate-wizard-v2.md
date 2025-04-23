# Estimate Wizard V2: Smart AI Conversation & Catalog Deduplication

## Overview

The Estimate Wizard V2 is a new approach to generating estimates that features:

1. A smarter conversation with the AI that:
   - First analyzes inspection notes to identify only what information is missing
   - Then generates a complete list of repair items with prices after the user fills in the gaps

2. Intelligent catalog deduplication that:
   - Compares new items with existing products in the database
   - Automatically links high-confidence matches to existing products
   - Suggests possible matches for medium-confidence cases
   - Creates new products only when necessary

## Technical Implementation

### Backend Components

- **PromptEngine.js**: Handles AI prompt creation and response parsing with Zod validation
- **CatalogService.js**: Performs similarity matching using PostgreSQL extensions
- **estimate.controller.v2.js**: Orchestrates the conversation and catalog integration workflow

### Frontend Components

- **EstimateWizard.vue**: Main container for the wizard workflow
- **StartForm.vue**: Initial form for assessment input
- **ClarifyForm.vue**: Form for providing missing information
- **ItemsReview.vue**: Interface for reviewing generated items and handling catalog matches

### Database Extensions

- **pg_trgm**: PostgreSQL extension for trigram-based text similarity (for typos and wording variations)
- **pgvector** (optional): PostgreSQL extension for vector similarity (for synonyms and related concepts)

## Setup Instructions

### 1. Enable Feature Flag

To enable the new Estimate Wizard V2, set the following environment variable:

```
VITE_USE_ESTIMATE_V2=true
```

This can be done in `.env.development` for development or `.env.production` for production.

### 2. Install PostgreSQL Extensions

First, connect to your PostgreSQL database:

```bash
docker exec -it management-db-1 psql -U postgres -d management_db
```

Then, install the required extensions:

```sql
-- Required: pg_trgm for text similarity
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Optional: pgvector for semantic similarity
CREATE EXTENSION IF NOT EXISTS vector;
```

### 3. Run Database Migration

Run the migration to add the vector column to the products table:

```bash
npm run migrate
```

### 4. Generate Vector Embeddings (Optional)

If you're using pgvector for semantic similarity, generate embeddings for existing products:

```bash
npm run embed:backfill
```

## Usage Guide

### 1. Accessing the Wizard

1. Navigate to the Estimate Generator
2. Click on the "AI Wizard (v2)" tab

### 2. Step 1: Initial Assessment

1. Enter your inspection notes in the provided text area
2. Optionally, adjust advanced settings:
   - Temperature: Controls creativity (lower for more consistent results)
   - Similarity thresholds: Sets when items are automatically matched or need review
3. Click "Generate Estimate"

### 3. Step 2: Clarifications (if needed)

If the AI detects missing information:

1. Fill in the required measurements
2. Answer any additional questions about the project
3. Click "Continue"

### 4. Step 3: Review Generated Items

1. Review the list of generated repair items with their prices
2. For items marked "Needs Review", click "Review Matches" to see possible matches
3. Choose the best match or keep as a new item
4. When satisfied, click "Create Estimate"

## Similarity Matching Explained

The system uses two complementary approaches for matching:

1. **Trigram Matching (pg_trgm)**:
   - Compares 3-letter sequences between strings
   - Effective for catching typos, rewording, and minor variations
   - Example: "Install baseboards" and "Baseboard installation" would match

2. **Vector Similarity (pgvector)** (optional):
   - Uses AI embeddings to capture meaning
   - Effective for catching synonyms and conceptually similar items
   - Example: "Replace flooring" and "Install new floor" would match

## Confidence Thresholds

- **High Confidence (>0.85)**: Automatically linked to existing product
- **Medium Confidence (0.60-0.85)**: Shows "Needs Review" for user decision  
- **Low Confidence (<0.60)**: Creates new product

These thresholds can be adjusted in the advanced settings.

## Customization

### Adjusting Thresholds

To change the default similarity thresholds, modify:
- Frontend: `StartForm.vue` component's `options` ref
- Backend: `CatalogService.js` upsertOrMatch method parameters

### Modifying Prompts

To change the AI prompts and instructions, modify the `PromptEngine.js` file in the backend.

## Troubleshooting

### Common Issues

1. **AI not detecting missing measurements**: Make sure your assessment text is detailed enough but clearly indicates what measurements are still needed.

2. **Too many/few catalog matches**: Adjust the similarity thresholds in the advanced settings. Lower them if you want more matches, raise them for stricter matching.

3. **Vector search not working**: Ensure pgvector extension is installed and the embedding backfill process has been run.
