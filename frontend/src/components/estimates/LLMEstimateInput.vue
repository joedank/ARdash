<template>
  <div class="p-4 border rounded-lg shadow-lg bg-white dark:bg-gray-800 relative z-50 mt-16"> <!-- Added z-50, relative, and mt-16 -->
    <h3 class="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">Service Estimate Generator</h3>

    <!-- Initial Input Section -->
    <div v-if="currentStep === 'initial'" class="space-y-4">
      <div>
        <label for="description" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Project Description
        </label>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-2">Describe the repair work needed, and we'll generate an estimate based on our repair services. This tool focuses only on labor and services, not physical products.</p>
        <textarea
          id="description"
          v-model="description"
          rows="4"
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
          placeholder="e.g., Replace 2000 sq ft roof with architectural shingles, repair minor decking damage..."
          required
          :disabled="loading"
        ></textarea>
      </div>

      <div>
        <label for="targetPrice" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Target Estimate Price (Optional)
        </label>
        <input
          type="number"
          id="targetPrice"
          v-model.number="targetPrice"
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
          placeholder="e.g., 15000"
          min="0"
          step="any"
          :disabled="loading"
        />
      </div>
      
      <!-- Estimate Generation Controls -->
      <div class="mb-4 border rounded-lg p-4 bg-gray-50 dark:bg-gray-800">
        <h3 class="text-sm font-semibold mb-2">Estimate Generation Controls</h3>
        
        <div class="mb-4">
          <label class="block text-xs font-medium mb-1">Estimation Mode</label>
          <select 
            v-model="estimationMode" 
            class="w-full px-3 py-1 text-sm border rounded-md bg-white dark:bg-gray-700"
          >
            <option value="replace-focused">Replace-Focused (prioritize replacements)</option>
            <option value="repair-focused">Repair-Focused (prioritize repairs)</option>
            <option value="maintenance-focused">Maintenance-Focused (preventative care)</option>
            <option value="comprehensive">Comprehensive (complete solution)</option>
          </select>
          <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">{{getModeDescription()}}</p>
        </div>
        
        <div>
          <div class="flex justify-between items-center mb-1">
            <label class="block text-xs font-medium">Aggressiveness: {{ Math.round(aggressiveness * 100) }}%</label>
            <span class="text-xs text-gray-500">
              {{ aggressiveness < 0.3 ? 'Conservative' : aggressiveness > 0.7 ? 'Aggressive' : 'Balanced' }}
            </span>
          </div>
          <input 
            type="range" 
            v-model.number="aggressiveness" 
            min="0" 
            max="1" 
            step="0.05"
            class="w-full"
          />
          <div class="flex justify-between text-xs text-gray-500">
            <span>Conservative</span>
            <span>Balanced</span>
            <span>Aggressive</span>
          </div>
        </div>
      </div>

      <!-- Import From Assessment Option -->
      <div class="mt-4 p-3 bg-indigo-50 dark:bg-indigo-900/20 rounded-md border border-indigo-200 dark:border-indigo-800">
        <div class="flex items-center mb-2">
          <div class="flex-shrink-0">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-indigo-600 dark:text-indigo-400" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V7z" clip-rule="evenodd" />
            </svg>
          </div>
          <h4 class="ml-2 text-sm font-medium text-indigo-700 dark:text-indigo-300">Import From Assessment</h4>
        </div>
        
        <p class="text-xs text-indigo-600 dark:text-indigo-400 mb-3">
          Use data from an existing assessment to enhance this estimate's accuracy.
        </p>
        
        <div v-if="!loading">
          <div v-if="loadingProjects" class="text-center py-2">
            <svg class="animate-spin h-5 w-5 text-indigo-600 mx-auto" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <p class="text-xs mt-1">Loading projects...</p>
          </div>
          
          <div v-else-if="!useAssessmentData" class="flex items-center space-x-2">
            <select
              v-model="assessmentProjectId"
              class="flex-grow px-3 py-1 text-sm border border-indigo-300 dark:border-indigo-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-indigo-900/30 dark:text-indigo-200"
              :disabled="availableProjects.length === 0"
            >
              <option value="" disabled>Select a project</option>
              <option v-for="project in availableProjects" :key="project.id" :value="project.id">
                {{ project.client?.displayName || 'Unknown Client' }} - {{ formatDate(project.scheduledDate) }}
              </option>
            </select>
            
            <button
              @click="fetchAssessmentData"
              :disabled="!assessmentProjectId"
              class="px-3 py-1 text-xs font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Import
            </button>
            
            <button
              @click="loadProjects"
              class="p-1 text-xs rounded-md text-indigo-600 hover:text-indigo-800 focus:outline-none"
              title="Refresh project list"
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
            </button>
          </div>
        </div>
        
        <!-- Show when assessment data is loaded -->
        <div v-if="useAssessmentData && assessmentData" class="mt-3 text-xs">
          <div class="flex justify-between items-center bg-indigo-100 dark:bg-indigo-800/50 py-1 px-2 rounded">
            <span class="font-medium text-indigo-700 dark:text-indigo-300">
              Using assessment data from project {{ getProjectName(assessmentProjectId) }}
            </span>
            <button 
              @click="clearAssessmentData" 
              class="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300"
              title="Remove assessment data"
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          <ul class="mt-1 list-disc list-inside pl-1 text-indigo-600 dark:text-indigo-400">
            <li v-if="assessmentData.measurements && assessmentData.measurements.length">{{ assessmentData.measurements.length }} measurement(s) available</li>
            <li v-if="assessmentData.conditions && assessmentData.conditions.length">{{ assessmentData.conditions.length }} condition(s) recorded</li>
            <li v-if="assessmentData.materials && assessmentData.materials.length">{{ assessmentData.materials.length }} material(s) specified</li>
            <li v-if="assessmentData.scope">Project scope available</li>
            <li v-if="assessmentData.formattedMarkdown"><span class="text-green-600 dark:text-green-400">✓</span> Enhanced assessment data formatting</li>
          </ul>
          
          <!-- Direct Assessment Estimate Option -->
          <div class="mt-2 bg-green-50 dark:bg-green-900/30 border border-green-200 dark:border-green-800 rounded-md p-2">
            <button 
              @click="generateDirectFromAssessment" 
              :disabled="loading"
              class="w-full px-2 py-1 text-xs font-medium rounded-md text-white bg-green-600 hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
            >
              <span v-if="loading && directAssessmentMode">
                <svg class="animate-spin h-3 w-3 mr-1" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Processing...
              </span>
              <span v-else>
                <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3 mr-1 inline" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
                Generate Estimate Directly from Assessment
              </span>
            </button>
            <p class="text-xs mt-1 text-green-700 dark:text-green-300">Skip analysis and directly generate an estimate from assessment data using enhanced formatting.</p>
          </div>
        </div>
      </div>

      <div class="flex justify-end">
        <button
          @click="startAnalysis"
          :disabled="loading || !description.trim()"
          class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <span v-if="loading">Analyzing...</span>
          <span v-else>Start Analysis</span>
        </button>
      </div>
    </div>

    <!-- Results and Clarification Input Area -->
    <div v-if="currentStep === 'clarification' && (analysisResult || error || loading)" class="mt-6 p-4 border rounded-md bg-gray-50 dark:bg-gray-700">
      <h4 class="text-md font-semibold mb-2 text-gray-800 dark:text-gray-200">
        {{ loading && !analysisResult ? 'Analyzing...' : 'Analysis Results & Next Steps' }}
      </h4>
      <div v-if="loading && !analysisResult" class="relative">
        <div class="absolute inset-0 bg-gray-100 dark:bg-gray-800 opacity-75 flex items-center justify-center">
          <div class="text-center">
            <svg class="animate-spin h-10 w-10 text-indigo-600 mx-auto" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <p class="mt-3 text-indigo-700 dark:text-indigo-400 font-medium">
              {{ loadingMessage }}
            </p>
            <p v-if="loadingTime > 15" class="text-sm text-gray-600 dark:text-gray-400 mt-2">
              Processing complex data. This may take a moment...
            </p>
            <div v-if="loadingTime > 30" class="mt-3 h-2 w-48 mx-auto bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
              <div class="h-full bg-indigo-600 dark:bg-indigo-500 rounded-full" 
                   :style="{width: `${Math.min(100, loadingTime * 1.5)}%`}"></div>
            </div>
          </div>
        </div>
      </div>
      <div v-else-if="error" class="text-red-600 dark:text-red-400">
        <p><strong>Error:</strong> {{ error }}</p>
        <pre v-if="rawErrorContent" class="mt-2 text-xs bg-red-100 dark:bg-red-900 p-2 rounded overflow-auto">{{ rawErrorContent }}</pre>
         <button @click="resetForm" class="mt-4 px-3 py-1 border border-gray-300 rounded-md text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600">
           Start Over
         </button>
      </div>
      <div v-else-if="analysisResult" class="space-y-4 text-sm text-gray-700 dark:text-gray-300">
        <!-- Display assessment data use indicator -->
        <div v-if="analysisResult.usedAssessmentData" class="p-2 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-md">
          <div class="flex items-start">
            <div class="flex-shrink-0">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-600 dark:text-green-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-2">
              <p class="text-sm font-medium text-green-700 dark:text-green-300">
                Assessment data incorporated
              </p>
              <p class="text-xs text-green-600 dark:text-green-400">
                This analysis includes data from your existing project assessment, which helps provide more accurate estimates.
              </p>
            </div>
          </div>
        </div>

        <!-- Repair Type Display -->
        <div v-if="analysisResult.repair_type" class="p-3 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-md">
          <p class="text-sm font-medium text-blue-700 dark:text-blue-300">
            Repair Type: <span class="font-semibold">{{ formatKey(analysisResult.repair_type) }}</span>
          </p>
        </div>

        <!-- Required Measurements Inputs -->
        <div v-if="analysisResult.required_measurements?.length">
          <strong class="block mb-2 text-base">Please provide the following measurements:</strong>
          <div v-for="measurement in analysisResult.required_measurements" :key="measurement" class="mb-3">
            <label :for="`measurement-${measurement}`" class="block text-sm font-medium mb-1">
              {{ formatKey(measurement) }}
            </label>
            <input
              :id="`measurement-${measurement}`"
              type="number"
              v-model.number="measurementInputs[measurement]"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
              :placeholder="`Enter ${formatKey(measurement)}`"
              min="0"
              step="any"
            />
            <!-- TODO: Add unit hints if possible -->
          </div>
        </div>

        <!-- Clarifying Questions Inputs -->
        <div v-if="analysisResult.clarifying_questions?.length">
          <strong class="block mb-2 text-base">Please answer the following questions:</strong>
          <div v-for="(question, index) in analysisResult.clarifying_questions" :key="index" class="mb-3">
            <label :for="`question-${index}`" class="block text-sm font-medium mb-1">
              {{ question }}
            </label>
            <input
              :id="`question-${index}`"
              type="text"
              v-model="questionAnswers[index]"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:text-gray-200 sm:text-sm"
              placeholder="Your answer"
            />
          </div>
        </div>

        <!-- Suggested Services (Display Only For Now) -->
         <div v-if="analysisResult.required_services?.length">
          <strong class="block text-base">Required Services:</strong>
          <ul class="list-disc list-inside ml-4 text-gray-600 dark:text-gray-400">
            <li v-for="s in analysisResult.required_services" :key="s">{{ formatKey(s) }}</li>
          </ul>
          <p class="text-xs italic mt-1 text-gray-500 dark:text-gray-400">(These will be matched to your service catalog later)</p>
        </div>

        <!-- Submit Details Button -->
        <div class="flex justify-end pt-4 border-t border-gray-200 dark:border-gray-600">
           <button
             @click="resetForm"
             class="inline-flex items-center px-4 py-2 mr-3 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
           >
             Start Over
           </button>
           <button
             @click="submitDetails"
             :disabled="loading"
             class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed"
           >
                 <span v-if="loading">{{ loadingTime > 15 ? 'This might take a minute or two...' : 'Submitting...' }}</span>
             <span v-else>Submit Details</span>
           </button>
         </div>
      </div>
    </div>

    <!-- Product Matching Review Component -->
    <div v-if="currentStep === 'service-matching' && generatedLineItems && generatedLineItems.length > 0">
      <ProductMatchReview
        :lineItems="generatedLineItems"
        @back="currentStep = 'clarification'"
        @finished="handleMatchingFinished"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import estimateService from '@/services/estimates.service.js';
