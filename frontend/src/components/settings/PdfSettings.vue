<template>
  <div class="pdf-settings">
    <h2 class="text-lg font-medium mb-4 text-gray-900 dark:text-white">PDF Settings</h2>
    
    <form @submit.prevent="saveSettings">
      <div class="space-y-6">
        <!-- Company Information -->
        <div>
          <h3 class="text-base font-medium text-gray-900 dark:text-white mb-3">Company Information</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label for="company_name" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Company Name
              </label>
              <input
                type="text"
                id="company_name"
                v-model="settings.companyName"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="Your Company Name"
              />
            </div>
            <div>
              <label for="company_address" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Company Address
              </label>
              <input
                type="text"
                id="company_address"
                v-model="settings.companyAddress"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="123 Business St, City, State 12345"
              />
            </div>
            <div>
              <label for="company_phone" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Phone Number
              </label>
              <input
                type="text"
                id="company_phone"
                v-model="settings.companyPhone"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="(555) 123-4567"
              />
            </div>
            <div>
              <label for="company_email" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Email Address
              </label>
              <input
                type="email"
                id="company_email"
                v-model="settings.companyEmail"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="info@yourcompany.com"
              />
            </div>
            <div>
              <label for="company_website" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Website
              </label>
              <input
                type="text"
                id="company_website"
                v-model="settings.companyWebsite"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="www.yourcompany.com"
              />
            </div>
            <div>
              <label for="company_logo" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Company Logo
              </label>
              <div class="flex items-start space-x-3">
                <div>
                  <input
                    type="file"
                    id="company_logo"
                    ref="logoInput"
                    @change="handleLogoUpload"
                    accept="image/*"
                    class="hidden"
                  />
                  <div class="flex items-center space-x-2">
                    <button
                      type="button"
                      @click="$refs.logoInput.click()"
                      class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                    >
                      Upload Logo
                    </button>
                    <button
                      v-if="logoPreview"
                      type="button"
                      @click="handleLogoRemove"
                      class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-red-600 dark:text-red-400 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                    >
                      Remove Logo
                    </button>
                    <span v-if="uploadStatus" class="ml-2 text-sm" :class="uploadStatus.type === 'success' ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'">
                      {{ uploadStatus.message }}
                    </span>
                  </div>
                </div>
                <div v-if="logoPreview" class="mt-1">
                  <img 
                    :src="logoPreview" 
                    alt="Company Logo Preview" 
                    class="h-16 w-auto object-contain"
                    @error="handleImageError"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- PDF Appearance -->
        <div>
          <h3 class="text-base font-medium text-gray-900 dark:text-white mb-3">PDF Appearance</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <!-- Primary Color -->
            <div>
              <label for="primary_color" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Primary Color
              </label>
              <div class="flex items-center gap-2">
                <ColorPicker
                  v-model="settings.primaryColor"
                  format="hex"
                  defaultColor="#3b82f6"
                  inputId="primary_color"
                  @change="(e) => handleColorChange(e.value, 'primaryColor')"
                />
                <span class="text-sm text-gray-600 dark:text-gray-400">{{ settings.primaryColor }}</span>
              </div>
            </div>
            
            <!-- Secondary Color -->
            <div>
              <label for="pdf_secondary_color" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Secondary Color
              </label>
              <div class="flex items-center gap-2">
                <ColorPicker
                  v-model="settings.pdfSecondaryColor"
                  format="hex"
                  defaultColor="#64748b"
                  inputId="pdf_secondary_color"
                  @change="(e) => handleColorChange(e.value, 'pdfSecondaryColor')"
                />
                <span class="text-sm text-gray-600 dark:text-gray-400">{{ settings.pdfSecondaryColor }}</span>
              </div>
            </div>

            <!-- Background Color -->
            <div>
              <label for="pdf_background_color" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Background Color
              </label>
              <div class="flex items-center gap-2">
                <ColorPicker
                  v-model="settings.pdfBackgroundColor"
                  format="hex"
                  defaultColor="#f8f9fa"
                  inputId="pdf_background_color"
                  @change="(e) => handleColorChange(e.value, 'pdfBackgroundColor')"
                />
                <span class="text-sm text-gray-600 dark:text-gray-400">{{ settings.pdfBackgroundColor }}</span>
              </div>
            </div>

            <!-- Table Border Color -->
            <div>
              <label for="pdf_table_border_color" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Table Border Color
              </label>
              <div class="flex items-center gap-2">
                <ColorPicker
                  v-model="settings.pdfTableBorderColor"
                  format="hex"
                  defaultColor="#e2e8f0"
                  inputId="pdf_table_border_color"
                  @change="(e) => handleColorChange(e.value, 'pdfTableBorderColor')"
                />
                <span class="text-sm text-gray-600 dark:text-gray-400">{{ settings.pdfTableBorderColor }}</span>
              </div>
            </div>

            <!-- Page Margin -->
            <div>
              <label for="pdf_page_margin" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Page Margin (points)
              </label>
              <input
                type="number"
                id="pdf_page_margin"
                v-model="settings.pdfPageMargin"
                min="0"
                max="100"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="50"
              />
            </div>

            <!-- Watermark Text -->
            <div class="md:col-span-2">
              <label for="pdf_watermark_text" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Watermark Text (optional)
              </label>
              <input
                type="text"
                id="pdf_watermark_text"
                v-model="settings.pdfWatermarkText"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="Leave empty for no watermark"
              />
            </div>
          </div>
        </div>
        
        <!-- Invoice Settings -->
        <div>
          <h3 class="text-base font-medium text-gray-900 dark:text-white mb-3">Invoice Settings</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label for="invoice_prefix" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Invoice Number Prefix
              </label>
              <input
                type="text"
                id="invoice_prefix"
                v-model="settings.invoicePrefix"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="INV-"
              />
            </div>
            <div>
              <label for="invoice_due_days" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Default Due Days
              </label>
              <input
                type="number"
                id="invoice_due_days"
                v-model="settings.invoiceDueDays"
                min="1"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="30"
              />
            </div>
            <div class="md:col-span-2">
              <label for="default_invoice_terms" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Default Invoice Terms
              </label>
              <textarea
                id="default_invoice_terms"
                v-model="settings.defaultInvoiceTerms"
                rows="3"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="Payment is due within {due_days} days from the date of invoice."
              ></textarea>
              <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                Use <code>{due_days}</code> as a placeholder for the due days value.
              </p>
            </div>
            <div class="md:col-span-2">
              <label for="pdf_invoice_footer" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                PDF Footer Text
              </label>
              <textarea
                id="pdf_invoice_footer"
                v-model="settings.pdfInvoiceFooter"
                rows="2"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="Thank you for your business."
              ></textarea>
            </div>
          </div>
        </div>
        
        <!-- Estimate Settings -->
        <div>
          <h3 class="text-base font-medium text-gray-900 dark:text-white mb-3">Estimate Settings</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label for="estimate_prefix" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Estimate Number Prefix
              </label>
              <input
                type="text"
                id="estimate_prefix"
                v-model="settings.estimatePrefix"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="EST-"
              />
            </div>
            <div>
              <label for="estimate_valid_days" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Default Valid Days
              </label>
              <input
                type="number"
                id="estimate_valid_days"
                v-model="settings.estimateValidDays"
                min="1"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="30"
              />
            </div>
            <div class="md:col-span-2">
              <label for="default_estimate_terms" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Default Estimate Terms
              </label>
              <textarea
                id="default_estimate_terms"
                v-model="settings.defaultEstimateTerms"
                rows="3"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="This estimate is valid for {valid_days} days from the date issued."
              ></textarea>
              <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                Use <code>{valid_days}</code> as a placeholder for the valid days value.
              </p>
            </div>
            <div class="md:col-span-2">
              <label for="pdf_estimate_footer" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                PDF Footer Text
              </label>
              <textarea
                id="pdf_estimate_footer"
                v-model="settings.pdfEstimateFooter"
                rows="2"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="Thank you for considering our services."
              ></textarea>
            </div>
          </div>
        </div>
        
        <!-- Save Button -->
        <div class="pt-5">
          <div class="flex justify-end">
            <button
              type="submit"
              :disabled="isSaving"
              class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 dark:bg-blue-500 dark:hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <span v-if="isSaving" class="flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                </svg>
                Saving...
              </span>
              <span v-else>Save Settings</span>
            </button>
          </div>
          <div v-if="saveStatus" class="mt-3 text-right">
            <div 
              class="inline-block px-3 py-1 rounded-md text-sm" 
              :class="saveStatus.type === 'success' ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'"
            >
              {{ saveStatus.message }}
            </div>
          </div>
        </div>
      </div>
    </form>
  </div>
