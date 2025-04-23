const z = require('zod');
const logger = require('../utils/logger');
const WorkType = require('../models').WorkType;
const WorkTypeTag = require('../models').WorkTypeTag;
const { sequelize } = require('../models');

// Simple in-memory cache with TTL
class Cache {
  constructor(ttlMs = 300000) { // Default 5 minutes TTL
    this.cache = new Map();
    this.ttl = ttlMs;
  }

  get(key) {
    if (!this.cache.has(key)) return null;

    const { value, expires } = this.cache.get(key);
    if (Date.now() > expires) {
      this.cache.delete(key);
      return null;
    }

    return value;
  }

  set(key, value) {
    this.cache.set(key, {
      value,
      expires: Date.now() + this.ttl
    });
  }

  clear() {
    this.cache.clear();
  }
}

// ----- schemas -----
const ScopeSchema = z.object({
  requiredMeasurements: z.array(z.string()),
  questions: z.array(z.string()),
});

const DraftItemSchema = z.object({
  name: z.string(),
  measurementType: z.enum(['AREA', 'LINEAR', 'QUANTITY']),
  quantity: z.number(),
  unitPrice: z.number(),
});

const DraftSchema = z.array(DraftItemSchema);

// ----- builder -----
class PromptEngine {
  constructor() {
    // Initialize cache for work types with 5-minute TTL
    this.workTypeCache = new Cache(300000);
  }
  /**
   * Find matching work types by name using trigram similarity
   * @param {string} name - Name to search for
   * @param {number} threshold - Similarity threshold (0-1)
   * @returns {Promise<Array>} - Array of matching work types with costs, materials, and tags
   */
  async findMatchingWorkTypes(name, threshold = 0.7) {
    try {
      // Generate cache key
      const cacheKey = `workType:${name}:${threshold}`;

      // Check cache first
      const cachedResult = this.workTypeCache.get(cacheKey);
      if (cachedResult) {
        logger.debug(`Cache hit for work type "${name}"`);
        return cachedResult;
      }

      logger.debug(`Cache miss for work type "${name}", fetching from database`);

      const query = `
        SELECT id, name, parent_bucket, measurement_type, suggested_units,
               unit_cost_material, unit_cost_labor, productivity_unit_per_hr,
               similarity(name, :name) AS score
        FROM work_types
        WHERE similarity(name, :name) > :threshold
        ORDER BY score DESC
        LIMIT 1
      `;

      const results = await sequelize.query(query, {
        replacements: { name, threshold },
        type: sequelize.QueryTypes.SELECT
      });

      if (results.length === 0) {
        // Cache null result to avoid repeated DB queries for non-existent work types
        this.workTypeCache.set(cacheKey, null);
        return null;
      }

      // Get the matching work type
      const workType = results[0];

      // Get tags for the work type
      const tags = await WorkTypeTag.findAll({
        where: { work_type_id: workType.id }
      });

      workType.tags = tags.map(tag => tag.tag);

      // Cache the result
      this.workTypeCache.set(cacheKey, workType);

      return workType;
    } catch (error) {
      logger.error(`Error finding matching work types for "${name}":`, error);
      return null;
    }
  }

  buildScope(assessment) {
    return {
      messages: [
        { role: 'system',
          content:
            'You are a construction estimation assistant. ' +
            'Read the assessment and return a JSON object with two arrays: ' +
            '`requiredMeasurements` (strings) and `questions` (strings).' },
        { role: 'user', content: `Assessment:\n${assessment}` },
        { role: 'user', content: 'Return JSON {"requiredMeasurements":[],"questions":[]}' }
      ],
      max_tokens: 600,
      temperature: 0.2,
    };
  }

