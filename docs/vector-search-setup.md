# Vector Search and Catalog Matching Setup

This document describes how to set up and use the vector search and catalog matching functionality in the Construction Management application.

## Overview

Vector search enables semantic matching of product names, which significantly improves the accuracy of catalog deduplication. This feature combines:

1. **Trigram Matching** (pg_trgm): For text similarity based on character patterns
2. **Vector Similarity** (pgvector): For semantic similarity based on meaning

Together, these methods provide a robust approach to finding similar products and preventing duplicates in your catalog.

## Prerequisites

- Docker environment for the application
- PostgreSQL database with admin access
- DeepSeek API key (already configured in your environment)

## Installation Steps

Follow these steps to set up vector search:

1. **Add Environment Variables**

   Add the following to your `.env` file:

   ```
   # Embedding model to use with DeepSeek
   EMBEDDING_MODEL=embedding-2

   # Feature flag for enabling the v2 estimate wizard
   VITE_USE_ESTIMATE_V2=true
   ```

   Note: The DEEPSEEK_API_KEY is already configured in your environment.

2. **Run the Setup Script**

   Execute the provided setup script:

   ```bash
   ./run-vector-setup.sh
   ```

   This script will:
   - Install the pgvector extension in your PostgreSQL database
   - Run the migration to add the embedding column to the products table
   - Generate embeddings for existing products using the DeepSeek API

3. **Restart the Application**

   Restart both frontend and backend services:

   ```bash
   ./docker-services.sh restart all
   ```

## How It Works

When the system is set up:

1. **During Estimate Generation**:
   - Generated line items are checked against the catalog
   - Both trigram and vector similarity are used to find matches
   - Items are categorized by confidence level:
     - High confidence (>85%): Automatic matching
     - Medium confidence (60-85%): User decides
     - Low confidence (<60%): Added as new product

2. **Adding New Products**:
   - When new products are added to the catalog, embeddings are automatically generated via DeepSeek
   - No manual action is required for new products

3. **Confidence Levels**:
   - High confidence (green): Automatically linked to existing product
   - Medium confidence (yellow): Interactive user decision required
   - Low confidence (blue): Added as new product

## DeepSeek Integration

The system uses your existing DeepSeek API integration for generating embeddings:

- It leverages DeepSeek's OpenAI-compatible API interface
- The same API key (DEEPSEEK_API_KEY) you already use for chat completions is used for embeddings
- The embedding model defaults to "embedding-2" but can be customized via EMBEDDING_MODEL

## Troubleshooting

If you encounter issues:

1. **Check Extension Installation**:
   ```sql
   SELECT * FROM pg_extension WHERE extname = 'vector';
   ```

2. **Verify Embedding Column**:
   ```sql
   SELECT column_name FROM information_schema.columns 
   WHERE table_name = 'products' AND column_name = 'embedding';
   ```

3. **Check DeepSeek API Connectivity**:
   - Ensure your existing DEEPSEEK_API_KEY is valid
   - DeepSeek must support the embedding model you've specified
   - Check backend logs for any API errors

4. **Regenerate Embeddings**:
   If needed, you can regenerate all embeddings by running:
   ```bash
   ./run-backfill.sh
   ```

## Monitoring

You can monitor the embedding status with:

```sql
SELECT 
  COUNT(*) as total_products,
  COUNT(embedding) as products_with_embeddings,
  COUNT(*) - COUNT(embedding) as products_without_embeddings
FROM products WHERE deleted_at IS NULL;
```

## Feature Flag

The AI Wizard (v2) tab will appear in the estimate generation interface when:
- The `VITE_USE_ESTIMATE_V2` environment variable is set to `true`
- The application is properly configured with vector search capabilities