import projectsService from '@/services/projects.service.js';
import { useToast } from 'vue-toastification';
import ProductMatchReview from './ProductMatchReview.vue';
import { toFrontend } from '@/utils/field-adapter.js';

const router = useRouter();

const toast = useToast();

// Initial Input State
const description = ref('');
const targetPrice = ref(null);
const aggressiveness = ref(0.6);
const estimationMode = ref('replace-focused');

// Assessment Import State
const assessmentProjectId = ref('');
const assessmentData = ref(null);
const useAssessmentData = ref(false);
const availableProjects = ref([]);
const loadingProjects = ref(false);
const directAssessmentMode = ref(false);

// Workflow State
const currentStep = ref('initial'); // 'initial', 'clarification', 'service-matching', 'finalize'

// Analysis State
const loading = ref(false);
const loadingTime = ref(0); // Track loading time in seconds
const loadingTimer = ref(null); // Timer reference
const analysisResult = ref(null); // Stores the object from the backend { required_measurements: [], clarifying_questions: [], required_services: [] }
const error = ref(null);
const rawErrorContent = ref(null);
const loadingMessage = ref('Processing description...');

// Computed property to update loading message based on time elapsed
const updateLoadingMessage = () => {
  if (directAssessmentMode.value) {
    loadingMessage.value = 'Generating estimate from assessment...';
  } else if (loadingTime.value > 45) {
    loadingMessage.value = 'Still working... complex analysis in progress';
  } else if (loadingTime.value > 30) {
    loadingMessage.value = 'Analyzing requirements... this is taking longer than usual';
  } else if (loadingTime.value > 15) {
    loadingMessage.value = 'Processing your description...';
  } else {
    loadingMessage.value = 'Processing description...';
  }
};