  async buildDraft(scopedAssessment, opts = {}) {
    // Handle both string and object inputs
    const userContent = typeof scopedAssessment === 'string'
      ? scopedAssessment
      : JSON.stringify(scopedAssessment);

    // Extract potential work type names for cost reference
    let systemContent = 'You are a construction estimate assistant. ' +
      'Respond **only** with a JSON array of line item objects. ' +
      'Each object **must** have exactly these properties: ' +
      '`name` (string), `measurementType` (one of "AREA", "LINEAR", "QUANTITY"), ' +
      '`quantity` (number), and `unitPrice` (number).';

    // Add cost and safety guidance if available
    try {
      // Get work types from the assessment payload if available
      const workTypeIds = [];
      if (opts.payload && opts.payload.assessment && opts.payload.assessment.workTypes) {
        // If assessment includes explicitly tagged work types, use those first
        if (Array.isArray(opts.payload.assessment.workTypes) && opts.payload.assessment.workTypes.length > 0) {
          workTypeIds.push(...opts.payload.assessment.workTypes);
          logger.info(`Using ${workTypeIds.length} explicit work types from assessment`);
        }
      }
      
      // If no explicit work types, extract potential work type names from the assessment text
      const workTypeNames = workTypeIds.length > 0 ? [] : this.extractWorkTypeNames(userContent);

      // Process either explicit IDs or extracted names
      let references = [];
      if (workTypeIds.length > 0) {
        // Fetch work types by ID
        const workTypes = await WorkType.findAll({
          where: { id: workTypeIds },
          include: ['tags']
        });
        
        references = workTypes.map(wt => ({
          id: wt.id,
          name: wt.name,
          measurement_type: wt.measurement_type,
          unit_cost_material: wt.unit_cost_material,
          unit_cost_labor: wt.unit_cost_labor,
          tags: wt.tags ? wt.tags.map(t => t.tag) : []
        }));
        
        logger.info(`Found ${references.length} work types by ID`);
      } else if (workTypeNames.length > 0) {
        // Get cost and safety reference for the work types by similarity
        references = await Promise.all(
          workTypeNames.map(name => this.findMatchingWorkTypes(name))
        );

        // Filter out null results
        const validReferences = references.filter(ref => ref !== null);

        // Add cost guidance to the system prompt
        if (validReferences.length > 0) {
          systemContent += '\n\nHere are some reference costs and safety guidelines for your consideration:';

          for (const ref of validReferences) {
            // Add cost reference if available
            if (ref.unit_cost_material !== null || ref.unit_cost_labor !== null) {
              systemContent += `\n\nFor "${ref.name}" (${ref.measurement_type}):`;

              if (ref.unit_cost_material !== null && ref.unit_cost_labor !== null) {
                const totalCost = parseFloat(ref.unit_cost_material) + parseFloat(ref.unit_cost_labor);

                systemContent += `
"reference_cost": {
  "material": ${ref.unit_cost_material},
  "labor": ${ref.unit_cost_labor},
  "total": ${totalCost}
}`;
              } else if (ref.unit_cost_material !== null) {
                systemContent += `
"reference_cost": {
  "material": ${ref.unit_cost_material}
}`;
              } else if (ref.unit_cost_labor !== null) {
                systemContent += `
"reference_cost": {
  "labor": ${ref.unit_cost_labor}
}`;
              }
            }

            // Add safety tags if available
            if (ref.tags && ref.tags.length > 0) {
              systemContent += `\n"safety_tags": [${ref.tags.map(tag => `"${tag}"`).join(', ')}]`;

              // Add specific safety guidance for certain tags
              const safetyGuidance = [];

              if (ref.tags.includes('asbestos')) {
                safetyGuidance.push('When dealing with asbestos, always add appropriate PPE and testing as line items.');
              }

              if (ref.tags.includes('electrical')) {
                safetyGuidance.push('For electrical work, ensure licensed electrician labor is specified.');
              }

              if (ref.tags.includes('permit-required')) {
                safetyGuidance.push('Include permit fees as a separate line item.');
              }

              if (safetyGuidance.length > 0) {
                systemContent += `\n"safety_guidance": [${safetyGuidance.map(guidance => `"${guidance}"`).join(', ')}]`;
              }
            }
          }
        }
      }
    } catch (error) {
      logger.error('Error adding cost/safety reference to prompt:', error);
      // Continue without cost/safety reference if there's an error
    }

    return {
      messages: [
        { role: 'system', content: systemContent },
        { role: 'user', content: userContent }
      ],
      max_tokens: 1200,
      temperature: opts.temperature ?? 0.5,
    };
  }

