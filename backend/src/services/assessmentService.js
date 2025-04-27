// services/assessmentService.js
const { Project, ProjectInspection } = require("../models");
const { Op } = require("sequelize");

/**
 * Retrieves a complete assessment by project ID with all necessary data
 * for markdown formatting (measurements, conditions, materials).
 */
async function getAssessmentById(projectId) {
  try {
    const project = await Project.findByPk(projectId, {
      include: [
        {
          model: ProjectInspection,
          as: 'inspections',
          where: {
            category: {
              [Op.in]: ['measurements', 'conditions', 'materials']
            }
          },
          required: false
        }
      ]
    });

    if (!project) {
      throw new Error(`Assessment project with ID ${projectId} not found`);
    }

    // Transform project data into the format expected by the formatter
    const assessment = {
      date: project.scheduled_date,
      inspector: project.assigned_to || 'Unknown',
      projectId: project.id,
      scope: project.condition || '',
      notes: project.notes || '',
      measurements: [],
      conditions: [],
      materials: []
    };

    // Process inspections into appropriate categories
    project.inspections.forEach(inspection => {
      const content = inspection.content || {};

      if (inspection.category === 'measurements' && content.items && Array.isArray(content.items)) {
        // Handle new array-based measurement format
        content.items.forEach(item => {
          // Handle different measurement types
          if (item.measurementType === 'area' && item.dimensions) {
            assessment.measurements.push({
              label: item.description || 'Unlabeled',
              value: calculateMeasurementValue(item.dimensions),
              unit: 'sq ft',
              material: item.material || '',
              location: item.location || '',
              measurementType: 'area'
            });
          } else if (item.measurementType === 'linear' && item.dimensions) {
            assessment.measurements.push({
              label: item.description || 'Unlabeled',
              value: item.dimensions.length || '0',
              unit: 'ln ft',
              material: item.material || '',
              location: item.location || '',
              measurementType: 'linear'
            });
          } else if (item.measurementType === 'quantity') {
            assessment.measurements.push({
              label: item.description || 'Unlabeled',
              value: item.quantity || '1',
              unit: item.quantityUnit || 'each',
              material: item.material || '',
              location: item.location || '',
              measurementType: 'quantity'
            });
          } else if (item.dimensions) {
            // Legacy format or unspecified type with dimensions
            assessment.measurements.push({
              label: item.description || 'Unlabeled',
              value: calculateMeasurementValue(item.dimensions),
              unit: determineMeasurementUnit(item.dimensions),
              material: item.material || '',
              location: item.location || '',
              measurementType: item.dimensions.width ? 'area' : 'linear'
            });
          }
        });
      } else if (inspection.category === 'measurements' && content.dimensions) {
        // Handle legacy single measurement format
        assessment.measurements.push({
          label: content.description || 'Unlabeled',
          value: calculateMeasurementValue(content.dimensions),
          unit: determineMeasurementUnit(content.dimensions),
          material: content.material || '',
          location: content.location || '',
          measurementType: content.dimensions.width ? 'area' : 'linear'
        });
      } else if (inspection.category === 'conditions' && content.issue) {
        assessment.conditions.push({
          location: content.location || 'General',
          issue: content.issue || 'Unspecified Issue',
          severity: content.severity || 'Unknown',
        });
      } else if (inspection.category === 'materials' && content.items && Array.isArray(content.items)) {
        content.items.forEach(item => {
          if (item && item.name) {
            assessment.materials.push({
              name: item.name,
              specification: item.specification || item.description || '',
              quantity: item.quantity || '',
              unit: item.unit || 'each'
            });
          }
        });
      } else if (inspection.category === 'materials' && content.name) {
        // Handle legacy single material format
        assessment.materials.push({
          name: content.name,
          specification: content.specification || content.description || '',
          quantity: content.quantity || '',
          unit: content.unit || 'each'
        });
      }
    });

    return assessment;
  } catch (error) {
    console.error(`Error retrieving assessment data for project ${projectId}:`, error);
    throw error;
  }
}

/**
 * Calculate a single measurement value from dimensions object
 */
function calculateMeasurementValue(dimensions) {
  if (!dimensions) return '0';

  if (dimensions.length && dimensions.width) {
    // Area calculation
    return (parseFloat(dimensions.length) * parseFloat(dimensions.width)).toFixed(2);
  } else if (dimensions.length) {
    // Linear measurement
    return dimensions.length.toString();
  } else if (dimensions.count) {
    // Count measurement
    return dimensions.count.toString();
  }

  return '0';
}

/**
 * Determine the unit type based on dimensions
 */
function determineMeasurementUnit(dimensions) {
  if (!dimensions) return 'each';

  if (dimensions.length && dimensions.width) {
    return 'sq ft';
  } else if (dimensions.length) {
    return 'ln ft';
  } else if (dimensions.count) {
    return 'each';
  }

  return 'each';
}

module.exports = {
  getAssessmentById
};