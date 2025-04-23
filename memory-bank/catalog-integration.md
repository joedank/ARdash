# Catalog Integration Documentation

## Overview

The catalog integration feature allows for efficient management of line items in estimates by leveraging the existing product catalog. This documentation covers the implementation details of catalog similarity checking, matching, and standardization features.

## Key Features

### 1. Catalog Similarity Checking

The system can identify potential duplicate or similar items between LLM-generated line items and existing catalog entries.

- **Backend Endpoint**: `POST /api/estimates/llm/similarity-check`
- **Frontend Service**: `catalogMatcherService.checkSimilarity(descriptions)`
- **Implementation Details**:
  - Uses string similarity algorithm to compare descriptions with catalog products
  - Returns top 3 matches for each description with similarity scores
  - Filters results to include only reasonable matches (similarity > 0.3)
  - Sorts matches by similarity score (highest first)

### 2. Catalog-Eligible Items Identification

Identifies which items in a set of descriptions are eligible for automatic replacement with catalog items.

- **Backend Endpoint**: `POST /api/estimates/llm/catalog-eligible`
- **Frontend Service**: `catalogMatcherService.getCatalogEligibleItems(descriptions, threshold)`
- **Implementation Details**:
  - Accepts an optional similarity threshold (default: 0.7)
  - Only returns items that exceed the threshold
  - For each description, finds the best matching catalog product
  - Returns eligible items with their product details and similarity scores

### 3. Batch Catalog Operations

The UI supports various batch operations for managing line items and their relationship to the catalog.

#### Add to Catalog

- Allows adding multiple selected items to the catalog at once
- Checks for similar items before adding to prevent duplicates
- Converts line items to product format before saving

#### Replace with Catalog Items

- Replaces selected line items with their catalog counterparts
- Preserves quantities from original items
- Updates prices and units to match catalog standards
- Sets appropriate source metadata (sourceType, sourceId, etc.)

#### Standardize Pricing

- Groups selected items by unit type
- For each unit group, identifies the most common price or calculates an average
- Updates all items in the group to use the standardized price
- Recalculates totals based on new price and existing quantities

## UI Implementation

### Item Selection and Visual Indicators

- Items can be selected by clicking on them in the items list
- Selected items are highlighted with a blue background
- Catalog matches are indicated with a warning icon and similarity percentage
- Modal dialogs show details before performing actions

### CatalogActions Component

Provides a panel of actions that can be performed on selected items:

```html
<CatalogActions
  :items="items"
  :selected-item-indices="selectedItemIndices"
  @update:selected-item-indices="updateSelectedIndices"
  @update:items="updateItems"
/>
```

### ItemsList Component

Displays line items with catalog match indicators and allows selection:

```html
<ItemsList
  :items="items"
  :catalog-matches="catalogMatches"
  @update:items="updateItems"
  @update:selected-indices="updateSelectedIndices"
  @highlight-source="highlightSource"
/>
```

## API Endpoints

### Check Similarity

```
POST /api/estimates/llm/similarity-check
Body: {
  "descriptions": ["Description 1", "Description 2", ...]
}
Response: {
  "success": true,
  "data": [
    {
      "description": "Description 1",
      "matches": [
        {
          "id": "uuid",
          "name": "Catalog Item Name",
          "description": "Catalog Item Description",
          "price": 100.00,
          "unit": "sq ft",
          "similarity": 0.85
        },
        ...
      ]
    },
    ...
  ],
  "message": "Similarity check completed successfully"
}
```

### Get Catalog Eligible Items

```
POST /api/estimates/llm/catalog-eligible
Body: {
  "descriptions": ["Description 1", "Description 2", ...],
  "threshold": 0.7
}
Response: {
  "success": true,
  "data": [
    {
      "description": "Description 1",
      "product": {
        "id": "uuid",
        "name": "Catalog Item Name",
        "description": "Catalog Item Description",
        "price": 100.00,
        "unit": "sq ft"
      },
      "similarity": 0.85
    },
    ...
  ],
  "message": "Catalog eligibility check completed successfully"
}
```

## Integration with Estimate Generation

The catalog integration features are available in both estimate generation modes:

1. **Built-in AI Mode**:
   - After LLM generates line items, they are automatically checked against the catalog
   - Similarity indicators appear in the items list
   - Users can perform batch operations before finalizing the estimate

2. **External Paste Mode**:
   - After parsing the pasted content, items are checked against the catalog
   - Same UI for batch operations is available

## Future Enhancements

1. **Improved Similarity Algorithm**:
   - Semantic-based similarity comparison
   - Category-aware matching for better accuracy
   - Machine learning integration to improve over time

2. **Automated Batch Replacement**:
   - Option to automatically replace all items above a certain similarity threshold
   - Preview mode to show differences before applying

3. **Pricing Intelligence**:
   - Analyze historical pricing data to suggest optimal prices
   - Consider project context and client information in pricing decisions

4. **Catalog Cleanup Utilities**:
   - Identify and merge duplicate catalog items
   - Archive or remove unused catalog items

## Implementation Notes

The similarity checking functionality depends on the `string-similarity` package for calculating similarity scores. The implementation uses the Dice coefficient algorithm which provides good results for comparing short descriptions.

For optimal performance, avoid checking too many descriptions at once against a large catalog. The current implementation is optimized for batch sizes up to about 50 items.
