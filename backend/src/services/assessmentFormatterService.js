// services/assessmentFormatterService.js
const { applyRulesToAssessment } = require("../utils/rulesEngine");

/**
 * Converts enriched assessment data into markdown format expected by LLM.
 * Structured for accuracy, traceability, and consistent LLM behavior.
 */
function formatAssessmentToMarkdown(assessment) {
  // Apply business rules to the assessment data
  const {
    date,
    inspector,
    projectId,
    projectName,
    scope,
    measurements = [],
    materials = [],
    conditions = [],
    notes = "",
  } = applyRulesToAssessment(assessment);

  const lines = [];

  // === Metadata ===
  lines.push("## ASSESSMENT DATA\n");
  lines.push("### Metadata");
  lines.push(`- Project: ${projectName || 'Unknown Project'}`);
  lines.push(`- Date: ${date}`);
  lines.push(`- Inspector: ${inspector}`);
  lines.push(`- Project ID: ${projectId}\n`);

  // === Scope ===
  // Only include scope section if there's an actual scope provided
  if (scope && scope.trim()) {
    lines.push("### Scope");
    lines.push(scope);
    lines.push("");
  }

  // === Measurements ===
  lines.push("### MEASUREMENTS");
  if (!measurements || measurements.length === 0) {
    lines.push("- No measurements recorded.");
  } else {
    // Group measurements by type for better organization
    const areaItems = measurements.filter(m => m.measurementType === 'area');
    const linearItems = measurements.filter(m => m.measurementType === 'linear');
    const quantityItems = measurements.filter(m => m.measurementType === 'quantity');
    const otherItems = measurements.filter(m => !m.measurementType);

    // Area measurements
    if (areaItems.length > 0) {
      lines.push("#### Area Measurements (sq ft)");
      for (const m of areaItems) {
        // Get dimensions from either direct properties or dimensions object
        let length, width, value;
        
        // Try to get dimensions from the dimensions object first
        if (m.dimensions) {
          length = m.dimensions.length;
          width = m.dimensions.width;
          value = parseFloat(length) * parseFloat(width);
        } else {
          // Then try direct properties
          length = m.length;
          width = m.width;
          value = m.value || (parseFloat(length) * parseFloat(width));
        }
        
        // Format the value
        const formattedValue = value ? `${value} ${m.unit || 'sq ft'}` : '';
        
        // Format dimensions
        const dimensionsText = (length && width) ? ` (${length} × ${width})` : '';
        
        // Create the base measurement line
        const description = m.description || m.label || 'Area';
        const base = `- ${description}${dimensionsText}: ${formattedValue}`;
        
        // Add recommendation tag if present
        const tag = m.recommendation ? ` → ${m.recommendation}` : "";
        lines.push(`${base}${tag}`);
      }
      lines.push("");
    }

    // Linear measurements
    if (linearItems.length > 0) {
      lines.push("#### Linear Measurements (ln ft)");
      for (const m of linearItems) {
        // Get length from either direct properties or dimensions object
        let length, value;
        
        // Try dimensions object first
        if (m.dimensions) {
          length = m.dimensions.length;
          value = length;
        } else {
          // Then try direct properties
          length = m.length;
          value = m.value || length;
        }
        
        // Format the value
        const formattedValue = value ? `${value} ${m.unit || 'ln ft'}` : '';
        
        // Create the base measurement line
        const description = m.description || m.label || 'Linear';
        const base = `- ${description}: ${formattedValue}`;
        
        // Add recommendation tag if present
        const tag = m.recommendation ? ` → ${m.recommendation}` : "";
        lines.push(`${base}${tag}`);
      }
      lines.push("");
    }

    // Quantity measurements
    if (quantityItems.length > 0) {
      lines.push("#### Quantity Measurements");
      for (const m of quantityItems) {
        // Get quantity
        const quantity = m.quantity || m.value || '';
        const unit = m.quantityUnit || m.unit || 'each';
        
        // Format the value
        const formattedValue = quantity ? `${quantity} ${unit}` : '';
        
        // Create the base measurement line
        const description = m.description || m.label || 'Item';
        const base = `- ${description}: ${formattedValue}`;
        
        // Add recommendation tag if present
        const tag = m.recommendation ? ` → ${m.recommendation}` : "";
        lines.push(`${base}${tag}`);
      }
      lines.push("");
    }

    // Other/unspecified measurements
    if (otherItems.length > 0) {
      lines.push("#### Other Measurements");
      for (const m of otherItems) {
        // Get value and unit
        const value = m.value || '';
        const unit = m.unit || '';
        
        // Format the value
        const formattedValue = value ? `${value} ${unit}` : '';
        
        // Create the base measurement line
        const description = m.description || m.label || 'Measurement';
        const base = `- ${description}: ${formattedValue}`;
        
        // Add recommendation tag if present
        const tag = m.recommendation ? ` → ${m.recommendation}` : "";
        lines.push(`${base}${tag}`);
      }
      lines.push("");
    }
  }
  // Remove extra blank line if no measurements
  if (measurements.length === 0) {
    lines.push("");
  }

  // === Materials ===
  lines.push("### MATERIALS");
  if (materials.length === 0) {
    lines.push("- No materials recorded.");
  } else {
    for (const mat of materials) {
      lines.push(`- ${mat.name}: ${mat.specification}`);
    }
  }
  lines.push("");

  // === Conditions ===
  lines.push("### CONDITIONS");
  if (conditions.length === 0) {
    lines.push("- No conditions reported.");
  } else {
    for (const c of conditions) {
      const base = `- ${c.location}: ${c.issue} (${c.severity})`;
      const mods = c.modifiers?.length ? ` → ${c.modifiers.join(", ")}` : "";
      lines.push(`${base}${mods}`);
    }
  }
  lines.push("");

  // === Replacement Indicators ===
  lines.push("### REPLACEMENT INDICATORS");
  const indicators = [];

  measurements.forEach((m) => {
    if (m.recommendation) {
      indicators.push(`- ${m.label} → ${m.recommendation}`);
    }

    // Filter out the "No related condition found" placeholder
    const realModifiers = (m.conditionModifiers || []).filter(
      mod => mod !== "(No related condition found)"
    );

    if (realModifiers?.length) {
      indicators.push(`- ${m.label} → ${realModifiers.join(", ")}`);
    }
  });

  if (indicators.length === 0) {
    indicators.push("- No replacement needs detected.");
  }
  lines.push(...indicators);
  lines.push("");

  // === Notes ===
  lines.push("### NOTES");
  lines.push(notes || "No additional notes.");

  return lines.join("\n");
}

/**
 * Generates a HTML preview of the formatted markdown
 * @param {Object} assessment - The assessment data
 * @returns {Object} - Object containing raw markdown and HTML preview
 */
function generateMarkdownPreview(assessment) {
  const markdown = formatAssessmentToMarkdown(assessment);

  // Convert markdown to HTML for preview
  const html = markdown
    .replace(/\n/g, '<br>')
    .replace(/###\s(.*)/g, '<h3>$1</h3>')
    .replace(/##\s(.*)/g, '<h2>$1</h2>')
    .replace(/^-\s(.*)/gm, '<li>$1</li>')
    .replace(/→/g, '<span style="color:#0066cc;">→</span>');

  return {
    raw: markdown,
    html
  };
}

module.exports = { formatAssessmentToMarkdown, generateMarkdownPreview };