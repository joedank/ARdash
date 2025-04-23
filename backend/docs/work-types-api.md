# Work Types API Documentation

This document describes the Work Types API endpoints, including the Phase B enhancements for cost, material, and safety data.

## Base URL

All API endpoints are relative to `/api/work-types`.

## Authentication

All endpoints require authentication. Include a valid JWT token in the `Authorization` header:

```
Authorization: Bearer <token>
```

## Common Response Format

All responses follow this standard format:

```json
{
  "success": true|false,
  "data": <response data>,
  "message": "Optional message"
}
```

## Error Handling

Errors return with `success: false` and an error message:

```json
{
  "success": false,
  "message": "Error message"
}
```

## Endpoints

### Get All Work Types

```
GET /api/work-types
```

**Query Parameters:**
- `parent_bucket` (string, optional): Filter by parent bucket
- `measurement_type` (string, optional): Filter by measurement type (area, linear, quantity)
- `include_materials` (boolean, optional): Include materials in response
- `include_tags` (boolean, optional): Include tags in response

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Work Type Name",
      "parent_bucket": "parent-bucket",
      "measurement_type": "area|linear|quantity",
      "suggested_units": "sq ft",
      "unit_cost_material": 10.50,
      "unit_cost_labor": 25.75,
      "productivity_unit_per_hr": 5.5,
      "revision": 1,
      "materials": [...],  // If include_materials=true
      "tags": [...]        // If include_tags=true
    },
    ...
  ]
}
```

### Get Work Type by ID

```
GET /api/work-types/:id
```

**Query Parameters:**
- `include_materials` (boolean, optional): Include materials in response
- `include_tags` (boolean, optional): Include tags in response
- `include_cost_history` (boolean, optional): Include cost history in response

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Work Type Name",
    "parent_bucket": "parent-bucket",
    "measurement_type": "area|linear|quantity",
    "suggested_units": "sq ft",
    "unit_cost_material": 10.50,
    "unit_cost_labor": 25.75,
    "productivity_unit_per_hr": 5.5,
    "revision": 1,
    "materials": [...],      // If include_materials=true
    "tags": [...],           // If include_tags=true
    "costHistory": [...]     // If include_cost_history=true
  }
}
```

### Create Work Type

```
POST /api/work-types
```

**Request Body:**
```json
{
  "name": "Work Type Name",
  "parent_bucket": "parent-bucket",
  "measurement_type": "area|linear|quantity",
  "suggested_units": "sq ft",
  "unit_cost_material": 10.50,
  "unit_cost_labor": 25.75,
  "productivity_unit_per_hr": 5.5
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Work Type Name",
    "parent_bucket": "parent-bucket",
    "measurement_type": "area|linear|quantity",
    "suggested_units": "sq ft",
    "unit_cost_material": 10.50,
    "unit_cost_labor": 25.75,
    "productivity_unit_per_hr": 5.5,
    "revision": 1
  },
  "message": "Work type created successfully"
}
```

### Update Work Type

```
PUT /api/work-types/:id
```

**Request Body:**
```json
{
  "name": "Updated Work Type Name",
  "parent_bucket": "parent-bucket",
  "measurement_type": "area|linear|quantity",
  "suggested_units": "sq ft"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Updated Work Type Name",
    "parent_bucket": "parent-bucket",
    "measurement_type": "area|linear|quantity",
    "suggested_units": "sq ft",
    "unit_cost_material": 10.50,
    "unit_cost_labor": 25.75,
    "productivity_unit_per_hr": 5.5,
    "revision": 2
  },
  "message": "Work type updated successfully"
}
```

### Delete Work Type

```
DELETE /api/work-types/:id
```

**Response:**
```json
{
  "success": true,
  "message": "Work type deleted successfully"
}
```

### Find Similar Work Types

```
GET /api/work-types/similar
```

**Query Parameters:**
- `q` or `name` (string, required): Work type name to search
- `threshold` (number, optional, default: 0.3): Similarity threshold (0-1)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Similar Work Type",
      "parent_bucket": "parent-bucket",
      "measurement_type": "area|linear|quantity",
      "suggested_units": "sq ft",
      "score": 0.85
    },
    ...
  ]
}
```

## Phase B Endpoints

### Update Costs

```
PATCH /api/work-types/:id/costs
```

**Request Body:**
```json
{
  "unit_cost_material": 12.75,
  "unit_cost_labor": 28.50,
  "productivity_unit_per_hr": 6.0,
  "region": "northeast"  // Optional, defaults to "default"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "workType": {
      "id": "uuid",
      "name": "Work Type Name",
      "unit_cost_material": 12.75,
      "unit_cost_labor": 28.50,
      "productivity_unit_per_hr": 6.0,
      "revision": 3
    },
    "costHistory": {
      "id": "uuid",
      "work_type_id": "uuid",
      "region": "northeast",
      "unit_cost_material": 12.75,
      "unit_cost_labor": 28.50,
      "captured_at": "2025-04-28T12:34:56.789Z",
      "updated_by": "user-uuid"
    }
  },
  "message": "Work type costs updated successfully"
}
```

### Get Cost History

```
GET /api/work-types/:id/costs/history
```

**Query Parameters:**
- `region` (string, optional): Filter by region
- `limit` (number, optional, default: 10): Maximum number of records to return

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "work_type_id": "uuid",
      "region": "northeast",
      "unit_cost_material": 12.75,
      "unit_cost_labor": 28.50,
      "captured_at": "2025-04-28T12:34:56.789Z",
      "updated_by": "user-uuid"
    },
    ...
  ]
}
```

### Add Materials

```
POST /api/work-types/:id/materials
```

**Request Body:**
```json
[
  {
    "product_id": "product-uuid",
    "qty_per_unit": 2.5,
    "unit": "each"
  },
  ...
]
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "work_type_id": "uuid",
      "product_id": "product-uuid",
      "qty_per_unit": 2.5,
      "unit": "each",
      "product": {
        "id": "product-uuid",
        "name": "Product Name",
        "sku": "SKU123"
      }
    },
    ...
  ],
  "message": "Successfully added 1 materials to work type"
}
```

### Remove Material

```
DELETE /api/work-types/:id/materials/:materialId
```

**Response:**
```json
{
  "success": true,
  "message": "Material removed successfully"
}
```

### Add Tags

```
POST /api/work-types/:id/tags
```

**Request Body:**
```json
[
  "asbestos",
  "electrical",
  "permit-required"
]
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "work_type_id": "uuid",
      "tag": "asbestos"
    },
    {
      "id": "uuid",
      "work_type_id": "uuid",
      "tag": "electrical"
    },
    {
      "id": "uuid",
      "work_type_id": "uuid",
      "tag": "permit-required"
    }
  ],
  "message": "Successfully added 3 tags to work type"
}
```

### Remove Tag

```
DELETE /api/work-types/:id/tags/:tag
```

**Response:**
```json
{
  "success": true,
  "message": "Tag removed successfully"
}
```

### Get Tags by Frequency

```
GET /api/work-types/tags/frequency
```

**Query Parameters:**
- `min_count` (number, optional, default: 1): Minimum count to include a tag

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "tag": "electrical",
      "count": 15
    },
    {
      "tag": "permit-required",
      "count": 12
    },
    {
      "tag": "asbestos",
      "count": 8
    },
    ...
  ]
}
```

## Error Codes

- `400 Bad Request`: Invalid input data
- `401 Unauthorized`: Missing or invalid authentication
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource already exists
- `500 Internal Server Error`: Server error

## Rate Limiting

The `/similar` endpoint is rate-limited to 60 requests per minute.