</template>

<script setup>
import { toCamelCase, toSnakeCase, snakeToCamel } from '@/utils/casing';
import { ref, onMounted } from 'vue';
import ColorPicker from 'primevue/colorpicker';
import settingsService from '@/services/settings.service';
import apiService from '@/services/api.service';
import { BACKEND_URL } from '@/config';
import { isBlank, isValidHexColor, normalizeHexColor } from '@/utils/validation';

const logoChanged = ref(false);
const logoExplicitlyRemoved = ref(false);

// State (using camelCase keys)
const settings = ref({
  // Company Info
  companyName: '',
  companyAddress: '',
  companyPhone: '',
  companyEmail: '',
  companyWebsite: '',
  companyLogoPath: '',
  
  // PDF Appearance
  primaryColor: '#3b82f6',
  pdfSecondaryColor: '#64748b',
  pdfBackgroundColor: '#f8f9fa',
  pdfTableBorderColor: '#e2e8f0',
  pdfPageMargin: '50',
  pdfHeaderMargin: '30',
  pdfFooterMargin: '30',
  pdfWatermarkText: '',
  
  // Invoice Settings
  invoicePrefix: 'INV-',
  invoiceDueDays: '30',
  defaultInvoiceTerms: 'Payment is due within {due_days} days from the date of invoice. Late payments are subject to a 1.5% monthly fee.', // Placeholder {due_days} remains snake_case as it's for string replacement
  pdfInvoiceFooter: 'Thank you for your business. Please contact us with any questions regarding this invoice.',
  
  // Estimate Settings
  estimatePrefix: 'EST-',
  estimateValidDays: '30',
  defaultEstimateTerms: 'This estimate is valid for {valid_days} days from the date issued. To accept this estimate, please sign and return.', // Placeholder {valid_days} remains snake_case
  pdfEstimateFooter: 'Thank you for considering our services. Please contact us with any questions regarding this estimate.'
});

