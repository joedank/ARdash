// utils/rulesEngine.js

/**
 * Configuration for measurement thresholds that trigger replacement recommendations
 */
const thresholds = {
  "sq ft": 50,
  "ln ft": 20
};

/**
 * Utility function to normalize unit strings
 * @param {string} unit - Unit to normalize
 * @returns {string} - Normalized unit string
 */
function normalizeUnit(unit) {
  return (unit || '').toLowerCase().trim();
}

/**
 * Utility function to normalize label strings
 * @param {string} label - Label to normalize
 * @returns {string} - Normalized label string
 */
function normalizeLabel(label) {
  if (!label) return '';
  // Convert to title case but keep common words lowercase
  return label.trim().replace(/\b\w+/g, word => 
    ['of', 'the', 'and', 'in', 'on', 'at'].includes(word.toLowerCase()) 
      ? word.toLowerCase() 
      : word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
  );
}

/**
 * Gets a measurement value from either direct properties or dimensions object
 * @param {Object} measurement - The measurement object
 * @param {string} property - The property to get (e.g., 'length', 'width')
 * @returns {string|number} - The measurement value
 */
function getMeasurementValue(measurement, property) {
  // First check direct property
  if (measurement[property] !== undefined && measurement[property] !== '') {
    return measurement[property];
  }
  // Then check in dimensions object
  if (measurement.dimensions && measurement.dimensions[property] !== undefined) {
    return measurement.dimensions[property];
  }
  // Default to empty string if not found
  return '';
}

/**
 * Extract measurement value based on type
 * @param {Object} m - Measurement object
 * @returns {number} - Numeric value
 */
function extractMeasurementValue(m) {
  if (m.measurementType === 'area') {
    // Area - calculate from length and width
    const length = parseFloat(getMeasurementValue(m, 'length')) || 0;
    const width = parseFloat(getMeasurementValue(m, 'width')) || 0;
    return length * width;
  } else if (m.measurementType === 'linear') {
    // Linear - just the length
    return parseFloat(getMeasurementValue(m, 'length')) || 0;
  } else if (m.measurementType === 'quantity') {
    // Quantity - use quantity field
    return parseFloat(m.quantity) || 0;
  } else {
    // Default fallback - use value if exists
    return parseFloat(m.value) || 0;
  }
}

/**
 * Get unit from measurement based on type
 * @param {Object} m - Measurement object
 * @returns {string} - Unit string
 */
function extractMeasurementUnit(m) {
  if (m.measurementType === 'area') {
    // For area measurements
    if (m.dimensions && m.dimensions.units) {
      return m.dimensions.units;
    } else if (m.units) {
      return m.units;
    }
    return 'sq ft'; // Default for area
  } else if (m.measurementType === 'linear') {
    // For linear measurements
    if (m.dimensions && m.dimensions.units) {
      return m.dimensions.units;
    } else if (m.units) {
      return m.units;
    }
    return 'ln ft'; // Default for linear
  } else if (m.measurementType === 'quantity') {
    // For quantity measurements
    return m.quantityUnit || 'each';
  } else {
    // Default fallback
    return m.unit || '';
  }
}

/**
 * Applies business rules to raw assessment data:
 * - Tags measurements with "REPLACE" where applicable
 * - Adds condition-based modifiers like "REPAIR", "TREAT"
 * - Links related conditions to measurement locations
 * - Handles both data structures for measurements (direct props and dimensions object)
 */
function applyRulesToAssessment(assessment) {
  const measurements = (assessment.measurements || []).map((m, index) => {
    // Extract description/label for the measurement
    const label = normalizeLabel(m.description || m.label || `Item ${index + 1}`);
    
    // Extract value and unit based on measurement type
    const value = extractMeasurementValue(m);
    const unit = normalizeUnit(extractMeasurementUnit(m));
    
    let recommendation = "";

    // Use thresholds from config
    if (thresholds[unit] && value > thresholds[unit]) {
      // Prefer material info when available for better context
      const replacementTarget = m.material || label || "Component";
      recommendation = `REPLACE: ${replacementTarget}`;
    }

    return { 
      ...m,
      label, // Use normalized label
      unit, // Use normalized unit 
      value, // Extracted numeric value
      recommendation,
      sourceType: "measurement",
      sourceId: m.id || `measurement-${index}`
    };
  });

  const conditions = (assessment.conditions || []).map((c, index) => {
    const mods = [];
    const issue = c.issue?.toLowerCase() || "";

    if (issue.includes("rot") && ["Moderate", "Severe"].includes(c.severity)) {
      mods.push("REPAIR: Substrate");
    }
    if (issue.includes("peeling paint") && c.severity === "Severe") {
      mods.push("TREAT: Primer before paint");
    }
    if (issue.includes("mold")) {
      mods.push("CLEAN before installation");
    }

    return { 
      ...c, 
      modifiers: mods,
      sourceType: "condition",
      sourceId: c.id || `condition-${index}`
    };
  });

  // Correlate measurements ↔ conditions by location
  const enrichedMeasurements = measurements.map((m) => {
    const location = m.location?.toLowerCase();
    const related = conditions.filter((c) =>
      c.location?.toLowerCase().includes(location || "")
    );
    
    // Add conditionIds for traceability
    const conditionIds = related.map(c => c.sourceId);
    
    // Extract modifiers from related conditions
    const linkedModifiers = related.flatMap((c) => c.modifiers || []);
    
    // Use fallback message if no related conditions found
    const conditionModifiers = related.length > 0 
      ? linkedModifiers 
      : ["(No related condition found)"];
    
    return { 
      ...m, 
      conditionModifiers,
      conditionIds, // Add for traceability
      relatedConditionsCount: related.length // Add count for debugging
    };
  });

  return {
    ...assessment,
    measurements: enrichedMeasurements,
    conditions,
  };
}

module.exports = { 
  applyRulesToAssessment,
  normalizeUnit,
  normalizeLabel,
  thresholds,
  getMeasurementValue,
  extractMeasurementValue,
  extractMeasurementUnit
};