<template>
  <div class="assessment-context p-4 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg">
    <h3 class="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">Assessment Data</h3>

    <!-- Loading state -->
    <div v-if="isLoading" class="flex items-center justify-center h-64">
      <svg class="animate-spin h-8 w-8 text-blue-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
    </div>

    <!-- Error state -->
    <div v-else-if="error" class="p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-900 rounded-md">
      <p class="text-red-700 dark:text-red-300">{{ error }}</p>
    </div>

    <!-- No data state -->
    <div v-else-if="!assessment || (!assessment.formattedMarkdown && !assessment.formattedData)" class="p-4 bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-900 rounded-md">
      <p class="text-yellow-700 dark:text-yellow-300">No formatted assessment data available.</p>
    </div>

    <!-- Assessment markdown content -->
    <div v-else class="assessment-content prose prose-sm dark:prose-invert">
      <!-- Render formatted assessment data -->
      <div v-html="processedMarkdown"></div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { marked } from 'marked';

const props = defineProps({
  assessment: {
    type: Object,
    required: true
  },
  activeSourceId: {
    type: String,
    default: null
  }
});

const emit = defineEmits(['highlightSource']);

// State
const isLoading = ref(false);
const error = ref(null);

// Watch for changes in activeSourceId from parent
watch(() => props.activeSourceId, (newSourceId) => {
  highlightElementById(newSourceId);
});

// Processed markdown with source IDs and highlighting
const processedMarkdown = computed(() => {
  if (!props.assessment) {
    return '';
  }

  // Use formattedMarkdown if available, otherwise try formattedData
  const markdownContent = props.assessment.formattedMarkdown || props.assessment.formattedData;

  if (!markdownContent) {
    return '';
  }

  // We'll use the marked package to render the markdown
  const renderer = new marked.Renderer();

  // Customize heading rendering to add source IDs with type safety
  renderer.heading = function(text = '', level) {
    // Convert text to string if it's an object and has a 'text' property
    if (typeof text === 'object' && text !== null && typeof text.text === 'string') {
      text = text.text;
    } else if (typeof text !== 'string') {
      console.warn('Invalid heading text passed to Markdown renderer:', text);
      text = String(text || '');
    }
    const escapedText = text.toLowerCase().replace(/[^\w]+/g, '-');
    const sourceId = `heading-${escapedText}`;

    return `<h${level} class="assessment-section" id="${sourceId}" data-source-id="${sourceId}">${text}</h${level}>`;
  };

  // Customize list item rendering to add source IDs with type safety
  renderer.listitem = function(text = '') {
    // Convert text to string if it's an object and has a 'text' property
    if (typeof text === 'object' && text !== null && typeof text.text === 'string') {
      text = text.text;
    } else if (typeof text !== 'string') {
      console.warn('Invalid list item text passed to Markdown renderer:', text);
      text = String(text || '');
    }
    // Extract potential measurement or condition
    const sourceMatch = text.match(/(.*?)(?:\s→\s(.*))?$/);

    if (sourceMatch) {
      const content = sourceMatch[1];
      const recommendation = sourceMatch[2] || '';

      // Generate sourceId from content
      const sourceId = generateSourceId(content);

      // Return item with data attributes for linking
      return `<li class="assessment-item" id="${sourceId}" data-source-id="${sourceId}" data-recommendation="${recommendation}">${content}${recommendation ? ` <span class="text-blue-600 dark:text-blue-400">→ ${recommendation}</span>` : ''}</li>`;
    }

    return `<li>${text}</li>`;
  };

  // Set options for marked
  const options = {
    renderer: renderer,
    gfm: true,
    breaks: true
  };

  // Convert markdown to HTML with our custom renderer
  try {
    // Use formattedMarkdown if available, otherwise try formattedData
    const markdownContent = props.assessment.formattedMarkdown || props.assessment.formattedData;
    return marked.parse(markdownContent, options);
  } catch (error) {
    console.error('Error processing markdown:', error);
    return '<p class="text-red-500">Error rendering assessment content</p>';
  }
});

// --- Methods ---

