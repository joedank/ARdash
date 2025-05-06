# PDF Settings Bug Fixes & Enhancements

## Issue Summary

The PDF settings component had an issue where empty strings (`''`) from form fields would overwrite existing settings values in the database, causing colors and the company logo to disappear in generated PDFs after refreshing the page.

## Root Cause

1. When saving settings, empty strings from form fields were being included in the payload
2. Backend was upserting these empty strings, overwriting existing values
3. No distinction between "not provided" and "explicitly cleared" values

## Implemented Solutions

### 1. Frontend Protection (PdfSettings.vue)

- Skip empty strings, null, and undefined values when building group settings objects
- Only send `companyLogoPath` when logo has been changed (`logoChanged = true`)
- Added whitespace detection for strings (e.g., `'   '` now treated as empty)
- Added new `isBlank()` utility function in `validation.js` to consistently check for empty values
- Added explicit "Remove Logo" button for intentional logo removal

### 2. Backend Protection (settingsService.js)

- Skip empty strings, null, and whitespace-only strings before database upsert
- Added special handling for explicit `null` values (interpreted as deletion request)
- Improved logging for skipped values and deletions
- Added cleanup migration to remove existing empty settings rows

### 3. Special Logo Handling

- Added ability to explicitly remove logo (sends `null` to backend)
- Created distinction between "not changed" (omitted from payload) and "removed" (explicit `null`)
- Enhanced UI with "Remove Logo" button that only appears when a logo exists

## Edge Cases Addressed

1. **Whitespace-only strings** - Now treated as blank with `isBlank()` utility
2. **Reset-to-default intent** - Added explicit reset button for logo and null handling
3. **Undefined values** - Frontend and backend both check for undefined
4. **Multiple clients racing** - Transactions ensure atomic operations per setting group

## Additional Enhancements

1. **Validation Utility** - Created reusable validation.js with functions for:
   - `isBlank(value)` - Check for empty strings, null, undefined, and whitespace-only
   - `isValidUuid(value)` - UUID format validation
   - `isValidEmail(value)` - Email format validation
   - `isValidHexColor(value)` - Hex color validation
   - `normalizeHexColor(color)` - Color format normalization

2. **Database Cleanup** - Added migration to remove existing empty settings:
   ```js
   // 20250504010000-cleanup-empty-settings.js
   'DELETE FROM settings WHERE value = \'\' OR value IS NULL;'
   ```

3. **Improved Color Handling** - Enhanced hex color validation and normalization

## Code Changes

### Frontend Validation Utility

```javascript
// validation.js
export const isBlank = (value) => 
  value === undefined || 
  value === null || 
  (typeof value === 'string' && value.trim() === '');
```

### Frontend Component Logic

```javascript
// PdfSettings.vue - saving settings
if (key === 'companyLogoPath') {
  // Special handling for logo path
  if (logoChanged.value) {
    // If explicitly removed, set to null to signal deletion
    if (logoExplicitlyRemoved.value) {
      groupSettings[key] = null; // Explicit null signals deletion
    } else {
      // Otherwise use the new value if not blank
      const val = settings.value[key];
      if (!isBlank(val)) {
        groupSettings[key] = val;
      }
    }
  }
} else {
  // For other keys, apply the non-empty check using isBlank
  const val = settings.value[key];
  if (!isBlank(val)) {
    groupSettings[key] = val;
  }
}
```

### Backend Service Logic

```javascript
// settingsService.js
// Handle special case for explicit null (signals deletion)
if (value === null) {
  // Delete the setting if it exists
  await Settings.destroy({
    where: { key },
    transaction
  });
  logger.debug(`Deleted setting '${key}'`);
  continue;
}

// Skip empty or undefined values to prevent overwriting existing settings with blank values
if (value === '' || value === undefined || (typeof value === 'string' && value.trim() === '')) {
  logger.debug(`Skipping empty or whitespace-only value for setting '${key}'`);
  continue;
}
```

## Usage Examples

### Explicitly Removing a Logo

1. User clicks "Remove Logo" button
2. Frontend sets `logoExplicitlyRemoved = true` and `settings.companyLogoPath = null`
3. When saving, the null value is sent to the backend
4. Backend interprets null as a deletion request and removes the setting

### Skipping Empty Values

1. User clears a text field (resulting in `''`)
2. Frontend uses `isBlank()` to detect empty field and excludes it from the payload
3. Backend retains the previous value since no update is received

## Testing

To verify these fixes:

1. Submit the form with some fields empty
2. Refresh the page - original values should be preserved
3. Test logo upload and removal
4. Check generated PDFs to ensure colors and logo are preserved