// Clarification Input State
const measurementInputs = ref({}); // e.g., { roof_square_footage: 1500, roof_pitch: 6 }
const questionAnswers = ref({}); // e.g., { 0: "Decking is good", 1: "No skylights" }

 // Service Matching State
const generatedLineItems = ref([]);
const finalEstimateData = ref(null);

// Initialize projects list when component is mounted
onMounted(() => {
  loadProjects();
});

// --- Methods ---

/**
 * Load available assessment projects
 */
const loadProjects = async () => {
  loadingProjects.value = true;
  
  try {
    // Call projects service to get assessment projects
    const response = await projectsService.getAllProjects({ type: 'assessment' });
    
    if (response.success && response.data) {
      // Normalize data from snake_case to camelCase
      const normalizedProjects = Array.isArray(response.data) 
        ? response.data.map(project => toFrontend(project))
        : [];
      
      // Filter to only active or pending assessment projects
      availableProjects.value = normalizedProjects
        .filter(p => p.type === 'assessment' && ['pending', 'in_progress'].includes(p.status))
        .sort((a, b) => new Date(b.scheduledDate) - new Date(a.scheduledDate)); // Now camelCase will work correctly
      
      if (availableProjects.value.length === 0) {
        toast.info('No assessment projects found.');
      }
    } else {
      toast.error(response.message || 'Failed to load projects');
    }
  } catch (err) {
    console.error('Error loading projects:', err);
    toast.error('Failed to load assessment projects');
  } finally {
    loadingProjects.value = false;
  }
};

