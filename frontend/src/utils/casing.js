/**
 * Utility functions for converting between snake_case and camelCase
 * to handle inconsistencies between frontend and backend naming conventions.
 */

/**
 * Converts a single snake_case string to camelCase
 *
 * @param {string} str - String to convert
 * @returns {string} - camelCase string
 */
export const snakeToCamel = (str) => {
  if (typeof str !== 'string') return str;
  return str.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
};

/**
 * Converts an object's keys from snake_case to camelCase
 * Works recursively on nested objects and arrays
 *
 * @param {Object|Array} obj - Object or array to convert
 * @returns {Object|Array} - New object or array with camelCase keys
 */
export const toCamelCase = (obj) => {
  if (obj === null) return obj;
  
  // Handle non-object types (including strings)
  if (typeof obj !== 'object') {
    return snakeToCamel(obj);
  }

  if (Array.isArray(obj)) {
    return obj.map(item => toCamelCase(item));
  }

  return Object.keys(obj).reduce((result, key) => {
    // Skip conversion for keys that should remain unchanged
    if (key === 'created_at' || key === 'updated_at' || key === 'deleted_at') {
      result[key] = toCamelCase(obj[key]);
      return result;
    }

    // Convert snake_case to camelCase
    const camelKey = snakeToCamel(key);
    result[camelKey] = toCamelCase(obj[key]);
    return result;
  }, {});
};

/**
 * Converts an object's keys from camelCase to snake_case
 * Works recursively on nested objects and arrays
 *
 * @param {Object|Array} obj - Object or array to convert
 * @returns {Object|Array} - New object or array with snake_case keys
 */
export const toSnakeCase = (obj) => {
  if (obj === null || typeof obj !== 'object') return obj;

  if (Array.isArray(obj)) {
    return obj.map(item => toSnakeCase(item));
  }

  return Object.keys(obj).reduce((result, key) => {
    // Skip conversion for specific keys
    if (key === 'createdAt' || key === 'updatedAt' || key === 'deletedAt') {
      const snakeKey = key === 'createdAt' ? 'created_at' : key === 'updatedAt' ? 'updated_at' : 'deleted_at';
      result[snakeKey] = toSnakeCase(obj[key]);
      return result;
    }

    // Convert camelCase to snake_case
    const snakeKey = key.replace(/([A-Z])/g, letter => `_${letter.toLowerCase()}`);
    result[snakeKey] = toSnakeCase(obj[key]);
    return result;
  }, {});
};

/**
 * Normalizes client data for consistent usage in frontend components
 *
 * @param {Object} client - Client data from API
 * @returns {Object} - Normalized client object
 */
export const normalizeClient = (client) => {
  if (!client) return null;

  // Handle inconsistent ID field names
  const clientId = client.client_id || client.client_fk_id || client.id;

  // Handle display name in both formats (camelCase and snake_case)
  const displayName = client.displayName || client.display_name || client.name;

  const normalized = {
    id: clientId,
    clientId: clientId, // Add clientId property to match what the invoice form expects
    displayName: displayName, // Use the detected display name
    company: client.company,
    email: client.email,
    phone: client.phone,
    clientType: client.clientType || client.client_type,
    paymentTerms: client.paymentTerms || client.payment_terms,
    defaultTaxRate: client.defaultTaxRate || client.default_tax_rate,
    defaultCurrency: client.defaultCurrency || client.default_currency,
    notes: client.notes,
    isActive: client.isActive || client.is_active,
    addresses: client.addresses ? client.addresses.map(addr => ({
      id: addr.id,
      clientId: addr.clientId || addr.client_id,
      name: addr.name,
      streetAddress: addr.streetAddress || addr.street_address,
      city: addr.city,
      state: addr.state,
      postalCode: addr.postalCode || addr.postal_code,
      country: addr.country,
      isPrimary: addr.isPrimary || addr.is_primary,
      notes: addr.notes,
      createdAt: addr.createdAt || addr.created_at,
      updatedAt: addr.updatedAt || addr.updated_at
    })) : [],
    // Include original selected address ID if present
    selectedAddressId: client.selectedAddressId || client.selected_address_id,
    createdAt: client.createdAt || client.created_at,
    updatedAt: client.updatedAt || client.updated_at
  };
  
  return normalized;
};

/**
 * Normalizes address data for consistent usage in frontend components
 *
 * @param {Object} address - Address data from API
 * @returns {Object} - Normalized address object
 */
export const normalizeAddress = (address) => {
  if (!address) return null;

  return {
    id: address.id,
    clientId: address.clientId || address.client_id,
    name: address.name,
    streetAddress: address.streetAddress || address.street_address,
    city: address.city,
    state: address.state,
    postalCode: address.postalCode || address.postal_code,
    country: address.country,
    isPrimary: address.isPrimary || address.is_primary,
    notes: address.notes,
    createdAt: address.createdAt || address.created_at,
    updatedAt: address.updatedAt || address.updated_at
  };
};

/**
 * Formats an address for display
 *
 * @param {Object} address - Address object to format
 * @returns {string} - Formatted address string
 */
export const formatAddressForDisplay = (address) => {
  if (!address) return '';

  const streetAddress = address.streetAddress || address.street_address;
  const postalCode = address.postalCode || address.postal_code;

  const parts = [
    streetAddress,
    address.city,
    address.state,
    postalCode,
    address.country
  ].filter(Boolean);

  return parts.join(', ');
};

/**
 * Validates that a string is a valid UUID
 *
 * @param {string} str - String to validate
 * @returns {boolean} - True if string is a valid UUID
 */
export const isValidUuid = (str) => {
  if (!str || typeof str !== 'string') return false;
  if (str === 'undefined' || str === 'null') return false;

  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  return uuidRegex.test(str);
};