/**
 * Generate a source ID from text content
 */
const generateSourceId = (text) => {
  // Convert text to a simplified form for use as an ID
  const base = text.toLowerCase()
    .replace(/[^\w]+/g, '-')
    .replace(/^-+|-+$/g, '');

  // Check if this has a measurement format (e.g., "South Wall Area: 240 sq ft")
  const measurementMatch = text.match(/([^:]+):\s*([\d.]+)\s*([\w\s]+)/);
  if (measurementMatch) {
    const area = measurementMatch[1].trim().toLowerCase().replace(/\s+/g, '-');
    return `measurement-${area}`;
  }

  // Check if this has a condition format
  const conditionMatch = text.match(/(.*?)\s*-\s*(Poor|Fair|Good|Excellent)/i);
  if (conditionMatch) {
    const item = conditionMatch[1].trim().toLowerCase().replace(/\s+/g, '-');
    return `condition-${item}`;
  }

  // Default ID format
  return `item-${base}`;
};

/**
 * Highlight element by its source ID
 */
const highlightElementById = (sourceId) => {
  if (!sourceId) {
    // Remove all highlights if no sourceId
    document.querySelectorAll('.assessment-item.highlight, .assessment-section.highlight').forEach(el => {
      el.classList.remove('highlight');
    });
    return;
  }

  // Remove existing highlights
  document.querySelectorAll('.assessment-item.highlight, .assessment-section.highlight').forEach(el => {
    el.classList.remove('highlight');
  });

  // Add highlight to matching element
  const element = document.getElementById(sourceId) || document.querySelector(`[data-source-id="${sourceId}"]`);
  if (element) {
    element.classList.add('highlight');

    // Scroll element into view
    element.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }
};

/**
 * Set up click handlers for assessment items after render
 */
const setupItemHandlers = () => {
  // Add click handlers to all assessment items and sections
  document.querySelectorAll('.assessment-item, .assessment-section').forEach(el => {
    el.addEventListener('click', () => {
      const sourceId = el.getAttribute('data-source-id');
      if (sourceId) {
        emit('highlightSource', sourceId);
      }
    });

    el.addEventListener('mouseenter', () => {
      el.classList.add('hover');
    });

    el.addEventListener('mouseleave', () => {
      el.classList.remove('hover');
    });
  });
};

// Setup click handlers after component is mounted and whenever assessment changes
watch(() => processedMarkdown.value, () => {
  setTimeout(() => {
    setupItemHandlers();
  }, 100);
});

onMounted(() => {
  setTimeout(() => {
    setupItemHandlers();
  }, 100);
});
</script>

<style scoped>
.assessment-context {
  font-size: 0.9rem;
  max-height: 500px;
  overflow-y: auto;
}

:deep(.assessment-item),
:deep(.assessment-section) {
  cursor: pointer;
  transition: background-color 0.2s ease;
  padding: 2px 4px;
  margin: -2px -4px;
  border-radius: 4px;
}

:deep(.assessment-item:hover),
:deep(.assessment-section:hover),
:deep(.assessment-item.hover),
:deep(.assessment-section.hover) {
  background-color: rgba(59, 130, 246, 0.1);
}

:deep(.assessment-item.highlight),
:deep(.assessment-section.highlight) {
  background-color: rgba(59, 130, 246, 0.2);
  border-left: 3px solid #3b82f6;
  padding-left: calc(4px - 3px);
}

/* Prose styles specific to assessment data */
:deep(.prose h1) {
  font-size: 1.5rem;
  margin-top: 1.5rem;
  margin-bottom: 0.5rem;
}

:deep(.prose h2) {
  font-size: 1.3rem;
  margin-top: 1.25rem;
  margin-bottom: 0.5rem;
}

:deep(.prose h3) {
  font-size: 1.1rem;
  margin-top: 1rem;
  margin-bottom: 0.5rem;
}

:deep(.prose ul) {
  margin-top: 0.5rem;
  margin-bottom: 0.5rem;
}

:deep(.prose li) {
  margin-top: 0.25rem;
  margin-bottom: 0.25rem;
}
</style>