// Logo upload state
const logoInput = ref(null);
const logoPreview = ref('');
const uploadStatus = ref(null);

// Form state
const isSaving = ref(false);
const saveStatus = ref(null);

// Load settings on component mount
onMounted(async () => {
  try {
    const response = await settingsService.getAllSettings();
    console.log('Settings response:', response); // Debug log
    
    if (response && response.success && response.data) {
      // Populate settings from response, converting keys to camelCase
      const camelCaseSettings = {};
      for (const setting of response.data) {
        console.log('Setting:', setting.key, '=', setting.value); // Debug log
        const camelKey = snakeToCamel(setting.key); // Convert snake_case key to camelCase
        console.log('Converted key:', setting.key, '->', camelKey); // Debug log
        if (camelKey in settings.value) { // Check if the camelCase key exists in our ref
          camelCaseSettings[camelKey] = setting.value;
          console.log('Assigned value to:', camelKey); // Debug log
        }
      }
      // Assign the converted settings to the ref
      Object.assign(settings.value, camelCaseSettings);
      
      // Set logo preview if available (using camelCase key)
      if (settings.value.companyLogoPath) {
        const logoUrl = `${BACKEND_URL}/uploads/logos/${settings.value.companyLogoPath}`;
        console.log('Logo URL:', logoUrl); // Debug log
        
        // Test if the image loads successfully
        const img = new Image();
        img.crossOrigin = 'anonymous'; // Handle CORS
        img.onload = () => {
          logoPreview.value = logoUrl;
          console.log('Logo loaded successfully');
        };
        img.onerror = () => {
          console.error('Failed to load logo:', logoUrl);
          // Don't set preview if image fails to load
          logoPreview.value = '';
          // Show error message but don't automatically clear the stored path
          uploadStatus.value = {
            type: 'error',
            message: 'The logo file could not be loaded. Please try uploading a new logo.'
          };
        };
        img.src = logoUrl;
      }
    }
  } catch (err) {
    console.error('Error loading settings:', err);
  }
});

// Handle logo upload
const handleLogoUpload = async (event) => {
  try {
    uploadStatus.value = null;
    
    const file = event.target.files[0];
    if (!file) return;
    
    // Check file type
    if (!file.type.startsWith('image/')) {
      uploadStatus.value = {
        type: 'error',
        message: 'Only image files are allowed'
      };
      return;
    }
    
    // Check file size (max 2MB)
    const maxSize = 2 * 1024 * 1024;
    if (file.size > maxSize) {
      uploadStatus.value = {
        type: 'error',
        message: 'File size exceeds the limit (2MB)'
      };
      return;
    }
    
    // Create FormData
    const formData = new FormData();
    formData.append('logo', file);
    
    // Upload logo
    const response = await apiService.post('/upload/logo', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });
    
    if (response && response.success && response.data) {
      // Update logo preview with full backend URL
      logoPreview.value = `${BACKEND_URL}${response.data.path}`;
      settings.value.companyLogoPath = response.data.filename; // Use camelCase
      logoChanged.value = true; // Mark logo as changed
      
      uploadStatus.value = {
        type: 'success',
        message: 'Logo uploaded successfully'
      };
    } else {
      uploadStatus.value = {
        type: 'error',
        message: response?.message || 'Failed to upload logo'
      };
    }
  } catch (err) {
    console.error('Error uploading logo:', err);
    uploadStatus.value = {
      type: 'error',
      message: err.message || 'An unexpected error occurred'
    };
  } finally {
    // Reset file input
    if (logoInput.value) {
      logoInput.value.value = '';
    }
  }
};

