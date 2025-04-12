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
 * Applies business rules to raw assessment data:
 * - Tags measurements with "REPLACE" where applicable
 * - Adds condition-based modifiers like "REPAIR", "TREAT"
 * - Links related conditions to measurement locations
 */
function applyRulesToAssessment(assessment) {
  const measurements = (assessment.measurements || []).map((m, index) => {
    const value = parseFloat(m.value);
    const unit = normalizeUnit(m.unit);
    const label = normalizeLabel(m.label);
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
  thresholds
};