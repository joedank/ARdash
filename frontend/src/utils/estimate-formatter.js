/**
 * Utility functions for standardizing estimate data formats
 */

/**
 * Standardize line items from various sources into a consistent format
 * @param {Array} items - Array of line items from different sources
 * @returns {Array} - Standardized line items
 */
export const standardizeLineItems = (items) => {
  if (!Array.isArray(items)) {
    console.warn('standardizeLineItems received non-array input:', items);
    return [];
  }
  
  return items.map(item => {
    // Create a standardized item with default values
    const standardItem = {
      description: '',
      quantity: 1,
      unit: 'each',
      unit_price: 0,
      total: 0,
      sourceType: 'manual',
      sourceId: null
    };
    
    // Handle different property naming conventions
    if (item.name || item.description) {
      standardItem.description = item.description || item.name;
    }
    
    if (item.quantity !== undefined) {
      standardItem.quantity = parseFloat(item.quantity) || 1;
    }
    
    if (item.unit) {
      standardItem.unit = item.unit;
    }
    
    // Handle different price field names
    if (item.unit_price !== undefined) {
      standardItem.unit_price = parseFloat(item.unit_price) || 0;
    } else if (item.unitPrice !== undefined) {
      standardItem.unit_price = parseFloat(item.unitPrice) || 0;
    } else if (item.price !== undefined) {
      standardItem.unit_price = parseFloat(item.price) || 0;
    }
    
    // Handle different total field names or calculate if missing
    if (item.total !== undefined) {
      standardItem.total = parseFloat(item.total) || 0;
    } else if (item.item_total !== undefined) {
      standardItem.total = parseFloat(item.item_total) || 0;
    } else if (item.itemTotal !== undefined) {
      standardItem.total = parseFloat(item.itemTotal) || 0;
    } else {
      // Calculate total if not provided
      standardItem.total = standardItem.quantity * standardItem.unit_price;
    }
    
    // Preserve source information if available
    if (item.sourceType) {
      standardItem.sourceType = item.sourceType;
    }
    
    if (item.sourceId) {
      standardItem.sourceId = item.sourceId;
    }
    
    // Preserve product ID if available
    if (item.product_id) {
      standardItem.product_id = item.product_id;
    } else if (item.productId) {
      standardItem.product_id = item.productId;
    }
    
    return standardItem;
  });
};

/**
 * Extract assessment data from various formats into a standardized structure
 * @param {Object} assessmentData - Assessment data from different sources
 * @returns {Object} - Standardized assessment data
 */
export const standardizeAssessmentData = (assessmentData) => {
  if (!assessmentData) {
    return null;
  }
  
  // Create a standardized assessment object
  const standardAssessment = {
    projectId: null,
    projectName: '',
    formattedMarkdown: '',
    inspections: []
  };
  
  // Extract project ID from different possible locations
  if (assessmentData.projectId) {
    standardAssessment.projectId = assessmentData.projectId;
  } else if (assessmentData.project_id) {
    standardAssessment.projectId = assessmentData.project_id;
  } else if (assessmentData.id) {
    standardAssessment.projectId = assessmentData.id;
  }
  
  // Extract project name
  if (assessmentData.projectName) {
    standardAssessment.projectName = assessmentData.projectName;
  } else if (assessmentData.project_name) {
    standardAssessment.projectName = assessmentData.project_name;
  } else if (assessmentData.name) {
    standardAssessment.projectName = assessmentData.name;
  }
  
  // Extract formatted markdown content
  if (assessmentData.formattedMarkdown) {
    standardAssessment.formattedMarkdown = assessmentData.formattedMarkdown;
  } else if (assessmentData.formattedData) {
    standardAssessment.formattedMarkdown = assessmentData.formattedData;
  } else if (assessmentData.formatted_markdown) {
    standardAssessment.formattedMarkdown = assessmentData.formatted_markdown;
  } else if (assessmentData.formatted_data) {
    standardAssessment.formattedMarkdown = assessmentData.formatted_data;
  }
  
  // Extract inspections
  if (Array.isArray(assessmentData.inspections)) {
    standardAssessment.inspections = assessmentData.inspections;
  }
  
  return standardAssessment;
};

/**
 * Format currency value
 * @param {number} value - Value to format
 * @returns {string} - Formatted currency string
 */
export const formatCurrency = (value) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2
  }).format(value || 0);
};

/**
 * Format a key string into a human-readable label
 * @param {string} key - Key to format
 * @returns {string} - Formatted label
 */
export const formatKey = (key) => {
  if (!key) return '';
  
  return key
    .replace(/_/g, ' ')
    .replace(/\b\w/g, l => l.toUpperCase());
};
