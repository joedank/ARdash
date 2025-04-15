/**
 * Fix imports script for the frontend
 * This script creates symlinks for missing service files to maintain compatibility
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Get the directory name in ESM
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Services directory path
const servicesDir = path.join(__dirname, 'src', 'services');

// Create estimate.service.js with proper exports
try {
  console.log('Creating estimate.service.js...');
  const targetPath = path.join(servicesDir, 'estimate.service.js');

  if (!fs.existsSync(targetPath)) {
    // Create a new file with proper exports
    const content = `// Re-export from estimates.service.js for backward compatibility
import { estimatesService } from './estimates.service.js';

// Export as estimateService for backward compatibility
export const estimateService = estimatesService;
`;

    fs.writeFileSync(targetPath, content);
    console.log('✅ Created estimate.service.js with proper exports');
  } else {
    console.log('⚠️ estimate.service.js already exists, skipping...');
  }
} catch (error) {
  console.error('❌ Error creating estimate.service.js:', error);
}

// Create assessment.service.js using projects.service.js as a base
try {
  console.log('Creating assessment.service.js...');
  const targetPath = path.join(servicesDir, 'assessment.service.js');

  if (!fs.existsSync(targetPath)) {
    const content = `import api from './api.service';
import { toCamelCase, toSnakeCase } from '@/utils/casing';

// Assessment service for handling communication with the assessment API
const assessmentService = {
  // Get assessment data for an estimate
  async getAssessmentForEstimate(estimateId) {
    try {
      const response = await api.get(\`/api/assessment/for-estimate/\${estimateId}\`);
      return response.data;
    } catch (error) {
      console.error('Error fetching assessment for estimate:', error);
      return null; // Return null to allow the application to continue
    }
  }
};

export { assessmentService };
`;

    fs.writeFileSync(targetPath, content);
    console.log('✅ Created assessment.service.js');
  } else {
    console.log('⚠️ assessment.service.js already exists, skipping...');
  }
} catch (error) {
  console.error('❌ Error creating assessment.service.js:', error);
}

console.log('🎉 Import fixes complete!');
