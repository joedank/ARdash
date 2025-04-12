/**
 * Generates a unique ID string
 * Used for creating unique identifiers for form elements
 * @returns {string} A unique identifier string
 */
export function generateId() {
  return Math.random().toString(36).substring(2, 11);
}
