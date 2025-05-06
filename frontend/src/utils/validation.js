/**
 * Utility functions for validation
 */

/**
 * Check if a value is blank (empty string, null, undefined, or whitespace-only string)
 * @param {*} value - Value to check
 * @returns {boolean} - True if value is blank
 */
export const isBlank = (value) => 
  value === undefined || 
  value === null || 
  (typeof value === 'string' && value.trim() === '');

/**
 * Check if a value is a valid UUID
 * @param {string} value - UUID to validate
 * @returns {boolean} - True if value is a valid UUID
 */
export const isValidUuid = (value) => {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  return typeof value === 'string' && uuidRegex.test(value);
};

/**
 * Check if a value is a valid email address
 * @param {string} value - Email to validate
 * @returns {boolean} - True if value is a valid email
 */
export const isValidEmail = (value) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return typeof value === 'string' && emailRegex.test(value);
};

/**
 * Check if a value is a valid hex color code
 * @param {string} value - Hex color to validate
 * @returns {boolean} - True if value is a valid hex color
 */
export const isValidHexColor = (value) => {
  return /^#([0-9A-F]{3}){1,2}$/i.test(value);
};

/**
 * Normalize hex color code to valid format
 * @param {string} color - Color to normalize
 * @returns {string} - Normalized color (with # prefix and 6 digits)
 */
export const normalizeHexColor = (color) => {
  if (isBlank(color)) return '#000000'; // Default to black if empty
  
  // If color already has # prefix and is valid format
  if (isValidHexColor(color)) {
    // Convert short hex (#RGB) to full hex (#RRGGBB)
    if (color.length === 4) {
      return `#${color[1]}${color[1]}${color[2]}${color[2]}${color[3]}${color[3]}`;
    }
    return color;
  }
  
  // If color doesn't have # prefix, add it
  if (/^[0-9A-F]{6}$/i.test(color)) {
    return `#${color}`;
  }
  
  // For any other invalid format, return default
  return '#000000';
};
