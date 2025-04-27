'use strict';

const logger = require('../logger');

/**
 * Set of relevant keywords for work-type matching
 * These are weighted more heavily when ranking sentences
 */
const RELEVANT_KEYWORDS = new Set([
  'replace', 'repair', 'install', 'remove', 'damage', 'leak',
  'rotted', 'broken', 'cracked', 'worn', 'deteriorated', 'water', 
  'mold', 'moisture', 'foundation', 'structure', 'subfloor', 'floor',
  'wall', 'ceiling', 'roof', 'window', 'door', 'cabinet', 'countertop',
  'plumbing', 'electrical', 'hvac', 'paint', 'drywall', 'insulation',
  'siding', 'trim', 'gutter', 'concrete', 'wood', 'metal', 'plastic',
  'tile', 'vinyl', 'laminate', 'carpet', 'flooring', 'shingle'
]);

/**
 * Extracts and ranks important sentences from assessment text
 * @param {string} text - The text to extract sentences from
 * @param {number} maxSentences - Maximum number of sentences to return
 * @returns {string[]} Array of highest-ranked sentences
 */
function extractTopSentences(text, maxSentences = 8) {
  if (!text || typeof text !== 'string') return [];
  
  // Split text into sentences (handle common punctuation)
  const sentences = text.split(/[.!?](?:\s+|$)/).filter(s => s.trim().length > 10);
  
  if (sentences.length <= maxSentences) {
    return sentences; // Return all if fewer than max
  }
  
  // Calculate relevance score for each sentence based on keyword density
  const scoredSentences = sentences.map(sentence => {
    const words = sentence.toLowerCase().split(/\s+/);
    const keywordCount = words.filter(word => RELEVANT_KEYWORDS.has(word)).length;
    const keywordDensity = keywordCount / words.length;
    
    return {
      sentence,
      score: keywordDensity * 2 + words.length * 0.01 // Prioritize keywords, slightly favor longer sentences
    };
  });
  
  // Sort by score (highest first) and take top N
  return scoredSentences
    .sort((a, b) => b.score - a.score)
    .slice(0, maxSentences)
    .map(s => s.sentence);
}

/**
 * Creates a compact version of assessment data
 * Reduces text size while preserving key information
 * @param {Object} assessment - Assessment data object
 * @param {Object} options - Options for compacting
 * @param {number} options.maxSentences - Max sentences to keep in long text fields
 * @returns {Object} Compacted assessment copy
 */
function compactAssessment(assessment, options = {}) {
  if (!assessment) return null;
  
  const { maxSentences = 8 } = options;
  
  try {
    // Create shallow copy of assessment
    const compacted = { ...assessment };
    
    // Compact scope if it exists and is a string
    if (compacted.scope && typeof compacted.scope === 'string') {
      const topSentences = extractTopSentences(compacted.scope, maxSentences);
      compacted.scope = topSentences.join('. ');
      
      if (compacted.scope && !compacted.scope.endsWith('.')) {
        compacted.scope += '.';
      }
    }
    
    // Compact conditions
    if (Array.isArray(compacted.conditions)) {
      // Keep all conditions but truncate long descriptions
      compacted.conditions = compacted.conditions.map(condition => {
        if (!condition) return condition;
        
        const copy = { ...condition };
        
        // Truncate issue text if too long
        if (copy.issue && typeof copy.issue === 'string' && copy.issue.length > 100) {
          copy.issue = copy.issue.substring(0, 100) + '...';
        }
        
        // Keep only essential information in notes
        if (copy.notes && typeof copy.notes === 'string' && copy.notes.length > 100) {
          const topNotes = extractTopSentences(copy.notes, 2);
          copy.notes = topNotes.join('. ');
        }
        
        return copy;
      });
    }
    
    // Remove internal IDs and unnecessary metadata
    if (compacted.inspections && Array.isArray(compacted.inspections)) {
      compacted.inspections = compacted.inspections.map(inspection => {
        if (!inspection) return inspection;
        
        // Create a copy without internal fields
        const { id, project_id, created_at, updated_at, ...essentialData } = inspection;
        return essentialData;
      });
    }
    
    // Strip out unnecessary properties from measurements
    if (compacted.measurements && Array.isArray(compacted.measurements)) {
      compacted.measurements = compacted.measurements.map(measurement => {
        if (!measurement) return measurement;
        
        // Keep only essential measurement properties
        const {
          label, description, measurementType, unit, value,
          length, width, height, diameter, quantity,
          location, recommendation,
          // Keep dimensions object if it exists
          dimensions
        } = measurement;
        
        return {
          label, description, measurementType, unit, value,
          length, width, height, diameter, quantity,
          location, recommendation,
          dimensions,
          // Add work_type_id if present for linking
          work_type_id: measurement.work_type_id
        };
      });
    }
    
    // Keep photos but remove binary data and limit the number
    if (compacted.photos && Array.isArray(compacted.photos)) {
      // Take only first 5 photos
      compacted.photos = compacted.photos.slice(0, 5).map(photo => {
        if (!photo) return photo;
        
        // Keep only essential photo properties, strip binary data
        const { file_path, photo_type, inspection_id, description } = photo;
        return { file_path, photo_type, inspection_id, description };
      });
    }
    
    logger.info(`Compacted assessment data: scope reduced from ${assessment.scope?.length || 0} to ${compacted.scope?.length || 0} chars`);
    
    return compacted;
  } catch (error) {
    logger.error(`Error compacting assessment data: ${error.message}`, { error });
    // Return original assessment on error
    return assessment;
  }
}

module.exports = {
  compactAssessment,
  extractTopSentences
};