/**
 * Fetch assessment data from a project
 */
const fetchAssessmentData = async () => {
  if (!assessmentProjectId.value) {
    toast.error('Please select a project');
    return;
  }
  
  loading.value = true;
  error.value = null;
  
  try {
    const response = await estimateService.getAssessmentData(assessmentProjectId.value);
    
    if (response.success && response.data) {
      assessmentData.value = response.data;
      useAssessmentData.value = true;
      toast.success('Assessment data imported successfully');
    } else {
      toast.error(response.message || 'Failed to import assessment data');
    }
  } catch (err) {
    console.error('Error fetching assessment data:', err);
    const errorMessage = err.response?.data?.message || err.message || 'Failed to fetch assessment data';
    toast.error(errorMessage);
  } finally {
    loading.value = false;
  }
};

/**
 * Get a formatted project name for display
 * @param {string} projectId - Project ID to look up
 * @returns {string} - Formatted project name
 */
const getProjectName = (projectId) => {
  const project = availableProjects.value.find(p => p.id === projectId);
  if (!project) return projectId;
  
  const clientName = project.client?.displayName || 'Unknown Client'; // Use camelCase
  const date = formatDate(project.scheduledDate); // Use camelCase
  
  return `${clientName} - ${date}`;
};

/**
 * Format a date for display
 * @param {string} dateString - ISO date string
 * @returns {string} - Formatted date
 */