// Handle logo removal
const handleLogoRemove = () => {
  // Clear logo preview
  logoPreview.value = '';
  // Set logo as explicitly removed (null) to signal deletion
  settings.value.companyLogoPath = null;
  logoExplicitlyRemoved.value = true;
  logoChanged.value = true; // Mark as changed
  
  uploadStatus.value = {
    type: 'success',
    message: 'Logo removed'
  };
  
  // Clear status after 3 seconds
  setTimeout(() => {
    uploadStatus.value = null;
  }, 3000);
};

// Handle color change from the ColorPicker
const handleColorChange = (color, fieldName) => {
  settings.value[fieldName] = normalizeHexColor(color);
};

// Handle image loading error
const handleImageError = (event) => {
  console.error('Failed to load logo preview image:', event.target.src);
  logoPreview.value = '';
  uploadStatus.value = {
    type: 'error',
    message: 'Error loading logo preview. The file may have been deleted.'
  };
};

// Save settings
const saveSettings = async () => {
  try {
    isSaving.value = true;
    saveStatus.value = null;

    // Validate and normalize color values (using camelCase keys)
    const colorFields = ['primaryColor', 'pdfSecondaryColor', 'pdfBackgroundColor', 'pdfTableBorderColor'];
    for (const field of colorFields) {
      // Normalize color format before validation
      settings.value[field] = normalizeHexColor(settings.value[field]);
      
      // Verify it's valid after normalization
      if (!isValidHexColor(settings.value[field])) {
        throw new Error(`Invalid color format for ${field}. Please use a valid hex color (e.g., #C0CBDA)`);
      }
    }
    
    // Prepare settings for API
    const updatedSettings = {};
    Object.entries(settings.value).forEach(([key, value]) => {
      updatedSettings[key] = value;
    });
    
    // Group settings by type (using camelCase keys)
    const groups = {
      company: [
        'companyName',
        'companyAddress',
        'companyPhone',
        'companyEmail',
        'companyWebsite',
        'companyLogoPath'
      ],
      appearance: [
        'primaryColor',
        'pdfSecondaryColor',
        'pdfBackgroundColor',
        'pdfTableBorderColor',
        'pdfPageMargin',
        'pdfHeaderMargin',
        'pdfFooterMargin',
        'pdfWatermarkText'
      ],
      invoice: [
        'invoicePrefix',
        'invoiceDueDays',
        'defaultInvoiceTerms',
        'pdfInvoiceFooter'
      ],
      estimate: [
        'estimatePrefix',
        'estimateValidDays',
        'defaultEstimateTerms',
        'pdfEstimateFooter'
      ]
    };
    
    // Save settings by group
    for (const [group, keys] of Object.entries(groups)) {
      const groupSettings = {};
      
      // Special handling for the company group to only include logo if changed
      if (group === 'company') {
        keys.forEach(key => {
          if (key === 'companyLogoPath') {
            // Special handling for logo path
            if (logoChanged.value) {
              // If explicitly removed, set to null to signal deletion
              if (logoExplicitlyRemoved.value) {
                groupSettings[key] = null; // Explicit null signals deletion
              } else {
                // Otherwise use the new value if not blank
                const val = settings.value[key];
                if (!isBlank(val)) {
                  groupSettings[key] = val;
                }
              }
            }
          } else {
            // For other keys, apply the non-empty check using isBlank
            const val = settings.value[key];
            if (!isBlank(val)) {
              groupSettings[key] = val;
            }
          }
        });
      } else {
        // Handle other groups normally, checking for empty values with isBlank
        keys.forEach(key => {
          const val = settings.value[key];
          if (!isBlank(val)) {
            groupSettings[key] = val;
          }
        });
      }
      
      // Convert the groupSettings object keys to snake_case before sending
      const snakeCaseGroupSettings = toSnakeCase(groupSettings);
      
      // Only proceed if there are settings to update
      if (Object.keys(snakeCaseGroupSettings).length > 0) {
        await settingsService.updateMultipleSettings(snakeCaseGroupSettings, group);
      }
    }
    
    saveStatus.value = {
      type: 'success',
      message: 'Settings saved successfully'
    };
    
    // Clear status after 3 seconds
    setTimeout(() => {
      saveStatus.value = null;
    }, 3000);
  } catch (err) {
    console.error('Error saving settings:', err);
    saveStatus.value = {
      type: 'error',
      message: err.message || 'Failed to save settings'
    };
  } finally {
    isSaving.value = false;
  }
};
</script>

<style>
/* Basic z-index styles for potential overlay issues */
.pdf-settings .color-setting-group {
  position: relative;
}

/* Add dark mode support for better contrast */
@media (prefers-color-scheme: dark) {
  .p-colorpicker-panel {
    background-color: #1e293b !important;
    border-color: #475569 !important;
  }
  
  .p-colorpicker-color-handle,
  .p-colorpicker-hue-handle {
    border-color: #fff !important;
  }
}
</style>
