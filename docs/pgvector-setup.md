# pgvector Setup Guide

This document explains how to set up and use pgvector for vector similarity search in the Construction Management application.

## Overview

pgvector is a PostgreSQL extension that adds support for vector similarity search. It allows us to store embeddings as vectors and perform efficient similarity searches using cosine distance, Euclidean distance, or inner product.

In our application, we use pgvector for:

1. Finding similar work types based on semantic meaning
2. Enhancing the trigram-based similarity search with vector-based semantic search
3. Improving the accuracy of work type detection in assessment data

## Setup Options

There are two ways to set up pgvector:

### Option 1: Automatic Setup with Docker (Recommended)

The Docker setup automatically installs pgvector when the database container starts:

1. The `02-install-pgvector.sh` script in `database/init/` installs the pgvector extension
2. The migration `20250530000000-add-pgvector-support.js` adds the vector column and index
3. Set `ENABLE_VECTOR_SIMILARITY=true` in the backend environment variables

To use this option:

```bash
# Start the Docker containers
docker-compose up -d

# Run migrations to set up the vector column and index
docker-compose exec backend npx sequelize-cli db:migrate

# Generate embeddings for existing work types
docker-compose exec backend node scripts/generate-work-type-embeddings.js
```

### Option 2: Manual Setup

If you're not using Docker or need to set up pgvector manually:

1. Install pgvector in your PostgreSQL database:

```bash
# Install build dependencies
sudo apt-get install postgresql-server-dev-14 # Adjust version as needed
git clone --branch v0.5.1 https://github.com/pgvector/pgvector.git
cd pgvector
make
sudo make install

# Create the extension in your database
psql -U postgres -d management_db -c "CREATE EXTENSION vector;"
```

2. Run the migration to set up the vector column and index:

```bash
npx sequelize-cli db:migrate
```

3. Set `ENABLE_VECTOR_SIMILARITY=true` in your `.env` file

4. Generate embeddings for existing work types:

```bash
node scripts/generate-work-type-embeddings.js
```

## Disabling Vector Similarity

If you need to disable vector similarity:

1. Set `ENABLE_VECTOR_SIMILARITY=false` in your environment variables
2. The application will automatically fall back to using trigram similarity only

## Troubleshooting

### Error: "DataTypes.VECTOR is not a function"

This error occurs when the custom data types utility is not properly loaded. Make sure:

1. The `sequelize-datatypes.js` file exists in `backend/src/utils/`
2. The WorkType model is importing the custom data types correctly
3. The models are being loaded in the correct order

### Error: "operator does not exist: text <=> vector"

This error occurs when trying to use vector operations on a TEXT column. Make sure:

1. The pgvector extension is installed in your database
2. The migration has run successfully to convert the column to vector type
3. `ENABLE_VECTOR_SIMILARITY=true` is set in your environment

### Error: "could not access file '$libdir/vector'"

This error occurs when the pgvector extension is not properly installed. Make sure:

1. You've installed pgvector correctly for your PostgreSQL version
2. You've created the extension in your database with `CREATE EXTENSION vector;`

## Testing Vector Similarity

To test if vector similarity is working:

```sql
-- Check if the pgvector extension is installed
SELECT * FROM pg_extension WHERE extname = 'vector';

-- Check if the name_vec column is vector type
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'work_types' AND column_name = 'name_vec';

-- Test a simple vector similarity query
SELECT id, name, 1-(name_vec <=> '[0.1, 0.2, 0.3, ...]'::vector) AS similarity
FROM work_types
WHERE name_vec IS NOT NULL
ORDER BY name_vec <=> '[0.1, 0.2, 0.3, ...]'::vector
LIMIT 5;
```

## Performance Considerations

- Vector similarity search is more computationally expensive than trigram similarity
- The application uses a hybrid approach, using trigram similarity first and only using vector similarity when needed
- The `ivfflat` index improves performance for large datasets but may be less accurate for small datasets
- Consider monitoring query performance and adjusting the index type if needed