const formatDate = (dateString) => {
  if (!dateString) return 'Unknown Date';
  
  const date = new Date(dateString);
  return date.toLocaleDateString();
};

/**
 * Get a description for the selected estimation mode
 * @returns {string} - Mode description
 */
const getModeDescription = () => {
  switch(estimationMode.value) {
    case 'replace-focused':
      return 'Prioritizes replacement over repair for damaged components.';
    case 'repair-focused':
      return 'Emphasizes repair solutions when possible, with fewer replacements.';
    case 'maintenance-focused':
      return 'Focuses on preventative maintenance to avoid future issues.';
    case 'comprehensive':
      return 'Includes all necessary work: repairs, replacements, and maintenance.';
    default:
      return '';
  }
};

/**
 * Clear the imported assessment data
 */
const clearAssessmentData = () => {
  assessmentData.value = null;
  useAssessmentData.value = false;
  toast.info('Assessment data removed');
};

const startAnalysis = async () => {
  if (!description.value.trim()) {
    toast.error('Please enter a project description.');
    return;
  }

  // Reset state for new analysis
  loading.value = true;
  analysisResult.value = null;
  error.value = null;
  rawErrorContent.value = null;
  measurementInputs.value = {}; // Clear previous measurement inputs
  questionAnswers.value = {}; // Clear previous answers
  currentStep.value = 'clarification'; // Update workflow step
  
  // Start loading timer
  loadingTime.value = 0;
  clearInterval(loadingTimer.value);
  loadingTimer.value = setInterval(() => {
    loadingTime.value++;
    updateLoadingMessage();
  }, 1000);

  try {
    const payload = {
      description: description.value.trim(),
      targetPrice: targetPrice.value && targetPrice.value > 0 ? targetPrice.value : undefined,
    };
    
    // Include assessment data if available
    if (useAssessmentData.value && assessmentData.value) {
      payload.assessmentData = assessmentData.value;
      // Add enhanced parameters when using assessment data
      payload.assessmentOptions = {
        aggressiveness: aggressiveness.value,
        mode: estimationMode.value,
        debug: false // Set to true for debugging
      };
    }
    
    const response = await estimateService.analyzeScope(payload);

    if (response.success && response.data) {
      analysisResult.value = response.data;
      // Pre-fill input objects based on analysis results
      initializeInputObjects();
      toast.success('Analysis complete. Please provide the required details.');
    } else {
      error.value = response.message || 'Analysis failed.';
      rawErrorContent.value = response.rawContent;
      toast.error(error.value);
    }
  } catch (err) {
    console.error('Error calling analysis API:', err);
    error.value = err.response?.data?.message || err.message || 'An unexpected error occurred during analysis.';
    rawErrorContent.value = err.response?.data?.rawContent;
    toast.error(error.value);
  } finally {
    loading.value = false;
    clearInterval(loadingTimer.value);
  }
};

// Initialize input refs based on analysis results
const initializeInputObjects = () => {
  if (!analysisResult.value) return;

  measurementInputs.value = (analysisResult.value.required_measurements || []).reduce((acc, key) => {
    acc[key] = null; // Initialize with null or appropriate default
    return acc;
  }, {});

  questionAnswers.value = (analysisResult.value.clarifying_questions || []).reduce((acc, _, index) => {
    acc[index] = ''; // Initialize with empty string
    return acc;
  }, {});
};

// Submits the collected measurements and answers to the backend
const submitDetails = async () => {
  loading.value = true;
  error.value = null;
  rawErrorContent.value = null; // Clear previous raw error content
  toast.info('Submitting clarification details...');
  
  // Start loading timer
  loadingTime.value = 0;
  clearInterval(loadingTimer.value);
  loadingTimer.value = setInterval(() => {
    loadingTime.value++;
  }, 1000);

  try {
    // Construct the payload
    const payload = {
      measurements: measurementInputs.value,
      answers: questionAnswers.value,
      originalDescription: description.value, // Send original description for context
      analysisResult: analysisResult.value // Send original analysis result for context
    };

    // Call the backend service
    const response = await estimateService.submitClarifications(payload);

    if (response.success && response.data) {
      toast.success('Details processed successfully!');
      
      // Store the line items for service matching
      if (response.data.line_items && response.data.line_items.length > 0) {
        generatedLineItems.value = response.data.line_items;
        
        // Move to service matching step
        currentStep.value = 'service-matching';
      } else {
        error.value = 'No line items were generated. Please try again.';
        toast.error(error.value);
      }
    } else {
      // Handle specific errors reported by the backend
      error.value = response.message || 'Failed to process details.';
      rawErrorContent.value = response.rawContent; // Capture raw content if available
      toast.error(error.value);
    }
  } catch (err) {
    console.error('Error calling clarification API:', err);
    error.value = err.response?.data?.message || err.message || 'An unexpected error occurred while submitting details.';
    rawErrorContent.value = err.response?.data?.rawContent;
    toast.error(error.value);
  } finally {
    loading.value = false;
    clearInterval(loadingTimer.value);
  }
};