  /**
   * Extract potential work type names from the assessment
   * @param {string} assessment - Assessment content
   * @returns {Array<string>} - Array of potential work type names
   */
  extractWorkTypeNames(assessment) {
    try {
      // Extract text that looks like common work types
      const workTypePatterns = [
        /\b(install|replace|repair|remove)\s+([a-z\s-]+)\b/gi,
        /\b([a-z\s-]+)\s+(installation|replacement|repair|removal)\b/gi,
        /\b(subfloor|drywall|roof|siding|window|door|floor|wall|ceiling|bath|kitchen)\s+([a-z\s-]+)\b/gi,
        /\b([a-z\s-]+)\s+(subfloor|drywall|roof|siding|window|door|floor|wall|ceiling|bath|kitchen)\b/gi
      ];

      const workTypeNames = [];

      // Apply each pattern and collect matches
      for (const pattern of workTypePatterns) {
        const matches = assessment.match(pattern);

        if (matches) {
          workTypeNames.push(...matches);
        }
      }

      // Deduplicate and return
      return [...new Set(workTypeNames)];
    } catch (error) {
      logger.error('Error extracting work type names:', error);
      return [];
    }
  }

  /**
   * Parse with retry and better error handling
   * @param {string} raw - Raw text from LLM response
   * @param {object} schema - Zod schema to validate against
   * @param {string} type - Type of parsing (scope or draft)
   * @returns {object} - Parsed and validated object
   * @throws {Error} - If parsing fails
   */
  parseWithRetry(raw, schema, type) {
    try {
      // Try to parse JSON and validate against schema
      return schema.parse(JSON.parse(raw));
    } catch (e) {
      logger.warn(`Failed to parse ${type} response: ${e.message}`);
      logger.debug(`Raw response: ${raw}`);

      // Attempt to extract JSON from text (sometimes LLM adds explanations)
      try {
        // Try to find JSON in code blocks first
        let jsonMatch = raw.match(/```(?:json)?\s*([\s\S]*?)\s*```/);
        if (jsonMatch) {
          logger.info(`Found JSON in code block, attempting to parse`);
          return schema.parse(JSON.parse(jsonMatch[1]));
        }

        // Try to find JSON objects or arrays
        jsonMatch = raw.match(/\{[\s\S]*\}/m) || raw.match(/\[[\s\S]*\]/m);
        if (jsonMatch) {
          logger.info(`Attempting to extract JSON from response`);
          return schema.parse(JSON.parse(jsonMatch[0]));
        }

        // Last resort: try to clean up the response and parse it
        logger.info(`Attempting to clean up and parse response`);
        const cleanedJson = this.cleanupJsonString(raw);
        if (cleanedJson) {
          return schema.parse(JSON.parse(cleanedJson));
        }
      } catch (extractError) {
        logger.error(`JSON extraction failed: ${extractError.message}`);
      }

      // If we get here, all parsing attempts failed
      throw new Error(`Invalid ${type} format: ${e.message}. Raw response: ${raw.substring(0, 200)}...`);
    }
  }

  parseScope(text) {
    try {
      return this.parseWithRetry(text, ScopeSchema, 'scope');
    } catch (error) {
      logger.error('Error parsing scope response', error);
      throw error;
    }
  }

  /**
   * Attempt to clean up a malformed JSON string
   * @param {string} jsonString - The potentially malformed JSON string
   * @returns {string|null} - Cleaned JSON string or null if cleaning failed
   */
  cleanupJsonString(jsonString) {
    try {
      // Remove any non-JSON text before the first [ or {
      let cleaned = jsonString.replace(/^[\s\S]*?([\[\{])/, '$1');

      // Remove any non-JSON text after the last ] or }
      cleaned = cleaned.replace(/([\]\}])[\s\S]*$/, '$1');

      // Replace any invalid escape sequences
      cleaned = cleaned.replace(/\\([^"\\bfnrtu])/g, '$1');

      // Fix missing quotes around property names
      cleaned = cleaned.replace(/(\{|,)\s*([a-zA-Z0-9_]+)\s*:/g, '$1"$2":');

      // Fix trailing commas in arrays and objects
      cleaned = cleaned.replace(/,\s*([\]\}])/g, '$1');

      // Validate that the cleaned string is valid JSON
      JSON.parse(cleaned);

      return cleaned;
    } catch (error) {
      logger.error(`Failed to clean up JSON string: ${error.message}`);
      return null;
    }
  }

  parseDraft(text) {
    try {
      return this.parseWithRetry(text, DraftSchema, 'draft');
    } catch (error) {
      logger.error('Error parsing draft response', error);
      throw error;
    }
  }
}

module.exports = new PromptEngine();