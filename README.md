# Construction Management Web Application

## API Path Prefixing Convention

This application uses a consistent convention for API path prefixing:

- In `api.service.js`, the `baseURL` is set to `/api`
- All service calls should use paths relative to this base URL
- Example: Use `/auth/login` instead of `/api/auth/login`

If you encounter any doubled prefixes (e.g., `/api/api/auth/login`), run the provided script:

```
node scripts/stripApiPrefix.js
```

This script will scan all service files and remove redundant `/api/` prefixes.

An ESLint rule (`no-hardcoded-api`) is also configured to prevent introducing new hard-coded `/api/` prefixes.

## Standardized Error Handling

The application implements a comprehensive standardized error handling middleware to ensure consistent error responses across all endpoints. This improves debugging, user experience, and frontend error handling.

### Response Format

All API responses follow a consistent format:

For successful operations:
```json
{
  "success": true,
  "message": "Operation description",
  "data": { /* Operation result data */ }
}
```

For errors:
```json
{
  "success": false,
  "message": "Error description",
  "data": { /* Optional error details */ }
}
```

### Error Types

The application supports several specialized error types:

| Error Type | HTTP Status | Description |
|------------|-------------|-------------|
| ValidationError | 400 | Input validation errors with field information |
| UUIDValidationError | 400 | Invalid UUID format in route parameters |
| AuthenticationError | 401 | User is not authenticated |
| AuthorizationError | 403 | User lacks permission for the action |
| NotFoundError | 404 | Resource not found |
| BusinessLogicError | 422 | Business logic constraint violated |
| DatabaseError | 500 | Database operation error |

### Using Error Classes in Controllers

Import error classes from the utils/errors.js module:

```javascript
const { 
  ValidationError, 
  NotFoundError,
  AuthenticationError,
  AuthorizationError,
  UUIDValidationError,
  BusinessLogicError
} = require('../utils/errors');

// In a controller method:
try {
  // Check validation
  if (!req.body.name) {
    throw new ValidationError('Name is required', 'name');
  }
  
  // Check UUID format
  if (!uuidRegex.test(id)) {
    throw new UUIDValidationError(`Invalid UUID format: ${id}`);
  }
  
  // Check resource existence
  const resource = await Model.findByPk(id);
  if (!resource) {
    throw new NotFoundError(`Resource with ID ${id} not found`);
  }
  
  // Respond with success
  return res.status(200).json({
    success: true,
    message: 'Operation successful',
    data: resource
  });
  
} catch (error) {
  // Pass to error middleware
  next(error);
}
```

### Error Handling Flow

1. Controller or service throws an error or passes it to `next(error)`
2. The standardized error middleware catches the error
3. The middleware determines the appropriate status code and formats the response
4. A standardized error response is returned to the client
5. Detailed error information is logged (including request context)

The standardized error handling approach simplifies error management throughout the application while providing clear, consistent feedback to users.