// Reset the entire form to initial state
const resetForm = () => {
  description.value = '';
  targetPrice.value = null;
  analysisResult.value = null;
  error.value = null;
  rawErrorContent.value = null;
  measurementInputs.value = {};
  questionAnswers.value = {};
  generatedLineItems.value = [];
  finalEstimateData.value = null;
  loading.value = false;
  loadingTime.value = 0;
  clearInterval(loadingTimer.value);
  currentStep.value = 'initial';
  // Don't reset assessment data - it might be used for another estimate
};


 // Handle finished event from ProductMatchReview component
const emit = defineEmits(['close']);

const handleMatchingFinished = async (data) => {
  finalEstimateData.value = data;
  
  toast.success('Product matching completed. Creating estimate...');
  
  // Navigate to create estimate page with the line items
  await router.push({
    path: '/invoicing/create-estimate',
    query: {
      prefill: 'true',
      items: encodeURIComponent(JSON.stringify(data.lineItems))
    }
  });
  
  // Close the generator modal after navigation
  emit('close');
};

/**
* Generate estimate directly from assessment data using enhanced formatting
*/
const generateDirectFromAssessment = async () => {
  if (!assessmentData.value) {
    toast.error('Assessment data is required');
    return;
  }

  loading.value = true;
  directAssessmentMode.value = true;
  clearError(); // Use the error handler to clear errors
  currentStep.value = 'clarification'; // Move to next step for result display

  // Start loading timer for UX feedback
  loadingTime.value = 0;
  clearInterval(loadingTimer.value);
  loadingTimer.value = setInterval(() => {
    loadingTime.value++;
    updateLoadingMessage();
  }, 1000);

  try {
    // Show detailed loading feedback
    toast.info('Generating estimate using enhanced assessment data...');

    const result = await estimateService.generateFromAssessment(assessmentData.value, {
      aggressiveness: aggressiveness.value,
      mode: estimationMode.value,
      debug: false
    });

    if (result.success && result.data) {
      toast.success('Estimate generated successfully from assessment data');

      // Convert to line item format expected by the product matching component (use camelCase)
      const lineItems = result.data.map(item => ({
        description: item.description,
        product_name: item.description, // Keep product_name as it might be expected downstream
        quantity: item.quantity,
        unit: item.unit,
        unit_price: item.unitPrice, // Use camelCase unitPrice
        total: item.total,
        sourceType: item.sourceType, // Use camelCase sourceType
        sourceId: item.sourceId // Use camelCase sourceId
      }));
      
      // Add more detailed feedback on what was found
      if (lineItems.length > 0) {
        toast.info(`Generated ${lineItems.length} line items from assessment data`);
      }
        
      // Process line items for service matching
      generatedLineItems.value = lineItems;
      currentStep.value = 'service-matching';
    } else {
      error.value = result.message || 'Failed to generate estimate from assessment data';
      toast.error(error.value);
      
      // Show diagnostic information if available
      if (result.diagnosticCode) {
        console.error(`Diagnostic code: ${result.diagnosticCode}`);
      }
    }
  } catch (err) {
    handleError(err, 'Error generating estimate from assessment');
    
    // Show more detailed error messaging if available
    if (err.response?.data?.error) {
      console.error('Server error details:', err.response.data.error);
    }
  } finally {
    loading.value = false;
    directAssessmentMode.value = false;
    clearInterval(loadingTimer.value);
  }
};


// Helper to format snake_case keys for display
const formatKey = (key) => {
  if (!key) return '';
  return key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
};

</script>

<style scoped>
/* Add any component-specific styles here */
</style>