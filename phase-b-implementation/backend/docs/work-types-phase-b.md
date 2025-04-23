# Work Types Knowledge Base - Phase B Implementation

This document describes the Phase B implementation of the Work Types Knowledge Base, which adds cost, material, and safety data management capabilities.

## Overview

The Phase B implementation enhances the Work Types Knowledge Base with the following features:

1. **Cost Management**
   - Track material and labor costs per unit
   - Record productivity rates (units per hour)
   - Maintain cost history with timestamps and user attribution
   - Support for regional cost variations

2. **Materials Management**
   - Associate materials from the product catalog with work types
   - Specify quantity per unit and unit of measurement
   - Manage material requirements for accurate estimating

3. **Safety & Permit Tags**
   - Tag work types with safety requirements
   - Identify permit needs
   - Standardize safety protocols across similar work types

## Database Schema

The Phase B implementation adds the following tables:

### work_type_materials

```sql
CREATE TABLE work_type_materials (
  id UUID PRIMARY KEY,
  work_type_id UUID NOT NULL REFERENCES work_types(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  qty_per_unit DECIMAL(10, 4) NOT NULL,
  unit VARCHAR(50) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
  UNIQUE(work_type_id, product_id)
);
```

### work_type_tags

```sql
CREATE TABLE work_type_tags (
  id UUID PRIMARY KEY,
  work_type_id UUID NOT NULL REFERENCES work_types(id) ON DELETE CASCADE,
  tag VARCHAR(100) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
  UNIQUE(work_type_id, tag)
);
```

### work_type_cost_history

```sql
CREATE TABLE work_type_cost_history (
  id UUID PRIMARY KEY,
  work_type_id UUID NOT NULL REFERENCES work_types(id) ON DELETE CASCADE,
  region VARCHAR(50) NOT NULL DEFAULT 'default',
  unit_cost_material DECIMAL(10, 2),
  unit_cost_labor DECIMAL(10, 2),
  captured_at TIMESTAMP WITH TIME ZONE NOT NULL,
  updated_by UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);
```

## API Endpoints

The Phase B implementation adds the following API endpoints:

### Cost Management

- `PATCH /api/work-types/:id/costs` - Update costs for a work type
- `GET /api/work-types/:id/costs/history` - Get cost history for a work type

### Materials Management

- `POST /api/work-types/:id/materials` - Add materials to a work type
- `DELETE /api/work-types/:id/materials/:materialId` - Remove a material from a work type

### Safety & Permit Tags

- `POST /api/work-types/:id/tags` - Add tags to a work type
- `DELETE /api/work-types/:id/tags/:tag` - Remove a tag from a work type
- `GET /api/work-types/tags/frequency` - Get tags grouped by frequency

## Security

Access to the cost, material, and safety management features is restricted to users with the following roles:

- `admin` - Full access to all features
- `estimator_manager` - Access to cost, material, and safety management features

Regular users can view work types but cannot modify costs, materials, or safety tags.

## Frontend Components

The Phase B implementation adds the following frontend components:

- `CostEditor.vue` - Modal for editing work type costs
- `MaterialsTab.vue` - Tab for managing materials and safety tags
- `CostHistoryTab.vue` - Tab for viewing cost history
- `SafetyTagChip.vue` - Component for displaying safety tags

## Utilities

The Phase B implementation adds the following utilities:

- `import-work-type-costs.js` - Script to backfill cost history for existing work types
- `convertRequestToSnakeCase` - Helper function for batch-converting request bodies to snake_case

## Testing

The Phase B implementation includes the following tests:

- Unit tests for the WorkType model validation
- Cypress tests for the Work Types UI

## Documentation

The Phase B implementation includes the following documentation:

- `work-types-api.md` - API documentation for the Work Types endpoints
- `work-types-phase-b.md` - This document

## Future Enhancements

Potential future enhancements for the Work Types Knowledge Base include:

1. **Cost Trend Visualization**
   - Add charts to visualize cost trends over time
   - Compare costs across regions

2. **Material Alternatives**
   - Support for alternative materials
   - Substitution recommendations based on availability and cost

3. **Safety Compliance Tracking**
   - Track compliance with safety requirements
   - Generate safety checklists for work orders

4. **Integration with Estimating Wizard**
   - Use work type data to power the estimating wizard
   - Suggest appropriate work types based on project requirements
